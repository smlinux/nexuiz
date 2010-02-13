entity pingplreport;
void PingPLReport_Think()
{
	float delta;
	entity e;

	delta = 3 / maxclients;
	if(delta < sys_frametime)
		delta = 0;
	self.nextthink = time + delta;

	e = edict_num(self.cnt + 1);
	if(clienttype(e) == CLIENTTYPE_REAL)
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, max(1, e.ping));
		WriteByte(MSG_BROADCAST, ceil(e.ping_packetloss * 255));
		WriteByte(MSG_BROADCAST, ceil(e.ping_movementloss * 255));
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
	}
	self.cnt = mod(self.cnt + 1, maxclients);
}
void PingPLReport_Spawn()
{
	pingplreport = spawn();
	pingplreport.classname = "pingplreport";
	pingplreport.think = PingPLReport_Think;
	pingplreport.nextthink = time;
}

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
		if(default_player_alpha == 0)
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

	world.cnt = -10;
	world.enemy = world;
	world.enemy.cnt += 10;
	if(world.cnt > 0.2 || world.cnt < -0.2) // don't error out if it's just roundoff errors
		dprint("*** fteqcc test: found += bug\n");
	else
		dprint("*** fteqcc test: += bug got FINALLY FIXED! HOORAY!\n");
	world.cnt = 0;
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
			//reset all the flood variables
			FOR_EACH_CLIENT(plr) {
				plr.nickspamcount = plr.nickspamtime = plr.floodcontrol_chat = plr.floodcontrol_chatteam = plr.floodcontrol_chattell = plr.floodcontrol_voice = plr.floodcontrol_voiceteam = 0;
			}
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
				Announce("prepareforbattle");
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

void GotoFirstMap()
{
	float n;
	if(cvar("_sv_init"))
	{
		// cvar_set("_sv_init", "0");
		// we do NOT set this to 0 any more, so someone "accidentally" changing
		// to this "init" map on a dedicated server will cause no permanent
		// harm
		if(cvar("g_maplist_shuffle"))
			ShuffleMaplist();
		n = tokenizebyseparator(cvar_string("g_maplist"), " ");
		cvar_set("g_maplist_index", ftos(n - 1)); // jump to map 0 in GotoNextMap

		MapInfo_Enumerate();
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);

		if(!DoNextMapOverride())
			GotoNextMap();

		return;
	}

	if(time < 5)
	{
		self.nextthink = time;
	}
	else
	{
		self.nextthink = time + 1;
		print("Waiting for _sv_init being set to 1 by initialization scripts...\n");
	}
}

void cvar_changes_init()
{
	float h;
	string k, v, d;
	float n, i;

	if(cvar_changes)
		strunzone(cvar_changes);
	cvar_changes = string_null;

	h = buf_create();
	buf_cvarlist(h, "", "_"); // exclude all _ cvars as they are temporary
	n = buf_getsize(h);

	for(i = 0; i < n; ++i)
	{
		k = bufstr_get(h, i);

#define BADPREFIX(p) if(substring(k, 0, strlen(p)) == p) continue
#define BADCVAR(p) if(k == p) continue
		// internal
		BADPREFIX("csqc_");
		BADPREFIX("cvar_check_");
		BADCVAR("gamecfg");
		BADCVAR("g_configversion");
		BADCVAR("g_maplist_index");
		BADCVAR("halflifebsp");

		// client
		BADPREFIX("cl_");
		BADPREFIX("con_");
		BADPREFIX("g_campaign");
		BADPREFIX("gl_");
		BADPREFIX("joy");
		BADPREFIX("menu_");
		BADPREFIX("net_slist_");
		BADPREFIX("r_");
		BADPREFIX("sbar_");
		BADPREFIX("scr_");
		BADPREFIX("userbind");
		BADPREFIX("v_");
		BADPREFIX("vid_");
		BADPREFIX("crosshair");
		BADCVAR("mod_q3bsp_lightmapmergepower");
		BADCVAR("mod_q3bsp_nolightmaps");

		// private
		BADCVAR("serverconfig");
		BADPREFIX("g_ban_");
		BADPREFIX("g_chat_flood_");
		BADPREFIX("g_voice_flood_");
		BADPREFIX("rcon_");
		BADPREFIX("settemp_");
		BADPREFIX("sv_allowdownloads_");
		BADPREFIX("sv_autodemo");
		BADPREFIX("sv_curl_");
		BADPREFIX("sv_eventlog");
		BADPREFIX("sv_logscores_");
		BADPREFIX("sv_master");
		BADCVAR("g_banned_list");
		BADCVAR("log_dest_udp");
		BADCVAR("log_file");
		BADCVAR("net_address");
		BADCVAR("port");
		BADCVAR("savedgamecfg");
		BADCVAR("sv_heartbeatperiod");
		BADCVAR("sv_vote_master_password");
		BADCVAR("sys_colortranslation");
		BADCVAR("sys_specialcharactertranslation");
		BADCVAR("timestamps");

		// mapinfo
		BADCVAR("timelimit");
		BADCVAR("fraglimit");
		BADCVAR("g_arena");
		BADCVAR("g_ca");
		BADCVAR("g_assault");
		BADCVAR("g_ctf");
		BADCVAR("g_dm");
		BADCVAR("g_domination");
		BADCVAR("g_keyhunt");
		BADCVAR("g_keyhunt_teams");
		BADCVAR("g_onslaught");
		BADCVAR("g_race");
		BADCVAR("g_cts");
		BADCVAR("g_runematch");
		BADCVAR("g_tdm");
		BADCVAR("g_nexball");
		BADCVAR("teamplay");

		// long
		BADCVAR("hostname");
		BADCVAR("g_maplist");
		BADCVAR("g_maplist_mostrecent");
		BADCVAR("sv_motd");
#undef BADPREFIX
#undef BADCVAR

		v = cvar_string(k);
		d = cvar_defstring(k);
		if(v != d)
		{
			cvar_changes = strcat(cvar_changes, k, " \"", v, "\" // \"", d, "\"\n");
			if(strlen(cvar_changes) > 16384)
			{
				cvar_changes = "// too many settings have been changed to show them here\n";
				break;
			}
		}
	}
	buf_del(h);
	if(cvar_changes == "")
		cvar_changes = "// this server runs at default settings\n";
	else
		cvar_changes = strcat("// this server runs at modified settings:\n", cvar_changes);
	cvar_changes = strzone(cvar_changes);
}

