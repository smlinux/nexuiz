/* --- UrreBotSetup ---
Issues a random funky name, random colors, playermodel and team to the bot*/

void() UrreBotSetup =
{
	local float r, shirt, pants;
	local string s;

	r = random()*18;
	if (r <= 1)
		s = "GrooveMachine";
	else if (r <= 2)
		s = "Worm";
	else if (r <= 3)
		s = "ClownLock";
	else if (r <= 4)
		s = "DiscO";
	else if (r <= 5)
		s = "FunkyFresh";
	else if (r <= 6)
		s = "DanceWithMe";
	else if (r <= 7)
		s = "BodyJiggle";
	else if (r <= 8)
		s = "CantSwim";
	else if (r <= 9)
		s = "AtomicDog";
	else if (r <= 10)
		s = "Follower";
	else if (r <= 11)
		s = "BrassMonkey";
	else if (r <= 12)
		s = "SirNose";
	else if (r <= 13)
		s = "StarChild";
	else if (r <= 14)
		s = "GeorgeC";
	else if (r <= 15)
		s = "Bootsy";
	else if (r <= 16)
		s = "Flashlight";
	else if (r <= 17)
		s = "Bodysnatcher";
	else
		s = "Boogieboy";

	self.netname = s;

	r = random()*15;
	if (r <= 1)
	{
		self.playermodel = "models/player/carni.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 2)
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "0";
	}
	else if (r <= 3)
	{
		self.playermodel = "models/player/grunt.zym";
		self.playerskin = "0";
	}
	else if (r <= 4)
	{
		self.playermodel = "models/player/headhunter.zym";
		self.playerskin = "0";
	}
	else if (r <= 5)
	{
		self.playermodel = "models/player/insurrectionist.zym";
		self.playerskin = "0";
	}
	else if (r <= 6)
	{
		self.playermodel = "models/player/jeandarc.zym";
		self.playerskin = "0";
	}
	else if (r <= 7)
	{
		self.playermodel = "models/player/lurk.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 8)
	{
		self.playermodel = "models/player/lycanthrope.zym";
		self.playerskin = "0";
	}
	else if (r <= 9)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "0";
	}
	else if (r <= 10)
	{
		self.playermodel = "models/player/nexus.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 11)
	{
		self.playermodel = "models/player/pyria.zym";
		self.playerskin = "0";
	}
	else if (r <= 12)
	{
		self.playermodel = "models/player/shock.zym";
		self.playerskin = "0";
	}
	else if (r <= 13)
	{
		self.playermodel = "models/player/skadi.zym";
		self.playerskin = "0";
	}
	else if (r <= 14)
	{
		self.playermodel = "models/player/specop.zym";
		self.playerskin = "0";
	}
	else
	{
		self.playermodel = "models/player/visitant.zym";
		self.playerskin = "0";
	}

	if (teamplay)
		JoinBestTeam(self, 0);
	else
	{
		shirt = floor(random()*15);
		pants = floor(random()*15);
		self.clientcolors = pants + shirt * 16;
	}
};

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
	e = findradius(v1, 1500);
	while (e)
	{
		if (!(e.flags & FL_NOTARGET) || e.killcount != -666) // -666 is spec/obs
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
						self.enemy = e;
				}
				else
					self.enemy = e;
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
		self.enemy = e;
};

/* --- UrreBotAim ---
Very crude and simple aiming, with some leading capability*/

void() UrreBotAim =
{
	local float dist, skeel;
	local vector v, desiredang, testang, diffang;

	skeel = bound(1, skill, 10);

	// get the desired angles to aim at
	if (self.enemy)
	{
		v = (self.enemy.absmin + self.enemy.absmax) * 0.5;
		if (self.enemy.classname == "door")
			self.aimpoint = v;
		else if (self.aimtime <= time)
		{
			self.aimtime = time + 0.3;
			traceline(self.origin + self.view_ofs, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, self);
			if (trace_fraction == 1)
			{
				self.aimpoint = v + self.enemy.velocity*vlen(self.origin - v)*self.lead;
				self.aimpoint = self.aimpoint + randomvec()*max(0, 120 - skeel*12);
			}
		}
		desiredang = vectoangles(self.aimpoint - (self.origin + self.view_ofs));
	}
	else
		desiredang = vectoangles(self.velocity);
	desiredang_x = 0-desiredang_x;

	if (desiredang_y <= -180)
		desiredang_y = desiredang_y + 360;
	else if (desiredang_y >= 180)
		desiredang_y = desiredang_y - 360;
	if (desiredang_x <= -180)
		desiredang_x = desiredang_x + 360;
	else if (desiredang_x >= 180)
		desiredang_x = desiredang_x - 360;

	// calculate turn angles
	testang = desiredang - self.v_angle;
	testang_z = 0;

	// turn
	dist = vlen(testang * ((skeel + 1) * frametime));
	if (vlen(normalize(testang) * skeel) > dist)
	{
		diffang = normalize(testang) * skeel;
		dist = vlen(normalize(testang) * skeel);
	}
	else
		diffang = testang * ((skeel + 1) * frametime);
	if (dist > vlen(testang))
		diffang = testang;

	self.v_angle = self.v_angle + diffang;
	self.angles_y = self.v_angle_y;
};

