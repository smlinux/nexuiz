string cache_mutatormsg;
string cache_lastmutatormsg;

// client counts for each team
float c1, c2, c3, c4;
// # of bots on those teams
float cb1, cb2, cb3, cb4;

float audit_teams_time;

float IsTeamBalanceForced()
{
	if(intermission_running)
		return 0; // no rebalancing whatsoever please
	if(!teams_matter)
		return 0;
	if(cvar("g_campaign"))
		return 0;
	if(!cvar("g_balance_teams_force"))
		return -1;
	return 1;
}

void TeamchangeFrags(entity e)
{
	PlayerScore_Clear(e);
}

vector TeamColor(float teem)
{
	switch(teem)
	{
		case COLOR_TEAM1:
			return '1 0.0625 0.0625';
		case COLOR_TEAM2:
			return '0.0625 0.0625 1';
		case COLOR_TEAM3:
			return '1 1 0.0625';
		case COLOR_TEAM4:
			return '1 0.0625 1';
		default:
			return '1 1 1';
	}
}

string TeamName(float t)
{
	return strcat(Team_ColorName(t), " Team");
}
string ColoredTeamName(float t)
{
	return strcat(Team_ColorCode(t), Team_ColorName(t), " Team^7");
}
string TeamNoName(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == 1)
		return "Red Team";
	if(t == 2)
		return "Blue Team";
	if(t == 3)
		return "Yellow Team";
	if(t == 4)
		return "Pink Team";
	return "Neutral Team";
}

void dom_init();
void ctf_init();
void runematch_init();
void tdm_init();
void nb_init();
void entcs_init();

void LogTeamchange(float player_id, float team_number, float type)
{
	if(!cvar("sv_eventlog"))
		return;

	if(player_id < 1)
		return;

	GameLogEcho(strcat(":team:", ftos(player_id), ":", ftos(team_number), ":", ftos(type)));
}

void WriteGameCvars()
{
	cvar_set("g_dm", ftos(g_dm));
	cvar_set("g_tdm", ftos(g_tdm));
	cvar_set("g_domination", ftos(g_domination));
	cvar_set("g_ctf", ftos(g_ctf));
	cvar_set("g_runematch", ftos(g_runematch));
	cvar_set("g_lms", ftos(g_lms));
	cvar_set("g_arena", ftos(g_arena));
	cvar_set("g_ca", ftos(g_ca));
	cvar_set("g_keyhunt", ftos(g_keyhunt));
	cvar_set("g_assault", ftos(g_assault));
	cvar_set("g_onslaught", ftos(g_onslaught));
	cvar_set("g_race", ftos(g_race));
	cvar_set("g_nexball", ftos(g_nexball));
	cvar_set("g_cts", ftos(g_cts));
}

void ReadGameCvars()
{
	float found;
	float prev;
	float i;

	found = 0;
	prev = cvar("gamecfg");
	for(i = 0; i < 2; ++i)
	{
		found += (g_dm = (!found && (prev != GAME_DEATHMATCH) && cvar("g_dm")));
		found += (g_tdm = (!found && (prev != GAME_TEAM_DEATHMATCH) && cvar("g_tdm")));
		found += (g_domination = (!found && (prev != GAME_DOMINATION) && cvar("g_domination")));
		found += (g_ctf = (!found && (prev != GAME_CTF) && cvar("g_ctf")));
		found += (g_runematch = (!found && (prev != GAME_RUNEMATCH) && cvar("g_runematch")));
		found += (g_lms = (!found && (prev != GAME_LMS) && cvar("g_lms")));
		found += (g_arena = (!found && (prev != GAME_ARENA) && cvar("g_arena")));
		found += (g_ca = (!found && (prev != GAME_CA) && cvar("g_ca")));
		found += (g_keyhunt = (!found && (prev != GAME_KEYHUNT) && cvar("g_keyhunt")));
		found += (g_assault = (!found && (prev != GAME_ASSAULT) && cvar("g_assault")));
		found += (g_onslaught = (!found && (prev != GAME_ONSLAUGHT) && cvar("g_onslaught")));
		found += (g_race = (!found && (prev != GAME_RACE) && cvar("g_race")));
		found += (g_nexball = (!found && (prev != GAME_NEXBALL) && cvar("g_nexball")));
		found += (g_cts = (!found && (prev != GAME_CTS) && cvar("g_cts")));

		if(found)
			break;

		prev = -1; // second attempt takes place WITHOUT prev set
	}

	if(!found)
		g_dm = 1;

	if(g_dm && cvar("deathmatch_force_teamplay"))
	{
		g_dm = 0;
		g_tdm = 1;
	}

	teams_matter = 0;
}

void default_delayedinit()
{
	if(!scores_initialized)
		ScoreRules_generic();
}

void ActivateTeamplay()
{
	float teamplay_default;
	teamplay_default = cvar("teamplay_default");

	if(teamplay_default)
		teamplay = teamplay_default;
	else
		teamplay = 3;
	cvar_set("teamplay", ftos(teamplay));

	teams_matter = 1;
}

