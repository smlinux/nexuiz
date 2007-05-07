void GameCommand_Init()
{
	// make gg call menu QC commands
	localcmd("alias qc_cmd \"menu_cmd $*\"\n");
}

void GameCommand(string command)
{
	float argc;
	argc = tokenize(command);

	if(argv(0) == "help" || argc == 0)
	{
		print("Usage: menu_cmd COMMAND..., where possible commands are:\n");
		print("  sync - reloads all cvars on the current menu page\n");
		print("  directmenu ITEM - select a menu item as main item\n");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Generic(command))
		return;

	if(argv(0) == "sync")
	{
		for(self = null_entity; (self = nextent(self)); )
			Raise_DataEvent(self, ITEM_DATA_SYNC);
		/*
		for(self = null_entity; (self = findstring(self, type, "Item_Data_Cvar")); )
			Raise_DataEvent(self, ITEM_DATA_SYNC);
		for(self = null_entity; (self = findstring(self, type, "Item_Data_ServerCvar")); )
			Raise_DataEvent(self, ITEM_DATA_SYNC);
		*/
		return;
	}

	if(argv(0) == "directmenu") if(argc == 2)
	{
		entity newitem;
		newitem = findstring(null_entity, name, argv(1));
		if(newitem)
			Menu_ActiveWindow = newitem;
		else
			print(argv(1), " not found.\n");
		return;
	}

	print("Invalid command. For a list of supported commands, try menu_cmd help.\n");
}
