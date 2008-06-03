float SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS = 1;
string redirection_target;
float world_initialized;

string GetMapname();
string GetGametype();
void GotoNextMap();
void ShuffleMaplist()
float() DoNextMapOverride;

void SetDefaultAlpha()
{
	if(cvar("g_running_guns"))
	{
		default_player_alpha = -1;
		default_weapon_alpha = +1;
	}
	else if(g_cloaked)
	{
		default_player_alpha = cvar("g_balance_cloaked_alpha");
		default_weapon_alpha = default_player_alpha;
	}
	else
	{
		default_player_alpha = cvar("g_player_alpha");
		if(default_player_alpha <= 0)
			default_player_alpha = 1;
		default_weapon_alpha = default_player_alpha;
	}
}

void fteqcc_testbugs()
{
	float a, b;

	if(!cvar("developer_fteqccbugs"))
		return;

	dprint("*** fteqcc test: checking for bugs...\n");

	a = 1;
	b = 5;
	if(sqrt(a) - sqrt(b - a) == 0)
		dprint("*** fteqcc test: found same-function-twice bug\n");
	else
		dprint("*** fteqcc test: same-function-twice bug got FINALLY FIXED! HOORAY!\n");

	world.frags = -10;
	world.enemy = world;
	world.enemy.frags += 10;
	if(world.frags > 0.2 || world.frags < -0.2) // don't error out if it's just roundoff errors
		dprint("*** fteqcc test: found += bug\n");
	else
		dprint("*** fteqcc test: += bug got FINALLY FIXED! HOORAY!\n");
	world.frags = 0;
}

/**
 * Takes care of pausing and unpausing the game.
 * Centerprints the information about an upcoming or active timeout to all active
 * players. Also plays reminder sounds.
 */
void timeoutHandler_Think() {
	local string timeStr;
	local entity plr;
	if (timeoutStatus == 1) {
		if (remainingLeadTime > 0) {
			//centerprint the information to every player
			timeStr = getTimeoutText(0);
			FOR_EACH_REALCLIENT(plr) {
				if(plr.classname == "player") {
					centerprint_atprio(plr, CENTERPRIO_SPAM, timeStr);
				}
			}
			remainingLeadTime -= 1;
			//think again in 1 second:
			self.nextthink = time + 1;
		}
		else {
			//now pause the game:
			timeoutStatus = 2;
			cvar_set("slowmo", ftos(TIMEOUT_SLOWMO_VALUE));
			//copy .v_angle to .lastV_angle for every player in order to fix their view during pause (see PlayerPreThink)
			FOR_EACH_REALPLAYER(plr) {
				plr.lastV_angle = plr.v_angle;
			}
			self.nextthink = time;
		}
	}
	else if (timeoutStatus == 2) {
		if (remainingTimeoutTime > 0) {
			timeStr = getTimeoutText(0);
			FOR_EACH_REALCLIENT(plr) {
				if(plr.classname == "player") {
					centerprint_atprio(plr, CENTERPRIO_SPAM, timeStr);
				}
			}
			if(remainingTimeoutTime == cvar("sv_timeout_resumetime")) { //play a warning sound when only <sv_timeout_resumetime> seconds are left
				sound(world, CHAN_AUTO, "announcer/robotic/prepareforbattle.wav", 1, ATTN_NONE);
			}
			remainingTimeoutTime -= 1;
			self.nextthink = time + TIMEOUT_SLOWMO_VALUE;
		}
		else {
			//unpause the game again
			remainingTimeoutTime = timeoutStatus = 0;
			cvar_set("slowmo", ftos(orig_slowmo));
			//and unlock the fixed view again once there is no timeout active anymore
			FOR_EACH_REALPLAYER(plr) {
				plr.fixangle = FALSE;
			}
			//get rid of the countdown message
			FOR_EACH_REALCLIENT(plr) {
				if(plr.classname == "player") {
					centerprint_atprio(plr, CENTERPRIO_SPAM, "");
				}
			}
			remove(self);
			return;
		}
		
	}
	else if (timeoutStatus == 0) { //if a player called the resumegame command (which set timeoutStatus to 0 already)
		FOR_EACH_REALCLIENT(plr) {
			if(plr.classname == "player") {
				centerprint_atprio(plr, CENTERPRIO_SPAM, "");
			}
		}
		remove(self);
		return;
	}
}

float GotoFirstMap()
{
	if(cvar("_sv_init"))
	{
		cvar_set("_sv_init", "0");
		if(cvar("g_maplist_shuffle"))
			ShuffleMaplist();
#ifdef MAPINFO
		tokenizebyseparator(cvar_string("g_maplist"), " ");
#else
		tokenize(cvar_string("g_maplist"));
		if(argv(0) != GetMapname())
#endif
		{
			cvar_set("nextmap", argv(0));

#ifdef MAPINFO
			MapInfo_Enumerate();
			MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0);
#endif

			if(!DoNextMapOverride())
				GotoNextMap();

			return 1;
		}
	}
	return 0;
}

float world_already_spawned;
void spawnfunc_worldspawn (void)
{
	dprint_load(); // load dprint status from cvar

	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = TRUE;

	if(GotoFirstMap())
		return;

#ifdef MAPINFO
	MapInfo_LoadMapSettings(mapname);
#endif

	if(sv_cheats)
		ServerProgsDB = db_create();
	else
		ServerProgsDB = db_load("server.db");

	/*
	TODO sound pack system
	// initialize sound pack system
	soundpack = cvar_string("g_soundpack");
	if(soundpack != "")
		soundpack = strcat(soundpack, "/");
	soundpack = strzone(soundpack);
	*/

	// 0 normal
	lightstyle(0, "m");

	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the spawnfunc_light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	// for setting by mapinfo
	q3acompat_machineshotgunswap = cvar("sv_q3acompat_machineshotgunswap");
	cvar_set("sv_q3acompat_machineshotgunswap", "0");

	player_count = 0;
	lms_lowest_lives = 0;
	lms_next_place = 0;

	bot_waypoints_for_items = cvar("g_waypoints_for_items");
	if(bot_waypoints_for_items == 1)
		if(self.spawnflags & SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS)
			bot_waypoints_for_items = 0;

	if(cvar("g_campaign"))
		CampaignPreInit();

	InitGameplayMode();
	readlevelcvars();
	precache();

	WaypointSprite_Init();

	//if (g_domination)
	//	dom_init();

	local entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		maxclients++;
		head = nextent(head);
	}

	GameLogInit(); // prepare everything
	if(cvar("sv_eventlog"))
	{
		local string s;
		GameLogEcho(":logversion:2", FALSE);
		s = strcat(cvar_string("sv_eventlog_files_counter"), ".");
		s = strcat(s, ftos(random()));
#ifdef MAPINFO
		GameLogEcho(strcat(":gamestart:", GetGametype(), "_", GetMapname(), ":", s), FALSE);
#else
		GameLogEcho(strcat(":gamestart:", GetMapname(), ":", s), FALSE);
#endif
		s = ":gameinfo:mutators:LIST";
		if(cvar("g_grappling_hook"))
			s = strcat(s, ":grappling_hook");
		if(!cvar("g_use_ammunition"))
			s = strcat(s, ":no_use_ammunition");
		if(!cvar("g_pickup_items"))
			s = strcat(s, ":no_pickup_items");
		if(cvar("g_instagib"))
			s = strcat(s, ":instagib");
		if(cvar("g_rocketarena"))
			s = strcat(s, ":rockerarena");
		if(cvar("g_nixnex"))
			s = strcat(s, ":nixnex");
		if(cvar("g_vampire"))
			s = strcat(s, ":vampire");
		if(cvar("g_laserguided_missile"))
			s = strcat(s, ":laserguided_missile");
		if(cvar("g_norecoil"))
			s = strcat(s, ":norecoil");
		if(cvar("g_midair"))
			s = strcat(s, ":midair");
		if(cvar("g_minstagib"))
			s = strcat(s, ":minstagib");
		GameLogEcho(s, FALSE);
		GameLogEcho(":gameinfo:end", FALSE);
	}

	cvar_set("nextmap", "");

	SetDefaultAlpha();

	if(cvar("g_campaign"))
		CampaignPostInit();

	fteqcc_testbugs();

	Ban_LoadBans();

	//initialise globals related to sv_timeout
	sys_ticrate = cvar("sys_ticrate");
	orig_slowmo = cvar("slowmo");

