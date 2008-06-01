
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
void() SUB_UseTargets =
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


};



void() spawnfunc_trigger_reactivate =
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
void() multi_trigger =
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

    if(self.team)
    if(self.team == other.team)
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

/*QUAKED spawnfunc_trigger_multiple (.5 .5 .5) ? notouch
Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by spawnfunc_trigger_relay!
sounds
1)	secret
2)	beep beep
3)	large switch
4)
set "message" to text string
*/
void() spawnfunc_trigger_multiple =
{
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


/*QUAKED spawnfunc_trigger_once (.5 .5 .5) ? notouch
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
void() spawnfunc_trigger_once =
{
	self.wait = -1;
	spawnfunc_trigger_multiple();
};

//=============================================================================

/*QUAKED spawnfunc_trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() spawnfunc_trigger_relay =
{
	self.use = SUB_UseTargets;
};

void() delay_use
{
    self.think = SUB_UseTargets;
    self.nextthink = self.wait;
}

void() spawnfunc_trigger_delay
{
    if(!self.wait)
        self.wait = 1;

    self.use = delay_use;
}

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

/*QUAKED spawnfunc_trigger_counter (.5 .5 .5) ? nomessage
Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() spawnfunc_trigger_counter =
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};

.float triggerhurttime;
void() spawnfunc_hurt_touch =
{
	if (!other.owner)
	{
		if (other.items & IT_KEY1 || other.items & IT_KEY2)	// reset flag
			other.pain_finished = min(other.pain_finished, time + 2);
		else if (other.classname == "rune")			// reset runes
			other.nextthink = min(other.nextthink, time + 1);
	}

	if (other.takedamage)
	if (other.triggerhurttime < time)
	{
		other.triggerhurttime = time + 1;
		Damage (other, self, self, self.dmg, DEATH_HURTTRIGGER, other.origin, '0 0 0');
	}

	return;
};

/*QUAKED spawnfunc_trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() spawnfunc_trigger_hurt =
{
	InitTrigger ();
	self.touch = spawnfunc_hurt_touch;
	if (!self.dmg)
		self.dmg = 1000;
	if (!self.message)
		self.message = "was in the wrong place.";
};

//void() target_speaker_use = {sound(self, CHAN_VOICE, self.noise, 1, 1);}
//void() spawnfunc_target_speaker = {self.use = target_speaker_use;}

void() spawnfunc_target_speaker =
{
if(self.noise) {
 precache_sound (self.noise);
 ambientsound (self.origin, self.noise, 1, ATTN_STATIC);
}
//remove(self);
};


void() spawnfunc_func_stardust {
	self.effects = EF_STARDUST;
}


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
void() rain_think =
{
	self.nextthink = time + 0.1;
	te_particlerain(self.absmin, self.absmax, self.dest, self.count, self.cnt);
//	te_particlesnow(self.absmin, self.absmax, self.dest * 0.25, self.count, self.cnt);
//	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
//	WriteByte (MSG_BROADCAST, TE_PARTICLERAIN);
//	WriteVec (MSG_BROADCAST, self.absmin);
//	WriteVec (MSG_BROADCAST, self.absmax);
//	WriteVec (MSG_BROADCAST, self.dest);
//	WriteShort (MSG_BROADCAST, self.count);
//	WriteByte (MSG_BROADCAST, self.cnt);
};

/*QUAKED spawnfunc_func_rain (0 .5 .8) ?
This is an invisible area like a trigger, which rain falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -700', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
void() spawnfunc_func_rain =
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -700';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	if(self.model != "")
		setmodel(self, self.model); // no precision needed
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.model = "";
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.1 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
	{
		remove(self);
		return;
	}
	// convert from per second to per 0.1 sec,
	self.count = ceil(self.count * 0.1);
	self.think = rain_think;
	self.nextthink = time + 0.5;
};


void() snow_think =
{
	self.nextthink = time + 0.1 + random() * 0.05;
	te_particlesnow(self.absmin, self.absmax, self.dest, self.count, self.cnt);
//	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
//	WriteByte (MSG_BROADCAST, TE_PARTICLESNOW);
//	WriteVec (MSG_BROADCAST, self.absmin);
//	WriteVec (MSG_BROADCAST, self.absmax);
//	WriteVec (MSG_BROADCAST, self.dest);
//	WriteShort (MSG_BROADCAST, self.count);
//	WriteByte (MSG_BROADCAST, self.cnt);
};

/*QUAKED spawnfunc_func_snow (0 .5 .8) ?
This is an invisible area like a trigger, which snow falls inside of.

Keys:
"velocity"
 falling direction (should be something like '0 0 -300', use the X and Y velocity for wind)
"cnt"
 sets color of rain (default 12 - white)
"count"
 adjusts density, this many particles fall every second for a 1024x1024 area, default is 2000
*/
void() spawnfunc_func_snow =
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -300';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	if(self.model != "")
		setmodel(self, self.model); // no precision needed
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.model = "";
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.1 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
	{
		remove(self);
		return;
	}
	// convert from per second to per 0.1 sec,
	self.count = ceil(self.count * 0.1);
	self.think = snow_think;
	self.nextthink = time + 0.5;
};


