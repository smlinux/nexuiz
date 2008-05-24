void ReadyCount();
string ValidateMap(string vote);
void(entity e) DropFlag;
string MapVote_Suggest(string m);

.float floodcontrol_chat;
.float floodcontrol_team;
void Say(entity source, float teamsay, string msgin)
{
	string msgstr, colorstr, cmsgstr, namestr;
	float flood;
	entity head;

	if(!teamsay)
		if(substring(msgin, 0, 1) == " ")
			msgin = substring(msgin, 1, strlen(msgin) - 1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(msgin);

	if(msgin == "")
		return;

	if(source.classname != "player")
		colorstr = "^0"; // black for spectators
	else if(teams_matter)
		colorstr = Team_ColorCode(source.team);
	else
		teamsay = FALSE;

	if(intermission_running)
		teamsay = FALSE;

	/*
	 * using bprint solves this... me stupid
	// how can we prevent the message from appearing in a listen server?
	// for now, just give "say" back and only handle say_team
	if(!teamsay)
	{
		clientcommand(self, strcat("say ", msgin));
		return;
	}
	*/

	if(cvar("g_chat_teamcolors"))
		namestr = playername(source);
	else
		namestr = source.netname;
	if(teamsay)
	{
		msgstr = strzone(strcat("\{1}\{13}", colorstr, "(^3", namestr, colorstr, ") ^7", msgin, "\n"));
		cmsgstr = strcat(colorstr, "(^3", namestr, colorstr, ")\n^7", wordwrap(msgin, 50));
	}
	else
		msgstr = strzone(strcat("\{1}", namestr, "^7: ", msgin, "\n"));

	// FLOOD CONTROL
	flood = 0;
	{
		float flood_spl;
		float flood_burst;
		float flood_lmax;
		var .float flood_field;
		float lines;
		if(teamsay)
		{
			flood_spl = cvar("g_chat_flood_spl_team");
			flood_burst = cvar("g_chat_flood_burst_team");
			flood_lmax = cvar("g_chat_flood_lmax_team");
			flood_field = floodcontrol_team;
		}
		else
		{
			flood_spl = cvar("g_chat_flood_spl");
			flood_burst = cvar("g_chat_flood_burst");
			flood_lmax = cvar("g_chat_flood_lmax");
			flood_field = floodcontrol_chat;
		}
		flood_burst = max(0, flood_burst - 1);
		// to match explanation in default.cfg, a value of 3 must allow three-line bursts and not four!
		lines = ceil(strlennocol(msgstr) / 75);
		if(flood_lmax && lines > flood_lmax)
			flood = 2;
		else if(time >= self.flood_field)
			self.flood_field = max(time - flood_burst * flood_spl, self.flood_field) + lines * flood_spl;
		else
			flood = 1;
	}

	if(flood)
	{
		if(cvar("g_chat_flood_notify_flooder"))
		{
			if(flood == 1)
				sprint(self, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(self.flood_field - time), "^3 seconds\n"));
			else if(flood == 2)
				sprint(self, "^3FLOOD CONTROL: ^7message too long\n");
		}
		else
			sprint(self, msgstr);
		ServerConsoleEcho(strcat("NOTE: ", playername(self), "^7 is flooding."), TRUE);
	}
	else if(teamsay)
	{
		if(source.classname == "player")
		{
			FOR_EACH_REALPLAYER(head)
			{
				if(head.team == source.team)
				{
					sprint(head, msgstr);
					centerprint(head, cmsgstr);
				}
			}
		}
		else
		{
			FOR_EACH_REALCLIENT(head) if(head.classname != "player")
			{
				sprint(head, msgstr);
				centerprint(head, cmsgstr);
			}
		}
	}
	else
	{
		//when g_tourney is active and g_tourney_disable_spec_chat is set and game is in matchstage
		//don't print the text from specs/observers to the players but only the other spectators
		if(g_tourney && cvar("g_tourney_disable_spec_chat") && tourneyInMatchStage && source.classname != "player") {
			FOR_EACH_REALCLIENT(head) if(head.classname != "player") {
				sprint(head, msgstr);
			}
		}
		else
			bprint(msgstr);
		//ServerConsoleEcho(substring(msgstr, 1, strlen(msgstr) - 2), TRUE);
	}

	strunzone(msgstr);
}

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
entity GetKickVoteVictim(string vote, string cmd)
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

	sprint(self, strcat("Usage: ", cmd, " ", argv(0), " #playernumber (as in \"status\")\n"));
	return world;
}

