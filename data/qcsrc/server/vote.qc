float VoteCheckNasty(string cmd)
{
	if(strstrofs(cmd, ";", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "\n", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "\r", 0) >= 0)
		return TRUE;
	if(strstrofs(cmd, "$", 0) >= 0)
		return TRUE;
	return FALSE;
}

entity GetKickVoteVictim(string vote, string cmd, entity caller)
{
	float tokens;
	float i, n, t;
	string ns;
	entity e;

	tokens = tokenize(vote);
	ns = "";

	if(tokens >= 2)
		if(substring(argv(1), 0, 1) == "#")
		{
			ns = substring(argv(1), 1, 999);
			t = 2;
		}

	if(tokens >= 3)
		if(argv(1) == "#")
		{
			ns = argv(2);
			t = 3;
		}

	if(ns != "")
	{
		GetKickVoteVictim_reason = "";
		for(i = t; i < tokens; ++i)
			GetKickVoteVictim_reason = strcat(GetKickVoteVictim_reason, argv(i), " ");
		GetKickVoteVictim_reason = substring(GetKickVoteVictim_reason, 0, strlen(GetKickVoteVictim_reason) - 1);

		n = stof(ns);
		if(ns == ftos(n)) if(n >= 1) if(n <= maxclients)
		{
			e = edict_num(n);
			if(clienttype(e) == CLIENTTYPE_REAL)
			{
				GetKickVoteVictim_newcommand = strcat(argv(0), " # ", ns);
				return e;
			}
		}
	}

	print_to(caller, strcat("Usage: ", cmd, " ", argv(0), " #playernumber (as in \"status\")\n"));
	return world;
}