void detect_maptype()
{
#if 0
	vector o, v;
	float i;

	for(;;)
	{
		o = world.mins;
		o_x += random() * (world.maxs_x - world.mins_x);
		o_y += random() * (world.maxs_y - world.mins_y);
		o_z += random() * (world.maxs_z - world.mins_z);

		tracebox(o, PL_MIN, PL_MAX, o - '0 0 32768', MOVE_WORLDONLY, world);
		if(trace_fraction == 1)
			continue;

		v = trace_endpos;

		for(i = 0; i < 64; i += 4)
		{
			tracebox(o, '-1 -1 -1' * i, '1 1 1' * i, o - '0 0 32768', MOVE_WORLDONLY, world);
	if(trace_fraction == 1)
		continue;
			print(ftos(i), " -> ", vtos(trace_endpos), "\n");
		}

		break;
	}
#endif
}

entity randomseed;
float RandomSeed_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RANDOMSEED);
	WriteShort(MSG_ENTITY, self.cnt);
	return TRUE;
}
void RandomSeed_Think()
{
	self.cnt = bound(0, floor(random() * 65536), 65535);
	self.nextthink = time + 5;

	self.SendFlags |= 1;
}
void RandomSeed_Spawn()
{
	randomseed = spawn();
	randomseed.think = RandomSeed_Think;
	Net_LinkEntity(randomseed, FALSE, 0, RandomSeed_Send);

	entity oldself;
	oldself = self;
	self = randomseed;
	self.think(); // sets random seed and nextthink
	self = oldself;
}

void spawnfunc___init_dedicated_server(void)
{
	// handler for _init/_init map (only for dedicated server initialization)

	world_initialized = -1; // don't complain
	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	remove = remove_unsafely;

	entity e;
	e = spawn();
	e.think = GotoFirstMap;
	e.nextthink = time; // this is usually 1 at this point

	e = spawn();
	e.classname = "info_player_deathmatch"; // safeguard against player joining

	self.classname = "worldspawn"; // safeguard against various stuff ;)

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
}

