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

string GetKickVoteVictim_newcommand;
string GetKickVoteVictim_reason;

entity GetKickVoteVictim(string vote, string cmd, entity caller)
{
	float tokens;
	string ns;
	entity e;
	string reason;

	tokens = tokenize_console(vote);
	ns = "";

	e = GetCommandPlayerSlotTargetFromTokenizedCommand(tokens, 1);
	if(e)
	{
		if(ParseCommandPlayerSlotTarget_firsttoken < tokens)
			GetKickVoteVictim_reason = substring(vote, argv_start_index(ParseCommandPlayerSlotTarget_firsttoken), argv_end_index(-1) - argv_start_index(ParseCommandPlayerSlotTarget_firsttoken));
		else
			GetKickVoteVictim_reason = "";

		reason = "";
		if(cmd != "vdo" || GetKickVoteVictim_reason == "")
			reason = "~"; // by convention, ~ prefixes a "unverified" kickban which will not be networked

		if(substring(GetKickVoteVictim_reason, 0, 1) == "~")
		{
			reason = "~";
			GetKickVoteVictim_reason = substring(GetKickVoteVictim_reason, 1, strlen(GetKickVoteVictim_reason) - 1);
		}

		if(caller)
			reason = strcat(reason, "player ", strdecolorize(caller.netname));
		else
			reason = strcat(reason, "console vote");
		if(GetKickVoteVictim_reason != "")
			reason = strcat(reason, ": ", strdecolorize(GetKickVoteVictim_reason));

		if not(cvar_value_issafe(reason))
			reason = uri_escape(reason);

		GetKickVoteVictim_newcommand = strcat(argv(0), " # ", ftos(num_for_edict(e)));
		if(argv(0) == "kickban")
		{
			GetKickVoteVictim_newcommand = strcat(GetKickVoteVictim_newcommand, " ", cvar_string("g_ban_default_bantime"), " ", cvar_string("g_ban_default_masksize"), " ", reason);
		}
		else if(argv(0) == "kick")
		{
			GetKickVoteVictim_newcommand = strcat(GetKickVoteVictim_newcommand, " ", reason);
		}
		return e;
	}

	print_to(caller, strcat("Usage: ", cmd, " ", argv(0), " #playernumber (as in \"status\")\n"));
	return world;
}

string RemapVote_display;
string RemapVote_vote;
float RemapVote(string vote, string cmd, entity e)
{
	float vote_argc;
	entity victim;
	vote_argc = tokenize_console(vote);

	if(!VoteAllowed(argv(0), cmd))
		return FALSE;

	// VoteAllowed tokenizes!
	vote_argc = tokenize_console(vote);

	// remap chmap to gotomap (forces intermission)
	if(vote_argc < 2)
		if(argv(0) == "chmap" || argv(0) == "gotomap" || argv(0) == "kick" || argv(0) == "kickban") // won't work without arguments
			return FALSE;
	if(argv(0) == "chmap")
	{
		vote = strcat("gotomap ", substring(vote, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)));
		vote_argc = tokenize_console(vote);
	}
	if(argv(0) == "gotomap")
	{
		if(!(vote = ValidateMap(substring(vote, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), e)))
			return FALSE;
		vote = strcat("gotomap ", vote);
		vote_argc = tokenize_console(vote); // ValidateMap may have done some stuff to it
	}

	// make kick and kickban votes a bit nicer (and reject them if formatted badly)
	if(argv(0) == "kick" || argv(0) == "kickban")
	{
		if(!(victim = GetKickVoteVictim(vote, cmd, e)))
			return FALSE;
		RemapVote_vote = GetKickVoteVictim_newcommand;
		RemapVote_display = strcat("^1", vote, " (^7", victim.netname, "^1): ", GetKickVoteVictim_reason);
	}
	else
	{
		RemapVote_vote = vote;
		RemapVote_display = strzone(strcat("^1", vote));
	}

	return TRUE;
}

void VoteDialog_UpdateHighlight(float selected) {
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_VOTE);
	WriteByte(MSG_ONE, 1);
	WriteShort(MSG_ONE, selected);
}

void VoteDialog_Reset() {
	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	WriteByte(MSG_ALL, TE_CSQC_VOTERESET);
}