void InitGameplayMode()
{
	float fraglimit_override, timelimit_override, leadlimit_override, qualifying_override;

	qualifying_override = -1;

	VoteReset();

	teams_matter = 0;
	cvar_set("teamplay", "0");

	// make sure only ONE type is selected
	ReadGameCvars();
	WriteGameCvars();

	// find out good world mins/maxs bounds, either the static bounds found by looking for solid, or the mapinfo specified bounds
	get_mi_min_max(1);
	world.mins = mi_min;
	world.maxs = mi_max;

	MapInfo_LoadMapSettings(mapname);

	if not(cvar_value_issafe(world.fog))
	{
		print("The current map contains a potentially harmful fog setting, ignored\n");
		world.fog = string_null;
	}
	if(MapInfo_Map_fog != "")
		if(MapInfo_Map_fog == "none")
			world.fog = string_null;
		else
			world.fog = strzone(MapInfo_Map_fog);
	clientstuff = strzone(MapInfo_Map_clientstuff);

	MapInfo_ClearTemps();

	// in case mapinfo switched the type
	ReadGameCvars();

	// set both here, gamemode can override it later
	timelimit_override = cvar("timelimit_override");
	fraglimit_override = cvar("fraglimit_override");
	leadlimit_override = cvar("leadlimit_override");

	if(g_dm)
	{
		game = GAME_DEATHMATCH;
		gamemode_name = "Deathmatch";
	}

	if(g_tdm)
	{
		game = GAME_TEAM_DEATHMATCH;
		gamemode_name = "Team Deathmatch";
		ActivateTeamplay();
		tdm_init();
		if(cvar("g_tdm_team_spawns"))
			have_team_spawns = -1; // request team spawns
	}

	if(g_domination)
	{
		game = GAME_DOMINATION;
		gamemode_name = "Domination";
		ActivateTeamplay();
		fraglimit_override = cvar("g_domination_point_limit");
		leadlimit_override = cvar("g_domination_point_leadlimit");
		dom_init();
		have_team_spawns = -1; // request team spawns
	}

	if(g_ctf)
	{
		game = GAME_CTF;
		gamemode_name = "Capture the Flag";
		ActivateTeamplay();
		if(cvar("g_campaign"))
			g_ctf_win_mode = 2;
		else
			g_ctf_win_mode = cvar("g_ctf_win_mode");
		g_ctf_ignore_frags = cvar("g_ctf_ignore_frags");
		if(g_ctf_win_mode == 2)
		{
			fraglimit_override = cvar("g_ctf_capture_limit");
			leadlimit_override = cvar("g_ctf_capture_leadlimit");
		}
		else
		{
			fraglimit_override = cvar("capturelimit_override");
			leadlimit_override = cvar("captureleadlimit_override");
		}
		ctf_init();
		have_team_spawns = -1; // request team spawns
	}

	if(g_runematch)
	{
		game = GAME_RUNEMATCH;
		gamemode_name = "Rune Match";
		if(cvar("deathmatch_force_teamplay"))
			ActivateTeamplay();
		fraglimit_override = cvar("g_runematch_point_limit");
		leadlimit_override = cvar("g_runematch_point_leadlimit");
		runematch_init();
	}

	if(g_lms)
	{
		game = GAME_LMS;
		gamemode_name = "Last Man Standing";
		fraglimit_override = cvar("g_lms_lives_override");
		leadlimit_override = 0; // not supported by LMS
		if(fraglimit_override == 0)
			fraglimit_override = -1;
		lms_lowest_lives = 9999;
		lms_next_place = 0;
		ScoreRules_lms();
	}

	if(g_arena)
	{
		game = GAME_ARENA;
		gamemode_name = "Arena";
		fraglimit_override = cvar("g_arena_point_limit");
		leadlimit_override = cvar("g_arena_point_leadlimit");
		maxspawned = cvar("g_arena_maxspawned");
		if(maxspawned < 2)
			maxspawned = 2;
		arena_roundbased = cvar("g_arena_roundbased");
	}

	if(g_ca)
	{
		game = GAME_CA;
		gamemode_name = "Clan Arena";
		ActivateTeamplay();
		fraglimit_override = cvar("g_ca_point_limit");
		leadlimit_override = cvar("g_ca_point_leadlimit");
		precache_sound("ctf/red_capture.wav");
		precache_sound("ctf/blue_capture.wav");
	}
	if(g_keyhunt)
	{
		game = GAME_KEYHUNT;
		gamemode_name = "Key Hunt";
		ActivateTeamplay();
		fraglimit_override = cvar("g_keyhunt_point_limit");
		leadlimit_override = cvar("g_keyhunt_point_leadlimit");
		kh_init();
	}

	if(g_assault)
	{
		game = GAME_ASSAULT;
		gamemode_name = "Assault";
		ActivateTeamplay();
		ScoreRules_assault();
		have_team_spawns = -1; // request team spawns
	}

	if(g_onslaught)
	{
		game = GAME_ONSLAUGHT;
		gamemode_name = "Onslaught";
		ActivateTeamplay();
		have_team_spawns = -1; // request team spawns
	}

	if(g_race)
	{
		game = GAME_RACE;
		gamemode_name = "Race";

		if(cvar("g_race_teams"))
		{
			ActivateTeamplay();
			race_teams = bound(2, cvar("g_race_teams"), 4);
			have_team_spawns = -1; // request team spawns
		}
		else
			race_teams = 0;

		qualifying_override = cvar("g_race_qualifying_timelimit_override");
		fraglimit_override = cvar("g_race_laps_limit");
		leadlimit_override = 0; // currently not supported by race
	}

	if(g_cts)
	{
		game = GAME_CTS;
		gamemode_name = "CTS";
		g_race_qualifying = 1;
		fraglimit_override = 0;
		leadlimit_override = 0;
	}

	if(g_nexball)
	{
		game = GAME_NEXBALL;
		gamemode_name = "Nexball";
		fraglimit_override = cvar("g_nexball_goallimit");
		leadlimit_override = cvar("g_nexball_goalleadlimit");
		ActivateTeamplay();
		nb_init();
		have_team_spawns = -1; // request team spawns
	}

	if(teams_matter)
		entcs_init();

	// save it (for the next startup)
	cvar_set("gamecfg", ftos(game));

	cache_mutatormsg = strzone("");
	cache_lastmutatormsg = strzone("");

	// enforce the server's universal frag/time limits
	if(!cvar("g_campaign"))
	{
		if(fraglimit_override >= 0)
			cvar_set("fraglimit", ftos(fraglimit_override));
		if(timelimit_override >= 0)
			cvar_set("timelimit", ftos(timelimit_override));
		if(leadlimit_override >= 0)
			cvar_set("leadlimit", ftos(leadlimit_override));
		if(qualifying_override >= 0)
			cvar_set("g_race_qualifying_timelimit", ftos(qualifying_override));
	}

	if(g_race)
	{
		// we need to find out the correct value for g_race_qualifying
		if(cvar("g_campaign"))
		{
			g_race_qualifying = 1;
		}
		else if(!cvar("g_campaign") && cvar("g_race_qualifying_timelimit") > 0)
		{
			g_race_qualifying = 2;
			race_fraglimit = cvar("fraglimit");
			race_leadlimit = cvar("leadlimit");
			race_timelimit = cvar("timelimit");
			cvar_set("fraglimit", "0");
			cvar_set("leadlimit", "0");
			cvar_set("timelimit", cvar_string("g_race_qualifying_timelimit"));
		}
		else
			g_race_qualifying = 0;
	}

	if(g_race || g_cts)
	{
		if(g_race_qualifying)
			independent_players = 1;

		ScoreRules_race();
	}

	InitializeEntity(world, default_delayedinit, INITPRIO_GAMETYPE_FALLBACK);
}