#ifdef MAPINFO
	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 1);
#endif

	//if tourney is used map starts in warmup mode. if this mode shall stay unlimited, reset timelimit, but save the original one
	if(g_tourney && cvar("g_tourney_warmup_unlimited_time")) {
		timelimit_orig = cvar("timelimit");
		cvar_set("timelimit", "0");
	}

	world_initialized = 1;
}

void spawnfunc_light (void)
{
	//makestatic (self); // Who the f___ did that?
	remove(self);
}

float( string pFilename ) TryFile =
{
	local float lHandle;
	dprint("TryFile(\"", pFilename, "\")\n");
	lHandle = fopen( pFilename, FILE_READ );
	if( lHandle != -1 ) {
		fclose( lHandle );
		return TRUE;
	} else {
		return FALSE;
	}
};

string GetGametype()
{
	if (game == GAME_DEATHMATCH)
		return "dm";
	else if (game == GAME_TEAM_DEATHMATCH)
		return "tdm";
	else if (game == GAME_DOMINATION)
		return "dom";
	else if (game == GAME_CTF)
		return "ctf";
	else if (game == GAME_RUNEMATCH)
		return "rune";
	else if (game == GAME_LMS)
		return "lms";
	else if (game == GAME_KEYHUNT)
		return "kh";
	else if (game == GAME_ONSLAUGHT)
		return "ons";
	else if (game == GAME_ASSAULT)
		return "as";
	return "dm";
}

float IsSameGametype(string mapcfgname)
{
#ifdef MAPINFO
	return TRUE; // can't change game type by map name here
#else
	string gt;
	gt = GetGametype();
	if(substring(mapcfgname, 0, strlen(gt) + 1) == strcat(gt, "_"))
		return TRUE;
	return FALSE;
#endif
}

string getmapname_stored;
string GetMapname()
{
#ifdef MAPINFO
	return mapname;
#else
	if(getmapname_stored == "")
		getmapname_stored = strzone(strcat(GetGametype(), "_", mapname));
	return getmapname_stored;
#endif
}

float Map_Count, Map_Current;
string Map_Current_Name;

// NOTE: this now expects the map list to be already tokenize()d and the count in Map_Count
float GetMaplistPosition()
{
	float pos, idx;
	string map;

	map = GetMapname();
	idx = cvar("g_maplist_index");

	if(idx >= 0)
		if(idx < Map_Count)
			if(map == argv(idx))
				return idx;

	for(pos = 0; pos < Map_Count; ++pos)
		if(map == argv(pos))
			return pos;

	// resume normal maplist rotation if current map is not in g_maplist
	return idx;
}

float MapHasRightSize(string map)
{
	float fh;
	if(currentbots || cvar("bot_number") || player_count < cvar("minplayers"))
	if(cvar("g_maplist_check_waypoints"))
	{
		dprint("checkwp "); dprint(map);
		fh = fopen(strcat("maps/", map, ".waypoints"), FILE_READ);
		if(fh < 0)
		{
			dprint(": no waypoints\n");
			return FALSE;
		}
		dprint(": has waypoints\n");
		fclose(fh);
	}

	// open map size restriction file
	dprint("opensize "); dprint(map);
	fh = fopen(strcat("maps/", map, ".sizes"), FILE_READ);
	if(fh >= 0)
	{
		float mapmin, mapmax;
		dprint(": ok, ");
		mapmin = stof(fgets(fh));
		mapmax = stof(fgets(fh));
		fclose(fh);
		if(player_count < mapmin)
		{
			dprint("not enough\n");
			return FALSE;
		}
		if(player_count > mapmax)
		{
			dprint("too many\n");
			return FALSE;
		}
		dprint("right size\n");
		return TRUE;
	}
	dprint(": not found\n");
	return TRUE;
}

string Map_Filename(float position)
{
#ifdef MAPINFO
	return strcat("maps/", argv(position), ".bsp");
#else
	return strcat("maps/", argv(position), ".mapcfg");
#endif
}

string strwords(string s, float w)
{
	float endpos;
	for(endpos = 0; w && endpos >= 0; --w)
		endpos = strstrofs(s, " ", endpos + 1);
	if(endpos < 0)
		return s;
	else
		return substring(s, 0, endpos);
}

float strhasword(string s, string w)
{
	return strstrofs(strcat(" ", s, " "), strcat(" ", w, " "), 0) >= 0;
}

void Map_MarkAsRecent(string m)
{
	cvar_set("g_maplist_mostrecent", strwords(strcat(m, " ", cvar_string("g_maplist_mostrecent")), cvar("g_maplist_mostrecent_count")));
}

float Map_IsRecent(string m)
{
	return strhasword(cvar_string("g_maplist_mostrecent"), m);
}

float(float position, float pass) Map_Check =
{
	string filename;
	string map_next;
	map_next = argv(position);
	if(pass <= 1)
	{
		if(map_next == Map_Current_Name) // same map again in first pass?
			return 0;
		if(Map_IsRecent(map_next))
			return 0;
	}
	filename = Map_Filename(position);
#ifdef MAPINFO
	if(MapInfo_CheckMap(map_next))
#else
	if(TryFile(filename))
#endif
	{
		if(pass == 2)
			return 1;
		if(MapHasRightSize(map_next))
			return 1;
		return 0;
	}
	else
		dprint( "Couldn't select '", filename, "'..\n" );

	return 0;
}

void(string nextmapname) Map_Goto_SetStr =
{
	if(getmapname_stored != "")
		strunzone(getmapname_stored);
	if(nextmapname == "")
		getmapname_stored = "";
	else
		getmapname_stored = strzone(nextmapname);
}

void(float position) Map_Goto_SetFloat =
{
	cvar_set("g_maplist_index", ftos(position));
	Map_Goto_SetStr(argv(position));
}

void() GameResetCfg =
{
#ifdef MAPINFO
	// settings persist, except...
	if(cvar("g_campaign"))
		localcmd("\nexec mutator_reset.cfg\n");
	localcmd("\nsettemp_restore\n");
#else
	// if an exit cfg is defined by exiting map, exec it.
	string exit_cfg;
	exit_cfg = cvar_string("exit_cfg");
	if(exit_cfg != "")
		localcmd(strcat("exec \"", exit_cfg, "\"\n"));

	localcmd("exec game_reset.cfg\n");
#endif
};

void() Map_Goto =
{
	Map_MarkAsRecent(getmapname_stored);
	GameResetCfg();
#ifdef MAPINFO
	MapInfo_LoadMap(getmapname_stored);
#else
	localcmd(strcat("exec \"maps/", getmapname_stored ,".mapcfg\"\n"));
#endif
}

// return codes of map selectors:
//   -1 = temporary failure (that is, try some method that is guaranteed to succeed)
//   -2 = permanent failure
float() MaplistMethod_Iterate = // usual method
{
	float pass, i;

	for(pass = 1; pass <= 2; ++pass)
	{
		for(i = 1; i < Map_Count; ++i)
		{
			float mapindex;
			mapindex = mod(i + Map_Current, Map_Count);
			if(Map_Check(mapindex, pass))
				return mapindex;
		}
	}
	return -1;
}