/* --- UrreBotMove ---
Moves towards the closest point on the next goal in the bots list,
which can be a navnode, item or domination point*/

void() UrreBotMove =
{
	local float f, bad;
	local vector dir, tvec;
	local entity plane;

	if (self.link0)
	{
		if (boxesoverlap(self.origin + self.mins, self.origin + self.maxs, self.link0.origin + self.link0.mins, self.link0.origin + self.link0.maxs))
		{
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
					self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.link0);
			}
		}
		else if (((self.goalcurrent.sflags & S_TOUCH) && boxesoverlap(self.origin + self.mins, self.origin + self.maxs, self.goalcurrent.origin + self.goalcurrent.mins, self.goalcurrent.origin + self.goalcurrent.maxs)) || boxenclosed(self.origin + self.mins, self.origin + self.maxs, self.goalcurrent.origin + self.goalcurrent.mins, self.goalcurrent.origin + self.goalcurrent.maxs))
		{
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
					self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.goalcurrent);
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
		if (!self.goalcurrent || ((self.goalcurrent.flags & FL_ITEM) && !self.goalcurrent.solid) || (self.goalcurrent.classname == "dom_controlpoint" && self.goalcurrent.enemy.team == self.team))
		{
			self.strat_me = TRUE;
			UrreBotPath(minisearch_distance);
		}
		self.movepoint = ClampPointToSpace(self.origin, self.goalcurrent, self.goalcurrent);
	}
	dir = normalize(ToPointInSpace(self.goalcurrent, self.movepoint));
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
	local float dist;
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

	if (dist > 300 && cells && (self.items & IT_NEX))
	{
		self.lead = 0;
		return WEP_NEX;
	}
	else if (rockets)
	{
		if (dist < 500)
		if (self.items & IT_GRENADE_LAUNCHER)
		{
			self.lead = 1 / cvar("g_balance_grenadelauncher_speed");
			return WEP_GRENADE_LAUNCHER;
		}
		if (self.items & IT_HAGAR)
		{
			self.lead = 1 / cvar("g_balance_hagar_speed");
			return WEP_HAGAR;
		}
		else if (self.items & IT_ROCKET_LAUNCHER)
		{
			self.lead = 1 / cvar("g_balance_rocketlauncher_speed");
			return WEP_ROCKET_LAUNCHER;
		}
	}
	else if (cells)
	{
		if (self.items & IT_ELECTRO)
		{
			self.lead = 1 / cvar("g_balance_electro_speed");
			return WEP_ELECTRO;
		}
		else if (self.items & IT_CRYLINK)
		{
			self.lead = 1 / cvar("g_balance_crylink_speed");
			return WEP_CRYLINK;
		}
	}
	else if (nails)
	{
		if (self.items & IT_UZI)
		{
			self.lead = 0;
			return WEP_UZI;
		}
	}
	else if (shells)
	{
		if (self.items & IT_SHOTGUN)
		{
			self.lead = 0;
			return WEP_SHOTGUN;
		}
	}
	self.lead = 1 / cvar("g_balance_laser_speed");
	return WEP_LASER;
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
	local float f;
	local vector v;

	self.movement = '0 0 0';
	self.button0 = 0;
	self.button2 = 0;
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
			strategytoken = bot_chain;
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
			self.camptime = time + actualurrebots;
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

	if (self.enemy)
	{
		makevectors (self.v_angle);
		v = self.origin + '0 0 16';
		f = vlen(v - self.aimpoint);
		traceline (v, v + v_forward*f, FALSE, self);
		if (vlen(trace_endpos - self.aimpoint) < 150)
		{
			if (skill < 3)
			{
				if (random() < 0.3)
					self.button0 = 1;
			}
			else
				self.button0 = 1;
		}
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
