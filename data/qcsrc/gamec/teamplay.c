float COLOR_TEAM1	= 5;  // red
float COLOR_TEAM2	= 14; // blue
float COLOR_TEAM3	= 10; // pink
float COLOR_TEAM4	= 13; // yellow


float GAME_DEATHMATCH		= 1;
float GAME_TEAM_DEATHMATCH	= 2;
float GAME_DOMINATION		= 3;
float GAME_CTF			= 4;
float GAME_RUNEMATCH		= 5;
float GAME_LMS			= 6;


// client counts for each team
float c1, c2, c3, c4;
// # of bots on those teams
float cb1, cb2, cb3, cb4;


float g_domination, g_ctf, g_tdm;

float audit_teams_time;


string TeamName(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == COLOR_TEAM1)
		return "Red Team";
	if(t == COLOR_TEAM2)
		return "Blue Team";
	if(t == COLOR_TEAM3)
		return "Pink Team";
	if(t == COLOR_TEAM4)
		return "Yellow Team";
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
		return "^6Pink Team^7";
	if(t == COLOR_TEAM4)
		return "^3Yellow Team^7";
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
		return "Pink Team";
	if(t == 4)
		return "Yellow Team";
	return "Neutral Team";
}

void dom_init();
void ctf_init();
void runematch_init();
void tdm_init();


