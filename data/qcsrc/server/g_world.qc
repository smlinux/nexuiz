string GetMapname();
void GotoNextMap();

void SetDefaultAlpha()
{
	if(cvar("g_running_guns"))
	{
		default_player_alpha = -1;
		default_weapon_alpha = +1;
	}
	else if(cvar("g_cloaked"))
	{
		default_player_alpha = cvar("g_balance_cloaked_alpha");
		default_weapon_alpha = default_player_alpha;
	}
	else
	{
		default_player_alpha = cvar("g_player_alpha");
		if(default_player_alpha <= 0)
			default_player_alpha = 1;
		default_weapon_alpha = default_player_alpha;
	}
}

void fteqcc_testbugs()
{
	float a, b;

	if(!cvar("developer_fteqccbugs"))
		return;

	dprint("*** fteqcc test: checking for bugs...\n");

	a = 1;
	b = 5;
	if(sqrt(a) - sqrt(b - a) == 0)
		dprint("*** fteqcc test: found same-function-twice bug\n");
	else
		dprint("*** fteqcc test: same-function-twice bug got FINALLY FIXED! HOORAY!\n");

	world.frags = -10;
	world.enemy = world;
	world.enemy.frags += 10;
	if(world.frags > 0.2 || world.frags < -0.2) // don't error out if it's just roundoff errors
		dprint("*** fteqcc test: found += bug\n");
	else
		dprint("*** fteqcc test: += bug got FINALLY FIXED! HOORAY!\n");
	world.frags = 0;
}

void GotoFirstMap()
{
	if(cvar("_sv_init"))
	{
		cvar_set("_sv_init", "0");
		tokenize(cvar_string("g_maplist"));
		if(argv(0) != GetMapname())
		{
			cvar_set("nextmap", argv(0));
			GotoNextMap();
		}
	}
}

