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
		// make changes in cvars known to the system
		return;
	}

	if(argv(0) == "directmenu") if(argc == 2)
	{
		// switch to a menu item
		return;
	}

	print("Invalid command. For a list of supported commands, try menu_cmd help.\n");
}
