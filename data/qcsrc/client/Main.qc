// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS
//include "main.qh"

#define DP_CSQC_ENTITY_REMOVE_IS_B0RKED

void cvar_clientsettemp(string cv, string val)
{
	entity e;
	for(e = world; (e = find(e, classname, "saved_cvar_value")); )
		if(e.netname == cv)
			goto saved;
	e = spawn();
	e.classname = "saved_cvar_value";
	e.netname = strzone(cv);
	e.message = strzone(cvar_string(cv));
:saved
	cvar_set(cv, val);
}

void cvar_clientsettemp_restore()
{
	entity e;
	for(e = world; (e = find(e, classname, "saved_cvar_value")); )
			cvar_set(e.netname, e.message);
}

void() menu_show_error =
{
	drawstring('0 200 0', "ERROR - MENU IS VISIBLE BUT NO MENU WAS DEFINED!", '8 8 0', '1 0 0', 1, 0);
};

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
// Useful for precaching things

void() menu_sub_null =
{
};

#ifdef USE_FTE
float __engine_check;
#endif

string forcefog;
string cl_announcer_prev;
void WaypointSprite_Load();
void CSQC_Init(void)
{
#ifdef USE_FTE
#pragma target ID
	__engine_check = checkextension("DP_SV_WRITEPICTURE");
	if(!__engine_check)
	{
		print("^3Your engine build is outdated\n^3This Server uses a newer QC VM. Please update!\n");
		localcmd("\ndisconnect\n");
		return;
	}
#pragma target FTE
#endif
	
	check_unacceptable_compiler_bugs();

	float i;
	CSQC_CheckEngine();

	binddb = db_create();
	tempdb = db_create();
	ClientProgsDB = db_load("client.db");
	compressShortVector_init();

	drawfont = 0;
	menu_visible = FALSE;
	menu_show = menu_show_error;
	menu_action = menu_sub_null;

	for(i = 0; i < 255; ++i)
		if(getplayerkey(i, "viewentity") == "")
			break;
	maxclients = i;

	//ctf_temp_1 = "";
	// localcmd("alias order \"cmd order $*\""); enable if ctf-command thingy is used
	//registercmd("ctf_menu");
	registercmd("ons_map");
	//registercmd("menu_action");

	registercmd("+button3");
	registercmd("-button3");
	registercmd("+button4");
	registercmd("-button4");
	registercmd("+showaccuracy");registercmd("-showaccuracy");

#ifndef CAMERATEST
	if(isdemo())
	{
#endif
		registercmd("+forward");registercmd("-forward");
		registercmd("+back");registercmd("-back");
		registercmd("+moveup");registercmd("-moveup");
		registercmd("+movedown");registercmd("-movedown");
		registercmd("+moveright");registercmd("-moveright");
		registercmd("+moveleft");registercmd("-moveleft");
		registercmd("+roll_right");registercmd("-roll_right");
		registercmd("+roll_left");registercmd("-roll_left");
#ifndef CAMERATEST
	}
#endif
	registercvar("sbar_usecsqc", "1");
	registercvar("sbar_columns", "default", CVAR_SAVE);

	gametype = 0;

	// sbar_fields uses strunzone on the titles!
	for(i = 0; i < MAX_SBAR_FIELDS; ++i)
		sbar_title[i] = strzone("(null)");

	postinit = false;

	calledhooks = 0;

	teams = Sort_Spawn();
	players = Sort_Spawn();

	GetTeam(COLOR_SPECTATOR, true); // add specs first

	cvar_clientsettemp("_supports_weaponpriority", "1");

	RegisterWeapons();

	WaypointSprite_Load();

	// precaches
	Projectile_Precache();
	GibSplash_Precache();
	Casings_Precache();
	DamageInfo_Precache();
	if(cvar_string("cl_announcer") != cl_announcer_prev) {
		Announcer_Precache();
		if(cl_announcer_prev)
			strunzone(cl_announcer_prev);
		cl_announcer_prev = strzone(cvar_string("cl_announcer"));
	}
	Tuba_Precache();

#ifdef UID
	{
		// find the user ID
		string uid;
		registercvar("_cl_userid", "", CVAR_SAVE);
		uid = cvar_string("_cl_userid");
		if(strlen(uid) < 16)
		{
			uid = "";
			for(i = 0; i < 4; ++i)
				uid = strcat(uid, substring(ftos(floor(10000 + random() * 10000)), 1, -1));
		}
		cvar_set("_cl_userid", uid);
		localcmd(strcat("\ncmd uid ", uid, "\n"));
	}
#endif

	get_mi_min_max_texcoords(1); // try the CLEVER way first
	minimapname = strcat("gfx/", mi_shortname, "_radar.tga");
	shortmapname = mi_shortname;

	if(precache_pic(minimapname) == "")
	{
		// but maybe we have a non-clever minimap
		minimapname = strcat("gfx/", mi_shortname, "_mini.tga");
		if(precache_pic(minimapname) == "")
			minimapname = ""; // FAIL
		else
			get_mi_min_max_texcoords(0); // load new texcoords
	}

	mi_center = (mi_min + mi_max) * 0.5;
	mi_scale = mi_max - mi_min;
	minimapname = strzone(minimapname);

	WarpZone_Init();
}

// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown(void)
{
#ifdef USE_FTE
#pragma TARGET id
	if(!__engine_check)
		return 0;
#pragma TARGET fte
#endif

	WarpZone_Shutdown();

	remove(teams);
	remove(players);
	db_close(binddb);
	db_close(tempdb);
	db_save(ClientProgsDB, "client.db");
	db_close(ClientProgsDB);

	cvar_clientsettemp_restore();

	if(camera_active)
		cvar_set("chase_active",ftos(chase_active_backup));

	if not(isdemo())
	{
		if not(calledhooks & HOOK_START)
			localcmd("\n_cl_hook_gamestart nop;");
		if not(calledhooks & HOOK_END)
			localcmd("\ncl_hook_gameend;");
	}
}

.float has_team;
float SetTeam(entity o, float Team)
{
	entity tm;
	if(teamplay)
	{
		switch(Team)
		{
			case -1:
			case COLOR_TEAM1:
			case COLOR_TEAM2:
			case COLOR_TEAM3:
			case COLOR_TEAM4:
				break;
			default:
				if(GetTeam(Team, false) == NULL)
				{
					print("trying to switch to unsupported team ", ftos(Team), "\n");
					Team = COLOR_SPECTATOR;
				}
				break;
		}
	}
	else
	{
		switch(Team)
		{
			case -1:
			case 0:
				break;
			default:
				if(GetTeam(Team, false) == NULL)
				{
					print("trying to switch to unsupported team ", ftos(Team), "\n");
					Team = COLOR_SPECTATOR;
				}
				break;
		}
	}
	if(Team == -1) // leave
	{
		if(o.has_team)
		{
			//print("(DISCONNECT) leave team ", ftos(o.team), "\n");
			tm = GetTeam(o.team, false);
			tm.team_size -= 1;
			o.has_team = 0;
			return TRUE;
		}
	}
	else
	{
		if not(o.has_team)
		{
			//print("(CONNECT) enter team ", ftos(o.team), "\n");
			o.team = Team;
			tm = GetTeam(Team, true);
			tm.team_size += 1;
			o.has_team = 1;
			return TRUE;
		}
		else if(Team != o.team)
		{
			//print("(CHANGE) leave team ", ftos(o.team), "\n");
			tm = GetTeam(o.team, false);
			tm.team_size -= 1;
			o.team = Team;
			//print("(CHANGE) enter team ", ftos(o.team), "\n");
			tm = GetTeam(Team, true);
			tm.team_size += 1;
			return TRUE;
		}
	}
	return FALSE;
}

void Playerchecker_Think()
{
	float i;
	entity e;
	for(i = 0; i < maxclients; ++i)
	{
		e = playerslots[i];
		if(GetPlayerName(i) == "")
		{
			if(e.sort_prev)
			{
				//print("playerchecker: KILL KILL KILL\n");
				// player disconnected
				SetTeam(e, -1);
				RemovePlayer(e);
				e.sort_prev = world;
				//e.gotscores = 0;
			}
		}
		else
		{
			if not(e.sort_prev)
			{
				//print("playerchecker: SPAWN SPAWN SPAWN\n");
				// player connected
				if not(e)
					playerslots[i] = e = spawn();
				e.sv_entnum = i;
				e.ping = 0;
				e.ping_packetloss = 0;
				e.ping_movementloss = 0;
				//e.gotscores = 0; // we might already have the scores...
				SetTeam(e, GetPlayerColor(i)); // will not hurt; later updates come with Sbar_UpdatePlayerTeams
				RegisterPlayer(e);
				Sbar_UpdatePlayerPos(e);
			}
		}
	}
	self.nextthink = time + 0.2;
}

void Porto_Init();
void TrueAim_Init();
void PostInit(void)
{
	print(strcat("PostInit\n    maxclients = ", ftos(maxclients), "\n"));
	localcmd(strcat("\nsbar_columns_set ", cvar_string("sbar_columns"), ";\n"));

	entity playerchecker;
	playerchecker = spawn();
	playerchecker.think = Playerchecker_Think;
	playerchecker.nextthink = time + 0.2;

	Porto_Init();
	TrueAim_Init();

	postinit = true;
}

// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
float button_zoom;
void Cmd_Sbar_SetFields(float);
void Cmd_Sbar_Help(float);
float CSQC_ConsoleCommand(string strMessage)
{
	float argc;
	// Tokenize String
	//argc = tokenize(strMessage);
	argc = tokenize_console(strMessage);

	// Acquire Command
	local string strCmd;
	strCmd = argv(0);

	if(strCmd == "+button4") { // zoom
		// return false, because the message shall be sent to the server anyway (for demos/speccing)
		if(ignore_plus_zoom)
		{
			--ignore_plus_zoom;
			return false;
		}
		button_zoom = 1;
		return true;
	} else if(strCmd == "-button4") { // zoom
		if(ignore_minus_zoom)
		{
			--ignore_minus_zoom;
			return false;
		}
		button_zoom = 0;
		return true;
	} else if(strCmd == "+button3") { // secondary
		button_attack2 = 1;
		return false;
	} else if(strCmd == "-button3") { // secondary
		button_attack2 = 0;
		return false;
	} else if(strCmd == "+showscores") {
		sb_showscores = true;
		return true;
	} else if(strCmd == "-showscores") {
		sb_showscores = false;
		return true;
	} else if(strCmd == "+showaccuracy") {
		sb_showaccuracy = true;
		return true;
	} else if(strCmd == "-showaccuracy") {
		sb_showaccuracy = false;
		return true;
	}

	if(camera_active)
	if(strCmd == "+forward" || strCmd == "-back") {
		++camera_direction_x;
		return true;
	} else if(strCmd == "-forward" || strCmd == "+back") {
		--camera_direction_x;
		return true;
	} else if(strCmd == "+moveright" || strCmd == "-moveleft") {
		--camera_direction_y;
		return true;
	} else if(strCmd == "-moveright" || strCmd == "+moveleft") {
		++camera_direction_y;
		return true;
	} else if(strCmd == "+moveup" || strCmd == "-movedown") {
		++camera_direction_z;
		return true;
	} else if(strCmd == "-moveup" || strCmd == "+movedown") {
		--camera_direction_z;
		return true;
	} else if(strCmd == "+roll_right" || strCmd == "-roll_left") {
		++camera_roll;
		return true;
	} else if(strCmd == "+roll_left" || strCmd == "-roll_right") {
		--camera_roll;
		return true;
	}

	return false;
}

.vector view_ofs;
entity debug_shotorg;
void ShotOrg_Draw()
{
	self.origin = view_origin + view_forward * self.view_ofs_x + view_right * self.view_ofs_y + view_up * self.view_ofs_z;
	self.angles = view_angles;
	self.angles_x = -self.angles_x;
	if not(self.cnt)
		R_AddEntity(self);
}
void ShotOrg_Draw2D()
{
	vector coord2d_topleft, coord2d_topright, coord2d;
	string s;
	vector fs;

	s = vtos(self.view_ofs);
	s = substring(s, 1, strlen(s) - 2);
	if(tokenize_console(s) == 3)
		s = strcat(argv(0), " ", argv(1), " ", argv(2));

	coord2d_topleft = project_3d_to_2d(self.origin + view_up * 4 - view_right * 4);
	coord2d_topright = project_3d_to_2d(self.origin + view_up * 4 + view_right * 4);

	fs = '1 1 0' * ((coord2d_topright_x - coord2d_topleft_x) / stringwidth(s, FALSE, '8 8 0'));

	coord2d = coord2d_topleft;
	if(fs_x < 8)
	{
		coord2d_x += (coord2d_topright_x - coord2d_topleft_x) * (1 - 8 / fs_x) * 0.5;
		fs = '8 8 0';
	}
	coord2d_y -= fs_y;
	coord2d_z = 0;
	drawstring(coord2d, s, fs, '1 1 1', 1, 0);
}

void ShotOrg_Spawn()
{
	debug_shotorg = spawn();
	debug_shotorg.draw = ShotOrg_Draw;
	debug_shotorg.draw2d = ShotOrg_Draw2D;
	debug_shotorg.renderflags = RF_VIEWMODEL;
	debug_shotorg.effects = EF_FULLBRIGHT;
	precache_model("models/shotorg_adjuster.md3");
	setmodel(debug_shotorg, "models/shotorg_adjuster.md3");
	debug_shotorg.scale = 2;
	debug_shotorg.view_ofs = '25 8 -8';
}

void DrawDebugModel()
{
	if(time - floor(time) > 0.5)
	{
		PolyDrawModel(self);
	}
	else
	{
		self.renderflags = 0;
		R_AddEntity(self);
	}
}

