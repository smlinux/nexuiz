float PUSH_ONCE			= 1;
float PUSH_SILENT		= 2;

.float pushltime;
void() trigger_push_touch =
{
	local float flighttime, dist, grav;
	local vector org;

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

	org = other.origin;

	if (other.classname == "player")
	{
		local float i;
		local float found;
		sound (other, CHAN_ITEM, "misc/jumppad.ogg", 1, ATTN_NORM);
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

	// figure out how long it will take to hit the point considering gravity
	grav = cvar("sv_gravity");
	flighttime = sqrt((self.enemy.origin_z - org_z) / (0.5 * grav));
	if (!flighttime)
		return;

	// how far in X and Y to move
	self.movedir = (self.enemy.origin - org);
	self.movedir_z = 0;
	dist = vlen(self.movedir);

	// finally calculate the velocity
	self.movedir = normalize(self.movedir) * (dist / flighttime);
	self.movedir_z = flighttime * grav;

	other.flags = other.flags - (other.flags & FL_ONGROUND);
	// reset tracking of oldvelocity for impact damage (sudden velocity changes)
	other.oldvelocity = other.velocity = self.movedir;
	// reset tracking of who pushed you into a hazard (for kill credit)
	other.pushltime = 0;

	if (other.classname == "missile")
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
	local float grav;
	local float flighttime;
	local float dist;
	local vector org;

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

		// figure out how long it will take to hit the point considering gravity
		grav = cvar("sv_gravity");
		flighttime = sqrt((self.enemy.origin_z - org_z) / (0.5 * grav));
		if (!flighttime)
		{
			objerror("trigger_push: jump pad with bad destination\n");
			remove(self);
			return;
		}

		// how far in X and Y to move
		self.movedir = (self.enemy.origin - org);
		self.movedir_z = 0;
		dist = vlen(self.movedir);

		// finally calculate the velocity
		self.movedir = normalize(self.movedir) * (dist / flighttime);
		self.movedir_z = flighttime * grav;
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

void() trigger_push =
{
	if (self.angles != '0 0 0')
		SetMovedir ();

	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";

	self.touch = trigger_push_touch;

	// normal push setup
	if (!self.speed)
		self.speed = 1000;
	self.movedir = self.movedir * self.speed * 10;

	// this must be called to spawn the teleport waypoints for bots
	self.think = trigger_push_findtarget;
	self.nextthink = time + 0.2;
};

void() target_push = {};
void() info_notnull = {};
void() target_position = {};
