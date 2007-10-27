void GameCommand_Init()
{
	// make gg call menu QC theCommands
	localcmd("alias qc_cmd \"menu_cmd $*\"\n");
}

void GameCommand(string theCommand)
{
	float argc;
	argc = tokenize(theCommand);

	if(argv(0) == "help" || argc == 0)
	{
		print("Usage: menu_cmd theCommand..., where possible theCommands are:\n");
		print("  sync - reloads all cvars on the current menu page\n");
		print("  directmenu ITEM - select a menu item as main item\n");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Generic(theCommand))
		return;

	if(argv(0) == "sync")
	{
		// make changes in cvars known to the system
		return;
	}

	if(argv(0) == "directmenu") if(argc == 2)
	{
		// switch to a menu item
		m_goto(argv(1));
		return;
	}

	print("Invalid theCommand. For a list of supported theCommands, try menu_cmd help.\n");
}