float GameCommand_Vote(string s, entity e) {
	local entity victim;
	if(argv(0) == "help") {
		print_to(e, "  vote COMMANDS ARGUMENTS. See 'vote help' for more info.");
		return TRUE;
	} else if(argv(0) == "vote") {
		if(argv(1) == "") {
			print_to(e, "^1You have to supply a vote command. See help for more info.");
		} else if(argv(1) == "help") {
			VoteHelp(e);
		} else if(argv(1) == "status") {
			if(votecalled) {
				print_to(e, strcat("^7Vote for ", votecalledvote_display, "^7 called by ^7", VoteNetname(votecaller), "^7."));
			} else {
				print_to(e, "^1No vote called.");
			}
		} else if(argv(1) == "call") {
			if(!e || cvar("sv_vote_call")) {
				if(tourneyInMatchStage
				   && cvar("g_tourney_disable_spec_vote")
				   && e.classname != "player") {
					print_to(e, "^1Error: Only players can call a vote during the match-stage.");
				}
				else if(timeoutStatus) { //don't allow a vote call during a timeout
					print_to(e, "^1Error: You can not call a vote while a timeout is active.");
				}
				else if(votecalled) {
					print_to(e, "^1There is already a vote called.");
				} else {
					local string vote;
					vote = VoteParse();
					if(vote == "") {
						print_to(e, "^1Your vote is empty. See help for more info.");
					} else if(e
						&& time < e.vote_next) {
							print_to(e, strcat("^1You have to wait ^2", ftos(e.vote_next - time), "^1 seconds before you can again call a vote."));
					} else if(VoteCheckNasty(vote)) {
						print_to(e, "Syntax error in command. See help for more info.");
					} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
						// remap chmap to gotomap (forces intermission)
						if(vote == "chmap" || vote == "gotomap") // won't work without arguments
							return TRUE;
						if(substring(vote, 0, 6) == "chmap ")
							vote = strcat("gotomap ", substring(vote, 6, strlen(vote) - 6));
						if(substring(vote, 0, 8) == "gotomap ")
						{
							if(!(vote = ValidateMap(substring(vote, 8, strlen(vote) - 8), e)))
								return TRUE;
							vote = strcat("gotomap ", vote);
						}

						// make kick and kickban votes a bit nicer (and reject them if formatted badly)
						if(substring(vote, 0, 4) == "kick" || substring(vote, 0, 7) == "kickban")
						{
							if(!(victim = GetKickVoteVictim(vote, "vcall", e)))
								return TRUE;
							vote = GetKickVoteVictim_newcommand;
							votecalledvote_display = strzone(strcat("^1", vote, " (^7", victim.netname, "^1): ", GetKickVoteVictim_reason));
						}
						else
						{
							votecalledvote_display = strzone(strcat("^1", vote));
						}
						votecalledvote = strzone(vote);
						votecalled = TRUE;
						votecalledmaster = FALSE;
						votefinished = time + cvar("sv_vote_timeout");
						votecaller = e; // remember who called the vote
						if(e) {
							e.vote_vote = 1; // of course you vote yes
							e.vote_next = time + cvar("sv_vote_wait");
						}
						bprint("\{1}^2* ^3", VoteNetname(votecaller), "^2 calls a vote for ", votecalledvote_display, "\n");
						if(cvar("sv_eventlog"))
							GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display), TRUE);
						VoteCount(); // needed if you are the only one
					} else {
						print_to(e, "^1This vote is not ok. See help for more info.");
					}
				}
			} else {
				print_to(e, "^1Vote calling is NOT allowed.");
			}
		} else if(argv(1) == "stop") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if(e == votecaller) { // the votecaller can stop a vote
				VoteStop(e);
			} else if(!e) { // server admin / console can too
				VoteStop(e);
			} else if(e.vote_master) { // masters can too
				VoteStop(e);
			} else {
				print_to(e, "^1You are not allowed to stop that Vote.");
			}
		} else if(argv(1) == "master") {
			if(cvar("sv_vote_master")) {
				if(votecalled) {
					print_to(e, "^1There is already a vote called.");
				} else {
					votecalled = TRUE;
					votecalledmaster = TRUE;
					votecalledvote = strzone("XXX");
					votecalledvote_display = strzone("^3master");
					votefinished = time + cvar("sv_vote_timeout");
					votecaller = e; // remember who called the vote
					if(e) {
						e.vote_vote = 1; // of course you vote yes
						e.vote_next = time + cvar("sv_vote_wait");
					}
					bprint("\{1}^2* ^3", VoteNetname(votecaller), "^2 calls a vote to become ^3master^2.\n");
					if(cvar("sv_eventlog"))
						GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display), FALSE);
					VoteCount(); // needed if you are the only one
				}
			} else {
				print_to(e, "^1Vote to become master is NOT allowed.");
			}
		} else if(argv(1) == "do") {
			if(!e || e.vote_master) {
				local string dovote, dovote_display;
				dovote = VoteParse();
				if(dovote == "") {
					print_to(e, "^1Your command was empty. See help for more info.");
				} else if(VoteCheckNasty(dovote)) {
					print_to(e, "Syntax error in command. See help for more info.");
				} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
					if(dovote == "chmap" || dovote == "gotomap") // won't work without arguments
						return TRUE;
					if(substring(dovote, 0, 6) == "chmap ")
						dovote = strcat("gotomap ", substring(dovote, 6, strlen(dovote) - 6));
					if(substring(dovote, 0, 8) == "gotomap ")
					{
						if(!(dovote = ValidateMap(substring(dovote, 8, strlen(dovote) - 8), e)))
							return TRUE;
						dovote = strcat("gotomap ", dovote);
					}

					dovote_display = dovote;
					if(substring(dovote, 0, 4) == "kick" || substring(dovote, 0, 7) == "kickban")
					{
						if(!(victim = GetKickVoteVictim(dovote, "vdo", e)))
							return TRUE;
						dovote = GetKickVoteVictim_newcommand;
						dovote_display = strcat("^1", dovote, " (^7", victim.netname, "^1): ", GetKickVoteVictim_reason);
					}
					bprint("\{1}^2* ^3", VoteNetname(e), "^2 used his ^3master^2 status to do \"^2", dovote_display, "^2\".\n");
					if(cvar("sv_eventlog"))
						GameLogEcho(strcat(":vote:vdo:", ftos(e.playerid), ":", dovote_display), FALSE);
					localcmd(strcat(dovote, "\n"));
				} else {
					print_to(e, "^1This command is not ok. See help for more info.");
				}
			} else {
				print_to(e, "^1You are NOT a master.  You might need to login or vote to become master first. See help for more info.");
			}
		} else if(argv(1) == "login") {
			local string masterpwd;
			masterpwd = cvar_string("sv_vote_master_password");
			if(masterpwd != "") {
				local float granted;
				granted = (masterpwd == argv(2));
				if (e)
					e.vote_master = granted;
				if(granted) {
					ServerConsoleEcho(strcat("Accepted master login from ", VoteNetname(e)), TRUE);
					bprint("\{1}^2* ^3", VoteNetname(e), "^2 logged in as ^3master^2\n");
					if(cvar("sv_eventlog"))
						GameLogEcho(strcat(":vote:vlogin:", ftos(e.playerid)), FALSE);
				}
				else
					ServerConsoleEcho(strcat("REJECTED master login from ", VoteNetname(e)), TRUE);
			}
			else
				print_to(e, "^1Login to become master is NOT allowed.");
		} else if(argv(1) == "yes") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
			} else if(e.vote_vote == 0
				  || cvar("sv_vote_change")) {
				print_to(e, "^1You accepted the vote.");
				e.vote_vote = 1;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else if(argv(1) == "no") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
			} else if(e.vote_vote == 0
				  || cvar("sv_vote_change")) {
				print_to(e, "^1You rejected the vote.");
				e.vote_vote = -1;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else if(argv(1) == "abstain" || argv(1) == "dontcare") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if (!e) {
				print_to(e, "^1You can't vote from the server console.");
			} else if(e.vote_vote == 0
				  || cvar("sv_vote_change")) {
				print_to(e, "^1You abstained from your vote.");
				e.vote_vote = -2;
				centerprint_expire(e, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				print_to(e, "^1You have already voted.");
			}
		} else {
			// ignore this?
			print_to(e, "^1Unknown vote command.");
		}
		return TRUE;
	}
	return FALSE;
}

