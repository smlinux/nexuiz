
string(float c) colorname =
{
	// yikes, the quake color set is HARD to describe
	// many are easy, but, uh, 2 browns???
	// 2 purples???
	// that 'pink' is hard to classify
	// I think 'biege' is a fairly good name for color 10
	// oh well, gotta do all the color names...
	if (c ==  0) return "white";
	else if (c ==  1) return "brown";
	else if (c ==  2) return "lightblue";
	else if (c ==  3) return "green";
	else if (c ==  4) return "red";
	else if (c ==  5) return "lighterbrown";
	else if (c ==  6) return "orange";
	else if (c ==  7) return "pink";
	else if (c ==  8) return "purple";
	else if (c ==  9) return "redishpurple";
	else if (c == 10) return "biege";
	else if (c == 11) return "aqua";
	else if (c == 12) return "yellow";
	else if (c == 13) return "blue";
	else if (c == 14) return "flamingorange";
	else if (c == 15) return "psychadelic";
	else              return "INVALID COLOR";
};

float mode_shirtmustmatchpants;
float mode_numteams;
float mode_allowedteams[17];
float mode_teamcount[17];
float mode_teamscore[17];

void() mode_initallowedteams =
{
	local float c;
	c = 0;
	while(c < 17)
	{
		mode_allowedteams[c] = FALSE;
		c = c + 1;
	}
	mode_allowedteams[5] = TRUE; // red
	mode_allowedteams[14] = TRUE; // blue
	if (deathmatch == DM_ELIM
	 || deathmatch == DM_ONEVSALL
	 || deathmatch == DM_CTF_2TEAM
	 || deathmatch == DM_DOMINATION
	 || deathmatch == DM_SUPERDOMINATION)
		mode_numteams = 2;
	else if (deathmatch == DM_CTF_3TEAM)
	{
		mode_numteams = 3;
		mode_allowedteams[13] = TRUE; // yellow
	}
	else
	{
		mode_numteams = 16;
		c = 1;
		while(c < 17)
		{
			mode_allowedteams[c] = TRUE;
			c = c + 1;
		}
	}
};

float(float t) validteam =
{
	return mode_allowedteams[t];
};

float() weakestteam =
{
	local float bestteam;
	local float bestteamcount;
	local float headcount;
	local float c;
	bestteam = -1;
	bestteamcount = 0;
	c = 1;
	while (c < 17)
	{
		if (mode_allowedteams[c])
		{
			headcount = mode_teamcount[c];
			if (bestteamcount > headcount || bestteam == -1)
			{
				bestteamcount = headcount;
				bestteam = c;
			}
		}
		c = c + 1;
	}
	return bestteam;
};

void() updateteams =
{
	local entity head;
	local float c;
	c = 1;
	while (c < 17)
	{
		mode_teamcount[c] = 0;
		mode_teamscore[c] = 0;
		c = c + 1;
	}
	c = 0;
	head = nextent(world);
	while (c < maxclients)
	{
		mode_teamcount[head.team] = mode_teamcount[head.team] + 1;
		mode_teamscore[head.team] = mode_teamscore[head.team] + head.frags;
		c = c + 1;
		head = nextent(head);
	}
};

float(float p) checkteamcolor =
{
	if (!validteam(p + 1))
		p = weakestteam() - 1;
	return p;
};

void(float c) SV_ChangeTeam =
{
	local float pants, shirt, old;
	old = self.clientcolors & 15;
	if (c >= 0)
	{
		pants = c & 15;
		shirt = (c / 16) & 15;
	}
	else
	{
		pants = -1;
		shirt = -1;
	}
	pants = checkteamcolor(pants);
	if (mode_shirtmustmatchpants || shirt < 0)
		shirt = pants;
	setcolor(self, pants + shirt * 16);
	if (pants != old && old >= 0 && teamplay && deathmatch)
	{
		T_Damage(self, self, self, 0, 0, " changed teams", DT_TELEFRAG, self.origin, '0 0 0', Obituary_Generic);
		self.frags = 0;
		PutClientInServer ();
	}
};

