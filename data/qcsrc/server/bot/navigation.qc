
// rough simulation of walking from one point to another to test if a path
// can be traveled, used for waypoint linking and havocbot

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
	local float swimming;

	#ifdef DEBUG_TRACEWALK
		debugresetnodes();
		debugnode(start);
	#endif

	move = end - start;
	move_z = 0;
	org = start;
	dist = totaldist = vlen(move);
	dir = normalize(move);
	stepdist = 32;
	ignorehazards = FALSE;

	// Analyze starting point
	traceline(start, start, MOVE_NORMAL, e);
	if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
		ignorehazards = TRUE;
	else
	{
		traceline( start, start + '0 0 -65536', MOVE_NORMAL, e);
		if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
		{
			ignorehazards = TRUE;
			swimming = TRUE;
		}
	}
	tracebox(start, m1, m2, start, MOVE_NOMONSTERS, e);
	if (trace_startsolid)
	{
		// Bad start
		#ifdef DEBUG_TRACEWALK
			debugnodestatus(start, DEBUG_NODE_FAIL);
		#endif
		//print("tracewalk: ", vtos(start), " is a bad start\n");
		return FALSE;
	}

	// Movement loop
	yaw = vectoyaw(move);
	move = end - org;
	for (;;)
	{
		if (boxesoverlap(end, end, org + m1 + '-1 -1 -1', org + m2 + '1 1 1'))
		{
			// Succeeded
			#ifdef DEBUG_TRACEWALK
				debugnodestatus(org, DEBUG_NODE_SUCCESS);
			#endif
			//print("tracewalk: ", vtos(start), " can reach ", vtos(end), "\n");
			return TRUE;
		}
		#ifdef DEBUG_TRACEWALK
			debugnode(org);
		#endif

		if (dist <= 0)
			break;
		if (stepdist > dist)
			stepdist = dist;
		dist = dist - stepdist;
		traceline(org, org, MOVE_NORMAL, e);
		if (!ignorehazards)
		{
			if (trace_dpstartcontents & (DPCONTENTS_SLIME | DPCONTENTS_LAVA))
			{
				// hazards blocking path
				#ifdef DEBUG_TRACEWALK
					debugnodestatus(org, DEBUG_NODE_FAIL);
				#endif
				//print("tracewalk: ", vtos(start), " hits a hazard when trying to reach ", vtos(end), "\n");
				return FALSE;
			}
		}
		if (trace_dpstartcontents & DPCONTENTS_LIQUIDSMASK)
		{
			move = normalize(end - org);
			tracebox(org, m1, m2, org + move * stepdist, movemode, e);

			#ifdef DEBUG_TRACEWALK
				debugnode(trace_endpos);
			#endif

			if (trace_fraction < 1)
			{
				swimming = TRUE;
				org = trace_endpos - normalize(org - trace_endpos) * stepdist;
				for(; org_z < end_z + self.maxs_z; org_z += stepdist)
				{
						#ifdef DEBUG_TRACEWALK
							debugnode(org);
						#endif
				        if(pointcontents(org) == CONTENT_EMPTY)
							break;
				}

				if not (pointcontents(org + '0 0 1') == CONTENT_EMPTY)
				{
					#ifdef DEBUG_TRACEWALK
						debugnodestatus(org, DEBUG_NODE_FAIL);
					#endif
					return FALSE;
					//print("tracewalk: ", vtos(start), " failed under water\n");
				}
				continue;

			}
			else
				org = trace_endpos;
		}
		else
		{
			move = dir * stepdist + org;
			tracebox(org, m1, m2, move, movemode, e);

			#ifdef DEBUG_TRACEWALK
				debugnode(trace_endpos);
			#endif

			// hit something
			if (trace_fraction < 1)
			{
				// check if we can walk over this obstacle
				tracebox(org + stepheightvec, m1, m2, move + stepheightvec, movemode, e);
				if (trace_fraction < 1 || trace_startsolid)
				{
					#ifdef DEBUG_TRACEWALK
						debugnodestatus(trace_endpos, DEBUG_NODE_WARNING);
					#endif

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
					{
						#ifdef DEBUG_TRACEWALK
							debugnodestatus(trace_endpos, DEBUG_NODE_FAIL);
						#endif
						//print("tracewalk: ", vtos(start), " hit something when trying to reach ", vtos(end), "\n");
						//te_explosion(trace_endpos);
						//print(ftos(e.dphitcontentsmask), "\n");
						return FALSE; // failed
					}
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

			// moved successfully
			if(swimming)
			{
				local float c;
				c = pointcontents(org + '0 0 1');
				if not(c == CONTENT_WATER || c == CONTENT_LAVA || c == CONTENT_SLIME)
					swimming = FALSE;
				else
					continue;
			}

			org = trace_endpos;
		}
	}

	//print("tracewalk: ", vtos(start), " did not arrive at ", vtos(end), " but at ", vtos(org), "\n");

	// moved but didn't arrive at the intended destination
	#ifdef DEBUG_TRACEWALK
		debugnodestatus(org, DEBUG_NODE_FAIL);
	#endif

	return FALSE;
};

/////////////////////////////////////////////////////////////////////////////
// goal stack
/////////////////////////////////////////////////////////////////////////////

// completely empty the goal stack, used when deciding where to go
void navigation_clearroute()
{
	//print("bot ", etos(self), " clear\n");
	self.navigation_hasgoals = FALSE;
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
// NOTE: when a waypoint is added, the WP gets pushed first, then the
// next-closest WP on the shortest path to the WP
// That means, if the stack overflows, the bot will know how to do the FIRST 32
// steps to the goal, and then recalculate the path.
void navigation_pushroute(entity e)
{
	//print("bot ", etos(self), " push ", etos(e), "\n");
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
	//print("bot ", etos(self), " pop\n");
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
entity navigation_findnearestwaypoint(entity ent, float walkfromwp)
{
	local entity waylist, w, best;
	local float dist, bestdist;
	local vector v, org, pm1, pm2;
	pm1 = ent.origin + ent.mins;
	pm2 = ent.origin + ent.maxs;
	waylist = findchain(classname, "waypoint");

	// do two scans, because box test is cheaper
	w = waylist;
	while (w)
	{
		// if object is touching spawnfunc_waypoint
		if(w != ent)
			if (boxesoverlap(pm1, pm2, w.absmin, w.absmax))
				return w;
		w = w.chain;
	}

	org = ent.origin + 0.5 * (ent.mins + ent.maxs);
	org_z = ent.origin_z + ent.mins_z - PL_MIN_z; // player height
	// TODO possibly make other code have the same support for bboxes
	if(ent.tag_entity)
		org = org + ent.tag_entity.origin;
	if (navigation_testtracewalk)
		te_plasmaburn(org);

	best = world;
	bestdist = 1050;

	// box check failed, try walk
	w = waylist;
	while (w)
	{
		// if object can walk from spawnfunc_waypoint
		if(w != ent)
		{
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
				traceline(v, org, TRUE, ent);
				if (trace_fraction == 1)
				{
					if (walkfromwp)
					{
						//print("^1can I reach ", vtos(org), " from ", vtos(v), "?\n");
						if (tracewalk(ent, v, PL_MIN, PL_MAX, org, bot_navigation_movemode))
						{
							bestdist = dist;
							best = w;
						}
					}
					else
					{
						if (tracewalk(ent, org, PL_MIN, PL_MAX, v, bot_navigation_movemode))
						{
							bestdist = dist;
							best = w;
						}
					}
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
				if (tracewalk(self, self.origin, self.mins, self.maxs, v, bot_navigation_movemode))
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
	cost2 = cost2 + vlen(v - p);
	if (wp.wpcost > cost2)
	{
		wp.wpcost = cost2;
		wp.enemy = w;
		wp.wpfire = 1;
		wp.wpnearestpoint = v;
	}
};

// queries the entire spawnfunc_waypoint network for pathes leading away from the bot
void navigation_markroutes(entity fixed_source_waypoint)
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

	if(fixed_source_waypoint)
	{
		fixed_source_waypoint.wpconsidered = TRUE;
		fixed_source_waypoint.wpnearestpoint = fixed_source_waypoint.origin + 0.5 * (fixed_source_waypoint.mins + fixed_source_waypoint.maxs);
		fixed_source_waypoint.wpcost = fixed_source_waypoint.dmg;
		fixed_source_waypoint.wpfire = 1;
		fixed_source_waypoint.enemy = world;
	}
	else
	{
		// try a short range search for the nearest waypoints, and expand the search repeatedly if none are found
		// as this search is expensive we will use lower values if the bot is on the air
		local float i, increment, maxdistance;
		if(self.flags & FL_ONGROUND)
		{
			increment = 750;
			maxdistance = 50000;
		}
		else
		{
			increment = 500;
			maxdistance = 1500;
		}

		for(i=increment;!navigation_markroutes_nearestwaypoints(waylist, i)&&i<maxdistance;i+=increment);
	}

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
				wp = w.wp00;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp00mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp01;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp01mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp02;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp02mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp03;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp03mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp04;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp04mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp05;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp05mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp06;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp06mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp07;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp07mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp08;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp08mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp09;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp09mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp10;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp10mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp11;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp11mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp12;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp12mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp13;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp13mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp14;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp14mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp15;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp15mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp16;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp16mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp17;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp17mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp18;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp18mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp19;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp19mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp20;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp20mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp21;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp21mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp22;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp22mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp23;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp23mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp24;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp24mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp25;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp25mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp26;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp26mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp27;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp27mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp28;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp28mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp29;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp29mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp30;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp30mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				wp = w.wp31;if (wp){cost2 = cost + wp.dmg;if (wp.wpcost > cost2 + w.wp31mincost) navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
			}
			w = w.chain;
		}
	}
};

// queries the entire spawnfunc_waypoint network for pathes leading to the bot
void navigation_markroutes_inverted(entity fixed_source_waypoint)
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

	if(fixed_source_waypoint)
	{
		fixed_source_waypoint.wpconsidered = TRUE;
		fixed_source_waypoint.wpnearestpoint = fixed_source_waypoint.origin + 0.5 * (fixed_source_waypoint.mins + fixed_source_waypoint.maxs);
		fixed_source_waypoint.wpcost = fixed_source_waypoint.dmg; // the cost to get from X to fixed_source_waypoint
		fixed_source_waypoint.wpfire = 1;
		fixed_source_waypoint.enemy = world;
	}
	else
	{
		error("need to start with a waypoint\n");
	}

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
				cost = w.wpcost; // cost to walk from w to home
				p = w.wpnearestpoint;
				for(wp = waylist; wp; wp = wp.chain)
				{
					if(w != wp.wp00) if(w != wp.wp01) if(w != wp.wp02) if(w != wp.wp03)
					if(w != wp.wp04) if(w != wp.wp05) if(w != wp.wp06) if(w != wp.wp07)
					if(w != wp.wp08) if(w != wp.wp09) if(w != wp.wp10) if(w != wp.wp11)
					if(w != wp.wp12) if(w != wp.wp13) if(w != wp.wp14) if(w != wp.wp15)
					if(w != wp.wp16) if(w != wp.wp17) if(w != wp.wp18) if(w != wp.wp19)
					if(w != wp.wp20) if(w != wp.wp21) if(w != wp.wp22) if(w != wp.wp23)
					if(w != wp.wp24) if(w != wp.wp25) if(w != wp.wp26) if(w != wp.wp27)
					if(w != wp.wp28) if(w != wp.wp29) if(w != wp.wp30) if(w != wp.wp31)
						continue;
					cost2 = cost + wp.dmg;
					navigation_markroutes_checkwaypoint(w, wp, cost2, p);
				}
			}
			w = w.chain;
		}
	}
};

