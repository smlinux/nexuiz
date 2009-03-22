.float aistatus;
float AI_STATUS_ROAMING			= 1;	// Bot is just crawling the map. No enemies at sight
float AI_STATUS_ATTACKING		= 2;	// There are enemies at sight
float AI_STATUS_RUNNING			= 4;	// Bot is bunny hopping
float AI_STATUS_DANGER_AHEAD	= 8;	// There is lava/slime/trigger_hurt ahead
float AI_STATUS_OUT_JUMPPAD		= 16;	// Trying to get out of a "vertical" jump pad
float AI_STATUS_OUT_WATER		= 32;	// Trying to get out of water

.string netname_freeme;
// rough simulation of walking from one point to another to test if a path
// can be traveled, used by havocbot

vector stepheightvec;
float navigation_testtracewalk;
float tracewalk(entity e, vector start, vector m1, vector m2, vector end, float movemode)
{
	local vector org;
	local vector move;
	local vector dir;
	local float dist;
	local float totaldist;
	local float stepdist;
	local float yaw;
	local float ignorehazards;
	if (navigation_testtracewalk)
	{
		if (navigation_testtracewalk > 1)
			dprint("tracewalk: ");
		//te_wizspike(start);
		//te_knightspike(end);
		//te_lightning2(world, start, end);
	}
	move = end - start;
	move_z = 0;
	org = start;
	dist = totaldist = vlen(move);
	dir = normalize(move);
	stepdist = 32;
	ignorehazards = FALSE;
	//self.angles = vectoangles(dir);
	traceline(start, start, MOVE_NORMAL, e);
	if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
		ignorehazards = TRUE;
	tracebox(start, m1, m2, start, MOVE_NOMONSTERS, e);
	if (trace_startsolid)
	{
		// failed - bad start
		if (navigation_testtracewalk)
		{
			if (navigation_testtracewalk > 1)
				dprint("bad-start\n");
			te_knightspike(start);
		}
		return 0;
	}
	yaw = vectoyaw(move);
	move = end - org;
	while (1)
	{
		if (boxesoverlap(end, end, org + m1 + '-1 -1 -1', org + m2 + '1 1 1'))
		{
			if (navigation_testtracewalk)
			{
				if (navigation_testtracewalk > 1)
					dprint("success\n");
				te_wizspike(org);
			}
			// succeeded
			return 1;
		}
		if (dist <= 0)
			break;
		if (navigation_testtracewalk)
		{
			//dprint("trying ");
			//te_gunshot(org);
			particle(org, '0 0 0', 104, 8);
		}
		if (stepdist > dist)
			stepdist = dist;
		dist = dist - stepdist;
		traceline(org, org, MOVE_NORMAL, e);
		if (!ignorehazards)
		{
			if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
			{
				if (navigation_testtracewalk)
				{
					if (navigation_testtracewalk > 1)
						dprint("hazard\n");
					te_gunshot(org);
				}
				// hazards blocking path
				return 0;
			}
		}
		if (trace_dpstartcontents & DPCONTENTS_LIQUIDSMASK)
		{
			move = normalize(end - org);
			tracebox(org, m1, m2, org + move * stepdist, movemode, e);
			if (trace_fraction < 1)
			{
				if (navigation_testtracewalk)
				{
					if (navigation_testtracewalk > 1)
						dprint("swimming-hit-something\n");
					//particle(org, move * 64, 104, 4);
					te_gunshot(org);
				}
				return 0;
			}
			org = trace_endpos;
		}
		else
		{
			move = dir * stepdist + org;
			tracebox(org, m1, m2, move, movemode, e);
			// hit something
			if (trace_fraction < 1)
			{
				// check if we can walk over this obstacle
				tracebox(org + stepheightvec, m1, m2, move + stepheightvec, movemode, e);
				if (trace_fraction < 1 || trace_startsolid)
				{
					if (navigation_testtracewalk)
					{
						if (navigation_testtracewalk > 1)
							dprint("hit-something\n");
					//	move = normalize(end - org);
					//	particle(org, move * 64, 104, 4);
					//	te_gunshot(org);
					}

					// check for doors
					traceline( org, move, movemode, e);
					if ( trace_ent.classname == "door_rotating" || trace_ent.classname == "door")
					{
						local vector nextmove;
						move = trace_endpos;
						while(trace_ent.classname == "door_rotating" || trace_ent.classname == "door")
						{
							nextmove = move + (dir * stepdist);
							traceline( move, nextmove, movemode, e);
							move = nextmove;
						}
					}
					else
						return 0; // failed
				}
				else
					move = trace_endpos;
			}
			else
				move = trace_endpos;

			// trace down from stepheight as far as possible and move there,
			// if this starts in solid we try again without the stepup, and
			// if that also fails we assume it is a wall
			// (this is the same logic as the Quake walkmove function used)
			tracebox(move, m1, m2, move + '0 0 -65536', movemode, e);
			/*
			if (trace_startsolid)
			{
				tracebox(move, m1, m2, move + '0 0 -65536', FALSE, e);
				if (trace_startsolid)
				{
					if (navigation_testtracewalk)
					{
						if (navigation_testtracewalk > 1)
							dprint("hit-something\n");
						//move = normalize(end - org);
						//particle(org, move * 64, 104, 4);
						te_knightspike(org);
					}
					// failed
					return 0;
				}
			}
			*/
			// moved successfully
			if (navigation_testtracewalk > 1)
				dprint("moved ");
			org = trace_endpos;
		}
	}
	if (navigation_testtracewalk)
	{
		if (navigation_testtracewalk > 1)
			dprint("wrong-place\n");
		te_knightspike(org);
		//te_gunshot(end);
	}
	// moved but didn't arrive at the intended destination
	return 0;
};


// grenade tracing to decide the best pitch to fire at

entity tracetossent;
entity tracetossfaketarget;

// traces multiple trajectories to find one that will impact the target
// 'end' vector is the place it aims for,
// returns TRUE only if it hit targ (don't target non-solid entities)
vector findtrajectory_velocity;
float findtrajectorywithleading(vector org, vector m1, vector m2, entity targ, float shotspeed, float shotspeedupward, float maxtime, float shotdelay, entity ignore)
{
	local float c, savesolid, shottime;
	local vector dir, end, v;
	if (shotspeed < 1)
		return FALSE; // could cause division by zero if calculated
	if (targ.solid < SOLID_BBOX) // SOLID_NOT and SOLID_TRIGGER
		return FALSE; // could never hit it
	if (!tracetossent)
		tracetossent = spawn();
	tracetossent.owner = ignore;
	setsize(tracetossent, m1, m2);
	savesolid = targ.solid;
	targ.solid = SOLID_NOT;
	shottime = ((vlen(targ.origin - org) / shotspeed) + shotdelay);
	v = targ.velocity * shottime + targ.origin;
	tracebox(targ.origin, targ.mins, targ.maxs, v, FALSE, targ);
	v = trace_endpos;
	end = v + (targ.mins + targ.maxs) * 0.5;
	if ((vlen(end - org) / shotspeed + 0.2) > maxtime)
	{
		// out of range
		targ.solid = savesolid;
		return FALSE;
	}

	if (!tracetossfaketarget)
		tracetossfaketarget = spawn();
	tracetossfaketarget.solid = savesolid;
	tracetossfaketarget.movetype = targ.movetype;
	setmodel(tracetossfaketarget, targ.model); // no low precision
	tracetossfaketarget.model = targ.model;
	tracetossfaketarget.modelindex = targ.modelindex;
	setsize(tracetossfaketarget, targ.mins, targ.maxs);
	setorigin(tracetossfaketarget, v);

	c = 0;
	dir = normalize(end - org);
	while (c < 10) // 10 traces
	{
		setorigin(tracetossent, org); // reset
		tracetossent.velocity = findtrajectory_velocity = normalize(dir) * shotspeed + shotspeedupward * '0 0 1';
		tracetoss(tracetossent, ignore); // love builtin functions...
		if (trace_ent == tracetossfaketarget) // done
		{
			targ.solid = savesolid;

			// make it disappear
			tracetossfaketarget.solid = SOLID_NOT;
			tracetossfaketarget.movetype = MOVETYPE_NONE;
			tracetossfaketarget.model = "";
			tracetossfaketarget.modelindex = 0;
			// relink to remove it from physics considerations
			setorigin(tracetossfaketarget, v);

			return TRUE;
		}
		dir_z = dir_z + 0.1; // aim up a little more
		c = c + 1;
	}
	targ.solid = savesolid;

	// make it disappear
	tracetossfaketarget.solid = SOLID_NOT;
	tracetossfaketarget.movetype = MOVETYPE_NONE;
	tracetossfaketarget.model = "";
	tracetossfaketarget.modelindex = 0;
	// relink to remove it from physics considerations
	setorigin(tracetossfaketarget, v);

	// leave a valid one even if it won't reach
	findtrajectory_velocity = normalize(end - org) * shotspeed + shotspeedupward * '0 0 1';
	return FALSE;
};



// lag simulation

.void(float t, float f1, float f2, entity e1, vector v1, vector v2, vector v3, vector v4) lag_func;

// upto 5 queued messages
.float lag1_time;
.float lag1_float1;
.float lag1_float2;
.entity lag1_entity1;
.vector lag1_vec1;
.vector lag1_vec2;
.vector lag1_vec3;
.vector lag1_vec4;

.float lag2_time;
.float lag2_float1;
.float lag2_float2;
.entity lag2_entity1;
.vector lag2_vec1;
.vector lag2_vec2;
.vector lag2_vec3;
.vector lag2_vec4;

.float lag3_time;
.float lag3_float1;
.float lag3_float2;
.entity lag3_entity1;
.vector lag3_vec1;
.vector lag3_vec2;
.vector lag3_vec3;
.vector lag3_vec4;

.float lag4_time;
.float lag4_float1;
.float lag4_float2;
.entity lag4_entity1;
.vector lag4_vec1;
.vector lag4_vec2;
.vector lag4_vec3;
.vector lag4_vec4;

.float lag5_time;
.float lag5_float1;
.float lag5_float2;
.entity lag5_entity1;
.vector lag5_vec1;
.vector lag5_vec2;
.vector lag5_vec3;
.vector lag5_vec4;

void lag_update()
{
	if (self.lag1_time) if (time > self.lag1_time) {self.lag_func(self.lag1_time, self.lag1_float1, self.lag1_float2, self.lag1_entity1, self.lag1_vec1, self.lag1_vec2, self.lag1_vec3, self.lag1_vec4);self.lag1_time = 0;}
	if (self.lag2_time) if (time > self.lag2_time) {self.lag_func(self.lag2_time, self.lag2_float1, self.lag2_float2, self.lag2_entity1, self.lag2_vec1, self.lag2_vec2, self.lag2_vec3, self.lag2_vec4);self.lag2_time = 0;}
	if (self.lag3_time) if (time > self.lag3_time) {self.lag_func(self.lag3_time, self.lag3_float1, self.lag3_float2, self.lag3_entity1, self.lag3_vec1, self.lag3_vec2, self.lag3_vec3, self.lag3_vec4);self.lag3_time = 0;}
	if (self.lag4_time) if (time > self.lag4_time) {self.lag_func(self.lag4_time, self.lag4_float1, self.lag4_float2, self.lag4_entity1, self.lag4_vec1, self.lag4_vec2, self.lag4_vec3, self.lag4_vec4);self.lag4_time = 0;}
	if (self.lag5_time) if (time > self.lag5_time) {self.lag_func(self.lag5_time, self.lag5_float1, self.lag5_float2, self.lag5_entity1, self.lag5_vec1, self.lag5_vec2, self.lag5_vec3, self.lag5_vec4);self.lag5_time = 0;}
};