void GameCommand(string msg)
{
	string s;
	float argc;
	entity e;
	argc = tokenize_console(msg);

	if(argv(0) == "help" || argc == 0)
	{
		print("Usage: cl_cmd COMMAND..., where possible commands are:\n");
		print("  settemp cvar value\n");
		print("  radar\n");
		print("  sbar_columns_set ...\n");
		print("  sbar_columns_help\n");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Generic(msg))
		return;

	string cmd;
	cmd = argv(0);
	if(cmd == "mv_download") {
		Cmd_MapVote_MapDownload(argc);
	}
	else if(cmd == "settemp") {
		cvar_clientsettemp(argv(1), argv(2));
	}
	else if(cmd == "radar") {
		ons_showmap = !ons_showmap;
	}
	else if(cmd == "sbar_columns_set") {
		Cmd_Sbar_SetFields(argc);
	}
	else if(cmd == "sbar_columns_help") {
		Cmd_Sbar_Help(argc);
	}
#ifdef BLURTEST
	else if(cmd == "blurtest") {
		blurtest_time0 = time;
		blurtest_time1 = time + stof(argv(1));
		blurtest_radius = stof(argv(2));
		blurtest_power = stof(argv(3));
	}
#endif
	else if(cmd == "shotorg_move") {
		if(!debug_shotorg)
			ShotOrg_Spawn();
		else
			debug_shotorg.view_ofs = debug_shotorg.view_ofs + stov(argv(1));
		localcmd("sv_cmd debug_shotorg \"", vtos(debug_shotorg.view_ofs), "\"\n");
	}
	else if(cmd == "shotorg_movez") {
		if(!debug_shotorg)
			ShotOrg_Spawn();
		else
			debug_shotorg.view_ofs = debug_shotorg.view_ofs + stof(argv(1)) * (debug_shotorg.view_ofs * (1 / debug_shotorg.view_ofs_x)); // closer/farther, same xy pos
		localcmd("sv_cmd debug_shotorg \"", vtos(debug_shotorg.view_ofs), "\"\n");
	}
	else if(cmd == "shotorg_set") {
		if(!debug_shotorg)
			ShotOrg_Spawn();
		else
			debug_shotorg.view_ofs = stov(argv(1));
		localcmd("sv_cmd debug_shotorg \"", vtos(debug_shotorg.view_ofs), "\"\n");
	}
	else if(cmd == "shotorg_setz") {
		if(!debug_shotorg)
			ShotOrg_Spawn();
		else
			debug_shotorg.view_ofs = debug_shotorg.view_ofs * (stof(argv(1)) / debug_shotorg.view_ofs_x); // closer/farther, same xy pos
		localcmd("sv_cmd debug_shotorg \"", vtos(debug_shotorg.view_ofs), "\"\n");
	}
	else if(cmd == "shotorg_toggle_hide") {
		if(debug_shotorg)
		{
			debug_shotorg.cnt = !debug_shotorg.cnt;
		}
	}
	else if(cmd == "shotorg_end") {
		if(debug_shotorg)
		{
			print(vtos(debug_shotorg.view_ofs), "\n");
			remove(debug_shotorg);
			debug_shotorg = world;
		}
		localcmd("sv_cmd debug_shotorg\n");
	}
	else if(cmd == "sendcvar") {
		s = cvar_string(argv(1));
		if(argv(1) == "cl_weaponpriority")
			s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 1);
		else if(substring(argv(1), 0, 17) == "cl_weaponpriority" && strlen(argv(1)) == 18)
			s = W_FixWeaponOrder(W_NumberWeaponOrder(s), 0);
		localcmd("cmd sentcvar ", argv(1), " \"", s, "\"\n");
	}
	else if(cmd == "spawn") {
		s = argv(1);
		e = spawn();
		precache_model(s);
		setmodel(e, s);
		setorigin(e, view_origin);
		e.angles = view_angles;
		e.draw = DrawDebugModel;
		e.classname = "debugmodel";
	}
	else
	{
		print("Invalid command. For a list of supported commands, try cl_cmd help.\n");
	}

	return;
}

// CSQC_InputEvent : Used to perform actions based on any key pressed, key released and mouse on the client.
// Return value should be 1 if CSQC handled the input, otherwise return 0 to have the input passed to the engine.
// All keys are in ascii.
// bInputType = 0 is key pressed, 1 is key released, 2 is mouse input.
// In the case of keyboard input, nPrimary is the ascii code, and nSecondary is 0.
// In the case of mouse input, nPrimary is xdelta, nSecondary is ydelta.
float CSQC_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	local float bSkipKey;
	bSkipKey = false;

	if (MapVote_InputEvent(bInputType, nPrimary, nSecondary))
		return true;

	if(menu_visible)
		if(menu_action(bInputType, nPrimary, nSecondary))
			return TRUE;
	return bSkipKey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS
void Ent_ReadEntCS()
{
	InterpolateOrigin_Undo();

	self.classname = "entcs_receiver";
	self.sv_entnum = ReadByte() - 1;
	self.origin_x = ReadShort();
	self.origin_y = ReadShort();
	self.origin_z = ReadShort();
	self.angles_y = ReadByte() * 360.0 / 256;
	self.origin_z = self.angles_x = self.angles_z = 0;

	InterpolateOrigin_Note();
}

void Ent_Remove();

void Ent_RemovePlayerScore()
{
	float i;

	if(self.owner)
	{
		SetTeam(self.owner, -1);
		self.owner.gotscores = 0;
		for(i = 0; i < MAX_SCORE; ++i)
			self.owner.(scores[i]) = 0; // clear all scores
	}
}

