float PUSH_ONCE			= 1;
float PUSH_SILENT		= 2;

// TODO: add sounds
void() trigger_push_touch =
{
	local float flighttime, dist, grav;
	local vector org;

	if (!other.health)
		return;

	// where the center is
	//org = (self.absmin + self.absmax) * 0.5;
	org = other.origin;

	// figure out how long it will take to hit the point considering gravity
	grav = cvar("sv_gravity");
	flighttime = sqrt((self.enemy.origin_z - org_z) / (0.5 * grav));
	if (!flighttime)
	{
	//	remove(self);
		return;
	}

	// how far in X and Y to move
	self.movedir = (self.enemy.origin - org);
	self.movedir_z = 0;
	dist = vlen(self.movedir);

	// finally calculate the velocity
	self.movedir = normalize(self.movedir) * (dist / flighttime);
	self.movedir_z = flighttime * grav;

	other.velocity = self.movedir;

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
		objerror("trigger_push: target not found\n");
};

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE SILENT
Improved version of normal trigger_push.

Pushes anything that touches it,
or acts as a jump pad, hitting "target"
at the apogee (peak) of the jump.

Target should be an info_notnull.

Flags:
"PUSH_ONCE" - removes itself after push
"SILENT" - no 'windtunnel' noise
Keys:
"target" - acts as jump pad, hits this entity
*/

void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
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

void() info_notnull = {};
void() target_position = {};