string GetClientVersionMessage() {
	local string versionmsg;
	if (self.version_mismatch) {
		if(self.version < cvar("gameversion")) {
			versionmsg = "^3Your client version is outdated.\n\n\n### YOU WON'T BE ABLE TO PLAY ON THIS SERVER ###\n\n\nPlease update!!!^8";
		} else {
			versionmsg = "^3This server is using an outdated Nexuiz version.\n\n\n ### THIS SERVER IS INCOMPATIBLE AND THUS YOU CANNOT JOIN ###.^8";
		}
	} else {
		versionmsg = "^2client version and server version are compatible.^8";
	}
	return versionmsg;
}


void PrintWelcomeMessage(entity pl)
{
	string s, modifications, motd;

	if(self.cvar_scr_centertime == 0) return;

	if(cvar("g_campaign"))
	{
		if(self.classname == "player" && !self.BUTTON_INFO)
			return;
	}
	else
	{
		if((time - self.jointime) > cvar("welcome_message_time") && !self.BUTTON_INFO)
			return;
	}

	if( !(timeoutStatus >= 1) ) { //really print the WelcomeMessage to the player every frame when timeout-seconds are shown or the game is restarted, to make sure that the shown number is accurate
		if(self.welcomemessage_time > time) return;
		self.welcomemessage_time = time + max(0.5, self.cvar_scr_centertime * 0.6);
	}

	if(cvar("g_campaign"))
	{
		centerprint(pl, campaign_message);
		return;
	}

//TODO GreEn`mArine: make the timeout-messages clientside as well (just like the ready restart countdown)!
	if(!self.BUTTON_INFO)
	{
		// TODO get rid of this too
		local string specString;
		specString = NEWLINES;
		//if(time < game_starttime) //also show the countdown when being a spectator
		//	specString = strcat(specString, "\n\n^1Game starts in ", ftos(ceil(game_starttime - time)), " seconds^7");
		//else
		if (timeoutStatus != 0)
			specString = strcat(specString, "\n\n", getTimeoutText(1));
		else
		{
			if(self.classname == "player")
				return;
			goto normal;
		}
		return centerprint_atprio(self, CENTERPRIO_SPAM, specString);
	}

:normal
	modifications = "";
	if(g_minstagib)
		modifications = strcat(modifications, ", MinstaGib");
	if(g_nixnex)
		modifications = strcat(modifications, ", NixNex");
	if(g_weaponarena)
	{
		if(g_weaponarena_random)
			modifications = strcat(modifications, ", ", ftos(g_weaponarena_random), " of ", g_weaponarena_list, " Arena");
		else
			modifications = strcat(modifications, ", ", g_weaponarena_list, " Arena");
	}
	if(cvar("g_start_weapon_laser") == 0)
		modifications = strcat(modifications, ", No start weapons");
	if(cvar("sv_gravity") < 800)
		modifications = strcat(modifications, ", Low gravity");
	if(g_cloaked)
		modifications = strcat(modifications, ", Cloaked");
	if(g_footsteps)
		modifications = strcat(modifications, ", Steps");
	if(g_grappling_hook)
		modifications = strcat(modifications, ", Hook");
	if(g_laserguided_missile)
		modifications = strcat(modifications, ", LG missiles");
	if(g_midair)
		modifications = strcat(modifications, ", Midair");
	if(g_vampire)
		modifications = strcat(modifications, ", Vampire");
	if(g_pinata)
		modifications = strcat(modifications, ", Pinata");
	if(g_weapon_stay)
		modifications = strcat(modifications, ", Weapons stay");
	if(g_bloodloss > 0)
		modifications = strcat(modifications, ", Bloodloss");
	if(g_jetpack)
		modifications = strcat(modifications, ", Jet pack");
	modifications = substring(modifications, 2, strlen(modifications) - 2);

	local string versionmessage;
	versionmessage = GetClientVersionMessage();

	s = strcat(s, NEWLINES, "This is Nexuiz ", cvar_string("g_nexuizversion"), "\n", versionmessage);
	s = strcat(s, "^8\n\nmatch type is ^1", gamemode_name, "^8\n");

	if(modifications != "")
		s = strcat(s, "^8\nactive modifications: ^3", modifications, "^8\n");

	if(timeoutStatus != 0)
		s = strcat(s, "\n\n", getTimeoutText(1));

	if (g_grappling_hook)
		s = strcat(s, "\n\n^3grappling hook^8 is enabled, press 'e' to use it\n");

	if(cache_lastmutatormsg != cvar_string("g_mutatormsg"))
	{
		if(cache_lastmutatormsg)
			strunzone(cache_lastmutatormsg);
		if(cache_mutatormsg)
			strunzone(cache_mutatormsg);
		cache_lastmutatormsg = strzone(cvar_string("g_mutatormsg"));
		cache_mutatormsg = strzone(cache_lastmutatormsg);
	}

	if (cache_mutatormsg != "") {
		s = strcat(s, "\n\n^8special gameplay tips: ^7", cache_mutatormsg);
	}

	motd = cvar_string("sv_motd");
	if (motd != "") {
		s = strcat(s, "\n\n^8MOTD: ^7", strreplace("\\n", "\n", motd));
	}
	s = strcat(s, "\n");

	centerprint(pl, s);
}


