
void() SUB_UseTargets;

void DelayThink()
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
void SUB_UseTargets()
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
			play2(activator, "misc/talk.wav");
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


//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;

// the wait time has passed, so set back up for another activation
void multi_wait()
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
void multi_trigger()
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
		sound (self.enemy, CHAN_AUTO, self.noise, VOL_BASE, ATTN_NORM);

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

void multi_use()
{
	self.enemy = activator;
	multi_trigger();
};

void multi_touch()
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

	EXACTTRIGGER_TOUCH;

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
void spawnfunc_trigger_multiple()
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

	EXACTTRIGGER_INIT;

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
void spawnfunc_trigger_once()
{
	self.wait = -1;
	spawnfunc_trigger_multiple();
};

//=============================================================================

/*QUAKED spawnfunc_trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void spawnfunc_trigger_relay()
{
	self.use = SUB_UseTargets;
};

void delay_use()
{
    self.think = SUB_UseTargets;
    self.nextthink = self.wait;
}

void spawnfunc_trigger_delay()
{
    if(!self.wait)
        self.wait = 1;

    self.use = delay_use;
}

//=============================================================================


void counter_use()
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
void spawnfunc_trigger_counter()
{
	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};

.float triggerhurttime;
void trigger_hurt_touch()
{
	// only do the EXACTTRIGGER_TOUCH checks when really needed (saves some cpu)
	if (!other.owner)
	{
		if (other.items & IT_KEY1 || other.items & IT_KEY2)	// reset flag
		{
			EXACTTRIGGER_TOUCH;
			other.pain_finished = min(other.pain_finished, time + 2);
		}
		else if (other.classname == "rune")			// reset runes
		{
			EXACTTRIGGER_TOUCH;
			other.nextthink = min(other.nextthink, time + 1);
		}
	}

	if (other.takedamage)
	if (other.triggerhurttime < time)
	{
		EXACTTRIGGER_TOUCH;
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
.entity trigger_hurt_next;
entity trigger_hurt_last;
entity trigger_hurt_first;
void spawnfunc_trigger_hurt()
{
	EXACTTRIGGER_INIT;
	self.touch = trigger_hurt_touch;
	if (!self.dmg)
		self.dmg = 1000;
	if (!self.message)
		self.message = "was in the wrong place.";

	if(!trigger_hurt_first)
		trigger_hurt_first = self;
	if(trigger_hurt_last)
		trigger_hurt_last.trigger_hurt_next = self;
	trigger_hurt_last = self;
};

float trace_hits_box_a0, trace_hits_box_a1;

float trace_hits_box_1d(float end, float thmi, float thma)
{
	if(end == 0)
	{
		// just check if x is in range
		if(0 < thmi)
			return FALSE;
		if(0 > thma)
			return FALSE;
	}
	else
	{
		// do the trace with respect to x
		// 0 -> end has to stay in thmi -> thma
		trace_hits_box_a0 = max(trace_hits_box_a0, min(thmi / end, thma / end));
		trace_hits_box_a1 = min(trace_hits_box_a1, max(thmi / end, thma / end));
		if(trace_hits_box_a0 > trace_hits_box_a1)
			return FALSE;
	}
	return TRUE;
}

float trace_hits_box(vector start, vector end, vector thmi, vector thma)
{
	end -= start;
	thmi -= start;
	thma -= start;
	// now it is a trace from 0 to end

	trace_hits_box_a0 = 0;
	trace_hits_box_a1 = 1;

	if(!trace_hits_box_1d(end_x, thmi_x, thma_x))
		return FALSE;
	if(!trace_hits_box_1d(end_y, thmi_y, thma_y))
		return FALSE;
	if(!trace_hits_box_1d(end_z, thmi_z, thma_z))
		return FALSE;

	return TRUE;
}

float tracebox_hits_box(vector start, vector mi, vector ma, vector end, vector thmi, vector thma)
{
	return trace_hits_box(start, end, thmi - ma, thma - mi);
}

float tracebox_hits_trigger_hurt(vector start, vector mi, vector ma, vector end)
{
	entity th;

	for(th = trigger_hurt_first; th; th = th.trigger_hurt_next)
		if(tracebox_hits_box(start, mi, ma, end, th.absmin, th.absmax))
			return TRUE;

	return FALSE;
}


void target_speaker_use() {sound(self, CHAN_TRIGGER, self.noise, VOL_BASE, ATTN_NORM);}

void spawnfunc_target_speaker()
{
	if(self.noise)
		precache_sound (self.noise);
	if(self.targetname)
		self.use = target_speaker_use;
	else
		ambientsound (self.origin, self.noise, VOL_BASE, ATTN_STATIC);
};


void spawnfunc_func_stardust() {
	self.effects = EF_STARDUST;
}

float pointparticles_SendEntity(entity to, float fl)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_POINTPARTICLES);
	WriteByte(MSG_ENTITY, fl);
	if(fl & 2)
	{
		print("state changed, sending: ", ftos(self.state), "\n");
		if(self.state)
			WriteCoord(MSG_ENTITY, self.impulse);
		else
			WriteCoord(MSG_ENTITY, 0); // off
	}
	if(fl & 4)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	if(fl & 1)
	{
		if(self.modelindex != 4.2)
		{
			WriteShort(MSG_ENTITY, self.modelindex);
			WriteCoord(MSG_ENTITY, self.mins_x);
			WriteCoord(MSG_ENTITY, self.mins_y);
			WriteCoord(MSG_ENTITY, self.mins_z);
			WriteCoord(MSG_ENTITY, self.maxs_x);
			WriteCoord(MSG_ENTITY, self.maxs_y);
			WriteCoord(MSG_ENTITY, self.maxs_z);
		}
		else
		{
			WriteShort(MSG_ENTITY, 0);
			WriteCoord(MSG_ENTITY, self.maxs_x);
			WriteCoord(MSG_ENTITY, self.maxs_y);
			WriteCoord(MSG_ENTITY, self.maxs_z);
		}
		WriteShort(MSG_ENTITY, self.cnt);
		WriteShort(MSG_ENTITY, compressShortVector(self.velocity));
		WriteShort(MSG_ENTITY, compressShortVector(self.movedir));
		WriteCoord(MSG_ENTITY, self.waterlevel);
		WriteCoord(MSG_ENTITY, self.count);
		WriteByte(MSG_ENTITY, self.glow_color);
		WriteString(MSG_ENTITY, self.noise);
	}
	return 1;
}

void pointparticles_use()
{
	self.state = !self.state;
	self.SendFlags |= 2;
}

void pointparticles_think()
{
	if(self.origin != self.oldorigin)
	{
		self.SendFlags |= 4;
		self.oldorigin = self.origin;
	}
	self.nextthink = time;
}

void spawnfunc_func_pointparticles()
{
	if(self.model != "")
		setmodel(self, self.model);
	if(self.noise != "")
		precache_sound (self.noise);

	self.effects = EF_NODEPTHTEST;
	self.SendEntity = pointparticles_SendEntity;
	self.SendFlags = 7;
	if(!self.modelindex)
	{
		self.modelindex = 4.2;
		self.origin += self.mins;
		self.maxs -= self.mins;
	}
	self.model = "net_entity";
	if(!self.cnt)
		self.cnt = particleeffectnum(self.mdl);
	if(self.targetname != "")
	{
		self.use = pointparticles_use;
		if(self.spawnflags & 1)
			self.state = 1;
		else
			self.state = 0;
	}
	else
		self.state = 1;
	self.think = pointparticles_think;
	self.nextthink = time;
}

void spawnfunc_func_sparks()
{
	// self.cnt is the amount of sparks that one burst will spawn
	if(self.cnt < 1) {
		self.cnt = 25.0; // nice default value
	}

	// self.wait is the probability that a sparkthink will spawn a spark shower
	// range: 0 - 1, but 0 makes little sense, so...
	if(self.wait < 0.05) {
		self.wait = 0.25; // nice default value
	}

	self.count = self.cnt;
	self.mins = '0 0 0';
	self.maxs = '0 0 0';
	self.velocity = '0 0 -1';
	self.mdl = "func_sparks";
	self.impulse = 0.1 / self.wait;
	self.wait = 0;

	spawnfunc_func_pointparticles();
}

float rainsnow_SendEntity(float to)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RAINSNOW);
	WriteByte(MSG_ENTITY, self.state);
	WriteCoord(MSG_ENTITY, self.origin_x + self.mins_x);
	WriteCoord(MSG_ENTITY, self.origin_y + self.mins_y);
	WriteCoord(MSG_ENTITY, self.origin_z + self.mins_z);
	WriteCoord(MSG_ENTITY, self.maxs_x - self.mins_x);
	WriteCoord(MSG_ENTITY, self.maxs_y - self.mins_y);
	WriteCoord(MSG_ENTITY, self.maxs_z - self.mins_z);
	WriteShort(MSG_ENTITY, compressShortVector(self.dest));
	WriteShort(MSG_ENTITY, self.count);
	WriteByte(MSG_ENTITY, self.cnt);
	return 1;
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
void spawnfunc_func_rain()
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -700';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	SetBrushEntityModel();
	self.model = "";
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.01 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
		self.count = 1;
	if(self.count > 65535)
		self.count = 65535;

	self.state = 1; // 1 is rain, 0 is snow
	self.effects = EF_NODEPTHTEST;
	self.SendEntity = rainsnow_SendEntity;
	self.Version = 1;
	self.modelindex = 1;
	self.model = "net_entity";
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
void spawnfunc_func_snow()
{
	self.dest = self.velocity;
	self.velocity = '0 0 0';
	if (!self.dest)
		self.dest = '0 0 -300';
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	SetBrushEntityModel();
	self.model = "";
	if (!self.cnt)
		self.cnt = 12;
	if (!self.count)
		self.count = 2000;
	self.count = 0.01 * self.count * (self.size_x / 1024) * (self.size_y / 1024);
	if (self.count < 1)
		self.count = 1;
	if(self.count > 65535)
		self.count = 65535;

	self.state = 0; // 1 is rain, 0 is snow
	self.effects = EF_NODEPTHTEST;
	self.SendEntity = rainsnow_SendEntity;
	self.Version = 1;
	self.modelindex = 1;
	self.model = "net_entity";
};


void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float deathtype);

void misc_laser_aim()
{
	vector a;
	if(self.enemy)
	{
		a = vectoangles(self.enemy.origin - self.origin);
		a_x = -a_x;
		if(a != self.angles)
		{
			self.angles = a;
			self.SendFlags |= 2;
		}
	}
	if(self.origin != self.oldorigin)
		self.SendFlags |= 1;
}

void misc_laser_think()
{
	vector o;

	self.nextthink = time;

	if(!self.count)
	{
		self.enemy = find(world, targetname, self.target);
		self.count = 1;
	}

	if(!self.state)
		return;

	misc_laser_aim();

	makevectors(self.angles);
	o = self.origin + 32768 * v_forward;

	if(self.dmg)
	{
		if(self.dmg < 0)
			FireRailgunBullet(self.origin, o, 100000, 0, DEATH_HURTTRIGGER);
		else
			FireRailgunBullet(self.origin, o, self.dmg * frametime, 0, DEATH_HURTTRIGGER);
	}
}

float laser_SendEntity(entity to, float fl)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_LASER);
	WriteByte(MSG_ENTITY, fl);
	if(fl & 1)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}
	if(fl & 8)
	{
		WriteByte(MSG_ENTITY, self.colormod_x * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_y * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_z * 255.0);
		WriteShort(MSG_ENTITY, self.cnt);
	}
	if(fl & 2)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
	}
	if(fl & 4)
		WriteByte(MSG_ENTITY, self.state);
	return 1;
}

/*QUAKED spawnfunc_misc_laser (.5 .5 .5) ? START_ON
Any object touching the beam will be hurt
Keys:
"target"
 spawnfunc_target_position where the laser ends
"mdl"
 name of beam end effect to use
"colormod"
 color of the beam (default: red)
"dmg"
 damage per second (-1 for a laser that kills immediately)
*/
void laser_use()
{
	self.state = !self.state;
	self.SendFlags |= 4;
	misc_laser_aim();
}