void Map_MarkAsRecent(string m);
float world_already_spawned;
void RegisterWeapons();
void Nagger_Init();
void ClientInit_Spawn();
void WeaponStats_Init();
void WeaponStats_Shutdown();
void spawnfunc_worldspawn (void)
{
	float fd, l, i, j, n;
	string s, col;

	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = TRUE;

	remove = remove_safely; // during spawning, watch what you remove!

	check_unacceptable_compiler_bugs();

	compressShortVector_init();

	local entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		++maxclients;
		head = nextent(head);
	}

	// needs to be done so early as they would still spawn
	RegisterWeapons();

	ServerProgsDB = db_load("server.db");

	TemporaryDB = db_create();

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

	if(cvar("g_campaign"))
		CampaignPreInit();

	Map_MarkAsRecent(mapname);

	precache_model ("null"); // we need this one before InitGameplayMode
	InitGameplayMode();
	readlevelcvars();
	GrappleHookInit();

	player_count = 0;
	bot_waypoints_for_items = cvar("g_waypoints_for_items");
	if(bot_waypoints_for_items == 1)
		if(self.spawnflags & SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS)
			bot_waypoints_for_items = 0;

	// for setting by mapinfo
	q3acompat_machineshotgunswap = cvar("sv_q3acompat_machineshotgunswap");
	cvar_set("sv_q3acompat_machineshotgunswap", "0");

	precache();

	WaypointSprite_Init();

	//if (g_domination)
	//	dom_init();

	GameLogInit(); // prepare everything
	if(cvar("sv_eventlog"))
	{
		s = strcat(cvar_string("sv_eventlog_files_counter"), ".");
		s = strcat(s, ftos(random()));
		matchid = strzone(s);

		GameLogEcho(strcat(":gamestart:", GetGametype(), "_", GetMapname(), ":", s));
		s = ":gameinfo:mutators:LIST";
		if(cvar("g_grappling_hook"))
			s = strcat(s, ":grappling_hook");
		if(!cvar("g_use_ammunition"))
			s = strcat(s, ":no_use_ammunition");
		if(!cvar("g_pickup_items"))
			s = strcat(s, ":no_pickup_items");
		if(cvar_string("g_weaponarena") != "0")
			s = strcat(s, ":", cvar_string("g_weaponarena"), " arena");
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
		GameLogEcho(s);
		GameLogEcho(":gameinfo:end");
	}
	else
		matchid = strzone(ftos(random()));

	cvar_set("nextmap", "");

	SetDefaultAlpha();

	if(cvar("g_campaign"))
		CampaignPostInit();

	fteqcc_testbugs();

	Ban_LoadBans();

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);

	if(whichpack(strcat("maps/", mapname, ".cfg")) != "")
	{
		fd = fopen(strcat("maps/", mapname, ".cfg"), FILE_READ);
		if(fd != -1)
		{
			while((s = fgets(fd)))
			{
				l = tokenize_console(s);
				if(l < 2)
					continue;
				if(argv(0) == "cd")
				{
					print("Found ^1DEPRECATED^7 cd loop command in .cfg file; put this line in mapinfo instead:\n");
					print("  cdtrack ", argv(2), "\n");
				}
				else if(argv(0) == "fog")
				{
					print("Found ^1DEPRECATED^7 fog command in .cfg file; put this line in worldspawn in the .map/.bsp/.ent file instead:\n");
					print("  \"fog\" \"", s, "\"\n");
				}
				else if(argv(0) == "set")
				{
					print("Found ^1DEPRECATED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(1), " ", argv(2), "\n");
				}
				else if(argv(0) != "//")
				{
					print("Found ^1DEPRECATED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(0), " ", argv(1), "\n");
				}
			}
			fclose(fd);
		}
	}

	WeaponStats_Init();

	addstat(STAT_WEAPONS, AS_INT, weapons);
	addstat(STAT_SWITCHWEAPON, AS_INT, switchweapon);
	addstat(STAT_GAMESTARTTIME, AS_FLOAT, stat_game_starttime);
	addstat(STAT_ALLOW_OLDNEXBEAM, AS_INT, stat_allow_oldnexbeam);
	Nagger_Init();

	addstat(STAT_STRENGTH_FINISHED, AS_FLOAT, strength_finished);
	addstat(STAT_INVINCIBLE_FINISHED, AS_FLOAT, invincible_finished);
	addstat(STAT_PRESSED_KEYS, AS_FLOAT, pressedkeys);
	addstat(STAT_FUEL, AS_INT, ammo_fuel);
	addstat(STAT_DAMAGE_HITS, AS_INT, stat_hit);
	addstat(STAT_DAMAGE_FIRED, AS_INT, stat_fired);
	addstat(STAT_SHOTORG, AS_INT, stat_shotorg);
	addstat(STAT_LEADLIMIT, AS_FLOAT, stat_leadlimit);
	addstat(STAT_BULLETS_LOADED, AS_INT, campingrifle_bulletcounter);

	next_pingtime = time + 5;
	InitializeEntity(self, cvar_changes_init, INITPRIO_CVARS);

	detect_maptype();

	lsmaps_reply = "^7Maps available: ";
	lsnewmaps_reply = "^7Maps without a record set: ";
	for(i = 0, j = 0; i < MapInfo_count; ++i)
	{
		if(MapInfo_Get_ByID(i))
			if not(MapInfo_Map_flags & (MAPINFO_FLAG_HIDDEN | MAPINFO_FLAG_FORBIDDEN))
			{
				if(mod(i, 2))
					col = "^2";
				else
					col = "^3";
				++j;
				lsmaps_reply = strcat(lsmaps_reply, col, MapInfo_Map_bspname, " ");
				if(g_race && !stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, RACE_RECORD, "time"))))
					lsnewmaps_reply = strcat(lsnewmaps_reply, col, MapInfo_Map_bspname, " ");
				else if(g_cts && !stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, CTS_RECORD, "time"))))
					lsnewmaps_reply = strcat(lsnewmaps_reply, col, MapInfo_Map_bspname, " ");
			}
	}
	lsmaps_reply = strzone(strcat(lsmaps_reply, "\n"));
	if (!g_race && !g_cts)
		lsnewmaps_reply = "Need to be playing race or CTS for lsnewmaps to work.";
	lsnewmaps_reply = strzone(strcat(lsnewmaps_reply, "\n"));

	maplist_reply = "^7Maps in list: ";
	n = tokenize_console(cvar_string("g_maplist"));
	for(i = 0, j = 0; i < n; ++i)
	{
		if(MapInfo_CheckMap(argv(i)))
		{
			if(mod(j, 2))
				col = "^2";
			else
				col = "^3";
			maplist_reply = strcat(maplist_reply, col, argv(i), " ");
			++j;
		}
	}
	maplist_reply = strzone(strcat(maplist_reply, "\n"));
	MapInfo_ClearTemps();

	for(i = 0; i < 10; ++i)
	{
		records_reply[i] = strzone(getrecords(i));
	}

	rankings_reply = strzone(getrankings());

	ClientInit_Spawn();
	RandomSeed_Spawn();
	PingPLReport_Spawn();

	CheatInit();

	localcmd("\n_sv_hook_gamestart ", GetGametype(), ";");

	world_initialized = 1;
}

void spawnfunc_light (void)
{
	//makestatic (self); // Who the f___ did that?
	remove(self);
}

float TryFile( string pFilename )
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
	return GametypeNameFromType(game);
}

string getmapname_stored;
string GetMapname()
{
	return mapname;
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
	return strcat("maps/", argv(position), ".bsp");
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
	cvar_set("g_maplist_mostrecent", strwords(strcat(m, " ", cvar_string("g_maplist_mostrecent")), max(0, cvar("g_maplist_mostrecent_count"))));
}

float Map_IsRecent(string m)
{
	return strhasword(cvar_string("g_maplist_mostrecent"), m);
}

float Map_Check(float position, float pass)
{
	string filename;
	string map_next;
	map_next = argv(position);
	if(pass <= 1)
	{
		if(Map_IsRecent(map_next))
			return 0;
	}
	filename = Map_Filename(position);
	if(MapInfo_CheckMap(map_next))
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

void Map_Goto_SetStr(string nextmapname)
{
	if(getmapname_stored != "")
		strunzone(getmapname_stored);
	if(nextmapname == "")
		getmapname_stored = "";
	else
		getmapname_stored = strzone(nextmapname);
}

void Map_Goto_SetFloat(float position)
{
	cvar_set("g_maplist_index", ftos(position));
	Map_Goto_SetStr(argv(position));
}

void GameResetCfg()
{
	// settings persist, except...
	localcmd("\nsettemp_restore\n");
};

void Map_Goto()
{
	GameResetCfg();
	MapInfo_LoadMap(getmapname_stored);
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
		mapindex = mod(Map_Current + floor(random() * (Map_Count - 1) + 1), Map_Count); // any OTHER map
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
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, " ", argv(j));
		newlist = strcat(newlist, " ", argv(0));       // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, " ", argv(j));
		newlist = substring(newlist, 1, strlen(newlist) - 1);
		cvar_set("g_maplist", newlist);
		Map_Count = tokenizebyseparator(cvar_string("g_maplist"), " ");

		// NOTE: the selected map has just been inserted at (insertpos-1)th position
		Map_Current = insertpos - 1; // this is not really valid, but this way the fallback has a chance of working
		if(Map_Check(Map_Current, 1))
			return Map_Current;
	}
	return -1;
}

