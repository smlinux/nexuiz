string GotoMap(string m);

void make_mapinfo_Think()
{
	if(MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 1))
	{
		print("Done rebuiling mapinfos.\n");
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0);
		remove(self);
	}
	else
	{
		self.think = make_mapinfo_Think;
		self.nextthink = time;
	}
}

void GameCommand(string command)
{
	float argc;
	argc = tokenize(command);

	if(argv(0) == "help" || argc == 0)
	{
		print("Usage: sv_cmd COMMAND..., where possible commands are:\n");
		print("  adminmsg clientnumber \"message\"\n");
		print("  teamstatus\n");
		print("  printstats\n");
		print("  make_mapinfo\n");
		print("  gametype dm|ctf|...\n");
		print("  savedb filename\n");
		print("  dumpdb filename\n");
		print("  loaddb filename\n");
		print("  vstop\n");
		GameCommand_Ban("help");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Ban(command))
		return;

	if(GameCommand_Generic(command))
		return;

	if(argv(0) == "teamstatus")
	{
		PrintScoreboard(world);
		return;
	}

	if(argv(0) == "printstats")
	{
		DumpStats(FALSE);
		return;
	}

	if(argv(0) == "make_mapinfo")
	{
		entity e;
		e = spawn();
		e.classname = "make_mapinfo";
		e.think = make_mapinfo_Think;
		e.nextthink = time;
		MapInfo_Enumerate();
		return;
	}

	if(argv(0) == "warp") if(argc == 2) if(cvar("g_campaign"))
	{
		CampaignLevelWarp(stof(argv(1)));
		return;
	}

	if(argv(0) == "gotomap") if(argc == 2)
	{
		print(GotoMap(argv(1)), "\n");
		return;
	}

#ifdef MAPINFO
	if(argv(0) == "gametype") if(argc == 2)
	{
		float t, tsave;
		string s;
		s = argv(1);
		t = MapInfo_Type_FromString(s);
		tsave = MapInfo_CurrentGametype();
		if(t)
		{
			MapInfo_SwitchGameType(t);
			MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0);
			if(MapInfo_count > 0)
			{
				bprint("Game type successfully switched to ", s, "\n");
			}
			else
			{
				bprint("Cannot use this game type: no map for it found\n");
				MapInfo_SwitchGameType(tsave);
				MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0);
			}
		}
		else
			bprint("Game type switch to ", s, " failed: this type does not exist!\n");
		return;
	}
#endif

	if(argv(0) == "adminmsg") if(argc == 3)
	{
		entity client;
		float entno;
		entno = stof(argv(1));
		client = world;
		if(entno <= maxclients)
			client = edict_num(entno);
		if(client.flags & FL_CLIENT)
		{
			centerprint_atprio(client, CENTERPRIO_ADMIN, strcat("^3SERVER ADMIN:\n\n^7", argv(2)));
			sprint(client, strcat("\{1}\{13}^3SERVER ADMIN^7: ", argv(2), "\n"));
			print("Message sent to ", client.netname, "\n");
		}
		else
			print("Client not found\n");
		return;
	}

	if(argv(0) == "savedb") if(argc == 2)
	{
		db_save(ServerProgsDB, argv(1));
		print("DB saved.\n");
		return;
	}

	if(argv(0) == "dumpdb") if(argc == 2)
	{
		db_dump(ServerProgsDB, argv(1));
		print("DB dumped.\n");
		return;
	}

	if(argv(0) == "loaddb") if(argc == 2)
	{
		db_close(ServerProgsDB);
		ServerProgsDB = db_load(argv(1));
		print("DB loaded.\n");
		return;
	}

	if(argv(0) == "vstop")
	{
		local entity temp;
		temp = spawn();
		temp.netname = (cvar_string("sv_adminnick") == "") ? cvar_string("hostname") : cvar_string("sv_adminnick");
		VoteStop(temp);
		remove(temp);
		return;
	}

	print("Invalid command. For a list of supported commands, try sv_cmd help.\n");
}

