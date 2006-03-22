
void worldspawn (void)
{

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
	precache_model ("models/sprites/grenexpl.spr");
	precache_model ("models/sprites/hagar.spr");
	precache_model ("models/sprites/muzzleflash.spr32");
	precache_model ("models/sprites/electrocombo.spr32");
	//precache_model ("models/sprites/plasmahitwall.spr32");
	//precache_model ("models/sprites/plasmashot.spr32");
	precache_model ("models/sprites/rockexpl.spr");
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
	lms_dead_count = 0;
	lms_lowest_lives = 0;

	InitGameplayMode();
	//if (cvar("g_domination"))
	//	dom_init();

	// Urrebot setting
	urrebots_navopt = cvar("urrebots_navopt");

	local entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		maxclients++;
		head = nextent(head);
	}

	cvar_set("nextmap", "");
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

void() GotoNextMap =
{
	//local string nextmap;
	//local float n, nummaps;
	//local string s;
	string exit_cfg;
	if (alreadychangedlevel)
		return;
	alreadychangedlevel = TRUE;
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

	ResetGameCvars();


	if (cvar("lastlevel"))
	{
		localcmd(strcat("set lastlevel 0\n"));
		localcmd(strcat("togglemenu\n"));
	}
	else
	{
		// method 0
		local float lCurrent;
		local float lSize;
		local float lOldCurrent;
		local float pass;

		if(TryFile(strcat("maps/", cvar_string("nextmap"), ".mapcfg")))
		{
			localcmd(strcat("exec \"maps/", cvar_string("nextmap"), ".mapcfg\"\n"));
			return;
		}
		
		pass = 0;
		while (pass < 2)
		{
			pass = pass + 1;
			local string temp;
			temp = cvar_string( "g_maplist" );
			dprint("g_maplist is ", temp, "\n");
			lSize = tokenize( temp );
			lCurrent = cvar( "g_maplist_index" );
			lOldCurrent = lCurrent;
			dprint(ftos(lOldCurrent), " / ", ftos(lSize), " (start)\n");
			while( 1 ) {
				local string lFilename;

				lCurrent = lCurrent + 1;
				dprint(ftos(lCurrent), " / ", ftos(lSize), "\n");
				if( lCurrent >= lSize ) {
					lCurrent = 0;
				}
				if( lOldCurrent == lCurrent ) {
					// we couldn't find a valid map at all
					if (pass == 1)
					{
						bprint( "Maplist is bad/messed up. Not one good mapcfg can be found in it!  Resetting it to default map list.\n" );
						cvar_set("g_maplist", cvar_string("g_maplist_defaultlist"));
						// let the loop restart with the default list now
					}
					else
					{
						bprint( "Both g_maplist and g_maplist_defaultlist are messed up!  complain to developers!\n" );
						localcmd( "disconnect\n" );
					}
					break;
				}

				cvar_set( "g_maplist_index", ftos( lCurrent ) );

				lFilename = strcat( "maps/", argv( lCurrent ), ".mapcfg" );
				if( TryFile( lFilename ) ) {
					localcmd(strcat("exec \"", lFilename ,"\"\n"));
					pass = 2; // exit the outer loop
					break;
				} else {
					dprint( "Couldn't find '", lFilename, "'..\n" );
				}
				//changelevel( argv( lCurrent ) );
			}
		}

		/*
		// method 1

		//local entity pos;
		local float fh;
		local string line;

		// restart current map if no cycle is found
		nextmap = strzone(mapname);
		fh = fopen("maplist.cfg", FILE_READ);
		if (fh >= 0)
		{
			while (1)
			{
				line = fgets(fh);
				if (nextmap == mapname)
				{
					strunzone(nextmap);
					nextmap = strzone(line);
				}
				if (!line)
					break;
				if (line == mapname)
				{
					line = fgets(fh);
					if (!line)
						break;
					strunzone(nextmap);
					nextmap = strzone(line);
					break;
				}
			}
			fclose(fh);
		}
		changelevel (nextmap);
		strunzone(nextmap);*/

		// method 3
		/*
		s = cvar_string("g_maplist");
		nummaps = tokenize(s);
		// if no map list, restart current one
		nextmap = mapname;
		if (nummaps >= 1)
		{
			n = 0;
			while (n < nummaps)
			{
				if (argv(n) == mapname)
					break;
				n = n + 1;
			}
			n = n + 1;
			if (n >= nummaps)
				n = 0;
			nextmap = argv(n);
		}
		changelevel (nextmap);
		*/
	}
};


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
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
	local float file, now;
	local string gametype, s;

	if(cvar("_printstats"))
		cvar_set("_printstats", "0");
	else if(!gameover)
		return;

	now = time;

	if (cvar("g_tdm"))
		gametype = "tdm";
	else if (cvar("g_ctf"))
		gametype = "ctf";
	else if (cvar("g_domination"))
		gametype = "dom";
	else if (cvar("g_runematch"))
		gametype = "rune";
	else
		gametype = "dm";

	if(gameover)
		s = ":scores:";
	else
		s = ":status:";

	s = strcat(s, gametype, "_", mapname, ":", ftos(rint(now)));

	if(cvar("sv_logscores_console"))
		localcmd(strcat("echo \"", s, "\"\n"));
	if(cvar("sv_logscores_file"))
	{
		file = fopen(cvar_string("sv_logscores_filename"), FILE_APPEND);
		fputs(file, strcat(s, "\n"));
	}

	other = findchain(classname, "player");
	while (other)
	{
		if ((clienttype(other) == CLIENTTYPE_REAL) || (clienttype(other) == CLIENTTYPE_BOT && cvar("sv_logscores_bots")))
		{
			s = strcat(":player:", ftos(other.frags), ":");
			s = strcat(s, ftos(other.deaths), ":");
			s = strcat(s, ftos(rint(now - other.jointime)), ":");
			s = strcat(s, ftos(other.team), ":");

			if(cvar("sv_logscores_file"))
				fputs(file, strcat(s, other.netname, "\n"));
			if(cvar("sv_logscores_console"))
			{
				local string ch;
				local float i;
				
				localcmd(strcat("echo \"", s));
				for(i = 0; i < strlen(other.netname); ++i)
				{
					ch = substring(other.netname, i, 1);
					if(ch != "\"" && ch != "\r" && ch != "\n")
						localcmd(ch);
				}
				localcmd("\"\n");
			}
		}
		other = other.chain;
	}

	if(cvar("sv_logscores_console"))
		localcmd("echo :end\n");
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
	intermission_exittime = time + cvar("sv_mapchange_delay");

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	//pos = FindIntermission ();

	VoteReset();

	DumpStats();

	other = findchainflags(flags, FL_CLIENT);
	while (other != world)
	{
		//other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.angles = other.v_angle;
		other.angles_x = other.angles_x * -1;

		self = other;
		weapon_action(other.weapon, WR_IDLE);

		if(clienttype(other) == CLIENTTYPE_REAL)
		if(cvar("sv_autoscreenshot"))
			stuffcmd(other, "screenshot\necho \"^5A screenshot has been taken at request of the server.\"\n");
		
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
	local float fraglimit;

	if (gameover)	// someone else quit the game already
		return;

	// fixme: don't check players; instead check dom_team and ctf_team entities

	fraglimit = cvar("fraglimit");

	if(!cvar("g_lms") && !(cvar("g_tdm") || (cvar("teamplay") && cvar("g_runematch"))))
	{
		if (fraglimit && self.frags >= fraglimit)
		{
			NextLevel ();
			return;
		}
	}
};