void Maplist_Init()
{
	Map_Count = tokenizebyseparator(cvar_string("g_maplist"), " ");
	if(Map_Count == 0)
	{
		bprint( "Maplist is empty!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(cvar("g_maplist_shuffle"))
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		Map_Count = tokenizebyseparator(cvar_string("g_maplist"), " ");
	}
	if(Map_Count == 0)
		error("empty maplist, cannot select a new map");
	Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);

	if(Map_Current_Name)
		strunzone(Map_Current_Name);
	Map_Current_Name = strzone(argv(Map_Current)); // will be automatically freed on exit thanks to DP
	// this may or may not be correct, but who cares, in the worst case a map
	// isn't chosen in the first pass that should have been
}

string GetNextMap()
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

float DoNextMapOverride()
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
		if(MapInfo_CheckMap(cvar_string("nextmap")))
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

void GotoNextMap()
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
				cvar_set("g_maplist", MapInfo_ListAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
				if(cvar("g_maplist_shuffle"))
					ShuffleMaplist();
				localcmd("\nmenu_cmd sync\n");
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
void IntermissionThink()
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
		if (time < intermission_exittime + 10 && !self.BUTTON_ATCK && !self.BUTTON_JUMP && !self.BUTTON_ATCK2 && !self.BUTTON_HOOK && !self.BUTTON_USE)
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
entity FindIntermission()
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

void DumpStats(float final)
{
	local float file;
	local string s;
	local float to_console;
	local float to_eventlog;
	local float to_file;
	local float i;

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
	s = strcat(s, GetGametype(), "_", GetMapname(), ":", ftos(rint(time)));

	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);
	if(to_file)
	{
		file = fopen(cvar_string("sv_logscores_filename"), FILE_APPEND);
		if(file == -1)
			to_file = FALSE;
		else
			fputs(file, strcat(s, "\n"));
	}

	s = strcat(":labels:player:", GetPlayerScoreString(world, 0));
	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);
	if(to_file)
		fputs(file, strcat(s, "\n"));

	FOR_EACH_CLIENT(other)
	{
		if ((clienttype(other) == CLIENTTYPE_REAL) || (clienttype(other) == CLIENTTYPE_BOT && cvar("sv_logscores_bots")))
		{
			s = strcat(":player:see-labels:", GetPlayerScoreString(other, 0), ":");
			s = strcat(s, ftos(rint(time - other.jointime)), ":");
			if(other.classname == "player" || g_arena || g_ca || g_lms)
				s = strcat(s, ftos(other.team), ":");
			else
				s = strcat(s, "spectator:");

			if(to_console)
				print(s, other.netname, "\n");
			if(to_eventlog)
				GameLogEcho(strcat(s, ftos(other.playerid), ":", other.netname));
			if(to_file)
				fputs(file, strcat(s, other.netname, "\n"));
		}
	}

	if(teams_matter)
	{
		s = strcat(":labels:teamscores:", GetTeamScoreString(0, 0));
		if(to_console)
			print(s, "\n");
		if(to_eventlog)
			GameLogEcho(s);
		if(to_file)
			fputs(file, strcat(s, "\n"));

		for(i = 1; i < 16; ++i)
		{
			s = strcat(":teamscores:see-labels:", GetTeamScoreString(i, 0));
			s = strcat(s, ":", ftos(i));
			if(to_console)
				print(s, "\n");
			if(to_eventlog)
				GameLogEcho(s);
			if(to_file)
				fputs(file, strcat(s, "\n"));
		}
	}

	if(to_console)
		print(":end\n");
	if(to_eventlog)
		GameLogEcho(":end");
	if(to_file)
	{
		fputs(file, ":end\n");
		fclose(file);
	}
}

