float GAME_DEATHMATCH		= 1;
float GAME_TEAM_DEATHMATCH	= 2;
float GAME_DOMINATION		= 3;
float GAME_CTF			= 4;
float GAME_RUNEMATCH		= 5;
float GAME_LMS			= 6;
float GAME_ARENA		= 7;
float GAME_KEYHUNT		= 8;

// client counts for each team
float c1, c2, c3, c4;
// # of bots on those teams
float cb1, cb2, cb3, cb4;

float g_domination, g_ctf, g_tdm, g_keyhunt;

float audit_teams_time;

float() IsTeamBalanceForced = {
	if(intermission_running)
		return 0; // no rebalancing whatsoever please
	if(!cvar("teamplay"))
		return 0;
	if(cvar("g_campaign"))
		return 0;
	if(!cvar("g_balance_teams_force"))
		return -1;
	return 1;
}

void TeamchangeFrags(entity e)
{
	if(e.classname == "player")
	{
		// reduce frags during a team change
		DistributeFragsAmongTeam(e, (e.clientcolors & 0x0F) + 1, 1 - cvar("g_changeteam_fragtransfer") / 100);
	}
}

string TeamName(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == COLOR_TEAM1)
		return "Red Team";
	if(t == COLOR_TEAM2)
		return "Blue Team";
	if(t == COLOR_TEAM3)
		return "Yellow Team";
	if(t == COLOR_TEAM4)
		return "Pink Team";
	return "Neutral Team";
}
string ColoredTeamName(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == COLOR_TEAM1)
		return "^1Red Team^7";
	if(t == COLOR_TEAM2)
		return "^4Blue Team^7";
	if(t == COLOR_TEAM3)
		return "^3Yellow Team^7";
	if(t == COLOR_TEAM4)
		return "^6Pink Team^7";
	return "Neutral Team";
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

void(entity pl) LogTeamchange =
{
	string str;
	if(!cvar("sv_eventlog"))
		return;
	if(pl.playerid < 1)
		return;
	str = strcat(":team:", ftos(pl.playerid), ":");
	str = strcat(str, ftos(pl.team));
	GameLogEcho(str, FALSE);
}

void ResetGameCvars()
{
	cvar_set("g_tdm", "0");
	cvar_set("g_domination", "0");
	cvar_set("g_ctf", "0");
	cvar_set("g_runematch", "0");
	cvar_set("g_lms", "0");
	cvar_set("g_arena", "0");
	cvar_set("g_keyhunt", "0");
	cvar_set("teamplay", "0");
}

void ActivateTeamplay()
{
	float teamplay_default;
	teamplay_default = cvar("teamplay_default");

	if(teamplay_default)
		cvar_set("teamplay", ftos(teamplay_default));
	else
		cvar_set("teamplay", "3");
}