float checkrules_oneminutewarning;
float checkrules_leaderfrags;
entity checkrules_leader;
float tdm_max_score, tdm_old_score;

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void() CheckRules_World =
{
	local float timelimit;
	local float fraglimit;
	local float checkrules_oldleaderfrags;
	local float f;
	local entity checkrules_oldleader;
	local entity head;

	VoteThink();

	if (intermission_running)
	if (time >= intermission_exittime + 60)
	{
		GotoNextMap();
		return;
	}

	if (gameover)	// someone else quit the game already
		return;

	DumpStats();

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}

	if (!checkrules_oneminutewarning && timelimit && time > timelimit - 60)
	{
		checkrules_oneminutewarning = TRUE;
		sound(world, CHAN_AUTO, "announcer/robotic/1minuteremains.ogg", 1, ATTN_NONE);
	}

	if(cvar("minplayers"))
	{
		if(cvar("minplayers") >= maxclients)
			cvar_set("minplayers", ftos(maxclients - 1));
	
		f = cvar("minplayers") - (player_count - bot_number);
		if((player_count - bot_number) < 1)
			f = 0;

		if(cvar("bot_number") != f)
		{
			if(cvar("minplayers") != f)
				cvar_set("bot_number", ftos(f));
			else
				cvar_set("bot_number", "0");
		}
	}
	
	// last man camping winning conditions
	if(cvar("g_lms"))
	{
		if(lms_dead_count < 0)
			lms_dead_count = 0;

		// goto next map if only one player is alive or
		// if there is only one player as spectator (could happen with g_lms_join_anytime 1)
		if((player_count > 1 && (player_count - lms_dead_count) <= 1) ||
		  (player_count == 1 && lms_dead_count == 1))
			NextLevel();
		return;
	}

	if((cvar("g_tdm") || (cvar("teamplay") && cvar("g_runematch"))) && fraglimit)
	{
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

		tdm_old_score = tdm_max_score;
		tdm_max_score = max(team1_score, team2_score, team3_score, team4_score);

		if(tdm_max_score >= fraglimit)
			NextLevel();

		if(!cvar("g_domination") && !cvar("g_runematch"))
		if(tdm_max_score != tdm_old_score)
		{
			if(tdm_max_score == fraglimit - 1)
				sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.ogg", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 2)
				sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.ogg", 1, ATTN_NONE);
			else if(tdm_max_score == fraglimit - 3)
				sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.ogg", 1, ATTN_NONE);
		}
		return;
	}

	checkrules_oldleader = checkrules_leader;
	checkrules_oldleaderfrags = checkrules_leaderfrags;
	checkrules_leaderfrags = 0;
	checkrules_leader = world;
	head = findchain(classname, "player");
	while (head)
	{
		if (checkrules_leaderfrags < head.frags)
		{
			checkrules_leaderfrags = head.frags;
			checkrules_leader = head;
		}
		head = head.chain;
	}
	if (checkrules_leaderfrags <= 0)
	{
		checkrules_leader = world;
		checkrules_leaderfrags = 0;
	}
	checkrules_leaderfrags = floor(checkrules_leaderfrags);

	if (!cvar("g_domination") && !cvar("g_runematch"))
	if (checkrules_leaderfrags != checkrules_oldleaderfrags)
	{
		if (checkrules_leaderfrags == fraglimit - 1)
			sound(world, CHAN_AUTO, "announcer/robotic/1fragleft.ogg", 1, ATTN_NONE);
		else if (checkrules_leaderfrags == fraglimit - 2)
			sound(world, CHAN_AUTO, "announcer/robotic/2fragsleft.ogg", 1, ATTN_NONE);
		else if (checkrules_leaderfrags == fraglimit - 3)
			sound(world, CHAN_AUTO, "announcer/robotic/3fragsleft.ogg", 1, ATTN_NONE);
	}
//	if (checkrules_leader != checkrules_oldleader)// && checkrules_leaderfrags > checkrules_oldleaderfrags)
//		bprint("^1",checkrules_leader.netname, " has taken the lead with ", ftos(checkrules_leaderfrags), " frags\n");
};