void() checkinvalidteam =
{
	// call SV_ChangeTeam to trigger the weakestteam change
	if (!validteam(self.team))
		SV_ChangeTeam(self.team - 1);
};


string dmmessage;

void(string m) setdm =
{
	dmmessage = m;
	if (cvar_string("deathmatch") != m)
		cvar_set("deathmatch", m);
}

void(string m) setteamplay =
{
	dmmessage = m;
	if (cvar_string("teamplay") != m)
		cvar_set("teamplay", m);
}

void() mode_updatecvars =
{
	local float dm, tp;
	dm = cvar("deathmatch");
	tp = cvar("teamplay");
	// now set deathmatch cvar
	if (dm ==  0) setdm("0?Dark Places - Coop");
	else if (dm ==  1) setdm("1?Dark Places - Deathmatch");
	else if (dm ==  2) setdm("2?Dark Places - Deathmatch 2 (can only pickup gun once)");
	else if (dm ==  3) setdm("3?Dark Places - Deathmatch 3 (quick ammo respawn)");
	else if (dm ==  5) setdm("5?Dark Places - Frag Fest (spawn with full pack)");
//	else if (dm ==  6) setdm("6?Dark Places - Random Weapons (spawn with 2 random weapons)"); // removed
	else if (dm ==  7) setdm("7?Dark Places - Monsters");
//	else if (dm ==  8) setdm("8?Dark Places - Elimination");
//	else if (dm ==  9) setdm("9?Dark Places - Kill The Leader Mode");
	else if (dm == 10) setdm("10?Dark Places - Capture The Flag - 2 Team");
	else if (dm == 11) setdm("11?Dark Places - Capture The Flag - 3 Team");
	else if (dm == 12) setdm("12?Dark Places - Domination");
	else if (dm == 13) setdm("13?Dark Places - Monster Capture The Flag - 2 Team");
	else if (dm == 14) setdm("14?Dark Places - Super Domination");
	else if (dm == 30) setdm("30?Dark Places - Role Playing Game");
	else                               setdm("1?Dark Places - Deathmatch");

	// now set teamplay cvar
	if (dm == 0) setteamplay("4?Dark Places - Coop (Can't hurt other players)");
	//else if (dm == 8) setteamplay("3?Dark Places - Elimination");
	//else if (dm == 9) setteamplay("3?Dark Places - Kill The Leader");
	else if (dm == 10) setteamplay("3?Dark Places - Capture The Flag - 2 Team");
	else if (dm == 11) setteamplay("3?Dark Places - Capture The Flag - 3 Team");
	else if (dm == 12) setteamplay("3?Dark Places - Domination");
	else if (dm == 13) setteamplay("3?Dark Places - Monster Capture The Flag - 2 Team");
	else
	{
		if (tp == 0) setteamplay("0?Dark Places - No Teamplay");
		else if (tp == 1) setteamplay("1?Dark Places - No team damage");
		else if (tp == 2) setteamplay("2?Dark Places - Can hurt anyone");
		else if (tp == 3) setteamplay("3?Dark Places - No team damage, but can hurt self");
		else              setteamplay("0?Dark Places - No Teamplay");
	}
};

float nextcvarupdate;
void() deathmatch7update;
void() modeupdate =
{
	if (time > nextcvarupdate)
	{
		nextcvarupdate = time + 1;
		mode_updatecvars();
	}
	deathmatch7update();
};

// true if items should respawn
float itemrespawn;
// when the next monster spawning check will occur in deathmatch 7 mode
float spawnchecktime;

void() precachemonsters;
void() superdomination_precache;
void() modesetup =
{
	mode_shirtmustmatchpants = deathmatch >= DM_TEAM_MODS_START && deathmatch < DM_TEAM_MODS_END;
	mode_initallowedteams();

	itemrespawn = cvar("deathmatch") + cvar("coop");

	// don't spawn any monsters until 15 seconds
	spawnchecktime = 15;
	if (deathmatch == 7 || cvar("spawnmonsters") >= 1)
		precachemonsters();

	superdomination_precache();
};