void VoteHelp(entity e) {
	local string vmasterdis;
	if(!cvar("sv_vote_master")) {
		vmasterdis = " ^1(disabled)";
	}

	local string vlogindis;
	if("" == cvar_string("sv_vote_master_password")) {
		vlogindis = " ^1(disabled)";
	}

	local string vcalldis;
	if(!cvar("sv_vote_call")) {
		vcalldis = " ^1(disabled)";
	}

	print_to(e, "^7You can use voting with \"^2cmd vote help^7\" \"^2cmd vote status^7\" \"^2cmd vote call ^3COMMAND ARGUMENTS^7\" \"^2cmd vote stop^7\" \"^2cmd vote master^7\" \"^2cmd vote login^7\" \"^2cmd vote do ^3COMMAND ARGUMENTS^7\" \"^2cmd vote yes^7\" \"^2cmd vote no^7\" \"^2cmd vote abstain^7\" \"^2cmd vote dontcare^7\".");
	print_to(e, "^7Or if your version is up to date you can use these aliases \"^2vhelp^7\" \"^2vstatus^7\" \"^2vcall ^3COMMAND ARGUMENTS^7\" \"^2vstop^7\" \"^2vmaster^7\" \"^2vlogin^7\" \"^2vdo ^3COMMAND ARGUMENTS^7\" \"^2vyes^7\" \"^2vno^7\" \"^2abstain^7\" \"^2vdontcare^7\".");
	print_to(e, "^7\"^2help^7\" shows this info.");
	print_to(e, "^7\"^2status^7\" shows if there is a vote called and who called it.");
	print_to(e, strcat("^7\"^2call^7\" is used to call a vote. See the list of allowed commands.", vcalldis, "^7"));
	print_to(e, "^7\"^2stop^7\" can be used by the vote caller or an admin to stop a vote and maybe correct it.");
	print_to(e, strcat("^7\"^2master^7\" call a vote to become master who can execute commands without a vote", vmasterdis, "^7"));
	print_to(e, strcat("^7\"^2login^7\" login to become master who can execute commands without a vote.", vlogindis, "^7"));
	print_to(e, "^7\"^2do^7\" executes a command if you are a master. See the list of allowed commands.");
	print_to(e, "^7\"^2yes^7\", \"^2no^7\", \"^2abstain^7\" and \"^2dontcare^7\" to make your vote.");
	print_to(e, "^7If enough of the players vote yes the vote is accepted.");
	print_to(e, "^7If enough of the players vote no the vote is rejected.");
	print_to(e, strcat("^7If neither the vote will timeout after ", cvar_string("sv_vote_timeout"), "^7 seconds."));
	print_to(e, "^7You can call a vote for or execute these commands:");
	print_to(e, strcat("^3", cvar_string("sv_vote_commands"), "^7 and maybe further ^3arguments^7"));
}

string VoteNetname(entity e)
{
	if(e) {
		return e.netname;
	} else {
		if(cvar_string("sv_adminnick") != "") {
			return cvar_string("sv_adminnick");
		} else {
			return cvar_string("hostname");
		}
	}
}

