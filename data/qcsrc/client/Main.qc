// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS
//include "main.qh"

#define DP_CSQC_ENTITY_REMOVE_IS_B0RKED

void() menu_show_error =
{
	drawstring('0 200 0', "ERROR - MENU IS VISIBLE BUT NO MENU WAS DEFINED!", '8 8 0', '1 0 0', 1, 0);
};

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
// Useful for precaching things

void() menu_sub_null =
{
};

// let's make this a general data buffer...
float using_gps;

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

	configdb = db_create();

	drawfont = 0;
	menu_visible = FALSE;
	menu_show = menu_show_error;
	menu_action = menu_sub_null;
	using_gps = false;
	maxclients = 255; // we later get the real maxclients to speed up stuff
	//ctf_temp_1 = "";
	// localcmd("alias order \"cmd order $*\""); enable if ctf-command thingy is used
	//registercmd("ctf_menu");
	registercmd("ons_map");
	//registercmd("menu_action");
	registercmd("sbar_columns_set");
	registercmd("sbar_columns_help");

	registercvar("sbar_usecsqc", "1");
	registercvar("sbar_columns", "default", CVAR_SAVE);

	gametype = 0;

	gps_start = world;

	// sbar_fields uses strunzone on the titles!
	for(i = 0; i < MAX_SBAR_FIELDS; ++i)
		sbar_title[i] = strzone("(null)");

	postinit = false;

	teams = Sort_Spawn();
	players = Sort_Spawn();
	
	GetTeam(COLOR_SPECTATOR, true); // add specs first
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

	entity e;
	for(e = world; (e = find(e, classname, "saved_cvar_value")); )
			cvar_set(e.netname, e.message);
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
	for(i = 0; i < maxclients; ++i)
	{
		if(getplayerkey(i, "name") == "")
		{
			if(playerslots[i].sort_prev)
			{
				//print("playerchecker: KILL KILL KILL\n");
				// player disconnected
				SetTeam(playerslots[i], -1);
				RemovePlayer(playerslots[i]);
				playerslots[i].sort_prev = world;
				playerslots[i].gotscores = 0;
			}
		}
		else
		{
			if not(playerslots[i].sort_prev)
			{
				//print("playerchecker: SPAWN SPAWN SPAWN\n");
				// player connected
				if not(playerslots[i])
					playerslots[i] = spawn();
				playerslots[i].sv_entnum = i;
				playerslots[i].gotscores = 0;
				SetTeam(playerslots[i], COLOR_SPECTATOR);
				RegisterPlayer(playerslots[i]);
				Sbar_UpdatePlayerPos(playerslots[i]);
			}
		}
	}
	self.nextthink = time + 0.2;
}

void PostInit(void)
{
	print(strcat("PostInit\n    maxclients = ", ftos(maxclients), "\n"));
	localcmd(strcat("\nsbar_columns_set ", cvar_string("sbar_columns"), ";\n"));

	entity playerchecker;
	playerchecker = spawn();
	playerchecker.think = Playerchecker_Think;
	playerchecker.nextthink = time + 0.2;

	postinit = true;
}

// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
void Cmd_Sbar_SetFields(float);
void Cmd_Sbar_Help(float);
float CSQC_ConsoleCommand(string strMessage)
{
	float argc;
	// Tokenize String
	//argc = tokenize(strMessage);
	argc = tokenizebyseparator(strMessage, " ");
	
	// Acquire Command
	local string strCmd;
	strCmd = argv(0);

	/*if(strCmd == "ctf_menu") {
		ctf_menu_show();
		nReturn = true;
		} else*/
	if(strCmd == "ons_map") {
		Cmd_ons_map();
		return true;
	} else if(strCmd == "sbar_columns_set") {
		Cmd_Sbar_SetFields(argc);
		return true;
	} else if(strCmd == "sbar_columns_help") {
		Cmd_Sbar_Help(argc);
		return true;
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
	argc = tokenize(msg);
	string cmd;
	cmd = argv(0);
	if(cmd == "mv_download") {
		Cmd_MapVote_MapDownload(argc);
		return true;
	}
	else if(cmd == "settemp") {
		entity e;
		for(e = world; (e = find(e, classname, "saved_cvar_value")); )
			if(e.netname == argv(1))
				goto saved;
		e = spawn();
		e.classname = "saved_cvar_value";
		e.netname = strzone(argv(1));
		e.message = strzone(cvar_string(argv(1)));
:saved
		cvar_set(argv(1), argv(2));
	}
	
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
void Ent_ReadONS()
{
	entity gps;
	using_gps = true;

	self.origin_x = ReadCoord();
	self.origin_y = ReadCoord();
	self.angles_y = ReadCoord();
	self.origin_z = self.angles_x = self.angles_z = 0;

	for(gps = gps_start; gps; gps = gps.chain)
	{
		if(gps == self)
			break;
	}
	if(!gps)
	{
		self.chain = gps_start;
		gps_start = self;
	}
}

void Ent_RemoveONS()
{
	if(gps_start == self)
		gps_start = self.chain;
	else
	{
		local entity ent;
		ent = gps_start;
			
		while(ent.chain != self && ent.chain != world)
			ent = ent.chain;
		if(ent.chain == self)
			ent.chain = self.chain;
	}
}

void Ent_Remove();
void Ent_ReadPlayerScore()
{
	float i, Team, n;
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
	Team = GetPlayerColor(self.sv_entnum);

	if not(playerslots[self.sv_entnum])
		playerslots[self.sv_entnum] = spawn();
	o = self.owner = playerslots[self.sv_entnum];
	o.sv_entnum = self.sv_entnum;
	o.gotscores = 1;
	if not(o.sort_prev)
		RegisterPlayer(o);

	SetTeam(o, Team);

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

	Sbar_UpdatePlayerPos(o);
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

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void(float bIsNewEntity) CSQC_Ent_Update =
{
	float msg, t;
	t = ReadByte();
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
	{
		self.sv_entnum = ReadByte()-1;

		for(msg = ReadByte(); msg != ENTCS_MSG_END; msg = ReadByte())
		{
			switch(msg)
			{
			case ENTCS_MSG_ONS_GPS: Ent_ReadONS(); break;
			case ENTCS_MSG_ONS_REMOVE: Ent_RemoveONS(); break;
			default:
				error("unknown ENTCS_MSG type\n");
			}
		}
	}
	else if(self.enttype == ENT_CLIENT_SCORES)
		Ent_ReadPlayerScore();
	else if(self.enttype == ENT_CLIENT_TEAMSCORES)
		Ent_ReadTeamScore();
	else
		error("unknown entity type in CSQC_Ent_Update\n");
	
};
// Destructor, but does NOT deallocate the entity by calling remove(). Also
// used when an entity changes its type. For an entity that someone interacts
// with others, make sure it can no longer do so.
void Ent_Remove()
{
	if(self.enttype == ENT_CLIENT_ENTCS)
	{
		if(using_gps) //gametype == GAME_ONSLAUGHT)
		{
			if(gps_start == self)
				gps_start = self.chain;
			else
			{
				local entity ent;
				ent = gps_start;
			
				while(ent.chain != self && ent.chain != world)
					ent = ent.chain;
				if(ent.chain == self)
					ent.chain = self.chain;
			}
		}
	} else if(self.enttype == ENT_CLIENT_SCORES)
	{
		if(self.owner)
		{
			SetTeam(self.owner, -1);
			if(self.owner.sort_prev)
				RemovePlayer(self.owner);
			self.owner.sort_prev = NULL;
		}
	} else if(self.enttype == ENT_CLIENT_TEAMSCORES)
	{
		/*
		if(self.owner)
			RemoveTeam(self.owner);
		*/
		// we don't NEED to remove them... they won't display anyway
		// plus, svqc never does this anyway
	}

	self.enttype = 0;
	self.classname = "";
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
	local string mapinfo, infoline;
	local float len;
	local float file;
	local vector mi_min, mi_max;

	if(!strcasecmp(substring(mapname, 0, 5), "maps/"))
		shortmapname = substring(mapname, 5, 999);
	else
		shortmapname = mapname;
	len = strlen(shortmapname);
	if(!strcasecmp(substring(shortmapname, len-4, 4), ".bsp"))
		shortmapname = substring(shortmapname, 0, len-4);
	shortmapname = strzone(shortmapname);

	if(gametype == GAME_ONSLAUGHT) {
		mapinfo = strcat("maps/", minimapname, ".info");
		minimapname = strzone(strcat("gfx/", shortmapname, "_mini.tga"));

		mi_min = world.mins;
		mi_max = world.maxs;
		
		file = fopen(mapinfo, FILE_READ);
		if(file >= 0) {
			while((infoline = fgets(file))) {
				if(!strncasecmp(infoline, "mins", 4)) {
					mi_min = stov(substring(infoline, 5, 999));
				} else if(!strncasecmp(infoline, "maxs", 4)) {
					mi_max = stov(substring(infoline, 5, 999));
				} else if(strncasecmp(infoline, "//", 2)) { // don't print comment-style lines
					print(strcat("mapinfo: ", infoline, "\n"));
				}
			}
		} else {
			print(strcat("Map has no .info file (", mapinfo, ").\n"));
		}
		fclose(file);

		print(strcat("Mins: ", vtos(mi_min), "    Maxs: ", vtos(mi_max), "\n"));
		
		mi_center = (mi_min + mi_max) * 0.5;
		mi_scale = mi_max - mi_min;
		
		
		print(strcat("Using ", minimapname, " as minimap.\n"));
		precache_pic(minimapname);
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
	print(strMessage);
}
// CSQC_Parse_CenterPrint : Provides the centerprint string in the first parameter that the server provided.  To execute standard behavior, simply execute cprint with the string.
void CSQC_Parse_CenterPrint(string strMessage)
{
	cprint(strMessage);
}

void CSQC_CheckRevision();

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
	csqc_revision = ReadShort();
	maxclients = ReadByte();

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
			race_previousbestname = strzone(ReadString());

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
			race_nextbestname = strzone(ReadString());
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
			race_mycheckpointenemy = strzone(ReadString());
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
			race_othercheckpointenemy = strzone(ReadString());
			break;
	}
}

void Net_ReadForceScoreboard()
{
	sb_showscores_force = ReadByte();
}

void Net_Reset()
{
	race_laptime = 0;
	race_checkpointtime = 0;
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