void FixIntermissionClient(entity e)
{
	string s;
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
		{
			e.weaponentity.effects = EF_NODRAW;
			if (e.weaponentity.weaponentity)
				e.weaponentity.weaponentity.effects = EF_NODRAW;
		}
		if(clienttype(e) == CLIENTTYPE_REAL)
		{
			stuffcmd(e, "\nscr_printspeed 1000000\n");
			s = cvar_string("sv_intermission_cdtrack");
			if(s != "")
				stuffcmd(e, strcat("\ncd loop ", s, "\n"));
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
void NextLevel()
{
	float i;

	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if(player_count > 0)
		intermission_exittime = time + cvar("sv_mapchange_delay");
	else
		intermission_exittime = -1;

	/*
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	// done in FixIntermission
	*/

	//pos = FindIntermission ();

	VoteReset();

	DumpStats(TRUE);

	if(cvar("sv_eventlog"))
		GameLogEcho(":gameover");

	GameLogClose();

// TO DO

// save the stats to a text file on the client
// stuffcmd(other, log_stats "stats/file_name");
// bprint stats
// stuffcmd(other, log_stats "");
// use a filename similar to the demo name
	// string file_name;
	// file_name = strcat("\nlog_file \"stats/", strftime(TRUE, "%Y-%m-%d_%H-%M"), "_", mapname, ".txt\"");  // open the log file

// write a stats parser for the menu

	if(cvar("sv_accuracy_data_send")) {
		string stats_to_send;

		FOR_EACH_CLIENT(other) {  // make the string to send
			FixIntermissionClient(other);

			if(other.cvar_cl_accuracy_data_share) {
				stats_to_send = strcat(stats_to_send, ":hits:", other.netname);

				for(i = WEP_FIRST; i <= WEP_LAST; ++i)
					stats_to_send = strcat(stats_to_send, ":", ftos(other.stats_hit[i-1]));

				stats_to_send = strcat(stats_to_send, "\n:fired:", other.netname);

				for(i = WEP_FIRST; i <= WEP_LAST; ++i)
					stats_to_send = strcat(stats_to_send, ":", ftos(other.stats_fired[i-1]));

				stats_to_send = strcat(stats_to_send, "\n");
			}
		}

		FOR_EACH_REALCLIENT(other) {  // only spam humans
			Score_NicePrint(other);  // print the score

			if(other.cvar_cl_accuracy_data_receive)  // send the stats string to all the willing clients
				bprint(stats_to_send);
		}
	} else { // ye olde message
		FOR_EACH_PLAYER(other) {
			FixIntermissionClient(other);

			if(other.winning)
				bprint(other.netname, " ^7wins.\n");
		}
	}

	if(cvar("g_campaign"))
		CampaignPreIntermission();

	localcmd("\nsv_hook_gameend;");
}

/*
============
CheckRules_Player

Exit deathmatch games upon conditions
============
*/
void CheckRules_Player()
{
	if (gameover)	// someone else quit the game already
		return;

	if(self.deadflag == DEAD_NO)
		self.play_time += frametime;

	// fixme: don't check players; instead check spawnfunc_dom_team and spawnfunc_ctf_team entities
	//   (div0: and that in CheckRules_World please)
};

float checkrules_equality;
float checkrules_suddendeathwarning;
float checkrules_suddendeathend;
float checkrules_overtimesadded; //how many overtimes have been already added

float WINNING_NO = 0; // no winner, but time limits may terminate the game
float WINNING_YES = 1; // winner found
float WINNING_NEVER = 2; // no winner, enter overtime if time limit is reached
float WINNING_STARTSUDDENDEATHOVERTIME = 3; // no winner, enter suddendeath overtime NOW

float InitiateSuddenDeath()
{
	// Check first whether normal overtimes could be added before initiating suddendeath mode
	// - for this timelimit_overtime needs to be >0 of course
	// - also check the winning condition calculated in the previous frame and only add normal overtime
	//   again, if at the point at which timelimit would be extended again, still no winner was found
	if ((checkrules_overtimesadded >= 0) && (checkrules_overtimesadded < cvar("timelimit_overtimes")) && cvar("timelimit_overtime") && !(g_race && !g_race_qualifying))
	{
		return 1; // need to call InitiateOvertime later
	}
	else
	{
		if(!checkrules_suddendeathend)
		{
			checkrules_suddendeathend = time + 60 * cvar("timelimit_suddendeath");
			if(g_race && !g_race_qualifying)
				race_StartCompleting();
		}
		return 0;
	}
}

void InitiateOvertime() // ONLY call this if InitiateSuddenDeath returned true
{
	++checkrules_overtimesadded;
	//add one more overtime by simply extending the timelimit
	float tl;
	tl = cvar("timelimit");
	tl += cvar("timelimit_overtime");
	cvar_set("timelimit", ftos(tl));
	string minutesPlural;
	if (cvar("timelimit_overtime") == 1)
		minutesPlural = " ^3minute";
	else
		minutesPlural = " ^3minutes";

	bcenterprint(
		strcat(
			"^3Now playing ^1OVERTIME^3!\n\n^3Added ^1",
			ftos(cvar("timelimit_overtime")),
			minutesPlural,
			" to the game!"
		)
	);
}

float GetWinningCode(float fraglimitreached, float equality)
{
	if(equality)
		if(fraglimitreached)
			return WINNING_STARTSUDDENDEATHOVERTIME;
		else
			return WINNING_NEVER;
	else
		if(fraglimitreached)
			return WINNING_YES;
		else
			return WINNING_NO;
}

// set the .winning flag for exactly those players with a given field value
void SetWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = (head.field == value);
}

// set the .winning flag for those players with a given field value
void AddWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		if(head.field == value)
			head.winning = 1;
}

// clear the .winning flags
void ClearWinners(void)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = 0;
}

// Onslaught winning condition:
// game terminates if only one team has a working generator (or none)
float WinningCondition_Onslaught()
{
	entity head;
	local float t1, t2, t3, t4;

	WinningConditionHelper(); // set worldstatus

	if(inWarmupStage)
		return WINNING_NO;

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

float LMS_NewPlayerLives()
{
	float fl;
	fl = cvar("fraglimit");
	if(fl == 0)
		fl = 999;

	// first player has left the game for dying too much? Nobody else can get in.
	if(lms_lowest_lives < 1)
		return 0;

	if(!cvar("g_lms_join_anytime"))
		if(lms_lowest_lives < fl - cvar("g_lms_last_join"))
			return 0;

	return bound(1, lms_lowest_lives, fl);
}

// Assault winning condition: If the attackers triggered a round end (by fulfilling all objectives)
// they win. Otherwise the defending team wins once the timelimit passes.
void assault_new_round();
float WinningCondition_Assault()
{
	local float status;

	WinningConditionHelper(); // set worldstatus

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
			bprint("ASSAULT: round completed...\n");
			SetWinners(team, assault_attacker_team);

			TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 666 - TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 0));

			if(ent.cnt == 1) // this was the second round
			{
				status = WINNING_YES;
			}
			else
			{
				local entity oldself;
				oldself = self;
				self = ent;
				assault_new_round();
				self = oldself;
			}
		}
	}

	return status;
}