float world_already_spawned;
void worldspawn (void)
{
	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = TRUE;
	// Precache all player models
	// Workaround for "invisible players"
	precache_model("models/player/carni.zym");
	precache_model("models/player/crash.zym");
	precache_model("models/player/grunt.zym");
	precache_model("models/player/headhunter.zym");
	precache_model("models/player/insurrectionist.zym");
	precache_model("models/player/jeandarc.zym");
	precache_model("models/player/lurk.zym");
	precache_model("models/player/lycanthrope.zym");
	precache_model("models/player/marine.zym");
	precache_model("models/player/nexus.zym");
	precache_model("models/player/pyria.zym");
	precache_model("models/player/shock.zym");
	precache_model("models/player/skadi.zym");
	precache_model("models/player/specop.zym");
	precache_model("models/player/visitant.zym");

	//precache_model ("progs/beam.mdl");
	precache_model ("models/bullet.mdl");
	precache_model ("models/casing_bronze.mdl");
	precache_model ("models/casing_shell.mdl");
	precache_model ("models/casing_steel.mdl");
	precache_model ("models/ebomb.mdl");
	precache_model ("models/elaser.mdl");
	precache_model ("models/flash.md3");
	precache_model ("models/gibs/bloodyskull.md3");
	precache_model ("models/gibs/chunk.mdl");
	precache_model ("models/gibs/eye.md3");
	precache_model ("models/gibs/gib1.md3");
	//precache_model ("models/gibs/gib2.md3");
	//precache_model ("models/gibs/gib3.md3");
	//precache_model ("models/gibs/gib4.md3");
	precache_model ("models/gibs/gib5.md3");
	//precache_model ("models/gibs/gib6.md3");
	precache_model ("models/gibs/gib1.mdl");
	precache_model ("models/gibs/gib2.mdl");
	precache_model ("models/gibs/gib3.mdl");
	precache_model ("models/grenademodel.md3");
	precache_model ("models/hagarmissile.mdl");
	precache_model ("models/items/a_bullets.mdl");
	precache_model ("models/items/a_cells.md3");
	precache_model ("models/items/a_rockets.md3");
	precache_model ("models/items/a_shells.md3");
	precache_model ("models/items/g_a1.md3");
	precache_model ("models/items/g_a25.md3");
	precache_model ("models/items/g_h1.md3");
	precache_model ("models/items/g_h25.md3");
	precache_model ("models/items/g_h100.md3");
	precache_model ("models/items/g_invincible.md3");
	precache_model ("models/items/g_strength.md3");
	precache_model ("models/laser.mdl");
	precache_model ("models/misc/chatbubble.spr");
	precache_model ("models/misc/teambubble.spr");
	precache_model ("models/nexflash.md3");
	precache_model ("models/plasma.mdl");
	precache_model ("models/plasmatrail.mdl");
	precache_model ("models/rocket.md3");
	//precache_model ("models/sprites/grenexpl.spr");
	precache_model ("models/runematch/rune.mdl");
	precache_model ("models/runematch/curse.mdl");
	//precache_model ("models/sprites/hagar.spr");
	//precache_model ("models/sprites/muzzleflash.spr32");
	//precache_model ("models/sprites/electrocombo.spr32");
	//precache_model ("models/sprites/plasmahitwall.spr32");
	//precache_model ("models/sprites/plasmashot.spr32");
	//precache_model ("models/sprites/rockexpl.spr");
	precache_model ("models/tracer.mdl");
	precache_model ("models/uziflash.md3");
	precache_model ("models/weapons/g_crylink.md3");
	precache_model ("models/weapons/g_electro.md3");
	precache_model ("models/weapons/g_gl.md3");
	precache_model ("models/weapons/g_hagar.md3");
	precache_model ("models/weapons/g_nex.md3");
	precache_model ("models/weapons/g_rl.md3");
	precache_model ("models/weapons/g_shotgun.md3");
	precache_model ("models/weapons/g_uzi.md3");
	precache_model ("models/weapons/v_crylink.md3");
	precache_model ("models/weapons/v_electro.md3");
	precache_model ("models/weapons/v_gl.md3");
	precache_model ("models/weapons/v_hagar.md3");
	precache_model ("models/weapons/v_laser.md3");
	precache_model ("models/weapons/v_nex.md3");
	precache_model ("models/weapons/v_rl.md3");
	precache_model ("models/weapons/v_shotgun.md3");
	precache_model ("models/weapons/v_uzi.md3");
	precache_model ("models/weapons/w_crylink.zym");
	precache_model ("models/weapons/w_electro.zym");
	precache_model ("models/weapons/w_gl.zym");
	precache_model ("models/weapons/w_hagar.zym");
	precache_model ("models/weapons/w_laser.zym");
	precache_model ("models/weapons/w_nex.zym");
	precache_model ("models/weapons/w_rl.zym");
	precache_model ("models/weapons/w_shotgun.zym");
	precache_model ("models/weapons/w_uzi.zym");

	// laser for laser-guided weapons
	precache_model ("models/laser_dot.mdl");

	precache_sound ("misc/null.wav");
	precache_sound ("misc/armor1.wav");
	precache_sound ("misc/armor25.wav");
	precache_sound ("misc/armorimpact.wav");
	precache_sound ("misc/bodyimpact1.wav");
	precache_sound ("misc/bodyimpact2.wav");
	precache_sound ("misc/gib.wav");
	precache_sound ("misc/gib_splat01.wav");
	precache_sound ("misc/gib_splat02.wav");
	precache_sound ("misc/gib_splat03.wav");
	precache_sound ("misc/gib_splat04.wav");
	//precache_sound ("misc/h2ohit.wav");
	precache_sound ("misc/hit.wav");
	precache_sound ("misc/footstep01.wav");
	precache_sound ("misc/footstep02.wav");
	precache_sound ("misc/footstep03.wav");
	precache_sound ("misc/footstep04.wav");
	precache_sound ("misc/footstep05.wav");
	precache_sound ("misc/footstep06.wav");
	precache_sound ("misc/hitground1.ogg");
	precache_sound ("misc/hitground2.ogg");
	precache_sound ("misc/hitground3.ogg");
	precache_sound ("misc/hitground4.ogg");
	precache_sound ("misc/itempickup.ogg");
	precache_sound ("misc/itemrespawn.ogg");
	precache_sound ("misc/jumppad.ogg");
	precache_sound ("misc/mediumhealth.ogg");
	precache_sound ("misc/megahealth.ogg");
	precache_sound ("misc/minihealth.ogg");
	precache_sound ("misc/powerup.ogg");
	precache_sound ("misc/powerup_shield.ogg");
	precache_sound ("misc/talk.wav");
	precache_sound ("misc/teleport.ogg");
	precache_sound ("plats/medplat1.wav");
	precache_sound ("plats/medplat2.wav");
	precache_sound ("player/lava.wav");
	precache_sound ("player/slime.wav");
	precache_sound ("weapons/crylink_fire.ogg");
	precache_sound ("weapons/electro_bounce.ogg");
	precache_sound ("weapons/electro_fire.ogg");
	precache_sound ("weapons/electro_fire2.ogg");
	precache_sound ("weapons/electro_fly.wav");
	precache_sound ("weapons/electro_impact.ogg");
	precache_sound ("weapons/electro_impact_combo.ogg");
	//precache_sound ("weapons/grenade_bounce.ogg");
	precache_sound ("weapons/grenade_bounce1.ogg");
	precache_sound ("weapons/grenade_bounce2.ogg");
	precache_sound ("weapons/grenade_bounce3.ogg");
	precache_sound ("weapons/grenade_bounce4.ogg");
	precache_sound ("weapons/grenade_bounce5.ogg");
	precache_sound ("weapons/grenade_bounce6.ogg");
	precache_sound ("weapons/grenade_fire.ogg");
	precache_sound ("weapons/grenade_impact.ogg");
	precache_sound ("weapons/hagar_fire.ogg");
	precache_sound ("weapons/hagexp1.ogg");
	precache_sound ("weapons/hagexp2.ogg");
	precache_sound ("weapons/hagexp3.ogg");
	precache_sound ("weapons/hook_fire.ogg");
	precache_sound ("weapons/hook_impact.ogg");
	precache_sound ("weapons/lasergun_fire.ogg");
	precache_sound ("weapons/laserimpact.ogg");
	precache_sound ("weapons/nexfire.ogg");
	precache_sound ("weapons/neximpact.ogg");
	precache_sound ("weapons/ric1.ogg");
	precache_sound ("weapons/ric2.ogg");
	precache_sound ("weapons/ric3.ogg");
	precache_sound ("weapons/rocket_fire.ogg");
	precache_sound ("weapons/rocket_fly.wav");
	precache_sound ("weapons/rocket_impact.ogg");
	precache_sound ("weapons/rocket_det.ogg");
	precache_sound ("weapons/shotgun_fire.ogg");
	precache_sound ("weapons/tink1.ogg");
	precache_sound ("weapons/uzi_fire.ogg");
	precache_sound ("weapons/weapon_switch.ogg");
	precache_sound ("weapons/weaponpickup.ogg");
	precache_sound ("weapons/strength_fire.ogg");

	//precache_sound ("announce/male/kill10.ogg");
	//precache_sound ("announce/male/kill15.ogg");
	//precache_sound ("announce/male/kill20.ogg");
	//precache_sound ("announce/male/kill25.ogg");
	//precache_sound ("announce/male/kill3.ogg");
	//precache_sound ("announce/male/kill30.ogg");
	//precache_sound ("announce/male/kill4.ogg");
	//precache_sound ("announce/male/kill5.ogg");
	//precache_sound ("announce/male/kill6.ogg");
	//precache_sound ("announce/male/mapkill1.ogg");
	//precache_sound ("announce/robotic/last_second_save.ogg");
	//precache_sound ("announce/robotic/narrowly_averted.ogg");
	//precache_sound ("minstagib/mockery.ogg");

	// announcer sounds - male
	precache_sound ("announcer/male/03kills.ogg");
	precache_sound ("announcer/male/05kills.ogg");
	precache_sound ("announcer/male/10kills.ogg");
	precache_sound ("announcer/male/15kills.ogg");
	precache_sound ("announcer/male/20kills.ogg");
	precache_sound ("announcer/male/25kills.ogg");
	precache_sound ("announcer/male/30kills.ogg");
	precache_sound ("announcer/male/botlike.ogg");
	precache_sound ("announcer/male/electrobitch.ogg");
	precache_sound ("announcer/male/welcome.ogg");
	precache_sound ("announcer/male/yoda.ogg");

	// announcer sounds - robotic
	precache_sound ("announcer/robotic/1fragleft.ogg");
	precache_sound ("announcer/robotic/1minuteremains.ogg");
	precache_sound ("announcer/robotic/2fragsleft.ogg");
	precache_sound ("announcer/robotic/3fragsleft.ogg");
	precache_sound ("announcer/robotic/lastsecond.ogg");
	precache_sound ("announcer/robotic/narrowly.ogg");
	precache_sound ("announcer/robotic/1.ogg");
	precache_sound ("announcer/robotic/2.ogg");
	precache_sound ("announcer/robotic/3.ogg");
	precache_sound ("announcer/robotic/4.ogg");
	precache_sound ("announcer/robotic/5.ogg");
	precache_sound ("announcer/robotic/6.ogg");
	precache_sound ("announcer/robotic/7.ogg");
	precache_sound ("announcer/robotic/8.ogg");
	precache_sound ("announcer/robotic/9.ogg");
	precache_sound ("announcer/robotic/10.ogg");

	// plays music for the level if there is any
	if (self.noise)
	{
		precache_sound (self.noise);
		ambientsound ('0 0 0', self.noise, 1.00, ATTN_NONE);
	}

		// 0 normal
	lightstyle(0, "m");

	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	player_count = 0;
	lms_lowest_lives = 0;
	lms_next_place = 0;

	GotoFirstMap();

	if(cvar("g_campaign"))
		CampaignPreInit();

	InitGameplayMode();
	//if (cvar("g_domination"))
	//	dom_init();

	local entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		maxclients++;
		head = nextent(head);
	}

	GameLogInit(); // prepare everything
	if(cvar("sv_eventlog"))
	{
		local string s;
		GameLogEcho(":logversion:2", FALSE);
		s = strcat(cvar_string("sv_eventlog_files_counter"), ".");
		s = strcat(s, ftos(random()));
		GameLogEcho(strcat(":gamestart:", GetMapname(), ":", s), FALSE);
		s = ":gameinfo:mutators:LIST";
		if(cvar("g_grappling_hook"))
			s = strcat(s, ":grappling_hook");
		if(!cvar("g_use_ammunition"))
			s = strcat(s, ":no_use_ammunition");
		if(!cvar("g_pickup_items"))
			s = strcat(s, ":no_pickup_items");
		if(cvar("g_instagib"))
			s = strcat(s, ":instagib");
		if(cvar("g_rocketarena"))
			s = strcat(s, ":rockerarena");
		if(cvar("g_nixnex"))
			s = strcat(s, ":nixnex");
		if(cvar("g_vampire"))
			s = strcat(s, ":vampire");
		if(cvar("g_laserguided_missile"))
			s = strcat(s, ":laserguided_missile");
		if(cvar("g_norecoil"))
			s = strcat(s, ":norecoil");
		if(cvar("g_midair"))
			s = strcat(s, ":midair");
		if(cvar("g_minstagib"))
			s = strcat(s, ":minstagib");
		GameLogEcho(s, FALSE);
		GameLogEcho(":gameinfo:end", FALSE);
	}

	cvar_set("nextmap", "");

	SetDefaultAlpha();

	if(cvar("g_campaign"))
		CampaignPostInit();

	fteqcc_testbugs();
}

