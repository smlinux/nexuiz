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
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Generic(command))
		return;

	print("Invalid command. For a list of supported commands, try menu_cmd help.\n");
}
