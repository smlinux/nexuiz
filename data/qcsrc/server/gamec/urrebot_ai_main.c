/* --- UrreBotInfront ---
I could've used id's infront, but as it wasn't in LordHavoc's multiplayer
only mod, I had to add a new one, named something else to not mess with people's
possible/eventual plugin-attempts*/

float(entity targ) UrreBotInfront =
{
	local float dot;
	local vector vec;

	makevectors (self.angles);
	vec = normalize (targ.origin - self.origin);
	dot = vec * v_forward;

	if (dot > 0.3)
		return TRUE;
	return FALSE;
};

/* --- UrreBotEvalTargets ---
Enemies are found and lost using this function
If the bot can't see his enemy for 3 seconds, it is dropped*/

void() UrreBotEvalTargets =
{
	local float old, new;
	local vector v1, v2;
	local entity e;

	v1 = self.origin + self.view_ofs;

	/*
	if (self.enemy)
	{
		if (self.enemy.health >= 1 && !self.enemy.deadflag)
		{
			if (self.evaltime <= time)
			{
				self.evaltime = time + 3;
				v2 = (self.enemy.absmin + self.enemy.absmax) * 0.5;
				traceline(v1, v2, TRUE, self);
				if (trace_fraction < 1)
					self.enemy = world;
			}
		}
		else
			self.enemy = world;
	}
	*/
	e = findradius(v1, 1500);
	while (e)
	{
		if (!(e.flags & FL_NOTARGET))
		if (!(cvar("teamplay") && self.team == e.team))      // don't target teammates
		if (e.flags & FL_CLIENT)
		if (e != self)
		if (!e.deadflag)
		if (UrreBotInfront(e))
		if (e.health >= 1)
		{
			v2 = (e.absmin + e.absmax) * 0.5;
			traceline(v1, v2, TRUE, self);
			if (trace_fraction == 1 || trace_ent == e)
			{
				if (self.enemy)
				{
					old = vlen(self.origin - (self.enemy.absmin + self.enemy.absmax)*0.5);
					new = vlen(self.origin - v2);
					if (new < old)
					{
						self.enemy = e;
						self.enemytimeout = time + 3;
					}
				}
				else
				{
					self.enemy = e;
					self.enemytimeout = time + 3;
				}
			}
		}
		e = e.chain;
	}

	e = world;
	if (self.goalcurrent.sflags & S_DOOR)
		e = self.goalcurrent.goalentity;
	else if (self.link0.sflags & S_DOOR)
		e = self.link0.goalentity;
	if (e.health >= 1)
	{
		self.enemy = e;
		self.enemytimeout = time + 3;
	}
};

/* --- UrreBotAim ---
Very crude and simple aiming, with some leading capability*/

