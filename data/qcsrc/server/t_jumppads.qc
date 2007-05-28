float PUSH_ONCE			= 1;
float PUSH_SILENT		= 2;

.float pushltime;
.float height;

float trigger_push_calculatevelocity_flighttime;

/*
	trigger_push_calculatevelocity

	Arguments:
	  org - origin of the object which is to be pushed
	  tgt - target entity (can be either a point or a model entity; if it is
	        the latter, its midpoint is used)
	  ht  - jump height, measured from the higher one of org and tgt's midpoint

	Returns: velocity for the jump
	the global trigger_push_calculatevelocity_flighttime is set to the total
	jump time
 */

vector(vector org, entity tgt, float ht) trigger_push_calculatevelocity =
{
	local float grav, sdist, zdist, vs, vz, jumpheight, trajsign;
	local vector sdir, torg;

	torg = tgt.origin + (tgt.mins + tgt.maxs) * 0.5;

	grav = cvar("sv_gravity");

	zdist = torg_z - org_z;
	sdist = vlen(torg - org - zdist * '0 0 1');
	sdir = normalize(torg - org - zdist * '0 0 1');

	// how high do we need to push the player?
	jumpheight = fabs(ht);
	if(zdist > 0)
		jumpheight = jumpheight + zdist;

	/*
		STOP.

		You will not understand the following equations anyway...
		But here is what I did to get them.

		I used the functions

		  s(t) = t * vs
		  z(t) = t * vz - 1/2 grav t^2

		and solved for:

		  s(ti) = sdist
		  z(ti) = zdist
		  max(z, ti) = jumpheight

		From these three equations, you will find the three parameters vs, vz
		and ti.
	 */

	// push him so high...
	vz = sqrt(2 * grav * jumpheight); // NOTE: sqrt(positive)!
	if(ht < 0)
		if(zdist < 0)
			vz = -vz;

	// how far to push him?
	if(zdist == 0)
	{
		trigger_push_calculatevelocity_flighttime = sqrt(jumpheight * 8 / grav);
		vs = sdist / trigger_push_calculatevelocity_flighttime;
			// trajsign is ignored (the high point MUST be inside the jump!)
	}
	else
	{
		if(ht > 0)
			trajsign = +1;
		else
			trajsign = -1;

		// >0: the lower speed that achieves "it"
		//     (parabola's maximum inside the jump)
		// <0: the higher speed that achieves "it"
		//     (parabola's maximum outside the jump)

		vs = sqrt(jumpheight - zdist);
		vs = sqrt(jumpheight) - trajsign * vs; // fteqcc sucks
		vs = fabs(vs * sqrt(grav/2) / zdist);
		//vs = fabs((sdist / zdist) * sqrt(grav/2) * (sqrt(jumpheight) - trajsign * sqrt(jumpheight - zdist)));
		trigger_push_calculatevelocity_flighttime = 1 / vs;
			// note: vs cannot be zero here. The difference between the sqrts is zero IFF zdist == 0, which we have excluded.
		vs = vs * sdist;

		// cases to test: "jump up", "jump down" with positive and negative height
	}

	// finally calculate the velocity
	return sdir * vs + '0 0 1' * vz;
}

void() trigger_push_touch =
{
	// FIXME: add a .float for whether an entity should be tossed by jumppads
	if (other.classname != "player")
	if (other.classname != "corpse")
	if (other.classname != "body")
	if (other.classname != "gib")
	if (other.classname != "missile")
	if (other.classname != "casing")
	if (other.classname != "grenade")
	if (other.classname != "plasma")
	if (other.classname != "plasma_prim")
	if (other.classname != "plasma_chain")
	if (other.classname != "droppedweapon")
		return;

	if (other.deadflag && other.classname == "player")
		return;

	if (!self.target)
	{
		other.velocity = self.movedir;
		other.flags = other.flags - (other.flags & FL_ONGROUND);
		return;
	}

	if (other.classname == "player")
	{
		if(self.pushltime < time)  // prevent "snorring" sound when a player hits the jumppad more than once
		{
			// flash when activated
			te_smallflash(other.origin);
			sound (other, CHAN_ITEM, "misc/jumppad.wav", 1, ATTN_NORM);
			self.pushltime = time + 0.2;
		}
		if(clienttype(other) == CLIENTTYPE_REAL)
		{
			local float i;
			local float found;
			found = FALSE;
			for(i = 0; i < other.jumppadcount && i < NUM_JUMPPADSUSED; ++i)
				if(other.(jumppadsused[i]) == self)
					found = TRUE;
			if(!found)
			{
				other.(jumppadsused[math_mod(other.jumppadcount, NUM_JUMPPADSUSED)]) = self;
				other.jumppadcount = other.jumppadcount + 1;
			}
		}
		else
			other.jumppadcount = TRUE;
	}

	self.movedir = trigger_push_calculatevelocity(other.origin, self.enemy, self.height);

	other.flags = other.flags - (other.flags & FL_ONGROUND);
	// reset tracking of oldvelocity for impact damage (sudden velocity changes)
	other.oldvelocity = other.velocity = self.movedir;
	// reset tracking of who pushed you into a hazard (for kill credit)
	other.pushltime = 0;

	if (other.flags & FL_PROJECTILE)
		other.angles = vectoangles (other.velocity);

	if (self.spawnflags & PUSH_ONCE)
	{
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time;
	}
};

.vector dest;

void() trigger_push_findtarget =
{
	local entity e;
	local vector org;
	local float flighttime;

	// first calculate a typical start point for the jump
	org = (self.absmin + self.absmax) * 0.5;
	org_z = self.absmax_z - PL_MIN_z;

	if (self.target)
	{
		// find the target
		self.enemy = find(world, targetname, self.target);
		if (!self.enemy)
		{
			objerror("trigger_push: target not found\n");
			remove(self);
			return;
		}

		self.movedir = trigger_push_calculatevelocity(org, self.enemy, self.height);
		flighttime = trigger_push_calculatevelocity_flighttime;
	}
	else
		flighttime = 0;

	// calculate the destination and spawn a teleporter waypoint
	e = spawn();
	setorigin(e, org);
	setsize(e, PL_MIN, PL_MAX);
	e.velocity = self.movedir;
	tracetoss(e, e);
	self.dest = trace_endpos;
	remove(e);

	waypoint_spawnforteleporter(self, self.dest, flighttime);
};

/*
 * ENTITY PARAMETERS:
 *
 *   target:  target of jump
 *   height:  the absolute value is the height of the highest point of the jump
 *            trajectory above the higher one of the player and the target.
 *            the sign indicates whether the highest point is INSIDE (positive)
 *            or OUTSIDE (negative) of the jump trajectory. General rule: use
 *            positive values for targets mounted on the floor, and use negative
 *            values to target a point on the ceiling.
 *   movedir: if target is not set, this * speed * 10 is the velocity to be reached.
 */
void() trigger_push =
{
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model); // no precision needed
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";

	self.touch = trigger_push_touch;

	// normal push setup
	if (!self.speed)
		self.speed = 1000;
	self.movedir = self.movedir * self.speed * 10;

	if (self.target)
		precache_sound ("misc/jumppad.wav");

	// this must be called to spawn the teleport waypoints for bots
	self.think = trigger_push_findtarget;
	self.nextthink = time + 0.2;
};

void() target_push = {};
void() info_notnull = {};
void() target_position = {};