void Ent_ReadPlayerScore()
{
	float i, n;
	float isNew;
	entity o;

	// damnit -.- don't want to go change every single .sv_entnum in sbar.qc AGAIN
	// (no I've never heard of M-x replace-string, sed, or anything like that)
	isNew = !self.owner; // workaround for DP bug
	n = ReadByte()-1;

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if(!isNew && n != self.sv_entnum)
	{
		print("A CSQC entity changed its owner!\n");
		isNew = true;
		Ent_Remove();
		self.enttype = ENT_CLIENT_SCORES;
	}
#endif

	self.sv_entnum = n;

	if not(playerslots[self.sv_entnum])
		playerslots[self.sv_entnum] = spawn();
	o = self.owner = playerslots[self.sv_entnum];
	o.sv_entnum = self.sv_entnum;
	o.gotscores = 1;

	//if not(o.sort_prev)
	//	RegisterPlayer(o);
	//playerchecker will do this for us later, if it has not already done so

	float sf, lf;
#if MAX_SCORE <= 8
	sf = ReadByte();
	lf = ReadByte();
#else
	sf = ReadShort();
	lf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_SCORE; ++i, p *= 2)
		if(sf & p)
		{
			if(lf & p)
				o.(scores[i]) = ReadInt24_t();
			else
				o.(scores[i]) = ReadChar();
		}

	if(o.sort_prev)
		Sbar_UpdatePlayerPos(o); // if not registered, we cannot do this yet!

	self.entremove = Ent_RemovePlayerScore;
}

void Ent_ReadTeamScore()
{
	float i;
	entity o;

	self.team = ReadByte();
	o = self.owner = GetTeam(self.team, true); // these team numbers can always be trusted

	float sf, lf;
#if MAX_TEAMSCORE <= 8
	sf = ReadByte();
	lf = ReadByte();
#else
	sf = ReadShort();
	lf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_TEAMSCORE; ++i, p *= 2)
		if(sf & p)
		{
			if(lf & p)
				o.(teamscores[i]) = ReadInt24_t();
			else
				o.(teamscores[i]) = ReadChar();
		}

	Sbar_UpdateTeamPos(o);
}

void Net_Reset()
{
}

void Ent_ClientData()
{
	float f;
	float newspectatee_status;

	f = ReadByte();

	sb_showscores_force = (f & 1);

	if(f & 2)
	{
		newspectatee_status = ReadByte();
		if(newspectatee_status == player_localentnum)
			newspectatee_status = -1; // observing
	}
	else
		newspectatee_status = 0;

	spectatorbutton_zoom = (f & 4);

	if(f & 8)
	{
		angles_held_status = 1;
		angles_held_x = ReadAngle();
		angles_held_y = ReadAngle();
		angles_held_z = 0;
	}
	else
		angles_held_status = 0;

	if(newspectatee_status != spectatee_status)
	{
		float i;
		// clear the weapon accuracy stats
		for(i = WEP_FIRST; i <= WEP_LAST; ++i) {
			weapon_hits[i] = 0;
			weapon_fired[i] = 0;
		}

		// clear race stuff
		race_laptime = 0;
		race_checkpointtime = 0;
	}
	spectatee_status = newspectatee_status;
}

void Ent_Nagger()
{
	float nags, i, j, b, f;

	nags = ReadByte();

	if(nags & 128)
	{
		if(vote_called_vote)
			strunzone(vote_called_vote);
		vote_called_vote = strzone(ColorTranslateRGB(ReadString()));
	}

	if(nags & 1)
	{
		for(j = 0; j < maxclients; ++j)
			if(playerslots[j])
				playerslots[j].ready = 1;
		for(i = 1; i <= maxclients; i += 8)
		{
			f = ReadByte();
			for(j = i-1, b = 1; b < 256; b *= 2, ++j)
				if not(f & b)
					if(playerslots[j])
						playerslots[j].ready = 0;
		}
	}

	ready_waiting = (nags & 1);
	ready_waiting_for_me = (nags & 2);
	vote_waiting = (nags & 4);
	vote_waiting_for_me = (nags & 8);
	warmup_stage = (nags & 16);
}