// updates the best goal according to a weighted calculation of travel cost and item value of a new proposed item
void navigation_routerating(entity e, float f, float rangebias)
{
	entity nwp;
	if (!e)
		return;

	//print("routerating ", etos(e), " = ", ftos(f), " - ", ftos(rangebias), "\n");

	// Evaluate path using jetpack
	if(g_jetpack)
	if(self.items & IT_JETPACK)
	if(cvar("bot_ai_navigation_jetpack"))
	if(vlen(self.origin - e.origin) > cvar("bot_ai_navigation_jetpack_mindistance"))
	{
		vector pointa, pointb;

	//	dprint("jetpack ai: evaluating path for ", e.classname,"\n");

		// Point A
		traceline(self.origin, self.origin + '0 0 65535', MOVE_NORMAL, self);
		pointa = trace_endpos - '0 0 1';

		// Point B
		traceline(e.origin, e.origin + '0 0 65535', MOVE_NORMAL, e);
		pointb = trace_endpos - '0 0 1';

		// Can I see these two points from the sky?
		traceline(pointa, pointb, MOVE_NORMAL, self);

		if(trace_fraction==1)
		{
		//	dprint("jetpack ai: can bridge these two points\n");

			// Lower the altitude of these points as much as possible
			local float zdistance, xydistance, cost, t, fuel;
			local vector down, npa, npb;

			down = '0 0 -1' * (PL_MAX_z - PL_MIN_z) * 10;

			do{
				npa = pointa + down;
				npb = pointb + down;

				if(npa_z<=self.absmax_z)
					break;

				if(npb_z<=e.absmax_z)
					break;

				traceline(npa, npb, MOVE_NORMAL, self);
				if(trace_fraction==1)
				{
					pointa = npa;
					pointb = npb;
				}
			}
			while(trace_fraction == 1);


			// Rough estimation of fuel consumption
			// (ignores acceleration and current xyz velocity)
			xydistance = vlen(pointa - pointb);
			zdistance = fabs(pointa_z - self.origin_z);

			t = zdistance / cvar("g_jetpack_maxspeed_up");
			t += xydistance / cvar("g_jetpack_maxspeed_side");
			fuel = t * cvar("g_jetpack_fuel") * 0.8;

		//	dprint("jetpack ai: required fuel ", ftos(fuel), " self.ammo_fuel ", ftos(self.ammo_fuel),"\n");

			// enough fuel ?
			if(self.ammo_fuel>fuel)
			{
				// Estimate cost
				// (as onground costs calculation is mostly based on distances, here we do the same establishing some relationship
				//  - between air and ground speeds)

				cost = xydistance / (cvar("g_jetpack_maxspeed_side")/cvar("sv_maxspeed"));
				cost += zdistance / (cvar("g_jetpack_maxspeed_up")/cvar("sv_maxspeed"));
				cost *= 1.5;

				// Compare against other goals
				f = f * rangebias / (rangebias + cost);

				if (navigation_bestrating < f)
				{
			//		dprint("jetpack path: added goal", e.classname, " (with rating ", ftos(f), ")\n");
					navigation_bestrating = f;
					navigation_bestgoal = e;
					self.navigation_jetpack_goal = e;
					self.navigation_jetpack_point = pointb;
				}
				return;
			}
		}
	}

	//te_wizspike(e.origin);
	//bprint(etos(e));
	//bprint("\n");
	// update the cached spawnfunc_waypoint link on a dynamic item entity
	if(e.classname == "waypoint" && !(e.wpflags & WAYPOINTFLAG_PERSONAL))
	{
		nwp = e;
	}
	else
	{
		if (time > e.nearestwaypointtimeout)
		{
			nwp = navigation_findnearestwaypoint(e, TRUE);
			if(nwp)
				e.nearestwaypoint = nwp;
			else
				dprint("FAILED to find a nearest waypoint to '", e.classname, "' #", etos(e), "\n");

			// TODO: Cleaner solution, probably handling this timeout from ctf.qc
			if(e.classname=="item_flag_team")
				e.nearestwaypointtimeout = time + 2;
			else
				e.nearestwaypointtimeout = time + random() * 3 + 5;
		}
		nwp = e.nearestwaypoint;
	}

	//dprint("-- checking ", e.classname, " (with cost ", ftos(nwp.wpcost), ")\n");
	if (nwp)
	if (nwp.wpcost < 10000000)
	{
		//te_wizspike(nwp.wpnearestpoint);
	//	dprint(e.classname, " ", ftos(f), "/(1+", ftos((nwp.wpcost + vlen(e.origin - nwp.wpnearestpoint))), "/", ftos(rangebias), ") = ");
		f = f * rangebias / (rangebias + (nwp.wpcost + vlen(e.origin - nwp.wpnearestpoint)));
		//dprint("considering ", e.classname, " (with rating ", ftos(f), ")\n");
		//dprint(ftos(f));
		if (navigation_bestrating < f)
		{
		//	dprint("ground path: added goal ", e.classname, " (with rating ", ftos(f), ")\n");
			navigation_bestrating = f;
			navigation_bestgoal = e;
		}
	}
	//dprint("\n");
};