void SetPlayerColors(entity pl, float _color)
{
	/*string s;
	s = ftos(cl);
	stuffcmd(pl, strcat("color ", s, " ", s, "\n")  );
	pl.team = cl + 1;
	//pl.clientcolors = pl.clientcolors - (pl.clientcolors & 15) + cl;
	pl.clientcolors = 16*cl + cl;*/

	float pants, shirt;
	pants = _color & 0x0F;
	shirt = _color & 0xF0;


	if(teams_matter) {
		setcolor(pl, 16*pants + pants);
	} else {
		setcolor(pl, shirt + pants);
	}
}

void SetPlayerTeam(entity pl, float t, float s, float noprint)
{
	float _color;

	if(t == 4)
		_color = COLOR_TEAM4 - 1;
	else if(t == 3)
		_color = COLOR_TEAM3 - 1;
	else if(t == 2)
		_color = COLOR_TEAM2 - 1;
	else
		_color = COLOR_TEAM1 - 1;

	SetPlayerColors(pl,_color);

	if(t != s) {
		LogTeamchange(pl.playerid, pl.team, 3);  // log manual team join

		if(!noprint)
		bprint(pl.netname, "^7 has changed from ", TeamNoName(s), " to ", TeamNoName(t), "\n");
	}

}

// set c1...c4 to show what teams are allowed
void CheckAllowedTeams (entity for_whom)
{
	float dm;
	entity head;
	string teament_name;

	c1 = c2 = c3 = c4 = -1;
	cb1 = cb2 = cb3 = cb4 = 0;

	if(g_onslaught)
	{
		// onslaught is special
		head = findchain(classname, "onslaught_generator");
		while (head)
		{
			if (head.team == COLOR_TEAM1) c1 = 0;
			if (head.team == COLOR_TEAM2) c2 = 0;
			if (head.team == COLOR_TEAM3) c3 = 0;
			if (head.team == COLOR_TEAM4) c4 = 0;
			head = head.chain;
		}
	}
	else if(g_domination)
		teament_name = "dom_team";
	else if(g_ctf)
		teament_name = "ctf_team";
	else if(g_tdm)
		teament_name = "tdm_team";
	else if(g_nexball)
		teament_name = "nexball_team";
	else if(g_assault)
		c1 = c2 = 0; // Assault always has 2 teams
	else
	{
		// cover anything else by treating it like tdm with no teams spawned
		if(g_keyhunt)
			dm = kh_teams;
		else if(g_race)
			dm = race_teams;
		else
			dm = 2;

		if(dm >= 4)
			c1 = c2 = c3 = c4 = 0;
		else if(dm >= 3)
			c1 = c2 = c3 = 0;
		else
			c1 = c2 = 0;
	}

	// find out what teams are allowed if necessary
	if(teament_name)
	{
		head = find(world, classname, teament_name);
		while(head)
		{
			if(!(g_domination && head.netname == ""))
			{
				if(head.team == COLOR_TEAM1)
					c1 = 0;
				else if(head.team == COLOR_TEAM2)
					c2 = 0;
				else if(head.team == COLOR_TEAM3)
					c3 = 0;
				else if(head.team == COLOR_TEAM4)
					c4 = 0;
			}
			head = find(head, classname, teament_name);
		}
	}

	// TODO: Balance quantity of bots across > 2 teams when bot_vs_human is set (and remove next line)
	if(c3==-1&&c4==-1)
	if(cvar("bot_vs_human") && for_whom)
	{
		if(cvar("bot_vs_human") > 0)
		{
			// bots are all blue
			if(clienttype(for_whom) == CLIENTTYPE_BOT)
				c1 = c3 = c4 = -1;
			else
				c2 = -1;
		}
		else
		{
			// bots are all red
			if(clienttype(for_whom) == CLIENTTYPE_BOT)
				c2 = c3 = c4 = -1;
			else
				c1 = -1;
		}
	}
}