void spawnfunc_misc_laser()
{
	if(self.mdl)
	{
		self.cnt = particleeffectnum(strcat(self.mdl, "_end"));
		if(self.cnt < 0)
			self.cnt = particleeffectnum(self.mdl);
	}
	else
	{
		self.cnt = particleeffectnum("misc_laser_beam_end");
	}
	if(self.colormod == '0 0 0')
		self.colormod = '1 0 0';
	if(!self.message)
		self.message = "saw the light";
	self.think = misc_laser_think;
	self.nextthink = time;

	self.effects = EF_NODEPTHTEST;
	self.SendEntity = laser_SendEntity;
	self.SendFlags = 15;
	self.modelindex = 1;
	self.model = "net_entity";

	if(self.targetname != "")
	{
		self.use = laser_use;
		if(self.spawnflags & 1)
			self.state = 1;
		else
			self.state = 0;
	}
	else
		self.state = 1;
}

// tZorks trigger impulse / gravity
.float radius;
.float falloff;
.float strength;
.float lastpushtime;

// targeted (directional) mode
void trigger_impulse_touch1()
{
	entity targ;
    float pushdeltatime;
    float str;

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

	EXACTTRIGGER_TOUCH;

    targ = find(world, targetname, self.target);
    if(!targ)
    {
        objerror("trigger_force without a (valid) .target!\n");
        remove(self);
        return;
    }

    if(self.falloff == 1)
        str = (str / self.radius) * self.strength;
    else if(self.falloff == 2)
        str = (1 - (str / self.radius)) * self.strength;
    else
        str = self.strength;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    other.velocity = other.velocity + normalize(targ.origin - self.origin) * self.strength * pushdeltatime;
}