float lag_additem(float t, float f1, float f2, entity e1, vector v1, vector v2, vector v3, vector v4)
{
	if (self.lag1_time == 0) {self.lag1_time = t;self.lag1_float1 = f1;self.lag1_float2 = f2;self.lag1_entity1 = e1;self.lag1_vec1 = v1;self.lag1_vec2 = v2;self.lag1_vec3 = v3;self.lag1_vec4 = v4;return TRUE;}
	if (self.lag2_time == 0) {self.lag2_time = t;self.lag2_float1 = f1;self.lag2_float2 = f2;self.lag2_entity1 = e1;self.lag2_vec1 = v1;self.lag2_vec2 = v2;self.lag2_vec3 = v3;self.lag2_vec4 = v4;return TRUE;}
	if (self.lag3_time == 0) {self.lag3_time = t;self.lag3_float1 = f1;self.lag3_float2 = f2;self.lag3_entity1 = e1;self.lag3_vec1 = v1;self.lag3_vec2 = v2;self.lag3_vec3 = v3;self.lag3_vec4 = v4;return TRUE;}
	if (self.lag4_time == 0) {self.lag4_time = t;self.lag4_float1 = f1;self.lag4_float2 = f2;self.lag4_entity1 = e1;self.lag4_vec1 = v1;self.lag4_vec2 = v2;self.lag4_vec3 = v3;self.lag4_vec4 = v4;return TRUE;}
	if (self.lag5_time == 0) {self.lag5_time = t;self.lag5_float1 = f1;self.lag5_float2 = f2;self.lag5_entity1 = e1;self.lag5_vec1 = v1;self.lag5_vec2 = v2;self.lag5_vec3 = v3;self.lag5_vec4 = v4;return TRUE;}
	// no room for it (what is the best thing to do here??)
	return FALSE;
};


// Random skill system
.float bot_thinkskill;
.float bot_mouseskill;
.float bot_predictionskill;
.float bot_offsetskill;


// spawnfunc_waypoint navigation system

// itemscore = (howmuchmoreIwant / howmuchIcanwant) / itemdistance
// waypointscore = 0.7 / waypointdistance

.entity wp00, wp01, wp02, wp03, wp04, wp05, wp06, wp07;
.entity wp08, wp09, wp10, wp11, wp12, wp13, wp14, wp15;
.entity wp16, wp17, wp18, wp19, wp20, wp21, wp22, wp23, wp24, wp25, wp26, wp27, wp28, wp29, wp30, wp31;
.float wp00mincost, wp01mincost, wp02mincost, wp03mincost, wp04mincost, wp05mincost, wp06mincost, wp07mincost;
.float wp08mincost, wp09mincost, wp10mincost, wp11mincost, wp12mincost, wp13mincost, wp14mincost, wp15mincost;
.float wp16mincost, wp17mincost, wp18mincost, wp19mincost, wp20mincost, wp21mincost, wp22mincost, wp23mincost, wp24mincost, wp25mincost, wp26mincost, wp27mincost, wp28mincost, wp29mincost, wp30mincost, wp31mincost;
.float wpfire, wpcost, wpconsidered;
.float wpisbox;
.float wpflags;
.vector wpnearestpoint;

// stack of current goals (the last one of which may be an item or other
// desirable object, the rest are typically waypoints to reach it)
.entity goalcurrent, goalstack01, goalstack02, goalstack03;
.entity goalstack04, goalstack05, goalstack06, goalstack07;
.entity goalstack08, goalstack09, goalstack10, goalstack11;
.entity goalstack12, goalstack13, goalstack14, goalstack15;
.entity goalstack16, goalstack17, goalstack18, goalstack19;
.entity goalstack20, goalstack21, goalstack22, goalstack23;
.entity goalstack24, goalstack25, goalstack26, goalstack27;
.entity goalstack28, goalstack29, goalstack30, goalstack31;

.entity nearestwaypoint;
.float nearestwaypointtimeout;

// used during navigation_goalrating_begin/end sessions
float navigation_bestrating;
entity navigation_bestgoal;
entity navigation_alternativegoal;
.entity alternativegoal;




/////////////////////////////////////////////////////////////////////////////
// spawnfunc_waypoint management
/////////////////////////////////////////////////////////////////////////////

// waypoints with this flag are not saved, they are automatically generated
// waypoints like jump pads, teleporters, and items
float WAYPOINTFLAG_GENERATED = 8388608;
float WAYPOINTFLAG_ITEM = 4194304;
float WAYPOINTFLAG_TELEPORT = 2097152;
float WAYPOINTFLAG_NORELINK = 1048576;

// add a new link to the spawnfunc_waypoint, replacing the furthest link it already has
void waypoint_addlink(entity from, entity to)
{
	local float c;

	if (from == to)
		return;
	if (from.wpflags & WAYPOINTFLAG_NORELINK)
		return;

	if (from.wp00 == to) return;if (from.wp01 == to) return;if (from.wp02 == to) return;if (from.wp03 == to) return;
	if (from.wp04 == to) return;if (from.wp05 == to) return;if (from.wp06 == to) return;if (from.wp07 == to) return;
	if (from.wp08 == to) return;if (from.wp09 == to) return;if (from.wp10 == to) return;if (from.wp11 == to) return;
	if (from.wp12 == to) return;if (from.wp13 == to) return;if (from.wp14 == to) return;if (from.wp15 == to) return;
	if (from.wp16 == to) return;if (from.wp17 == to) return;if (from.wp18 == to) return;if (from.wp19 == to) return;
	if (from.wp20 == to) return;if (from.wp21 == to) return;if (from.wp22 == to) return;if (from.wp23 == to) return;
	if (from.wp24 == to) return;if (from.wp25 == to) return;if (from.wp26 == to) return;if (from.wp27 == to) return;
	if (from.wp28 == to) return;if (from.wp29 == to) return;if (from.wp30 == to) return;if (from.wp31 == to) return;

	if (to.wpisbox || from.wpisbox)
	{
		// if either is a box we have to find the nearest points on them to
		// calculate the distance properly
		local vector v1, v2, m1, m2;
		v1 = from.origin;
		m1 = to.absmin;
		m2 = to.absmax;
		v1_x = bound(m1_x, v1_x, m2_x);
		v1_y = bound(m1_y, v1_y, m2_y);
		v1_z = bound(m1_z, v1_z, m2_z);
		v2 = to.origin;
		m1 = from.absmin;
		m2 = from.absmax;
		v2_x = bound(m1_x, v2_x, m2_x);
		v2_y = bound(m1_y, v2_y, m2_y);
		v2_z = bound(m1_z, v2_z, m2_z);
		v2 = to.origin;
		c = vlen(v2 - v1);
	}
	else
		c = vlen(to.origin - from.origin);

	if (from.wp31mincost < c) return;
	if (from.wp30mincost < c) {from.wp31 = to;from.wp31mincost = c;return;} from.wp31 = from.wp30;from.wp31mincost = from.wp30mincost;
	if (from.wp29mincost < c) {from.wp30 = to;from.wp30mincost = c;return;} from.wp30 = from.wp29;from.wp30mincost = from.wp29mincost;
	if (from.wp28mincost < c) {from.wp29 = to;from.wp29mincost = c;return;} from.wp29 = from.wp28;from.wp29mincost = from.wp28mincost;
	if (from.wp27mincost < c) {from.wp28 = to;from.wp28mincost = c;return;} from.wp28 = from.wp27;from.wp28mincost = from.wp27mincost;
	if (from.wp26mincost < c) {from.wp27 = to;from.wp27mincost = c;return;} from.wp27 = from.wp26;from.wp27mincost = from.wp26mincost;
	if (from.wp25mincost < c) {from.wp26 = to;from.wp26mincost = c;return;} from.wp26 = from.wp25;from.wp26mincost = from.wp25mincost;
	if (from.wp24mincost < c) {from.wp25 = to;from.wp25mincost = c;return;} from.wp25 = from.wp24;from.wp25mincost = from.wp24mincost;
	if (from.wp23mincost < c) {from.wp24 = to;from.wp24mincost = c;return;} from.wp24 = from.wp23;from.wp24mincost = from.wp23mincost;
	if (from.wp22mincost < c) {from.wp23 = to;from.wp23mincost = c;return;} from.wp23 = from.wp22;from.wp23mincost = from.wp22mincost;
	if (from.wp21mincost < c) {from.wp22 = to;from.wp22mincost = c;return;} from.wp22 = from.wp21;from.wp22mincost = from.wp21mincost;
	if (from.wp20mincost < c) {from.wp21 = to;from.wp21mincost = c;return;} from.wp21 = from.wp20;from.wp21mincost = from.wp20mincost;
	if (from.wp19mincost < c) {from.wp20 = to;from.wp20mincost = c;return;} from.wp20 = from.wp19;from.wp20mincost = from.wp19mincost;
	if (from.wp18mincost < c) {from.wp19 = to;from.wp19mincost = c;return;} from.wp19 = from.wp18;from.wp19mincost = from.wp18mincost;
	if (from.wp17mincost < c) {from.wp18 = to;from.wp18mincost = c;return;} from.wp18 = from.wp17;from.wp18mincost = from.wp17mincost;
	if (from.wp16mincost < c) {from.wp17 = to;from.wp17mincost = c;return;} from.wp17 = from.wp16;from.wp17mincost = from.wp16mincost;
	if (from.wp15mincost < c) {from.wp16 = to;from.wp16mincost = c;return;} from.wp16 = from.wp15;from.wp16mincost = from.wp15mincost;
	if (from.wp14mincost < c) {from.wp15 = to;from.wp15mincost = c;return;} from.wp15 = from.wp14;from.wp15mincost = from.wp14mincost;
	if (from.wp13mincost < c) {from.wp14 = to;from.wp14mincost = c;return;} from.wp14 = from.wp13;from.wp14mincost = from.wp13mincost;
	if (from.wp12mincost < c) {from.wp13 = to;from.wp13mincost = c;return;} from.wp13 = from.wp12;from.wp13mincost = from.wp12mincost;
	if (from.wp11mincost < c) {from.wp12 = to;from.wp12mincost = c;return;} from.wp12 = from.wp11;from.wp12mincost = from.wp11mincost;
	if (from.wp10mincost < c) {from.wp11 = to;from.wp11mincost = c;return;} from.wp11 = from.wp10;from.wp11mincost = from.wp10mincost;
	if (from.wp09mincost < c) {from.wp10 = to;from.wp10mincost = c;return;} from.wp10 = from.wp09;from.wp10mincost = from.wp09mincost;
	if (from.wp08mincost < c) {from.wp09 = to;from.wp09mincost = c;return;} from.wp09 = from.wp08;from.wp09mincost = from.wp08mincost;
	if (from.wp07mincost < c) {from.wp08 = to;from.wp08mincost = c;return;} from.wp08 = from.wp07;from.wp08mincost = from.wp07mincost;
	if (from.wp06mincost < c) {from.wp07 = to;from.wp07mincost = c;return;} from.wp07 = from.wp06;from.wp07mincost = from.wp06mincost;
	if (from.wp05mincost < c) {from.wp06 = to;from.wp06mincost = c;return;} from.wp06 = from.wp05;from.wp06mincost = from.wp05mincost;
	if (from.wp04mincost < c) {from.wp05 = to;from.wp05mincost = c;return;} from.wp05 = from.wp04;from.wp05mincost = from.wp04mincost;
	if (from.wp03mincost < c) {from.wp04 = to;from.wp04mincost = c;return;} from.wp04 = from.wp03;from.wp04mincost = from.wp03mincost;
	if (from.wp02mincost < c) {from.wp03 = to;from.wp03mincost = c;return;} from.wp03 = from.wp02;from.wp03mincost = from.wp02mincost;
	if (from.wp01mincost < c) {from.wp02 = to;from.wp02mincost = c;return;} from.wp02 = from.wp01;from.wp02mincost = from.wp01mincost;
	if (from.wp00mincost < c) {from.wp01 = to;from.wp01mincost = c;return;} from.wp01 = from.wp00;from.wp01mincost = from.wp00mincost;
	from.wp00 = to;from.wp00mincost = c;return;
};

