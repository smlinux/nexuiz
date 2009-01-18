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

string config_get(string key, string defaultvalue)
{
	string s;
	s = db_get(configdb, strcat("/s/", key));
	if(s == "")
		return defaultvalue;
	else
		return db_get(configdb, strcat("/v/", key));
}

string forcefog;
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
	
	float i;
	CSQC_CheckEngine();
	dprint_load();

	configdb = db_create();
	binddb = db_create();
	tempdb = db_create();
	compressShortVector_init();

	drawfont = 0;
	menu_visible = FALSE;
	menu_show = menu_show_error;
	menu_action = menu_sub_null;
	maxclients = 255; // we later get the real maxclients to speed up stuff
	//ctf_temp_1 = "";
	// localcmd("alias order \"cmd order $*\""); enable if ctf-command thingy is used
	//registercmd("ctf_menu");
	registercmd("ons_map");
	//registercmd("menu_action");
	registercmd("sbar_columns_set");
	registercmd("sbar_columns_help");

	registercmd("+button3");
	registercmd("-button3");
	registercmd("+button4");
	registercmd("-button4");

	registercvar("sbar_usecsqc", "1");
	registercvar("sbar_columns", "default", CVAR_SAVE);

	gametype = 0;

	// sbar_fields uses strunzone on the titles!
	for(i = 0; i < MAX_SBAR_FIELDS; ++i)
		sbar_title[i] = strzone("(null)");

	postinit = false;

	teams = Sort_Spawn();
	players = Sort_Spawn();
	
	GetTeam(COLOR_SPECTATOR, true); // add specs first

	cvar_clientsettemp("_supports_weaponpriority", "1");




	cs_project_is_b0rked = TRUE;
	R_SetView(VF_VIEWPORT, '0 0 0', '640 480 0');
	R_SetView(VF_FOV, '90 90 0');
	R_SetView(VF_ORIGIN, '0 0 0');
	R_SetView(VF_ANGLES, '0 0 0');
	R_SetView(VF_PERSPECTIVE, 1);
	makevectors('0 0 0');
	vector v;
	v = cs_project(v_forward);
	if(v_x - 320 < +1)
	if(v_x - 320 > -1)
	if(v_y - 240 < +1)
	if(v_y - 240 > -1)
		cs_project_is_b0rked = FALSE;

	RegisterWeapons();

	WaypointSprite_Load();

	Projectile_Precache();
	GibSplash_Precache();
	Casings_Precache();
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

	remove(teams);
	remove(players);
	db_close(configdb);
	db_close(binddb);
	db_close(tempdb);

	cvar_clientsettemp_restore();
}

.float has_team;
float SetTeam(entity o, float Team)
{
	entity tm;
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
void PostInit(void)
{
	print(strcat("PostInit\n    maxclients = ", ftos(maxclients), "\n"));
	localcmd(strcat("\nsbar_columns_set ", cvar_string("sbar_columns"), ";\n"));

	entity playerchecker;
	playerchecker = spawn();
	playerchecker.think = Playerchecker_Think;
	playerchecker.nextthink = time + 0.2;

	Porto_Init();

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
	argc = tokenize_sane(strMessage);
	
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
	}
	
	return false;
}

float GameCommand(string msg)
{
	float argc;
	argc = tokenize_sane(msg);
	string cmd;
	cmd = argv(0);
	if(cmd == "mv_download") {
		Cmd_MapVote_MapDownload(argc);
		return true;
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
	
	return false;
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

void Ent_RemoveEntCS()
{
}

void Ent_Remove();
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

#if MAX_SCORE <= 3
	for(i = 0; i < MAX_SCORE; ++i)
		o.(scores[i]) = ReadShort();
#else
	float sf;
#if MAX_SCORE <= 8
	sf = ReadByte();
#else
	sf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_SCORE; ++i, p *= 2)
		if(sf & p)
			o.(scores[i]) = ReadShort();
#endif

	if(o.sort_prev)
		Sbar_UpdatePlayerPos(o); // if not registered, we cannot do this yet!
}

void Ent_ReadTeamScore()
{
	float i;
	entity o;
	
	self.team = ReadByte();
	o = self.owner = GetTeam(self.team, true);

#if MAX_TEAMSCORE <= 3
	for(i = 0; i < MAX_TEAMSCORE; ++i)
		o.(teamscores[i]) = ReadShort();
#else
	float sf;
#if MAX_TEAMSCORE <= 8
	sf = ReadByte();
#else
	sf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_TEAMSCORE; ++i, p *= 2)
		if(sf & p)
			o.(teamscores[i]) = ReadShort();
#endif

	Sbar_UpdateTeamPos(o);
}