float() MaplistMethod_Repeat = // fallback method
{
	if(Map_Check(Map_Current, 2))
		return Map_Current;
	return -2;
}

float() MaplistMethod_Random = // random map selection
{
	float i, imax;

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		float mapindex;
		mapindex = mod(Map_Current + ceil(random() * (Map_Count - 1)), Map_Count); // any OTHER map
		if(Map_Check(mapindex, 1))
			return mapindex;
	}
	return -1;
}

float(float exponent) MaplistMethod_Shuffle = // more clever shuffling
// the exponent sets a bias on the map selection:
// the higher the exponent, the less likely "shortly repeated" same maps are
{
	float i, j, imax, insertpos;

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		string newlist;

		// now reinsert this at another position
		insertpos = pow(random(), 1 / exponent);       // ]0, 1]
		insertpos = insertpos * (Map_Count - 1);       // ]0, Map_Count - 1]
		insertpos = ceil(insertpos) + 1;               // {2, 3, 4, ..., Map_Count}
		dprint("SHUFFLE: insert pos = ", ftos(insertpos), "\n");

		// insert the current map there
		newlist = "";
#ifdef MAPINFO
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, " ", argv(j));
		newlist = strcat(newlist, " ", argv(0));       // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, " ", argv(j));
		newlist = substring(newlist, 1, strlen(newlist) - 1);
#else
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, "'", argv(j), "'");
		newlist = strcat(newlist, "'", argv(0), "'");  // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, "'", argv(j), "'");
#endif
		cvar_set("g_maplist", newlist);
#ifdef MAPINFO
		Map_Count = tokenizebyseparator(cvar_string("g_maplist"), " ");
#else
		Map_Count = tokenize(newlist);
#endif

		// NOTE: the selected map has just been inserted at (insertpos-1)th position
		Map_Current = insertpos - 1; // this is not really valid, but this way the fallback has a chance of working
		if(Map_Check(Map_Current, 1))
			return Map_Current;
	}
	return -1;
}

void() Maplist_Init =
{
	string temp;
	temp = cvar_string("g_maplist");
#ifdef MAPINFO
	Map_Count = tokenizebyseparator(cvar_string("g_maplist"), " ");
#else
	Map_Count = tokenize(temp);
#endif
	if(Map_Count == 0)
	{
		bprint( "Maplist is empty!  Resetting it to default map list.\n" );
#ifdef MAPINFO
		cvar_set("g_maplist", temp = MapInfo_ListAllowedMaps());
		localcmd("\nmenu_cmd sync\n");
		Map_Count = tokenizebyseparator(temp, " ");
#else
		cvar_set("g_maplist", temp = cvar_string("g_maplist_defaultlist"));
		Map_Count = tokenize(temp);
#endif
	}
	if(Map_Count == 0)
		error("empty maplist, cannot select a new map");
	Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);

	Map_Current_Name = strzone(argv(Map_Current)); // will be automatically freed on exit thanks to DP
	// this may or may not be correct, but who cares, in the worst case a map
	// isn't chosen in the first pass that should have been
}

string() GetNextMap =
{
	float nextMap;

	Maplist_Init();
	nextMap = -1;

	if(nextMap == -1)
		if(cvar("g_maplist_shuffle") > 0)
			nextMap = MaplistMethod_Shuffle(cvar("g_maplist_shuffle") + 1);

	if(nextMap == -1)
		if(cvar("g_maplist_selectrandom"))
			nextMap = MaplistMethod_Random();

	if(nextMap == -1)
		nextMap = MaplistMethod_Iterate();

	if(nextMap == -1)
		nextMap = MaplistMethod_Repeat();

	if(nextMap >= 0)
	{
		Map_Goto_SetFloat(nextMap);
		return getmapname_stored;
	}

	return "";
};