// fields you can query using prvm_global server to get some statistics about waypoint linking culling
float relink_total, relink_walkculled, relink_pvsculled, relink_lengthculled;

// relink this spawnfunc_waypoint
// (precompile a list of all reachable waypoints from this spawnfunc_waypoint)
// (SLOW!)
void waypoint_think()
{
	local entity e;
	local vector sv, sm1, sm2, ev, em1, em2, dv;
	//dprint("waypoint_think wpisbox = ", ftos(self.wpisbox), "\n");
	sm1 = self.origin + self.mins;
	sm2 = self.origin + self.maxs;
	stepheightvec = cvar("sv_stepheight") * '0 0 1';
	for(e = world; (e = find(e, classname, "waypoint")); )
	{
		if (boxesoverlap(self.absmin, self.absmax, e.absmin, e.absmax))
		{
			waypoint_addlink(self, e);
			waypoint_addlink(e, self);
		}
		else
		{
			++relink_total;
			if(!checkpvs(self.origin, e))
			{
				++relink_pvsculled;
				continue;
			}
			sv = e.origin;
			sv_x = bound(sm1_x, sv_x, sm2_x);
			sv_y = bound(sm1_y, sv_y, sm2_y);
			sv_z = bound(sm1_z, sv_z, sm2_z);
			ev = self.origin;
			em1 = e.origin + e.mins;
			em2 = e.origin + e.maxs;
			ev_x = bound(em1_x, ev_x, em2_x);
			ev_y = bound(em1_y, ev_y, em2_y);
			ev_z = bound(em1_z, ev_z, em2_z);
			dv = ev - sv;
			dv_z = 0;
			if (vlen(dv) >= 1050) // max search distance in XY
			{
				++relink_lengthculled;
				continue;
			}
			navigation_testtracewalk = 0;
			if (!self.wpisbox)
			{
				tracebox(sv - PL_MIN_z * '0 0 1', PL_MIN, PL_MAX, sv, FALSE, self);
				if (!trace_startsolid)
				{
					//dprint("sv deviation", vtos(trace_endpos - sv), "\n");
					sv = trace_endpos + '0 0 1';
				}
			}
			if (!e.wpisbox)
			{
				tracebox(ev - PL_MIN_z * '0 0 1', PL_MIN, PL_MAX, ev, FALSE, e);
				if (!trace_startsolid)
				{
					//dprint("ev deviation", vtos(trace_endpos - ev), "\n");
					ev = trace_endpos + '0 0 1';
				}
			}
			//traceline(self.origin, e.origin, FALSE, world);
			//if (trace_fraction == 1)
			if (!self.wpisbox && tracewalk(self, sv, PL_MIN, PL_MAX, ev, MOVE_NOMONSTERS))
				waypoint_addlink(self, e);
			else
				relink_walkculled += 0.5;
			if (!e.wpisbox && tracewalk(e, ev, PL_MIN, PL_MAX, sv, MOVE_NOMONSTERS))
				waypoint_addlink(e, self);
			else
				relink_walkculled += 0.5;
		}
	}
	navigation_testtracewalk = 0;
};

void waypoint_clearlinks(entity wp)
{
	// clear links to other waypoints
	local float f;
	f = 10000000;
	wp.wp00 = wp.wp01 = wp.wp02 = wp.wp03 = wp.wp04 = wp.wp05 = wp.wp06 = wp.wp07 = world;wp.wp00mincost = wp.wp01mincost = wp.wp02mincost = wp.wp03mincost = wp.wp04mincost = wp.wp05mincost = wp.wp06mincost = wp.wp07mincost = f;
	wp.wp08 = wp.wp09 = wp.wp10 = wp.wp11 = wp.wp12 = wp.wp13 = wp.wp14 = wp.wp15 = world;wp.wp08mincost = wp.wp09mincost = wp.wp10mincost = wp.wp11mincost = wp.wp12mincost = wp.wp13mincost = wp.wp14mincost = wp.wp15mincost = f;
	wp.wp16 = wp.wp17 = wp.wp18 = wp.wp19 = wp.wp20 = wp.wp21 = wp.wp22 = wp.wp23 = world;wp.wp16mincost = wp.wp17mincost = wp.wp18mincost = wp.wp19mincost = wp.wp20mincost = wp.wp21mincost = wp.wp22mincost = wp.wp23mincost = f;
	wp.wp24 = wp.wp25 = wp.wp26 = wp.wp27 = wp.wp28 = wp.wp29 = wp.wp30 = wp.wp31 = world;wp.wp24mincost = wp.wp25mincost = wp.wp26mincost = wp.wp27mincost = wp.wp28mincost = wp.wp29mincost = wp.wp30mincost = wp.wp31mincost = f;
};

// tell a spawnfunc_waypoint to relink
void waypoint_schedulerelink(entity wp)
{
	if (wp == world)
		return;
	// TODO: add some sort of visible box in edit mode for box waypoints
	if (cvar("g_waypointeditor"))
	{
		local vector m1, m2;
		m1 = wp.mins;
		m2 = wp.maxs;
		setmodel(wp, "models/runematch/rune.mdl"); wp.effects = EF_LOWPRECISION;
		setsize(wp, m1, m2);
		if (wp.wpflags & WAYPOINTFLAG_ITEM)
			wp.colormod = '1 0 0';
		else if (wp.wpflags & WAYPOINTFLAG_GENERATED)
			wp.colormod = '1 1 0';
		else
			wp.colormod = '1 1 1';
	}
	else
		wp.model = "";
	wp.wpisbox = vlen(wp.size) > 0;
	wp.enemy = world;
	wp.owner = world;
	if (!(wp.wpflags & WAYPOINTFLAG_NORELINK))
		waypoint_clearlinks(wp);
	// schedule an actual relink on next frame
	wp.think = waypoint_think;
	wp.nextthink = time;
	wp.effects = EF_LOWPRECISION;
}

// create a new spawnfunc_waypoint and automatically link it to other waypoints, and link
// them back to it as well
// (suitable for spawnfunc_waypoint editor)
entity waypoint_spawn(vector m1, vector m2, float f)
{
	local entity w;
	local vector org;
	w = find(world, classname, "waypoint");
	while (w)
	{
		// if a matching spawnfunc_waypoint already exists, don't add a duplicate
		if (boxesoverlap(m1, m2, w.absmin, w.absmax))
			return w;
		w = find(w, classname, "waypoint");
	}
	w = spawn();
	w.classname = "waypoint";
	w.wpflags = f;
	setorigin(w, (m1 + m2) * 0.5);
	setsize(w, m1 - w.origin, m2 - w.origin);
	if (vlen(w.size) > 0)
		w.wpisbox = TRUE;

	if(!(f & WAYPOINTFLAG_GENERATED))
	if(!w.wpisbox)
	{
		traceline(w.origin + '0 0 1', w.origin + PL_MIN_z * '0 0 1' - '0 0 1', MOVE_NOMONSTERS, w);
		if (trace_fraction < 1)
			setorigin(w, trace_endpos - PL_MIN_z * '0 0 1');

		// check if the start position is stuck
		tracebox(w.origin, PL_MIN + '-1 -1 -1', PL_MAX + '1 1 1', w.origin, MOVE_NOMONSTERS, w);
		if (trace_startsolid)
		{
			org = w.origin + '0 0 26';
			tracebox(org, PL_MIN, PL_MAX, w.origin, MOVE_WORLDONLY, w);
			if(trace_startsolid)
			{
				org = w.origin + '2 2 2';
				tracebox(org, PL_MIN, PL_MAX, w.origin, MOVE_WORLDONLY, w);
				if(trace_startsolid)
				{
					org = w.origin + '-2 -2 2';
					tracebox(org, PL_MIN, PL_MAX, w.origin, MOVE_WORLDONLY, w);
					if(trace_startsolid)
					{
						org = w.origin + '-2 2 2';
						tracebox(org, PL_MIN, PL_MAX, w.origin, MOVE_WORLDONLY, w);
						if(trace_startsolid)
						{
							org = w.origin + '2 -2 2';
							tracebox(org, PL_MIN, PL_MAX, w.origin, MOVE_WORLDONLY, w);
							if(trace_startsolid)
							{
								// this WP is in solid, refuse it
								dprint("Killed a waypoint that was stuck in solid at ", vtos(org), "\n");
								remove(w);
								return world;
							}
						}
					}
				}
			}
			setorigin(w, org * 0.05 + trace_endpos * 0.95); // don't trust the trace fully
		}

		tracebox(w.origin, PL_MIN, PL_MAX, w.origin - '0 0 128', MOVE_WORLDONLY, w);
		if(trace_startsolid)
		{
			dprint("Killed a waypoint that was stuck in solid ", vtos(w.origin), "\n");
			remove(w);
			return world;
		}
		if (!trace_inwater)
		{
			if(trace_fraction == 1)
			{
				dprint("Killed a waypoint that was stuck in air at ", vtos(w.origin), "\n");
				remove(w);
				return world;
			}
			trace_endpos_z += 0.1; // don't trust the trace fully
//			dprint("Moved waypoint at ", vtos(w.origin), " by ", ftos(vlen(w.origin - trace_endpos)));
//			dprint(" direction: ", vtos((trace_endpos - w.origin)), "\n");
			setorigin(w, trace_endpos);
		}
	}

	waypoint_clearlinks(w);
	//waypoint_schedulerelink(w);
	return w;
};

// spawnfunc_waypoint map entity
void spawnfunc_waypoint()
{
	setorigin(self, self.origin);
	// schedule a relink after other waypoints have had a chance to spawn
	waypoint_clearlinks(self);
	//waypoint_schedulerelink(self);
};

