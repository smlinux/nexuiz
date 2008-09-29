string GotoMap(string m);

#if 0
// TODO make this algorithm work (no idea why it is failing), it would be much faster
float FullTraceFraction(vector a, vector mi, vector ma, vector b)
{
	vector c;
	float d;
	if(a_z > b_z)
		return 0;
	tracebox(a, mi, ma, b, MOVE_WORLDONLY, world);
	if(trace_startsolid)
	{
		// a leaves solid, then hits trace_endpos
		// where does a leave solid?
		c = trace_endpos;
		tracebox(c, mi, ma, a, MOVE_WORLDONLY, world);
		// a to trace_endpos is solid
		// trace_endpos to c is not solid
		d = trace_endpos_z - a_z;
		return FullTraceFraction(c + '0 0 1', mi, ma, b) + d;
	}
	else
	{
		// a hits trace_endpos
		return FullTraceFraction(trace_endpos + '0 0 1', mi, ma, b);
	}
}

float RoughMapAtPoint(float x, float y, float w, float h)
{
	vector a, b, mi, ma;
	mi = '0 0 0';
	ma = '1 0 0' * w + '0 1 0' * h;
	a = '1 0 0' * x + '0 1 0' * y + '0 0 1' * world.mins_z;
	b = '1 0 0' * x + '0 1 0' * y + '0 0 1' * world.maxs_z;
	return floor(FullTraceFraction(a, mi, ma, b) / (world.maxs_z - world.mins_z) * 255);
}
#else
float RoughMapAtPoint(float x, float y, float w, float h)
{
	vector o, mi, ma;
	float i, r;
	vector dz;
	mi = '0 0 0';
	dz = ((world.maxs_z - world.mins_z) / 64) * '0 0 1';
	ma = '1 0 0' * w + '0 1 0' * h + dz;
	o = '1 0 0' * x + '0 1 0' * y + '0 0 1' * world.mins_z;
	
	r = 0;
	for(i = 0; i < 51; ++i)
	{
		tracebox(o + dz * i, mi, ma, o + dz * i, MOVE_WORLDONLY, world);
		if(trace_startsolid)
			++r;
	}
	return r * 5; // 0 .. 255
}
#endif

string doublehex = "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";

void RoughMap()
{
	float x0, y0, w, h;
	float m, n;
	float x, y;
	float l;
	float f;
	float i;
	string si;
	string fn;

	m = 256;
	n = 256;

	x0 = world.mins_x;
	y0 = world.mins_y;
	w = (world.maxs_x - x0) / m;
	h = (world.maxs_y - y0) / n;
	// TODO fix aspect
	w = h = max(w, h);

	/*
	m = min(m, ceil((world.maxs_x - x0) / w));
	n = min(n, ceil((world.maxs_y - y0) / h));
	*/

	fn = strcat("maps/", mapname, ".xpm");
	f = fopen(fn, FILE_WRITE);
	if(f < 0)
	{
		print("Error writing ", fn, "\n");
		return;
	}
	print("Writing to ", fn, "...\n");
	fputs(f, "/* XPM */\n");
	fputs(f, "static char *RoughMap[] = {\n");
	fputs(f, "/* columns rows colors chars-per-pixel */\n");
	fputs(f, strcat("\"", ftos(m), " ", ftos(n), " 256 2\",\n"));
	for(i = 0; i < 256; ++i)
	{
		si = substring(doublehex, i*2, 2);
		fputs(f, strcat("\"", si, " c #", si, si, si, "\",\n"));
	}
	for(y = n-1; y >= 0; --y)
	{
		fputs(f, "\"");
		for(x = 0; x < m; ++x)
		{
			l = RoughMapAtPoint(x0 + x * w, y0 + y * h, w, h);
			fputs(f, substring(doublehex, 2 * l, 2));
		}
		if(y == 0)
			fputs(f, "\"\n");
		else
		{
			fputs(f, "\",\n");
			print(ftos(y), " lines left\n");
		}
	}
	fputs(f, "};\n");
	print("Finished. Please edit data/", fn, " with an image editing application and place it with the name XXX in the TGA format in the same folder as the BSP file.\n");
}

