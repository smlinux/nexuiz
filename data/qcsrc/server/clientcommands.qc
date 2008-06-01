void ReadyCount();
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

void SV_ParseClientCommand(string s) {
	local string cmd;
	local float i;

	tokenize(s);

	if(GameCommand_Vote(s, self)) {
		return;
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
			if(timeoutStatus) {
				return sprint(self, "^1You cannot reset the game while a timeout is active!\n");
			}
			
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
	} else if(argv(0) == "calltimeout") {
		if(cvar("sv_timeout")) {
			if(self.classname == "player") {
				if(votecalled)
					sprint(self, "^7Error: you can not call a timeout while a vote is active!\n");
				else
					evaluateTimeoutCall();
			}
			else
				sprint(self, "^7Error: only players can call a timeout!\n");
		}
	} else if(argv(0) == "resumegame") {
		if(cvar("sv_timeout")) {
			evaluateResumeGame();
		}
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
	
	//after a restart every players number of allowed timeouts gets reset, too
	if(cvar("sv_timeout"))
	{
		FOR_EACH_REALPLAYER(e)
		{
			e.allowedTimeouts = cvar("sv_timeout_number");
		}
	}

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

/**
 * Checks whether the player who calls the timeout is allowed to do so.
 * If so, it initializes the timeout countdown. It also checks whether another
 * timeout was already running at this time and reacts correspondingly.
 *
 * affected globals/fields: .allowedTimeouts, remainingTimeoutTime, remainingLeadTime,
 *                          timeoutInitiator, timeoutStatus, timeoutHandler
 *
 * This function is called when a player issues the calltimeout command.
 */
void evaluateTimeoutCall() {
	if (g_tourney && !tourneyInMatchStage && !cvar("g_tourney_warmup_allow_timeout"))
		return sprint(self, "^7Error: You can not call a timeout in warmup-stage!\n");
	if (time < restart_countdown )
		return sprint(self, "^7Error: You can not call a timeout while the map is being restarted!\n");
	if (timeoutStatus != 2) {
		//if the map uses a timelimit make sure that timeout cannot be called right before the map ends
		if (cvar("timelimit")) {
			//a timelimit was used
			local float myTl;
			if (cvar("timelimit"))
				myTl = cvar("timelimit");
			else
				myTl = timelimit_orig;

			local float lastPossibleTimeout;
			lastPossibleTimeout = (myTl*60) - cvar("sv_timeout_leadtime") - 1;

			if (lastPossibleTimeout < time)
				return sprint(self, "^7Error: It is too late to call a timeout now!\n");
		}
	}
	//player may not call a timeout if he has no calls left
	if (self.allowedTimeouts < 1)
		return sprint(self, "^7Error: You already used all your timeout calls for this map!\n");
	//now all required checks are passed
	self.allowedTimeouts -= 1;
	bprint(self.netname, " ^7called a timeout (", ftos(self.allowedTimeouts), " timeouts left)!\n"); //write a bprint who started the timeout (and how many he has left)
	remainingTimeoutTime = cvar("sv_timeout_length");
	remainingLeadTime = cvar("sv_timeout_leadtime");
	timeoutInitiator = self;
	if (timeoutStatus == 0) { //if another timeout was already active, don't change its status (which was 1 or 2) to 1, only change it to 1 if no timeout was active yet
		timeoutStatus = 1;
		//create the timeout indicator which centerprints the information to all players and takes care of pausing/unpausing
		timeoutHandler = spawn();
		timeoutHandler.think = timeoutHandler_Think;
	}
	timeoutHandler.nextthink = time; //always let the entity think asap

	//inform all connected clients about the timeout call
	sound(world, CHAN_AUTO, "announcer/robotic/timeoutcalled.wav", 1, ATTN_NONE);
}

/**
 * Checks whether a player is allowed to resume the game. If he is allowed to do it,
 * and the lead time for the timeout is still active, this countdown just will be aborted (the
 * game will never be paused). Otherwise the remainingTimeoutTime will be set to the corresponding
 * value of the cvar sv_timeout_resumetime.
 *
 * This function is called when a player issues the resumegame command.
 */
void evaluateResumeGame() {
	if (!timeoutStatus)
		return sprint(self, "^7Error: There is no active timeout which could be aborted!\n");
	if (self != timeoutInitiator)
		return sprint(self, "^7Error: You may not abort the active timeout. Only the player who called it can do that!\n");
	if (timeoutStatus == 1) {
		remainingTimeoutTime = timeoutStatus = 0;
		timeoutHandler.nextthink = time; //timeoutHandler has to take care of it immediately
		bprint(strcat("^7The timeout was aborted by ", self.netname, " !\n"));
	}
	else if (timeoutStatus == 2) {
		//only shorten the remainingTimeoutTime if it makes sense
		if( remainingTimeoutTime > (cvar("sv_timeout_resumetime") + 1) ) {
			bprint(strcat("^1Attention: ^7", self.netname, " resumed the game! Prepare for battle!\n"));
			remainingTimeoutTime = cvar("sv_timeout_resumetime");
			timeoutHandler.nextthink = time; //timeoutHandler has to take care of it immediately
		}
		else
			sprint(self, "^7Error: Your resumegame call was discarded!\n");

	}
}
