bool _Nex_ExtResponseSystem_RequestsSent;
bool _Nex_ExtResponseSystem_VersionHandled;
bool _Nex_ExtResponseSystem_BanlistHandled;
string _Nex_ExtResponseSystem_UpdateTo;
float _Nex_ExtResponseSystem_RetryTime;
float _Nex_ExtResponseSystem_RetryTime_LastDelay;
bool _Nex_ExtResponseSystem_UpdateStringSet;
bool _Nex_ExtResponseSystem_Initialized;

void() Item_Nex_ExtResponseSystem_SendQuery =
{
	dprint("Sending extended response requests...\n");
	localcmd(strcat("packet update.alientrap.org:27950 \"getExtResponse checkUpdates nexuiz ", cvar_string("g_nexuizversion"), "\"\n"));
	localcmd(strcat("packet update.alientrap.org:27950 \"getExtResponse getBanlist nexuiz\"\n"));
	_Nex_ExtResponseSystem_RequestsSent = TRUE;
	_Nex_ExtResponseSystem_RetryTime_LastDelay = _Nex_ExtResponseSystem_RetryTime_LastDelay * 2 + 1;
	_Nex_ExtResponseSystem_RetryTime = Timer_Time + _Nex_ExtResponseSystem_RetryTime_LastDelay;
}

void(float argc) Item_Nex_ExtResponseSystem_Parse =
{
	float i;
	string banlist;
	dprint("Received extended response packet from ", argv(0), "\n");
	if(!_Nex_ExtResponseSystem_RequestsSent)
	{
		dprint("  But I haven't sent a request yet! Ignoring.\n");
		return;
	}
	if(argv(1) == "noUpdateAvailable")
	{
		if(_Nex_ExtResponseSystem_VersionHandled)
		{
			dprint("  duplicated update notice, ignored\n");
			return;
		}
		_Nex_ExtResponseSystem_VersionHandled = TRUE;
	}
	else if(argv(1) == "updateAvailable")
	{
		if(_Nex_ExtResponseSystem_VersionHandled)
		{
			dprint("  duplicated update notice, ignored\n");
			return;
		}
		_Nex_ExtResponseSystem_VersionHandled = TRUE;
		_Nex_ExtResponseSystem_UpdateTo = strzone(argv(2)); // note: only one packet can be handled, so this can't be a leak
		//Nex_MessageBox("Update available!", strcat("We recommend you to download Nexuiz ", _Nex_ExtResponseSystem_UpdateTo, " from http://www.nexuiz.com/"), "Ok", "Download in background", Util_NullFunction, Util_NullFunction);
	}
	else if(argv(1) == "banlist")
	{
		if(_Nex_ExtResponseSystem_BanlistHandled)
		{
			dprint("  duplicated banlist notice\n");
			return;
		}
		_Nex_ExtResponseSystem_BanlistHandled = TRUE;
		dprint("  BANLIST RECEIVED:");

		if(cvar_string("net_banlist") == cvar_string("_alientrap_net_banlist"))
		{
			banlist = ""; // IP of www.alientrap.org
			for(i = 0; i < argc - 2; ++i)
			{
				banlist = strcat(banlist, argv(i + 2), " ");
				dprint(" ", argv(i + 2));
			}
			dprint(" (", ftos(i), " items)\n");
			cvar_set("net_banlist", banlist);
			cvar_set("_alientrap_net_banlist", banlist);
		}
		else
		{
			for(i = 0; i < argc - 2; ++i)
				dprint(" ", argv(i + 2));
			dprint(" (", ftos(i), " items; overridden by user setting)\n");
		}
	}
	else
		dprint("  UNKNOWN RESPONSE TYPE: ", argv(1), "\n");
}

void() Item_Nex_ExtResponseSystem_CheckForResponse =
{
	local string s;
	local float argc;
	while(strlen((s = getextresponse())))
	{
		argc = tokenize(s);
		Item_Nex_ExtResponseSystem_Parse(argc);
	}
}

void() Item_Nex_ExtResponseSystem_Update =
{
	Item_Nex_ExtResponseSystem_CheckForResponse();

	if(!_Nex_ExtResponseSystem_VersionHandled)
		if(Timer_Time > _Nex_ExtResponseSystem_RetryTime)
			Item_Nex_ExtResponseSystem_SendQuery();

	if(_Nex_ExtResponseSystem_UpdateTo)
		if(!_Nex_ExtResponseSystem_UpdateStringSet)
		{
			local string filler;
			local float count;

			filler = "";
			for(count = strlen(_Nex_ExtResponseSystem_UpdateTo); count < 5; ++count)
				filler = strcat(filler, " ");

			String_EntitySet(self, text, strcat(filler, "Update to Nexuiz ", _Nex_ExtResponseSystem_UpdateTo, " on:"));
			self.size = '0 0 0';
			_Nex_ExtResponseSystem_UpdateStringSet = TRUE;
		}

	Item_Label_Update();
}

void() Item_Nex_ExtResponseSystem_Spawn =
{
	if(_Nex_ExtResponseSystem_Initialized)
		objerror("Item_Nex_ExtResponseSystem is a singleton!");
	_Nex_ExtResponseSystem_Initialized = TRUE;
	Item_Label_Spawn();
	self._update = Item_Nex_ExtResponseSystem_Update;
}
