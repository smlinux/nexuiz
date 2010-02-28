void SUB_Null() {};
float SUB_True() { return 1; }
float SUB_False() { return 0; }

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

void setanim(entity e, vector anim, float looping, float override, float restart)
{
	if (anim_x == e.animstate_startframe)
	if (anim_y == e.animstate_numframes)
	if (anim_z == e.animstate_framerate)
	{
		if(restart)
		{
			if(restart > 0)
			if(anim_y == 1) // ZYM animation
				BITXOR_ASSIGN(e.effects, EF_RESTARTANIM_BIT);
		}
		else
			return;
	}
	e.animstate_startframe = anim_x;
	e.animstate_numframes = anim_y;
	e.animstate_framerate = anim_z;
	e.animstate_starttime = servertime - 0.1 * serverframetime; // shift it a little bit into the past to prevent float inaccuracy hiccups
	e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
	e.animstate_looping = looping;
	e.animstate_override = override;
	e.frame = e.animstate_startframe;
};

void updateanim(entity e)
{
	if (time >= e.animstate_endtime)
	{
		if (e.animstate_looping)
		{
			e.animstate_starttime = e.animstate_endtime;
			e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
		}
		e.animstate_override = FALSE;
	}
	e.frame = e.animstate_startframe + bound(0, (time - e.animstate_starttime) * e.animstate_framerate, e.animstate_numframes - 1);
	//print(ftos(time), " -> ", ftos(e.frame), "\n");
};

float animparseerror;
vector animparseline(float animfile)
{
	local string line;
	local float c;
	local vector anim;
	if (animfile < 0)
		return '0 1 2';
	line = fgets(animfile);
	c = tokenize_console(line);
	if (c < 3)
	{
		animparseerror = TRUE;
		return '0 1 2';
	}
	anim_x = stof(argv(0));
	anim_y = stof(argv(1));
	anim_z = stof(argv(2));
	// don't allow completely bogus values
	if (anim_x < 0 || anim_y < 1 || anim_z < 0.001)
		anim = '0 1 2';
	return anim;
};

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
SUB_Friction