void SV_ParseClientCommand(string s) {
	local string cmd;
	local entity e;
	local float i;

	tokenize(s);

	if(argv(0) == "vote") {
		if(argv(1) == "help") {
			local string vmasterdis;
			if(!cvar("sv_vote_master")) {
				vmasterdis = " ^1(disabled)";
			}
			local string vcalldis;
			if(!cvar("sv_vote_call")) {
				vcalldis = " ^1(disabled)";
			}
			sprint(self, "^7You can use voting with \"^2cmd vote help^7\" \"^2cmd vote status^7\" \"^2cmd vote call ^3COMMAND ARGUMENTS^7\" \"^2cmd vote stop^7\" \"^2cmd vote master^7\" \"^2cmd vote do ^3COMMAND ARGUMENTS^7\" \"^2cmd vote yes^7\" \"^2cmd vote no^7\" \"^2cmd vote dontcare^7\".\n");
			sprint(self, "^7Or if your version is up to date you can use these aliases \"^2vhelp^7\" \"^2vstatus^7\" \"^2vcall ^3COMMAND ARGUMENTS^7\" \"^2vstop^7\" \"^2vmaster^7\" \"^2vdo ^3COMMAND ARGUMENTS^7\" \"^2vyes^7\" \"^2vno^7\" \"^2vdontcare^7\".\n");
			sprint(self, "^7\"^2help^7\" shows this info.\n");
			sprint(self, "^7\"^2status^7\" shows if there is a vote called and who called it.\n");
			sprint(self, strcat("^7\"^2call^7\" is used to call a vote. See the list of allowed commands.", vcalldis, "^7\n"));
			sprint(self, "^7\"^2stop^7\" can be used by the vote caller or an admin to stop a vote and maybe correct it.\n");
			sprint(self, strcat("^7\"^2master^7\" is used to call a vote to become a master.", vmasterdis, "^7\n"));
			sprint(self, "^7\"^2do^7\" If you are a master you can execute a command without a vote. See the list of allowed commands.\n");
			sprint(self, "^7\"^2yes^7\", \"^2no^7\" and \"^2dontcare^7\" to make your vote.\n");
			sprint(self, "^7If enough of the players vote yes the vote is accepted.\n");
			sprint(self, "^7If enough of the players vote no the vote is rejected.\n");
			sprint(self, strcat("^7The vote will end after ", cvar_string("sv_vote_timeout"), "^7 seconds.\n"));
			sprint(self, "^7You can call a vote for or execute these commands:\n");
			sprint(self, strcat("^3", cvar_string("sv_vote_commands"), "^7 and maybe further ^3arguments^7\n"));
		} else if(argv(1) == "status") {
			if(votecalled) {
				sprint(self, strcat("^7Vote for ", votecalledvote_display, "^7 called by ^7", votecaller.netname, "^7.\n"));
			} else {
				sprint(self, "^1No vote called.\n");
			}
		} else if(argv(1) == "call") {
			if(cvar("sv_vote_call")) {
				if(tourneyInMatchStage && cvar("g_tourney_disable_spec_vote") && self.classname != "player") {
					sprint(self, "^1Error: Only players can call a vote during the match-stage.\n");
				}
				else if(votecalled) {
					sprint(self, "^1There is already a vote called.\n");
				} else {
					local string vote;
					vote = VoteParse();
					if(vote == "") {
						sprint(self, "^1Your vote is empty. See help for more info.\n");
					} else if(time < self.vote_next) {
						sprint(self, strcat("^1You have to wait ^2", ftos(self.vote_next - time), "^1 seconds before you can again call a vote.\n"));
					} else if(VoteCheckNasty(vote)) {
						sprint(self, "Syntax error in command.\n");
					} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
						// remap chmap to gotomap (forces intermission)
						if(vote == "chmap" || vote == "gotomap") // won't work without arguments
							return;
						if(substring(vote, 0, 6) == "chmap ")
							vote = strcat("gotomap ", substring(vote, 6, strlen(vote) - 6));
						if(substring(vote, 0, 8) == "gotomap ")
						{
							if(!(vote = ValidateMap(substring(vote, 8, strlen(vote) - 8))))
								return;
							vote = strcat("gotomap ", vote);
						}

						// make kick and kickban votes a bit nicer (and reject them if formatted badly)
						if(substring(vote, 0, 5) == "kick " || substring(vote, 0, 8) == "kickban ")
						{
							if(!(e = GetKickVoteVictim(vote, "vcall")))
								return;
							vote = GetKickVoteVictim_newcommand;
							votecalledvote_display = strzone(strcat("^1", vote, " (^7", e.netname, "^1): ", GetKickVoteVictim_reason));
						}
						else
						{
							votecalledvote_display = strzone(strcat("^1", vote));
						}
						votecalledvote = strzone(vote);
						votecalled = TRUE;
						votecalledmaster = FALSE;
						votecaller = self; // remember who called the vote
						votefinished = time + cvar("sv_vote_timeout");
						votecaller.vote_vote = 1; // of course you vote yes
						votecaller.vote_next = time + cvar("sv_vote_wait");
						bprint("\{1}^2* ^3", votecaller.netname, "^2 calls a vote for ", votecalledvote_display, "\n");
						VoteCount(); // needed if you are the only one
					} else {
						sprint(self, "^1This vote is not ok. See help for more info.\n");
					}
				}
			} else {
				sprint(self, "^1Vote calling is NOT allowed.\n");
			}
		} else if(argv(1) == "stop") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self == votecaller) { // the votecaller can stop a vote
				VoteStop(self);
			} else if(self.vote_master) { // masters can, too
				VoteStop(self);
			} else {
				sprint(self, "^1You are not allowed to stop that Vote.\n");
			}
		} else if(argv(1) == "master") {
			if(cvar("sv_vote_master")) {
				if(votecalled) {
					sprint(self, "^1There is already a vote called.\n");
				} else {
					votecalled = TRUE;
					votecalledmaster = TRUE;
					votecalledvote = strzone("XXX");
					votecalledvote_display = strzone("^3master");
					votecaller = self; // remember who called the vote
					votefinished = time + cvar("sv_vote_timeout");
					votecaller.vote_vote = 1; // of course you vote yes
					votecaller.vote_next = time + cvar("sv_vote_wait");
					bprint("\{1}^2* ^3", votecaller.netname, "^2 calls a vote to become ^3master^2.\n");
					VoteCount(); // needed if you are the only one
				}
			} else {
				sprint(self, "^1Vote to become master is NOT allowed.\n");
			}
		} else if(argv(1) == "do") {
			if(argv(2) == "login") {
				local string masterpwd;
				masterpwd = cvar_string("sv_vote_master_password");
				if(masterpwd != "") {
					self.vote_master = (masterpwd == argv(3));
					if(self.vote_master) {
						ServerConsoleEcho(strcat("Accepted master login from ", self.netname), TRUE);
						bprint("\{1}^2* ^3", self.netname, "^2 logged in as ^3master^2\n");
					}
					else
						ServerConsoleEcho(strcat("REJECTED master login from ", self.netname), TRUE);
				}
				else
					sprint(self, "^1You are NOT a master.\n");
			} else if(self.vote_master) {
				local string dovote, dovote_display;
				dovote = VoteParse();
				if(dovote == "") {
					sprint(self, "^1Your command was empty. See help for more info.\n");
				} else if(VoteCheckNasty(dovote)) {
					sprint(self, "Syntax error in command.\n");
				} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
					if(dovote == "chmap" || dovote == "gotomap") // won't work without arguments
						return;
					if(substring(dovote, 0, 6) == "chmap ")
						dovote = strcat("gotomap ", substring(dovote, 6, strlen(dovote) - 6));
					if(substring(dovote, 0, 8) == "gotomap ")
					{
						if(!(dovote = ValidateMap(substring(dovote, 8, strlen(dovote) - 8))))
							return;
						dovote = strcat("gotomap ", dovote);
					}

					dovote_display = dovote;
					if(substring(dovote, 0, 5) == "kick " || substring(dovote, 0, 8) == "kickban ")
					{
						if(!(e = GetKickVoteVictim(dovote, "vdo")))
							return;
						dovote = GetKickVoteVictim_newcommand;
						dovote_display = strcat("^1", dovote, " (^7", e.netname, "^1): ", GetKickVoteVictim_reason);
					}
					bprint("\{1}^2* ^3", self.netname, "^2 used his ^3master^2 status to do \"^2", dovote_display, "^2\".\n");
					localcmd(strcat(dovote, "\n"));
				} else {
					sprint(self, "^1This command is not ok. See help for more info.\n");
				}
			} else {
				sprint(self, "^1You are NOT a master.\n");
			}
		} else if(argv(1) == "yes") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				sprint(self, "^1You accepted the vote.\n");
				self.vote_vote = 1;
				centerprint_expire(self, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else if(argv(1) == "no") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				sprint(self, "^1You rejected the vote.\n");
				self.vote_vote = -1;
				centerprint_expire(self, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else if(argv(1) == "abstain" || argv(1) == "dontcare") {
			if(!votecalled) {
				sprint(self, "^1No vote called.\n");
			} else if(self.vote_vote == 0
				  || cvar("sv_vote_change")) {
				sprint(self, "^1You abstained from your vote.\n");
				self.vote_vote = -2;
				centerprint_expire(self, CENTERPRIO_VOTE);
				if(!cvar("sv_vote_singlecount")) {
					VoteCount();
				}
			} else {
				sprint(self, "^1You have already voted.\n");
			}
		} else {
			// ignore this?
			sprint(self, "^1Unknown vote command.\n");
		}
	} else if(argv(0) == "autoswitch") {
		// be backwards compatible with older clients (enabled)
		self.autoswitch = ("0" != argv(1));
		local string autoswitchmsg;
		if (self.autoswitch) {
			autoswitchmsg = "on";
		} else {
			autoswitchmsg = "off";
		}
		sprint(self, strcat("^1autoswitch turned ", autoswitchmsg, "\n"));
	} else if(argv(0) == "clientversion") {
		if (argv(1) == "$gameversion") {
			//versionmsg = "^1client is too old to get versioninfo.\nUPDATE!!! (http://www.nexuiz.com)^8";
			// either that or someone wants to be funny
			self.version = 1;
		} else {
			self.version = stof(argv(1));
		}
		if(self.version != cvar("gameversion"))
		{
			self.classname = "observer";
			self.frags = -2;
			PutClientInServer();
		} else if(cvar("g_campaign") || cvar("g_balance_teams") || cvar("g_balance_teams_force")) {
			//JoinBestTeam(self, FALSE, TRUE);
		} else if(cvar("teamplay") && !cvar("sv_spectate")) {
			self.classname = "observer";
			stuffcmd(self,"menu_showteamselect\n");
		}
	} else if(argv(0) == "reportcvar") { // old system
		GetCvars(1);
	} else if(argv(0) == "sentcvar") { // new system
		GetCvars(1);
	} else if(argv(0) == "spectate") {
		if(g_lms || g_arena)
			return; // don't allow spectating in lms, unless player runs out of lives
		if(self.classname == "player" && cvar("sv_spectate") == 1) {
			if(self.flagcarried)
				DropFlag(self.flagcarried);
			kh_Key_DropAll(self, TRUE);
			WaypointSprite_PlayerDead();
			DistributeFragsAmongTeam(self, self.team, 1.0);
			self.classname = "observer";
			if(blockSpectators)
				sprint(self, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
			PutClientInServer();
		}
	} else if(argv(0) == "join") {
		if(!g_arena)
		if (self.classname != "player" && !lockteams)
		{
			if(isJoinAllowed()) {
				self.classname = "player";
				self.frags = 0;
				bprint ("^4", self.netname, "^4 is playing now\n");
				PutClientInServer();
			}
			else {
				//player may not join because of g_maxplayers is set
				centerprint_atprio(self, CENTERPRIO_MAPVOTE, PREVENT_JOIN_TEXT);
			}
		}
	} else if( argv(0) == "selectteam" ) {
		if( !cvar("teamplay") ) {
			sprint( self, "selecteam can only be used in teamgames\n");
		} else if(cvar("g_campaign")) {
			//JoinBestTeam(self, 0);
		} else if(lockteams) {
			sprint( self, "^7The game has already begun, you must wait until the next map to be able to join a team.\n");
		} else if( argv(1) == "red" ) {
			DoTeamChange(COLOR_TEAM1);
		} else if( argv(1) == "blue" ) {
			DoTeamChange(COLOR_TEAM2);
		} else if( argv(1) == "yellow" ) {
			DoTeamChange(COLOR_TEAM3);
		} else if( argv(1) == "pink" ) {
			DoTeamChange(COLOR_TEAM4);
		} else if( argv(1) == "auto" ) {
			DoTeamChange(-1);
		} else {
			sprint( self, strcat( "selectteam none/red/blue/yellow/pink/auto - \"", argv(1), "\" not recognised\n" ) );
		}
	} else if(argv(0) == "ready") {
		if(cvar("sv_ready_restart"))
		{
			if(!restart_countdown || cvar("sv_ready_restart_repeatable"))
			{
				self.ready = TRUE;
				bprint(self.netname, "^2 is ready\n");
				ReadyCount();
			} else {
				sprint(self, "^1game has already been restarted\n");
			}
		}
	} else if(argv(0) == "maplist") {
		local float n;
		local string col;
		n = tokenize(cvar_string("g_maplist"));
		sprint(self, "^7Maps in list: ");
		for(i = 0; i < n; ++i)
		{
			if(mod(i, 2))
				col = "^2";
			else
				col = "^3";
			sprint(self, strcat(col, argv(i), " "));
		}
		sprint(self, "\n");
#ifdef MAPINFO
	} else if(argv(0) == "lsmaps") {
		sprint(self, "^7Maps available: ");
		for(i = 0; i < MapInfo_count; ++i)
		{
			if(mod(i, 2))
				col = "^2";
			else
				col = "^3";
			sprint(self, strcat(col, MapInfo_BSPName_ByID(i), " "));
		}
		sprint(self, "\n");
#endif
	} else if(argv(0) == "teamstatus") {
		PrintScoreboard(self);
	} else if(argv(0) == "voice") {
		VoiceMessage(argv(1));
	} else if(argv(0) == "say") {
		Say(self, FALSE, substring(s, 4, strlen(s) - 4));
		//clientcommand(self, formatmessage(s));
	} else if(argv(0) == "say_team") {
		Say(self, TRUE, substring(s, 9, strlen(s) - 9));
		//clientcommand(self, formatmessage(s));
	} else if(argv(0) == "info") {
		cmd = cvar_string(strcat("sv_info_", argv(1)));
		if(cmd == "")
			sprint(self, "ERROR: unsupported info command\n");
		else
			wordwrap_sprint(cmd, 1111);
	} else if(argv(0) == "suggestmap") {
		sprint(self, strcat(MapVote_Suggest(argv(1)), "\n"));
	} else {
		cmd = argv(0);
		/* checks not needed any more since DP has separated clientcommands and regular commands
		if(cmd != "status")
		if(cmd != "name")
		//if(cmd != "say") // handled above
		//if(cmd != "say_team") // handled above
		if(cmd != "tell")
		if(cmd != "color")
		if(cmd != "kill")
		if(cmd != "pause")
		if(cmd != "kick")
		if(cmd != "ping")
		if(cmd != "pings")
		if(cmd != "ban")
		if(cmd != "pmodel")
		if(cmd != "rate")
		if(cmd != "playermodel")
		if(cmd != "playerskin")
		if(cmd != "god") if(cmd != "notarget") if(cmd != "fly") if(cmd != "give") if(cmd != "noclip")
		{
			ServerConsoleEcho(strcat("WARNING: Invalid clientcommand by ", self.netname, ": ", s), TRUE);
			return;
		}
		*/
		clientcommand(self,s);
	}
}

string ValidateMap(string m)
{
#ifdef MAPINFO
	m = MapInfo_FixName(m);
	if(!m)
	{
		sprint(self, "This map is not available on this server.\n");
		return string_null;
	}
#else
	if(!cvar("sv_vote_change_gametype"))
		if(!IsSameGametype(m))
		{
			sprint(self, "This server does not allow changing the game type by map votes.\n");
			return string_null;
		}
#endif
	if(!cvar("sv_vote_override_mostrecent"))
		if(Map_IsRecent(m))
		{
			sprint(self, "This server does not allow for recent maps to be played again. Please be patient for some rounds.\n");
			return string_null;
		}
#ifdef MAPINFO
	if(!MapInfo_CheckMap(m))
	{
		sprint(self, strcat("^1Invalid mapname, \"^3", m, "^1\" does not support the current game mode.\n"));
		return string_null;
	}
#else
	if(!TryFile(strcat("maps/", m, ".mapcfg")))
	{
		sprint(self, strcat("^1Invalid mapname, \"^3", m, "^1\" does not exist on this server.\n"));
		return string_null;
	}
#endif

	return m;
}


void VoteThink() {
	if(votefinished > 0 // a vote was called
	    && time > votefinished) // time is up
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

	// now we remove some things that could be misused
	index = 0;
	local float found;
	found = FALSE;
	local float votelength;
	votelength = strlen(vote);
	while(!found && index < votelength)
	{
		local string badchar;
		badchar = substring(vote, index, 1);
		if(badchar == ";"
		   || badchar == "\r"
		   || badchar == "\n")
		{
			found = TRUE;
		} else {
			index++;
		}
	}
	return substring(vote, 0, index);
}

float VoteAllowed(string votecommand) {
	tokenize(cvar_string("sv_vote_commands"));
	local float index;
	index = 0;
	while(argv(index) != "") {
		local string allowed;
		allowed = argv(index);
		if(votecommand == allowed) {
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
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ^1", votecalledvote_display, "^2 was accepted\n");
	if(votecalledmaster)
	{
		votecaller.vote_master = 1;
	} else {
		//in g_tourney mode and if the vote is a timelimit-change, don't change it immediately but after restart
		if(cvar("g_tourney") && substring(votecalledvote, 0, 10) == "timelimit ") {
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
	votecaller.vote_next = 0; // people like your votes, no wait for next vote
	VoteReset();
}

void VoteReject() {
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ", votecalledvote_display, "^2 was rejected\n");
	VoteReset();
}

void VoteTimeout() {
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ", votecalledvote_display, "^2 timed out\n");
	VoteReset();
}

void VoteStop(entity stopper) {
	bprint("\{1}^2* ^3", stopper.netname, "^2 stopped ^3", votecaller.netname, "^2's vote\n");
	if(stopper == votecaller) {
		// no wait for next vote so you can correct your vote
		votecaller.vote_next = 0;
	}
	VoteReset();
}

void VoteNag() {
	if(votecalled)
		if(self.vote_vote == 0)
			centerprint_atprio(self, CENTERPRIO_VOTE, strcat("^7^3", votecaller.netname, "^2 called a vote for ", votecalledvote_display, "\n\n^2You have not voted yet!\n^2HINT: By default, F1 is yes and F2 is no."));
}

void VoteSpam(float yescount, float nocount, float abstaincount, float notvoters, float mincount)
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
		s = strcat(s, ftos(nocount), "^2 (^1");
		s = strcat(s, ftos(abstaincount), "^2 didn't care, ^1");
		s = strcat(s, ftos(notvoters), "^2 didn't have to vote\n");
	}
	bprint(s);
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
	if( cvar("g_tourney") && (realplayercount > 0) ) {
		yescount = realplayeryescount;
		nocount = realplayernocount;
		abstaincount = realplayerabstaincount;
		playercount = realplayercount;
	}


	if((playercount == 1) && votecalledmaster) {
		// if only one player is on the server becoming vote
		// master is not allowed.  This could be used for
		// trolling or worse. 'self' is the user who has
		// called the vote because this function is called
		// by SV_ParseClientCommand. Maybe all voting should
		// be disabled for a single player?
		sprint(self, "^1You are the only player on this server so you can not become vote master.\n");
		votecaller.vote_next = 0;
		VoteReset();
	} else {
		float votefactor;
		votefactor = bound(0.5, cvar("sv_vote_majority_factor"), 0.999);
		if(yescount > (playercount - abstaincount) * votefactor)
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1);
			VoteAccept();
		}
		else if(nocount >= (playercount - abstaincount) * (1 - votefactor)) // that means, yescount cannot reach minyes any more
		{
			VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, -1);
			VoteReject();
		}
		else if(time > votefinished)
		{
			if(cvar("sv_vote_simple_majority"))
			{
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor((yescount + nocount) * votefactor) + 1);
				if(yescount > (yescount + nocount) * votefactor)
					VoteAccept();
				else if(yescount + nocount > 0)
					VoteReject();
				else
					VoteTimeout();
			}
			else
			{
				VoteSpam(yescount, nocount, abstaincount, playercount - yescount - nocount - abstaincount, floor((playercount - abstaincount) * votefactor) + 1);
				VoteTimeout();
			}
		}
	}
}