void Ent_RandomSeed()
{
	float s;
	prandom_debug();
	s = ReadShort();
	psrandom(s);
}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void Ent_RadarLink();
void Ent_Init();
void Ent_ScoresInfo();
void(float bIsNewEntity) CSQC_Ent_Update =
{
	float t;
	float savetime;
	t = ReadByte();

	// set up the "time" global for received entities to be correct for interpolation purposes
	savetime = time;
	if(servertime)
	{
		time = servertime;
	}
	else
	{
		serverprevtime = time;
		serverdeltatime = getstatf(STAT_MOVEVARS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);
		time = serverprevtime + serverdeltatime;
	}

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if(self.enttype)
		if(t != self.enttype)
		{
			print("A CSQC entity changed its type!\n");
			Ent_Remove();
			bIsNewEntity = 1;
		}
#endif
	self.enttype = t;
	switch(t)
	{
		case ENT_CLIENT_ENTCS: Ent_ReadEntCS(); break;
		case ENT_CLIENT_SCORES: Ent_ReadPlayerScore(); break;
		case ENT_CLIENT_TEAMSCORES: Ent_ReadTeamScore(); break;
		case ENT_CLIENT_POINTPARTICLES: Ent_PointParticles(); break;
		case ENT_CLIENT_RAINSNOW: Ent_RainOrSnow(); break;
		case ENT_CLIENT_LASER: Ent_Laser(); break;
		case ENT_CLIENT_NAGGER: Ent_Nagger(); break;
		case ENT_CLIENT_WAYPOINT: Ent_WaypointSprite(); break;
		case ENT_CLIENT_RADARLINK: Ent_RadarLink(); break;
		case ENT_CLIENT_PROJECTILE: Ent_Projectile(); break;
		case ENT_CLIENT_GIBSPLASH: Ent_GibSplash(bIsNewEntity); break;
		case ENT_CLIENT_DAMAGEINFO: Ent_DamageInfo(bIsNewEntity); break;
		case ENT_CLIENT_CASING: Ent_Casing(bIsNewEntity); break;
		case ENT_CLIENT_INIT: Ent_Init(); break;
		case ENT_CLIENT_SCORES_INFO: Ent_ScoresInfo(); break;
		case ENT_CLIENT_MAPVOTE: Ent_MapVote(); break;
		case ENT_CLIENT_CLIENTDATA: Ent_ClientData(); break;
		case ENT_CLIENT_RANDOMSEED: Ent_RandomSeed(); break;
		case ENT_CLIENT_WALL: Ent_Wall(); break;
		case ENT_CLIENT_MODELEFFECT: Ent_ModelEffect(bIsNewEntity); break;
		case ENT_CLIENT_TUBANOTE: Ent_TubaNote(bIsNewEntity); break;
		case ENT_CLIENT_WARPZONE: WarpZone_Read(bIsNewEntity); break;
		case ENT_CLIENT_WARPZONE_CAMERA: WarpZone_Camera_Read(bIsNewEntity); break;
		default:
			error(strcat("unknown entity type in CSQC_Ent_Update: ", ftos(self.enttype), "\n"));
			break;
	}

	time = savetime;
};
// Destructor, but does NOT deallocate the entity by calling remove(). Also
// used when an entity changes its type. For an entity that someone interacts
// with others, make sure it can no longer do so.
void Ent_Remove()
{
	if(self.entremove)
		self.entremove();

	self.enttype = 0;
	self.classname = "";
	self.draw = menu_sub_null;
	self.entremove = menu_sub_null;
	// TODO possibly set more stuff to defaults
}
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
	if(self.enttype)
		Ent_Remove();
	remove(self);
}

void Gamemode_Init()
{
	if(gametype == GAME_ONSLAUGHT) {
		print(strcat("Using ", minimapname, " as minimap.\n"));
		precache_pic("gfx/ons-cp-neutral.tga");
		precache_pic("gfx/ons-cp-red.tga");
		precache_pic("gfx/ons-cp-blue.tga");
		precache_pic("gfx/ons-frame.tga");
		precache_pic("gfx/ons-frame-team.tga");
	} else if(gametype == GAME_KEYHUNT) {
		precache_pic("gfx/sb_key_carrying");
		precache_pic("gfx/sb_key_carrying_outline");
	}

	if not(isdemo())
	{
		localcmd("\n_cl_hook_gamestart ", GametypeNameFromType(gametype), ";");
		calledhooks |= HOOK_START;
	}
}
// CSQC_Parse_StuffCmd : Provides the stuffcmd string in the first parameter that the server provided.  To execute standard behavior, simply execute localcmd with the string.
void CSQC_Parse_StuffCmd(string strMessage)
{
	localcmd(strMessage);
}
// CSQC_Parse_Print : Provides the print string in the first parameter that the server provided.  To execute standard behavior, simply execute print with the string.
void CSQC_Parse_Print(string strMessage)
{
	print(ColorTranslateRGB(strMessage));
}

// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.
void CSQC_Parse_CenterPrint(string strMessage)
{
	centerprint(strMessage);
}

string notranslate_fogcmd1 = "\nfog ";
string notranslate_fogcmd2 = "\nr_fog_exp2 0\nr_drawfog 1\n";
void Fog_Force()
{
	// TODO somehow thwart prvm_globalset client ...

	if(forcefog != "")
		localcmd(strcat(notranslate_fogcmd1, forcefog, notranslate_fogcmd2));
}