void light (void)
{
	makestatic (self);
}

float( string pFilename ) TryFile =
{
	local float lHandle;
	dprint("TryFile(\"", pFilename, "\")\n");
	lHandle = fopen( pFilename, FILE_READ );
	if( lHandle != -1 ) {
		fclose( lHandle );
		return TRUE;
	} else {
		return FALSE;
	}
};

string GetGametype()
{
	if (game == GAME_DEATHMATCH)
		return "dm";
	else if (game == GAME_TEAM_DEATHMATCH)
		return "tdm";
	else if (game == GAME_DOMINATION)
		return "dom";
	else if (game == GAME_CTF)
		return "ctf";
	else if (game == GAME_RUNEMATCH)
		return "rune";
	else if (game == GAME_LMS)
		return "lms";
	return "dm";
}

string GetMapname()
{
	return strcat(GetGametype(), "_", mapname);
}

float Map_Count, Map_Current;
string Map_Current_Name;

// NOTE: this now expects the map list to be already tokenize()d and the count in Map_Count
float GetMaplistPosition()
{
	float pos;
	string map;

	map = GetMapname();
	for(pos = 0; pos < Map_Count; ++pos)
		if(map == argv(pos))
			return pos;

	// resume normal maplist rotation if current map is not in g_maplist
	return cvar("g_maplist_index");
}