/**
 * Counts how many players are ready. If not enough players are ready, the function
 * does nothing. If all players are ready, the timelimit will be extended and the
 * restart_countdown variable is set to allow other functions like PlayerPostThink
 * to detect that the countdown is now active. If the cvar sv_ready_restart_after_countdown
 * is not set the map will be resetted.
 * 
 * Function is called after the server receives a 'ready' sign from a player.
 */
void ReadyCount()
{
	local entity e;
	local float r, p;

	FOR_EACH_REALPLAYER(e)
	{
		p += 1;
		if(e.ready)
			r += 1;
	}

	if(cvar("sv_ready_restart_nag")) {
		if(!readyNagActive) {
			readyNagger = spawn();
			readyNagger.think = readyNagger_Think;
			readyNagger.cnt = cvar("sv_ready_restart_nag_duration");
			readyNagger.nextthink = time;
			readyNagActive = 1;
		}
	}

	if(!p || r < p)
		return;

	bprint("^1Server is restarting...\n");

	// no arena, assault support yet...
	if(g_arena | g_assault | gameover | intermission_running)
		localcmd("restart\n");

	if(readyNagActive) { //if every player is ready, remove the ready-nagger again
		readyNagActive = 0;
		remove(readyNagger);
	}

	if(g_tourney) {
		tourneyInMatchStage = 1; //once the game is restarted the game is in match stage
		//reset weapons and ammo, health and armor to default:
		start_items = IT_LASER | IT_SHOTGUN;
		start_switchweapon = WEP_SHOTGUN;
		start_ammo_shells = cvar("g_start_ammo_shells");
		start_ammo_nails = cvar("g_start_ammo_nails");
		start_ammo_rockets = cvar("g_start_ammo_rockets");
		start_ammo_cells = cvar("g_start_ammo_cells");
		start_health = cvar("g_balance_health_start");
		start_armorvalue = cvar("g_balance_armor_start");
	}

	restart_countdown = time + RESTART_COUNTDOWN;
	restart_mapalreadyrestarted = 0; //reset this var, needed when cvar sv_ready_restart_repeatable is in use
	//reset the .ready status of all players (also spectators)
	FOR_EACH_CLIENT(e)
	{
		e.ready = 0;
	}
	if(0<cvar("timelimit") || (g_tourney && cvar("g_tourney_warmup_unlimited_time")) )
	{
		// remember original timelimit on first restart
		if(!timelimit_orig)
			timelimit_orig = cvar("timelimit");
		//only set the new timelimit if, when loading the map, a timelimit was really set
		if(timelimit_orig)
			cvar_set("timelimit", ftos(timelimit_orig + ceil(restart_countdown)/60));
	}
	if(cvar("teamplay_lockonrestart") && teams_matter) {
		lockteams = 1;
		bprint("^1The teams are now locked.\n");
	}
	
	//initiate the restart-countdown-announcer entity
	restartAnnouncer = spawn();
	restartAnnouncer.think = restartAnnouncer_Think;
	restartAnnouncer.nextthink = time;
	restartAnnouncer.cnt = RESTART_COUNTDOWN;

	//play the prepareforbattle sound to everyone
	sound(world, CHAN_AUTO, "announcer/robotic/prepareforbattle.wav", 1, ATTN_NONE);

	//reset map immediately if this cvar is not set
	if (!cvar("sv_ready_restart_after_countdown"))
		reset_map();
	
	if(cvar("sv_eventlog"))
		GameLogEcho(":restart", FALSE);
}