void Gamemode_Init();
void Ent_ScoresInfo()
{
	float i;
	self.classname = "ent_client_scores_info";
	gametype = ReadByte();
	for(i = 0; i < MAX_SCORE; ++i)
	{
		scores_label[i] = strzone(ReadString());
		scores_flags[i] = ReadByte();
	}
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		teamscores_label[i] = strzone(ReadString());
		teamscores_flags[i] = ReadByte();
	}
	Sbar_InitScores();
	Gamemode_Init();
}

void Ent_Init()
{
	self.classname = "ent_client_init";

	nb_pb_period = ReadByte() / 32; //Accuracy of 1/32th

	hook_shotorigin_x = ReadCoord();
	hook_shotorigin_y = ReadCoord();
	hook_shotorigin_z = ReadCoord();

	if(forcefog)
		strunzone(forcefog);
	forcefog = strzone(ReadString());

	armorblockpercent = ReadByte() / 255.0;

	g_weaponswitchdelay = ReadByte() / 255.0;

	if(!postinit)
		PostInit();
}

void Net_ReadRace()
{
	float b;

	b = ReadByte();

	switch(b)
	{
		case RACE_NET_CHECKPOINT_HIT_QUALIFYING:
			race_checkpoint = ReadByte();
			race_time = ReadInt24_t();
			race_previousbesttime = ReadInt24_t();
			if(race_previousbestname)
				strunzone(race_previousbestname);
			race_previousbestname = strzone(ColorTranslateRGB(ReadString()));

			race_checkpointtime = time;

			if(race_checkpoint == 0 || race_checkpoint == 254)
			{
				race_penaltyaccumulator = 0;
				race_laptime = time; // valid
			}

			break;

		case RACE_NET_CHECKPOINT_CLEAR:
			race_laptime = 0;
			race_checkpointtime = 0;
			break;

		case RACE_NET_CHECKPOINT_NEXT_SPEC_QUALIFYING:
			race_laptime = ReadCoord();
			race_checkpointtime = -99999;
			// fall through
		case RACE_NET_CHECKPOINT_NEXT_QUALIFYING:
			race_nextcheckpoint = ReadByte();

			race_nextbesttime = ReadInt24_t();
			if(race_nextbestname)
				strunzone(race_nextbestname);
			race_nextbestname = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_CHECKPOINT_HIT_RACE:
			race_mycheckpoint = ReadByte();
			race_mycheckpointtime = time;
			race_mycheckpointdelta = ReadInt24_t();
			race_mycheckpointlapsdelta = ReadByte();
			if(race_mycheckpointlapsdelta >= 128)
				race_mycheckpointlapsdelta -= 256;
			if(race_mycheckpointenemy)
				strunzone(race_mycheckpointenemy);
			race_mycheckpointenemy = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_CHECKPOINT_HIT_RACE_BY_OPPONENT:
			race_othercheckpoint = ReadByte();
			race_othercheckpointtime = time;
			race_othercheckpointdelta = ReadInt24_t();
			race_othercheckpointlapsdelta = ReadByte();
			if(race_othercheckpointlapsdelta >= 128)
				race_othercheckpointlapsdelta -= 256;
			if(race_othercheckpointenemy)
				strunzone(race_othercheckpointenemy);
			race_othercheckpointenemy = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_PENALTY_RACE:
			race_penaltyeventtime = time;
			race_penaltytime = ReadShort();
			//race_penaltyaccumulator += race_penaltytime;
			if(race_penaltyreason)
				strunzone(race_penaltyreason);
			race_penaltyreason = strzone(ReadString());
			break;

		case RACE_NET_PENALTY_QUALIFYING:
			race_penaltyeventtime = time;
			race_penaltytime = ReadShort();
			race_penaltyaccumulator += race_penaltytime;
			if(race_penaltyreason)
				strunzone(race_penaltyreason);
			race_penaltyreason = strzone(ReadString());
			break;

		case RACE_NET_SERVER_RECORD:
			race_server_record = ReadInt24_t();
			break;
		case RACE_NET_SPEED_AWARD:
			race_speedaward = ReadInt24_t();
			if(race_speedaward_holder)
				strunzone(race_speedaward_holder);
			race_speedaward_holder = strzone(ReadString());
			break;
		case RACE_NET_SPEED_AWARD_BEST:
			race_speedaward_alltimebest = ReadInt24_t();
			if(race_speedaward_alltimebest_holder)
				strunzone(race_speedaward_alltimebest_holder);
			race_speedaward_alltimebest_holder = strzone(ReadString());
			break;
		case RACE_NET_SERVER_RANKINGS:
			float pos, prevpos, del;
			pos = ReadShort();
			prevpos = ReadShort();
			del = ReadShort();

			// move other rankings out of the way
			float i;
			if (prevpos) {
				for (i=prevpos-1;i>pos-1;--i) {
					grecordtime[i] = grecordtime[i-1];
					if(grecordholder[i])
						strunzone(grecordholder[i]);
					grecordholder[i] = strzone(grecordholder[i-1]);
				}
			} else if (del) { // a record has been deleted by the admin
				for (i=pos-1; i<= RANKINGS_CNT-1; ++i) {
					if (i == RANKINGS_CNT-1) { // clear out last record
						grecordtime[i] = 0;
						if (grecordholder[i])
							strunzone(grecordholder[i]);
						grecordholder[i] = string_null;
					}
					else {
						grecordtime[i] = grecordtime[i+1];
						if (grecordholder[i])
							strunzone(grecordholder[i]);
						grecordholder[i] = strzone(grecordholder[i+1]);
					}
				}
			} else { // player has no ranked record yet
				for (i=RANKINGS_CNT-1;i>pos-1;--i) {
					grecordtime[i] = grecordtime[i-1];
					if(grecordholder[i])
						strunzone(grecordholder[i]);
					grecordholder[i] = strzone(grecordholder[i-1]);
				}
			}

			// store new ranking
			if(grecordholder[pos-1] != "")
				strunzone(grecordholder[pos-1]);
			grecordholder[pos-1] = strzone(ReadString());
			grecordtime[pos-1] = ReadInt24_t();
			if(grecordholder[pos-1] == GetPlayerName(player_localentnum -1))
				race_myrank = pos;
			break;
		case RACE_NET_SERVER_STATUS:
			race_status = ReadShort();
			if(race_status_name)
				strunzone(race_status_name);
			race_status_name = strzone(ReadString());
	}
}