void Ent_Nagger()
{
	float nags;

	nags = ReadByte();

	if(nags & 128)
	{
		if(vote_called_vote)
			strunzone(vote_called_vote);
		vote_called_vote = strzone(ColorTranslateRGB(ReadString()));
	}

	ready_waiting = (nags & 1);
	ready_waiting_for_me = (nags & 2);
	vote_waiting = (nags & 4);
	vote_waiting_for_me = (nags & 8);
}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void Ent_RadarLink();
void(float bIsNewEntity) CSQC_Ent_Update =
{
	float t;
	float savetime;
	t = ReadByte();

	// set up the "time" global for received entities to be correct for interpolation purposes
	savetime = time;
	if(servertime)
		time = servertime;

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if(self.enttype)
		if(t != self.enttype)
		{
			print("A CSQC entity changed its type!\n");
			Ent_Remove();
		}
#endif
	self.enttype = t;
	if(self.enttype == ENT_CLIENT_ENTCS)
		Ent_ReadEntCS();
	else if(self.enttype == ENT_CLIENT_SCORES)
		Ent_ReadPlayerScore();
	else if(self.enttype == ENT_CLIENT_TEAMSCORES)
		Ent_ReadTeamScore();
	else if(self.enttype == ENT_CLIENT_POINTPARTICLES)
		Ent_PointParticles();
	else if(self.enttype == ENT_CLIENT_RAINSNOW)
		Ent_RainOrSnow();
	else if(self.enttype == ENT_CLIENT_LASER)
		Ent_Laser();
	else if(self.enttype == ENT_CLIENT_NAGGER)
		Ent_Nagger();
	else if(self.enttype == ENT_CLIENT_WAYPOINT)
		Ent_WaypointSprite();
	else if(self.enttype == ENT_CLIENT_RADARLINK)
		Ent_RadarLink();
	else if(self.enttype == ENT_CLIENT_PROJECTILE)
		Ent_Projectile();
	else if(self.enttype == ENT_CLIENT_GIBSPLASH)
		Ent_GibSplash();
	else if(self.enttype == ENT_CLIENT_DAMAGEINFO)
		Ent_DamageInfo();
	else if(self.enttype == ENT_CLIENT_CASING)
		Ent_Casing();
	else
		error(strcat("unknown entity type in CSQC_Ent_Update: ", ftos(self.enttype), "\n"));
	
	time = savetime;
};
// Destructor, but does NOT deallocate the entity by calling remove(). Also
// used when an entity changes its type. For an entity that someone interacts
// with others, make sure it can no longer do so.
void Ent_Remove()
{
	float i;
	if(self.enttype == ENT_CLIENT_ENTCS)
	{
		Ent_RemoveEntCS();
	} else if(self.enttype == ENT_CLIENT_SCORES)
	{
		if(self.owner)
		{
			SetTeam(self.owner, -1);
			self.owner.gotscores = 0;
			for(i = 0; i < MAX_SCORE; ++i)
				self.owner.(scores[i]) = 0; // clear all scores
		}
	} else if(self.enttype == ENT_CLIENT_TEAMSCORES)
	{
		/*
		if(self.owner)
			RemoveTeam(self.owner);
		*/
		// we don't NEED to remove them... they won't display anyway
		// plus, svqc never does this anyway
	} else if(self.enttype == ENT_CLIENT_POINTPARTICLES)
	{
		Ent_PointParticles_Remove();
	}
	else if(self.enttype == ENT_CLIENT_WAYPOINT)
		Ent_RemoveWaypointSprite();
	else if(self.enttype == ENT_CLIENT_PROJECTILE)
		Ent_RemoveProjectile();

	self.enttype = 0;
	self.classname = "";
	self.draw = menu_sub_null;
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
// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.  To execute standard behavior, simply execute cprint with the string.
void CSQC_Parse_CenterPrint(string strMessage)
{
	cprint(ColorTranslateRGB(strMessage));
}

void CSQC_CheckRevision();

void Fog_Force()
{
	// TODO somehow thwart prvm_globalset client ...

	if(forcefog != "")
		localcmd(strcat("\nfog ", forcefog, "\nr_fog_exp2 0\nr_drawfog 1\n"));
}

void Net_ReadFog()
{
	if(forcefog)
		strunzone(forcefog);
	ReadCoord(); // ignore fog interval
	forcefog = strzone(ReadString());
}

void Gamemode_Init();
void Net_ReadScoresInfo()
{
	float i;
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

void Net_ReadInit()
{
	float i;
	csqc_revision = ReadShort();
	maxclients = ReadByte();
	for(i = 0; i < 24; ++i)
		weaponimpulse[i] = ReadByte() - 1;
	hook_shotorigin_x = ReadCoord();
	hook_shotorigin_y = ReadCoord();
	hook_shotorigin_z = ReadCoord();
	CSQC_CheckRevision();
}

string Net_ReadPicture()
{
	string img;
	if(csqc_flags & CSQC_FLAG_READPICTURE)
	{
		img = ReadPicture();
		print(strcat("Got Picture: ", img, "\n"));
	} else {
		img = ReadString();
		print(strcat("^3Warning: ^7Couldn't download ", img, ". This is probably because your engine build is outdated.\n"));
		float psize, i;
		psize = ReadShort();
		// Can I be sure that ReadShort is 2 bytes and ReadLong is 4 bytes?
		// Because then this could be optimized to first get all 4-byte-groups,
		// then the remaining 2, then the remaining 1
		for(i = 0; i < psize; ++i)
			ReadByte();
	}
	return img;
}

void Net_Config()
{
	string key, value;
	key = ReadString();
	value = ReadString();
	db_put(configdb, strcat("/v/", key), value);
	db_put(configdb, strcat("/s/", key), "1");
}

void Net_ReadRace()
{
	float b;

	b = ReadByte();

	switch(b)
	{
		case RACE_NET_CHECKPOINT_HIT_QUALIFYING:
			race_checkpoint = ReadByte();
			race_time = ReadShort();
			race_previousbesttime = ReadShort();
			if(race_previousbestname)
				strunzone(race_previousbestname);
			race_previousbestname = strzone(ColorTranslateRGB(ReadString()));

			race_checkpointtime = time;

			if(race_checkpoint == 0)
				race_laptime = time; // valid

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

			race_nextbesttime = ReadShort();
			if(race_nextbestname)
				strunzone(race_nextbestname);
			race_nextbestname = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_CHECKPOINT_HIT_RACE:
			race_mycheckpoint = ReadByte();
			race_mycheckpointtime = time;
			race_mycheckpointdelta = ReadShort();
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
			race_othercheckpointdelta = ReadShort();
			race_othercheckpointlapsdelta = ReadByte();
			if(race_othercheckpointlapsdelta >= 128)
				race_othercheckpointlapsdelta -= 256;
			if(race_othercheckpointenemy)
				strunzone(race_othercheckpointenemy);
			race_othercheckpointenemy = strzone(ColorTranslateRGB(ReadString()));
			break;
	}
}

void Net_ReadForceScoreboard()
{
	sb_showscores_force = ReadByte();
}

void Net_Reset()
{
	float i;
	race_laptime = 0;
	race_checkpointtime = 0;
	for(i = 0; i < 24; ++i)
		angles_held_status[i] = 0;
}

void Net_ReadSpectating()
{
	float newspectatee_status;
	newspectatee_status = ReadByte();
	if(newspectatee_status == player_localentnum)
		newspectatee_status = -1; // observing
	if(newspectatee_status != spectatee_status)
		Net_Reset();
	spectatee_status = newspectatee_status;
}

void Net_ReadZoomNotify()
{
	spectatorbutton_zoom = ReadByte();
}

void Net_ReadSpawn()
{
	zoomin_effect = 1;
	current_viewzoom = 0.6;
}

void Net_ReadWarmupStage()
{
	warmup_stage = ReadByte();
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
void Net_ReadHoldAngles();
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
		case TE_CSQC_INIT:
			Net_ReadInit();
			bHandled = true;
			break;
		case TE_CSQC_MAPVOTE:
			Net_Mapvote();
			bHandled = true;
			break;
		case TE_CSQC_CONFIG:
			Net_Config();
			bHandled = true;
			break;
		case TE_CSQC_SCORESINFO:
			Net_ReadScoresInfo();
			bHandled = true;
			break;
		case TE_CSQC_RACE:
			Net_ReadRace();
			bHandled = true;
			break;
		case TE_CSQC_FORCESCOREBOARD:
			Net_ReadForceScoreboard();
			bHandled = true;
			break;
		case TE_CSQC_SPECTATING:
			Net_ReadSpectating();
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
		case TE_CSQC_ZOOMNOTIFY:
			Net_ReadZoomNotify();
			bHandled = true;
			break;
		case TE_CSQC_HOLDANGLES:
			Net_ReadHoldAngles();
			bHandled = true;
			break;
		case TE_CSQC_WARMUP:
			Net_ReadWarmupStage();
			bHandled = true;
			break;
		case TE_CSQC_FOG:
			Net_ReadFog();
			bHandled = true;
			break;
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = false;
			break;
	}
	
	if(!postinit)
		PostInit();
		
	return bHandled;
}

// COMMIT-TODO: Update if necessare, before committing
void CSQC_CheckRevision()
{
	if(csqc_revision == CSQC_REVISION)
	{
		print("^2SVQC and CSQC revisions are compatible.\n");
	} else if(csqc_revision < CSQC_REVISION) {
		print("^1Your csprogs.dat (CSQC) version is newer than the one on the server.\n");
	} else if(csqc_revision > CSQC_REVISION) {
		print("^1Your csprogs.dat (CSQC) is too old for this server.\n");
		print("^1Please update to a newer version.\n");
	}
}

string getcommandkey(string text, string command)
{
	string keys;
	float n, j, k, l;

	if (!sbar_showbinds)
		return text;

	keys = db_get(binddb, command);
	if(csqc_flags & CSQC_FLAG_READPICTURE)
	{
		if (!keys) 
		{
			n = tokenize_insane(findkeysforcommand(command)); // uses '...' strings
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