float() DoNextMapOverride =
{
	if(cvar("g_campaign"))
	{
		CampaignPostIntermission();
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(cvar("quit_when_empty"))
	{
		if(player_count <= currentbots)
		{
			localcmd("quit\n");
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	}
	if(cvar_string("quit_and_redirect") != "")
	{
		redirection_target = strzone(cvar_string("quit_and_redirect"));
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if (cvar("samelevel")) // if samelevel is set, stay on same level
	{
		// this does not work because it tries to exec maps/nexdm01.mapcfg (which doesn't exist, it should be trying maps/dm_nexdm01.mapcfg for example)
		//localcmd(strcat("exec \"maps/", mapname, ".mapcfg\"\n"));
		// so instead just restart the current map using the restart command (DOES NOT WORK PROPERLY WITH exit_cfg STUFF)
		localcmd("restart\n");
		//changelevel (mapname);
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(cvar_string("nextmap") != "")
#ifdef MAPINFO
		if(MapInfo_CheckMap(cvar_string("nextmap")))
#else
		if(TryFile(strcat("maps/", cvar_string("nextmap"), ".mapcfg")))
#endif
		{
			Map_Goto_SetStr(cvar_string("nextmap"));
			Map_Goto();
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	if(cvar("lastlevel"))
	{
		GameResetCfg();
		localcmd("set lastlevel 0\ntogglemenu\n");
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	return FALSE;
};

void() GotoNextMap =
{
	//local string nextmap;
	//local float n, nummaps;
	//local string s;
	if (alreadychangedlevel)
		return;
	alreadychangedlevel = TRUE;

	{
		string nextMap;
		float allowReset;

		for(allowReset = 1; allowReset >= 0; --allowReset)
		{
			nextMap = GetNextMap();
			if(nextMap != "")
				break;

			if(allowReset)
			{
				bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
#ifdef MAPINFO
				cvar_set("g_maplist", MapInfo_ListAllowedMaps());
				localcmd("\nmenu_cmd sync\n");
#else
				cvar_set("g_maplist", cvar_string("g_maplist_defaultlist"));
#endif
			}
			else
			{
				error("Everything is broken - not even the default map list works. Please report this to the developers.");
			}
		}
		Map_Goto();
	}
};


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
.float autoscreenshot;
void() MapVote_Start;
void() MapVote_Think;
float mapvote_initialized;
void() IntermissionThink =
{
	FixIntermissionClient(self);

	if(cvar("sv_autoscreenshot"))
	if(self.autoscreenshot > 0)
	if(time > self.autoscreenshot)
	{
		self.autoscreenshot = -1;
		if(clienttype(self) == CLIENTTYPE_REAL)
			stuffcmd(self, "\nscreenshot\necho \"^5A screenshot has been taken at request of the server.\"\n");
		return;
	}

	if (time < intermission_exittime)
		return;

	if(!mapvote_initialized)
		if (time < intermission_exittime + 10 && !self.button0 && !self.button2 && !self.button3 && !self.button6 && !self.buttonuse)
			return;

	MapVote_Start();
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
/*
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// then look for the start position
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
		return spot;

	//objerror ("FindIntermission: no spot");
	return world;
};
*/

/*
===============================================================================

RULES

===============================================================================
*/

void(float final) DumpStats =
{
	local float file;
	local string s;
	local float to_console;
	local float to_eventlog;
	local float to_file;

	to_console = cvar("sv_logscores_console");
	to_eventlog = cvar("sv_eventlog");
	to_file = cvar("sv_logscores_file");

	if(!final)
	{
		to_console = TRUE; // always print printstats replies
		to_eventlog = FALSE; // but never print them to the event log
	}

	if(to_eventlog)
		if(cvar("sv_eventlog_console"))
			to_console = FALSE; // otherwise we get the output twice

	if(final)
		s = ":scores:";
	else
		s = ":status:";
#ifdef MAPINFO
	s = strcat(s, GetGametype(), "_", GetMapname(), ":", ftos(rint(time)));
#else
	s = strcat(s, GetMapname(), ":", ftos(rint(time)));
#endif

	if(to_console)
		ServerConsoleEcho(s, FALSE);
	if(to_eventlog)
		GameLogEcho(s, FALSE);
	if(to_file)
	{
		file = fopen(cvar_string("sv_logscores_filename"), FILE_APPEND);
		if(file == -1)
			to_file = FALSE;
		else
			fputs(file, strcat(s, "\n"));
	}

	FOR_EACH_CLIENT(other)
	{
		if ((clienttype(other) == CLIENTTYPE_REAL) || (clienttype(other) == CLIENTTYPE_BOT && cvar("sv_logscores_bots")))
		{
			s = strcat(":player:", ftos(other.frags), ":");
			s = strcat(s, ftos(other.deaths), ":");
			s = strcat(s, ftos(rint(time - other.jointime)), ":");
			s = strcat(s, ftos(other.team), ":");

			if(to_console)
				ServerConsoleEcho(strcat(s, other.netname), TRUE);
			if(to_eventlog)
				GameLogEcho(strcat(s, ftos(other.playerid), ":", other.netname), TRUE);
			if(to_file)
				fputs(file, strcat(s, other.netname, "\n"));
		}
	}

	if(to_console)
		ServerConsoleEcho(":end", FALSE);
	if(to_eventlog)
		GameLogEcho(":end", FALSE);
	if(to_file)
	{
		fputs(file, ":end\n");
		fclose(file);
	}
}

void FixIntermissionClient(entity e)
{
	if(!e.autoscreenshot) // initial call
	{
		e.angles = e.v_angle;
		e.angles_x = -e.angles_x;
		e.autoscreenshot = time + 0.8;	// used for autoscreenshot
		e.health = -2342;
		// first intermission phase; voting phase has positive health (used to decide whether to send SVC_FINALE or not)
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		e.takedamage = DAMAGE_NO;
		if(e.weaponentity)
			e.weaponentity.effects = EF_NODRAW;
		stuffcmd(e, "\nscr_printspeed 1000000\n");
		if(clienttype(e) == CLIENTTYPE_REAL)
		{
			msg_entity = e;
			WriteByte(MSG_ONE, SVC_INTERMISSION);
		}
	}

	//e.velocity = '0 0 0';
	//e.fixangle = TRUE;

	// TODO halt weapon animation
}


/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	float minTotalFrags;
	float maxTotalFrags;
	float score;
	float f;

	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if(player_count > 0)
		intermission_exittime = time + cvar("sv_mapchange_delay");
	else
		intermission_exittime = -1;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	//pos = FindIntermission ();

	VoteReset();

	DumpStats(TRUE);

	if(cvar("sv_eventlog"))
		GameLogEcho(":gameover", FALSE);

	GameLogClose();

	FOR_EACH_CLIENT(other)
	{
		FixIntermissionClient(other);

		if(other.winning)
			bprint(other.netname, " ^7wins.\n");
	}

	minTotalFrags = 0;
	maxTotalFrags = 0;
	FOR_EACH_PLAYER(other)
	{
		if(maxTotalFrags < other.totalfrags)
			maxTotalFrags = other.totalfrags;
		if(minTotalFrags > other.totalfrags)
			minTotalFrags = other.totalfrags;
	}

	if(!currentbots)
	{
		FOR_EACH_PLAYER(other)
		{
			score = (other.totalfrags - minTotalFrags) / max(maxTotalFrags - minTotalFrags, 1);
			f = bound(0, other.play_time / max(time, 1), 1);
			// store some statistics?
		}
	}

	if(cvar("g_campaign"))
		CampaignPreIntermission();

	// WriteByte (MSG_ALL, SVC_INTERMISSION);
};

/*
============
CheckRules_Player

Exit deathmatch games upon conditions
============
*/
void() CheckRules_Player =
{
	if (gameover)	// someone else quit the game already
		return;

	if(self.deadflag == DEAD_NO)
		self.play_time += frametime;

	// fixme: don't check players; instead check spawnfunc_dom_team and spawnfunc_ctf_team entities
	//   (div0: and that in CheckRules_World please)
};

float checkrules_oneminutewarning;
float checkrules_leaderfrags;
float tdm_max_score, tdm_old_score;

float checkrules_equality;
float checkrules_overtimewarning;
float checkrules_overtimeend;

void() InitiateOvertime =
{
	if(!checkrules_overtimeend)
		checkrules_overtimeend = time + 60 * cvar("timelimit_maxovertime");
}

float WINNING_NO = 0; // no winner, but time limits may terminate the game
float WINNING_YES = 1; // winner found
float WINNING_NEVER = 2; // no winner, enter overtime if time limit is reached
float WINNING_STARTOVERTIME = 3; // no winner, enter overtime NOW

float(float fraglimitreached, float equality) GetWinningCode =
{
	if(equality)
		if(fraglimitreached)
			return WINNING_STARTOVERTIME;
		else
			return WINNING_NEVER;
	else
		if(fraglimitreached)
			return WINNING_YES;
		else
			return WINNING_NO;
}

// set the .winning flag for exactly those players with a given field value
void(.float field, float value) SetWinners =
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = (head.field == value);
}

// set the .winning flag for those players with a given field value
void(.float field, float value) AddWinners =
{
	entity head;
	FOR_EACH_PLAYER(head)
		if(head.field == value)
			head.winning = 1;
}

// clear frags for all players but the team given (when they ran out of spawnpoints)
void(.float field, float value) ClearFragsForEveryoneBut =
{
	entity head;
	FOR_EACH_PLAYER(head)
		if(head.field != value)
			head.frags = max(head.frags, 0);
}

// clear the .winning flags
void(void) ClearWinners =
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = 0;
}

// Onslaught winning condition:
// game terminates if only one team has a working generator (or none)
float() WinningCondition_Onslaught =
{
	entity head;
	local float t1, t2, t3, t4;
	// first check if the game has ended
	t1 = t2 = t3 = t4 = 0;
	head = find(world, classname, "onslaught_generator");
	while (head)
	{
		if (head.health > 0)
		{
			if (head.team == COLOR_TEAM1) t1 = 1;
			if (head.team == COLOR_TEAM2) t2 = 1;
			if (head.team == COLOR_TEAM3) t3 = 1;
			if (head.team == COLOR_TEAM4) t4 = 1;
		}
		head = find(head, classname, "onslaught_generator");
	}
	if (t1 + t2 + t3 + t4 < 2)
	{
		// game over, only one team remains (or none)
		ClearWinners();
		if (t1) SetWinners(team, COLOR_TEAM1);
		if (t2) SetWinners(team, COLOR_TEAM2);
		if (t3) SetWinners(team, COLOR_TEAM3);
		if (t4) SetWinners(team, COLOR_TEAM4);
		dprint("Have a winner, ending game.\n");
		return WINNING_YES;
	}

	// Two or more teams remain
	return WINNING_NO;
}

float() LMS_NewPlayerLives =
{
	float fl;
	fl = cvar("fraglimit");
	if(fl == 0)
		fl = 999;

	// first player has left the game for dying too much? Nobody else can get in.
	if(lms_lowest_lives < 1)
		return FALSE;

	if(!cvar("g_lms_join_anytime"))
		if(lms_lowest_lives < fl - cvar("g_lms_last_join"))
			return FALSE;

	return bound(1, lms_lowest_lives, fl);
}

// Assault winning condition: If the attackers triggered a round end (by fulfilling all objectives)
// they win. Otherwise the defending team wins once the timelimit passes.
void assault_new_round();
float() WinningCondition_Assault =
{
	local float status;
	status = WINNING_NO;

	// as the timelimit has not yet passed just assume the defending team will win
	if(assault_attacker_team == COLOR_TEAM1)
	{
		SetWinners(team, COLOR_TEAM2);
	}
	else
	{
		SetWinners(team, COLOR_TEAM1);
	}

	local entity ent;
	ent = find(world, classname, "target_assault_roundend");
	if(ent)
	{
		if(ent.winning)	// round end has been triggered by attacking team
		{
			SetWinners(team, assault_attacker_team);
			if(assault_attacker_team == COLOR_TEAM1)
			{
				team1_score = team1_score + 50;
			}
			else
			{
				team2_score = team2_score + 50;
			}

			if(ent.cnt == 1) // this was the second round
			{
				status = WINNING_YES;
			}
			else
			{
				cvar_set("timelimit", ftos((2*time)/60));
				assault_new_round();
			}
		}
	}

	return status;

}


// LMS winning condition: game terminates if and only if there's at most one
// one player who's living lives. Top two scores being equal cancels the time
// limit.
float() WinningCondition_LMS =
{
	entity head;
	float have_player;
	float have_players;
	float l;

	have_player = FALSE;
	have_players = FALSE;
	l = LMS_NewPlayerLives();

	head = find(world, classname, "player");
	if(head)
		have_player = TRUE;
	head = find(head, classname, "player");
	if(head)
		have_players = TRUE;

	if(have_player)
	{
		// we have at least one player
		if(have_players)
		{
			// two or more active players - continue with the game
		}
		else
		{
			// exactly one player?
			if(l)
			{
				// but no game has taken place yet
			}
			else
			{
				// a winner!
				ClearWinners(); SetWinners(winning, 0); // NOTE: exactly one player is still "player", so this works out
				dprint("Have a winner, ending game.\n");
				return WINNING_YES;
			}
		}
	}
	else
	{
		// nobody is playing at all...
		if(l)
		{
			// wait for players...
		}
		else
		{
			// SNAFU (maybe a draw game?)
			ClearWinners();
			dprint("No players, ending game.\n");
			return WINNING_YES;
		}
	}

	// When we get here, we have at least two players who are actually LIVING,
	// or one player who is still waiting for a victim to join the server. Now
	// check if the top two players have equal score.

	checkrules_leaderfrags = 0;
	checkrules_equality = FALSE;
	FOR_EACH_PLAYER(head)
	{
		if(head.frags > checkrules_leaderfrags)
		{
			checkrules_leaderfrags = head.frags;
			checkrules_equality = FALSE;
		}
		else if(head.frags > 0 && head.frags == checkrules_leaderfrags)
			checkrules_equality = TRUE;
	}

	SetWinners(frags, checkrules_leaderfrags);

	// The top two players have the same amount of lives? No timelimit then,
	// enter overtime...

	if(checkrules_equality)
		return WINNING_NEVER;

	// Top two have different scores? Way to go for our beloved TIMELIMIT!
	return WINNING_NO;
}

// DM winning condition: game terminates if a player reached the fraglimit,
// unless the first two players have the same score. The latter case also
// breaks the time limit.
float(float fraglimit) WinningCondition_MaxIndividualScore =
{
	float checkrules_oldleaderfrags;
	entity head;

	checkrules_oldleaderfrags = checkrules_leaderfrags;
	checkrules_leaderfrags = 0;
	checkrules_equality = FALSE;
	FOR_EACH_PLAYER(head)
	{
		if(head.frags > checkrules_leaderfrags)
		{
			checkrules_leaderfrags = head.frags;
			checkrules_equality = FALSE;
		}
		else if(head.frags > 0 && head.frags == checkrules_leaderfrags)
			checkrules_equality = TRUE;
	}

	if(checkrules_leaderfrags > 0)
		SetWinners(frags, checkrules_leaderfrags);
	else
		ClearWinners();

	if (!g_runematch)
		if (checkrules_leaderfrags != checkrules_oldleaderfrags)
		{
			if (checkrules_leaderfrags == fraglimit - 1)
				sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.wav", 1, ATTN_NONE);
			else if (checkrules_leaderfrags == fraglimit - 2)
				sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.wav", 1, ATTN_NONE);
			else if (checkrules_leaderfrags == fraglimit - 3)
				sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.wav", 1, ATTN_NONE);
		}

	return GetWinningCode(fraglimit && checkrules_leaderfrags >= fraglimit, checkrules_equality);
}

float(float fraglimit) WinningConditionBase_Teamplay =
{
	tdm_old_score = tdm_max_score;
	tdm_max_score = max4(team1_score, team2_score, team3_score, team4_score);

	checkrules_equality =
	(
		(tdm_max_score > 0)
		&&
		(
			  (team1_score == tdm_max_score)
			+ (team2_score == tdm_max_score)
			+ (team3_score == tdm_max_score)
			+ (team4_score == tdm_max_score)
			>= 2));

	ClearWinners();
	if(tdm_max_score > 0)
	{
		if(team1_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM1);
		if(team2_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM2);
		if(team3_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM3);
		if(team4_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM4);
	}

	if(!g_runematch && !g_domination)
		if(tdm_max_score != tdm_old_score)
		{
			if(tdm_max_score == fraglimit - 1)
				sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.wav", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 2)
				sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.wav", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 3)
				sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.wav", 1, ATTN_NONE);
		}

	return GetWinningCode(fraglimit && tdm_max_score >= fraglimit, checkrules_equality);
}

// TDM winning condition: game terminates if a team's score sum reached the
// fraglimit, unless the first two teams have the same total score. The latter
// case also breaks the time limit.
float(float fraglimit) WinningCondition_MaxTeamSum =
{
	entity head;

	team1_score = team2_score = team3_score = team4_score = 0;

	FOR_EACH_PLAYER(head)
	{
		if(head.team == COLOR_TEAM1)
			team1_score += head.frags;
		else if(head.team == COLOR_TEAM2)
			team2_score += head.frags;
		else if(head.team == COLOR_TEAM3)
			team3_score += head.frags;
		else if(head.team == COLOR_TEAM4)
			team4_score += head.frags;
	}

	return WinningConditionBase_Teamplay(fraglimit);
}

// DOM/CTF winning condition: game terminates if the max of a team's players'
// score reached the fraglimit, unless the first two teams have the same
// maximum score. The latter case also breaks the time limit.
float(float fraglimit) WinningCondition_MaxTeamMax =
{
	entity head;

	team1_score = team2_score = team3_score = team4_score = 0;

	FOR_EACH_PLAYER(head)
	{
		if(head.team == COLOR_TEAM1)
		{
			if(head.frags > team1_score)
				team1_score = head.frags;
		}
		else if(head.team == COLOR_TEAM2)
		{
			if(head.frags > team2_score)
				team2_score = head.frags;
		}
		else if(head.team == COLOR_TEAM3)
		{
			if(head.frags > team3_score)
				team3_score = head.frags;
		}
		else if(head.team == COLOR_TEAM4)
		{
			if(head.frags > team4_score)
				team4_score = head.frags;
		}
	}

	return WinningConditionBase_Teamplay(fraglimit);
}

void print_to(entity e, string s)
{
	if(e)
		sprint(e, strcat(s, "\n"));
	else
		ServerConsoleEcho(s, TRUE);
}

void PrintScoreboardFor(entity e, string name, string colorcode, float whichteam)
{
	entity head;
	float v;
	float teamvalue;
	float fragtotal;
	string s;
	float found;
	found = FALSE;
	teamvalue = 0;
	FOR_EACH_PLAYER(head)
	{
		if(!whichteam || head.team == whichteam)
		{
			if(name != "")
				if(!found)
					print_to(e, strcat(" ", colorcode, name, ":"));
			found = TRUE;
			fragtotal = fragtotal + head.frags;
			s = ftos(head.frags);
			s = strcat(s, "/", ftos(head.deaths));
			s = strcat(s, " @ ", ftos(head.ping));
			if(clienttype(head) == CLIENTTYPE_BOT)
				s = strcat(s, "botms");
			else
				s = strcat(s, "ms");
			v = PlayerValue(head);
			teamvalue += v;
			s = strcat(s, " / ", ftos(v));
			print_to(e, strcat("  ", colorcode, head.netname, colorcode, " (", s, ")"));
		}
	}
	if(whichteam && found)
	{
		s = ftos(fragtotal);
		s = strcat(s, " / ", ftos(teamvalue));
		print_to(e, strcat(colorcode, "  (total: ", s, ")"));
	}
}

void PrintScoreboard(entity e)
{
	print_to(e, strcat("Time:      ", ftos(time / 60)));
	print_to(e, strcat("Timelimit: ", ftos(cvar("timelimit"))));
	print_to(e, strcat("Fraglimit: ", ftos(cvar("fraglimit"))));
	print_to(e, "Scoreboard:");
	if(teams_matter)
	{
		PrintScoreboardFor(e, "Red", "^1", COLOR_TEAM1);
		PrintScoreboardFor(e, "Blue", "^4", COLOR_TEAM2);
		PrintScoreboardFor(e, "Yellow", "^3", COLOR_TEAM3);
		PrintScoreboardFor(e, "Pink", "^6", COLOR_TEAM4);
	}
	else
	{
		PrintScoreboardFor(e, "", "^7", 0);
	}
	print_to(e, ".");
}

void ShuffleMaplist()
{
	string result;
	float start;
	float litems;
	float selected;
	float i;

	result = cvar_string("g_maplist");
#ifdef MAPINFO
	litems = tokenizebyseparator(result, " ");
#else
	litems = tokenize(result);
#endif

	for(start = 0; start < litems - 1; ++start)
	{
		result = "";

		// select a random item
		selected = ceil(random() * (litems - start) + start) - 1;

		// shift this item to the place start
#ifdef MAPINFO
		for(i = 0; i < start; ++i)
			result = strcat(result, " ", argv(i));
		result = strcat(result, " ", argv(selected));
		for(i = start; i < litems; ++i)
			if(i != selected)
				result = strcat(result, " ", argv(i));
		result = substring(result, 1, strlen(result) - 1);

		litems = tokenizebyseparator(result, " ");
#else
		for(i = 0; i < start; ++i)
			result = strcat(result, "'", argv(i), "'");
		result = strcat(result, "'", argv(selected), "'");
		for(i = start; i < litems; ++i)
			if(i != selected)
				result = strcat(result, "'", argv(i), "'");

		litems = tokenize(result);
#endif

		//dprint(result, "\n");
	}

	cvar_set("g_maplist", result);
}

float WinningCondition_RanOutOfSpawns()
{
	entity head;

	if(!have_team_spawns)
		return WINNING_NO;

	if(!some_spawn_has_been_used)
		return WINNING_NO;

	team1_score = team2_score = team3_score = team4_score = 0;

	FOR_EACH_PLAYER(head) if(head.deadflag == DEAD_NO)
	{
		if(head.team == COLOR_TEAM1)
			team1_score = 1;
		else if(head.team == COLOR_TEAM2)
			team2_score = 1;
		else if(head.team == COLOR_TEAM3)
			team3_score = 1;
		else if(head.team == COLOR_TEAM4)
			team4_score = 1;
	}

	for(head = world; (head = find(head, classname, "info_player_deathmatch")) != world; )
	{
		if(head.team == COLOR_TEAM1)
			team1_score = 1;
		else if(head.team == COLOR_TEAM2)
			team2_score = 1;
		else if(head.team == COLOR_TEAM3)
			team3_score = 1;
		else if(head.team == COLOR_TEAM4)
			team4_score = 1;
	}

	ClearWinners();
	if(team1_score + team2_score + team3_score + team4_score == 0)
	{
		checkrules_equality = TRUE;
		return WINNING_YES;
	}
	else if(team1_score + team2_score + team3_score + team4_score == 1)
	{
		if(team1_score)
		{
			AddWinners(team, COLOR_TEAM1);
			ClearFragsForEveryoneBut(team, COLOR_TEAM1);
		}
		if(team2_score)
		{
			AddWinners(team, COLOR_TEAM2);
			ClearFragsForEveryoneBut(team, COLOR_TEAM2);
		}
		if(team3_score)
		{
			AddWinners(team, COLOR_TEAM3);
			ClearFragsForEveryoneBut(team, COLOR_TEAM3);
		}
		if(team4_score)
		{
			AddWinners(team, COLOR_TEAM4);
			ClearFragsForEveryoneBut(team, COLOR_TEAM4);
		}
		return WINNING_YES;
	}
	else
		return WINNING_NO;
}

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void() CheckRules_World =
{
	local float status;
	local float timelimit;
	local float fraglimit;

	VoteThink();
	MapVote_Think();

	SetDefaultAlpha();

	/*
	MapVote_Think should now do that part
	if (intermission_running)
		if (time >= intermission_exittime + 60)
		{
			if(!DoNextMapOverride())
				GotoNextMap();
			return;
		}
	*/

	if (gameover)	// someone else quit the game already
	{
		if(player_count == 0) // Nobody there? Then let's go to the next map
			MapVote_Start();
			// this will actually check the player count in the next frame
			// again, but this shouldn't hurt
		return;
	}

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if(checkrules_overtimeend)
	{
		if(!checkrules_overtimewarning)
		{
			checkrules_overtimewarning = TRUE;
			//sound(world, CHAN_AUTO, "announcer/robotic/1minuteremains.wav", 1, ATTN_NONE);
			bcenterprint("^3Now playing ^1OVERTIME^3!\n\n^3Keep fragging until we have a ^1winner^3!");
		}
	}
	else
	{
		if (timelimit && time >= timelimit)
			InitiateOvertime();
	}

	if (checkrules_overtimeend && time >= checkrules_overtimeend)
	{
		NextLevel();
		return;
	}

	if (!checkrules_oneminutewarning && timelimit > 0 && time > timelimit - 60)
	{
		checkrules_oneminutewarning = TRUE;
		sound(world, CHAN_AUTO, "announcer/robotic/1minuteremains.wav", 1, ATTN_NONE);
	}

	status = WinningCondition_RanOutOfSpawns();
	if(status == WINNING_YES)
	{
		bprint("Hey! Someone ran out of spawns!\n");
	}
	else if(g_assault)
	{
		status = WinningCondition_Assault();
	}
	else if(g_lms)
	{
		status = WinningCondition_LMS();
	}
	else if (g_onslaught)
	{
		status = WinningCondition_Onslaught();
	}
	else
	{
		if(teams_matter)
		{
			if(g_tdm || g_runematch || g_ctf || g_domination || g_keyhunt)
				status = WinningCondition_MaxTeamSum(fraglimit);
			//else if()
			//	status = WinningCondition_MaxTeamMax(fraglimit);
			else
			{
				dprint("div0: How can this happen?\n");
				status = WinningCondition_MaxTeamMax(fraglimit);
			}
		}
		else
			status = WinningCondition_MaxIndividualScore(fraglimit);
	}

	if(status == WINNING_STARTOVERTIME)
	{
		status = WINNING_NEVER;
		InitiateOvertime();
	}

	if(status == WINNING_NEVER)
		// equality cases! Nobody wins if the overtime ends in a draw.
		ClearWinners();

	if(checkrules_overtimeend)
		if(status != WINNING_NEVER || time >= checkrules_overtimeend)
			status = WINNING_YES;

	if(status == WINNING_YES)
		NextLevel();
};

float randsel_value;
float randsel_priority;
float randsel_count;
void RandSel_Init()
{
	randsel_value = -1;
	randsel_priority = -1;
	randsel_count = -1;
}
void RandSel_Add(float priority, float value)
{
	if(priority > randsel_priority)
	{
		randsel_priority = priority;
		randsel_value = value;
		randsel_count = 1;
	}
	else if(priority == randsel_priority)
	{
		randsel_count += 1;
		if(ceil(random() * randsel_count) == 1)
			randsel_value = value;
	}
}

float mapvote_nextthink;
float mapvote_initialized;
float mapvote_keeptwotime;
float mapvote_timeout;
string mapvote_message;

#define MAPVOTE_COUNT 10
float mapvote_count;
float mapvote_count_real;
string mapvote_maps[MAPVOTE_COUNT];
float mapvote_maps_suggested[MAPVOTE_COUNT];
string mapvote_suggestions[MAPVOTE_COUNT];
float mapvote_suggestion_ptr;
float mapvote_maxlen;
float mapvote_voters;
float mapvote_votes[MAPVOTE_COUNT];
float mapvote_run;
float mapvote_detail;
float mapvote_abstain;
.float mapvote;

void MapVote_ClearAllVotes()
{
	FOR_EACH_CLIENT(other)
		other.mapvote = 0;
}

string MapVote_Suggest(string m)
{
	float i;
	if(m == "")
		return "That's not how to use this command.";
	if(!cvar("g_maplist_votable_suggestions"))
		return "Suggestions are not accepted on this server.";
	if(mapvote_initialized)
		return "Can't suggest - voting is already in progress!";
#ifdef MAPINFO
	m = MapInfo_FixName(m);
	if(!m)
		return "The map you suggested is not available on this server.";
#else
	if(!cvar("g_maplist_votable_suggestions_change_gametype"))
		if(!IsSameGametype(m))
			return "This server does not allow changing the game type by map suggestions.";
#endif
	if(!cvar("g_maplist_votable_override_mostrecent"))
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

#ifdef MAPINFO
	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
#else
	if(!TryFile(strcat("maps/", m, ".mapcfg")))
		return "The map you suggested is not available on this server.";
#endif
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = ceil(random() * mapvote_suggestion_ptr) - 1;
	}
	else
	{
		i = mapvote_suggestion_ptr;
		mapvote_suggestion_ptr += 1;
	}
	if(mapvote_suggestions[i] != "")
		strunzone(mapvote_suggestions[i]);
	mapvote_suggestions[i] = strzone(m);
	if(cvar("sv_eventlog"))
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)), TRUE);
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j;
	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	if(strlen(nextMap) > mapvote_maxlen)
		mapvote_maxlen = strlen(nextMap);
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;
	mapvote_count += 1;
}