void Net_ReadSpawn()
{
	zoomin_effect = 1;
	current_viewzoom = 0.6;
}

void Net_TeamNagger()
{
	teamnagger = 1;
}

void Net_ReadPingPLReport()
{
	float e, pi, pl, ml;
	e = ReadByte();
	pi = ReadShort();
	pl = ReadByte();
	ml = ReadByte();
	if not(playerslots[e])
		return;
	playerslots[e].ping = pi;
	playerslots[e].ping_packetloss = pl / 255.0;
	playerslots[e].ping_movementloss = ml / 255.0;
}

void Net_VoteDialog(float highlight) {
	if(highlight) {
		vote_highlighted = ReadShort();
		return;
	}

	vote_yescount = ReadShort();
	vote_nocount = ReadShort();
	vote_needed = ReadShort();
	vote_active = 1;
}

void Net_VoteDialogReset() {
	vote_active = 0;
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float CSQC_Parse_TempEntity()
{
	local float bHandled;
		bHandled  = true;
	// Acquire TE ID
	local float nTEID;
		nTEID = ReadByte();

		// NOTE: Could just do return instead of break...
	switch(nTEID)
	{
		case TE_CSQC_PICTURE:
			Net_MapVote_Picture();
			bHandled = true;
			break;
		case TE_CSQC_RACE:
			Net_ReadRace();
			bHandled = true;
			break;
		case 13: // TE_BEAM
			Net_GrapplingHook();
			bHandled = true;
			break;
		case TE_CSQC_SPAWN:
			Net_ReadSpawn();
			bHandled = true;
			break;
		case TE_CSQC_ZCURVEPARTICLES:
			Net_ReadZCurveParticles();
			bHandled = true;
			break;
		case TE_CSQC_NEXGUNBEAMPARTICLE:
			Net_ReadNexgunBeamParticle();
			bHandled = true;
			break;
		case TE_CSQC_TEAMNAGGER:
			Net_TeamNagger();
			bHandled = true;
			break;
		case TE_CSQC_VOTE:
			Net_VoteDialog(ReadByte());
			bHandled = true;
			break;
		case TE_CSQC_VOTERESET:
			Net_VoteDialogReset();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARC:
			Net_ReadLightningarc();
			bHandled = true;
			break;
		case TE_CSQC_PINGPLREPORT:
			Net_ReadPingPLReport();
			bHandled = true;
			break;
		case TE_CSQC_ANNOUNCE:
			announce_snd = strzone(ReadString());
			bHandled = true;
			break;
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = false;
			break;
	}

	return bHandled;
}

string getcommandkey(string text, string command)
{
	string keys;
	float n, j, k, l;

	if (!sbar_showbinds)
		return text;

	keys = db_get(binddb, command);
	if (!keys)
	{
		n = tokenize(findkeysforcommand(command)); // uses '...' strings
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
			{
				if ("" == keys)
					keys = keynumtostring(k);
				else
					keys = strcat(keys, ", ", keynumtostring(k));

				++l;
				if (sbar_showbinds_limit > 0 && sbar_showbinds_limit >= l) break;
			}

		}
		db_put(binddb, command, keys);
	}

	if ("" == keys) {
		if (sbar_showbinds > 1)
			return strcat(text, " (not bound)");
		else
			return text;
	}
	else if (sbar_showbinds > 1)
		return strcat(text, " (", keys, ")");
	else
		return keys;
}
