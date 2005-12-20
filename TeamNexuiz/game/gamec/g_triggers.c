
void() SUB_UseTargets;

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
/*void() SUB_UseTargets =
{
	local entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}


//
// print the message
//
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
				return;
			remove (t);
		} while ( 1 );
	}

//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use)
				self.use ();
			self = stemp;
			other = otemp;
			activator = act;
		} while ( 1 );
	}


};*/



void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
/*void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise)
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;

	SUB_UseTargets();

	if (self.wait > 0)
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;

		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};*/

void() multi_trigger = 
{
	if (self.nextthink > time)
	{
		return;
	}
	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
		{
			return;
		}
		found_secrets = found_secrets + TF_FLARE_OFF;
		WriteByte(2, 28);
	}
	if (self.noise)
	{
		sound(self, 2, self.noise, TF_FLARE_OFF, TF_FLARE_OFF);
	}
	self.takedamage = TF_FLARE_LIT;
	activator = self.enemy;
	SUB_UseTargets();
	if (self.wait > TF_FLARE_LIT)
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
	}
	else
	{
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_use =
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch =
{
	if (other.classname != "player")
		return;

// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	self.enemy = other;
	multi_trigger ();
};

void multi_eventdamage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	if (!self.takedamage)
		return;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.enemy = attacker;
		multi_trigger();
	}
}

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void (float tno) ConvertToGoal;
void () CheckIfQ3FTrigger;
void() trigger_multiple =
{
/*	if (CheckIfQ3FTrigger() == 1)
	{
		ConvertToGoal (1);
		return;
	}
	if (CheckIfQ3FTrigger() == 2)
	{
		ConvertToGoal (2);
		return;
	}*/
	CheckIfQ3FTrigger ();

	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}

	if (!self.wait)
		self.wait = 0.2;
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.event_damage = multi_eventdamage;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}
};


/*QUAKED trigger_once (.5 .5 .5) ? notouch
Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
/*void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};*/

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = SUB_UseTargets;
};


//=============================================================================


void() counter_use =
{
	self.count = self.count - 1;
	if (self.count < 0)
		return;

	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}

	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};

.float triggerhurttime;
/*void() hurt_touch =
{
	if (other.takedamage)
	if (other.triggerhurttime < time)
	{
		other.triggerhurttime = time + 1;
		Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
	}

	return;
};*/

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
/*void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 1000;
	if (!self.message)
		self.message = "was in the wrong place.";
};*/

//void() target_speaker_use = {sound(self, CHAN_VOICE, self.noise, 1, 1);}
//void() target_speaker = {self.use = target_speaker_use;}

void() target_speaker =
{
if(self.noise) {
 precache_sound (self.noise);
 ambientsound (self.origin, self.noise, 1, ATTN_STATIC);
}
//remove(self);
};


/*
void() sparksthink =
{
  self.nextthink = time + 0.1;

  if(random() < self.wait) {
    te_spark(self.origin,'0 0 -1',self.cnt);
  }
}


void() func_sparks =
{
  self.think = sparksthink;
  self.nextthink = time + 0.2;

  // self.cnt is the amount of sparks that one burst will spawn
  if(self.cnt < 1) {
    self.cnt = 25.0; // nice default value
  }

  // self.wait is the probability that a sparkthink will spawn a spark shower
  // range: 0 - 1, but 0 makes little sense, so...
  if(self.wait < 0.05) {
    self.wait = 0.25; // nice default value
  }

  // sound
  if(self.noise) {
    precache_sound (self.noise);
    ambientsound (self.origin, self.noise, 1, ATTN_STATIC);
  }
}
*/


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
	//self.havocattack = TRUE;

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
	setmodel (self, self.model);
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


// TF DOORS			// SHOULD MOVE THIS TO SEPERATE TF DOORS FILE
void() door_go_down;
void() door_go_up;
float() DoorShouldOpen;

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;


void() door_blocked = 
{
	T_Damage(other, self, self, self.dmg);
	if (self.wait >= TF_FLARE_LIT)
	{
		if (self.state == 3)
		{
			door_go_up();
		}
		else
		{
			door_go_down();
		}
	}
};