// adds an item to the the goal stack with the path to a given item
float navigation_routetogoal(entity e, vector startposition)
{
	self.goalentity = e;

	// if there is no goal, just exit
	if (!e)
		return FALSE;

	self.navigation_hasgoals = TRUE;

	// put the entity on the goal stack
	//print("routetogoal ", etos(e), "\n");
	navigation_pushroute(e);

	if(g_jetpack)
	if(e==self.navigation_jetpack_goal)
		return TRUE;

	// if it can reach the goal there is nothing more to do
	if (tracewalk(self, startposition, PL_MIN, PL_MAX, e.origin, bot_navigation_movemode))
		return TRUE;

	// see if there are waypoints describing a path to the item
	if(e.classname != "waypoint" || (e.wpflags & WAYPOINTFLAG_PERSONAL))
		e = e.nearestwaypoint;
	else
		e = e.enemy; // we already have added it, so...

	if(e == world)
		return FALSE;

	for (;;)
	{
		// add the spawnfunc_waypoint to the path
		navigation_pushroute(e);
		e = e.enemy;

		if(e==world)
			break;
	}

	return FALSE;
};

// removes any currently touching waypoints from the goal stack
// (this is how bots detect if they reached a goal)
void navigation_poptouchedgoals()
{
	local vector org, m1, m2;
	org = self.origin;
	m1 = org + self.mins;
	m2 = org + self.maxs;

	if(self.goalcurrent.wpflags & WAYPOINTFLAG_TELEPORT)
	{
		if(self.lastteleporttime>0)
		if(time-self.lastteleporttime<(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL)?2:0.15)
		{
			if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
			if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
			{
				self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
				self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
			}
			navigation_poproute();
			return;
		}
	}

	// Loose goal touching check when running
	if(self.aistatus & AI_STATUS_RUNNING)
	if(self.goalcurrent.classname=="waypoint")
	{
		if(vlen(self.origin - self.goalcurrent.origin)<150)
		{
			traceline(self.origin + self.view_ofs , self.goalcurrent.origin, TRUE, world);
			if(trace_fraction==1)
			{
				// Detect personal waypoints
				if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
				if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
				{
					self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
					self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
				}

				navigation_poproute();
			}
		}
	}

	while (self.goalcurrent && boxesoverlap(m1, m2, self.goalcurrent.absmin, self.goalcurrent.absmax))
	{
		// Detect personal waypoints
		if(self.aistatus & AI_STATUS_WAYPOINT_PERSONAL_GOING)
		if(self.goalcurrent.wpflags & WAYPOINTFLAG_PERSONAL && self.goalcurrent.owner==self)
		{
			self.aistatus &~= AI_STATUS_WAYPOINT_PERSONAL_GOING;
			self.aistatus |= AI_STATUS_WAYPOINT_PERSONAL_REACHED;
		}

		navigation_poproute();
	}
}