void ResetGameCvars()
{
	cvar_set("g_tdm", "0");
	cvar_set("g_domination", "0");
	cvar_set("g_ctf", "0");
	cvar_set("g_runematch", "0");
	cvar_set("g_lms", "0");
	cvar_set("teamplay", "0");


	cvar_set("exit_cfg", "");
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

string gamemode_name;
float teams_matter;

void InitGameplayMode()
{
	float fraglimit_override, timelimit_override;

	game = cvar ("gamecfg");	// load game options

	// game cvars get reset before map changes
	// then map's cfg sets them as desired

	// FIXME: also set a message or game mode name to print to players when the join

	// set both here, gamemode can override it later
	timelimit_override = cvar("timelimit_override");
	fraglimit_override = cvar("fraglimit_override");

	if(game == GAME_DOMINATION || cvar("g_domination"))
	{
		game = GAME_DOMINATION;
		cvar_set("g_domination", "1");

		ActivateTeamplay();

		fraglimit_override = cvar("g_domination_point_limit");

		gamemode_name = "Domination";
		teams_matter = 1;
	}
	else if(game == GAME_CTF || cvar("g_ctf"))
	{
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
			game = GAME_TEAM_DEATHMATCH;
			gamemode_name = "Team Deathmatch";
			ActivateTeamplay();
			teams_matter = 1;
		}
		else
		{
			game = GAME_DEATHMATCH;
			gamemode_name = "Deathmatch";
			teams_matter = 0;
		}

		fraglimit_override = cvar("fraglimit_override");
	}
	else if(game == GAME_LMS || cvar("g_lms"))
	{
		game = GAME_LMS;
		cvar_set("g_lms", "1");
		fraglimit_override = cvar("fraglimit_override");
		gamemode_name = "Last Man Standing";
		teams_matter = 0;
		cvar_set("teamplay", "0");
		lms_lowest_lives = 999;
	}
	else
	{
		// we can only assume...
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
	if(fraglimit_override >= 0)
		cvar_set("fraglimit", ftos(fraglimit_override));
	if(timelimit_override >= 0)
		cvar_set("timelimit", ftos(timelimit_override));

	if (game == GAME_DOMINATION)//cvar("g_domination"))
		dom_init();
	else if (game == GAME_CTF)//cvar("g_ctf"))
		ctf_init();
	else if (game == GAME_RUNEMATCH)//cvar("g_runematch"))
		runematch_init();
	else if (game == GAME_TEAM_DEATHMATCH)//cvar("g_runematch"))
		tdm_init();

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
}

void PrintWelcomeMessage(entity pl)
{
	string s, grap_msg, temp, mutator;

	/*if(self.welcomemessage_time < time)
		return;
	if(self.welcomemessage_time2 > time)
		return;
	self.welcomemessage_time2 = time + 0.8; */

	if(self.welcomemessage_time2 > time) return;
	self.welcomemessage_time2 = time + 1.0;

	if(cvar("g_minstagib"))
		mutator = "^2Minstagib ^1";
	else if(cvar("g_instagib"))
		mutator = "^2Instagib ^1";
	else if(cvar("g_rocketarena"))
		mutator = "^2Rocketarena ^1";
	else
		mutator = "";

	if(cvar("g_grappling_hook"))
		grap_msg = strzone("\n\nBind a key to ^1+hook^8 to use the grappling hook\n");

	s = strcat(s, "\n\nThis is Nexuiz ", cvar_string("g_nexuizversion"), "\n", self.versionmessage);
	s = strcat(s, "^8\n\nMatch type is ^1", mutator, gamemode_name, "^8\n");

	if(self.classname == "observer" || self.classname == "spectator") {
		s = strcat(s,"^7\n\n\npress jump to play\npress attack to spectate other players\n\n");
	}


	s = strzone(s);

	temp = strcat(
		"\n\n\n^8Welcome, ", pl.netname, "^8\n",
		s
		);
	temp = strzone(temp);


	if (cvar_string("g_mutatormsg") != "") {
		s = strcat(s, "\n\nSpecial gameplay tips: ", cvar_string("g_mutatormsg"));
	}

	if (cvar_string("sv_motd") != "") {
		s = strcat(s, "\n\nMOTD: ", cvar_string("sv_motd"));
	}

	centerprint(pl, s);
	//sprint(pl, s);

	strunzone(temp);
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
		//bprint(strcat(pl.netname, " has changed to ", TeamNoName(t), "\n"));
		bprint(strcat(pl.netname, "^7 has changed from ", TeamNoName(s), " to ", TeamNoName(t), "\n"));
	}
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

// c1...c4 should be set to -1 (not allowed) or 0 (allowed).
// teams that are allowed will now have their player counts stored in c1...c4
void GetTeamCounts(entity ignore)
{
	entity head;
	// now count how many players are on each team already

	// FIXME: also find and memorize the lowest-scoring bot on each team (in case players must be shuffled around)
	// also remember the lowest-scoring player

	head = find(world, classname, "player");
	while(head)
	{
		if(head != ignore)// && head.netname != "")
		{
			if(head.team == COLOR_TEAM1)
			{
				if(c1 >= 0)
				{
					c1 = c1 + 1;
					cb1 = cb1 + 1;
				}
			}
			if(head.team == COLOR_TEAM2)
			{
				if(c2 >= 0)
				{
					c2 = c2 + 1;
					cb2 = cb2 + 1;
				}
			}
			if(head.team == COLOR_TEAM3)
			{
				if(c3 >= 0)
				{
					c3 = c3 + 1;
					cb3 = cb3 + 1;
				}
			}
			if(head.team == COLOR_TEAM4)
			{
				if(c4 >= 0)
				{
					c4 = c4 + 1;
					cb4 = cb4 + 1;
				}
			}
		}
		head = find(head, classname, "player");
	}
}

// returns # of smallest team (1, 2, 3, 4)
// NOTE: Assumes CheckAllowedTeams has already been called!
float FindSmallestTeam(entity pl, float ignore_pl)
{
	float totalteams, smallestteam, smallestteam_count, balance_type;
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
		else
			error("Too few teams available for team deathmatch\n");
	}


	// count how many players are in each team
	if(ignore_pl)
		GetTeamCounts(world);
	else
		GetTeamCounts(pl);



	// c1...c4 now have counts of each team
	// figure out which is smallest, giving priority to the team the player is already on as a tie-breaker

	smallestteam = 0;
	smallestteam_count = 999;

	// 2 gives priority to what team you're already on, 1 goes in order
	// 2 doesn't seem to work though...
	balance_type = 1;

	if(balance_type == 1)
	{
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

	g_domination = cvar("g_domination");
	g_ctf = cvar("g_ctf");

	// don't join a team if we're not playing a team game
	if(!cvar("teamplay") && !g_domination && !g_ctf)
		return 0;

	// find out what teams are available
	CheckAllowedTeams();

	// if we don't care what team he ends up on, put him on whatever team he entered as.
	// if he's not on a valid team, then let other code put him on the smallest team
	if(!cvar("balance_teams") && !cvar("force_balance"))
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
				SetPlayerColors(pl, selectedteam - 1);
			return selectedteam;
		}
		// otherwise end up on the smallest team (handled below)
	}

	smallest = FindSmallestTeam(pl, TRUE);


	if(!only_return_best)
	{
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
	}

	return smallest;
}