Applies some friction to self
==================
*/
.float friction;
void SUB_Friction (void)
{
	self.nextthink = time;
	if(self.flags & FL_ONGROUND)
		self.velocity = self.velocity * (1 - frametime * self.friction);
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

// FIXME: I fixed this function only for rotation around the main axes
void SUB_CalcAngleMove (vector destangle, float tspeed, void() func)
{
	vector	delta;
	float	traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	// take the shortest distance for the angles
	self.angles_x -= 360 * floor((self.angles_x - destangle_x) / 360 + 0.5);
	self.angles_y -= 360 * floor((self.angles_y - destangle_y) / 360 + 0.5);
	self.angles_z -= 360 * floor((self.angles_z - destangle_z) / 360 + 0.5);
	delta = destangle - self.angles;
	traveltime = vlen (delta) / tspeed;

	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;

	if (traveltime < 0.1)
	{
		self.avelocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	self.avelocity = delta * (1 / traveltime);
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

// Misc

/*
==================
traceline_antilag

A version of traceline that must be used by SOLID_SLIDEBOX things that want to hit SOLID_CORPSE things with a trace attack
Additionally it moves players back into the past before the trace and restores them afterward.
==================
*/
void tracebox_antilag_force_wz (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag, float wz)
{
	local entity player;
	local float oldsolid;

	// check whether antilagged traces are enabled
	if (lag < 0.001)
		lag = 0;
	if (clienttype(forent) != CLIENTTYPE_REAL)
		lag = 0; // only antilag for clients

	// change shooter to SOLID_BBOX so the shot can hit corpses
	if(source)
	{
		oldsolid = source.dphitcontentsmask;
		source.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;
	}

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
	if(wz)
		WarpZone_TraceBox (v1, mi, ma, v2, nomonst, forent);
	else
		tracebox (v1, mi, ma, v2, nomonst, forent);

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
	if(source)
		source.dphitcontentsmask = oldsolid;
}
void traceline_antilag_force (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	tracebox_antilag_force_wz(source, v1, '0 0 0', '0 0 0', v2, nomonst, forent, lag, FALSE);
}
void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	if (cvar("g_antilag") != 2 || source.cvar_cl_noantilag)
		lag = 0;
	traceline_antilag_force(source, v1, v2, nomonst, forent, lag);
}
void tracebox_antilag (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag)
{
	if (cvar("g_antilag") != 2 || source.cvar_cl_noantilag)
		lag = 0;
	tracebox_antilag_force_wz(source, v1, mi, ma, v2, nomonst, forent, lag, FALSE);
}
void WarpZone_traceline_antilag_force (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	tracebox_antilag_force_wz(source, v1, '0 0 0', '0 0 0', v2, nomonst, forent, lag, TRUE);
}
void WarpZone_traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	if (cvar("g_antilag") != 2 || source.cvar_cl_noantilag)
		lag = 0;
	WarpZone_traceline_antilag_force(source, v1, v2, nomonst, forent, lag);
}
void WarpZone_tracebox_antilag (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag)
{
	if (cvar("g_antilag") != 2 || source.cvar_cl_noantilag)
		lag = 0;
	tracebox_antilag_force_wz(source, v1, mi, ma, v2, nomonst, forent, lag, TRUE);
}

float tracebox_inverted (vector v1, vector mi, vector ma, vector v2, float nomonsters, entity forent) // returns the number of traces done, for benchmarking
{
	vector pos, dir, t;
	float nudge;

	//nudge = 2 * cvar("collision_impactnudge"); // why not?
	nudge = 0.5;

	dir = normalize(v2 - v1);

	pos = v1 + dir * nudge;

	float c;
	c = 0;

	for(;;)
	{
		if((pos - v1) * dir >= (v2 - v1) * dir)
		{
			// went too far
			trace_fraction = 1;
			trace_endpos = v2;
			return c;
		}

		tracebox(pos, mi, ma, v2, nomonsters, forent);
		++c;

		if(c == 50)
		{
			dprint("HOLY SHIT! When tracing from ", vtos(v1), " to ", vtos(v2), "\n");
			dprint("  Nudging gets us nowhere at ", vtos(pos), "\n");
			dprint("  trace_endpos is ", vtos(trace_endpos), "\n");
			dprint("  trace distance is ", ftos(vlen(pos - trace_endpos)), "\n");
		}

		if(trace_startsolid)
		{
			// we started inside solid.
			// then trace from endpos to pos
			t = trace_endpos;
			tracebox(t, mi, ma, pos, nomonsters, forent);
			++c;
			if(trace_startsolid)
			{
				// t is still inside solid? bad
				// force advance, then, and retry
				pos = t + dir * nudge;
			}
			else
			{
				// we actually LEFT solid!
				trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
				return c;
			}
		}
		else
		{
			// pos is outside solid?!? but why?!? never mind, just return it.
			trace_endpos = pos;
			trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
			return c;
		}
	}
}

void traceline_inverted (vector v1, vector v2, float nomonsters, entity forent)
{
#if 0
	vector pos, dir, t;
	float nudge;

	//nudge = 2 * cvar("collision_impactnudge"); // why not?
	nudge = 0.5;

	dir = normalize(v2 - v1);

	pos = v1 + dir * nudge;

	for(;;)
	{
		if((pos - v1) * dir >= (v2 - v1) * dir)
		{
			// went too far
			trace_fraction = 1;
			return;
		}

		traceline(pos, v2, nomonsters, forent);

		if(trace_startsolid)
		{
			// we started inside solid.
			// then trace from endpos to pos
			t = trace_endpos;
			traceline(t, pos, nomonsters, forent);
			if(trace_startsolid)
			{
				// t is inside solid? bad
				// force advance, then
				pos = pos + dir * nudge;
			}
			else
			{
				// we actually LEFT solid!
				trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
				return;
			}
		}
		else
		{
			// pos is outside solid?!? but why?!? never mind, just return it.
			trace_endpos = pos;
			trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
			return;
		}
	}
#else
	tracebox_inverted(v1, '0 0 0', '0 0 0', v2, nomonsters, forent);
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
	float c, h;

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
			h = vec_y;
			vec_y = vec_x;
			vec_x = vec_z;
			vec_z = h;
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

.string lodtarget1;
.string lodtarget2;
.string lodmodel1;
.string lodmodel2;
.float lodmodelindex0;
.float lodmodelindex1;
.float lodmodelindex2;
.float loddistance1;
.float loddistance2;

vector NearestPointOnBox(entity box, vector org);
float LOD_customize()
{
	float d;

	if(cvar("loddebug"))
	{
		d = cvar("loddebug");
		if(d == 1)
			self.modelindex = self.lodmodelindex0;
		else if(d == 2)
			self.modelindex = self.lodmodelindex1;
		else // if(d == 3)
			self.modelindex = self.lodmodelindex2;
		return TRUE;
	}

	// TODO csqc network this so it only gets sent once
	d = vlen(NearestPointOnBox(self, other.origin) - other.origin);
	if(d < self.loddistance1)
		self.modelindex = self.lodmodelindex0;
	else if(!self.lodmodelindex2 || d < self.loddistance2)
		self.modelindex = self.lodmodelindex1;
	else
		self.modelindex = self.lodmodelindex2;

	return TRUE;
}

void LOD_uncustomize()
{
	self.modelindex = self.lodmodelindex0;
}

void LODmodel_attach()
{
	entity e;

	if(!self.loddistance1)
		self.loddistance1 = 1000;
	if(!self.loddistance2)
		self.loddistance2 = 2000;
	self.lodmodelindex0 = self.modelindex;

	if(self.lodtarget1 != "")
	{
		e = find(world, targetname, self.lodtarget1);
		if(e)
		{
			self.lodmodel1 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget2 != "")
	{
		e = find(world, targetname, self.lodtarget2);
		if(e)
		{
			self.lodmodel2 = e.model;
			remove(e);
		}
	}

	if(cvar("loddebug") < 0)
	{
		self.lodmodel1 = self.lodmodel2 = ""; // don't even initialize
	}

	if(self.lodmodel1 != "")
	{
		vector mi, ma;
		mi = self.mins;
		ma = self.maxs;

		precache_model(self.lodmodel1);
		setmodel(self, self.lodmodel1);
		self.lodmodelindex1 = self.modelindex;

		if(self.lodmodel2 != "")
		{
			precache_model(self.lodmodel2);
			setmodel(self, self.lodmodel2);
			self.lodmodelindex2 = self.modelindex;
		}

		self.modelindex = self.lodmodelindex0;
		setsize(self, mi, ma);
	}

	if(self.lodmodelindex1)
		SetCustomizer(self, LOD_customize, LOD_uncustomize);
}

void SetBrushEntityModel()
{
 	if(self.model != "")
 	{
 		precache_model(self.model);
 		setmodel(self, self.model); // no precision needed
		InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
 	}
	setorigin(self, self.origin);
	if(self.scale)
		setsize(self, self.mins * self.scale, self.maxs * self.scale);
	else
		setsize(self, self.mins, self.maxs);
}

void SetBrushEntityModelNoLOD()
{
 	if(self.model != "")
 	{
 		precache_model(self.model);
 		setmodel(self, self.model); // no precision needed
 	}
	setorigin(self, self.origin);
	if(self.scale)
		setsize(self, self.mins * self.scale, self.maxs * self.scale);
	else
		setsize(self, self.mins, self.maxs);
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
		makevectors (self.angles);
		self.movedir = v_forward;
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
	SetBrushEntityModel();
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
	SetBrushEntityModel();
	self.movetype = MOVETYPE_NONE; // why was this PUSH? -div0
//	self.modelindex = 0;
	self.model = "";
};

float InitMovingBrushTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	self.solid = SOLID_BSP;
	SetBrushEntityModel();
	self.movetype = MOVETYPE_PUSH;
	if(self.modelindex == 0)
	{
		objerror("InitMovingBrushTrigger: no brushes found!");
		return 0;
	}
	return 1;
};