float GameCommand_Vote(string s, entity e) {
	float argc;
	argc = tokenize_console(s);
	if(argv(0) == "help") {
		print_to(e, "  vote COMMANDS ARGUMENTS. See 'vhelp' for more info.");
		return TRUE;
	} else if(argv(0) == "vote") {
		if(argv(1) == "") {
			print_to(e, "^1You have to supply a vote command. See 'vhelp' for more info.");
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
				if(cvar("sv_vote_nospectators") && e && e.classname != "player") {
					print_to(e, "^1Error: Only players can call a vote."); // TODO invent a cvar name for allowing votes by spectators during warmup anyway
				}
				else if(timeoutStatus) { //don't allow a vote call during a timeout
					print_to(e, "^1Error: You can not call a vote while a timeout is active.");
				}
				else if(votecalled) {
					print_to(e, "^1There is already a vote called.");
				} else {
					local string vote;
					vote = VoteParse(s, argc);
					if(vote == "") {
						print_to(e, "^1Your vote is empty. See 'vhelp' for more info.");
					} else if(e
						&& time < e.vote_next) {
							print_to(e, strcat("^1You have to wait ^2", ftos(e.vote_next - time), "^1 seconds before you can again call a vote."));
					} else if(VoteCheckNasty(vote)) {
						print_to(e, "Syntax error in command. See 'vhelp' for more info.");
					} else if(RemapVote(vote, "vcall", e)) {
						votecalledvote = strzone(RemapVote_vote);
						votecalledvote_display = strzone(RemapVote_display);
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
							GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display));
						VoteCount(); // needed if you are the only one
						Nagger_VoteChanged();
						msg_entity = e;
						VoteDialog_UpdateHighlight(1);
					} else {
						print_to(e, "^1This vote is not ok. See 'vhelp' for more info.");
					}
				}
			} else {
				print_to(e, "^1Vote calling is NOT allowed.");
			}
		} else if(argv(1) == "stop") {
			if(!votecalled) {
				print_to(e, "^1No vote called.");
			} else if(e == votecaller) { // the votecaller can stop a vote
				VoteDialog_Reset();
				VoteStop(e);
			} else if(!e) { // server admin / console can too
				VoteDialog_Reset();
				VoteStop(e);
			} else if(e.vote_master) { // masters can too
				VoteDialog_Reset();
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
						GameLogEcho(strcat(":vote:vcall:", ftos(votecaller.playerid), ":", votecalledvote_display));
					VoteCount(); // needed if you are the only one
					Nagger_VoteChanged();
				}
			} else {
				print_to(e, "^1Vote to become master is NOT allowed.");
			}
		} else if(argv(1) == "do") {
			if(!e || e.vote_master) {
				local string dovote;
				dovote = VoteParse(s, argc);
				if(dovote == "") {
					print_to(e, "^1Your command was empty. See 'vhelp' for more info.");
				} else if(VoteCheckNasty(dovote)) {
					print_to(e, "Syntax error in command. See 'vhelp' for more info.");
				} else if(RemapVote(dovote, "vdo", e)) { // strcat seems to be necessary
					bprint("\{1}^2* ^3", VoteNetname(e), "^2 used their ^3master^2 status to do \"^2", RemapVote_display, "^2\".\n");
					if(cvar("sv_eventlog"))
						GameLogEcho(strcat(":vote:vdo:", ftos(e.playerid), ":", RemapVote_display));
					localcmd(strcat(RemapVote_vote, "\n"));
				} else {
					print_to(e, "^1This command is not ok. See 'vhelp' for more info.");
				}
			} else {
				print_to(e, "^1You are NOT a master.  You might need to login or vote to become master first. See 'vhelp' for more info.");
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
					print("Accepted master login from ", VoteNetname(e), "\n");
					bprint("\{1}^2* ^3", VoteNetname(e), "^2 logged in as ^3master^2\n");
					if(cvar("sv_eventlog"))
						GameLogEcho(strcat(":vote:vlogin:", ftos(e.playerid)));
				}
				else
					print("REJECTED master login from ", VoteNetname(e), "\n");
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
				msg_entity = e;
				VoteDialog_UpdateHighlight(1);
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
				msg_entity = e;
				VoteDialog_UpdateHighlight(2);
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
				msg_entity = e;
				VoteDialog_UpdateHighlight(3);
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
	m = MapInfo_FixName(m);
	if(!m)
	{
		print_to(e, "This map is not available on this server.");
		return string_null;
	}
	if(!cvar("sv_vote_override_mostrecent"))
		if(Map_IsRecent(m))
		{
			print_to(e, "This server does not allow for recent maps to be played again. Please be patient for some rounds.");
			return string_null;
		}
	if(!MapInfo_CheckMap(m))
	{
		print_to(e, strcat("^1Invalid mapname, \"^3", m, "^1\" does not support the current game mode."));
		return string_null;
	}

	return m;
}