string ValidateMap(string m, entity e)
{
#ifdef MAPINFO
	m = MapInfo_FixName(m);
	if(!m)
	{
		print_to(e, "This map is not available on this server.");
		return string_null;
	}
#else
	if(!cvar("sv_vote_change_gametype"))
		if(!IsSameGametype(m))
		{
			print_to(e, "This server does not allow changing the game type by map votes.");
			return string_null;
		}
#endif
	if(!cvar("sv_vote_override_mostrecent"))
		if(Map_IsRecent(m))
		{
			print_to(e, "This server does not allow for recent maps to be played again. Please be patient for some rounds.");
			return string_null;
		}
#ifdef MAPINFO
	if(!MapInfo_CheckMap(m))
	{
		print_to(e, strcat("^1Invalid mapname, \"^3", m, "^1\" does not support the current game mode."));
		return string_null;
	}
#else
	if(!TryFile(strcat("maps/", m, ".mapcfg")))
	{
		print_to(e, strcat("^1Invalid mapname, \"^3", m, "^1\" does not exist on this server."));
		return string_null;
	}
#endif

	return m;
}


void VoteThink() {
	if(votefinished > 0) // a vote was called
	if(time > votefinished) // time is up
	{
		VoteCount();
	}
}

string VoteParse() {
	local float index;
	index = 3;
	local string vote;
	vote = argv(2);
	while(argv(index) != "") {
		vote = strcat(vote, " ", argv(index));
		index++;
	}

	// necessary for some of the string operations
	vote = strzone(vote);

	return vote;
}

float VoteAllowed(string votecommand) {
	tokenize(cvar_string("sv_vote_commands"));
	local float index;
	index = 0;
	while(argv(index) != "") {
		if(votecommand == argv(index)) {
			return TRUE;
		}
		index++;
	}
	return FALSE;
}

void VoteReset() {
	local entity player;

	FOR_EACH_CLIENT(player)
	{
		player.vote_vote = 0;
		centerprint_expire(player, CENTERPRIO_VOTE);
	}

	if(votecalled)
	{
		strunzone(votecalledvote);
		strunzone(votecalledvote_display);
	}

	votecalled = FALSE;
	votecalledmaster = FALSE;
	votefinished = 0;
}

void VoteAccept() {
	bprint("\{1}^2* ^3", VoteNetname(votecaller), "^2's vote for ^1", votecalledvote_display, "^2 was accepted\n");
	if(votecalledmaster)
	{
		if(votecaller) {
			votecaller.vote_master = 1;
		}
	} else {
		//in g_tourney mode and if the vote is a timelimit-change, don't change it immediately but after restart
		if(cvar("g_tourney")
		   && substring(votecalledvote, 0, 10) == "timelimit ") {
			if( stof(substring(votecalledvote, 10, strlen(votecalledvote) - 10)) > 0 ) {
				timelimit_orig = stof(substring(votecalledvote, 10, strlen(votecalledvote) - 10));
				bprint(strcat("The timelimit will be set to ", ftos(timelimit_orig), " minutes after the next restart!\n"));
			}
			else //calls like "timelimit -1" can pass immediately
				localcmd(strcat(votecalledvote, "\n"));
		}
		else
			localcmd(strcat(votecalledvote, "\n"));
	}
	if(votecaller) {
		votecaller.vote_next = 0; // people like your votes,
					  // no wait for next vote
	}
	VoteReset();
}

void VoteReject() {
	bprint("\{1}^2* ^3", VoteNetname(votecaller), "^2's vote for ", votecalledvote_display, "^2 was rejected\n");
	VoteReset();
}

void VoteTimeout() {
	bprint("\{1}^2* ^3", VoteNetname(votecaller), "^2's vote for ", votecalledvote_display, "^2 timed out\n");
	VoteReset();
}

void VoteStop(entity stopper) {
	bprint("\{1}^2* ^3", VoteNetname(stopper), "^2 stopped ^3", VoteNetname(votecaller), "^2's vote\n");
	if(cvar("sv_eventlog"))
		GameLogEcho(strcat(":vote:vstop:", ftos(stopper.playerid)), FALSE);
	if(stopper == votecaller) {
		// no wait for next vote so you can correct your vote
		if(votecaller) {
			votecaller.vote_next = 0;
		}
	}
	VoteReset();
}