float monsterspawn;
void() spawnmonster_think =
{
	//local float c;
	local void() sfunc;
	self.nextthink = time;
	if (time > self.cnt)
	{
		remove(self);
		return;
	}
	if (vlen(self.velocity) > 5)
		return; // try again later

	//if (!(self.flags & FL_FLY))
	//	droptofloor();
	// don't spawn if something is in the way
	/*
	// walk around a lot
	if (walkmove(0,0))
	{
		if (self.lefty > 0)
		{
			c = 100;
			self.lefty = self.lefty - 1;
			self.angles = '0 0 0';
			while(c > 0)
			{
				c = c - 1;
				if (!walkmove(self.angles_y, 16))
					self.angles_y = random() * 360;
			}
			self.angles = '0 0 0';
			return;
		}
	}
	*/
	// don't spawn if something is in the way
	if (!walkmove(0,0))
	{
		self.lefty = 10;
		setorigin(self, self.dest);
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.velocity = randomvec() * 700 + '0 0 1000';
		return;
	}
	newmis = findchain(classname, "player");
	while (newmis)
	{
		if (vlen(newmis.origin - self.origin) < 300)
			return;
		newmis = newmis.chain;
	}

	if (self.netname == "monster_fish")
	{
		if (pointcontents(self.origin) != CONTENT_WATER)
		{
			remove(self);
			return;
		}
	}

	// spawn in
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.velocity = '0 0 0';
	self.flags = 0;
	self.model = "";
	self.modelindex = 0;
	setorigin(self, self.origin);
	self.angles = '0 360 0' * random();
	self.classname = self.netname;
	self.netname = "";
	self.cnt = 0;
	self.think = SUB_Remove;
	sfunc = self.th_run;
	self.th_run = SUB_Null;
	te_teleport(self.origin);
	monsterspawn = TRUE;
	sfunc();
	monsterspawn = FALSE;
};

void(vector org, float c1, float c2, string cname, void() spawnfunc, vector m1, vector m2) spawnmonster =
{
	local float c;
	c = (c2 - c1) * random() + c1;
	c = rint(c);
	while (c > 0)
	{
		c = c - 1;

		newmis = spawn();
		newmis.cnt = time + 10;
		if (cname == "monster_wizard")
			newmis.cnt = time + 2;
		newmis.lefty = 10;
		newmis.dest = org;
		newmis.classname = "spawningmonster";
		newmis.netname = cname;
		newmis.solid = SOLID_TRIGGER;
		newmis.movetype = MOVETYPE_TOSS;
		newmis.flags = FL_MONSTER; // make this count as a monster even though it hasn't spawned in yet
		newmis.velocity = randomvec() * 700 + '0 0 1000';
		newmis.th_run = spawnfunc;
		newmis.think = spawnmonster_think;
		newmis.nextthink = time + random() * 0.5 + 0.3;
		setorigin(newmis, org);
		setmodel(newmis, "progs/s_explod.spr");
		setsize(newmis, m1, m2);
	}
};

void() monster_army;
void() monster_demon1;
void() monster_dog;
void() monster_enforcer;
void() monster_hell_knight;
void() monster_knight;
void() monster_ogre;
void() monster_shalrath;
void() monster_shambler;
void() monster_tarbaby;
void() monster_wizard;
void() monster_zombie;
void() monster_fish;
void() monster_hellfish;