void() UrreBotAim =
{
	//local float dist;
	local float f;
	local float skeel;
	local vector v, desiredang, testang, diffang, aimpoint;

	if (self.deadflag)
		return;
	skeel = bound(1, skill, 10);

	v = (self.enemy.absmin + self.enemy.absmax) * 0.5;

	if (self.switchweapon == WEP_ELECTRO || self.switchweapon == WEP_HAGAR || self.switchweapon == WEP_LASER)
	{
		if(math_mod(self.playerid, 2) == 1)
			v_z = (self.enemy.absmin_z * 0.8 + v_z * 0.2); // aim more at the floor
	}

	if (self.enemy)
	{
		if (time > self.enemytimeout || self.enemy.takedamage == DAMAGE_NO || self.enemy.deadflag)
			self.enemy = world;
		else if (self.aimtime <= time)
		{
			self.aimtime = time + 0.1; // LordHavoc: changed from time + 0.3 to time + 0.1
			self.aimfire = FALSE;
			if (self.enemy)
			{
				traceline(self.origin + self.view_ofs, v, TRUE, self);
				if (trace_fraction == 1)
				{
					self.enemytimeout = time + 3;
					self.aimfire = TRUE;
				}
			}
		}
	}

	// get the desired angles to aim at
	desiredang = self.v_angle_y * '0 1 0';
	aimpoint = v;
	if (self.enemy)
	{
		//dprint("urrebotaim (skeel == ", ftos(skeel), ") : old aimpoint ", vtos(self.aimpoint));
		aimpoint = v + self.enemy.velocity*vlen(self.origin - v)*self.lead;
		//dprint(", v = ", vtos(v));
		//dprint(", self.enemy.velocity = ", vtos(self.enemy.velocity));
		//dprint(", vlen(self.origin - v) = ", ftos(vlen(self.origin - v)));
		//dprint(", self.lead = ", ftos(self.lead));
		aimpoint = aimpoint + randomvec()*max(0, 120 - skeel*12);
		//dprint(", final aimpoint = ", vtos(self.aimpoint), "\n");
		//eprint(self);
		//eprint(self.enemy);
		desiredang = vectoangles(aimpoint - (self.origin + self.view_ofs));
	}
	else if (vlen(self.velocity) >= 50)
		desiredang = vectoyaw(self.velocity) * '0 1 0';
	desiredang_x = 0-desiredang_x;

	// calculate turn angles
	testang = desiredang - self.v_angle;
	testang_z = 0;

	while (testang_y < -180)
		testang_y = testang_y + 360;
	while (testang_y >= 180)
		testang_y = testang_y - 360;
	while (testang_x < -180)
		testang_x = testang_x + 360;
	while (testang_x >= 180)
		testang_x = testang_x - 360;

	// turn
	// LordHavoc: simplified to one line
	diffang = testang * min(1, ((skeel * 2) * frametime));

	self.v_angle = self.v_angle + diffang;
	self.angles_y = self.v_angle_y;

	if (self.aimfire)
	if (self.enemy)
	{
		makevectors (self.v_angle);
		//v = self.origin + '0 0 16';
		v = self.origin + self.view_ofs; // neuiz trueaim
		f = vlen(v - aimpoint);
		traceline (v, v + v_forward*f, FALSE, self);
		if (vlen(trace_endpos - aimpoint) < (200 - skeel * 15))
		{
			f = 0.1 + skeel*0.1;
			if (f >= 1)
				self.button0 = 1;
			else if (random() < f)
				self.button0 = 1;
		}
	}

	if(self.switchweapon == WEP_ROCKET_LAUNCHER)
	{
		if(self.lastrocket && self.enemy)
		{
			if(vlen(self.lastrocket.origin - self.enemy.origin) < cvar("g_balance_rocketlauncher_radius") * 0.85)
			{
				if(vlen(self.lastrocket.origin - self.origin) > cvar("g_balance_rocketlauncher_radius") * 1.05)
				{
					f = 0.1 + skeel*0.1;
					if (random() < f)
						self.button3 = 1;
				}
			}
		}
	}
};

/* --- UrreBotMove ---
Moves towards the closest point on the next goal in the bots list,
which can be a navnode, item or domination point*/

void() UrreBotMove =
{
	local float f, bad;
	local vector dir, tvec;
	local entity plane, optpoint;

	if (self.link0)
	{
		if (boxesoverlap(self.origin + self.mins, self.origin + self.maxs, self.link0.origin + self.link0.mins, self.link0.origin + self.link0.maxs))
		{
			optpoint = world;
			plane = self.link0.plane_chain;
			while (plane)
			{
				tvec = self.maxs;
				if (plane.mangle_x < 0)
					tvec_x = self.mins_x;
				if (plane.mangle_y < 0)
					tvec_y = self.mins_y;
				if (plane.mangle_z < 0)
					tvec_z = self.mins_z;
				tvec += self.origin;
				f = tvec*plane.mangle - self.link0.origin*plane.mangle-plane.delay;
				if (f > 0)
					bad = TRUE;
				plane = plane.list;
			}
			if (!bad)
			{
				PopRoute();
				if (self.goalcurrent.sflags & S_TELEPORT)
					self.movepoint = self.goalcurrent.origin;
				else
				{
					if (urrebots_navopt)
						optpoint = MatchOptPoint(self.goalcurrent, self.goallist, self.link0);
					if (optpoint)
						self.movepoint = optpoint.origin;
					else
						self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.link0);
				}
			}
		}
		else if (((self.goalcurrent.sflags & S_TOUCH) && boxesoverlap(self.origin + self.mins, self.origin + self.maxs, self.goalcurrent.origin + self.goalcurrent.mins, self.goalcurrent.origin + self.goalcurrent.maxs)) || boxenclosed(self.origin + self.mins, self.origin + self.maxs, self.goalcurrent.origin + self.goalcurrent.mins, self.goalcurrent.origin + self.goalcurrent.maxs))
		{
			optpoint = world;
			plane = self.goalcurrent.plane_chain;
			while (plane)
			{
				tvec = self.maxs;
				if (plane.mangle_x < 0)
					tvec_x = self.mins_x;
				if (plane.mangle_y < 0)
					tvec_y = self.mins_y;
				if (plane.mangle_z < 0)
					tvec_z = self.mins_z;
				tvec += self.origin;
				f = tvec*plane.mangle - self.goalcurrent.origin*plane.mangle-plane.delay;
				if (f > 0)
					bad = TRUE;
				plane = plane.list;
			}
			if (!bad)
			{
				PopRoute();
				if (self.goalcurrent.sflags & S_TELEPORT)
					self.movepoint = self.goalcurrent.origin;
				else
				{
					if (urrebots_navopt)
						optpoint = MatchOptPoint(self.goalcurrent, self.goallist, self.goalcurrent);
					if (optpoint)
						self.movepoint = optpoint.origin;
					else
						self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.goalcurrent);
				}
				if (self.movepoint == '0 0 0')
				{
					self.strat_me = TRUE;
					UrreBotPath(minisearch_distance);
				}
			}
		}
	}
	else
	{
		optpoint = world;
		if (!self.goalcurrent || ((self.goalcurrent.flags & FL_ITEM) && !self.goalcurrent.solid) || (self.goalcurrent.classname == "dom_controlpoint" && self.goalcurrent.enemy.team == self.team))
		{
			self.strat_me = TRUE;
			UrreBotPath(minisearch_distance);
		}
		if (urrebots_navopt)
			optpoint = MatchOptPoint(self.goalcurrent, self.goallist, self.goalcurrent);
		if (optpoint)
			self.movepoint = optpoint.origin;
		else
			self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.goalcurrent);
	}