// remove a spawnfunc_waypoint, and schedule all neighbors to relink
void waypoint_remove(entity e)
{
	// tell all linked waypoints that they need to relink
	waypoint_schedulerelink(e.wp00);
	waypoint_schedulerelink(e.wp01);
	waypoint_schedulerelink(e.wp02);
	waypoint_schedulerelink(e.wp03);
	waypoint_schedulerelink(e.wp04);
	waypoint_schedulerelink(e.wp05);
	waypoint_schedulerelink(e.wp06);
	waypoint_schedulerelink(e.wp07);
	waypoint_schedulerelink(e.wp08);
	waypoint_schedulerelink(e.wp09);
	waypoint_schedulerelink(e.wp10);
	waypoint_schedulerelink(e.wp11);
	waypoint_schedulerelink(e.wp12);
	waypoint_schedulerelink(e.wp13);
	waypoint_schedulerelink(e.wp14);
	waypoint_schedulerelink(e.wp15);
	waypoint_schedulerelink(e.wp16);
	waypoint_schedulerelink(e.wp17);
	waypoint_schedulerelink(e.wp18);
	waypoint_schedulerelink(e.wp19);
	waypoint_schedulerelink(e.wp20);
	waypoint_schedulerelink(e.wp21);
	waypoint_schedulerelink(e.wp22);
	waypoint_schedulerelink(e.wp23);
	waypoint_schedulerelink(e.wp24);
	waypoint_schedulerelink(e.wp25);
	waypoint_schedulerelink(e.wp26);
	waypoint_schedulerelink(e.wp27);
	waypoint_schedulerelink(e.wp28);
	waypoint_schedulerelink(e.wp29);
	waypoint_schedulerelink(e.wp30);
	waypoint_schedulerelink(e.wp31);
	// and now remove the spawnfunc_waypoint
	remove(e);
};

// empties the map of waypoints
void waypoint_removeall()
{
	local entity head, next;
	head = findchain(classname, "waypoint");
	while (head)
	{
		next = head.chain;
		remove(head);
		head = next;
	}
};

// tell all waypoints to relink
// (is this useful at all?)
void waypoint_schedulerelinkall()
{
	local entity head;
	relink_total = relink_walkculled = relink_pvsculled = relink_lengthculled = 0;
	head = findchain(classname, "waypoint");
	while (head)
	{
		waypoint_schedulerelink(head);
		head = head.chain;
	}
};

// save waypoints to gamedir/data/maps/mapname.waypoints
// TODO: support saving wayboxes
void waypoint_saveall()
{
	local string filename, s;
	local float file, c;
	local entity w;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints");
	file = fopen(filename, FILE_WRITE);
	if (file >= 0)
	{
		c = 0;
		w = findchain(classname, "waypoint");
		while (w)
		{
			if (!(w.wpflags & WAYPOINTFLAG_GENERATED))
			{
				s = strcat(vtos(w.origin + w.mins), "\n");
				s = strcat(s, vtos(w.origin + w.maxs));
				s = strcat(s, "\n");
				s = strcat(s, ftos(w.wpflags));
				s = strcat(s, "\n");
				fputs(file, s);
				c = c + 1;
			}
			w = w.chain;
		}
		fclose(file);
		bprint("saved ");
		bprint(ftos(c));
		bprint(" waypoints to maps/");
		bprint(mapname);
		bprint(".waypoints\n");
	}
	else
	{
		bprint("waypoint save to ");
		bprint(filename);
		bprint(" failed\n");
	}
};

// load waypoints from file
float waypoint_loadall()
{
	local string filename, s;
	local float file, cwp, cwb, fl;
	local vector m1, m2;
	cwp = 0;
	cwb = 0;
	filename = strcat("maps/", mapname);
	filename = strcat(filename, ".waypoints");
	file = fopen(filename, FILE_READ);
	if (file >= 0)
	{
		while (1)
		{
			s = fgets(file);
			if (!s)
				break;
			m1 = stov(s);
			s = fgets(file);
			if (!s)
				break;
			m2 = stov(s);
			s = fgets(file);
			if (!s)
				break;
			fl = stof(s);
			waypoint_spawn(m1, m2, fl);
			if (m1 == m2)
				cwp = cwp + 1;
			else
				cwb = cwb + 1;
		}
		fclose(file);
		dprint("loaded ");
		dprint(ftos(cwp));
		dprint(" waypoints and ");
		dprint(ftos(cwb));
		dprint(" wayboxes from maps/");
		dprint(mapname);
		dprint(".waypoints\n");
	}
	else
	{
		dprint("waypoint load from ");
		dprint(filename);
		dprint(" failed\n");
	}
	return cwp + cwb;
};

void waypoint_spawnforitem(entity e)
{
	local entity w;
	local vector org;

	if(!bot_waypoints_for_items)
		return;

	org = e.origin + (e.mins + e.maxs) * 0.5;
	org_z = e.origin_z + e.mins_z - PL_MIN_z + 1;
	e.nearestwaypointtimeout = time + 1000000000;
	// don't spawn an item spawnfunc_waypoint if it already exists
	w = findchain(classname, "waypoint");
	while (w)
	{
		if (w.wpisbox)
		{
			if (boxesoverlap(org, org, w.absmin, w.absmax))
			{
				e.nearestwaypoint = w;
				return;
			}
		}
		else
		{
			if (vlen(w.origin - org) < 16)
			{
				e.nearestwaypoint = w;
				return;
			}
		}
		w = w.chain;
	}
	e.nearestwaypoint = waypoint_spawn(org, org, WAYPOINTFLAG_GENERATED | WAYPOINTFLAG_ITEM);
};

void waypoint_spawnforteleporter(entity e, vector destination, float timetaken)
{
	local entity w;
	local entity dw;
	w = waypoint_spawn(e.absmin, e.absmax, WAYPOINTFLAG_GENERATED | WAYPOINTFLAG_TELEPORT | WAYPOINTFLAG_NORELINK);
	dw = waypoint_spawn(destination, destination, WAYPOINTFLAG_GENERATED);
	// one way link to the destination
	w.wp00 = dw;
	w.wp00mincost = timetaken; // this is just for jump pads
	// the teleporter's nearest spawnfunc_waypoint is this one
	// (teleporters are not goals, so this is probably useless)
	e.nearestwaypoint = w;
	e.nearestwaypointtimeout = time + 1000000000;
};





/////////////////////////////////////////////////////////////////////////////
// goal stack
/////////////////////////////////////////////////////////////////////////////

// completely empty the goal stack, used when deciding where to go
void navigation_clearroute()
{
	self.goalcurrent = world;
	self.goalstack01 = world;
	self.goalstack02 = world;
	self.goalstack03 = world;
	self.goalstack04 = world;
	self.goalstack05 = world;
	self.goalstack06 = world;
	self.goalstack07 = world;
	self.goalstack08 = world;
	self.goalstack09 = world;
	self.goalstack10 = world;
	self.goalstack11 = world;
	self.goalstack12 = world;
	self.goalstack13 = world;
	self.goalstack14 = world;
	self.goalstack15 = world;
	self.goalstack16 = world;
	self.goalstack17 = world;
	self.goalstack18 = world;
	self.goalstack19 = world;
	self.goalstack20 = world;
	self.goalstack21 = world;
	self.goalstack22 = world;
	self.goalstack23 = world;
	self.goalstack24 = world;
	self.goalstack25 = world;
	self.goalstack26 = world;
	self.goalstack27 = world;
	self.goalstack28 = world;
	self.goalstack29 = world;
	self.goalstack30 = world;
	self.goalstack31 = world;
};

// add a new goal at the beginning of the stack
// (in other words: add a new prerequisite before going to the later goals)
void navigation_pushroute(entity e)
{
	self.goalstack31 = self.goalstack30;
	self.goalstack30 = self.goalstack29;
	self.goalstack29 = self.goalstack28;
	self.goalstack28 = self.goalstack27;
	self.goalstack27 = self.goalstack26;
	self.goalstack26 = self.goalstack25;
	self.goalstack25 = self.goalstack24;
	self.goalstack24 = self.goalstack23;
	self.goalstack23 = self.goalstack22;
	self.goalstack22 = self.goalstack21;
	self.goalstack21 = self.goalstack20;
	self.goalstack20 = self.goalstack19;
	self.goalstack19 = self.goalstack18;
	self.goalstack18 = self.goalstack17;
	self.goalstack17 = self.goalstack16;
	self.goalstack16 = self.goalstack15;
	self.goalstack15 = self.goalstack14;
	self.goalstack14 = self.goalstack13;
	self.goalstack13 = self.goalstack12;
	self.goalstack12 = self.goalstack11;
	self.goalstack11 = self.goalstack10;
	self.goalstack10 = self.goalstack09;
	self.goalstack09 = self.goalstack08;
	self.goalstack08 = self.goalstack07;
	self.goalstack07 = self.goalstack06;
	self.goalstack06 = self.goalstack05;
	self.goalstack05 = self.goalstack04;
	self.goalstack04 = self.goalstack03;
	self.goalstack03 = self.goalstack02;
	self.goalstack02 = self.goalstack01;
	self.goalstack01 = self.goalcurrent;
	self.goalcurrent = e;
};

// remove first goal from stack
// (in other words: remove a prerequisite for reaching the later goals)
// (used when a spawnfunc_waypoint is reached)
void navigation_poproute()
{
	self.goalcurrent = self.goalstack01;
	self.goalstack01 = self.goalstack02;
	self.goalstack02 = self.goalstack03;
	self.goalstack03 = self.goalstack04;
	self.goalstack04 = self.goalstack05;
	self.goalstack05 = self.goalstack06;
	self.goalstack06 = self.goalstack07;
	self.goalstack07 = self.goalstack08;
	self.goalstack08 = self.goalstack09;
	self.goalstack09 = self.goalstack10;
	self.goalstack10 = self.goalstack11;
	self.goalstack11 = self.goalstack12;
	self.goalstack12 = self.goalstack13;
	self.goalstack13 = self.goalstack14;
	self.goalstack14 = self.goalstack15;
	self.goalstack15 = self.goalstack16;
	self.goalstack16 = self.goalstack17;
	self.goalstack17 = self.goalstack18;
	self.goalstack18 = self.goalstack19;
	self.goalstack19 = self.goalstack20;
	self.goalstack20 = self.goalstack21;
	self.goalstack21 = self.goalstack22;
	self.goalstack22 = self.goalstack23;
	self.goalstack23 = self.goalstack24;
	self.goalstack24 = self.goalstack25;
	self.goalstack25 = self.goalstack26;
	self.goalstack26 = self.goalstack27;
	self.goalstack27 = self.goalstack28;
	self.goalstack28 = self.goalstack29;
	self.goalstack29 = self.goalstack30;
	self.goalstack30 = self.goalstack31;
	self.goalstack31 = world;
};

// find the spawnfunc_waypoint near a dynamic goal such as a dropped weapon
entity navigation_findnearestwaypoint(entity player, float walkfromwp)
{
	local entity waylist, w, best;
	local float dist, bestdist;
	local vector v, org, pm1, pm2;
	pm1 = player.origin + PL_MIN;
	pm2 = player.origin + PL_MAX;
	waylist = findchain(classname, "waypoint");
	// do two scans, because box test is cheaper
	w = waylist;
	while (w)
	{
		// if object is touching spawnfunc_waypoint
		if (boxesoverlap(pm1, pm2, w.absmin, w.absmax))
			return w;
		w = w.chain;
	}

	org = player.origin + (player.mins_z - PL_MIN_z) * '0 0 1';
	if(player.tag_entity)
		org = org + player.tag_entity.origin;
	if (navigation_testtracewalk)
		te_plasmaburn(org);
	best = world;
	bestdist = 1050;

	// box check failed, try walk
	w = waylist;
	while (w)
	{
		// if object can walk from spawnfunc_waypoint
		if (w.wpisbox)
		{
			local vector wm1, wm2;
			wm1 = w.origin + w.mins;
			wm2 = w.origin + w.maxs;
			v_x = bound(wm1_x, org_x, wm2_x);
			v_y = bound(wm1_y, org_y, wm2_y);
			v_z = bound(wm1_z, org_z, wm2_z);
		}
		else
			v = w.origin;
		dist = vlen(v - org);
		if (bestdist > dist)
		{
			if (walkfromwp)
			{
				traceline(v, org, TRUE, player);
				if (trace_fraction == 1)
				if (tracewalk(player, v, PL_MIN, PL_MAX, org, MOVE_NORMAL))
				{
					bestdist = dist;
					best = w;
				}
			}
			else
			{
				traceline(v, org, TRUE, player);
				if (trace_fraction == 1)
				if (tracewalk(player, org, PL_MIN, PL_MAX, v, MOVE_NORMAL))
				{
					bestdist = dist;
					best = w;
				}
			}
		}
		w = w.chain;
	}
	return best;
}

