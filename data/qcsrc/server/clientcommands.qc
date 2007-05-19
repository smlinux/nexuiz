void ReadyCount();
float ValidateMap(string vote);
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

	colorstr = Team_ColorCode(source.team);

	if(!teams_matter)
		teamsay = FALSE;

	if(intermission_running)
		teamsay = FALSE;

	if(source.classname != "player") // observers can't
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
		bprint(msgstr);
		//ServerConsoleEcho(substring(msgstr, 1, strlen(msgstr) - 2), TRUE);
	}

	strunzone(msgstr);
}

void SV_ParseClientCommand(string s) {
	local string cmd;

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
			sprint(self, "^7You can use voting with \"^2cmd vote help^7\" \"^2cmd vote status^7\" \"^2cmd vote call ^3COMMAND ARGUMENTS^7\" \"^2cmd vote stop^7\" \"^2cmd vote master^7\" \"^2cmd vote do ^3COMMAND ARGUMENTS^7\" \"^2cmd vote yes^7\" \"^2cmd vote no^7\".\n");
			sprint(self, "^7Or if your version is up to date you can use these aliases \"^2vhelp^7\" \"^2vstatus^7\" \"^2vcall ^3COMMAND ARGUMENTS^7\" \"^2vstop^7\" \"^2vmaster^7\" \"^2vdo ^3COMMAND ARGUMENTS^7\" \"^2vyes^7\" \"^2vno^7\".\n");
			sprint(self, "^7\"^2help^7\" shows this info.\n");
			sprint(self, "^7\"^2status^7\" shows if there is a vote called and who called it.\n");
			sprint(self, strcat("^7\"^2call^7\" is used to call a vote. See the list of allowed commands.", vcalldis, "^7\n"));
			sprint(self, "^7\"^2stop^7\" can be used by the vote caller or an admin to stop a vote and maybe correct it.\n");
			sprint(self, strcat("^7\"^2master^7\" is used to call a vote to become a master.", vmasterdis, "^7\n"));
			sprint(self, "^7\"^2do^7\" If you are a master you can execute a command without a vote. See the list of allowed commands.\n");
			sprint(self, "^7\"^2yes^7\" and \"^2no^7\" to make your vote.\n");
			sprint(self, "^7If more then 50% of the players vote yes the vote is accepted.\n");
			sprint(self, "^7If more then 50% of the players vote no the vote is rejected.\n");
			sprint(self, strcat("^7The vote will end after ", cvar_string("sv_vote_timeout"), "^7 seconds.\n"));
			sprint(self, "^7You can call a vote for or execute these commands:\n");
			sprint(self, strcat("^3", cvar_string("sv_vote_commands"), "^7 and maybe further ^3arguments^7\n"));
		} else if(argv(1) == "status") {
			if(votecalled) {
				sprint(self, strcat("^7Vote for \"^1", votecalledvote, "^7\" called by \"^7", votecaller.netname, "^7\".\n"));
			} else {
				sprint(self, "^1No vote called.\n");
			}
		} else if(argv(1) == "call") {
			if(cvar("sv_vote_call")) {
				if(votecalled) {
					sprint(self, "^1There is already a vote called.\n");
				} else {
					local string vote;
					vote = VoteParse();
					if(vote == "") {
						sprint(self, "^1Your vote is empty. See help for more info.\n");
					} else if(time < self.vote_next) {
						sprint(self, strcat("^1You have to wait ^2", ftos(self.vote_next - time), "^1 seconds before you can again call a vote.\n"));
					} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
						if(!ValidateMap(vote))
							return;
						votecalled = TRUE;
						votecalledmaster = FALSE;
						// remap chmap to gotomap (forces intermission)
						if(strlen(vote) >= 6)
							if(substring(vote, 0, 6) == "chmap ")
								vote = strcat("gotomap ", substring(vote, 6, strlen(vote) - 6));
						votecalledvote = strzone(vote);
						votecaller = self; // remember who called the vote
						votefinished = time + cvar("sv_vote_timeout");
						votecaller.vote_vote = 1; // of course you vote yes
						votecaller.vote_next = time + cvar("sv_vote_wait");
						bprint("\{1}^2* ^3", votecaller.netname, "^2 calls a vote for ^1", votecalledvote, "\n");
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
					votecalledvote = strzone("^3master");
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
				local string dovote;
				dovote = VoteParse();
				if(dovote == "") {
					sprint(self, "^1Your command was empty. See help for more info.\n");
				} else if(VoteAllowed(strcat1(argv(2)))) { // strcat seems to be necessary
					if(!ValidateMap(dovote))
						return;
					// remap chmap to gotomap (forces intermission)
					if(strlen(dovote) >= 6)
						if(substring(dovote, 0, 6) == "chmap ")
							vote = strcat("gotomap ", substring(dovote, 6, strlen(dovote) - 6));
					bprint("\{1}^2* ^3", self.netname, "^2 used his ^3master^2 status to do \"^2", dovote, "^2\".\n");
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
		} else if(cvar("g_campaign") || cvar("g_balance_teams")) {
			//JoinBestTeam(self, 0);
		} else if(cvar("teamplay") && !cvar("sv_spectate")) {
			self.classname = "observer";
			stuffcmd(self,"menu_showteamselect\n");
		}
	} else if(argv(0) == "reportcvar") { // old system
		GetCvars(1);
	} else if(argv(0) == "sentcvar") { // new system
		GetCvars(1);
	} else if(argv(0) == "spectate") {
		if(cvar("g_lms") || cvar("g_arena"))
			return; // don't allow spectating in lms, unless player runs out of lives
		if(self.classname == "player" && cvar("sv_spectate") == 1) {
			if(self.flagcarried)
				DropFlag(self.flagcarried);
			kh_Key_DropAll(self, TRUE);
			WaypointSprite_PlayerDead();
			DistributeFragsAmongTeam(self, self.team, 1.0);
			self.classname = "observer";
			PutClientInServer();
		}
	} else if(argv(0) == "join") {
		if(!cvar("g_arena"))
		if (self.classname != "player")
		{
			self.classname = "player";
			self.frags = 0;
			bprint ("^4", self.netname, "^4 is playing now\n");
			PutClientInServer();
		}
	} else if( argv(0) == "selectteam" ) {
		if( !cvar("teamplay") ) {
			sprint( self, "selecteam can only be used in teamgames\n");
		} else if(cvar("g_campaign")) {
			//JoinBestTeam(self, 0);
		} else if( argv(1) == "none" ) {
			SV_ChangeTeam( 0 );
		} else if( argv(1) == "red" ) {
			SV_ChangeTeam( COLOR_TEAM1 - 1 );
		} else if( argv(1) == "blue" ) {
			SV_ChangeTeam( COLOR_TEAM2 - 1 );
		} else if( argv(1) == "yellow" ) {
			SV_ChangeTeam( COLOR_TEAM3 - 1 );
		} else if( argv(1) == "pink" ) {
			SV_ChangeTeam( COLOR_TEAM4 - 1 );
		} else if( argv(1) == "auto" ) {
			self.team = -1;
			JoinBestTeam( self, 0 );
		} else {
			sprint( self, strcat( "selectteam none/red/blue/yellow/pink/auto - \"", argv(1), "\" not recognised\n" ) );
		}
	} else if(argv(0) == "ready") {
		if(cvar("sv_ready_restart"))
		{
			self.ready = TRUE;
			bprint(self.netname, "^2 is ready\n");
			ReadyCount();
		}
	} else if(argv(0) == "maplist") {
		local float i, n;
		local string col;
		n = tokenize(cvar_string("g_maplist"));
		sprint(self, "^7Maps in list: ");
		for(i = 0; i < n; ++i)
		{
			if(math_mod(i, 2))
				col = "^2";
			else
				col = "^3";
			sprint(self, strcat(col, argv(i), " "));
		}
		sprint(self, "\n");
	} else if(argv(0) == "teamstatus") {
		PrintScoreboard(self);
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

float ValidateMap(string vote)
{
	string ext;
	
	tokenize(vote);
	if(argv(0) == "map" || argv(0) == "changelevel")
		ext = ".bsp";
	else if(argv(0) == "chmap")
		ext = ".mapcfg";
	else if(argv(0) == "gotomap")
		ext = ".mapcfg";
	else
		return TRUE;

	if(!cvar("sv_vote_change_gametype"))
		if(!IsSameGametype(argv(1)))
		{
			sprint(self, "This server does not allow changing the game type by map votes.\n");
			return FALSE;
		}

	if(!TryFile(strcat("maps/", argv(1), ext)))
	{
		sprint(self, strcat("^1Invalid mapname, \"^3", argv(1), "^1\" does not exist on this server.\n"));
		return FALSE;
	}

	return TRUE;
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

	votecalled = FALSE;
	votecalledmaster = FALSE;
	votefinished = 0;
}

void VoteAccept() {
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ^1", votecalledvote, "^2 was accepted\n");
	if(votecalledmaster)
	{
		votecaller.vote_master = 1;
	} else {
		localcmd(strcat(votecalledvote, "\n"));
	}
	votecaller.vote_next = 0; // people like your votes, no wait for next vote
	VoteReset();
}

void VoteReject() {
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ^1", votecalledvote, "^2 was rejected\n");
	VoteReset();
}

void VoteTimeout() {
	bprint("\{1}^2* ^3", votecaller.netname, "^2's vote for ^1", votecalledvote, "^2 timed out\n");
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
			centerprint_atprio(self, CENTERPRIO_VOTE, strcat("^7^3", votecaller.netname, "^2 called a vote for ^1", votecalledvote, "\n\n^2You have not voted yet!\n^2HINT: By default, F1 is yes and F2 is no."));
}

void VoteCount() {
	local float playercount;
	playercount = 0;
	local float yescount;
	yescount = 0;
	local float nocount;
	nocount = 0;
	local entity player;

	FOR_EACH_REALCLIENT(player)
	{
		if(player.vote_vote < 0) {
			nocount++;
		} else if(player.vote_vote > 0) {
			yescount++;
		}
		playercount++;
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
	} else if((playercount / 2) < yescount) { // vote accepted
		VoteAccept();
	} else if((playercount / 2) < nocount) { // vote rejected
		VoteReject();
	} else if(time > votefinished) { // vote timedout
		if(cvar("sv_vote_simple_majority"))
			if(yescount > nocount)
				VoteAccept();
			else if(nocount > yescount)
				VoteReject();
			else
				VoteTimeout();
		else
			VoteTimeout();
	} // else still running
}


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

	if(p && r == p)
	{
		bprint("^1Server is restarting...\n");
		localcmd("restart\n");
	}
}