float MapHasRightSize(string map)
{
	// open map size restriction file
	float fh;
	dprint("opensize "); dprint(map);
	fh = fopen(strcat("maps/", map, ".sizes"), FILE_READ);
	if(fh >= 0)
	{
		float mapmin, mapmax;
		dprint(": ok, ");
		mapmin = stof(fgets(fh));
		mapmax = stof(fgets(fh));
		fclose(fh);
		if(player_count < mapmin)
		{
			dprint("not enough\n");
			return FALSE;
		}
		if(player_count > mapmax)
		{
			dprint("too many\n");
			return FALSE;
		}
		dprint("right size\n");
		return TRUE;
	}
	dprint(": not found\n");
	return TRUE;
}

string Map_Filename(float position)
{
	return strcat("maps/", argv(position), ".mapcfg");
}

float(float position, float pass) Map_Check =
{
	string filename;
	string map_next;
	map_next = argv(position);
	if(pass <= 1)
		if(map_next == Map_Current_Name) // same map again in first pass?
			return 0;
	filename = Map_Filename(position);
	if(TryFile(filename))
	{
		if(pass == 2)
			return 1;
		if(MapHasRightSize(argv(position)))
			return 1;
		return 0;
	}
	else
		dprint( "Couldn't find '", filename, "'..\n" );

	return 0;
}

void(float position) Map_Goto =
{
	cvar_set("g_maplist_index", ftos(position));
	localcmd(strcat("exec \"", Map_Filename(position) ,"\"\n"));
}

// return codes of map selectors:
//   -1 = temporary failure (that is, try some method that is guaranteed to succeed)
//   -2 = permanent failure
float() MaplistMethod_Iterate = // usual method
{
	float pass, i;

	for(pass = 1; pass <= 2; ++pass)
	{
		for(i = 1; i < Map_Count; ++i)
		{
			float mapindex;
			mapindex = math_mod(i + Map_Current, Map_Count);
			if(Map_Check(mapindex, pass))
				return mapindex;
		}
	}
	return -1;
}

float() MaplistMethod_Repeat = // fallback method
{
	if(Map_Check(Map_Current, 2))
		return Map_Current;
	return -2;
}

float() MaplistMethod_Random = // random map selection
{
	float i, imax;

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		float mapindex;
		mapindex = math_mod(Map_Current + ceil(random() * (Map_Count - 1)), Map_Count); // any OTHER map
		if(Map_Check(mapindex, 1))
			return mapindex;
	}
	return -1;
}

float(float exponent) MaplistMethod_Shuffle = // more clever shuffling
// the exponent sets a bias on the map selection:
// the higher the exponent, the 
{
	float i, j, imax, insertpos;

	imax = 42;

	if(Map_Count <= 1)
		return 0; // only one map, then always play this one

	for(i = 0; i <= imax; ++i)
	{
		string newlist;

		// now reinsert this at another position
		insertpos = pow(random(), 1 / exponent);       // ]0, 1]
		insertpos = insertpos * (Map_Count - 1);       // ]0, Map_Count - 1]
		insertpos = ceil(insertpos) + 1;               // {2, 3, 4, ..., Map_Count}
		dprint("SHUFFLE: insert pos = ", ftos(insertpos), "\n");

		// insert the current map there
		newlist = "";
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, "'", argv(j), "'");
		newlist = strcat(newlist, "'", argv(0), "'");  // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, "'", argv(j), "'");
		cvar_set("g_maplist", newlist);
		Map_Count = tokenize(newlist);

		// NOTE: the selected map has just been inserted at (insertpos-1)th position
		Map_Current = insertpos - 1; // this is not really valid, but this way the fallback has a chance of working
		if(Map_Check(Map_Current, 1))
			return Map_Current;
	}
	return -1;
}

void() Maplist_Init =
{
	string temp;
	temp = cvar_string("g_maplist");
	Map_Count = tokenize(temp);
	if(Map_Count == 0)
	{
		bprint( "Maplist is empty!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", temp = cvar_string("g_maplist_defaultlist"));
		Map_Count = tokenize(temp);
	}
	if(Map_Count == 0)
		error("empty maplist, cannot select a new map");
	Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);

	Map_Current_Name = strzone(argv(Map_Current)); // will be automatically freed on exit thanks to DP
	// this may or may not be correct, but who cares, in the worst case a map
	// isn't chosen in the first pass that should have been
}