// LMS winning condition: game terminates if and only if there's at most one
// one player who's living lives. Top two scores being equal cancels the time
// limit.
float WinningCondition_LMS()
{
	entity head, head2;
	float have_player;
	float have_players;
	float l;

	have_player = FALSE;
	have_players = FALSE;
	l = LMS_NewPlayerLives();

	head = find(world, classname, "player");
	if(head)
		have_player = TRUE;
	head2 = find(head, classname, "player");
	if(head2)
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

			ClearWinners();
			SetWinners(winning, 0); // NOTE: exactly one player is still "player", so this works out

			if(l)
			{
				// game still running (that is, nobody got removed from the game by a frag yet)? then continue
				return WINNING_NO;
			}
			else
			{
				// a winner!
				// and assign him his first place
				PlayerScore_Add(head, SP_LMS_RANK, 1);
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
	// now check if the top two players have equal score.
	WinningConditionHelper();

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = TRUE;
	if(WinningConditionHelper_topscore == WinningConditionHelper_secondscore)
		return WINNING_NEVER;

	// Top two have different scores? Way to go for our beloved TIMELIMIT!
	return WINNING_NO;
}

void ShuffleMaplist()
{
	cvar_set("g_maplist", shufflewords(cvar_string("g_maplist")));
}

float leaderfrags;
float WinningCondition_Scores(float limit, float leadlimit)
{
	// TODO make everything use THIS winning condition (except LMS)
	WinningConditionHelper();

	if(teams_matter)
	{
		team1_score = TeamScore_GetCompareValue(COLOR_TEAM1);
		team2_score = TeamScore_GetCompareValue(COLOR_TEAM2);
		team3_score = TeamScore_GetCompareValue(COLOR_TEAM3);
		team4_score = TeamScore_GetCompareValue(COLOR_TEAM4);
	}

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = 1;
	if(WinningConditionHelper_winnerteam >= 0)
		SetWinners(team, WinningConditionHelper_winnerteam);

	if(WinningConditionHelper_lowerisbetter)
	{
		WinningConditionHelper_topscore = -WinningConditionHelper_topscore;
		WinningConditionHelper_secondscore = -WinningConditionHelper_secondscore;
		limit = -limit;
	}

	if(WinningConditionHelper_zeroisworst)
		leadlimit = 0; // not supported in this mode

	if(g_dm || g_tdm || g_arena || g_ca || (g_race && !g_race_qualifying) || g_nexball)
	// these modes always score in increments of 1, thus this makes sense
	{
		if(leaderfrags != WinningConditionHelper_topscore)
		{
			leaderfrags = WinningConditionHelper_topscore;

			if (limit)
			if (leaderfrags == limit - 1)
				Announce("1fragleft");
			else if (leaderfrags == limit - 2)
				Announce("2fragsleft");
			else if (leaderfrags == limit - 3)
				Announce("3fragsleft");
		}
	}

	return GetWinningCode(
		WinningConditionHelper_topscore &&
		(
			(limit && (WinningConditionHelper_topscore >= limit))
			||
			(leadlimit && (WinningConditionHelper_topscore - WinningConditionHelper_secondscore >= leadlimit))
		),
		WinningConditionHelper_equality
	);
}

float WinningCondition_Race(float fraglimit)
{
	float wc;
	entity p;
	float n, c;

	n = 0;
	c = 0;
	FOR_EACH_PLAYER(p)
	{
		++n;
		if(p.race_completed)
			++c;
	}
	if(n && (n == c))
		return WINNING_YES;
	wc = WinningCondition_Scores(fraglimit, 0);

	// ALWAYS initiate overtime, unless EVERYONE has finished the race!
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	// do NOT support equality when the laps are all raced!
		return WINNING_STARTSUDDENDEATHOVERTIME;
	else
		return WINNING_NEVER;
	return wc;
}

void ReadyRestart();
float WinningCondition_QualifyingThenRace(float limit)
{
	float wc;
	wc = WinningCondition_Scores(limit, 0);

	// NEVER initiate overtime
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		return WINNING_YES;
	}

	return wc;
}

