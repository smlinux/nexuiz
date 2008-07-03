void SUB_Null() {};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
//void() SUB_UseTargets;
void() SUB_Remove;

void spawnfunc_info_null (void)
{
	remove(self);
	// if anything breaks, tell the mapper to fix his map! info_null is meant to remove itself immediately.
}

/*
==================
SUB_Remove

Remove self
==================
*/
void SUB_Remove (void)
{
	remove (self);
}

/*
==================
SUB_VanishOrRemove

Makes client invisible or removes non-client
==================
*/
void SUB_VanishOrRemove (entity ent)
{
	if (ent.flags & FL_CLIENT)
	{
		// vanish
		ent.model = "";
		ent.effects = 0;
		ent.glow_size = 0;
		ent.pflags = 0;
	}
	else
	{
		// remove
		remove (ent);
	}
}

void SUB_SetFade_Think (void)
{
	self.think = SUB_SetFade_Think;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;
	if (self.alpha < 0.01)
		SUB_VanishOrRemove(self);
	self.alpha = bound(0.01, self.alpha, 1);
}

/*
==================
SUB_SetFade

Fade 'ent' out when time >= 'when'
==================
*/
void SUB_SetFade (entity ent, float when, float fadetime)
{
	//if (ent.flags & FL_CLIENT) // && ent.deadflag != DEAD_NO)
	//	return;
	//ent.alpha = 1;
	ent.fade_rate = 1/fadetime;
	ent.fade_time = when;
	ent.think = SUB_SetFade_Think;
	ent.nextthink = when;
}

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void SUB_CalcMoveDone (void)
{
	// After moving, set origin to exact final destination

	setorigin (self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1 ();
}

void SUB_CalcMove (vector tdest, float tspeed, void() func)
{
	vector	delta;
	float	traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	delta = tdest - self.origin;
	traveltime = vlen (delta) / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	self.velocity = delta * (1/traveltime);	// QuakeC doesn't allow vector/float division

	self.nextthink = self.ltime + traveltime;
}

void SUB_CalcMoveEnt (entity ent, vector tdest, float tspeed, void() func)
{
	entity	oldself;

	oldself = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);

	self = oldself;
}

/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating

The calling function should make sure self.think is valid
===============
*/
void SUB_CalcAngleMoveDone (void)
{
	// After rotating, set angle to exact final angle
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1 ();
}

void SUB_CalcAngleMove (vector destangle, float tspeed, void() func)
{
	vector	delta;
	float	traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	delta = destangle - self.angles;
	traveltime = vlen (delta) / tspeed;

	self.avelocity = delta * (1 / traveltime);

	self.think1 = func;
	self.finalangle = destangle;

	self.think = SUB_CalcAngleMoveDone;
	self.nextthink = self.ltime + traveltime;
}

void SUB_CalcAngleMoveEnt (entity ent, vector destangle, float tspeed, void() func)
{
	entity	oldself;

	oldself = self;
	self = ent;

	SUB_CalcAngleMove (destangle, tspeed, func);

	self = oldself;
}

/*
==================
main

unused but required by the engine
==================
*/
void main (void)
{

}

// Sound functions

/*
==================
PointSound

Play a sound at the given location
==================
*/
void PointSound (vector org, string snd, float vol, float attn)
{
	entity	speaker;

	speaker = spawn ();
	setorigin (speaker, org);
	sound (speaker, CHAN_BODY, snd, vol, attn);
	remove (speaker);
}

// Misc

/*
==================
traceline_antilag

A version of traceline that must be used by SOLID_SLIDEBOX things that want to hit SOLID_CORPSE things with a trace attack
Additionally it moves players back into the past before the trace and restores them afterward.
==================
*/
void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	local entity player;
	local float oldsolid;

	// check whether antilagged traces are enabled
	if (lag < 0.001)
		lag = 0;
	if (clienttype(forent) != CLIENTTYPE_REAL)
		lag = 0; // only antilag for clients
	if (lag)
	if (cvar("g_antilag") != 2)
		lag = 0;

	// change shooter to SOLID_BBOX so the shot can hit corpses
	oldsolid = source.solid;
	source.solid = SOLID_BBOX;

	if (lag)
	{
		// take players back into the past
		player = player_list;
		while (player)
		{
			antilag_takeback(player, time - lag);
			player = player.nextplayer;
		}
	}

	// do the trace
	traceline (v1, v2, nomonst, forent);

	// restore players to current positions
	if (lag)
	{
		player = player_list;
		while (player)
		{
			antilag_restore(player);
			player = player.nextplayer;
		}
	}

	// restore shooter solid type
	source.solid = oldsolid;
}

/*
==================
findbetterlocation

Returns a point at least 12 units away from walls
(useful for explosion animations, although the blast is performed where it really happened)
Ripped from DPMod
==================
*/
vector findbetterlocation (vector org, float mindist)
{
	vector	loc;
	vector vec;
	float c;

	vec = mindist * '1 0 0';
	c = 0;
	while (c < 6)
	{
		traceline (org, org + vec, TRUE, world);
		vec = vec * -1;
		if (trace_fraction < 1)
		{
			loc = trace_endpos;
			traceline (loc, loc + vec, TRUE, world);
			if (trace_fraction >= 1)
				org = loc + vec;
		}
		if (c & 1)
		{
			vec_z = vec_y;
			vec_y = vec_x;
			vec_x = vec_z;
		}
		c = c + 1;
	}

	return org;
}

/*
==================
crandom

Returns a random number between -1.0 and 1.0
==================
*/
float crandom (void)
{
	return 2 * (random () - 0.5);
}

/*
==================
Angc used for animations
==================
*/


float angc (float a1, float a2)
{
	float	a;

	while (a1 > 180)
		a1 = a1 - 360;
	while (a1 < -179)
		a1 = a1 + 360;

	while (a2 > 180)
		a2 = a2 - 360;
	while (a2 < -179)
		a2 = a2 + 360;

	a = a1 - a2;
	while (a > 180)
		a = a - 360;
	while (a < -179)
		a = a + 360;

	return a;
}


/*
================
InitTrigger
================
*/

void SetMovedir()
{
	if (self.movedir != '0 0 0')
		self.movedir = normalize(self.movedir);
	else
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
	}

	self.angles = '0 0 0';
};

void InitTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.movedir == '0 0 0')
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world, no precision needed
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

void InitSolidBSPTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.movedir == '0 0 0')
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_BSP;
	setmodel (self, self.model);	// set size and link into world, no precision needed
	self.movetype = MOVETYPE_PUSH;
//	self.modelindex = 0;
	self.model = "";
};