void() GotoNextMap =
{
	//local string nextmap;
	//local float n, nummaps;
	//local string s;
	string exit_cfg;
	if (alreadychangedlevel)
		return;
	alreadychangedlevel = TRUE;

	if(cvar("g_campaign"))
	{
		CampaignPostIntermission();
		return;
	}

	if(cvar("quit_when_empty"))
	{
		if(player_count <= currentbots)
		{
			localcmd("quit\n");
			return;
		}
	}

	if (cvar("samelevel")) // if samelevel is set, stay on same level
	{
		// this does not work because it tries to exec maps/nexdm01.mapcfg (which doesn't exist, it should be trying maps/dm_nexdm01.mapcfg for example)
		//localcmd(strcat("exec \"maps/", mapname, ".mapcfg\"\n"));
		// so instead just restart the current map using the restart command (DOES NOT WORK PROPERLY WITH exit_cfg STUFF)
		localcmd("restart\n");
		//changelevel (mapname);
		return;
	}

	// if an exit cfg is defined by exiting map, exec it.
	exit_cfg = cvar_string("exit_cfg");
	if(exit_cfg != "")
		localcmd(strcat("exec \"", exit_cfg, "\"\n"));

	localcmd("exec game_reset.cfg\n");


	if (cvar("lastlevel"))
	{
		localcmd(strcat("set lastlevel 0\n"));
		localcmd(strcat("togglemenu\n"));
	}
	else
	{
		float nextMap;
		float allowReset;

		// cvar "nextmap" always gets priority
		if(TryFile(strcat("maps/", cvar_string("nextmap"), ".mapcfg")))
		{
			localcmd(strcat("exec \"maps/", cvar_string("nextmap"), ".mapcfg\"\n"));
			return;
		}

		for(allowReset = 1; allowReset >= 0; --allowReset)
		{
			Maplist_Init();
			nextMap = -1;

			if(nextMap == -1)
				if(cvar("g_maplist_shuffle") > 0)
					nextMap = MaplistMethod_Shuffle(cvar("g_maplist_shuffle") + 1);

			if(nextMap == -1)
				if(cvar("g_maplist_selectrandom"))
					nextMap = MaplistMethod_Random();

			if(nextMap == -1)
				nextMap = MaplistMethod_Iterate();

			if(nextMap == -1)
				nextMap = MaplistMethod_Repeat();

			if(nextMap >= 0)
			{
				Map_Goto(nextMap);
				break;
			}
			else // PERMANENT FAILURE
			{
				if(allowReset)
				{
					bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
					cvar_set("g_maplist", cvar_string("g_maplist_defaultlist"));
				}
				else
				{
					error("Everything is broken - not even the default map list works. Please report this to the developers.");
				}
			}
		}
	}
};


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
.float autoscreenshot;
void() IntermissionThink =
{
	if(cvar("sv_autoscreenshot"))
	if(self.autoscreenshot)
	if(time > self.autoscreenshot)
	{
		self.autoscreenshot = FALSE;
		if(clienttype(self) == CLIENTTYPE_REAL)
			stuffcmd(self, "\nscreenshot\necho \"^5A screenshot has been taken at request of the server.\"\n");
		return;
	}

	if (time < intermission_exittime)
		return;

	if (time < intermission_exittime + 10 && !self.button0 && !self.button1 && !self.button2 && !self.button3)
		return;

	GotoNextMap ();
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
/*
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// then look for the start position
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
		return spot;

	//objerror ("FindIntermission: no spot");
	return world;
};
*/

/*
===============================================================================

RULES

===============================================================================
*/

void() DumpStats =
{
	local float file;
	local string s;

	if(cvar("_printstats"))
		cvar_set("_printstats", "0");
	else if(!gameover)
		return;

	if(gameover)
		s = ":scores:";
	else
		s = ":status:";

	s = strcat(s, GetMapname(), ":", ftos(rint(time)));

	if(cvar("sv_eventlog") && gameover)
		GameLogEcho(s, FALSE);
	else if(cvar("sv_logscores_console"))
		ServerConsoleEcho(s, FALSE);
	if(cvar("sv_logscores_file"))
	{
		file = fopen(cvar_string("sv_logscores_filename"), FILE_APPEND);
		fputs(file, strcat(s, "\n"));
	}

	other = findchainflags(flags, FL_CLIENT);
	while (other)
	{
		if ((clienttype(other) == CLIENTTYPE_REAL) || (clienttype(other) == CLIENTTYPE_BOT && cvar("sv_logscores_bots")))
		{
			s = strcat(":player:", ftos(other.frags), ":");
			s = strcat(s, ftos(other.deaths), ":");
			s = strcat(s, ftos(rint(time - other.jointime)), ":");
			s = strcat(s, ftos(other.team), ":");

			if(cvar("sv_logscores_file"))
				fputs(file, strcat(s, other.netname, "\n"));
			if(cvar("sv_eventlog") && gameover)
				GameLogEcho(strcat(s, ftos(other.playerid), ":", other.netname), TRUE);
			else if(cvar("sv_logscores_console"))
				ServerConsoleEcho(strcat(s, other.netname), TRUE);
		}
		other = other.chain;
	}

	if(cvar("sv_eventlog") && gameover)
		GameLogEcho(":end", FALSE);
	else if(cvar("sv_logscores_console"))
		ServerConsoleEcho(":end", FALSE);
	if(cvar("sv_logscores_file"))
	{
		fputs(file, ":end\n");
		fclose(file);
	}
}


/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if(player_count > 0)
		intermission_exittime = time + cvar("sv_mapchange_delay");
	else
		intermission_exittime = -60;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	//pos = FindIntermission ();

	VoteReset();

	DumpStats();

	if(cvar("sv_eventlog"))
		GameLogEcho(":gameover", FALSE);

	GameLogClose();

	other = findchainflags(flags, FL_CLIENT);
	while (other != world)
	{
		//other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.angles = other.v_angle;
		other.angles_x = other.angles_x * -1;
		other.autoscreenshot = time + 0.8;	// used for autoscreenshot

		self = other;

		if(other.winning)
			bprint(strcat(other.netname, " ^7wins.\n"));

		/*
		if (pos != world);
		{
			other.modelindex = 0;
			other.weaponentity = world; // remove weapon model
			other.view_ofs = '0 0 0';
			other.angles = other.v_angle = pos.mangle;
			if (!other.angles)
			{
				other.angles = other.v_angle = pos.angles;
				other.v_angle_x = other.v_angle_x * -1;
			}
			other.fixangle = TRUE;		// turn this way immediately
			setorigin (other, pos.origin);
		}
		*/
		other = other.chain;
	}

	if(cvar("g_campaign"))
		CampaignPreIntermission();

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};

