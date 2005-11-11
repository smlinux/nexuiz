
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
	precache_model ("models/gibs/gib2.md3");
	precache_model ("models/gibs/gib3.md3");
	precache_model ("models/gibs/gib4.md3");
	precache_model ("models/gibs/gib5.md3");
	precache_model ("models/gibs/gib6.md3");
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
	precache_model ("models/nexflash.md3");
	precache_model ("models/plasma.mdl");
	precache_model ("models/plasmatrail.mdl");
	precache_model ("models/rocket.md3");
	precache_model ("models/sprites/grenadeexplosion.spr32");
	precache_model ("models/sprites/hagarexplosion.spr32");
	precache_model ("models/sprites/muzzleflash.spr32");
	precache_model ("models/sprites/electrocombo.spr32");
	//precache_model ("models/sprites/plasmahitwall.spr32");
	//precache_model ("models/sprites/plasmashot.spr32");
	precache_model ("models/sprites/rocketexplosion.spr32");
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

	precache_sound ("announcer/1fragleft.wav");
	precache_sound ("announcer/1minuteremains.wav");
	precache_sound ("announcer/2fragsleft.wav");
	precache_sound ("announcer/3fragsleft.wav");
	precache_sound ("announcer/welcometonexuiz.wav");
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
	precache_sound ("misc/hitground1.wav");
	precache_sound ("misc/hitground2.wav");
	precache_sound ("misc/hitground3.wav");
	precache_sound ("misc/hitground4.wav");
	precache_sound ("misc/itempickup.wav");
	precache_sound ("misc/itemrespawn.wav");
	precache_sound ("misc/jumppad.wav");
	precache_sound ("misc/mediumhealth.wav");
	precache_sound ("misc/megahealth.wav");
	precache_sound ("misc/minihealth.wav");
	precache_sound ("misc/powerup.wav");
	precache_sound ("misc/talk.wav");
	precache_sound ("misc/teleport.wav");
	precache_sound ("plats/medplat1.wav");
	precache_sound ("plats/medplat2.wav");
	precache_sound ("player/lava.wav");
	precache_sound ("player/slime.wav");
	precache_sound ("weapons/crylink.ogg");
	precache_sound ("weapons/crylink2.ogg");
	precache_sound ("weapons/electro_bounce.ogg");
	precache_sound ("weapons/electro_fire.ogg");
	precache_sound ("weapons/electro_fire2.ogg");
	precache_sound ("weapons/electro_fly.wav");
	precache_sound ("weapons/electro_impact.ogg");
	precache_sound ("weapons/electro_impact_combo.ogg");
	precache_sound ("weapons/grenade_bounce.ogg");
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
	precache_sound ("weapons/ric1.wav");
	precache_sound ("weapons/ric2.wav");
	precache_sound ("weapons/ric3.wav");
	precache_sound ("weapons/rocket_fire.wav");
	precache_sound ("weapons/rocket_fly.wav");
	precache_sound ("weapons/rocket_impact.wav");
	precache_sound ("weapons/shotgun_fire.wav");
	precache_sound ("weapons/tink1.wav");
	precache_sound ("weapons/uzi_fire.wav");
	precache_sound ("weapons/weapon_switch.wav");
	precache_sound ("weapons/weaponpickup.wav");



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

	InitGameplayMode();
	//if (cvar("g_domination"))
	//	dom_init();
}

void light (void)
{
	makestatic (self);
}