// finds the waypoints near the bot initiating a navigation query
float navigation_markroutes_nearestwaypoints(entity waylist, float maxdist)
{
	local entity head;
	local vector v, m1, m2, diff;
	local float c;
//	navigation_testtracewalk = TRUE;
	c = 0;
	head = waylist;
	while (head)
	{
		if (!head.wpconsidered)
		{
			if (head.wpisbox)
			{
				m1 = head.origin + head.mins;
				m2 = head.origin + head.maxs;
				v = self.origin;
				v_x = bound(m1_x, v_x, m2_x);
				v_y = bound(m1_y, v_y, m2_y);
				v_z = bound(m1_z, v_z, m2_z);
			}
			else
				v = head.origin;
			diff = v - self.origin;
			diff_z = max(0, diff_z);
			if (vlen(diff) < maxdist)
			{
				head.wpconsidered = TRUE;
				if (tracewalk(self, self.origin, self.mins, self.maxs, v, MOVE_NORMAL))
				{
					head.wpnearestpoint = v;
					head.wpcost = vlen(v - self.origin) + head.dmg;
					head.wpfire = 1;
					head.enemy = world;
					c = c + 1;
				}
			}
		}
		head = head.chain;
	}
	//navigation_testtracewalk = FALSE;
	return c;
}

// updates a path link if a spawnfunc_waypoint link is better than the current one
void navigation_markroutes_checkwaypoint(entity w, entity wp, float cost2, vector p)
{
	local vector m1;
	local vector m2;
	local vector v;
	if (wp.wpisbox)
	{
		m1 = wp.absmin;
		m2 = wp.absmax;
		v_x = bound(m1_x, p_x, m2_x);
		v_y = bound(m1_y, p_y, m2_y);
		v_z = bound(m1_z, p_z, m2_z);
	}
	else
		v = wp.origin;
	cost2 = cost2 + vlen(v);
	if (wp.wpcost > cost2)
	{
		wp.wpcost = cost2;
		wp.enemy = w;
		wp.wpfire = 1;
		wp.wpnearestpoint = v;
	}
};

// queries the entire spawnfunc_waypoint network for pathes leading away from the bot
void navigation_markroutes()
{
	local entity w, wp, waylist;
	local float searching, cost, cost2;
	local vector p;
	w = waylist = findchain(classname, "waypoint");
	while (w)
	{
		w.wpconsidered = FALSE;
		w.wpnearestpoint = '0 0 0';
		w.wpcost = 10000000;
		w.wpfire = 0;
		w.enemy = world;
		w = w.chain;
	}

	// try a short range search for the nearest waypoints, and expand thesearch repeatedly if none are found
	local float i, increment, maxdistance;
	increment = 500;
	if(self.flags & FL_ONGROUND)
		maxdistance = 50000;
	else
		maxdistance = 1500;

	for(i=increment;!navigation_markroutes_nearestwaypoints(waylist, i)&&i<maxdistance;i+=increment);

	searching = TRUE;
	while (searching)
	{
		searching = FALSE;
		w = waylist;
		while (w)
		{
			if (w.wpfire)
			{
				searching = TRUE;
				w.wpfire = 0;
				cost = w.wpcost;
				p = w.wpnearestpoint;
				wp = w.wp00;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp00mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp01;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp01mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp02;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp02mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp03;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp03mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp04;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp04mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp05;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp05mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp06;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp06mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp07;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp07mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp08;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp08mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp09;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp09mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp10;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp10mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp11;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp11mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp12;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp12mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp13;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp13mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp14;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp14mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp15;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp15mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp16;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp16mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp17;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp17mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp18;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp18mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp19;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp19mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp20;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp20mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp21;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp21mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp22;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp22mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp23;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp23mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp24;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp24mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp25;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp25mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp26;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp26mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp27;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp27mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp28;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp28mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp29;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp29mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp30;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp30mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp31;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + wp.wp31mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
			}
			w = w.chain;
		}
	}
};

// updates the best goal according to a weighted calculation of travel cost and item value of a new proposed item
.void() havocbot_role;
void() havocbot_role_ctf_offense;
void navigation_routerating(entity e, float f, float rangebias)
{
	if (!e)
		return;
	//te_wizspike(e.origin);
	//bprint(etos(e));
	//bprint("\n");
	// update the cached spawnfunc_waypoint link on a dynamic item entity
	if (time > e.nearestwaypointtimeout)
	{
		e.nearestwaypoint = navigation_findnearestwaypoint(e, TRUE);
		e.nearestwaypointtimeout = time + random() * 3 + 5;
	}
	//dprint(e.classname, " ", ftos(f));
	//dprint("-- checking ", e.classname, " (with cost ", ftos(e.nearestwaypoint.wpcost), ")\n");
	if (e.nearestwaypoint)
	if (e.nearestwaypoint.wpcost < 10000000)
	{
		//te_wizspike(e.nearestwaypoint.wpnearestpoint);
		//dprint(e.classname, " ", ftos(f), "/(1+", ftos((e.nearestwaypoint.wpcost + vlen(e.origin - e.nearestwaypoint.wpnearestpoint))), "/", ftos(rangebias), ") = ");
		f = f * rangebias / (rangebias + (e.nearestwaypoint.wpcost + vlen(e.origin - e.nearestwaypoint.wpnearestpoint)));
		//if (self.havocbot_role == havocbot_role_ctf_offense)
		//	dprint("-- considering ", e.classname, " (with rating ", ftos(f), ")\n");
		//dprint(ftos(f));
		if (navigation_bestrating < f)
		{
			navigation_alternativegoal = navigation_bestgoal;
			navigation_bestrating = f;
			navigation_bestgoal = e;
		}
	}
	//dprint("\n");
};

// replaces the goal stack with the path to a given item
void navigation_routetogoal(entity e)
{
	// if already going to this goal, don't stop
	//if (self.goalentity == e)
	//	return;
	// clear the route and add the new one
	navigation_clearroute();
	self.goalentity = e;
	// if there is no goal, just exit
	if (!e)
		return;
	// put the entity on the goal stack as the only item
	navigation_pushroute(e);
	//te_smallflash((e.absmin + e.absmax) * 0.5);
	//bprint("navigation_routetogoal(");
	//bprint(etos(e));
	//bprint(") : ");
	//bprint(etos(e));
	//tracebox(self.origin, '-16 -16 0', '16 16 0', e.origin, TRUE, self);
	//if (trace_fraction == 1)
	if (tracewalk(self, self.origin, PL_MIN, PL_MAX, e.origin, MOVE_NORMAL))
		return;
	// see if there are waypoints describing a path to the item
	e = e.nearestwaypoint;
	while (e != world)
	{
		//bprint(" ");
		//bprint(etos(e));
		//te_smallflash((e.absmin + e.absmax) * 0.5);
		//tracebox(self.origin, '-16 -16 0', '16 16 0', e.origin, TRUE, self);
		//if (trace_fraction == 1)
		//if (tracewalk(self, self.origin, PL_MIN, PL_MAX, e.origin, MOVE_NORMAL))
		//	break;
		// add the spawnfunc_waypoint to the path
		navigation_pushroute(e);
		e = e.enemy;
	}
	//bprint("\n");
};

// removes any currently touching waypoints from the goal stack
// (this is how bots detect if they have reached a goal)
void navigation_poptouchedgoals()
{
	local vector org, m1, m2;
	org = self.origin;// + self.velocity * 0.1;
	m1 = org + self.mins;
	m2 = org + self.maxs;

	// Loose goal touching check for running state
	if(self.aistatus & AI_STATUS_RUNNING)
	if(self.goalcurrent.classname=="waypoint")
	{
		if(vlen(self.origin - self.goalcurrent.origin)<150)
		{
				traceline(self.origin + self.view_ofs , self.goalcurrent.origin, TRUE, world);
				if(trace_fraction==1)
				{
					navigation_poproute();
				}
		}
	}

	while (self.goalcurrent && boxesoverlap(m1, m2, self.goalcurrent.absmin, self.goalcurrent.absmax))
		navigation_poproute();
}

// begin a goal selection session (queries spawnfunc_waypoint network)
void navigation_goalrating_start()
{
	navigation_bestrating = -1;
	navigation_bestgoal = world;
	navigation_markroutes();
};

// ends a goal selection session (updates goal stack to the best goal)
void navigation_goalrating_end()
{
	if (self.havocbot_role == havocbot_role_ctf_offense)
		dprint(navigation_bestgoal.classname, " (with rating ", ftos(navigation_bestrating), ")\n");
	self.alternativegoal = navigation_alternativegoal;
	navigation_routetogoal(navigation_bestgoal);
};





//////////////////////////////////////////////////////////////////////////////
// general bot functions
//////////////////////////////////////////////////////////////////////////////

.float isbot; // true if this client is actually a bot

float skill;
entity bot_list;
.entity nextbot;

float sv_maxspeed;
.float createdtime;

.float bot_preferredcolors;

.float bot_attack;
.float bot_dodge;
.float bot_dodgerating;

//.float bot_painintensity;
.float bot_firetimer;
//.float bot_oldhealth;
.void() bot_ai;

.entity bot_aimtarg;
.float bot_aimlatency;
.vector bot_aimselforigin;
.vector bot_aimselfvelocity;
.vector bot_aimtargorigin;
.vector bot_aimtargvelocity;

.float bot_pickup;
.float(entity player, entity item) bot_pickupevalfunc;
.float bot_pickupbasevalue;
.float bot_canfire;
.float bot_strategytime;

// used for aiming currently
// FIXME: make the weapon code use these and then replace the calculations here with a call to the weapon code
vector shotorg;
vector shotdir;

const float BOTSKINS = 19;
const float BOTNAMES = 32;
string bot_namefornumber(float r)
{
	if (r <  1) return "Thunderstorm";
	if (r <  2) return "Darkness";
	if (r <  3) return "Scorcher";
	if (r <  4) return "Paranoia";
	if (r <  5) return "Eureka";
	if (r <  6) return "Mystery";
	if (r <  7) return "Toxic";
	if (r <  8) return "Dominion";
	if (r <  9) return "Pegasus";
	if (r < 10) return "Sensible";
	if (r < 11) return "Gator";
	if (r < 12) return "Kangaroo";
	if (r < 13) return "Deadline";
	if (r < 14) return "Frosty";
	if (r < 15) return "Roadkill";
	if (r < 16) return "Death";
	if (r < 17) return "Panic";
	if (r < 18) return "Discovery";
	if (r < 19) return "Shadow";
	if (r < 20) return "Acidic";
	if (r < 21) return "Dominator";
	if (r < 22) return "Hellfire";
	if (r < 23) return "Necrotic";
	if (r < 24) return "Newbie";
	if (r < 25) return "Spellbinder";
	if (r < 26) return "Lion";
	if (r < 27) return "Controlled";
	if (r < 28) return "Airhead";
	if (r < 29) return "Delirium";
	if (r < 30) return "Resurrection";
	if (r < 31) return "Danger";
	return "Flatline";
};

