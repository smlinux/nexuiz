void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
void() SUB_Null;
//void() SUB_UseTargets;
void() SUB_Remove;


/*
==================
SUB_Null

Do nothing
==================
*/
void SUB_Null (void)
{
	
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

void SUB_SetFade_Think (void)
{
	if (self.alpha < 0.06)	// don't let it reach 0, lest it become fully visible again
		remove (self);

	self.alpha = self.alpha - 0.05;

	self.think = SUB_SetFade_Think;
	self.nextthink = time + 0.1;
}

/*
==================
SUB_SetFade

Fade 'ent' out when time >= 'when'
==================
*/
void SUB_SetFade (entity ent, float when)
{
	if (when < time)
	{
			ent.think = SUB_Null;
			return;
	}
	
	ent.alpha = 1.0;

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

	delta = destangle = self.angles;
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
traceline_hitcorpse

A version of traceline that must be used by SOLID_SLIDEBOX things that want to hit SOLID_CORPSE things with a trace attack
==================
*/
void traceline_hitcorpse (entity source, vector v1, vector v2, float nomonst, entity forent)
{
	float	oldsolid;
	
	oldsolid = source.solid;
	source.solid = SOLID_BBOX;
	
	traceline (v1, v2, nomonst, forent);
	
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
vector findbetterlocation (vector org)
{
	vector	loc;
	
	traceline (org, org - '12 0 0', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '12 0 0', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '12 0 0';
	}
	
	traceline (org, org - '-12 0 0', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '-12 0 0', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '-12 0 0';
	}
	
	traceline (org, org - '0 12 0' , TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 12 0', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '0 12 0';
	}
	
	traceline (org, org - '0 -12 0', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 -12 0', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '0 -12 0';
	}
	
	traceline (org, org - '0 0 12' , TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 0 12', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '0 0 12';
	}
	
	traceline (org, org - '0 0 -12', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 0 -12', TRUE, world);
		if (trace_fraction >= 1)
			org = loc + '0 0 -12';
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

// Violence

/*
==================
Explosion

Plays an explosion effect
==================
*/
void Explosion (entity ent, string snd, float fps)
{
	vector	org2;
	
	org2 = findbetterlocation (ent.origin);
	
	te_explosion (org2);
	effect (org2, "models/dpexplosion.spr32", 0, 20, fps);
	sound (ent, CHAN_BODY, snd, 1, ATTN_NORM);
}