void MapVote_Init()
{
	float i;
	float nmax, smax;

	MapVote_ClearAllVotes();

	mapvote_count = 0;
	mapvote_detail = !cvar("g_maplist_votable_nodetail");
	mapvote_abstain = cvar("g_maplist_votable_abstain");

	if(mapvote_abstain)
		nmax = min(MAPVOTE_COUNT - 1, cvar("g_maplist_votable"));
	else
		nmax = min(MAPVOTE_COUNT, cvar("g_maplist_votable"));
	smax = min(nmax, cvar("g_maplist_votable_suggestions"));

	for(i = 0; i < 100 && mapvote_count < smax; ++i)
		MapVote_AddVotable(mapvote_suggestions[ceil(random() * mapvote_suggestion_ptr) - 1], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
#ifdef MAPINFO
		cvar_set("g_maplist", MapInfo_ListAllowedMaps());
		localcmd("\nmenu_cmd sync\n");
#else
		cvar_set("g_maplist", cvar_string("g_maplist_defaultlist"));
#endif
		for(i = 0; i < 100 && mapvote_count < nmax; ++i)
			MapVote_AddVotable(GetNextMap(), FALSE);
	}

	mapvote_count_real = mapvote_count;
	if(mapvote_abstain)
		MapVote_AddVotable("don't care", 0);

	//dprint("mapvote count is ", ftos(mapvote_count), "\n");

	mapvote_keeptwotime = time + cvar("g_maplist_votable_keeptwotime");
	mapvote_timeout = time + cvar("g_maplist_votable_timeout");
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	mapvote_message = "Choose a map and press its key!";
}
float MapVote_Finished(float mappos)
{
	string result;
	float i;
	float didntvote;

	if(cvar("sv_eventlog"))
	{
		result = strcat(":vote:finished:", mapvote_maps[mappos]);
		result = strcat(result, ":", ftos(mapvote_votes[mappos]), "::");
		didntvote = mapvote_voters;
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				didntvote -= mapvote_votes[i];
				if(i != mappos)
				{
					result = strcat(result, ":", mapvote_maps[i]);
					result = strcat(result, ":", ftos(mapvote_votes[i]));
				}
			}
		result = strcat(result, ":didn't vote:", ftos(didntvote));

		GameLogEcho(result, FALSE);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]), FALSE);
	}

	FOR_EACH_REALCLIENT(other)
		FixClientCvars(other);

	Map_Goto_SetStr(mapvote_maps[mappos]);
	Map_Goto();
	alreadychangedlevel = TRUE;
	return TRUE;
}
void MapVote_CheckRules_1()
{
	float i;

	for(i = 0; i < mapvote_count; ++i) if(mapvote_maps[i] != "")
	{
		//dprint("Map ", ftos(i), ": "); dprint(mapvote_maps[i], "\n");
		mapvote_votes[i] = 0;
	}

	mapvote_voters = 0;
	FOR_EACH_REALCLIENT(other)
	{
		++mapvote_voters;
		if(other.mapvote)
		{
			i = other.mapvote - 1;
			//dprint("Player ", other.netname, " vote = ", ftos(other.mapvote - 1), "\n");
			mapvote_votes[i] = mapvote_votes[i] + 1;
		}
	}
}