/*
============
CheckRules_Player

Exit deathmatch games upon conditions
============
*/
void() CheckRules_Player =
{
	if (gameover)	// someone else quit the game already
		return;

	// fixme: don't check players; instead check dom_team and ctf_team entities
	//   (div0: and that in CheckRules_World please)
};

float checkrules_oneminutewarning;
float checkrules_leaderfrags;
float tdm_max_score, tdm_old_score;

float checkrules_equality;
float checkrules_overtimewarning;
float checkrules_overtimeend;

void() InitiateOvertime =
{
	if(!checkrules_overtimeend)
		checkrules_overtimeend = time + 60 * cvar("timelimit_maxovertime");
}

float WINNING_NO = 0; // no winner, but time limits may terminate the game
float WINNING_YES = 1; // winner found
float WINNING_NEVER = 2; // no winner, enter overtime if time limit is reached
float WINNING_STARTOVERTIME = 3; // no winner, enter overtime NOW

float(float fraglimitreached, float equality) GetWinningCode =
{
	if(equality)
		if(fraglimitreached)
			return WINNING_STARTOVERTIME;
		else
			return WINNING_NEVER;
	else
		if(fraglimitreached)
			return WINNING_YES;
		else
			return WINNING_NO;
}

// set the .winning flag for exactly those players with a given field value
void(.float field, float value) SetWinners =
{
	entity head;
	head = findchain(classname, "player");
	while (head)
	{
		head.winning = (head.field == value);
		head = head.chain;
	}
}

// set the .winning flag for those players with a given field value
void(.float field, float value) AddWinners =
{
	entity head;
	head = findchain(classname, "player");
	while (head)
	{
		if(head.field == value)
			head.winning = 1;
		head = head.chain;
	}
}

// clear the .winning flags
void(void) ClearWinners =
{
	entity head;
	head = findchain(classname, "player");
	while (head)
	{
		head.winning = 0;
		head = head.chain;
	}
}

float() LMS_NewPlayerLives =
{
	float fl;
	fl = cvar("fraglimit");
	if(fl == 0)
		fl = 999;

	// first player has left the game for dying too much? Nobody else can get in.
	if(lms_lowest_lives < 1)
		return FALSE;

	if(!cvar("g_lms_join_anytime"))
		if(lms_lowest_lives < fl - cvar("g_lms_last_join"))
			return FALSE;

	return bound(1, lms_lowest_lives, fl);
}

// LMS winning condition: game terminates if and only if there's at most one
// one player who's living lives. Top two scores being equal cancels the time
// limit.
float() WinningCondition_LMS =
{
	entity head;
	float have_player;
	float have_players;
	float l;

	have_player = FALSE;
	have_players = FALSE;
	l = LMS_NewPlayerLives();

	head = find(world, classname, "player");
	if(head)
		have_player = TRUE;
	head = find(head, classname, "player");
	if(head)
		have_players = TRUE;

	if(have_player)
	{
		// we have at least one player
		if(have_players)
		{
			// two or more active players - continue with the game
		}
		else
		{
			// exactly one player?
			if(l)
			{
				// but no game has taken place yet
			}
			else
			{
				// a winner!
				ClearWinners(); SetWinners(winning, 0); // NOTE: exactly one player is still "player", so this works out
				dprint("Have a winner, ending game.\n");
				return WINNING_YES;
			}
		}
	}
	else
	{
		// nobody is playing at all...
		if(l)
		{
			// wait for players...
		}
		else
		{
			// SNAFU (maybe a draw game?)
			ClearWinners();
			dprint("No players, ending game.\n");
			return WINNING_YES;
		}
	}

	// When we get here, we have at least two players who are actually LIVING,
	// or one player who is still waiting for a victim to join the server. Now
	// check if the top two players have equal score.

	checkrules_leaderfrags = 0;
	head = findchain(classname, "player");
	checkrules_equality = FALSE;
	while (head)
	{
		if(head.frags > checkrules_leaderfrags)
		{
			checkrules_leaderfrags = head.frags;
			checkrules_equality = FALSE;
		}
		else if(head.frags > 0 && head.frags == checkrules_leaderfrags)
			checkrules_equality = TRUE;
		head = head.chain;
	}

	SetWinners(frags, checkrules_leaderfrags);

	// The top two players have the same amount of lives? No timelimit then,
	// enter overtime...

	if(checkrules_equality)
		return WINNING_NEVER;

	// Top two have different scores? Way to go for our beloved TIMELIMIT!
	return WINNING_NO;
}

