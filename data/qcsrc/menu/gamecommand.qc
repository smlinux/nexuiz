void GameCommand_Init()
{
	// make gg call menu QC theCommands
	localcmd("alias qc_cmd \"menu_cmd $*\"\n");
}

string _dumptree_space;
void _dumptree_open(entity pass, entity me)
{
	string s;
	s = me.toString(me);
	if(s == "")
		s = me.classname;
	else
		s = strcat(me.classname, ": ", s);
	print(_dumptree_space, etos(me), " (", s, ")");
	if(me.firstChild)
	{
		print(" {\n");
		_dumptree_space = strcat(_dumptree_space, "  ");
	}
	else
		print("\n");
}
void _dumptree_close(entity pass, entity me)
{
	if(me.firstChild)
	{
		_dumptree_space = substring(_dumptree_space, 0, strlen(_dumptree_space) - 2);
		print(_dumptree_space, "}\n");
	}
}

void GameCommand(string theCommand)
{
	float argc;
	argc = tokenize_console(theCommand);

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
		loadAllCvars(main);
		return;
	}

	if(argv(0) == "directmenu") if(argc == 2)
	{
		// switch to a menu item
		if(!isdemo()) // don't allow this command in demos
			m_goto(argv(1));
		return;
	}

	if(argv(0) == "skinselect")
	{
		m_goto_skin_selector();
		return;
	}

	if(argv(0) == "videosettings")
	{
		m_goto_video_settings();
		return;
	}

	if(argv(0) == "dumptree")
	{
		_dumptree_space = "";
		depthfirst(main, parent, firstChild, nextSibling, _dumptree_open, _dumptree_close, NULL);
		return;
	}

	if(argv(0) == "setresolution")
	{
		updateConwidths();
		return;
	}

#if 0
	if(argv(0) == "tokentest")
	{
		string s;
		float i, n;

		print("SANE tokenizer:\n");
		s = cvar_string("tokentest");
		n = tokenize_console_force_builtin(s);
		for(i = -n; i < n; ++i)
		{
			print("token ", ftos(i), ": '", argv(i), "' = ");
			print(ftos(argv_start_index(i)), " to ", ftos(argv_end_index(i)), "\n");
		}
		print(".\n");

		print("INSANE tokenizer:\n");
		s = cvar_string("tokentest");
		n = tokenize(s);
		for(i = -n; i < n; ++i)
		{
			print("token ", ftos(i), ": '", argv(i), "' = ");
			print(ftos(argv_start_index(i)), " to ", ftos(argv_end_index(i)), "\n");
		}
		print(".\n");

		print("EMULATED tokenizer:\n");
		s = cvar_string("tokentest");
		n = tokenize_console_force_emulation(s);
		for(i = -n; i < n; ++i)
		{
			print("token ", ftos(i), ": '", argv(i), "' = ");
			print(ftos(argv_start_index(i)), " to ", ftos(argv_end_index(i)), "\n");
		}
		print(".\n");
		return;
	}
#endif

	print("Invalid theCommand. For a list of supported theCommands, try menu_cmd help.\n");
}