// reads and alters data/maplist.cfg (sliding it one line), and returns a
// strzoned string containing the next map
string() Nex_RotateMapList =
{
	local float lHandle;
	local string lNextMap;
	local string lCurrentMap;
	local string lBuffer;

	lHandle = fopen( "maplist.cfg", FILE_READ );
	if( lHandle < 0 ) {
		fclose( lHandle );
		// restart the current map if no other map is not found
		return strzone( mapname );
	}

	// get the first line that will be moved to the end later
	lCurrentMap = strzone( fgets( lHandle ) );
	if( !lCurrentMap ) {
		fclose( lHandle );
		// restart the current map if no other map is not found
		return strzone( mapname );
	}

	// now get the second line which is the map that should be loaded next
	lBuffer = fgets( lHandle );
	// if there isnt a second line, nothing needs to be rotated
	if( !lBuffer ) {
		fclose( lHandle );
		strunzone( lCurrentMap );
		// restart the current map if no other map is not found
		return strzone( mapname );
	}

	// since lBuffer holds the next map, it is assigned to nextmap
	lNextMap = strzone( lBuffer );

	// since fgets uses its own buffer we need to move lBuffer to a tempstring
	// before reading the next line (or lBuffer will be lost)
	lBuffer = strcat( lBuffer );

	// read in the rest of the list
	while( 1 )  {
		local string lLine;

		lLine = fgets( lHandle );
		if( !lLine ) {
			break;
		}

		lBuffer = strcat( lBuffer, "\n", lLine );
	}
	// rotate the list
	lBuffer = strcat( lBuffer, "\n", lCurrentMap );

	// dismiss lCurrentmap now
	strunzone( lCurrentMap );

	// and close the file handle
	fclose( lHandle );

	// open the maplist for output this one
	lHandle = fopen( "maplist.cfg", FILE_WRITE );
	if( lHandle < 0 ) {
		// this shouldnt happen!
		// print a warning/error message
		dprint( "Couldn't open ", "maplist.cfg", " for output!\n" );

		strunzone( lNextMap );

		// we return the currently running map
		return strzone( mapname );
	}

	fputs( lHandle, lBuffer );

	fclose( lHandle );

	return lNextMap;
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

	// if an exit cfg is defined by exiting map, exec it.
	exit_cfg = cvar_string("exit_cfg");
	if(exit_cfg != "")
		localcmd(strcat("exec \"", exit_cfg, "\"\n"));

	ResetGameCvars();


	if (cvar("samelevel"))	// if samelevel is set, stay on same level
	{
		localcmd(strcat("exec \"maps/", mapname, ".mapcfg\"\n"));
		//changelevel (mapname);
	}
	else
	{
		// method 0
		local float lCurrent;
		local float lSize;

		lSize = tokenize( cvar_string( "g_maplist" ) );
		lCurrent = cvar( "g_maplist_index" );

		lCurrent = lCurrent + 1;
		if( lCurrent >= lSize ) {
			lCurrent = 0;
		}

		cvar_set( "g_maplist_index", ftos( lCurrent ) );


		localcmd(strcat("exec \"maps/", argv( lCurrent ), ".mapcfg\"\n"));
		//changelevel( argv( lCurrent ) );


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

		// method 2
		//nextmap = Nex_RotateMapList();
		//changelevel (nextmap);
		//strunzone (nextmap);
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

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	intermission_exittime = time + 5;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	//pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		//other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.angles = other.v_angle;
		other.angles_x = other.angles_x * -1;
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
		other = find (other, classname, "player");
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

	if(cvar("g_domination"))
	{
		// fixme: check team frags, not players!
		if (fraglimit && self.frags >= fraglimit)
		{
			NextLevel ();
			return;
		}
	}
	else
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
	local entity checkrules_oldleader;
	local entity head;

	if (intermission_running)
	if (time >= intermission_exittime + 60)
	{
		GotoNextMap();
		return;
	}

	if (gameover)	// someone else quit the game already
		return;

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
		sound(world, CHAN_AUTO, "announcer/1minuteremains.wav", 1, ATTN_NONE);
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
	if (checkrules_leaderfrags != checkrules_oldleaderfrags)
	{
		if (checkrules_leaderfrags == fraglimit - 1)
			sound(world, CHAN_AUTO, "announcer/1fragleft.wav", 1, ATTN_NONE);
		else if (checkrules_leaderfrags == fraglimit - 2)
			sound(world, CHAN_AUTO, "announcer/2fragsleft.wav", 1, ATTN_NONE);
		else if (checkrules_leaderfrags == fraglimit - 3)
			sound(world, CHAN_AUTO, "announcer/3fragsleft.wav", 1, ATTN_NONE);
	}
//	if (checkrules_leader != checkrules_oldleader)// && checkrules_leaderfrags > checkrules_oldleaderfrags)
//		bprint("^1",checkrules_leader.netname, " has taken the lead with ", ftos(checkrules_leaderfrags), " frags\n");
};