/**
 * Centerprints the information to all players who didn't ready up yet to do so.
 */
void readyNagger_Think() {
	local entity plr;
	if(self.cnt <= 0) { //have a break showing the ready nag
		//make sure that the old ready-nag-centerprint isn't shown too long:
		FOR_EACH_REALCLIENT(plr) {
			if(plr.classname == "player") {
				if (!plr.ready)
					centerprint_atprio(plr, CENTERPRIO_SPAM, "");
			}
		}
		self.cnt = cvar("sv_ready_restart_nag_duration");
		self.nextthink = time + cvar("sv_ready_restart_nag_interval");
	}
	else {
		//show the ready nagging to all players who aren't ready yet
		FOR_EACH_REALCLIENT(plr) {
			if(plr.classname == "player") {
				if (!plr.ready) {
					centerprint_atprio(plr, CENTERPRIO_SPAM, "^2Please ready up (F4 by default)!");
					//play reminder sound once the centerprint appears for the first time after the pause:
					if (self.cnt == cvar("sv_ready_restart_nag_duration"))
						play2(plr, "misc/talk2.wav");
				}
			}
		}

		self.nextthink = time + 1;
		self.cnt -= 1;
	}
}

/**
 * Shows the restart countdown for all players.
 * Plays the countdown sounds for the seconds 3, 2 1, begin for everyone.
 * Restarts the map after the countdown is over (and cvar sv_ready_restart_after_countdown
 * is set to 1).
 */
void restartAnnouncer_Think() {
	local entity plr;
	local string s;
	if(self.cnt <= 0) { //show the "Begin" message and
		if (cvar("sv_ready_restart_after_countdown")) {
			restart_mapalreadyrestarted = 1;
			reset_map();
		}

		FOR_EACH_REALCLIENT(plr) {
			if(plr.classname == "player") {
				s = strcat(NEWLINES, "^1Begin!");
				centerprint(plr, s);
			}
		}
		sound(world, CHAN_AUTO, "announcer/robotic/begin.wav", 1, ATTN_NONE);

		remove(self);
		return;
	}
	else {
		FOR_EACH_REALCLIENT(plr) {
			if(plr.classname == "player") {
				s = strcat(NEWLINES, "^1Game starts in ", ftos(self.cnt), " seconds");
				centerprint(plr, s);
			}
		}

		if(self.cnt <= 3) {
			sound(world, CHAN_AUTO, strcat("announcer/robotic/", ftos(self.cnt), ".ogg"), 1, ATTN_NONE);
		}
		self.nextthink = time + 1;
		self.cnt -= 1;
	}
}