void SV_ChangeTeam(float _color)
{
	float scolor, dcolor, steam, dteam, dbotcount, scount, dcount;

	scolor = self.clientcolors & 0x0F;
	dcolor = _color & 0x0F;

	// store shirt color in .clientcolors
	// this will get overwritten in teamplay modes later
	if(!cvar("teamplay")) {
		SetPlayerColors(self, _color);
		return;
	}

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
	if(cvar("g_ctf") && dteam == 3)
		dteam = 2;
	else if(cvar("g_ctf") && dteam == 4)
		dteam = 1;
	else if(cvar("g_domination") && cvar("g_domination_default_teams") < 3)
	{
		if(dteam == 3)
			dteam = 2;
		else if(dteam == 4)
			dteam = 1;
	}
	else if(cvar("g_domination") && cvar("g_domination_default_teams") < 4)
	{
		if(dteam == 4)
			dteam = 1;
	}
	
	// not changing teams
	if(scolor == dcolor)
	{
		//bprint("same team change\n");
		SetPlayerTeam(self, dteam, steam, TRUE);
		return;
	}

	if(cvar("teamplay"))
	{
		if(self.classname == "player" && steam != dteam)
		{
			// kill player when changing teams
			if(self.deadflag == DEAD_NO)
				self.event_damage(self, self, 10000, DEATH_KILL, self.origin, '0 0 0');
		
			// reduce frags during a team change
			self.frags = floor(self.frags * (cvar("g_changeteam_fragtransfer") / 100));
		}
		
		if(cvar("g_changeteam_banned"))
		{
			sprint(self, "Team changes not allowed\n");
			return; // changing teams is not allowed
		}

		if(cvar("g_balance_teams_prevent_imbalance"))
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

//	bprint(strcat("allow change teams from ", ftos(steam), " to ", ftos(dteam), "\n"));

	SetPlayerTeam(self, dteam, steam, FALSE);
}


void ShufflePlayerOutOfTeam (float source_team)
{
	float smallestteam, smallestteam_count, steam;
	float lowest_bot_score, lowest_player_score;
	entity head, lowest_bot, lowest_player, selected;

	smallestteam = 0;
	smallestteam_count = 999;

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
	lowest_bot_score = 9999;
	lowest_player = world;
	lowest_player_score = 9999;

	// find the lowest-scoring player & bot of that team
	head = find(world, classname, "player");
	while(head)
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
		head = find(head, classname, "player");
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
	SetPlayerTeam(selected, smallestteam, source_team, FALSE);
}

// part of g_balance_teams_force
// occasionally perform an audit of the teams to make
// sure they're more or less balanced in player count.
void AuditTeams()
{
	float numplayers, numteams, average;
	if(!cvar("g_balance_teams_force"))
		return;
	if(!cvar("teamplay"))
		return;

	if(audit_teams_time > time)
		return;

	audit_teams_time = time + 4 + random();

//	bprint("Auditing teams\n");

	CheckAllowedTeams();
	GetTeamCounts(world);


	numteams = numplayers = 0;
	if(c1 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c1;
	}
	if(c2 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c2;
	}
	if(c3 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c3;
	}
	if(c4 >= 0)
	{
		numteams = numteams + 1;
		numplayers = numplayers + c4;
	}

	if(numplayers <= 0)
		return; // no players to move around
	if(numteams < 2)
		return; // don't bother shuffling if for some reason there aren't any teams

	average = ceil(numplayers / numteams);

	if(average <= 0)
		return; // that's weird...

	if(c1 && c1 > average)
	{
		bprint("Rebalancing Teams\n");
		//bprint("Shuffle from team 1\n");
		ShufflePlayerOutOfTeam(1);
	}
	if(c2 && c2 > average)
	{
		bprint("Rebalancing Teams\n");
		//bprint("Shuffle from team 2\n");
		ShufflePlayerOutOfTeam(2);
	}
	if(c3 && c3 > average)
	{
		bprint("Rebalancing Teams\n");
		//bprint("Shuffle from team 3\n");
		ShufflePlayerOutOfTeam(3);
	}
	if(c4 && c4 > average)
	{
		bprint("Rebalancing Teams\n");
		//bprint("Shuffle from team 4\n");
		ShufflePlayerOutOfTeam(4);
	}

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





void() tdm_team =
{
	self.classname = "tdm_team";
	self.team = self.cnt + 1;
};

// code from here on is just to support maps that don't have team entities
void tdm_spawnteam (string teamname, float teamcolor)
{
	local entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "tdm_team";
	self.netname = teamname;
	self.cnt = teamcolor;

	tdm_team();

	self = oldself;
};

// spawn some default teams if the map is not set up for tdm
void() tdm_spawnteams =
{
	float numteams;

	numteams = cvar("g_tdm_teams");

	tdm_spawnteam("Red", 4);
	tdm_spawnteam("Blue", 13);
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