float WinningCondition_RanOutOfSpawns()
{
	entity head;

	if(have_team_spawns <= 0)
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
		float t, i;
		if(team1_score) t = COLOR_TEAM1;
		if(team2_score) t = COLOR_TEAM2;
		if(team3_score) t = COLOR_TEAM3;
		if(team4_score) t = COLOR_TEAM4;
		CheckAllowedTeams(world);
		for(i = 0; i < MAX_TEAMSCORE; ++i)
		{
			if(t != COLOR_TEAM1) if(c1 >= 0) TeamScore_AddToTeam(COLOR_TEAM1, i, -1000);
			if(t != COLOR_TEAM2) if(c2 >= 0) TeamScore_AddToTeam(COLOR_TEAM2, i, -1000);
			if(t != COLOR_TEAM3) if(c3 >= 0) TeamScore_AddToTeam(COLOR_TEAM3, i, -1000);
			if(t != COLOR_TEAM4) if(c4 >= 0) TeamScore_AddToTeam(COLOR_TEAM4, i, -1000);
		}

		AddWinners(team, t);
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
void CheckRules_World()
{
	float timelimit;
	float fraglimit;
	float leadlimit;

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
	leadlimit = cvar("leadlimit");

	if(inWarmupStage || time <= game_starttime) // NOTE: this is <= to prevent problems in the very tic where the game starts
	{
		if(timelimit > 0)
			timelimit = 0; // timelimit is not made for warmup
		if(fraglimit > 0)
			fraglimit = 0; // no fraglimit for now
		leadlimit = 0; // no leadlimit for now
	}

	if(g_onslaught)
		timelimit = 0; // ONS has its own overtime rule

	if(timelimit > 0)
	{
		timelimit += game_starttime;
	}
	else if (timelimit < 0)
	{
		// endmatch
		NextLevel();
		return;
	}

	float wantovertime;
	wantovertime = 0;

	if(checkrules_suddendeathend)
	{
		if(!checkrules_suddendeathwarning)
		{
			checkrules_suddendeathwarning = TRUE;
			if(g_race && !g_race_qualifying)
				bcenterprint("^3Everyone, finish your lap! The race is over!");
			else
				bcenterprint("^3Now playing ^1OVERTIME^3!\n\n^3Keep fragging until we have a ^1winner^3!");
		}
	}
	else
	{
		if (timelimit && time >= timelimit)
		{
			if(g_race && (g_race_qualifying == 2) && timelimit > 0)
			{
				float totalplayers;
				float playerswithlaps;
				float readyplayers;
				entity head;
				totalplayers = playerswithlaps = readyplayers = 0;
				FOR_EACH_PLAYER(head)
				{
					++totalplayers;
					if(PlayerScore_Add(head, SP_RACE_FASTEST, 0))
						++playerswithlaps;
					if(head.ready)
						++readyplayers;
				}

				// at least 2 of the players have completed a lap: start the RACE
				// otherwise, the players should end the qualifying on their own
				if(readyplayers || playerswithlaps >= 2)
				{
					checkrules_suddendeathend = 0;
					ReadyRestart(); // go to race
					return;
				}
				else
					wantovertime |= InitiateSuddenDeath();
			}
			else
				wantovertime |= InitiateSuddenDeath();
		}
	}

	if (checkrules_suddendeathend && time >= checkrules_suddendeathend)
	{
		NextLevel();
		return;
	}

	float checkrules_status;
	checkrules_status = WinningCondition_RanOutOfSpawns();
	if(checkrules_status == WINNING_YES)
	{
		bprint("Hey! Someone ran out of spawns!\n");
	}
	else if(g_race && !g_race_qualifying && timelimit >= 0)
	{
		checkrules_status = WinningCondition_Race(fraglimit);
		//print("WC_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_race && g_race_qualifying == 2 && timelimit >= 0)
	{
		checkrules_status = WinningCondition_QualifyingThenRace(fraglimit);
		//print("WC_QUALIFYING_THEN_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_assault)
	{
		checkrules_status = WinningCondition_Assault(); // TODO remove this?
	}
	else if(g_lms)
	{
		checkrules_status = WinningCondition_LMS();
	}
	else if (g_onslaught)
	{
		checkrules_status = WinningCondition_Onslaught(); // TODO remove this?
	}
	else
	{
		checkrules_status = WinningCondition_Scores(fraglimit, leadlimit);
		//print("WC_SCORES yields ", ftos(checkrules_status), "\n");
	}

	if(checkrules_status == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		checkrules_status = WINNING_NEVER;
		checkrules_overtimesadded = -1;
		wantovertime |= InitiateSuddenDeath();
	}

	if(checkrules_status == WINNING_NEVER)
		// equality cases! Nobody wins if the overtime ends in a draw.
		ClearWinners();

	if(wantovertime)
	{
		if(checkrules_status == WINNING_NEVER)
			InitiateOvertime();
		else
			checkrules_status = WINNING_YES;
	}

	if(checkrules_suddendeathend)
		if(checkrules_status != WINNING_NEVER || time >= checkrules_suddendeathend)
			checkrules_status = WINNING_YES;

	if(checkrules_status == WINNING_YES)
	{
		//print("WINNING\n");
		NextLevel();
	}
};

float mapvote_nextthink;
float mapvote_initialized;
float mapvote_keeptwotime;
float mapvote_timeout;
string mapvote_message;
#define MAPVOTE_SCREENSHOT_DIRS_COUNT 4
string mapvote_screenshot_dirs[MAPVOTE_SCREENSHOT_DIRS_COUNT];
float mapvote_screenshot_dirs_count;

float mapvote_count;
float mapvote_count_real;
string mapvote_maps[MAPVOTE_COUNT];
float mapvote_maps_screenshot_dir[MAPVOTE_COUNT];
string mapvote_maps_pakfile[MAPVOTE_COUNT];
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
	m = MapInfo_FixName(m);
	if(!m)
		return "The map you suggested is not available on this server.";
	if(!cvar("g_maplist_votable_suggestions_override_mostrecent"))
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = floor(random() * mapvote_suggestion_ptr);
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
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)));
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j, i, o;
	string pakfile, mapfile;

	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	if(strlen(nextMap) > mapvote_maxlen)
		mapvote_maxlen = strlen(nextMap);
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;

	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
	{
		mapfile = strcat(mapvote_screenshot_dirs[i], "/", mapvote_maps[i]);
		pakfile = whichpack(strcat(mapfile, ".tga"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".jpg"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".png"));
		if(pakfile != "")
			break;
	}
	if(i >= mapvote_screenshot_dirs_count)
		i = 0; // FIXME maybe network this error case, as that means there is no mapshot on the server?
	for(o = strstr(pakfile, "/", 0)+1; o > 0; o = strstr(pakfile, "/", 0)+1)
		pakfile = substring(pakfile, o, -1);

	mapvote_maps_screenshot_dir[mapvote_count] = i;
	mapvote_maps_pakfile[mapvote_count] = strzone(pakfile);

	mapvote_count += 1;
}

void MapVote_Spawn();
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
	smax = min3(nmax, cvar("g_maplist_votable_suggestions"), mapvote_suggestion_ptr);

	// we need this for AddVotable, as that cycles through the screenshot dirs
	mapvote_screenshot_dirs_count = tokenize_console(cvar_string("g_maplist_votable_screenshot_dir"));
	if(mapvote_screenshot_dirs_count == 0)
		mapvote_screenshot_dirs_count = tokenize_console("maps levelshots");
	mapvote_screenshot_dirs_count = min(mapvote_screenshot_dirs_count, MAPVOTE_SCREENSHOT_DIRS_COUNT);
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
		mapvote_screenshot_dirs[i] = strzone(argv(i));

	if(mapvote_suggestion_ptr)
		for(i = 0; i < 100 && mapvote_count < smax; ++i)
			MapVote_AddVotable(mapvote_suggestions[floor(random() * mapvote_suggestion_ptr)], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(cvar("g_maplist_shuffle"))
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
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

	MapVote_Spawn();
}

void MapVote_SendPicture(float id)
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_PICTURE);
	WriteByte(MSG_ONE, id);
	WritePicture(MSG_ONE, strcat(mapvote_screenshot_dirs[mapvote_maps_screenshot_dir[id]], "/", mapvote_maps[id]), 3072);
}

float GameCommand_MapVote(string cmd)
{
	if(!intermission_running)
		return FALSE;

	if(cmd == "mv_getpic")
	{
		MapVote_SendPicture(stof(argv(1)));
		return TRUE;
	}

	return FALSE;
}

float MapVote_GetMapMask()
{
	float mask, i, power;
	mask = 0;
	for(i = 0, power = 1; i < mapvote_count; ++i, power *= 2)
		if(mapvote_maps[i] != "")
			mask |= power;
	return mask;
}

