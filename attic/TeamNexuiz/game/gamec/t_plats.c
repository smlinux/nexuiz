/*void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
	local entity trigger;
	local vector tmin, tmax;

	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;

	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;

	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}

	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = 1;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = 2;
};

void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = 3;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = 4;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == 2)
		plat_go_up ();
	else if (self.state == 1)
		self.nextthink = self.ltime + 1;	// delay going down
};

void() plat_outside_touch =
{
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == 1)
		plat_go_down ();
};

void() plat_trigger_use =
{
	if (self.think)
		return;		// allready activated
	plat_go_down();
};


void() plat_crush =
{
	if (self.state == 4)
		plat_go_down ();
	else if (self.state == 3)
		plat_go_up ();
	else
		objerror ("plat_crush: bad self.state\n");
};

void() plat_use =
{
	self.use = SUB_Null;
	if (self.state != 4)
		objerror ("plat_use: not in up state");
	plat_go_down();
};


.string sound1, sound2;

void() func_plat =
{
	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	if (self.sound1)
	{
		precache_sound (self.sound1);
		self.noise = self.sound1;
	}
	if (self.sound2)
	{
		precache_sound (self.sound2);
		self.noise1 = self.sound2;
	}

	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;
	if (!self.speed)
		self.speed = 150;
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	self.pos2_z = self.origin_z - self.size_z + 8;

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger

	if (self.targetname)
	{
		self.state = 4;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = 2;
	}
};


/*
void() train_next;
void() func_train_find;

void() train_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
};
void() train_use =
{
	if (self.think != func_train_find)
		return;
	train_next();
};

void() train_wait =
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
		self.nextthink = self.ltime + 0.1;

	self.think = train_next;
};

void() train_next =
{
	local entity targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror ("train_next: no next target");
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	SUB_CalcMove (targ.origin - self.mins, self.speed, train_wait);
};

void() func_train_find =
{
	local entity targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin - self.mins);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};


void() func_train =
{
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};
*/

void() train_next;			// temp
/*void() train_wait =
{
	self.think = train_next;
	self.nextthink = self.ltime + self.wait;
};

/*void() train_next =
{
	local entity targ;
	targ = find(world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror("train_next: no next target");
	self.wait = targ.wait;
	if (!self.wait)
		self.wait = 0.1;
	if (targ.speed)
		SUB_CalcMove(targ.origin - self.mins, targ.speed, train_wait);
	else
		SUB_CalcMove(targ.origin - self.mins, self.speed, train_wait);
};*/
/*						//temp
void() func_train_find =
{
	local entity targ;
	targ = find(world, targetname, self.target);
	self.target = targ.target;
	setorigin(self, targ.origin - self.mins);
	self.nextthink = self.ltime + 1;
	self.think = train_next;
};

/*QUAKED func_train (0 .5 .8) ?
Ridable platform, targets path_corner path to follow.
speed : speed the train moves (can be overridden by each path_corner)
target : targetname of first path_corner (starts here)
*/
/*void() func_train =
{
	if (!self.target)
		objerror("func_train without a target");
	if (!self.speed)
		self.speed = 100;

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

	// wait for targets to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

/*QUAKED func_rotating (0 .5 .8) ? - - X_AXIS Y_AXIS
Brush model that spins in place on one axis (default Z).
speed : speed to rotate (in degrees per second)
noise : path/name of looping .wav file to play.
*/
void() func_rotating =
{
	if (self.noise)
	{
		precache_sound(self.noise);
		ambientsound(self.origin, self.noise, 1, ATTN_IDLE);
	}
	if (!self.speed)
		self.speed = 100;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	if (self.spawnflags & 4) // X (untested)
		self.avelocity = '0 0 1' * self.speed;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	else if (self.spawnflags & 8) // Y (untested)
		self.avelocity = '1 0 0' * self.speed;
	// FIXME: test if this turns the right way, then remove this comment (negate as needed)
	else // Z
		self.avelocity = '0 1 0' * self.speed;

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

	// wait for targets to spawn
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_Null;
};

.float height;
.float phase;
void() func_bobbing_controller_think =
{
	local vector v;
	self.nextthink = time + 0.1;
	// calculate sinewave using makevectors
	makevectors((time * self.owner.cnt + self.owner.phase) * '0 1 0');
	v = self.owner.destvec + self.owner.movedir * v_forward_y;
	// * 10 so it will arrive in 0.1 sec
	self.owner.velocity = (v - self.owner.origin) * 10;
};

/*QUAKED func_bobbing (0 .5 .8) ? X_AXIS Y_AXIS
Brush model that moves back and forth on one axis (default Z).
speed : how long one cycle takes in seconds (default 4)
height : how far the cycle moves (default 32)
phase : cycle timing adjustment (0-1 as a fraction of the cycle, default 0)
noise : path/name of looping .wav file to play.
*/
void() func_bobbing =
{
	local entity controller;
	if (self.noise)
	{
		precache_sound(self.noise);
		ambientsound(self.origin, self.noise, 1, ATTN_IDLE);
	}
	if (!self.speed)
		self.speed = 4;
	if (!self.height)
		self.height = 32;
	// center of bobbing motion
	self.destvec = self.origin;
	// time scale to get degrees
	self.cnt = 360 / self.speed;
	// how far to bob
	if (self.spawnflags & 1) // X
		self.movedir = '1 0 0' * self.height;
	else if (self.spawnflags & 2) // Y
		self.movedir = '0 1 0' * self.height;
	else // Z
		self.movedir = '0 0 1' * self.height;

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

	// wait for targets to spawn
	controller = spawn();
	controller.classname = "func_bobbing_controller";
	controller.owner = self;
	controller.nextthink = time + 1;
	controller.think = func_bobbing_controller_think;
	self.nextthink = self.ltime + 999999999;
	self.think = SUB_Null;
};