float MapVote_CheckRules_2()
{
	float i;
	float firstPlace, secondPlace;
	float firstPlaceVotes, secondPlaceVotes;
	float mapvote_voters_real;
	string result;

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_votes[mapvote_count - 1];

	RandSel_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		RandSel_Add(mapvote_votes[i], i);
	firstPlace = randsel_value;
	firstPlaceVotes = randsel_priority;
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandSel_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		if(i != firstPlace)
			RandSel_Add(mapvote_votes[i], i);
	secondPlace = randsel_value;
	secondPlaceVotes = randsel_priority;
	//dprint("Second place: ", ftos(secondPlace), "\n");
	//dprint("Second place votes: ", ftos(secondPlaceVotes), "\n");

	if(firstPlace == -1)
		error("No first place in map vote... WTF?");

	if(secondPlace == -1 || time > mapvote_timeout || (mapvote_voters_real - firstPlaceVotes) < firstPlaceVotes)
		return MapVote_Finished(firstPlace);

	if(mapvote_keeptwotime)
		if(time > mapvote_keeptwotime || (mapvote_voters_real - firstPlaceVotes - secondPlaceVotes) < secondPlaceVotes)
		{
			float didntvote;
			mapvote_message = "Now decide between the TOP TWO!";
			mapvote_keeptwotime = 0;
			result = strcat(":vote:keeptwo:", mapvote_maps[firstPlace]);
			result = strcat(result, ":", ftos(firstPlaceVotes));
			result = strcat(result, ":", mapvote_maps[secondPlace]);
			result = strcat(result, ":", ftos(secondPlaceVotes), "::");
			didntvote = mapvote_voters;
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
				{
					didntvote -= mapvote_votes[i];
					if(i != firstPlace)
						if(i != secondPlace)
						{
							result = strcat(result, ":", mapvote_maps[i]);
							result = strcat(result, ":", ftos(mapvote_votes[i]));
							if(i < mapvote_count_real)
							{
								strunzone(mapvote_maps[i]);
								mapvote_maps[i] = "";
							}
						}
				}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(cvar("sv_eventlog"))
				GameLogEcho(result, FALSE);
		}

	return FALSE;
}
void MapVote_Tick()
{
	string msgstr;
	string tmp;
	float i;
	float keeptwo;
	float totalvotes;

	keeptwo = mapvote_keeptwotime;
	MapVote_CheckRules_1(); // count
	if(MapVote_CheckRules_2()) // decide
		return;

	totalvotes = 0;
	FOR_EACH_REALCLIENT(other)
	{
		// hide scoreboard again
		if(other.health != 2342)
		{
			other.health = 2342;
			other.impulse = 0;
			if(clienttype(other) == CLIENTTYPE_REAL)
			{
				stuffcmd(other, "\nin_bind 7 1 \"impulse 1\"; in_bind 7 2 \"impulse 2\"; in_bind 7 3 \"impulse 3\"; in_bind 7 4 \"impulse 4\"; in_bind 7 5 \"impulse 5\"; in_bind 7 6 \"impulse 6\"; in_bind 7 7 \"impulse 7\"; in_bind 7 8 \"impulse 8\"; in_bind 7 9 \"impulse 9\"; in_bind 7 0 \"impulse 10\"; in_bind 7 KP_1 \"impulse 1\"; in_bind 7 KP_2 \"impulse 2\"; in_bind 7 KP_3 \"impulse 3\"; in_bind 7 KP_4 \"impulse 4\"; in_bind 7 KP_5 \"impulse 5\"; in_bind 7 KP_6 \"impulse 6\"; in_bind 7 KP_7 \"impulse 7\"; in_bind 7 KP_8 \"impulse 8\"; in_bind 7 KP_9 \"impulse 9\"; in_bind 7 KP_0 \"impulse 10\"; in_bindmap 7 0\n");
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// notify about keep-two
		if(keeptwo != 0 && mapvote_keeptwotime == 0)
			play2(other, "misc/invshot.wav");

		// clear possibly invalid votes
		if(mapvote_maps[other.mapvote - 1] == "")
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if(mapvote_maps[other.impulse - 1] != "")
				other.mapvote = other.impulse;
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count

	FOR_EACH_REALCLIENT(other)
	{
		// display voting screen
		msgstr = "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
		msgstr = substring(msgstr, 0, strlen(msgstr) - mapvote_count);
		if(mapvote_abstain)
			msgstr = substring(msgstr, 1, strlen(msgstr) - 1);
		msgstr = strcat(msgstr, mapvote_message);
		msgstr = strcat(msgstr, "\n\n");
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] == "")
				msgstr = strcat(msgstr, "\n");
			else
			{
				tmp = mapvote_maps[i];
				tmp = strpad(mapvote_maxlen, tmp);
				tmp = strcat(ftos(mod(i + 1, 10)), ": ", tmp);
 				if(mapvote_detail)
 				{
 					tmp = strcat(tmp, " ^2(", ftos(mapvote_votes[i]), " vote");
 					if(mapvote_votes[i] != 1)
 						tmp = strcat(tmp, "s");
 					tmp = strcat(tmp, ")");
 					tmp = strpad(mapvote_maxlen + 15, tmp);
 				}
				if(mapvote_abstain)
					if(i == mapvote_count - 1)
						msgstr = strcat(msgstr, "\n");
				if(other.mapvote == i + 1)
					msgstr = strcat(msgstr, "^3> ", tmp, "\n");
				else
					msgstr = strcat(msgstr, "^7  ", tmp, "\n");
			}

 		msgstr = strcat(msgstr, "\n\n^2", ftos(totalvotes), " vote");
 		if(totalvotes != 1)
 			msgstr = strcat(msgstr, "s");
 		msgstr = strcat(msgstr, " cast");
		i = ceil(mapvote_timeout - time);
 		msgstr = strcat(msgstr, "\n", ftos(i), " second");
		if(i != 1)
			msgstr = strcat(msgstr, "s");
		msgstr = strcat(msgstr, " left");

		centerprint_atprio(other, CENTERPRIO_MAPVOTE, msgstr);
	}
}
void MapVote_Start()
{
	if(mapvote_run)
		return;

#ifdef MAPINFO
	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 1))