void() spawnmonsters =
{
	local float r;
	local vector org;
	local entity head, e;
	head = findchain(classname, "info_player_deathmatch");
	if (head == world)
	{
		head = findchain(classname, "info_player_coop");
		if (head == world)
		{
			head = findchain(classname, "info_player_start");
			if (head == world)
				return;
		}
	}

	// count the spawn points
	r = 0;
	e = head;
	while (e)
	{
		r = r + 1;
		e = e.chain;
	}

	// pick a random one
	r = random() * r;
	e = head;
	while (r > 0)
	{
		r = r - 1;
		org = e.origin;
		e = e.chain;
	}

	// pick a type of monster
	if (cvar("registered"))
	{
		r = floor(random() * 13);
		if (r > 12)
			r = 12;
	}
	else
	{
		r = floor(random() * 8);
		if (r > 7)
			r = 7;
	}
	     if (r ==  0) spawnmonster(org,  5, 10, "monster_army"       , monster_army       , '-16 -16 -24', '16 16 32');
	else if (r ==  1) spawnmonster(org,  3,  6, "monster_demon1"     , monster_demon1     , '-32 -32 -24', '32 32 64');
	else if (r ==  2) spawnmonster(org,  6, 12, "monster_dog"        , monster_dog        , '-16 -16 -24', '16 16 32');
	else if (r ==  3) spawnmonster(org,  6, 12, "monster_knight"     , monster_knight     , '-16 -16 -24', '16 16 32');
	else if (r ==  4) spawnmonster(org,  3,  6, "monster_ogre"       , monster_ogre       , '-32 -32 -24', '32 32 64');
	else if (r ==  5) spawnmonster(org,  1,  1, "monster_shambler"   , monster_shambler   , '-32 -32 -24', '32 32 64');
	else if (r ==  6) spawnmonster(org,  6, 10, "monster_wizard"     , monster_wizard     , '-16 -16 -24', '16 16 32');
	else if (r ==  7) spawnmonster(org,  8, 16, "monster_zombie"     , monster_zombie     , '-16 -16 -24', '16 16 32');
	else if (r ==  8) spawnmonster(org,  4,  8, "monster_enforcer"   , monster_enforcer   , '-16 -16 -24', '16 16 32');
	else if (r ==  9) spawnmonster(org,  4,  8, "monster_hell_knight", monster_hell_knight, '-16 -16 -24', '16 16 32');
	else if (r == 10) spawnmonster(org,  1,  3, "monster_shalrath"   , monster_shalrath   , '-32 -32 -24', '32 32 64');
	else if (r == 11) spawnmonster(org, 10, 15, "monster_tarbaby"    , monster_tarbaby    , '-16 -16 -24', '16 16 32');
	else if (r == 12) spawnmonster(org,  4,  8, "monster_fish"       , monster_fish       , '-16 -16 -24', '16 16 32');
};

float monstersprecached;
void() precachemonster_army;
void() precachemonster_demon1;
void() precachemonster_dog;
void() precachemonster_enforcer;
void() precachemonster_hell_knight;
void() precachemonster_knight;
void() precachemonster_ogre;
void() precachemonster_shalrath;
void() precachemonster_shambler;
void() precachemonster_tarbaby;
void() precachemonster_wizard;
void() precachemonster_zombie;
void() precachemonster_fish;

void() precachemonsters =
{
	precachemonster_army();
	precachemonster_demon1();
	precachemonster_dog();
	precachemonster_knight();
	precachemonster_ogre();
	precachemonster_shambler();
	precachemonster_wizard();
	precachemonster_zombie();
	if (cvar("registered"))
	{
		precachemonster_enforcer();
		precachemonster_hell_knight();
		precachemonster_shalrath();
		precachemonster_tarbaby();
		precachemonster_fish();
	}
	monstersprecached = TRUE;
};

float spawnedexitmonsters;
void() deathmatch7update =
{
	local entity e;
	local float f, monster_count, monsters;
	if (skill >= 5)
	if (!deathmatch)
	{
		if (!spawnedexitmonsters)
		if (time >= 2)
		{
			spawnedexitmonsters = TRUE;
			e = find(world, classname, "trigger_changelevel");
			while (e)
			{
				spawnmonster(e.origin + (e.mins + e.maxs) * 0.5, 8, 8, "monster_hellfish", monster_hellfish, '-16 -16 -24', '16 16 32');
				e = find(e, classname, "trigger_changelevel");
			}
		}
		return;
	}
	if (time < spawnchecktime)
		return;
	if (!monstersprecached)
		return;
	spawnchecktime = time + 0.2;
	monsters = 0;
	if (deathmatch == 7)
		monsters = 50;
	f = cvar("spawnmonsters");
	if (f >= 1)
		monsters = f;
	if (monsters < 1)
		return;
	monster_count = 0;
	e = findchainflags(flags, FL_MONSTER);
	while (e)
	{
		monster_count = monster_count + 1;
		e = e.chain;
	}
	if (monster_count >= monsters)
		return;
	spawnmonsters();
}