entity mapvote_ent;
float MapVote_SendEntity(entity to, float sf)
{
	float i;

	if(sf & 1)
		sf &~= 2; // if we send 1, we don't need to also send 2

	WriteByte(MSG_ENTITY, ENT_CLIENT_MAPVOTE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		// flag 1 == initialization
		for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
			WriteString(MSG_ENTITY, mapvote_screenshot_dirs[i]);
		WriteString(MSG_ENTITY, "");
		WriteByte(MSG_ENTITY, mapvote_count);
		WriteByte(MSG_ENTITY, mapvote_abstain);
		WriteByte(MSG_ENTITY, mapvote_detail);
		WriteCoord(MSG_ENTITY, mapvote_timeout);
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				if(mapvote_abstain && i == mapvote_count - 1)
				{
					WriteString(MSG_ENTITY, ""); // abstain needs no text
					WriteString(MSG_ENTITY, ""); // abstain needs no pack
					WriteByte(MSG_ENTITY, 0); // abstain needs no screenshot dir
				}
				else
				{
					WriteString(MSG_ENTITY, mapvote_maps[i]);
					WriteString(MSG_ENTITY, mapvote_maps_pakfile[i]);
					WriteByte(MSG_ENTITY, mapvote_maps_screenshot_dir[i]);
				}
			}
	}

	if(sf & 2)
	{
		// flag 2 == update of mask
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
	}

	if(sf & 4)
	{
		if(mapvote_detail)
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
					WriteByte(MSG_ENTITY, mapvote_votes[i]);

		WriteByte(MSG_ENTITY, to.mapvote);
	}

	return TRUE;
}

void MapVote_Spawn()
{
	Net_LinkEntity(mapvote_ent = spawn(), FALSE, 0, MapVote_SendEntity);
}

void MapVote_TouchMask()
{
	mapvote_ent.SendFlags |= 2;
}

void MapVote_TouchVotes(entity voter)
{
	mapvote_ent.SendFlags |= 4;
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

		GameLogEcho(result);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]));
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

	if(mapvote_count_real == 1)
		return MapVote_Finished(0);

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_votes[mapvote_count - 1];

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		RandomSelection_Add(world, i, string_null, 1, mapvote_votes[i]);
	firstPlace = RandomSelection_chosen_float;
	firstPlaceVotes = RandomSelection_best_priority;
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		if(i != firstPlace)
			RandomSelection_Add(world, i, string_null, 1, mapvote_votes[i]);
	secondPlace = RandomSelection_chosen_float;
	secondPlaceVotes = RandomSelection_best_priority;
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
			MapVote_TouchMask();
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
								strunzone(mapvote_maps_pakfile[i]);
								mapvote_maps_pakfile[i] = "";
							}
						}
				}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(cvar("sv_eventlog"))
				GameLogEcho(result);
		}

	return FALSE;
}
void MapVote_Tick()
{
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
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// clear possibly invalid votes
		if(mapvote_maps[other.mapvote - 1] == "")
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if(mapvote_maps[other.impulse - 1] != "")
			{
				other.mapvote = other.impulse;
				MapVote_TouchVotes(other);
			}
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count
}
void MapVote_Start()
{
	if(mapvote_run)
		return;

	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
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
		if(cvar("rescan_pending") == 1)
		{
			cvar_set("rescan_pending", "2");
			localcmd("fs_rescan\nrescan_pending 3\n");
			return;
		}
		else if(cvar("rescan_pending") == 2)
		{
			return;
		}
		else if(cvar("rescan_pending") == 3)
		{
			// now build missing mapinfo files
			if(!MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
				return;

			// we're done, start the timer
			cvar_set("rescan_pending", "0");
		}

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
	if(!MapInfo_CheckMap(m))
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
	float altime;
	FOR_EACH_REALCLIENT(self)
	{
		if(self.classname == "spectator")
		{
			if(self.enemy.typehitsound)
				play2(self, "misc/typehit.wav");
			else if(self.enemy.hitsound && self.cvar_cl_hitsound)
				play2(self, "misc/hit.wav");
		}
		else
		{
			if(self.typehitsound)
				play2(self, "misc/typehit.wav");
			else if(self.hitsound && self.cvar_cl_hitsound)
				play2(self, "misc/hit.wav");
		}
	}
	altime = time + frametime * (1 + cvar("g_antilag_nudge"));
	// add 1 frametime because after this, engine SV_Physics
	// increases time by a frametime and then networks the frame
	// add another frametime because client shows everything with
	// 1 frame of lag (cl_nolerp 0). The last +1 however should not be
	// needed!
	FOR_EACH_CLIENT(self)
	{
		self.hitsound = FALSE;
		self.typehitsound = FALSE;
		antilag_record(self, altime);
	}
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
		print("Redirecting: sending connect command to ", self.netname, "\n");
		if(redirection_target == "self")
			stuffcmd(self, "\ndisconnect; reconnect\n");
		else
			stuffcmd(self, strcat("\ndisconnect; connect ", redirection_target, "\n"));
		++clients_found;
	}

	print("Redirecting: ", ftos(clients_found), " clients left.\n");

	if(time > redirection_timeout || clients_found == 0)
		localcmd("\nwait; wait; wait; quit\n");

	return TRUE;
}

void RestoreGame()
{
	// Loaded from a save game
	// some things then break, so let's work around them...

	// Progs DB (capture records)
	ServerProgsDB = db_load("server.db");

	// Mapinfo
	MapInfo_Shutdown();
	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);
	WeaponStats_Init();
}

void SV_Shutdown()
{
	if(gameover > 1) // shutting down already?
		return;

	gameover = 2; // 2 = server shutting down

	if(world_initialized > 0)
	{
		world_initialized = 0;
		print("Saving persistent data...\n");
		Ban_SaveBans();
		if(!cheatcount_total)
			db_save(ServerProgsDB, "server.db");
		if(cvar("developer"))
			db_save(TemporaryDB, "server-temp.db");
		CheatShutdown(); // must be after cheatcount check
		db_close(ServerProgsDB);
		db_close(TemporaryDB);
		print("done!\n");
		// tell the bot system the game is ending now
		bot_endgame();

		WeaponStats_Shutdown();
		MapInfo_Shutdown();
	}
	else if(world_initialized == 0)
	{
		print("NOTE: crashed before even initializing the world, not saving persistent data\n");
	}
}