#endif
		mapvote_run = TRUE;
}
void MapVote_Think()
{
	if(!mapvote_run)
		return;

	if(alreadychangedlevel)
		return;

	if(time < mapvote_nextthink)
		return;
	//dprint("tick\n");

	mapvote_nextthink = time + 0.5;

	if(!mapvote_initialized)
	{
		mapvote_initialized = TRUE;
		if(DoNextMapOverride())
			return;
		if(!cvar("g_maplist_votable") || player_count <= 0)
		{
			GotoNextMap();
			return;
		}
		MapVote_Init();
	}

	MapVote_Tick();
};

string GotoMap(string m)
{
#ifdef MAPINFO
	if(!MapInfo_CheckMap(m))
#else
	if(!TryFile(strcat("maps/", m, ".mapcfg")))
#endif
		return "The map you chose is not available on this server.";
	cvar_set("nextmap", m);
	cvar_set("timelimit", "-1");
	if(mapvote_initialized || alreadychangedlevel)
	{
		if(DoNextMapOverride())
			return "Map switch initiated.";
		else
			return "Hm... no. For some reason I like THIS map more.";
	}
	else
		return "Map switch will happen after scoreboard.";
}


void EndFrame()
{
	FOR_EACH_REALCLIENT(self)
	{
		if(self.classname == "spectator")
		{
			if(self.enemy.hitsound)
				play2(self, "misc/hit.wav");
		}
		else
		{
			if(self.hitsound)
				play2(self, "misc/hit.wav");
		}
	}
	FOR_EACH_CLIENT(self)
		self.hitsound = FALSE;
}


