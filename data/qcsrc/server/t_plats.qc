
float	STATE_TOP		= 0;
float	STATE_BOTTOM	= 1;
float	STATE_UP		= 2;
float	STATE_DOWN		= 3;

.entity trigger_field;
//.float dmgtime;
.float dmgtime2;

void() plat_center_touch;
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
    if((self.spawnflags & 4) && (other.takedamage != DAMAGE_NO)) { // KIll Kill Kill!!
        Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    } else {
        if((self.dmg) && (other.takedamage != DAMAGE_NO)) {   // Shall we bite?
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
            // Gib dead/dying stuff
            if(other.deadflag != DEAD_NO)
                Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
        }

        if (self.state == 4)
            plat_go_down ();
        else if (self.state == 3)
            plat_go_up ();
        else
            objerror ("plat_crush: bad self.state\n");
    }
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

    if(self.spawnflags & 4)
        self.dmg = 10000;

    if(self.dmg && (!self.message))
		self.message = "was in the wrong place.";

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
	setmodel (self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;
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

	setmodel (self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};
*/

void() train_next;
void() train_wait =
{
	self.think = train_next;
	self.nextthink = self.ltime + self.wait;
};

void() train_next =
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
};

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
void() func_train =
{
	if (!self.target)
		objerror("func_train without a target");
	if (!self.speed)
		self.speed = 100;

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

	// wait for targets to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};



void() rotating_blocked =
{

    if(self.dmg && other.takedamage != DAMAGE_NO) {
        if(self.dmgtime2 < time) {
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
            self.dmgtime2 = time + self.dmgtime;
        }

        // Gib dead/dying stuff
        if(other.deadflag != DEAD_NO)
            Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    }


}

/*QUAKED func_rotating (0 .5 .8) ? - - X_AXIS Y_AXIS
Brush model that spins in place on one axis (default Z).
speed   : speed to rotate (in degrees per second)
noise   : path/name of looping .wav file to play.
dmg     : Do this mutch dmg every .dmgtime intervall when blocked
dmgtime : See above.
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

    if(self.dmg & (!self.message))
        self.message = " was in the wrong place.";


    if(self.dmg && (!self.dmgtime))
        self.dmgtime = 0.25;

    self.dmgtime2 = time;


	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model); // no lowprecision here! evil!
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);

    self.blocked = rotating_blocked;

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

void() bobbing_blocked =
{
	// no need to duplicate code
	rotating_blocked();
}

/*QUAKED func_bobbing (0 .5 .8) ? X_AXIS Y_AXIS
Brush model that moves back and forth on one axis (default Z).
speed : how long one cycle takes in seconds (default 4)
height : how far the cycle moves (default 32)
phase : cycle timing adjustment (0-1 as a fraction of the cycle, default 0)
noise : path/name of looping .wav file to play.
dmg : Do this mutch dmg every .dmgtime intervall when blocked
dmgtime : See above.
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

	// damage when blocked
	self.blocked = bobbing_blocked;
	if(self.dmg & (!self.message))
		self.message = " was in the wrong place.";
	if(self.dmg && (!self.dmgtime))
		self.dmgtime = 0.25;
	self.dmgtime2 = time;

	// how far to bob
	if (self.spawnflags & 1) // X
		self.movedir = '1 0 0' * self.height;
	else if (self.spawnflags & 2) // Y
		self.movedir = '0 1 0' * self.height;
	else // Z
		self.movedir = '0 0 1' * self.height;

	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;

	setmodel(self, self.model); // precision set below
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

	// Savage: Reduce bandwith, critical on e.g. nexdm02
	self.effects |= EF_LOWPRECISION;
};

// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{
	// do nothing, just don't come all the way back out
};


void() button_fire =
{
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;    // will be reset upon return

	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	if (self.noise != "")
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
//	if (activator.classname != "player")
//	{
//		dprint(activator.classname);
//		dprint(" triggered a button\n");
//	}
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
//	if (activator.classname != "player")
//	{
//		dprint(activator.classname);
//		dprint(" touched a button\n");
//	}
	if (!other)
		return;
	if (other.classname != "player")
		return;
	self.enemy = other;
	if (other.owner)
		self.enemy = other.owner;
	button_fire ();
};

void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) button_damage =
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
	//	if (activator.classname != "player")
	//	{
	//		dprint(activator.classname);
	//		dprint(" killed a button\n");
	//	}
		self.enemy = damage_attacker;
		button_fire ();
	}
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched. If set to -1, the button will fire on ANY attack, even damageless ones like the MinstaGib laser
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void() func_button =
{
	SetMovedir ();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;

	self.blocked = button_blocked;
	self.use = button_use;

//	if (self.health == 0) // all buttons are now shootable
//		self.health = 10;
	if (self.health)
	{
		self.max_health = self.health;
		self.event_damage = button_damage;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
};


float DOOR_START_OPEN = 1;
float DOOR_DONT_LINK = 4;
float DOOR_TOGGLE = 32;

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.

Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

/*
=============================================================================

THINK FUNCTIONS

=============================================================================
*/

void() door_go_down;
void() door_go_up;

void() door_blocked =
{

    if((self.spawnflags & 4) && (other.takedamage != DAMAGE_NO)) { // KIll Kill Kill!!
        Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
    } else {

        if((self.dmg) && (other.takedamage == DAMAGE_YES))    // Shall we bite?
            Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');

         //Dont chamge direction for dead or dying stuff
        if(other.deadflag != DEAD_NO && (other.takedamage == DAMAGE_NO)) {
            if (self.wait >= 0)
            {
                if (self.state == STATE_DOWN)
                    door_go_up ();
                else
                    door_go_down ();
            }
        } else {
            //gib dying stuff just to make sure
            if((self.dmg) && (other.takedamage != DAMAGE_NO))    // Shall we bite?
                Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
        }
    }

	//T_Damage (other, self, self, self.dmg, self.dmg, self.deathtype, DT_IMPACT, (self.absmin + self.absmax) * 0.5, '0 0 0', Obituary_Generic);
// if a door has a negative wait, it would never come back if blocked,
// so let it just squash the object to death real fast
/*	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
			door_go_up ();
		else
			door_go_down ();
	}
*/
};


void() door_hit_top =
{
	if (self.noise1 != "")
		sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	if (self.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically
	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom =
{
	if (self.noise1 != "")
		sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() door_go_down =
{
	if (self.noise2 != "")
		sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}

	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up =
{
	if (self.state == STATE_UP)
		return;		// allready going up

	if (self.state == STATE_TOP)
	{	// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}

	if (self.noise2 != "")
		sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);

	SUB_UseTargets();
};


/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

void() door_fire =
{
	local entity 	oself;
	local entity	starte;

	if (self.owner != self)
		objerror ("door_fire: self.owner != self");

	self.message = ""; // no more message
	oself = self;

	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP)
		{
			starte = self;
			do
			{
				door_go_down ();
				self = self.enemy;
			} while ( (self != starte) && (self != world) );
			self = oself;
			return;
		}
	}

// trigger all paired doors
	starte = self;
	do
	{
		door_go_up ();
		self = self.enemy;
	} while ( (self != starte) && (self != world) );
	self = oself;
};


void() door_use =
{
	local entity oself;

	//dprint("door_use (model: ");dprint(self.model);dprint(")\n");
	self.message = "";			// door message are for touch only
	if (self.owner)
		self.owner.message = "";
	if (self.enemy)
		self.enemy.message = "";
	if (self.owner)
	{
		oself = self;
		self = self.owner;
		door_fire ();
		self = oself;
	}
};


void() door_trigger_touch =
{
	if (other.health < 1)
		return;

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 1;

	activator = other;

	self = self.owner;
	door_use ();
};


void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) door_damage =
{
	local entity oself;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		oself = self;
		self = self.owner;
		self.health = self.max_health;
		self.takedamage = DAMAGE_NO;	// wil be reset upon return
		door_use ();
		self = oself;
	}
};