// begin a goal selection session (queries spawnfunc_waypoint network)
void navigation_goalrating_start()
{
	self.navigation_jetpack_goal = world;
	navigation_bestrating = -1;
	self.navigation_hasgoals = FALSE;
	navigation_bestgoal = world;
	navigation_markroutes(world);
};

// ends a goal selection session (updates goal stack to the best goal)
void navigation_goalrating_end()
{
	navigation_routetogoal(navigation_bestgoal, self.origin);
//	dprint("best goal ", self.goalcurrent.classname , "\n");

	// Hack: if it can't walk to any goal just move blindly to the first visible waypoint
	if not (self.navigation_hasgoals)
	{
		dprint(self.netname, " can't walk to any goal, going to a near waypoint\n");

		entity head;

		RandomSelection_Init();
		head = findradius(self.origin,1000);
		while(head)
		{
			if(head.classname=="waypoint")
			if(!(head.wpflags & WAYPOINTFLAG_GENERATED))
			if(vlen(self.origin-head.origin)>100)
			if(checkpvs(self.view_ofs,head))
				RandomSelection_Add(head, 0, string_null, 1 + (vlen(self.origin-head.origin)<500), 0);
			head = head.chain;
		}
		if(RandomSelection_chosen_ent)
			navigation_routetogoal(RandomSelection_chosen_ent, self.origin);

		self.navigation_hasgoals = FALSE; // Reset this value
	}
};

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