void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float deathtype);
void() misc_laser_think =
{
	vector o;
	if(!self.state)
	{
		self.enemy = find(world, targetname, self.target);
		self.state = 1;
	}
	if(self.enemy)
	{
		o = self.enemy.origin;
	}
	else
	{
		makevectors(self.angles);
		o = self.origin + v_forward * MAX_SHOT_DISTANCE;
	}

	if(self.dmg)
	{
		if(self.dmg < 0)
			FireRailgunBullet(self.origin, o, 100000, 0, DEATH_HURTTRIGGER);
		else
			FireRailgunBullet(self.origin, o, self.dmg * frametime, 0, DEATH_HURTTRIGGER);
	}

	if(time > self.ltime)
	{
		traceline(self.origin, o, MOVE_WORLDONLY, self);
		trailparticles(self, self.cnt, self.origin, trace_endpos);
		pointparticles(self.lip, trace_endpos, trace_plane_normal, 256 * frametime);
		self.ltime = time + self.wait;
	}
	self.nextthink = time;
}
/*QUAKED spawnfunc_misc_laser (.5 .5 .5) ?
Any object touching the beam will be hurt
Keys:
"target"
 spawnfunc_target_position where the laser ends
"mdl"
 name of beam effect to use
"dmg"
 damage per second (-1 for a laser that kills immediately)
"wait"
 delay between sending the particle effect
*/
void() spawnfunc_misc_laser =
{
	if(self.mdl)
	{
		self.cnt = particleeffectnum(self.mdl);
		self.lip = particleeffectnum(strcat(self.mdl, "_end"));
	}
	else
	{
		self.cnt = particleeffectnum("misc_laser_beam");
		self.lip = particleeffectnum("misc_laser_beam_end");
	}
	if(!self.wait)
		self.wait = 1;
	if(!self.message)
		self.message = "saw the spawnfunc_light";
	self.think = misc_laser_think;
	self.nextthink = time;
}

.float strength;
.float lastpushtime;
void trigger_impulse_touch1()
{
	entity targ;
    float pushdeltatime;

	// FIXME: Better checking for what to push and not.
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

    targ = find(world, targetname, self.target);
    if(!targ)
    {
        objerror("trigger_force without a (valif) .target!\n");
        remove(self);
        return;
    }


    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    other.velocity = other.velocity + normalize(targ.origin - self.origin) * self.strength * pushdeltatime;
}

void trigger_impulse_touch2()
{

	// FIXME: Better checking for what to push and not.
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

    other.velocity = other.velocity * self.strength;
}


/*QUAKED spawnfunc_trigger_impulse (.5 .5 .5) ?
-------- KEYS --------
target : If this is set, this points to the spawnfunc_target_position to which the player will get pushed.
         If not, this trigger acts like a damper/accelerator field.

strength : This is how mutch force to add in the direction of .target each second
           when .target is set. If not, this is hoe mutch to slow down/accelerate
           someting cought inside this trigger. (1=no change, 0,5 half speed rougthly each tic, 2 = doubble)

-------- NOTES --------
Use a brush textured with common/origin in the trigger entity to determine the origin of the force
in directional push mode. For damper/accelerator mode this is no nessesary (and has no effect).
*/

void spawnfunc_trigger_impulse()
{
    InitTrigger ();
    if(self.target)
    {
        if(!self.strength) self.strength = 950;
        self.touch = trigger_impulse_touch1;
    }
    else
    {
        if(!self.strength) self.strength = 0.9;
        self.touch = trigger_impulse_touch2;
    }
}