void VoteThink() {
	if(votefinished > 0) // a vote was called
	if(time > votefinished) // time is up
	{
		VoteCount();
	}
}

string VoteParse(string all, float argc) {
	if(argc < 3)
		return "";
	return substring(all, argv_start_index(2), argv_end_index(-1) - argv_start_index(2));
}

float VoteCommandInList(string votecommand, string list)
{
	string l;
	l = strcat(" ", list, " ");
	
	if(strstrofs(l, strcat(" ", votecommand, " "), 0) >= 0)
		return TRUE;
	
	// if gotomap is allowed, chmap is too, and vice versa
	if(votecommand == "gotomap")
		if(strstrofs(l, " chmap ", 0) >= 0)
			return TRUE;
	if(votecommand == "chmap")
		if(strstrofs(l, " gotomap ", 0) >= 0)
			return TRUE;
	
	return FALSE;
}

float VoteAllowed(string votecommand, string cmd) {
	if(VoteCommandInList(votecommand, cvar_string("sv_vote_commands")))
		return TRUE;

	if(cmd == "vdo")
	{
		if(VoteCommandInList(votecommand, cvar_string("sv_vote_master_commands")))
			return TRUE;
	}
	else
	{
		if(VoteCommandInList(votecommand, cvar_string("sv_vote_only_commands")))
			return TRUE;
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
		GameLogEcho(strcat(":vote:vstop:", ftos(stopper.playerid)));
	if(stopper == votecaller) {
		// no wait for next vote so you can correct your vote
		if(votecaller) {
			votecaller.vote_next = time + cvar("sv_vote_stop");
		}
	}
	VoteReset();
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
		GameLogEcho(s);
	}
}

void VoteDialog_Update(float msg, float vyes, float vno, float needed) {
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_VOTE);
	WriteByte(msg, 0);
	WriteShort(msg, vyes);
	WriteShort(msg, vno);
	WriteShort(msg, needed);
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
			++nocount;
		} else if(player.vote_vote == 1) {
			++yescount;
		} else if(player.vote_vote == -2) {
			++abstaincount;
		}
		++playercount;
		//do the same for real players
		if(player.classname == "player") {
			if(player.vote_vote == -1) {
				++realplayernocount;
			} else if(player.vote_vote == 1) {
				++realplayeryescount;
			} else if(player.vote_vote == -2) {
				++realplayerabstaincount;
			}
			++realplayercount;
		}
	}

	//in tournament mode, if we have at least one player then don't make the vote dependent on spectators (so specs don't have to press F1)
	if(cvar("sv_vote_nospectators"))
	if(realplayercount > 0) {
		yescount = realplayeryescount;
		nocount = realplayernocount;
		abstaincount = realplayerabstaincount;
		playercount = realplayercount;
	}

	float votefactor, simplevotefactor;
	votefactor = bound(0.5, cvar("sv_vote_majority_factor"), 0.999);
	simplevotefactor = cvar("sv_vote_simple_majority_factor");
	float needed;
	needed = floor((playercount - abstaincount) * max(votefactor, simplevotefactor)) + 1;
	VoteDialog_Update(MSG_ALL, yescount, nocount, needed);

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
		if(yescount > (playercount - abstaincount) * votefactor)
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "yes");
			VoteAccept();
			VoteDialog_Reset();
		}
		else if(nocount >= (playercount - abstaincount) * (1 - votefactor)) // that means, yescount cannot reach minyes any more
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1, "no");
			VoteReject();
			VoteDialog_Reset();
		}
		else if(time > votefinished)
		{
			if(simplevotefactor)
			{
				string result;
				simplevotefactor = bound(votefactor, simplevotefactor, 0.999);
				if(yescount > (yescount + nocount) * simplevotefactor)
					result = "yes";
				else if(yescount + nocount > 0)
					result = "no";
				else
					result = "timeout";
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor(min((playercount - abstaincount) * votefactor, (yescount + nocount) * simplevotefactor)) + 1, result);
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
		VoteDialog_Reset();
		}
	}
}