float PlayerValue(entity p)
{
	if(IsTeamBalanceForced() == 1)
		return 1;
	return 1;
}

// c1...c4 should be set to -1 (not allowed) or 0 (allowed).
// teams that are allowed will now have their player counts stored in c1...c4
void GetTeamCounts(entity ignore)
{
	entity head;
	float value, bvalue;
	// now count how many players are on each team already

	// FIXME: also find and memorize the lowest-scoring bot on each team (in case players must be shuffled around)
	// also remember the lowest-scoring player

	FOR_EACH_PLAYER(head)
	{
		if(head != ignore)// && head.netname != "")
		{
			value = PlayerValue(head);
			if(clienttype(head) == CLIENTTYPE_BOT)
				bvalue = value;
			else
				bvalue = 0;
			if(head.team == COLOR_TEAM1)
			{
				if(c1 >= 0)
				{
					c1 = c1 + value;
					cb1 = cb1 + bvalue;
				}
			}
			if(head.team == COLOR_TEAM2)
			{
				if(c2 >= 0)
				{
					c2 = c2 + value;
					cb2 = cb2 + bvalue;
				}
			}
			if(head.team == COLOR_TEAM3)
			{
				if(c3 >= 0)
				{
					c3 = c3 + value;
					cb3 = cb3 + bvalue;
				}
			}
			if(head.team == COLOR_TEAM4)
			{
				if(c4 >= 0)
				{
					c4 = c4 + value;
					cb4 = cb4 + bvalue;
				}
			}
		}
	}
}