//	dir = normalize(ToPointInSpace(self.goalcurrent, self.movepoint));
	dir = ToPointInSpace(self.goalcurrent, self.movepoint);
	dir = dir * sv_maxspeed;
	makevectors(self.v_angle);
	self.movement_x = dir * v_forward;
	self.movement_y = dir * v_right;
	self.movement_z = dir * v_up;
};

/* --- UrreBotImpulses ---
Returns the impulse for the best weapon in the given situation*/

float() UrreBotImpulses =
{
	local float dist, l, w;
	local float cells, rockets, nails, shells;
	local vector v;

	if (random() < 0.5)
		return 0;

	dist = 400; // we like nex and mortar
	if (self.enemy)
	{
		v = (self.enemy.absmin + self.enemy.absmax) * 0.5;
		dist = vlen(v - self.origin);
	}

	cells = self.ammo_cells;
	rockets = self.ammo_rockets;
	nails = self.ammo_nails;
	shells = self.ammo_shells;

	l = 0;
	w = 0;

	if (!w)
	if (self.items & IT_NEX)
	if (dist > 300)
	if (cells >= cvar("g_balance_nex_ammo"))
	{
		l = 1000000;
		w = WEP_NEX;
	}
	if (!w)
	if (self.items & IT_GRENADE_LAUNCHER)
	if (dist >= 200)
	if (dist < 2000)
	if (rockets >= cvar("g_balance_grenadelauncher_primary_ammo"))
	{
		l = cvar("g_balance_grenadelauncher_primary_speed");
		w = WEP_GRENADE_LAUNCHER;
	}
	if (!w)
	if (self.items & IT_HAGAR)
	if (dist >= 100)
	if (dist < 2000)
	if (rockets >= cvar("g_balance_hagar_primary_ammo"))
	{
		l = cvar("g_balance_hagar_primary_speed");
		w = WEP_HAGAR;
	}
	if (!w)
	if (self.items & IT_ROCKET_LAUNCHER)
	if (dist >= 200)
	if (dist < 800)
	if (rockets >= cvar("g_balance_rocketlauncher_ammo"))
	{
		l = cvar("g_balance_rocketlauncher_speed");
		w = WEP_ROCKET_LAUNCHER;
	}
	if (!w)
	if (self.items & IT_ELECTRO)
	if (dist >= 100)
	if (dist < 2000)
	if (cells >= cvar("g_balance_electro_primary_ammo"))
	{
		l = cvar("g_balance_electro_primary_speed");
		w = WEP_ELECTRO;
	}
	if (!w)
	if (self.items & IT_CRYLINK)
	if (dist < 800)
	if (cells >= cvar("g_balance_crylink_primary_ammo"))
	{
		l = cvar("g_balance_crylink_primary_speed");
		w = WEP_CRYLINK;
	}
	if (!w)
	if (self.items & IT_UZI)
	if (dist < 1000)
	if (nails >= cvar("g_balance_uzi_first_ammo"))
	{
		l = 1000000;
		w = WEP_UZI;
	}
	if (!w)
	if (self.items & IT_SHOTGUN)
	if (dist < 1000)
	if (nails >= cvar("g_balance_shotgun_primary_ammo"))
	{
		l = 1000000;
		w = WEP_SHOTGUN;
	}
	if (!w)
	{
		l = cvar("g_balance_laser_speed");
		w = WEP_LASER;
	}
	if (l < 1)
		error("UrreBotImpulses: missing cvar for weapon\n");
	self.lead = 1 / l;
	return w;
};