void VoteNag() {
	if(votecalled)
	if(self.vote_vote == 0)
		centerprint_atprio(self, CENTERPRIO_VOTE, strcat("^7^3", VoteNetname(votecaller), "^2 called a vote for ", votecalledvote_display, "\n\n^2You have not voted yet!\n^2HINT: By default, F1 is yes and F2 is no."));
}

void VoteSpam(float yescount, float nocount, float abstaincount, float notvoters, float mincount, string result)
{
	string s;
	if(mincount >= 0)
	{
		s = strcat("\{1}^2* vote results: ^1", ftos(yescount), "^2:^1");
		s = strcat(s, ftos(nocount), "^2 (^1");
		s = strcat(s, ftos(mincount), "^2 needed), ^1");
		s = strcat(s, ftos(abstaincount), "^2 didn't care, ^1");
		s = strcat(s, ftos(notvoters), "^2 didn't vote\n");
	}
	else
	{
		s = strcat("\{1}^2* vote results: ^1", ftos(yescount), "^2:^1");
		s = strcat(s, ftos(nocount), "^2, ^1");
		s = strcat(s, ftos(abstaincount), "^2 didn't care, ^1");
		s = strcat(s, ftos(notvoters), "^2 didn't have to vote\n");
	}
	bprint(s);
	if(cvar("sv_eventlog"))
	{
		s = strcat(":vote:v", result, ":", ftos(yescount));
		s = strcat(s, ":", ftos(nocount));
		s = strcat(s, ":", ftos(abstaincount));
		s = strcat(s, ":", ftos(notvoters));
		s = strcat(s, ":", ftos(mincount));
		GameLogEcho(s, FALSE);
	}
}

void VoteCount() {
	local float playercount;
	playercount = 0;
	local float yescount;
	yescount = 0;
	local float nocount;
	nocount = 0;
	local float abstaincount;
	abstaincount = 0;
	local entity player;
	//same for real players
	local float realplayercount;
	local float realplayeryescount;
	local float realplayernocount;
	local float realplayerabstaincount;
	realplayercount = realplayernocount = realplayerabstaincount = realplayeryescount = 0;

	FOR_EACH_REALCLIENT(player)
	{
		if(player.vote_vote == -1) {
			nocount++;
		} else if(player.vote_vote == 1) {
			yescount++;
		} else if(player.vote_vote == -2) {
			abstaincount++;
		}
		playercount++;
		//do the same for real players
		if(player.classname == "player") {
			if(player.vote_vote == -1) {
				realplayernocount++;
			} else if(player.vote_vote == 1) {
				realplayeryescount++;
			} else if(player.vote_vote == -2) {
				realplayerabstaincount++;
			}
			realplayercount++;
		}
	}

	//in tournament mode, if we have at least one player then don't make the vote dependent on spectators (so specs don't have to press F1)
	if(cvar("g_tourney"))
	if(realplayercount > 0) {
		yescount = realplayeryescount;
		nocount = realplayernocount;
		abstaincount = realplayerabstaincount;
		playercount = realplayercount;
	}


	if(votecalledmaster
	   && playercount == 1) {
		// if only one player is on the server becoming vote
		// master is not allowed.  This could be used for
		// trolling or worse. 'self' is the user who has
		// called the vote because this function is called
		// by SV_ParseClientCommand. Maybe all voting should
		// be disabled for a single player?
		print_to(votecaller, "^1You are the only player on this server so you can not become vote master.");
		if(votecaller) {
			votecaller.vote_next = 0;
		}
		VoteReset();
	} else {
		float votefactor;
		votefactor = bound(0.5, cvar("sv_vote_majority_factor"), 0.999);
		if(yescount > (playercount - abstaincount) * votefactor)
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "yes");
			VoteAccept();
		}
		else if(nocount >= (playercount - abstaincount) * (1 - votefactor)) // that means, yescount cannot reach minyes any more
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "no");
			VoteReject();
		}
		else if(time > votefinished)
		{
			if(cvar("sv_vote_simple_majority"))
			{
				string result;
				if(yescount > (yescount + nocount) * votefactor)
					result = "yes";
				else if(yescount + nocount > 0)
					result = "no";
				else
					result = "timeout";
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor((yescount + nocount) * votefactor) + 1, result);
				if(result == "yes")
					VoteAccept();
				else if(result == "no")
					VoteReject();
				else
					VoteTimeout();
			}
			else
			{
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor((playercount - abstaincount) * votefactor) + 1, "timeout");
				VoteTimeout();
			}
		}
	}
}