// returns # of smallest team (1, 2, 3, 4)
// NOTE: Assumes CheckAllowedTeams has already been called!
float FindSmallestTeam(entity pl, float ignore_pl)
{
	float totalteams, balance_type, maxc;
	totalteams = 0;

	// find out what teams are available
	//CheckAllowedTeams();

	// make sure there are at least 2 teams to join
	if(c1 >= 0)
		totalteams = totalteams + 1;
	if(c2 >= 0)
		totalteams = totalteams + 1;
	if(c3 >= 0)
		totalteams = totalteams + 1;
	if(c4 >= 0)
		totalteams = totalteams + 1;

	if(cvar("bot_vs_human"))
		totalteams += 1;

	if(totalteams <= 1)
	{
		if(g_domination)
			error("Too few teams available for domination\n");
		else if(g_ctf)
			error("Too few teams available for ctf\n");
		else if(g_keyhunt)
			error("Too few teams available for key hunt\n");
		else
			error("Too few teams available for team deathmatch\n");
	}

	// count how many players are in each team
	if(ignore_pl)
		GetTeamCounts(pl);
	else
		GetTeamCounts(world);

	// c1...c4 now have counts of each team
	// figure out which is smallest, giving priority to the team the player is already on as a tie-breaker

	// 2 gives priority to what team you're already on, 1 goes in order
	// 2 doesn't seem to work though...
	balance_type = 1;

	if(bots_would_leave)
	//if(pl.classname != "player")
	if(clienttype(pl) != CLIENTTYPE_BOT)
	{
		c1 -= cb1 * 255.0/256.0;
		c2 -= cb2 * 255.0/256.0;
		c3 -= cb3 * 255.0/256.0;
		c4 -= cb4 * 255.0/256.0;
	}
	maxc = max4(c1, c2, c3, c4);

	RandomSelection_Init();
	if(balance_type == 1)
	{
		// 1: use team count, then score (note: can only use 8 significant bits of score)
		if(c1 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + float2range01(-team1_score) / 256.0);
		if(c2 >= 0) RandomSelection_Add(world, 2, string_null, 1, (maxc - c2) + float2range01(-team2_score) / 256.0);
		if(c3 >= 0) RandomSelection_Add(world, 3, string_null, 1, (maxc - c3) + float2range01(-team3_score) / 256.0);
		if(c4 >= 0) RandomSelection_Add(world, 4, string_null, 1, (maxc - c4) + float2range01(-team4_score) / 256.0);
	}
	else if(balance_type == 2)
	{
		// 1: use team count, if equal prefer own team
		if(c1 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + (self.team == COLOR_TEAM1) / 512.0);
		if(c2 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + (self.team == COLOR_TEAM2) / 512.0);
		if(c3 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + (self.team == COLOR_TEAM3) / 512.0);
		if(c4 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + (self.team == COLOR_TEAM4) / 512.0);
	}
	else if(balance_type == 3)
	{
		// 1: use team count, then score, if equal prefer own team (probably fails due to float accuracy problems)
		if(c1 >= 0) RandomSelection_Add(world, 1, string_null, 1, (maxc - c1) + float2range01(-team1_score + 0.5 * (self.team == COLOR_TEAM1)) / 256.0);
		if(c2 >= 0) RandomSelection_Add(world, 2, string_null, 1, (maxc - c2) + float2range01(-team2_score + 0.5 * (self.team == COLOR_TEAM2)) / 256.0);
		if(c3 >= 0) RandomSelection_Add(world, 3, string_null, 1, (maxc - c3) + float2range01(-team3_score + 0.5 * (self.team == COLOR_TEAM3)) / 256.0);
		if(c4 >= 0) RandomSelection_Add(world, 4, string_null, 1, (maxc - c4) + float2range01(-team4_score + 0.5 * (self.team == COLOR_TEAM4)) / 256.0);
	}
	return RandomSelection_chosen_float;
}

float JoinBestTeam(entity pl, float only_return_best, float forcebestteam)
{
	float smallest, selectedteam;

	// don't join a team if we're not playing a team game
	if(!teams_matter)
		return 0;

	// find out what teams are available
	CheckAllowedTeams(pl);

	// if we don't care what team he ends up on, put him on whatever team he entered as.
	// if he's not on a valid team, then let other code put him on the smallest team
	if(!forcebestteam)
	{
		if(     c1 >= 0 && pl.team == COLOR_TEAM1)
			selectedteam = pl.team;
		else if(c2 >= 0 && pl.team == COLOR_TEAM2)
			selectedteam = pl.team;
		else if(c3 >= 0 && pl.team == COLOR_TEAM3)
			selectedteam = pl.team;
		else if(c4 >= 0 && pl.team == COLOR_TEAM4)
			selectedteam = pl.team;
		else
			selectedteam = -1;

		if(selectedteam > 0)
		{
			if(!only_return_best)
			{
				SetPlayerColors(pl, selectedteam - 1);

				// when JoinBestTeam is called by client.qc/ClientKill_Now_TeamChange the players team is -1 and thus skipped
				// when JoinBestTeam is called by cl_client.qc/ClientConnect the player_id is 0 the log attempt is rejected
				LogTeamchange(pl.playerid, pl.team, 99);
			}
			return selectedteam;
		}
		// otherwise end up on the smallest team (handled below)
	}

	smallest = FindSmallestTeam(pl, TRUE);

	if(!only_return_best)
	{
		TeamchangeFrags(self);
		if(smallest == 1)
		{
			SetPlayerColors(pl, COLOR_TEAM1 - 1);
		}
		else if(smallest == 2)
		{
			SetPlayerColors(pl, COLOR_TEAM2 - 1);
		}
		else if(smallest == 3)
		{
			SetPlayerColors(pl, COLOR_TEAM3 - 1);
		}
		else if(smallest == 4)
		{
			SetPlayerColors(pl, COLOR_TEAM4 - 1);
		}
		else
		{
			error("smallest team: invalid team\n");
		}

		LogTeamchange(pl.playerid, pl.team, 2); // log auto join

		if(pl.deadflag == DEAD_NO)
			Damage(pl, pl, pl, 100000, DEATH_TEAMCHANGE, pl.origin, '0 0 0');
	}

	return smallest;
}