/* --- BeamBox ---
Used for some debugging, occasionally*/

float BT_LIGHTNING = 0;
float BT_BEAM = 1;
void(float beamtype, vector bmins, vector bmaxs) BeamBox =
{
	local vector v1, v2;

	v1 = bmaxs;
	v2 = bmaxs;
	v2_x = bmins_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v2 = bmaxs;
	v2_y = bmins_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v2 = bmaxs;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_x = bmaxs_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_y = bmaxs_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_z = bmaxs_z;
	v2 = bmins;
	v2_x = bmaxs_x;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_z = bmaxs_z;
	v2 = bmins;
	v2_y = bmaxs_y;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v1_z = bmins_z;
	v2 = bmaxs;
	v2_x = bmins_x;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v1_z = bmins_z;
	v2 = bmaxs;
	v2_y = bmins_y;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_x = bmaxs_x;
	v2 = bmaxs;
	v2_y = bmins_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_y = bmaxs_y;
	v2 = bmaxs;
	v2_x = bmins_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
};

/* --- UrreBotPath ---
Marks route and determines which goal is the most useful to head for*/

void(float sdist) UrreBotPath =
{
	local float f, f2, f3;
	local entity e, best;

	ClearRoute();
	MarkRoute(sdist);
	DistEvalItems();
	f2 = 10000000;
	e = findchainflags(flags, FL_ITEM);
	while (e)
	{
		f = 0;
		if (e.evalfunc)
			f = e.evalfunc(e);
		if (f > 0)
		if (e.goallist)
		{
			f = f + e.costl;
			if (f < f2)
			if (e.solid)
			{
				best = e;
				f2 = e.costl;
			}
		}
		e = e.chain;
	}
	if (best)
	{
		while (best)
		{
			PushRoute(best);
			best = best.goallist;
		}
	}
	else
	{
		f3 = 0;
		while (f3 < 3)
		{
			f = 0;
			f2 = 0;
			f = ceil(random() * navnodes);
			e = navnode_chain;
			while (e)
			{
				if (f == f2)
				if (e.goallist)
				{
					best = e;
					f3 = 3;
				}
				f2 = f2 + 1;
				e = e.list;
			}
			f3 = f3 + 1;
		}
		while (best)
		{
			PushRoute(best);
			best = best.goallist;
		}
	}
};

/* --- UrreBotThink ---
In this version, UrreBot does a path search based on timer and turn
Then it aims, moves, checks if it's stuck, finds/loses stuff to shoot at,
picks best weapon, shoots, and optionally displays debug stuff, in that
order
Aiming must happen before movement, because movement depends on angles
He does not yet have any combat movement*/

void() UrreBotThink =
{
	self.movement = '0 0 0';
	self.button0 = 0;
	self.button2 = 0;
	self.button3 = 0;
	self.impulse = 0;

	if (cvar("teamplay") && self.team == self.enemy.team) // don't return fire if hit by a teammate
		self.enemy = world;

	if (self.deadflag)
	{
		ClearRoute();
		if (random() < 0.2)
			self.button0 = 1;
		return;
	}

	if (strategytime <= time)
	if (strategytoken == self)
	{
		strategytime = time + urrebots_strategytime;
		strategytoken = self.list;
		if (!strategytoken)
			strategytoken = urrebot_chain;
		if (self.strat_me)
		{
			self.strat_me = FALSE;
			UrreBotPath(stratsearch_distance);
		}
	}

	UrreBotAim();
	UrreBotMove();

	if (self.camptime <= time)
	{
		if (vlen(self.origin - self.campcheck) < 200) // stuckage avoidage
		{
			self.camptime = time + urrebots;
			self.strat_me = TRUE;
			UrreBotPath(minisearch_distance);
		}
		else
		{
			self.campcheck = self.origin;
			self.camptime = time + 2;
		}
	}

	if (self.combattime <= time)
	{
		self.combattime = time + urrebots_combattime;
		UrreBotEvalTargets();
		self.impulse = UrreBotImpulses();
	}

	if (cvar("urrebots_debug"))
	{
		te_lightning1(self, self.origin, self.movepoint);
		if (!self.goalcurrent)
		{
			bprint(self.netname);
			bprint(" has no goalcurrent\n");
		}
	}
};