// Directionless (accelerator/decelerator) mode
void trigger_impulse_touch2()
{
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

	EXACTTRIGGER_TOUCH;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    //if(self.strength > 1)
        other.velocity = other.velocity * (self.strength * pushdeltatime);
    //else
    //    other.velocity = other.velocity - (other.velocity * self.strength * pushdeltatime);
}

// Spherical (gravity/repulsor) mode
void trigger_impulse_touch3()
{
    float pushdeltatime;
    float str;

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

	EXACTTRIGGER_TOUCH;

    pushdeltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;

    setsize(self, '-1 -1 -1' * self.radius,'1 1 1' * self.radius);

	str = min(self.radius, vlen(self.origin - other.origin));

    if(self.falloff == 1)
        str = (1 - str / self.radius) * self.strength; // 1 in the inside
    else if(self.falloff == 2)
        str = (str / self.radius) * self.strength; // 0 in the inside
    else
        str = self.strength;

    other.velocity = other.velocity + normalize(other.origin - self.origin) * str * pushdeltatime;
}

/*QUAKED spawnfunc_trigger_impulse (.5 .5 .5) ?
-------- KEYS --------
target : If this is set, this points to the spawnfunc_target_position to which the player will get pushed.
         If not, this trigger acts like a damper/accelerator field.

strength : This is how mutch force to add in the direction of .target each second
           when .target is set. If not, this is hoe mutch to slow down/accelerate
           someting cought inside this trigger. (1=no change, 0,5 half speed rougthly each tic, 2 = doubble)

radius   : If set, act as a spherical device rather then a liniar one.

falloff : 0 = none, 1 = liniar, 2 = inverted liniar

-------- NOTES --------
Use a brush textured with common/origin in the trigger entity to determine the origin of the force
in directional and sperical mode. For damper/accelerator mode this is not nessesary (and has no effect).
*/