/*
================
door_touch

Prints messages
================
*/
void() door_touch =
{
	if (other.classname != "player")
		return;
	if (self.owner.attack_finished > time)
		return;

	self.owner.attack_finished = time + 2;

	if (self.owner.message != "")
	{
		if (other.flags & FL_CLIENT)
			centerprint (other, self.owner.message);
		sound (other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
};

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/


entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity	trigger;
	local	vector	t1, t2;

	trigger = spawn();
	trigger.classname = "doortriggerfield";
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
};


float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x)
		return FALSE;
	if (e1.mins_y > e2.maxs_y)
		return FALSE;
	if (e1.mins_z > e2.maxs_z)
		return FALSE;
	if (e1.maxs_x < e2.mins_x)
		return FALSE;
	if (e1.maxs_y < e2.mins_y)
		return FALSE;
	if (e1.maxs_z < e2.mins_z)
		return FALSE;
	return TRUE;
};


/*
=============
LinkDoors


=============
*/
void() LinkDoors =
{
	local entity	t, starte;
	local vector	cmins, cmaxs;

	if (self.enemy)
		return;		// already linked by another door
	if (self.spawnflags & 4)
	{
		self.owner = self.enemy = self;
		return;		// don't want to link this door
	}

	cmins = self.mins;
	cmaxs = self.maxs;

	starte = self;
	t = self;

	do
	{
		self.owner = starte;			// master door

		if (self.health)
			starte.health = self.health;
		if (self.targetname)
			starte.targetname = self.targetname;
		if (self.message != "")
			starte.message = self.message;

		t = find(t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;		// make the chain a loop

		// shootable, or triggered doors just needed the owner/enemy links,
		// they don't spawn a field

			self = self.owner;

			if (self.health)
				return;
			if (self.targetname)
				return;
			if (self.items)
				return;

			self.owner.trigger_field = spawn_field(cmins, cmaxs);

			return;
		}

		if (EntitiesTouching(self,t))
		{
			if (t.enemy)
				objerror ("cross connected doors");

			self.enemy = t;
			self = t;

			if (t.mins_x < cmins_x)
				cmins_x = t.mins_x;
			if (t.mins_y < cmins_y)
				cmins_y = t.mins_y;
			if (t.mins_z < cmins_z)
				cmins_z = t.mins_z;
			if (t.maxs_x > cmaxs_x)
				cmaxs_x = t.maxs_x;
			if (t.maxs_y > cmaxs_y)
				cmaxs_y = t.maxs_y;
			if (t.maxs_z > cmaxs_z)
				cmaxs_z = t.maxs_z;
		}
	} while (1 );

};