/*
 * RedirectionThink:
 * returns TRUE if redirecting
 */
float redirection_timeout;
float redirection_nextthink;
float RedirectionThink()
{
	float clients_found;

	if(redirection_target == "")
		return FALSE;

	if(!redirection_timeout)
	{
		cvar_set("sv_public", "-2");
		redirection_timeout = time + 0.6; // this will only try twice... should be able to keep more clients
		if(redirection_target == "self")
			bprint("^3SERVER NOTICE:^7 restarting the server\n");
		else
			bprint("^3SERVER NOTICE:^7 redirecting everyone to ", redirection_target, "\n");
	}

	if(time < redirection_nextthink)
		return TRUE;

	redirection_nextthink = time + 1;

	clients_found = 0;
	FOR_EACH_REALCLIENT(self)
	{
		ServerConsoleEcho(strcat("Redirecting: sending connect command to ", self.netname), FALSE);
		if(redirection_target == "self")
			stuffcmd(self, "\ndisconnect; reconnect\n");
		else
			stuffcmd(self, strcat("\ndisconnect; connect ", redirection_target, "\n"));
		++clients_found;
	}

	ServerConsoleEcho(strcat("Redirecting: ", ftos(clients_found), " clients left."), FALSE);

	if(time > redirection_timeout || clients_found == 0)
		localcmd("\nwait; wait; wait; quit\n");

	return TRUE;
}

void SV_Shutdown()
{
	if(world_initialized)
	{
		world_initialized = 0;
		print("Saving persistent data...\n");
		Ban_SaveBans();
		if(!sv_cheats)
			db_save(ServerProgsDB, "server.db");
		print("done!\n");
		// tell the bot system the game is ending now
		bot_endgame();
	}
	else
	{
		print("NOTE: crashed before even initializing the world, not saving persistent data\n");
	}
}