string bot_skinfornumber(float r)
{
	     if (r <  1) {self.playermodel = "models/player/carni.zym"          ;self.playerskin = "0";return "Carni"          ;}
	else if (r <  2) {self.playermodel = "models/player/carni.zym"          ;self.playerskin = "1";return "Armored Carni"  ;}
	else if (r <  3) {self.playermodel = "models/player/crash.zym"          ;self.playerskin = "0";return "Quark"          ;}
	else if (r <  4) {self.playermodel = "models/player/grunt.zym"          ;self.playerskin = "0";return "Grunt"          ;}
	else if (r <  5) {self.playermodel = "models/player/headhunter.zym"     ;self.playerskin = "0";return "HeadHunter"     ;}
	else if (r <  6) {self.playermodel = "models/player/insurrectionist.zym";self.playerskin = "0";return "Insurrectionist";}
	else if (r <  7) {self.playermodel = "models/player/lurk.zym"           ;self.playerskin = "0";return "Lurk"           ;}
	else if (r <  8) {self.playermodel = "models/player/lurk.zym"           ;self.playerskin = "1";return "Reptile"        ;}
	else if (r <  9) {self.playermodel = "models/player/lycanthrope.zym"    ;self.playerskin = "0";return "Lycanthrope"    ;}
	else if (r < 10) {self.playermodel = "models/player/marine.zym"         ;self.playerskin = "0";return "Marine"         ;}
	else if (r < 11) {self.playermodel = "models/player/nexus.zym"          ;self.playerskin = "0";return "Nexus"          ;}
	else if (r < 12) {self.playermodel = "models/player/nexus.zym"          ;self.playerskin = "1";return "Mulder"         ;}
	else if (r < 13) {self.playermodel = "models/player/nexus.zym"          ;self.playerskin = "2";return "Xolar"          ;}
	else if (r < 14) {self.playermodel = "models/player/pyria.zym"          ;self.playerskin = "0";return "Pyria"          ;}
	else if (r < 15) {self.playermodel = "models/player/shock.zym"          ;self.playerskin = "0";return "Shock"          ;}
	else if (r < 16) {self.playermodel = "models/player/skadi.zym"          ;self.playerskin = "0";return "Skadi"          ;}
	else if (r < 17) {self.playermodel = "models/player/specop.zym"         ;self.playerskin = "0";return "Specop"         ;}
	else             {self.playermodel = "models/player/visitant.zym"       ;self.playerskin = "0";return "Fricka"         ;}
};

void bot_setnameandstuff()
{
	local string name, prefix, suffix;
	local float r, b, shirt, pants;

	prefix = cvar_string("bot_prefix");
	suffix = cvar_string("bot_suffix");

	// this is really only a default, JoinBestTeam is called later
	pants = floor(random() * 15);
	shirt = floor(random() * 15);
	//shirt = pants;
	setcolor(self, shirt * 16 + pants);
	self.bot_preferredcolors = self.clientcolors;

	// now pick a name...

	if (cvar("bot_usemodelnames"))
	{
		// first see if all skins are taken
		b = 0;
		do
		{
			name = bot_skinfornumber(b);
			b = b + 1;
		}
		while (b < BOTSKINS && find(world, netname, name));

		// randomly pick a skin, if it's taken either repeat until we find one,
		// or give up if we already know all skins are taken
		do
		{
			r = floor(random() * BOTSKINS);
			name = bot_skinfornumber(r);
		}
		while (b < BOTSKINS && find(world, netname, name));
	}
	else
	{
		// first see if all names are taken
		b = 0;
		do
		{
			name = bot_namefornumber(b);
			b = b + 1;
		}
		while (b < BOTNAMES && find(world, netname, name));

		// randomly pick a name, if it's taken either repeat until we find one,
		// or give up if we already know all names are taken
		do
		{
			r = floor(random() * BOTNAMES);
			name = bot_namefornumber(r);
		}
		while (b < BOTNAMES && find(world, netname, name));

		// randomly pick a skin
		bot_skinfornumber(floor(random() * BOTSKINS));
	}
 	if(!cvar("g_campaign"))
 		self.netname = self.netname_freeme = strzone(strcat(prefix, name, suffix));
 	else
 		self.netname = name;
};

float bot_custom_weapon;
float bot_distance_far;
float bot_distance_close;

float bot_weapons_far[WEP_LAST];
float bot_weapons_mid[WEP_LAST];
float bot_weapons_close[WEP_LAST];