/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK x x TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
FIXME: only one sound set available at the time being

*/

void() func_door =
{
	//if (!self.deathtype) // map makers can override this
	//	self.deathtype = " got in the way";
	SetMovedir ();

	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);
	setmodel (self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;
	self.classname = "door";

	self.blocked = door_blocked;
	self.use = door_use;

    if(self.targetname == "") {
        self.spawnflags = 0;
        self.dmg = 0;
    }

    if(self.spawnflags & 4)
        self.dmg = 10000;

    if(self.dmg & (!self.message))
		self.message = "was in the wrong place.";



	if (self.sounds > 0)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise2 = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}

	if (!self.speed)
		self.speed = 100;
	if (!self.wait)
		self.wait = 3;
	if (!self.lip)
		self.lip = 8;
	if (!self.dmg)
		self.dmg = 2;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);

// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN)
	{
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	self.state = STATE_BOTTOM;

	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.event_damage = door_damage;
	}

	if (self.items)
		self.wait = -1;

	self.touch = door_touch;

// LinkDoors can't be done until all of the doors have been spawned, so
// the sizes can be detected properly.
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
};

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

float SECRET_OPEN_ONCE = 1;		// stays open
float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
float SECRET_NO_SHOOT = 8;		// only opened by trigger
float SECRET_YES_SHOOT = 16;	// shootable even if targeted


void () fd_secret_use =
{
	local float temp;

	self.health = 10000;
	self.bot_attack = TRUE;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;

	self.message = ""; // no more message

	SUB_UseTargets();				// fire all targets / killtargets

	self.velocity = '0 0 0';

	// Make a sound, wait a little...

	if (self.noise1 != "")
		sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);

	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self.t_width = fabs(v_up * self.size);
		else
			self.t_width = fabs(v_right * self.size);
	}

	if (!self.t_length)
		self.t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);

	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

// Wait after first movement...
void () fd_secret_move1 =
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move2;
	if (self.noise3 != "")
		sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

// Start moving sideways w/sound...
void () fd_secret_move2 =
{
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

// Wait here until time to go back...
void () fd_secret_move3 =
{
	if (self.noise3 != "")
		sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};

// Move backward...
void () fd_secret_move4 =
{
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);
};

// Wait 1 second...
void () fd_secret_move5 =
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move6;
	if (self.noise3 != "")
		sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 =
{
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void () fd_secret_done =
{
	if (!self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		//self.th_pain = fd_secret_use;
        }
	if (self.noise3 != "")
		sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	//T_Damage (other, self, self, self.dmg, self.dmg, self.deathtype, DT_IMPACT, (self.absmin + self.absmax) * 0.5, '0 0 0', Obituary_Generic);
};

/*
==============
secret_touch

Prints messages
================
*/
void() secret_touch =
{
	if (activator.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;

	if (self.message)
	{
		if (other.flags & FL_CLIENT)
			centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};


/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void () func_door_secret =
{
	/*if (!self.deathtype) // map makers can override this
		self.deathtype = " got in the way";*/

	if (!self.dmg)
		self.dmg = 2;

	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.classname = "door";
	setmodel (self, self.model); // precision set below
	self.effects |= EF_LOWPRECISION;
	setorigin (self, self.origin);

	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use;
	if ( !self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.event_damage = fd_secret_use;
	}
	self.oldorigin = self.origin;
	if (!self.wait)
		self.wait = 5;		// 5 seconds before closing
};