//void() ctf_playerchanged;
void SV_ChangeTeam(float _color)
{
	float scolor, dcolor, steam, dteam, dbotcount, scount, dcount;

	// in normal deathmatch we can just apply the color and we're done
	if(!teams_matter) {
		SetPlayerColors(self, _color);
		return;
	}

	scolor = self.clientcolors & 0x0F;
	dcolor = _color & 0x0F;

	if(scolor == COLOR_TEAM1 - 1)
		steam = 1;
	else if(scolor == COLOR_TEAM2 - 1)
		steam = 2;
	else if(scolor == COLOR_TEAM3 - 1)
		steam = 3;
	else // if(scolor == COLOR_TEAM4 - 1)
		steam = 4;
	if(dcolor == COLOR_TEAM1 - 1)
		dteam = 1;
	else if(dcolor == COLOR_TEAM2 - 1)
		dteam = 2;
	else if(dcolor == COLOR_TEAM3 - 1)
		dteam = 3;
	else // if(dcolor == COLOR_TEAM4 - 1)
		dteam = 4;

	CheckAllowedTeams(self);

	if(dteam == 1 && c1 < 0) dteam = 4;
	if(dteam == 4 && c4 < 0) dteam = 3;
	if(dteam == 3 && c3 < 0) dteam = 2;
	if(dteam == 2 && c2 < 0) dteam = 1;

	// not changing teams
	if(scolor == dcolor)
	{
		//bprint("same team change\n");
		SetPlayerTeam(self, dteam, steam, TRUE);
		return;
	}

	if((cvar("g_campaign")) || (cvar("g_changeteam_banned") && self.wasplayer)) {
		sprint(self, "Team changes not allowed\n");
		return; // changing teams is not allowed
	}

	if(cvar("g_balance_teams_prevent_imbalance"))
	{
		// only allow changing to a smaller or equal size team

		// find out what teams are available
		//CheckAllowedTeams();
		// count how many players on each team
		GetTeamCounts(world);

		// get desired team
		if(dteam == 1 && c1 >= 0)//dcolor == COLOR_TEAM1 - 1)
		{
			dcount = c1;
			dbotcount = cb1;
		}
		else if(dteam == 2 && c2 >= 0)//dcolor == COLOR_TEAM2 - 1)
		{
			dcount = c2;
			dbotcount = cb2;
		}
		else if(dteam == 3 && c3 >= 0)//dcolor == COLOR_TEAM3 - 1)
		{
			dcount = c3;
			dbotcount = cb3;
		}
		else if(dteam == 4 && c4 >= 0)//dcolor == COLOR_TEAM4 - 1)
		{
			dcount = c4;
			dbotcount = cb4;
		}
		else
		{
			sprint(self, "Cannot change to an invalid team\n");

			return;
		}

		// get starting team
		if(steam == 1)//scolor == COLOR_TEAM1 - 1)
			scount = c1;
		else if(steam == 2)//scolor == COLOR_TEAM2 - 1)
			scount = c2;
		else if(steam == 3)//scolor == COLOR_TEAM3 - 1)
			scount = c3;
		else if(steam == 4)//scolor == COLOR_TEAM4 - 1)
			scount = c4;

		if(scount) // started at a valid, nonempty team
		{
			// check if we're trying to change to a larger team that doens't have bots to swap with
			if(dcount >= scount && dbotcount <= 0)
			{
				sprint(self, "Cannot change to a larger team\n");
				return; // can't change to a larger team
			}
		}
	}

//	bprint("allow change teams from ", ftos(steam), " to ", ftos(dteam), "\n");

	if(self.classname == "player" && steam != dteam)
	{
		// reduce frags during a team change
		TeamchangeFrags(self);
	}

	SetPlayerTeam(self, dteam, steam, FALSE);

	if(self.classname == "player" && steam != dteam)
	{
		// kill player when changing teams
		if(self.deadflag == DEAD_NO)
			Damage(self, self, self, 100000, DEATH_TEAMCHANGE, self.origin, '0 0 0');
	}
	//ctf_playerchanged();
}