// DM winning condition: game terminates if a player reached the fraglimit,
// unless the first two players have the same score. The latter case also
// breaks the time limit.
float(float fraglimit) WinningCondition_MaxIndividualScore =
{
	float checkrules_oldleaderfrags;
	entity head;

	checkrules_oldleaderfrags = checkrules_leaderfrags;
	checkrules_leaderfrags = 0;
	head = findchain(classname, "player");
	checkrules_equality = FALSE;
	while (head)
	{
		if(head.frags > checkrules_leaderfrags)
		{
			checkrules_leaderfrags = head.frags;
			checkrules_equality = FALSE;
		}
		else if(head.frags > 0 && head.frags == checkrules_leaderfrags)
			checkrules_equality = TRUE;
		head = head.chain;
	}

	if(checkrules_leaderfrags > 0)
		SetWinners(frags, checkrules_leaderfrags);
	else
		ClearWinners();

	if (!cvar("g_runematch"))
		if (checkrules_leaderfrags != checkrules_oldleaderfrags)
		{
			if (checkrules_leaderfrags == fraglimit - 1)
				sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.ogg", 1, ATTN_NONE);
			else if (checkrules_leaderfrags == fraglimit - 2)
				sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.ogg", 1, ATTN_NONE);
			else if (checkrules_leaderfrags == fraglimit - 3)
				sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.ogg", 1, ATTN_NONE);
		}

	return GetWinningCode(fraglimit && checkrules_leaderfrags >= fraglimit, checkrules_equality);
}

float(float fraglimit) WinningConditionBase_Teamplay =
{
	tdm_old_score = tdm_max_score;
	tdm_max_score = max(team1_score, team2_score, team3_score, team4_score);

	checkrules_equality =
	(
		(tdm_max_score > 0)
		&&
		(
			  (team1_score == tdm_max_score)
			+ (team2_score == tdm_max_score)
			+ (team3_score == tdm_max_score)
			+ (team4_score == tdm_max_score)
			>= 2));

	ClearWinners();
	if(tdm_max_score > 0)
	{
		if(team1_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM1);
		if(team2_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM2);
		if(team3_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM3);
		if(team4_score == tdm_max_score)
			AddWinners(team, COLOR_TEAM4);
	}

	if(!cvar("g_runematch") && !cvar("g_domination"))
		if(tdm_max_score != tdm_old_score)
		{
			if(tdm_max_score == fraglimit - 1)
				sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.ogg", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 2)
				sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.ogg", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 3)
				sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.ogg", 1, ATTN_NONE);
		}

	return GetWinningCode(fraglimit && tdm_max_score >= fraglimit, checkrules_equality);
}

// TDM winning condition: game terminates if a team's score sum reached the
// fraglimit, unless the first two teams have the same total score. The latter
// case also breaks the time limit.
float(float fraglimit) WinningCondition_MaxTeamSum =
{
	entity head;

	team1_score = team2_score = team3_score = team4_score = 0;

	head = findchain(classname, "player");
	while (head)
	{
		if(head.team == COLOR_TEAM1)
			team1_score += head.frags;
		else if(head.team == COLOR_TEAM2)
			team2_score += head.frags;
		else if(head.team == COLOR_TEAM3)
			team3_score += head.frags;
		else if(head.team == COLOR_TEAM4)
			team4_score += head.frags;
		head = head.chain;
	}

	return WinningConditionBase_Teamplay(fraglimit);
}

// DOM/CTF winning condition: game terminates if the max of a team's players'
// score reached the fraglimit, unless the first two teams have the same
// maximum score. The latter case also breaks the time limit.
float(float fraglimit) WinningCondition_MaxTeamMax =
{
	entity head;

	team1_score = team2_score = team3_score = team4_score = 0;

	head = findchain(classname, "player");
	while (head)
	{
		if(head.team == COLOR_TEAM1)
		{
			if(head.frags > team1_score)
				team1_score = head.frags;
		}
		else if(head.team == COLOR_TEAM2)
		{
			if(head.frags > team2_score)
				team2_score = head.frags;
		}
		else if(head.team == COLOR_TEAM3)
		{
			if(head.frags > team3_score)
				team3_score = head.frags;
		}
		else if(head.team == COLOR_TEAM4)
		{
			if(head.frags > team4_score)
				team4_score = head.frags;
		}
		head = head.chain;
	}

	return WinningConditionBase_Teamplay(fraglimit);
}

void PrintScoreboardFor(string name, string colorcode, float whichteam)
{
	entity head;
	float fragtotal;
	string s;
	float found;
	found = FALSE;
	head = find(world, classname, "player");
	while(head)
	{
		if(!whichteam || head.team == whichteam)
		{
			if(name != "")
				if(!found)
					ServerConsoleEcho(strcat(" ", colorcode, name, ":"), FALSE);
			found = TRUE;
			fragtotal = fragtotal + head.frags;
			s = ftos(head.frags);
			s = strcat(s, "/", ftos(head.deaths));
			s = strcat(s, " @ ", ftos(head.ping));
			if(clienttype(head) == CLIENTTYPE_BOT)
				s = strcat(s, "botms");
			else
				s = strcat(s, "ms");
			ServerConsoleEcho(strcat("  ", colorcode, head.netname, colorcode, " (", s, ")"), TRUE);
		}
		head = find(head, classname, "player");
	}
	if(whichteam && found)
		ServerConsoleEcho(strcat(colorcode, "  (total: ", ftos(fragtotal), ")"), FALSE);
}

void PrintScoreboard()
{
	ServerConsoleEcho("Scoreboard:", FALSE);
	if(teams_matter)
	{
		PrintScoreboardFor("Red", "^1", COLOR_TEAM1);
		PrintScoreboardFor("Blue", "^4", COLOR_TEAM2);
		PrintScoreboardFor("Pink", "^6", COLOR_TEAM3);
		PrintScoreboardFor("Yellow", "^3", COLOR_TEAM4);
	}
	else
	{
		PrintScoreboardFor("", "^7", 0);
	}
	ServerConsoleEcho(".", FALSE);
}