void InitGameplayMode()
{
	float fraglimit_override, timelimit_override;

	VoteReset();

	game = cvar ("gamecfg");	// load game options

	// game cvars get reset before map changes
	// then map's cfg sets them as desired

	// FIXME: also set a message or game mode name to print to players when the join

	// set both here, gamemode can override it later
	timelimit_override = cvar("timelimit_override");
	fraglimit_override = cvar("fraglimit_override");

	if(game == GAME_DOMINATION || cvar("g_domination"))
	{
		ResetGameCvars();
		game = GAME_DOMINATION;
		cvar_set("g_domination", "1");

		ActivateTeamplay();

		fraglimit_override = cvar("g_domination_point_limit");

		gamemode_name = "Domination";
		teams_matter = 1;
	}
	else if(game == GAME_CTF || cvar("g_ctf"))
	{
		ResetGameCvars();
		game = GAME_CTF;
		cvar_set("g_ctf", "1");

		ActivateTeamplay();

		fraglimit_override = cvar("g_ctf_capture_limit");

		gamemode_name = "Capture the Flag";
		teams_matter = 1;
	}
	else if((game == GAME_RUNEMATCH || cvar("g_runematch")) && !cvar("g_minstagib"))
	{
		game = GAME_RUNEMATCH;
		cvar_set("g_runematch", "1");

		if(cvar("deathmatch_force_teamplay"))
			ActivateTeamplay();

		fraglimit_override = cvar("g_runematch_point_limit");

		gamemode_name = "Rune Match";
		if(cvar("teamplay"))
			teams_matter = 1;
		else
			teams_matter = 0;
	}
	else if(game == GAME_DEATHMATCH || game == GAME_TEAM_DEATHMATCH || cvar("g_tdm"))
	{
		if(!cvar("deathmatch"))
			cvar_set("deathmatch", "1");


		if(game == GAME_TEAM_DEATHMATCH || cvar("g_tdm") || cvar("deathmatch_force_teamplay"))
		{
			ResetGameCvars();
			game = GAME_TEAM_DEATHMATCH;
			gamemode_name = "Team Deathmatch";
			ActivateTeamplay();
			teams_matter = 1;
			cvar_set("g_tdm", "1");
		}
		else
		{
			ResetGameCvars();
			game = GAME_DEATHMATCH;
			gamemode_name = "Deathmatch";
			teams_matter = 0;
		}

		fraglimit_override = cvar("fraglimit_override");
	}
	else if(game == GAME_LMS || cvar("g_lms"))
	{
		ResetGameCvars();
		game = GAME_LMS;
		cvar_set("g_lms", "1");
		fraglimit_override = cvar("g_lms_lives_override");
		if(fraglimit_override == 0)
			fraglimit_override = -1;
		gamemode_name = "Last Man Standing";
		teams_matter = 0;
		lms_lowest_lives = 999;
	}
	else if(game == GAME_ARENA || cvar("g_arena"))
	{
		ResetGameCvars();
		game = GAME_ARENA;
		cvar_set("g_arena", "1");
		fraglimit_override = cvar("g_arena_point_limit");
		maxspawned = cvar("g_arena_maxspawned");
		if(maxspawned < 2)
			maxspawned = 2;
		arena_roundbased = cvar("g_arena_roundbased");
		gamemode_name = "Arena";
		teams_matter = 0;
	}
	else if(game == GAME_KEYHUNT || cvar("g_keyhunt"))
	{
		ResetGameCvars();
		game = GAME_KEYHUNT;
		cvar_set("g_keyhunt", "1");
		fraglimit_override = cvar("g_keyhunt_point_limit");
		ActivateTeamplay();
		gamemode_name = "Key Hunt";
		teams_matter = 1;
	}
	else
	{
		// we can only assume...
		ResetGameCvars();
		gamemode_name = "Deathmatch";
		teams_matter = 0;
	}
/*	else if(game == GAME_TEAM_DEATHMATCH)
	{
		if(!cvar("deathmatch"))
			cvar_set("deathmatch", "1");

		//if(!cvar("teamplay"))
		//	cvar_set("teamplay", "3");
		ActivateTeamplay();

		fraglimit_override = cvar("fraglimit_override");
	}*/

	// enforce the server's universal frag/time limits
	if(!cvar("g_campaign"))
	{
		if(fraglimit_override >= 0)
			cvar_set("fraglimit", ftos(fraglimit_override));
		if(timelimit_override >= 0)
			cvar_set("timelimit", ftos(timelimit_override));
	}

	if (game == GAME_DOMINATION)//cvar("g_domination"))
		dom_init();
	else if (game == GAME_CTF)//cvar("g_ctf"))
		ctf_init();
	else if (game == GAME_RUNEMATCH)//cvar("g_runematch"))
		runematch_init();
	else if (game == GAME_TEAM_DEATHMATCH)//cvar("g_runematch"))
		tdm_init();
	else if (game == GAME_KEYHUNT)//cvar("g_keyhunt"))
		kh_init();

	// those mutators rule each other out
	if(cvar("g_minstagib"))
	{
		cvar_set("g_instagib", "0");
		cvar_set("g_rocketarena", "0");
	}
	if(cvar("g_instagib"))
	{
		cvar_set("g_minstagib", "0");
		cvar_set("g_rocketarena", "0");
	}
	if(cvar("g_rocketarena"))
	{
		cvar_set("g_instagib", "0");
		cvar_set("g_minstagib", "0");
	}

	registercvar("_motd", "");
	registercvar("_mutatormsg", "");
	cvar_set("_motd", wordwrap(cvar_string("sv_motd"), 50));
	cvar_set("_mutatormsg", wordwrap(cvar_string("g_mutatormsg"), 50));

	g_domination = cvar("g_domination");
	g_ctf = cvar("g_ctf");
	g_tdm = cvar("g_tdm");
	g_keyhunt = cvar("g_keyhunt");
}

