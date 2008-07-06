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
float databuf;
float using_gps;

void CSQC_Init(void)
{
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

	registercvar("sbar_usecsqc", "1");

	gametype = 0;

	gps_start = world;

	postinit = false;
}

void PostInit(void)
{
	float i;
	entity pl;

	print(strcat("PostInit\n    maxclients = ", ftos(maxclients), "\n"));
	databuf = buf_create();
	for(i = 0; i < maxclients; ++i)
	{
		bufstr_set(databuf, DATABUF_PING + i, "N/A");
		bufstr_set(databuf, DATABUF_CAPTURES + i, "0");
	}

	postinit = true;
}
// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void CSQC_Shutdown(void)
{
	buf_del(databuf);
}

// CSQC_ConsoleCommand : Used to parse commands in the console that have been registered with the "registercmd" function
// Return value should be 1 if CSQC handled the command, otherwise return 0 to have the engine handle it.
float CSQC_ConsoleCommand(string strMessage)
{
	local float nReturn;
		nReturn = FALSE;
		
	// Tokenize String
	tokenize(strMessage);
	
	// Acquire Command
	local string strCmd;
	strCmd = argv(0);

	/*if(strCmd == "ctf_menu") {
		ctf_menu_show();
		nReturn = TRUE;
		} else*/
	if(strCmd == "ons_map") {
		Cmd_ons_map();
		nReturn = TRUE;
	}
	
	return nReturn;
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

	draw_enginesbar = true;
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
			print(strcat("^1Error: ^7Mapinfo file '", mapinfo, "' missing! Minimap will be screwed.\n"));
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
		draw_enginesbar = false;
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

void ReadInit()
{
	maxclients = ReadByte();
}

void ReadPings()
{
	float plnum, ping;
	for(plnum = ReadByte(); plnum != 0; plnum = ReadByte())
	{
		ping = ReadShort();
		bufstr_set(databuf, DATABUF_PING + plnum-1, ftos(ping));
	}
}

void ReadCaptures()
{
	float plnum, caps;
	entity pl;
	caps_team1 = ReadByte();
	caps_team2 = ReadByte();
	for(plnum = ReadByte(); plnum != 0; plnum = ReadByte())
	{
		caps = ReadByte();
		//print(strcat("Cap update: ", ftos(plnum), " has ", ftos(caps), " caps\n"));
		//print(strcat("Index: ", ftos(DATABUF_CAPTURES + plnum-1), " -- I AM: ", ftos(player_localentnum), "\n"));
		bufstr_set(databuf, DATABUF_CAPTURES + plnum-1, ftos(caps));
	}
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
		
	switch(nTEID)
	{
		case TE_CSQC_INIT:
			ReadInit();
			bHandled = true;
			break;
		case TE_CSQC_PING:
			ReadPings();
			bHandled = true;
			break;
		case TE_CSQC_CAPTURES:
			ReadCaptures();
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