void spawnfunc_trigger_impulse()
{
	EXACTTRIGGER_INIT;
    if(self.radius)
    {
        if(!self.strength) self.strength = 2000;
        setorigin(self, self.origin);
        setsize(self, '-1 -1 -1' * self.radius,'1 1 1' * self.radius);
        self.touch = trigger_impulse_touch3;
    }
    else
    {
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
}

/*QUAKED spawnfunc_trigger_flipflop (.5 .5 .5) (-8 -8 -8) (8 8 8) START_ENABLED
"Flip-flop" trigger gate... lets only every second trigger event through
*/
void flipflop_use()
{
	self.state = !self.state;
	if(self.state)
		SUB_UseTargets();
}

void spawnfunc_trigger_flipflop()
{
	if(self.spawnflags & 1)
		self.state = 1;
    self.use = flipflop_use;
}

/*QUAKED spawnfunc_trigger_monoflop (.5 .5 .5) (-8 -8 -8) (8 8 8)
"Mono-flop" trigger gate... turns one trigger event into one "on" and one "off" event, separated by a delay of "wait"
*/
void monoflop_use()
{
	self.nextthink = time + self.wait;
	if(self.state)
		return;
	self.state = 1;
	SUB_UseTargets();
}
void monoflop_fixed_use()
{
	if(self.state)
		return;
	self.nextthink = time + self.wait;
	self.state = 1;
	SUB_UseTargets();
}

void monoflop_think()
{
	self.state = 0;
	SUB_UseTargets();
}

void spawnfunc_trigger_monoflop()
{
	if(!self.wait)
		self.wait = 1;
	if(self.spawnflags & 1)
		self.use = monoflop_fixed_use;
	else
		self.use = monoflop_use;
	self.think = monoflop_think;
	self.state = 0;
}

void follow_think()
{
	entity src, dst;
	src = find(world, targetname, self.killtarget);
	dst = find(world, targetname, self.target);

	if(!src || !dst)
	{
		objerror("follow: could not find target/killtarget");
		return;
	}

	dst.movetype = MOVETYPE_FOLLOW;
	dst.aiment = src;
	dst.punchangle = src.angles;
	dst.view_ofs = dst.origin - src.origin;
	dst.v_angle = dst.angles - src.angles;

	remove(self);
}

void spawnfunc_misc_follow()
{
	self.think = follow_think;
	self.nextthink = time;
}