void RemoveFromMaplist(string m)
{
	string result;
	float litems;
	float i;
	float found;

	litems = tokenize(cvar_string("g_maplist"));
	found = 0;
	result = "";
	for(i = 0; i < litems; ++i)
	{
		m = strcat(m);
		result = strcat(result);
		if(argv(i) == m)
			found += 1;
		else
			result = strcat(result, "'", argv(i), "'");
	}
	if(found)
		cvar_set("g_maplist", result);
	ServerConsoleEcho(strcat("Removed ", ftos(found), " items."), FALSE);
}

void AddToMaplist(string m)
{
	string result;
	float found;
	float litems;
	float i;
	float ipos;
	float inserted;

	if(!TryFile(strcat("maps/", m, ".mapcfg")))
	{
		ServerConsoleEcho("Map not found.", FALSE);
		return;
	}

	litems = tokenize(cvar_string("g_maplist"));
	if(cvar("g_maplist_shuffle"))
		ipos = ceil(random() * (litems + 1)) - 1;
	else
		ipos = litems;
	found = 0;
	inserted = 0;
	for(i = 0; i < litems; ++i)
	{
		m = strcat(m);
		if(i == ipos)
		{
			result = strcat(result, "'", m, "'");
			inserted = 1;
		}
		result = strcat(result, "'", argv(i), "'");
		if(argv(i) == m)
			found += 1;
	}
	if(!inserted)
		result = strcat(result, "'", m, "'");
	if(!found)
	{
		cvar_set("g_maplist", result);
		ServerConsoleEcho("Map added.", FALSE);
	}
	else
		ServerConsoleEcho("Map already in list.", FALSE);
}

void ShuffleMaplist()
{
	string result;
	float start;
	float litems;
	float selected;
	float i;

	result = cvar_string("g_maplist");
	litems = tokenize(result);

	for(start = 0; start < litems - 1; ++start)
	{
		result = "";

		// select a random item
		selected = ceil(random() * (litems - start) + start) - 1;

		// shift this item to the place start
		for(i = 0; i < start; ++i)
			result = strcat(result, "'", argv(i), "'");
		result = strcat(result, "'", argv(selected), "'");
		for(i = start; i < litems; ++i)
			if(i != selected)
				result = strcat(result, "'", argv(i), "'");

		litems = tokenize(result);

		//dprint(result, "\n");
	}

	cvar_set("g_maplist", result);
}

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void() CheckRules_World =
{
	local float status;
	local float timelimit;
	local float fraglimit;

	VoteThink();

	SetDefaultAlpha();

	if (intermission_running)
		if (time >= intermission_exittime + 60)
		{
			GotoNextMap();
			return;
		}

	if (gameover)	// someone else quit the game already
		return;

	DumpStats();

	if(cvar("_scoreboard"))
	{
		cvar_set("_scoreboard", "0");
		PrintScoreboard();
	}

	// automatically shuffle when setting g_maplist_shuffle
	if(cvar_string("_g_maplist_add") != "")
	{
		AddToMaplist(cvar_string("_g_maplist_add"));
		cvar_set("_g_maplist_add", "");
	}
	if(cvar_string("_g_maplist_remove") != "")
	{
		RemoveFromMaplist(cvar_string("_g_maplist_remove"));
		cvar_set("_g_maplist_remove", "");
	}
	if(cvar("_g_maplist_shufflenow") || (cvar("g_maplist_shuffle") && !cvar("_g_maplist_have_shuffled")))
	{
		ShuffleMaplist();
		localcmd("set _g_maplist_shufflenow 0\nset _g_maplist_have_shuffled 1\necho Shuffled map list.\n");
	}
	if(cvar("_g_maplist_have_shuffled"))
		if(!cvar("g_maplist_shuffle"))
			localcmd("set _g_maplist_have_shuffled 0\n");

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
		InitiateOvertime();

	if (checkrules_overtimeend && time >= checkrules_overtimeend)
	{
		NextLevel();
		return;
	}

	if(!checkrules_overtimewarning && checkrules_overtimeend)
	{
		checkrules_overtimewarning = TRUE;
		//sound(world, CHAN_AUTO, "announcer/robotic/1minuteremains.ogg", 1, ATTN_NONE);
		bcenterprint("^3Now playing ^1OVERTIME^3!\n\n^3Keep fragging until we have a ^1winner^3!");
	}

	if (!checkrules_oneminutewarning && timelimit > 0 && time > timelimit - 60)
	{
		checkrules_oneminutewarning = TRUE;
		sound(world, CHAN_AUTO, "announcer/robotic/1minuteremains.ogg", 1, ATTN_NONE);
	}

	status = WINNING_NO;
	if(cvar("g_lms"))
	{
		status = WinningCondition_LMS();
	}
	else
	{
		if(teams_matter)
		{
			if(cvar("g_tdm") || cvar("g_runematch") || cvar("g_ctf") || cvar("g_domination"))
				status = WinningCondition_MaxTeamSum(fraglimit);
			//else if()
			//	status = WinningCondition_MaxTeamMax(fraglimit);
			else
			{
				dprint("div0: How can this happen?\n");
				status = WinningCondition_MaxTeamMax(fraglimit);
			}
		}
		else
			status = WinningCondition_MaxIndividualScore(fraglimit);
	}

	if(status == WINNING_STARTOVERTIME)
	{
		status = WINNING_NEVER;
		InitiateOvertime();
	}

	if(status == WINNING_NEVER)
		// equality cases! Nobody wins if the overtime ends in a draw.
		ClearWinners();

	if(checkrules_overtimeend)
		if(status != WINNING_NEVER)
			status = WINNING_YES;

	if(status == WINNING_YES)
		NextLevel();
};