#ifdef DEBUG_TRACEWALK

void debugresetnodes()
{
	debuglastnode = '0 0 0';
}

void debugnode(vector node)
{
	if not(self.classname=="player")
		return;

	if(debuglastnode=='0 0 0')
	{
		debuglastnode = node;
		return;
	}

	te_lightning2(world, node, debuglastnode);
	debuglastnode = node;
}

void debugnodestatus(vector position, float status)
{
	vector color;

	switch (status)
	{
		case DEBUG_NODE_SUCCESS:
			color = '0 15 0';
			break;
		case DEBUG_NODE_WARNING:
			color = '15 15 0';
			break;
		case DEBUG_NODE_FAIL:
			color = '15 0 0';
			break;
		default:
			color = '15 15 15';
	}

	te_customflash(position, 40,  2, color);
}

#endif

#ifdef DEBUG_BOT_GOALSTACK

.float goalcounter;
.vector lastposition;

// Debug the goal stack visually
void debuggoalstack()
{
	local entity target;
	local vector org;

	if(self.goalcounter==0)target=self.goalcurrent;
	else if(self.goalcounter==1)target=self.goalstack01;
	else if(self.goalcounter==2)target=self.goalstack02;
	else if(self.goalcounter==3)target=self.goalstack03;
	else if(self.goalcounter==4)target=self.goalstack04;
	else if(self.goalcounter==5)target=self.goalstack05;
	else if(self.goalcounter==6)target=self.goalstack06;
	else if(self.goalcounter==7)target=self.goalstack07;
	else if(self.goalcounter==8)target=self.goalstack08;
	else if(self.goalcounter==9)target=self.goalstack09;
	else if(self.goalcounter==10)target=self.goalstack10;
	else if(self.goalcounter==11)target=self.goalstack11;
	else if(self.goalcounter==12)target=self.goalstack12;
	else if(self.goalcounter==13)target=self.goalstack13;
	else if(self.goalcounter==14)target=self.goalstack14;
	else if(self.goalcounter==15)target=self.goalstack15;
	else if(self.goalcounter==16)target=self.goalstack16;
	else if(self.goalcounter==17)target=self.goalstack17;
	else if(self.goalcounter==18)target=self.goalstack18;
	else if(self.goalcounter==19)target=self.goalstack19;
	else if(self.goalcounter==20)target=self.goalstack20;
	else if(self.goalcounter==21)target=self.goalstack21;
	else if(self.goalcounter==22)target=self.goalstack22;
	else if(self.goalcounter==23)target=self.goalstack23;
	else if(self.goalcounter==24)target=self.goalstack24;
	else if(self.goalcounter==25)target=self.goalstack25;
	else if(self.goalcounter==26)target=self.goalstack26;
	else if(self.goalcounter==27)target=self.goalstack27;
	else if(self.goalcounter==28)target=self.goalstack28;
	else if(self.goalcounter==29)target=self.goalstack29;
	else if(self.goalcounter==30)target=self.goalstack30;
	else if(self.goalcounter==31)target=self.goalstack31;

	if(target==world)
	{
		self.goalcounter = 0;
		self.lastposition='0 0 0';
		return;
	}

	if(self.lastposition=='0 0 0')
		org = self.origin;
	else
		org = self.lastposition;


	te_lightning2(world, org, target.origin);
	self.lastposition = target.origin;

	self.goalcounter++;
}

#endif