void() door_hit_top = 
{
	sound(self, 2, self.noise1, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = TF_FLARE_LIT;
	if (self.spawnflags & 32)
	{
		return;
	}
	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom = 
{
	self.goal_state = 2;
	sound(self, 2, self.noise1, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = TF_FLARE_OFF;
};

void() door_go_down = 
{
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	if (self.max_health)
	{
		self.takedamage = TF_FLARE_OFF;
		self.health = self.max_health;
	}
	self.state = 3;
	SUB_CalcMove(self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up = 
{
	if (self.state == 2)
	{
		return;
	}
	if (self.state == TF_FLARE_LIT)
	{
		self.nextthink = self.ltime + self.wait;
		return;
	}
	sound(self, 2, self.noise2, TF_FLARE_OFF, TF_FLARE_OFF);
	self.state = 2;
	SUB_CalcMove(self.pos2, self.speed, door_hit_top);
	SUB_UseTargets();
};

void() door_fire = 
{
	local entity oself;
	local entity starte;
	if (self.owner != self)
	{
		objerror("door_fire: self.owner != self");
	}
	if (self.items)
	{
		sound(self, 2, self.noise4, TF_FLARE_OFF, TF_FLARE_OFF);
	}
	self.message = string_null;
	oself = self;
	if (self.spawnflags & 32)
	{
		if (self.state == 2 || self.state == TF_FLARE_LIT)
		{
			starte = self;
			do
			{
				door_go_down();
				self = self.enemy;
			} while (self != starte && self != world);
			self = oself;
			return;
		}
	}
	starte = self;
	do
	{
		door_go_up();
		self = self.enemy;
	} while (self != starte && self != world);
	self = oself;
};

void() door_use = 
{
	if (other.classname == "info_tfgoal")		// Doors by item_tfgoals in q3f maps werent working right
	{											//so I added this as a temp fix.
		return;									// Note: doors by info_tfgoals will react slower`
	}
	local entity oself;
	self.message = "";
	self.owner.message = "";
	self.enemy.message = "";
	oself = self;
	self = self.owner;
	door_fire();
	self = oself;
};

void() door_trigger_touch = 
{
	local entity te;
	if (other.health <= TF_FLARE_LIT)
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != TF_FLARE_LIT)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	if (time < self.attack_finished)
	{
		return;
	}
	self.attack_finished = time + TF_FLARE_OFF;
	activator = other;
	self = self.owner;
	door_use();
};

void() door_killed = 
{
	local entity oself;
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = TF_FLARE_LIT;
	door_use();
	self = oself;
};

void() door_touch = 
{
	local entity te;
	if (other.classname != "player")
	{
		return;
	}
	if (self.owner.attack_finished > time)
	{
		return;
	}
	if (!Activated(self, other))
	{
		if (self.else_goal != TF_FLARE_LIT)
		{
			te = Findgoal(self.else_goal);
			if (te)
			{
				DoResults(te, other, self.goal_result & 2);
			}
		}
		return;
	}
	self.owner.attack_finished = time + 2;
	if (self.owner.message != "")
	{
		CenterPrint(other, self.owner.message);
		sound(other, 2, "misc/talk.wav", TF_FLARE_OFF, TF_FLARE_OFF);
	}
	if (!(self.items))
	{
		return;
	}
	if ((self.items & other.items) != self.items)
	{
		if (self.owner.items == 131072)
		{
			if (world.worldtype == 2)
			{
				CenterPrint(other, "You need the silver keycard");
				sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
			}
			else
			{
				if (world.worldtype == TF_FLARE_OFF)
				{
					CenterPrint(other, "You need the silver runekey");
					sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
				}
				else
				{
					if (world.worldtype == TF_FLARE_LIT)
					{
						CenterPrint(other, "You need the silver key");
						sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
					}
				}
			}
		}
		else
		{
			if (world.worldtype == 2)
			{
				CenterPrint(other, "You need the gold keycard\n");
				sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
			}
			else
			{
				if (world.worldtype == TF_FLARE_OFF)
				{
					CenterPrint(other, "You need the gold runekey");
					sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
				}
				else
				{
					if (world.worldtype == TF_FLARE_LIT)
					{
						CenterPrint(other, "You need the gold key");
						sound(self, 2, self.noise3, TF_FLARE_OFF, TF_FLARE_OFF);
					}
				}
			}
		}
		return;
	}
	other.items = other.items - self.items;
	other.tf_items = other.tf_items | self.items;
	if (DoorShouldOpen())
	{
		self.touch = SUB_Null;
		if (self.enemy)
		{
			self.enemy.touch = SUB_Null;
		}
		door_use();
	}
};

entity(vector fmins, vector fmaxs) spawn_field = 
{
	local entity trigger;
	local vector t1;
	local vector t2;
	trigger = spawn();
	trigger.movetype = TF_FLARE_LIT;
	trigger.solid = TF_FLARE_OFF;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;
	trigger.team_no = self.team_no;
	trigger.playerclass = self.playerclass;
	trigger.items_allowed = self.items_allowed;
	trigger.activate_goal_no = self.activate_goal_no;
	trigger.inactivate_goal_no = self.inactivate_goal_no;
	trigger.remove_goal_no = self.remove_goal_no;
	trigger.restore_goal_no = self.restore_goal_no;
	trigger.activate_group_no = self.activate_group_no;
	trigger.inactivate_group_no = self.inactivate_group_no;
	trigger.remove_group_no = self.remove_group_no;
	trigger.restore_group_no = self.restore_group_no;
	trigger.goal_activation = self.goal_activation;
	trigger.goal_effects = self.goal_effects;
	trigger.goal_result = self.goal_result;
	trigger.goal_group = self.goal_group;
	t1 = fmins;
	t2 = fmaxs;
	setsize(trigger, t1 - '60 60 8', t2 + '60 60 8');
	return trigger;
};

float(entity e1, entity e2) EntitiesTouching = 
{
	if (e1.mins_x > e2.maxs_x)
	{
		return TF_FLARE_LIT;
	}
	if (e1.mins_y > e2.maxs_y)
	{
		return TF_FLARE_LIT;
	}
	if (e1.mins_z > e2.maxs_z)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_x < e2.mins_x)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_y < e2.mins_y)
	{
		return TF_FLARE_LIT;
	}
	if (e1.maxs_z < e2.mins_z)
	{
		return TF_FLARE_LIT;
	}
	return TF_FLARE_OFF;
};

void() LinkDoors = 
{
	local entity t;
	local entity starte;
	local vector cmins;
	local vector cmaxs;
	if (self.enemy)
	{
		return;
	}
	if (self.spawnflags & 4)
	{
		self.enemy = self;
		self.owner = self;
		return;
	}
	cmins = self.mins;
	cmaxs = self.maxs;
	starte = self;
	t = self;
	do
	{
		self.owner = starte;
		if (self.health)
		{
			starte.health = self.health;
		}
		if (self.targetname)
		{
			starte.targetname = self.targetname;
		}
		if (self.message != "")
		{
			starte.message = self.message;
		}
		t = find(t, classname, self.classname);
		if (!t)
		{
			self.enemy = starte;
			self = self.owner;
			if (self.health)
			{
				return;
			}
			if (self.targetname)
			{
				return;
			}
			if (self.items)
			{
				return;
			}
			self.owner.trigger_field = spawn_field(cmins, cmaxs);
			return;
		}
		if (EntitiesTouching(self, t))
		{
			if (t.enemy)
			{
				objerror("cross connected doors");
			}
			self.enemy = t;
			self = t;
			if (t.mins_x < cmins_x)
			{
				cmins_x = t.mins_x;
			}
			if (t.mins_y < cmins_y)
			{
				cmins_y = t.mins_y;
			}
			if (t.mins_z < cmins_z)
			{
				cmins_z = t.mins_z;
			}
			if (t.maxs_x > cmaxs_x)
			{
				cmaxs_x = t.maxs_x;
			}
			if (t.maxs_y > cmaxs_y)
			{
				cmaxs_y = t.maxs_y;
			}
			if (t.maxs_z > cmaxs_z)
			{
				cmaxs_z = t.maxs_z;
			}
		}
	} while (TF_FLARE_OFF);
};

void() func_door = 
{
	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}

	//	Q3F/ETF Map Support
	if (self.allowteams == "red")
	{
		self.team_no = 2;
	}
	if (self.allowteams == "blue")
	{
		self.team_no = 1;
	}

	if (world.worldtype == TF_FLARE_LIT)
	{
		precache_sound("doors/medtry.wav");
		precache_sound("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else
	{
		if (world.worldtype == TF_FLARE_OFF)
		{
			precache_sound("doors/runetry.wav");
			precache_sound("doors/runeuse.wav");
			self.noise3 = "doors/runetry.wav";
			self.noise4 = "doors/runeuse.wav";
		}
		else
		{
			if (world.worldtype == 2)
			{
				precache_sound("doors/basetry.wav");
				precache_sound("doors/baseuse.wav");
				self.noise3 = "doors/basetry.wav";
				self.noise4 = "doors/baseuse.wav";
			}
			else
			{
				dprint("no worldtype set!\n");
			}
		}
	}
	if (self.sounds == TF_FLARE_LIT)
	{
		precache_sound("misc/null.wav");
		precache_sound("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}
	if (self.sounds == TF_FLARE_OFF)
	{
		precache_sound("doors/drclos4.wav");
		precache_sound("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("doors/hydro1.wav");
		precache_sound("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("doors/stndr1.wav");
		precache_sound("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}
	if (self.sounds == 4)
	{
		precache_sound("doors/ddoor1.wav");
		precache_sound("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}
	if (self.armorclass == TF_FLARE_OFF)
	{
		precache_sound("doors/creekdr1.wav");
		precache_sound("doors/creekdr2.wav");
		self.noise2 = "doors/creekdr1.wav";
		self.noise1 = "doors/creekdr2.wav";
	}
	if (self.armorclass == 2)
	{
		precache_sound("doors/metaldr1.wav");
		precache_sound("doors/metaldr2.wav");
		self.noise2 = "doors/metaldr1.wav";
		self.noise1 = "doors/metaldr2.wav";
	}
	if (self.armorclass == 3)
	{
		precache_sound("doors/electdr1.wav");
		precache_sound("doors/electdr2.wav");
		self.noise2 = "doors/electdr1.wav";
		self.noise1 = "doors/electdr2.wav";
	}
	if (self.armorclass == 4)
	{
		precache_sound("doors/track_st.wav");
		precache_sound("doors/track_e.wav");
		self.noise2 = "doors/track_st.wav";
		self.noise1 = "doors/track_e.wav";
	}
	SetMovedir();
	self.max_health = self.health;
	self.solid = 4;
	self.movetype = 7;
	setorigin(self, self.origin);
	setmodel(self, self.model);
	self.classname = "door";
	self.blocked = door_blocked;
	self.use = door_use;
	if (self.spawnflags & 16)
	{
		self.items = 131072;
	}
	if (self.spawnflags & 8)
	{
		self.items = 262144;
	}
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.wait))
	{
		self.wait = 3;
	}
	if (!(self.lip))
	{
		self.lip = 8;
	}
	if (!(self.dmg))
	{
		self.dmg = 2;
	}
	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir * (fabs(self.movedir * self.size) - self.lip);
	if (self.spawnflags & TF_FLARE_OFF)
	{
		setorigin(self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}
	self.state = TF_FLARE_OFF;
	if (self.health)
	{
		self.takedamage = TF_FLARE_OFF;
		self.th_die = door_killed;
	}
	if (self.items)
	{
		self.wait = -1;
	}
	self.touch = door_touch;
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
};

// MOVE TO TFTRIGGERS
void() trigger_once = 
{
	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}
	self.wait = -1;
	trigger_multiple();
};

void() hurt_on = 
{
	self.solid = TF_FLARE_OFF;
	self.nextthink = -1;
};

void() hurt_touch = 
{
	local entity te;
	if (other.is_dead != 0)		// added by xavior to stop killing of dead bodies
		return;						////
	if (other.takedamage)
	{
		if (!Activated(self, other))
		{
			if (self.else_goal != TF_FLARE_LIT)
			{
				te = Findgoal(self.else_goal);
				if (te)
				{
					DoResults(te, other, self.goal_result & 2);
				}
			}
			return;
		}
		self.solid = TF_FLARE_LIT;
		deathmsg = 36;
		TF_T_Damage(other, self, self, self.dmg, TF_FLARE_OFF, TF_FLARE_LIT);
		self.think = hurt_on;
		self.nextthink = time + TF_FLARE_OFF;
	}
};

void() trigger_hurt = 
{
	if (self.allowteams == "red")		// Converted to work with q3f/ETF entities
	{
		self.team_no = 2;
		self.owned_by = 2;
	}
	if (self.allowteams == "blue")
	{
		self.owned_by = 1;
		self.team_no = 1;
	}

	if (CheckExistence() == TF_FLARE_LIT)
	{
		dremove(self);
		return;
	}
	InitTrigger();
	self.touch = hurt_touch;
	if (!(self.dmg))
	{
		self.dmg = 5;
	}
};


// TF SUBS
void () SUB_UseTargets =
{
	local entity t;
	local entity stemp;
	local entity otemp;
	local entity act;

	if (self.dont_do_triggerwork)
	{
		self.dont_do_triggerwork = 0;
		return;
	}
	if (self.delay)
	{
		t = spawn ();
		t.classname = "DelayedUse";
		t.nextthink = (time + self.delay);
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}
	if (((activator.classname == "player") && (self.message != "")))
	{
		CenterPrint (activator, self.message);
		if (!self.noise)
		{
			sound (activator, 2, "misc/talk.wav", 1, 1);
		}
	}
	if ((activator.classname == "player"))
	{
		DoGroupWork (self, activator);
		DoGoalWork (self, activator);
	}
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find (t, targetname, self.killtarget);
			if (!t)
			{
				return;
			}
			remove (t);

		} while (1);
	}
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find (t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if ((self.use != SUB_Null))
			{
				if (self.use)
				{
					self.use ();
				}
			}
			self = stemp;
			other = otemp;
			activator = act;

		} while (1);
	}
};