void EffectIndexDump()
{
	float d;
	float fh;
	string s;

	d = db_create();

	print("begin of effects list\n");
	db_put(d, "TE_GUNSHOT", "1"); print("effect TE_GUNSHOT is ", ftos(particleeffectnum("TE_GUNSHOT")), "\n");
	db_put(d, "TE_GUNSHOTQUAD", "1"); print("effect TE_GUNSHOTQUAD is ", ftos(particleeffectnum("TE_GUNSHOTQUAD")), "\n");
	db_put(d, "TE_SPIKE", "1"); print("effect TE_SPIKE is ", ftos(particleeffectnum("TE_SPIKE")), "\n");
	db_put(d, "TE_SPIKEQUAD", "1"); print("effect TE_SPIKEQUAD is ", ftos(particleeffectnum("TE_SPIKEQUAD")), "\n");
	db_put(d, "TE_SUPERSPIKE", "1"); print("effect TE_SUPERSPIKE is ", ftos(particleeffectnum("TE_SUPERSPIKE")), "\n");
	db_put(d, "TE_SUPERSPIKEQUAD", "1"); print("effect TE_SUPERSPIKEQUAD is ", ftos(particleeffectnum("TE_SUPERSPIKEQUAD")), "\n");
	db_put(d, "TE_WIZSPIKE", "1"); print("effect TE_WIZSPIKE is ", ftos(particleeffectnum("TE_WIZSPIKE")), "\n");
	db_put(d, "TE_KNIGHTSPIKE", "1"); print("effect TE_KNIGHTSPIKE is ", ftos(particleeffectnum("TE_KNIGHTSPIKE")), "\n");
	db_put(d, "TE_EXPLOSION", "1"); print("effect TE_EXPLOSION is ", ftos(particleeffectnum("TE_EXPLOSION")), "\n");
	db_put(d, "TE_EXPLOSIONQUAD", "1"); print("effect TE_EXPLOSIONQUAD is ", ftos(particleeffectnum("TE_EXPLOSIONQUAD")), "\n");
	db_put(d, "TE_TAREXPLOSION", "1"); print("effect TE_TAREXPLOSION is ", ftos(particleeffectnum("TE_TAREXPLOSION")), "\n");
	db_put(d, "TE_TELEPORT", "1"); print("effect TE_TELEPORT is ", ftos(particleeffectnum("TE_TELEPORT")), "\n");
	db_put(d, "TE_LAVASPLASH", "1"); print("effect TE_LAVASPLASH is ", ftos(particleeffectnum("TE_LAVASPLASH")), "\n");
	db_put(d, "TE_SMALLFLASH", "1"); print("effect TE_SMALLFLASH is ", ftos(particleeffectnum("TE_SMALLFLASH")), "\n");
	db_put(d, "TE_FLAMEJET", "1"); print("effect TE_FLAMEJET is ", ftos(particleeffectnum("TE_FLAMEJET")), "\n");
	db_put(d, "EF_FLAME", "1"); print("effect EF_FLAME is ", ftos(particleeffectnum("EF_FLAME")), "\n");
	db_put(d, "TE_BLOOD", "1"); print("effect TE_BLOOD is ", ftos(particleeffectnum("TE_BLOOD")), "\n");
	db_put(d, "TE_SPARK", "1"); print("effect TE_SPARK is ", ftos(particleeffectnum("TE_SPARK")), "\n");
	db_put(d, "TE_PLASMABURN", "1"); print("effect TE_PLASMABURN is ", ftos(particleeffectnum("TE_PLASMABURN")), "\n");
	db_put(d, "TE_TEI_G3", "1"); print("effect TE_TEI_G3 is ", ftos(particleeffectnum("TE_TEI_G3")), "\n");
	db_put(d, "TE_TEI_SMOKE", "1"); print("effect TE_TEI_SMOKE is ", ftos(particleeffectnum("TE_TEI_SMOKE")), "\n");
	db_put(d, "TE_TEI_BIGEXPLOSION", "1"); print("effect TE_TEI_BIGEXPLOSION is ", ftos(particleeffectnum("TE_TEI_BIGEXPLOSION")), "\n");
	db_put(d, "TE_TEI_PLASMAHIT", "1"); print("effect TE_TEI_PLASMAHIT is ", ftos(particleeffectnum("TE_TEI_PLASMAHIT")), "\n");
	db_put(d, "EF_STARDUST", "1"); print("effect EF_STARDUST is ", ftos(particleeffectnum("EF_STARDUST")), "\n");
	db_put(d, "TR_ROCKET", "1"); print("effect TR_ROCKET is ", ftos(particleeffectnum("TR_ROCKET")), "\n");
	db_put(d, "TR_GRENADE", "1"); print("effect TR_GRENADE is ", ftos(particleeffectnum("TR_GRENADE")), "\n");
	db_put(d, "TR_BLOOD", "1"); print("effect TR_BLOOD is ", ftos(particleeffectnum("TR_BLOOD")), "\n");
	db_put(d, "TR_WIZSPIKE", "1"); print("effect TR_WIZSPIKE is ", ftos(particleeffectnum("TR_WIZSPIKE")), "\n");
	db_put(d, "TR_SLIGHTBLOOD", "1"); print("effect TR_SLIGHTBLOOD is ", ftos(particleeffectnum("TR_SLIGHTBLOOD")), "\n");
	db_put(d, "TR_KNIGHTSPIKE", "1"); print("effect TR_KNIGHTSPIKE is ", ftos(particleeffectnum("TR_KNIGHTSPIKE")), "\n");
	db_put(d, "TR_VORESPIKE", "1"); print("effect TR_VORESPIKE is ", ftos(particleeffectnum("TR_VORESPIKE")), "\n");
	db_put(d, "TR_NEHAHRASMOKE", "1"); print("effect TR_NEHAHRASMOKE is ", ftos(particleeffectnum("TR_NEHAHRASMOKE")), "\n");
	db_put(d, "TR_NEXUIZPLASMA", "1"); print("effect TR_NEXUIZPLASMA is ", ftos(particleeffectnum("TR_NEXUIZPLASMA")), "\n");
	db_put(d, "TR_GLOWTRAIL", "1"); print("effect TR_GLOWTRAIL is ", ftos(particleeffectnum("TR_GLOWTRAIL")), "\n");
	db_put(d, "SVC_PARTICLE", "1"); print("effect SVC_PARTICLE is ", ftos(particleeffectnum("SVC_PARTICLE")), "\n");

	fh = fopen("effectinfo.txt", FILE_READ);
	while((s = fgets(fh)))
	{
		tokenize(s);
		if(argv(0) == "effect")
		{
			if(db_get(d, argv(1)) != "1")
			{
				if(particleeffectnum(argv(1)) >= 0)
					print("effect ", argv(1), " is ", ftos(particleeffectnum(argv(1))), "\n");
				db_put(d, argv(1), "1");
			}
		}
	}
	print("end of effects list\n");

	db_close(d);
}

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
	entity client;
	float entno;
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
		print("  allready\n");
		print("  effectindexdump\n");
		print("  roughmap\n");
		GameCommand_Vote("help", world);
		GameCommand_Ban("help");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Vote(command, world))
		return;

	if(GameCommand_Ban(command))
		return;

	if(GameCommand_Generic(command))
		return;

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

	if(argv(0) == "adminmsg") if(argc == 3)
	{
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
	if (argv(0) == "nospectators")
	{
		blockSpectators = 1;
		local entity plr;
		FOR_EACH_CLIENT(plr) //give every spectator <g_maxplayers_spectator_blocktime> seconds time to become a player
		{
			if(plr.classname == "spectator" || plr.classname == "observer")
			{
				plr.spectatortime = time;
				sprint(plr, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
			}
		}
		bprint(strcat("^7All spectators will be automatically kicked when not joining the game after ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds!\n"));
		return;
	}
	if (argv(0) == "lockteams")
	{
		if(teamplay)
		{
			lockteams = 1;
			bprint("^1The teams are now locked.\n");
		}
		else
			bprint("That command can only be used in a team-based gamemode.\n");
		return;
	}
	if (argv(0) == "unlockteams")
	{
		if(teamplay)
		{
			lockteams = 0;
			bprint("^1The teams are now unlocked.\n");
		}
		else
			bprint("That command can only be used in a team-based gamemode.\n");
		return;
	}
	if (argv(0) == "movetoteam") if(argc == 3)
	{
		entno = stof(argv(1));
		client = world;
		if(entno <= maxclients)
			client = edict_num(entno);
		if(client.flags & FL_CLIENT)
		{
			float lt;
			lt = lockteams;
			lockteams = 0;

			self = client;
			SV_ParseClientCommand(strcat("selectteam ", argv(2)));

			lockteams = lt;
		}
		else
			print("Client not found\n");
		return;
	}
	if (argv(0) == "teamstatus")
	{
		Score_NicePrint(world);
		return;
	}
	if (argv(0) == "allready")
	{
		ReadyRestart();
		return;
	}
	if (argv(0) == "effectindexdump")
	{
		EffectIndexDump();
		return;
	}
	if (argv(0) == "roughmap")
	{
		RoughMap();
		return;
	}
	if (argv(0) == "cvar_changes")
	{
		print(cvar_changes);
		return;
	}

	print("Invalid command. For a list of supported commands, try sv_cmd help.\n");
}