void bot_custom_weapon_priority_setup()
{
	local float tokens, i, c, w;

	bot_custom_weapon = FALSE;

	if(	cvar_string("bot_ai_custom_weapon_priority_far") == "" ||
		cvar_string("bot_ai_custom_weapon_priority_mid") == "" ||
		cvar_string("bot_ai_custom_weapon_priority_close") == "" ||
 		cvar_string("bot_ai_custom_weapon_priority_distances") == ""
	)
		return;

	// Parse distances
	tokens = tokenizebyseparator(cvar_string("bot_ai_custom_weapon_priority_distances")," ");

	if (tokens!=2)
		return;

	bot_distance_far = stof(argv(0));
	bot_distance_close = stof(argv(1));

	if(bot_distance_far < bot_distance_close){
		bot_distance_far = stof(argv(1));
		bot_distance_close = stof(argv(0));
	}

	// Initialize list of weapons
	bot_weapons_far[0] = -1;
	bot_weapons_mid[0] = -1;
	bot_weapons_close[0] = -1;

	// Parse far distance weapon priorities
	tokens = tokenizebyseparator(cvar_string("bot_ai_custom_weapon_priority_far")," ");

	c = 0;
	for(i=0; i < tokens && c < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_far[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_far[c] = -1;

	// Parse mid distance weapon priorities
	tokens = tokenizebyseparator(cvar_string("bot_ai_custom_weapon_priority_mid")," ");

	c = 0;
	for(i=0; i < tokens && c < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_mid[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_mid[c] = -1;

	// Parse close distance weapon priorities
	tokens = tokenizebyseparator(cvar_string("bot_ai_custom_weapon_priority_close")," ");

	c = 0;
	for(i=0; i < tokens && i < WEP_COUNT; ++i){
		w = stof(argv(i));
		if ( w >= WEP_FIRST && w <= WEP_LAST) {
			bot_weapons_close[c] = w;
			++c;
		}
	}
	if(c < WEP_COUNT)
		bot_weapons_close[c] = -1;

	bot_custom_weapon = TRUE;
};


void bot_endgame()
{
	local entity e;
	//dprint("bot_endgame\n");
	e = bot_list;
	while (e)
	{
		setcolor(e, e.bot_preferredcolors);
		e = e.nextbot;
	}
	// if dynamic waypoints are ever implemented, save them here
};

float bot_ignore_bots; // let bots not attack other bots (only works in non-teamplay)
float bot_shouldattack(entity e)
{
	if (e.team == self.team)
	{
		if (e == self)
			return FALSE;
		if (teams_matter)
		if (e.team != 0)
			return FALSE;
	}
	if(!teams_matter)
		if(bot_ignore_bots)
			if(clienttype(e) == CLIENTTYPE_BOT)
				return FALSE;
	if (!e.takedamage)
		return FALSE;
	if (e.deadflag)
		return FALSE;
	if (e.BUTTON_CHAT)
		return FALSE;
	if(g_minstagib)
	if(e.items & IT_STRENGTH)
		return FALSE;
	return TRUE;
};

void bot_lagfunc(float t, float f1, float f2, entity e1, vector v1, vector v2, vector v3, vector v4)
{
	if(self.flags & FL_INWATER)
	{
		self.bot_aimtarg = world;
		return;
	}
	self.bot_aimtarg = e1;
	self.bot_aimlatency = self.ping; // FIXME?  Shouldn't this be in the lag item?
	self.bot_aimselforigin = v1;
	self.bot_aimselfvelocity = v2;
	self.bot_aimtargorigin = v3;
	self.bot_aimtargvelocity = v4;
	if(skill <= 0)
		self.bot_canfire = (random() < 0.8);
	else if(skill <= 1)
		self.bot_canfire = (random() < 0.9);
	else if(skill <= 2)
		self.bot_canfire = (random() < 0.95);
	else
		self.bot_canfire = 1;
};

.float bot_nextthink;
.float bot_badaimtime;
.float bot_aimthinktime;
.float bot_prevaimtime;
.vector bot_mouseaim;
.vector bot_badaimoffset;
.vector bot_1st_order_aimfilter;
.vector bot_2nd_order_aimfilter;
.vector bot_3th_order_aimfilter;
.vector bot_4th_order_aimfilter;
.vector bot_5th_order_aimfilter;
.vector bot_olddesiredang;
float bot_aimdir(vector v, float maxfiredeviation)
{
	local float dist, delta_t, blend;
	local vector desiredang, diffang;
	local float delta_t;

	//dprint("aim ", self.netname, ": old:", vtos(self.v_angle));
	// make sure v_angle is sane first
	self.v_angle_y = self.v_angle_y - floor(self.v_angle_y / 360) * 360;
	self.v_angle_z = 0;

	// get the desired angles to aim at
	//dprint(" at:", vtos(v));
	v = normalize(v);
	//te_lightning2(world, self.origin + self.view_ofs, self.origin + self.view_ofs + v * 200);
	if (time >= self.bot_badaimtime)
	{
		self.bot_badaimtime = max(self.bot_badaimtime + 0.3, time);
		self.bot_badaimoffset = randomvec() * bound(0, 5 - 0.5 * (skill+self.bot_offsetskill), 5) * cvar("bot_ai_aimskill_offset");
	}
	desiredang = vectoangles(v) + self.bot_badaimoffset;
	//dprint(" desired:", vtos(desiredang));
	if (desiredang_x >= 180)
		desiredang_x = desiredang_x - 360;
	desiredang_x = bound(-90, 0 - desiredang_x, 90);
	desiredang_z = self.v_angle_z;
	//dprint(" / ", vtos(desiredang));

	//// pain throws off aim
	//if (self.bot_painintensity)
	//{
	//	// shake from pain
	//	desiredang = desiredang + randomvec() * self.bot_painintensity * 0.2;
	//}

	// calculate turn angles
	diffang = (desiredang - self.bot_olddesiredang);
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	self.bot_olddesiredang = desiredang;
	//dprint(" diff:", vtos(diffang));

	delta_t = time-self.bot_prevaimtime;
	self.bot_prevaimtime = time;
	// Here we will try to anticipate the comming aiming direction
	self.bot_1st_order_aimfilter= self.bot_1st_order_aimfilter
		+ (diffang * (1 / delta_t)    - self.bot_1st_order_aimfilter) * bound(0, cvar("bot_ai_aimskill_order_filter_1st"),1);
	self.bot_2nd_order_aimfilter= self.bot_2nd_order_aimfilter
		+ (self.bot_1st_order_aimfilter - self.bot_2nd_order_aimfilter) * bound(0, cvar("bot_ai_aimskill_order_filter_2nd"),1);
	self.bot_3th_order_aimfilter= self.bot_3th_order_aimfilter
		+ (self.bot_2nd_order_aimfilter - self.bot_3th_order_aimfilter) * bound(0, cvar("bot_ai_aimskill_order_filter_3th"),1);
	self.bot_4th_order_aimfilter= self.bot_4th_order_aimfilter
		+ (self.bot_3th_order_aimfilter - self.bot_4th_order_aimfilter) * bound(0, cvar("bot_ai_aimskill_order_filter_4th"),1);
	self.bot_5th_order_aimfilter= self.bot_5th_order_aimfilter
		+ (self.bot_4th_order_aimfilter - self.bot_5th_order_aimfilter) * bound(0, cvar("bot_ai_aimskill_order_filter_5th"),1);

	//blend = (bound(0,skill,10)*0.1)*pow(1-bound(0,skill,10)*0.05,2.5)*5.656854249; //Plot formule before changing !
	blend = bound(0,skill,10)*0.1;
	desiredang = desiredang + blend *
	(
		  self.bot_1st_order_aimfilter * cvar("bot_ai_aimskill_order_mix_1st")
		+ self.bot_2nd_order_aimfilter * cvar("bot_ai_aimskill_order_mix_2nd")
		+ self.bot_3th_order_aimfilter * cvar("bot_ai_aimskill_order_mix_3th")
		+ self.bot_4th_order_aimfilter * cvar("bot_ai_aimskill_order_mix_4th")
		+ self.bot_5th_order_aimfilter * cvar("bot_ai_aimskill_order_mix_5th")
	);

	// calculate turn angles
	diffang = desiredang - self.bot_mouseaim;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	//dprint(" diff:", vtos(diffang));

	if (time >= self.bot_aimthinktime)
	{
		self.bot_aimthinktime = max(self.bot_aimthinktime + 0.5 - 0.05*(skill+self.bot_thinkskill), time);
		self.bot_mouseaim = self.bot_mouseaim + diffang * (1-random()*0.1*bound(1,10-skill,10));
	}

	//self.v_angle = self.v_angle + diffang * bound(0, r * frametime * (skill * 0.5 + 2), 1);

	diffang = self.bot_mouseaim - desiredang;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	desiredang = desiredang + diffang * bound(0,cvar("bot_ai_aimskill_think"),1);

	// calculate turn angles
	diffang = desiredang - self.v_angle;
	// wrap yaw turn
	diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	if (diffang_y >= 180)
		diffang_y = diffang_y - 360;
	//dprint(" diff:", vtos(diffang));

	// jitter tracking
	dist = vlen(diffang);
	//diffang = diffang + randomvec() * (dist * 0.05 * (3.5 - bound(0, skill, 3)));

	// turn
	local float r, fixedrate, blendrate;
	fixedrate = cvar("bot_ai_aimskill_fixedrate") / bound(1,dist,1000);
	blendrate = cvar("bot_ai_aimskill_blendrate");
	r = max(fixedrate, blendrate);
	//self.v_angle = self.v_angle + diffang * bound(frametime, r * frametime * (2+skill*skill*0.05-random()*0.05*(10-skill)), 1);
	self.v_angle = self.v_angle + diffang * bound(delta_t, r * delta_t * (2+pow(skill+self.bot_mouseskill,3)*0.005-random()), 1);
	self.v_angle = self.v_angle * bound(0,cvar("bot_ai_aimskill_mouse"),1) + desiredang * bound(0,(1-cvar("bot_ai_aimskill_mouse")),1);
	//self.v_angle = self.v_angle + diffang * bound(0, r * frametime * (skill * 0.5 + 2), 1);
	//self.v_angle = self.v_angle + diffang * (1/ blendrate);
	self.v_angle_z = 0;
	self.v_angle_y = self.v_angle_y - floor(self.v_angle_y / 360) * 360;
	//dprint(" turn:", vtos(self.v_angle));

	makevectors(self.v_angle);
	shotorg = self.origin + self.view_ofs;
	shotdir = v_forward;

	//dprint(" dir:", vtos(v_forward));
	//te_lightning2(world, shotorg, shotorg + shotdir * 100);

	// calculate turn angles again
	//diffang = desiredang - self.v_angle;
	//diffang_y = diffang_y - floor(diffang_y / 360) * 360;
	//if (diffang_y >= 180)
	//	diffang_y = diffang_y - 360;

	//dprint("e ", vtos(diffang), " < ", ftos(maxfiredeviation), "\n");

	// decide whether to fire this time
	// note the maxfiredeviation is in degrees so this has to convert to radians first
	//if ((normalize(v) * shotdir) >= cos(maxfiredeviation * (3.14159265358979323846 / 180)))
	if ((normalize(v) * shotdir) >= cos(maxfiredeviation * (3.14159265358979323846 / 180)))
	if (vlen(trace_endpos-shotorg) < 500+500*bound(0, skill, 10) || random()*random()>bound(0,skill*0.05,1))
		self.bot_firetimer = time + bound(0.1, 0.5-skill*0.05, 0.5);
	//traceline(shotorg,shotorg+shotdir*1000,FALSE,world);
	//dprint(ftos(maxfiredeviation),"\n");
	//dprint(" diff:", vtos(diffang), "\n");

	return self.bot_canfire && (time < self.bot_firetimer);
};

vector bot_shotlead(vector targorigin, vector targvelocity, float shotspeed, float shotdelay)
{
	// Try to add code here that predicts gravity effect here, no clue HOW to though ... well not yet atleast...
	return targorigin + targvelocity * (shotdelay + vlen(targorigin - shotorg) / shotspeed);
};

float bot_aim(float shotspeed, float shotspeedupward, float maxshottime, float applygravity)
{
	local float f, r;
	local vector v;
	/*
	eprint(self);
	dprint("bot_aim(", ftos(shotspeed));
	dprint(", ", ftos(shotspeedupward));
	dprint(", ", ftos(maxshottime));
	dprint(", ", ftos(applygravity));
	dprint(");\n");
	*/
	if (!shotspeed)
	{
		dprint("bot_aim: WARNING: weapon ", W_Name(self.weapon), " shotspeed is zero!\n");
		shotspeed = 1000000;
	}
	if (!maxshottime)
	{
		dprint("bot_aim: WARNING: weapon ", W_Name(self.weapon), " maxshottime is zero!\n");
		maxshottime = 1;
	}
	makevectors(self.v_angle);
	shotorg = self.origin + self.view_ofs;
	shotdir = v_forward;
	v = bot_shotlead(self.bot_aimtargorigin, self.bot_aimtargvelocity, shotspeed, self.bot_aimlatency);
	local float distanceratio;
	distanceratio =sqrt(bound(0,skill,10000))*0.3*(vlen(v-shotorg)-100)/cvar("bot_ai_aimskill_firetolerance_distdegrees");
	distanceratio = bound(0,distanceratio,1);
	r =  (cvar("bot_ai_aimskill_firetolerance_maxdegrees")-cvar("bot_ai_aimskill_firetolerance_mindegrees"))
		* (1-distanceratio) + cvar("bot_ai_aimskill_firetolerance_mindegrees");
	if (applygravity && self.bot_aimtarg)
	{
		if (!findtrajectorywithleading(shotorg, '0 0 0', '0 0 0', self.bot_aimtarg, shotspeed, shotspeedupward, maxshottime, 0, self))
			return FALSE;
		f = bot_aimdir(findtrajectory_velocity - shotspeedupward * '0 0 1', r);
	}
	else
	{
		f = bot_aimdir(v - shotorg, r);
		//dprint("AIM: ");dprint(vtos(self.bot_aimtargorigin));dprint(" + ");dprint(vtos(self.bot_aimtargvelocity));dprint(" * ");dprint(ftos(self.bot_aimlatency + vlen(self.bot_aimtargorigin - shotorg) / shotspeed));dprint(" = ");dprint(vtos(v));dprint(" : aimdir = ");dprint(vtos(normalize(v - shotorg)));dprint(" : ");dprint(vtos(shotdir));dprint("\n");
		traceline(shotorg, shotorg + shotdir * 10000, FALSE, self);
		if (trace_ent.takedamage)
		if (trace_fraction < 1)
		if (!bot_shouldattack(trace_ent))
			return FALSE;
		traceline(shotorg, self.bot_aimtargorigin, FALSE, self);
		if (trace_fraction < 1)
		if (trace_ent != self.enemy)
		if (!bot_shouldattack(trace_ent))
			return FALSE;
	}
	if (r > maxshottime * shotspeed)
		return FALSE;
	return f;
};

// TODO: move this painintensity code to the player damage code
void bot_think()
{
	if (self.bot_nextthink > time)
		return;
	self.bot_nextthink = self.bot_nextthink + cvar("bot_ai_thinkinterval");
	//if (self.bot_painintensity > 0)
	//	self.bot_painintensity = self.bot_painintensity - (skill + 1) * 40 * frametime;

	//self.bot_painintensity = self.bot_painintensity + self.bot_oldhealth - self.health;
	//self.bot_painintensity = bound(0, self.bot_painintensity, 100);

	if(time < game_starttime || ((cvar("g_campaign") && !campaign_bots_may_start)))
	{
		self.nextthink = time + 0.5;
		return;
	}

	if (self.fixangle)
	{
		self.v_angle = self.angles;
		self.v_angle_z = 0;
		self.fixangle = FALSE;
	}

	self.dmg_take = 0;
	self.dmg_save = 0;
	self.dmg_inflictor = world;

	// calculate an aiming latency based on the skill setting
	// (simulated network latency + naturally delayed reflexes)
	//self.ping = 0.7 - bound(0, 0.05 * skill, 0.5); // moved the reflexes to bot_aimdir (under the name 'think')
	// minimum ping 20+10 random
	self.ping = bound(0,0.07 - bound(0, skill * 0.005,0.05)+random()*0.01,0.65); // Now holds real lag to server, and higer skill players take a less laggy server
	// skill 10 = ping 0.2 (adrenaline)
	// skill 0 = ping 0.7 (slightly drunk)

	// clear buttons
	self.BUTTON_ATCK = 0;
	self.button1 = 0;
	self.BUTTON_JUMP = 0;
	self.BUTTON_ATCK2 = 0;
	self.BUTTON_ZOOM = 0;
	self.BUTTON_CROUCH = 0;
	self.BUTTON_HOOK = 0;
	self.BUTTON_INFO = 0;
	self.button8 = 0;
	self.BUTTON_CHAT = 0;
	self.BUTTON_USE = 0;

	// if dead, just wait until we can respawn
	if (self.deadflag)
	{
		if (self.deadflag == DEAD_DEAD)
		{
			self.BUTTON_JUMP = 1; // press jump to respawn
			self.bot_strategytime = 0;
		}
		return;
	}

	// now call the current bot AI (havocbot for example)
	self.bot_ai();
};

entity bot_strategytoken;
float bot_strategytoken_taken;
entity player_list;
.entity nextplayer;
void bot_relinkplayerlist()
{
	local entity e;
	local entity prevbot;
	player_count = 0;
	currentbots = 0;
	player_list = e = findchainflags(flags, FL_CLIENT);
	bot_list = world;
	prevbot = world;
	while (e)
	{
		player_count = player_count + 1;
		e.nextplayer = e.chain;
		if (clienttype(e) == CLIENTTYPE_BOT)
		{
			if (prevbot)
				prevbot.nextbot = e;
			else
				bot_list = e;
			prevbot = e;
			currentbots = currentbots + 1;
		}
		e = e.chain;
	}
	dprint(strcat("relink: ", ftos(currentbots), " bots seen.\n"));
	bot_strategytoken = bot_list;
	bot_strategytoken_taken = TRUE;
};

void() havocbot_setupbot;
float JoinBestTeam(entity pl, float only_return_best, float forcebestteam);

void bot_clientdisconnect()
{
	if (clienttype(self) != CLIENTTYPE_BOT)
		return;
	if(self.netname_freeme)
		strunzone(self.netname_freeme);
	self.netname_freeme = string_null;
}

void bot_clientconnect()
{
	if (clienttype(self) != CLIENTTYPE_BOT)
		return;
	self.bot_preferredcolors = self.clientcolors;
	self.bot_nextthink = time - random();
	self.lag_func = bot_lagfunc;
	self.isbot = TRUE;
	self.createdtime = self.nextthink;
	JoinBestTeam(self, FALSE, TRUE);
	havocbot_setupbot();
	self.bot_mouseskill=random()-0.5;
	self.bot_thinkskill=random()-0.5;
	self.bot_predictionskill=random()-0.5;
	self.bot_offsetskill=random()-0.5;
};

entity bot_spawn()
{
	local entity oldself, bot;
	bot = spawnclient();
	if (bot)
	{
		currentbots = currentbots + 1;
		oldself = self;
		self = bot;
		bot_setnameandstuff();
		ClientConnect();
		PutClientInServer();
		self = oldself;
	}
	return bot;
};

void CheckAllowedTeams(entity for_whom); void GetTeamCounts(entity other); float c1, c2, c3, c4;
void bot_removefromlargestteam()
{
	local float besttime, bestcount, thiscount;
	local entity best, head;
	CheckAllowedTeams(world);
	GetTeamCounts(world);
	head = findchainfloat(isbot, TRUE);
	if (!head)
		return;
	best = head;
	besttime = head.createdtime;
	bestcount = 0;
	while (head)
	{
		if(head.team == COLOR_TEAM1)
			thiscount = c1;
		else if(head.team == COLOR_TEAM2)
			thiscount = c2;
		else if(head.team == COLOR_TEAM3)
			thiscount = c3;
		else if(head.team == COLOR_TEAM4)
			thiscount = c4;
		else
			thiscount = 0;
		if (thiscount > bestcount)
		{
			bestcount = thiscount;
			besttime = head.createdtime;
			best = head;
		}
		else if (thiscount == bestcount && besttime < head.createdtime)
		{
			besttime = head.createdtime;
			best = head;
		}
		head = head.chain;
	}
	currentbots = currentbots - 1;
	dropclient(best);
};

void bot_removenewest()
{
	local float besttime;
	local entity best, head;

	if(teams_matter)
	{
		bot_removefromlargestteam();
		return;
	}

	head = findchainfloat(isbot, TRUE);
	if (!head)
		return;
	best = head;
	besttime = head.createdtime;
	while (head)
	{
		if (besttime < head.createdtime)
		{
			besttime = head.createdtime;
			best = head;
		}
		head = head.chain;
	}
	currentbots = currentbots - 1;
	dropclient(best);
};

float botframe_waypointeditorlightningtime;
void botframe_showwaypointlinks()
{
	local entity player, head, w;
	if (time < botframe_waypointeditorlightningtime)
		return;
	botframe_waypointeditorlightningtime = time + 0.5;
	player = find(world, classname, "player");
	while (player)
	{
		if (!player.isbot)
		if (player.flags & FL_ONGROUND)
		{
			//navigation_testtracewalk = TRUE;
			head = navigation_findnearestwaypoint(player, FALSE);
			//navigation_testtracewalk = FALSE;
			if (head)
			{
				w = head     ;if (w) te_lightning2(world, w.origin, player.origin);
				w = head.wp00;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp01;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp02;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp03;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp04;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp05;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp06;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp07;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp08;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp09;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp10;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp11;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp12;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp13;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp14;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp15;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp16;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp17;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp18;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp19;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp20;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp21;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp22;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp23;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp24;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp25;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp26;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp27;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp28;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp29;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp30;if (w) te_lightning2(world, w.origin, head.origin);
				w = head.wp31;if (w) te_lightning2(world, w.origin, head.origin);
			}
		}
		player = find(player, classname, "player");
	}
};

entity botframe_dangerwaypoint;
void botframe_updatedangerousobjects(float maxupdate)
{
	local entity head, bot_dodgelist;
	local vector m1, m2, v;
	local float c, d, danger;
	c = 0;
	bot_dodgelist = findchainfloat(bot_dodge, TRUE);
	botframe_dangerwaypoint = find(botframe_dangerwaypoint, classname, "waypoint");
	while (botframe_dangerwaypoint != world)
	{
		danger = 0;
		m1 = botframe_dangerwaypoint.mins;
		m2 = botframe_dangerwaypoint.maxs;
		head = bot_dodgelist;
		while (head)
		{
			v = head.origin;
			v_x = bound(m1_x, v_x, m2_x);
			v_y = bound(m1_y, v_y, m2_y);
			v_z = bound(m1_z, v_z, m2_z);
			d = head.bot_dodgerating - vlen(head.origin - v);
			if (d > 0)
			{
				traceline(head.origin, v, TRUE, world);
				if (trace_fraction == 1)
					danger = danger + d;
			}
			head = head.chain;
		}
		botframe_dangerwaypoint.dmg = danger;
		c = c + 1;
		if (c >= maxupdate)
			break;
		botframe_dangerwaypoint = find(botframe_dangerwaypoint, classname, "waypoint");
	}
};


float botframe_spawnedwaypoints;
float botframe_nextthink;
float botframe_nextdangertime;

float autoskill_nextthink;
.float totalfrags_lastcheck;
void autoskill(float factor)
{
	float bestbot;
	float bestplayer;
	entity head;

	bestbot = -1;
	bestplayer = -1;
	FOR_EACH_PLAYER(head)
	{
		if(clienttype(head) == CLIENTTYPE_REAL)
			bestplayer = max(bestplayer, head.totalfrags - head.totalfrags_lastcheck);
		else
			bestbot = max(bestbot, head.totalfrags - head.totalfrags_lastcheck);
	}

	dprint("autoskill: best player got ", ftos(bestplayer), ", ");
	dprint("best bot got ", ftos(bestbot), "; ");
	if(bestbot < 0 || bestplayer < 0)
	{
		dprint("not doing anything\n");
		// don't return, let it reset all counters below
	}
	else if(bestbot <= bestplayer * factor - 2)
	{
		if(cvar("skill") < 17)
		{
			dprint("2 frags difference, increasing skill\n");
			cvar_set("skill", ftos(cvar("skill") + 1));
			bprint("^2SKILL UP!^7 Now at level ", ftos(cvar("skill")), "\n");
		}
	}
	else if(bestbot >= bestplayer * factor + 2)
	{
		if(cvar("skill") > 0)
		{
			dprint("2 frags difference, decreasing skill\n");
			cvar_set("skill", ftos(cvar("skill") - 1));
			bprint("^1SKILL DOWN!^7 Now at level ", ftos(cvar("skill")), "\n");
		}
	}
	else
	{
		dprint("not doing anything\n");
		return;
		// don't reset counters, wait for them to accumulate
	}

	FOR_EACH_PLAYER(head)
		head.totalfrags_lastcheck = head.totalfrags;
}

float bot_cvar_nextthink;
void bot_serverframe()
{
	float realplayers, bots, activerealplayers;
	entity head;

	if (intermission_running)
		return;

	if (time < 2)
		return;

	if(time > autoskill_nextthink)
	{
		float a;
		a = cvar("skill_auto");
		if(!cvar("g_campaign"))
			if(a)
				autoskill(a);
		autoskill_nextthink = time + 5;
	}

	activerealplayers = 0;
	realplayers = 0;

	FOR_EACH_REALCLIENT(head)
	{
		if(head.classname == "player" || g_lms || g_arena)
			++activerealplayers;
		++realplayers;
	}

	// add/remove bots if needed to make sure there are at least
	// minplayers+bot_number, or remove all bots if no one is playing
	// But don't remove bots immediately on level change, as the real players
	// usually haven't rejoined yet
	bots_would_leave = FALSE;
	if (realplayers || cvar("bot_join_empty") || (currentbots > 0 && time < 5))
	{
		float realminplayers, minplayers;
		realminplayers = cvar("minplayers");
		minplayers = max(0, floor(realminplayers));

		float realminbots, minbots;
		if(cvar("bot_vs_human"))
			realminbots = ceil(fabs(cvar("bot_vs_human")) * activerealplayers);
		else
			realminbots = cvar("bot_number");
		minbots = max(0, floor(realminbots));

		bots = min(max(minbots, minplayers - activerealplayers), maxclients - realplayers);
		if(bots > minbots)
			bots_would_leave = TRUE;
	}
	else
	{
		// if there are no players, remove bots
		bots = 0;
	}

	bot_ignore_bots = cvar("bot_ignore_bots");

	// only add one bot per frame to avoid utter chaos
	if(time > botframe_nextthink)
	{
		//dprint(ftos(bots), " ? ", ftos(currentbots), "\n");
		while (currentbots < bots)
		{
			if (bot_spawn() == world)
			{
				bprint("Can not add bot, server full.\n");
				botframe_nextthink = time + 10;
				break;
			}
		}
		while (currentbots > bots)
			bot_removenewest();
	}

	if(botframe_spawnedwaypoints)
	{
		if(cvar("waypoint_benchmark"))
			localcmd("quit\n");
	}

	if (currentbots > 0 || cvar("g_waypointeditor"))
	if (!botframe_spawnedwaypoints)
	{
		botframe_spawnedwaypoints = TRUE;
		waypoint_loadall();
		waypoint_schedulerelinkall();
	}

	if (bot_list)
	{
		// cycle the goal token from one bot to the next each frame
		// (this prevents them from all doing spawnfunc_waypoint searches on the same
		//  frame, which causes choppy framerates)
		if (bot_strategytoken_taken)
		{
			bot_strategytoken_taken = FALSE;
			if (bot_strategytoken)
				bot_strategytoken = bot_strategytoken.nextbot;
			if (!bot_strategytoken)
				bot_strategytoken = bot_list;
		}

		if (botframe_nextdangertime < time)
		{
			local float interval;
			interval = cvar("bot_ai_dangerdetectioninterval");
			if (botframe_nextdangertime < time - interval * 1.5)
				botframe_nextdangertime = time;
			botframe_nextdangertime = botframe_nextdangertime + interval;
			botframe_updatedangerousobjects(cvar("bot_ai_dangerdetectionupdates"));
		}
	}

	if (cvar("g_waypointeditor"))
		botframe_showwaypointlinks();

	if(time > bot_cvar_nextthink)
	{
		if(currentbots>1)
			bot_custom_weapon_priority_setup();
		bot_cvar_nextthink = time + 5;
	}
};
