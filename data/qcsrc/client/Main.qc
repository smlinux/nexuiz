// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS
//include "main.qh"

void() menu_show_error =
{
	drawstring('0 200', "ERROR - MENU IS VISIBLE BUT NO MENU WAS DEFINED!", '8 8 0', '1 0 0', 1, 0);
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
	drawfont = 0;
	menu_visible = FALSE;
	menu_show = menu_show_error;
	menu_action = menu_sub_null;
	using_gps = false;
	//ctf_temp_1 = "";
	localcmd("alias order \"cmd order $*\"");
	//registercmd("ctf_menu");
	registercmd("ons_map");
	//registercmd("menu_action");
	registercmd("sbar_columns_set");
	registercmd("sbar_columns_help");

	registercvar("sbar_usecsqc", "1");
	registercvar("sbar_columns", "ping name | caps returns frags deaths", CVAR_SAVE);

	gametype = 0;

	gps_start = world;

	// sbar_fields uses strunzone on the titles!
	for(i = 0; i < MAX_SBAR_FIELDS; ++i)
		sbar_title[i] = strzone("(null)");

	postinit = false;

	Sbar_Init();
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
	buf_del(databuf);
}

void PostInit(void)
{
	float i;

	print(strcat("PostInit\n    maxclients = ", ftos(maxclients), "\n"));
	databuf = buf_create();
	for(i = 0; i < maxclients; ++i)
	{
		bufstr_set(databuf, DATABUF_PING + i, "N/A");
		bufstr_set(databuf, DATABUF_DEATHS + i, "0");
		bufstr_set(databuf, DATABUF_CAPTURES + i, "0");
		bufstr_set(databuf, DATABUF_RETURNS + i, "0");
	}
	
	localcmd(strcat("\nsbar_columns_set ", cvar_string("sbar_columns"), ";\n"));

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
	argc = tokenize(strMessage);
	
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
void ReadONS()
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

void RemoveONS()
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

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void(float bIsNewEntity) CSQC_Ent_Update =
{
	float msg;
	self.enttype = ReadByte();
	if(self.enttype == ENT_CLIENT_ENTCS)
	{
		self.sv_entnum = ReadByte()-1;

		for(msg = ReadByte(); msg != ENTCS_MSG_END; msg = ReadByte())
		{
			switch(msg)
			{
			case ENTCS_MSG_ONS_GPS: ReadONS(); break;
			case ENTCS_MSG_ONS_REMOVE: RemoveONS(); break;
			default:
				error("unknown ENTCS_MSG type\n");
			}
		}
	}
	else
		error("unknown entity type in CSQC_Ent_Update\n");
	
};
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
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
	}
	remove(self);
}

void Gamemode_Init()
{
	local string mapinfo, infoline;
	local float len;
	local float file;
	local vector mi_min, mi_max;

	gametype = cvar("gametype");
	if(gametype == GAME_ONSLAUGHT) {
		if(!strcasecmp(substring(mapname, 0, 5), "maps/"))
			minimapname = substring(mapname, 5, 999);
		else
			minimapname = mapname;
		len = strlen(minimapname);
		if(!strcasecmp(substring(minimapname, len-4, 4), ".bsp"))
			minimapname = substring(minimapname, 0, len-4);
		
		mapinfo = strcat("maps/", minimapname, ".info");
		minimapname = strzone(strcat("gfx/", minimapname, "_mini.tga"));

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
	// watch for gametype changes!
	if(gametype != cvar("gametype"))
	{
		Gamemode_Init();
	}
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

void Net_ReadInit()
{
	csqc_revision = ReadShort();
	maxclients = ReadByte();

	CSQC_CheckRevision();
}

void Net_ReadPings()
{
	float plnum, ping;
	for(plnum = ReadByte(); plnum != 0; plnum = ReadByte())
	{
		ping = ReadShort();
		bufstr_set(databuf, DATABUF_PING + plnum-1, ftos(ping));
	}
}

void Net_ReadCaptures()
{
	float plnum, caps, mode;
	mode = ReadByte();
	caps_team1 = ReadByte();
	caps_team2 = ReadByte();
	for(plnum = ReadByte(); plnum != 0; plnum = ReadByte())
	{
		caps = ReadByte();
		bufstr_set(databuf, DATABUF_CAPTURES + plnum-1, ftos(caps));
	}
}

void Net_ReadDatabuf(float ofs)
{
	float plnum, data;
	for(plnum = ReadByte(); plnum != 0; plnum = ReadByte())
	{
		data = ReadByte();
		bufstr_set(databuf, ofs + plnum-1, ftos(data));
	}
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
		case TE_CSQC_PING:
			Net_ReadPings();
			bHandled = true;
			break;
		case TE_CSQC_CAPTURES:
			Net_ReadCaptures();
			bHandled = true;
			break;
		case TE_CSQC_RETURNS:
			Net_ReadDatabuf(DATABUF_RETURNS);
			bHandled = true;
			break;
		case TE_CSQC_DEATHS:
			Net_ReadDatabuf(DATABUF_DEATHS);
			bHandled = true;
			break;
		case TE_CSQC_MAPVOTE:
			Net_Mapvote();
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
float csqc_svn_map[CSQC_REVISION] =
{
	3812, // 3795,
	3820 // mapvote protocol changed from there
};

// COMMIT-TODO: Update if necessare, before committing
void CSQC_CheckRevision()
{
	if(csqc_revision == CSQC_REVISION)
	{
		print("^2SVQC and CSQC revisions are compatible.\n");
	} else if(csqc_revision < CSQC_REVISION) {
		print("^1Your csprogs.dat (CSQC) version is newer than the one on the server.\n");
		print("^1The last known svn revision for the server's CSQC is: ^7");
		print(ftos(csqc_svn_map[csqc_revision])); // don't use strcat, fteqcc loves screwing up arrays...
		print("\n");
	} else if(csqc_revision > CSQC_REVISION) {
		print("^1Your csprogs.dat (CSQC) is too old for this server.\n");
		print("^1Please update to a newer version.\n");
	}
}