string GetClientVersionMessage(float v) {
	local string versionmsg;
	if (v == 1) {
		versionmsg = "^1client is too old to get versioninfo.\n\n\n### YOU WON'T BE ABLE TO PLAY ON THIS SERVER ###\n\n\nUPDATE!!! (http://www.nexuiz.com)^8";
		// either that or someone wants to be funny
	} else if (v != cvar("gameversion")) {
		if(v < cvar("gameversion")) {
			versionmsg = "^3Your client version is outdated.\n\n\n### YOU WON'T BE ABLE TO PLAY ON THIS SERVER ###\n\n\nPlease update!!!^8";
		} else {
			versionmsg = "^3This server is using an outdated Nexuiz version.\n\n\n ### THIS SERVER IS INCOMPATIBLE AND THUS YOU CANNOT JOIN ###.^8";
		}
	} else {
		versionmsg = "^2client version and server version are compatible.^8";
	}
	return strzone(versionmsg);

}


void PrintWelcomeMessage(entity pl)
{
	string s, mutator, modifications, padding;

	/*if(self.welcomemessage_time > time)
		return;
	self.welcomemessage_time = time + 0.8; */

	if(self.cvar_scr_centertime == 0) return;
	if(self.welcomemessage_time > time) return;
	self.welcomemessage_time = time + self.cvar_scr_centertime * 0.6;

	if(cvar("g_campaign"))
	{
		centerprint(pl, campaign_message);
		return;
	}

	if(self.classname == "observer")
	{
		if(cvar("g_lms") && self.frags <= 0 && self.frags > -666)
			return centerprint(self, strcat(NEWLINES, "^1You have no more lives left\nwait for next round\n\n\n^7press attack to spectate other players"));
		else if(cvar("g_lms") && self.frags == -666)
			return centerprint(self, strcat(NEWLINES, "^1Match has already begun\nwait for next round\n\n\n^7press attack to spectate other players"));
	}
	else if(self.classname == "spectator")
	{
		if ((cvar("g_lms") && self.frags < 1) || cvar("g_arena"))
			return centerprint(self, strcat(NEWLINES, "spectating ", self.enemy.netname, "\n\n\n^7press attack for next player\npress attack2 for free fly mode"));
		else
			return centerprint(self, strcat(NEWLINES, "spectating ", self.enemy.netname, "\n\n\n^7press jump to play\n^7press attack for next player\npress attack2 for free fly mode"));
	}


	if(cvar("g_minstagib"))
		mutator = "^2Minstagib ^1";
	else if(cvar("g_instagib"))
		mutator = "^2Instagib ^1";
	else if(cvar("g_rocketarena"))
		mutator = "^2Rocketarena ^1";
	else if(cvar("g_nixnex"))
		mutator = "^2No Items Nexuiz ^1";

	if(cvar("g_midair")) {
		// to protect against unheedingly made changes
		if (modifications) {
			modifications = strcat(modifications, ", ");
		}
		modifications = "midair";
	}
	if(cvar("g_vampire")) {
		if (modifications) {
			modifications = strcat(modifications, ", ");
		}
		modifications = strcat(modifications, "vampire");
	}
	if(cvar("g_laserguided_missile")) {
		if (modifications) {
			modifications = strcat(modifications, ", ");
		}
		modifications = strcat(modifications, "laser-guided-missiles");
	}

	local string versionmessage;
	versionmessage = GetClientVersionMessage(self.version);

	s = strcat(s, NEWLINES, "This is Nexuiz ", cvar_string("g_nexuizversion"), "\n", versionmessage);
	s = strcat(s, "^8\n\nmatch type is ^1", mutator, gamemode_name, "^8\n");

	if(modifications != "")
		s = strcat(s, "^8\nactive modifications: ^3", modifications, "^8\n");

	if((self.classname == "observer" || self.classname == "spectator") && self.version == cvar("gameversion")) {
		if(!cvar("g_arena"))
			s = strcat(s,"^7\n\n\npress jump to play\npress attack to spectate other players\n\n");
		else if(player_count < 2 && arena_roundbased)
		{
			s = strcat(s, "\n\n\n^1waiting for second player to start match^7\n\n");
		}
		else
		{
			s = strcat(s, "\n\n\n");
			if(champion)
				s = strcat(s, "^7current champion is: ", champion.netname, "\n\n");
			s = strcat(s,"^7press attack to spectate other players\n\n");
		}
	}


	s = strzone(s);

	if (cvar("g_grappling_hook"))
		s = strcat(s, "\n\n^8grappling hook is enabled, press 'e' to use it\n");

	if (cvar_string("_mutatormsg") != "") {
		s = strcat(s, "\n\n^8special gameplay tips: ^7", cvar_string("_mutatormsg"));
	}

	if (cvar_string("_motd") != "") {
		s = strcat(s, "\n\n^8MOTD: ^7", cvar_string("_motd"));
	}

	s = strcat(s, "\n");
	if(cvar("fraglimit"))
	{
		padding = "";
		if(cvar("timelimit"))
			padding = "        ";
			//        " minutes"
		s = strcat(s, "\n^8frag limit: ^7", cvar_string("fraglimit"), padding);
	}
	if(cvar("timelimit"))
		s = strcat(s, "\n^8time limit: ^7", cvar_string("timelimit"), " minutes");

	s = strzone(s);

	centerprint(pl, s);
	//sprint(pl, s);

	strunzone(s);
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


	if(teamplay) {
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

	if(!noprint && t != s)
	{
		//bprint(pl.netname, " has changed to ", TeamNoName(t), "\n");
		bprint(pl.netname, "^7 has changed from ", TeamNoName(s), " to ", TeamNoName(t), "\n");
	}

	if(t != s)
		LogTeamchange(pl);
}






// set c1...c4 to show what teams are allowed
void CheckAllowedTeams ()
{
	string teament_name;
	float dm;
	entity head;

//	if(!dom && !ctf)
//		dm = 1;

	c1 = c2 = c3 = c4 = -1;
	cb1 = cb2 = cb3 = cb4 = 0;

	if(g_domination)
		teament_name = "dom_team";
	else if(g_ctf)
		teament_name = "ctf_team";
	else if(g_tdm)
		teament_name = "tdm_team";
	else
	{
		// cover anything else by treating it like tdm with no teams spawned
		if(g_keyhunt)
			dm = kh_teams;
		else
			dm = cvar("g_tdm_teams");
		if(dm < 2)
			error("g_tdm_teams < 2, not enough teams to play team deathmatch\n");

		if(dm >= 4)
		{
			c1 = c2 = c3 = c4 = 0;
		}
		else if(dm >= 3)
		{
			c1 = c2 = c3 = 0;
		}
		else// if(dm >= 2)
		{
			c1 = c2 = 0;
		}
		return;
	}

	// first find out what teams are allowed
	head = find(world, classname, teament_name);
	while(head)
	{
		if(!(g_domination && head.netname == ""))
		{
			if(head.team == COLOR_TEAM1)
			{
				c1 = 0;
			}
			if(head.team == COLOR_TEAM2)
			{
				c2 = 0;
			}
			if(head.team == COLOR_TEAM3)
			{
				c3 = 0;
			}
			if(head.team == COLOR_TEAM4)
			{
				c4 = 0;
			}
		}
		head = find(head, classname, teament_name);
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
	float totalteams, smallestteam, smallestteam_count, smallestteam_score, balance_type;
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

	smallestteam = 0;
	smallestteam_count = 999999999;
	smallestteam_score = 999999999;

	// 2 gives priority to what team you're already on, 1 goes in order
	// 2 doesn't seem to work though...
	balance_type = 1;

	if(bots_would_leave)
	//if(pl.classname != "player")
	if(clienttype(pl) != CLIENTTYPE_BOT)
	{
		c1 -= cb1 * 255.0/256;
		c2 -= cb2 * 255.0/256;
		c3 -= cb3 * 255.0/256;
		c4 -= cb4 * 255.0/256;
	}

	if(balance_type == 1)
	{
		if(c1 >= 0 && (c1 < smallestteam_count || (c1 <= smallestteam_count && team1_score < smallestteam_score)))
		{
			smallestteam = 1;
			smallestteam_count = c1;
			smallestteam_score = team1_score;
		}
		if(c2 >= 0 && (c2 < smallestteam_count || (c2 <= smallestteam_count && team2_score < smallestteam_score)))
		{
			smallestteam = 2;
			smallestteam_count = c2;
			smallestteam_score = team2_score;
		}
		if(c3 >= 0 && (c3 < smallestteam_count || (c3 <= smallestteam_count && team3_score < smallestteam_score)))
		{
			smallestteam = 3;
			smallestteam_count = c3;
			smallestteam_score = team3_score;
		}
		if(c4 >= 0 && (c4 < smallestteam_count || (c4 <= smallestteam_count && team4_score < smallestteam_score)))
		{
			smallestteam = 4;
			smallestteam_count = c4;
			smallestteam_score = team4_score;
		}
	}
	else
	{
		if(c1 >= 0 && (c1 < smallestteam_count ||
					(c1 == smallestteam_count && self.team == COLOR_TEAM1) ) )
		{
			smallestteam = 1;
			smallestteam_count = c1;
		}
		if(c2 >= 0 && c2 < (c2 < smallestteam_count ||
					(c2 == smallestteam_count && self.team == COLOR_TEAM2) ) )
		{
			smallestteam = 2;
			smallestteam_count = c2;
		}
		if(c3 >= 0 && c3 < (c3 < smallestteam_count ||
					(c3 == smallestteam_count && self.team == COLOR_TEAM3) ) )
		{
			smallestteam = 3;
			smallestteam_count = c3;
		}
		if(c4 >= 0 && c4 < (c4 < smallestteam_count ||
					(c4 == smallestteam_count && self.team == COLOR_TEAM4) ) )
		{
			smallestteam = 4;
			smallestteam_count = c4;
		}
	}

	return smallestteam;
}

float JoinBestTeam(entity pl, float only_return_best)
{
	float smallest, selectedteam;

	// don't join a team if we're not playing a team game
	if(!cvar("teamplay") && !g_domination && !g_ctf && !g_keyhunt)
		return 0;

	// find out what teams are available
	CheckAllowedTeams();

	if(cvar("g_domination"))
	{
		if(cvar("g_domination_default_teams") < 3)
			c3 = 999999999;
		if(cvar("g_domination_default_teams") < 4)
			c4 = 999999999;
	}

	// if we don't care what team he ends up on, put him on whatever team he entered as.
	// if he's not on a valid team, then let other code put him on the smallest team
	if(!cvar("g_campaign") && !cvar("g_balance_teams") && !cvar("g_balance_teams_force"))
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
				LogTeamchange(pl);
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
		LogTeamchange(pl);
		if(pl.deadflag == DEAD_NO)
			Damage(pl, pl, pl, 100000, DEATH_TEAMCHANGE, pl.origin, '0 0 0');
	}

	return smallest;
}


void SV_ChangeTeam(float _color)
{
	float scolor, dcolor, steam, dteam, dbotcount, scount, dcount;

	// in normal deathmatch we can just apply the color and we're done
	if(!cvar("teamplay")) {
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
	else if(scolor == COLOR_TEAM4 - 1)
		steam = 4;
	if(dcolor == COLOR_TEAM1 - 1)
		dteam = 1;
	else if(dcolor == COLOR_TEAM2 - 1)
		dteam = 2;
	else if(dcolor == COLOR_TEAM3 - 1)
		dteam = 3;
	else if(dcolor == COLOR_TEAM4 - 1)
		dteam = 4;

	// remap invalid teams in dom & ctf
	/*
	if(cvar("g_ctf") && dteam == 3)
		dteam = 2;
	else if(cvar("g_ctf") && dteam == 4)
		dteam = 1;
	else if((cvar("g_domination") && cvar("g_domination_default_teams") < 3) || (cvar("g_tdm") && cvar("g_tdm_teams") < 3))
	{
		if(dteam == 3)
			dteam = 2;
		else if(dteam == 4)
			dteam = 1;
	}
	else if((cvar("g_domination") && cvar("g_domination_default_teams") < 4) || (cvar("g_tdm") && cvar("g_tdm_teams") < 4))
	{
		if(dteam == 4)
			dteam = 1;
	}
	*/

	CheckAllowedTeams();
	if(dteam == 3 && c3 < 0)
		dteam = 2;
	if(dteam == 4 && c4 < 0)
		dteam = 1;

	// not changing teams
	if(scolor == dcolor)
	{
		//bprint("same team change\n");
		SetPlayerTeam(self, dteam, steam, TRUE);
		return;
	}

	if(cvar("teamplay"))
	{
		if(cvar("g_campaign") || cvar("g_changeteam_banned"))
		{
			sprint(self, "Team changes not allowed\n");
			return; // changing teams is not allowed
		}

		if(!cvar("g_campaign") && cvar("g_balance_teams_prevent_imbalance"))
		{
			// only allow changing to a smaller or equal size team

			// find out what teams are available
			CheckAllowedTeams();
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
	}

//	bprint("allow change teams from ", ftos(steam), " to ", ftos(dteam), "\n");

	if(cvar("teamplay") && self.classname == "player" && steam != dteam)
	{
		// reduce frags during a team change
		TeamchangeFrags(self);
	}

	SetPlayerTeam(self, dteam, steam, FALSE);

	if(cvar("teamplay") && self.classname == "player" && steam != dteam)
	{
		// kill player when changing teams
		if(self.deadflag == DEAD_NO)
			Damage(self, self, self, 100000, DEATH_TEAMCHANGE, self.origin, '0 0 0');
	}
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
				if(head.frags < lowest_bot_score)
				{
					lowest_bot = head;
					lowest_bot_score = head.frags;
				}
			}
			else
			{
				if(head.frags < lowest_player_score)
				{
					lowest_player = head;
					lowest_player_score = head.frags;
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

float lastRebalanceInfo;
void CauseRebalance(float source_team, float howmany_toomany)
{
	float steam;
	entity head;

	if(IsTeamBalanceForced() == 1)
	{
		bprint("Rebalancing Teams\n");
		ShufflePlayerOutOfTeam(source_team);
	}
	else
	{
		if(howmany_toomany < cvar("g_balance_teams_complain"))
			return;
		if(time < lastRebalanceInfo + 90)
			return;
		lastRebalanceInfo = time;
		if(source_team == 1)
			steam = COLOR_TEAM1;
		else if(source_team == 2)
			steam = COLOR_TEAM2;
		else if(source_team == 3)
			steam = COLOR_TEAM3;
		else if(source_team == 4)
			steam = COLOR_TEAM4;
		ServerConsoleEcho(strcat("Team ", ftos(source_team), " too large, complaining."), TRUE);
		FOR_EACH_REALPLAYER(head)
		{
			if(head.team == steam)
			{
				sprint(head, "\{1}\{13}^3SERVER NOTICE:^7 One of you please change teams!\n");
				centerprint_atprio(head, CENTERPRIO_REBALANCE, "^3SERVER NOTICE:\n\n^7Someone of you please change teams!");
			}
		}
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

	CheckAllowedTeams();
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



/*void(entity e, float first) UpdateTeamScore =
{
	clientno = e.FIXME;
	if(first)
	{
		WriteByte (MSG_ALL, SVC_UPDATENAME);
		WriteByte (MSG_ALL, clientno);
		WriteString (MSG_ALL, e.netname);

		WriteByte (MSG_ALL, SVC_UPDATECOLORS);
		WriteByte (MSG_ALL, clientno);
		WriteByte (MSG_ALL, e.b_shirt * 16 + who.b_pants);
	}

	WriteByte (MSG_ALL, SVC_UPDATEFRAGS);
	WriteByte (MSG_ALL, clientno);
	WriteShort (MSG_ALL, e.frags + 10000);
};

*/


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
void() tdm_spawnteams =
{
	float numteams;

	numteams = cvar("g_tdm_teams");

	tdm_spawnteam("Red", COLOR_TEAM1-1);
	tdm_spawnteam("Blue", COLOR_TEAM2-1);
};

void() tdm_delayedinit =
{
	self.think = SUB_Remove;
	self.nextthink = time;
	// if no teams are found, spawn defaults
	if (find(world, classname, "tdm_team") == world)
		tdm_spawnteams();
};

void() tdm_init =
{
	local entity e;
	e = spawn();
	e.think = tdm_delayedinit;
	e.nextthink = time + 0.1;
};


