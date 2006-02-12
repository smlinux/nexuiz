float PUSH_ONCE			= 1;
float PUSH_SILENT		= 2;

.float pushltime;
void() trigger_push_touch =
{
	local float flighttime, dist, grav;
	local vector org;

	if (other.classname != "player" && other.classname != "corpse" && other.classname != "body" && other.classname != "gib" && other.classname != "missile" && other.classname != "casing" && other.classname != "grenade" && other.classname != "plasma" && other.classname != "plasma_prim" && other.classname != "plasma_chain")
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
		sound (other, CHAN_ITEM, "misc/jumppad.ogg", 1, ATTN_NORM);

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

void() trigger_push_findtarget =
{
	// find the target
	self.enemy = find(world, targetname, self.target);
	if (!self.enemy)
	{
		objerror("trigger_push: target not found\n");
		remove(self);
	}
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

	// check if this is a jump pad
	if (self.target)
	{
		self.think = trigger_push_findtarget;
		self.nextthink = time + 0.2;
	}
	else
	{
		// normal push setup
		if (!self.speed)
			self.speed = 1000;
		self.movedir = self.movedir * self.speed * 10;
	}
};

void() target_push = {};
void() info_notnull = {};
void() target_position = {};