void ShufflePlayerOutOfTeam (float source_team)
{
	float smallestteam, smallestteam_count, steam;
	float lowest_bot_score, lowest_player_score;
	entity head, lowest_bot, lowest_player, selected;

	smallestteam = 0;
	smallestteam_count = 999999999;

	if(c1 >= 0 && c1 < smallestteam_count)
	{
		smallestteam = 1;
		smallestteam_count = c1;
	}
	if(c2 >= 0 && c2 < smallestteam_count)
	{
		smallestteam = 2;
		smallestteam_count = c2;
	}
	if(c3 >= 0 && c3 < smallestteam_count)
	{
		smallestteam = 3;
		smallestteam_count = c3;
	}
	if(c4 >= 0 && c4 < smallestteam_count)
	{
		smallestteam = 4;
		smallestteam_count = c4;
	}

	if(!smallestteam)
	{
		bprint("warning: no smallest team\n");
		return;
	}

	if(source_team == 1)
		steam = COLOR_TEAM1;
	else if(source_team == 2)
		steam = COLOR_TEAM2;
	else if(source_team == 3)
		steam = COLOR_TEAM3;
	else if(source_team == 4)
		steam = COLOR_TEAM4;

	lowest_bot = world;
	lowest_bot_score = 999999999;
	lowest_player = world;
	lowest_player_score = 999999999;

	// find the lowest-scoring player & bot of that team
	FOR_EACH_PLAYER(head)
	{
		if(head.team == steam)
		{
			if(head.isbot)
			{
				if(head.totalfrags < lowest_bot_score)
				{
					lowest_bot = head;
					lowest_bot_score = head.totalfrags;
				}
			}
			else
			{
				if(head.totalfrags < lowest_player_score)
				{
					lowest_player = head;
					lowest_player_score = head.totalfrags;
				}
			}
		}
	}

	// prefers to move a bot...
	if(lowest_bot != world)
		selected = lowest_bot;
	// but it will move a player if it has to
	else
		selected = lowest_player;
	// don't do anything if it couldn't find anyone
	if(!selected)
	{
		bprint("warning: couldn't find a player to move from team\n");
		return;
	}

	// smallest team gains a member
	if(smallestteam == 1)
	{
		c1 = c1 + 1;
	}
	else if(smallestteam == 2)
	{
		c2 = c2 + 1;
	}
	else if(smallestteam == 3)
	{
		c3 = c3 + 1;
	}
	else if(smallestteam == 4)
	{
		c4 = c4 + 1;
	}
	else
	{
		bprint("warning: destination team invalid\n");
		return;
	}
	// source team loses a member
	if(source_team == 1)
	{
		c1 = c1 + 1;
	}
	else if(source_team == 2)
	{
		c2 = c2 + 2;
	}
	else if(source_team == 3)
	{
		c3 = c3 + 3;
	}
	else if(source_team == 4)
	{
		c4 = c4 + 4;
	}
	else
	{
		bprint("warning: source team invalid\n");
		return;
	}

	// move the player to the new team
	TeamchangeFrags(selected);
	SetPlayerTeam(selected, smallestteam, source_team, FALSE);

	if(selected.deadflag == DEAD_NO)
		Damage(selected, selected, selected, 100000, DEATH_AUTOTEAMCHANGE, selected.origin, '0 0 0');
	centerprint(selected, strcat("You have been moved into a different team to improve team balance\nYou are now on: ", ColoredTeamName(selected.team)));
}

void CauseRebalance(float source_team, float howmany_toomany)
{
	if(IsTeamBalanceForced() == 1)
	{
		bprint("Rebalancing Teams\n");
		ShufflePlayerOutOfTeam(source_team);
	}
}

// part of g_balance_teams_force
// occasionally perform an audit of the teams to make
// sure they're more or less balanced in player count.
void AuditTeams()
{
	float numplayers, numteams, smallest, toomany;
	float balance;
	balance = IsTeamBalanceForced();
	if(balance == 0)
		return;

	if(audit_teams_time > time)
		return;

	audit_teams_time = time + 4 + random();

//	bprint("Auditing teams\n");

	CheckAllowedTeams(world);
	GetTeamCounts(world);


	numteams = numplayers = smallest = 0;
	if(c1 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c1;
		smallest = c1;
	}
	if(c2 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c2;
		if(c2 < smallest)
			smallest = c2;
	}
	if(c3 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c3;
		if(c3 < smallest)
			smallest = c3;
	}
	if(c4 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c4;
		if(c4 < smallest)
			smallest = c4;
	}

	if(numplayers <= 0)
		return; // no players to move around
	if(numteams < 2)
		return; // don't bother shuffling if for some reason there aren't any teams

	toomany = smallest + 1;

	if(c1 && c1 > toomany)
		CauseRebalance(1, c1 - toomany);
	if(c2 && c2 > toomany)
		CauseRebalance(2, c2 - toomany);
	if(c3 && c3 > toomany)
		CauseRebalance(3, c3 - toomany);
	if(c4 && c4 > toomany)
		CauseRebalance(4, c4 - toomany);

	// if teams are still unbalanced, balance them further in the next audit,
	// which will happen sooner (keep doing rapid audits until things are in order)
	audit_teams_time = time + 0.7 + random()*0.3;
}

// code from here on is just to support maps that don't have team entities
void tdm_spawnteam (string teamname, float teamcolor)
{
	local entity e;
	e = spawn();
	e.classname = "tdm_team";
	e.netname = teamname;
	e.cnt = teamcolor;
	e.team = e.cnt + 1;
};

// spawn some default teams if the map is not set up for tdm
void tdm_spawnteams()
{
	float numteams;

	numteams = cvar("g_tdm_teams_override");
	if(numteams < 2)
		numteams = cvar("g_tdm_teams");
	numteams = bound(2, numteams, 4);

	tdm_spawnteam("Red", COLOR_TEAM1-1);
	tdm_spawnteam("Blue", COLOR_TEAM2-1);
	if(numteams >= 3)
		tdm_spawnteam("Yellow", COLOR_TEAM3-1);
	if(numteams >= 4)
		tdm_spawnteam("Pink", COLOR_TEAM4-1);
};

void tdm_delayedinit()
{
	// if no teams are found, spawn defaults
	if (find(world, classname, "tdm_team") == world)
		tdm_spawnteams();
};

void tdm_init()
{
	InitializeEntity(world, tdm_delayedinit, INITPRIO_GAMETYPE);
};
