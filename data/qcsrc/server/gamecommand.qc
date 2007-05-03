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
		GameCommand_Generic("help");
		return;
	}

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

	if(argv(0) == "warp") if(argc == 2) if(cvar("g_campaign"))
	{
		CampaignLevelWarp(stof(argv(1)));
		return;
	}

	if(argv(0) == "adminmsg") if(argc == 3)
	{
		entity client;
		float entno;
		entno = stof(argv(1));
		for(client = world; entno > 0; --entno, client = nextent(client))
			;
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

	print("Invalid command. For a list of supported commands, try sv_cmd help.\n");
}

