entity nagger;
float readycount;
float Nagger_SendEntity(entity to, float sendflags)
{
	float nags, i, f, b;
	entity e;
	WriteByte(MSG_ENTITY, ENT_CLIENT_NAGGER);

	nags = 0;
	if(readycount)
	{
		nags |= 1;
		if(to.ready == 0)
			nags |= 2;
	}
	if(votecalled)
	{
		nags |= 4;
		if(to.vote_vote == 0)
			nags |= 8;
	}
	if(inWarmupStage)
		nags |= 16;

	if(sendflags & 128)
		nags |= 128;

	WriteByte(MSG_ENTITY, nags);

	if(nags & 128)
	{
		WriteString(MSG_ENTITY, votecalledvote_display);
	}

	if(nags & 1)
	{
		for(i = 1; i <= maxclients; i += 8)
		{
			for(f = 0, e = edict_num(i), b = 1; b < 256; b *= 2, e = nextent(e))
				if(clienttype(e) != CLIENTTYPE_REAL || e.ready)
					f |= b;
			WriteByte(MSG_ENTITY, f);
		}
	}

	return TRUE;
}
void Nagger_Init()
{
	Net_LinkEntity(nagger = spawn(), FALSE, 0, Nagger_SendEntity);
}
void Nagger_VoteChanged()
{
	if(nagger)
		nagger.SendFlags |= 128;
}
void Nagger_VoteCountChanged()
{
	if(nagger)
		nagger.SendFlags |= 1;
}
void Nagger_ReadyCounted()
{
	if(nagger)
		nagger.SendFlags |= 1;
}

void ReadyCount();
string MapVote_Suggest(string m);

entity GetPlayer(string name)
{
	float num;
	entity e;
	string ns;

	if(substring(name, 0, 1) == "#") {
		num = stof(substring(name, 1, 999));
		if(num >= 1 && num <= maxclients) {
			for((e = world); num > 0; --num, (e = nextent(e)))
				;
			//if(clienttype(e) == CLIENTTYPE_REAL)
			if(e.classname == "player")
				return e;
		}
	} else {
		ns = strdecolorize(name);
		FOR_EACH_REALPLAYER(e) {
			if(!strcasecmp(strdecolorize(e.netname), ns)) {
				return e;
			}
		}
	}
	return world;
}

//float ctf_clientcommand();
float readyrestart_happened;
.float lms_spectate_warning;
void spawnfunc_func_breakable();

.float cmd_floodtime;
.float cmd_floodcount;
float cmd_floodcheck()
{
	if (timeoutStatus != 2)
	{
		if(time == self.cmd_floodtime)
		{
			self.cmd_floodcount += 1;
			if(self.cmd_floodcount > 8)
				return TRUE;
		}
		else
		{
			self.cmd_floodtime = time;
			self.cmd_floodcount = 1;
		}
	}
	return FALSE;
}

void SV_ParseClientCommand(string s) {
	string cmd;
	float tokens;
	float i;
	entity e;

	tokens = tokenize_console(s);

	cmd = argv(0);
	if(cmd != "reportcvar")
	if(cmd != "sentcvar")
	if(cmd != "pause")
	if(cmd != "prespawn")
	if(cmd != "spawn")
	if(cmd != "begin")
	{
		if(cmd_floodcheck())
			return;
	}

	if(GameCommand_Vote(s, self)) {
		return;
	} else if(GameCommand_MapVote(argv(0))) {
		return;
	} else if(cmd == "autoswitch") {
		// be backwards compatible with older clients (enabled)
		self.autoswitch = ("0" != argv(1));
		local string autoswitchmsg;
		if (self.autoswitch) {
			autoswitchmsg = "on";
		} else {
			autoswitchmsg = "off";
		}
		sprint(self, strcat("^1autoswitch turned ", autoswitchmsg, "\n"));
	} else if(cmd == "clientversion") {
		if not(self.flags & FL_CLIENT)
			return;
		if (argv(1) == "$gameversion") {
			//versionmsg = "^1client is too old to get versioninfo.\nUPDATE!!! (http://www.alientrap.org/nexuiz/)^8";
			// either that or someone wants to be funny
			self.version = 1;
		} else {
			self.version = stof(argv(1));
		}
		if(self.version != cvar("gameversion"))
		{
			self.classname = "observer";
			self.version_mismatch = 1;
			PutClientInServer();
		} else if(cvar("g_campaign") || cvar("g_balance_teams") || cvar("g_balance_teams_force")) {
			//JoinBestTeam(self, FALSE, TRUE);
		} else if(teams_matter && !cvar("sv_spectate")) {
			self.classname = "observer";
			stuffcmd(self,"menu_showteamselect\n");
		}
	} else if(cmd == "reportcvar") { // old system
		if(substring(argv(2), 0, 1) == "$") // undefined cvar: use the default value on the server then
		{
			s = strcat(substring(s, argv_start_index(0), argv_end_index(1) - argv_start_index(0)), " \"", cvar_defstring(argv(1)), "\"");
			tokens = tokenize_console(s);
		}
		GetCvars(1);
#ifdef UID
	} else if(cmd == "uid") {
		if not(self.uid)
		{
			self.uid = strzone(argv(1));
			self.uid_kicktime = 0;
			print("Client ", etos(self), " has UID ", self.uid, "\n");
			Ban_MaybeEnforceBan(self);
		}
#endif
	} else if(cmd == "sentcvar") { // new system
		if(tokens == 2) // undefined cvar: use the default value on the server then
		{
			s = strcat(substring(s, argv_start_index(0), argv_end_index(1) - argv_start_index(0)), " \"", cvar_defstring(argv(1)), "\"");
			tokens = tokenize_console(s);
		}
		GetCvars(1);
	} else if(cmd == "spectate") {
		if(cmd_floodcheck())
			return;
		if not(self.flags & FL_CLIENT)
			return;
		if(g_arena)
			return;
		if(g_lms)
		{
			if(self.lms_spectate_warning)
			{
				// mark player as spectator
				PlayerScore_Add(self, SP_LMS_RANK, 666 - PlayerScore_Add(self, SP_LMS_RANK, 0));
			}
			else
			{
				self.lms_spectate_warning = 1;
				sprint(self, "WARNING: you won't be able to enter the game again after spectating in LMS. Use the same command again to spectate anyway.\n");
				return;
			}
		}
		if(self.classname == "player" && cvar("sv_spectate") == 1) {
			if(self.flagcarried)
				DropFlag(self.flagcarried, world, world);
			if(self.ballcarried)
				DropBall(self.ballcarried, self.origin, self.velocity);
			kh_Key_DropAll(self, TRUE);
			WaypointSprite_PlayerDead();
			self.classname = "observer";
			if(g_ca)
				self.caplayer = 0;
			if(blockSpectators)
				sprint(self, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
			PutClientInServer();
		}
	} else if(cmd == "join") {
		if not(self.flags & FL_CLIENT)
			return;
		if(!g_arena)
		if (self.classname != "player" && !lockteams)
		{
			if(isJoinAllowed()) {
				self.classname = "player";
				if(g_ca)
					self.caplayer = 1;
				PlayerScore_Clear(self);
				bprint ("^4", self.netname, "^4 is playing now\n");
				self.stat_count = WEP_LAST;
				PutClientInServer();
				if(cvar("g_campaign"))
					campaign_bots_may_start = 1;
			}
			else {
				//player may not join because of g_maxplayers is set
				centerprint_atprio(self, CENTERPRIO_MAPVOTE, PREVENT_JOIN_TEXT);
			}
		}
	} else if( cmd == "selectteam" ) {
		if not(self.flags & FL_CLIENT)
			return;
		if( !teams_matter ) {
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
	} else if(cmd == "ready") {
		if not(self.flags & FL_CLIENT)
			return;

		if((inWarmupStage && 0 >= g_warmup_limit) // with unlimited warmup players have to be able to restart
		   || cvar("sv_ready_restart") || g_race_qualifying == 2)
		{
			if(!readyrestart_happened || cvar("sv_ready_restart_repeatable"))
			{
				if (self.ready) // toggle
				{
					self.ready = FALSE;
					bprint(self.netname, "^2 is ^1NOT^2 ready\n");
				}
				else
				{
					self.ready = TRUE;
					bprint(self.netname, "^2 is ready\n");
				}

				// cannot reset the game while a timeout is active!
				if(!timeoutStatus)
					ReadyCount();
			} else {
				sprint(self, "^1Game has already been restarted\n");
			}
		}
	} else if(cmd == "maplist") {
		sprint(self, maplist_reply);
	} else if(cmd == "lsmaps") {
		sprint(self, lsmaps_reply);
	} else if(cmd == "lsnewmaps") {
		sprint(self, lsnewmaps_reply);
	} else if(cmd == "records") {
		for(i = 0; i < 10; ++i)
			sprint(self, records_reply[i]);
	} else if(cmd == "rankings") {
		sprint(self, rankings_reply);
	} else if(cmd == "voice") {
		if(tokens >= 3)
			VoiceMessage(argv(1), substring(s, argv_start_index(2), argv_end_index(-1) - argv_start_index(2)));
		else
			VoiceMessage(argv(1), "");
	} else if(cmd == "say") {
		if(tokens >= 2)
			Say(self, FALSE, world, substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		//clientcommand(self, formatmessage(s));
	} else if(cmd == "say_team") {
		if(tokens >= 2)
			Say(self, TRUE, world, substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		//clientcommand(self, formatmessage(s));
	} else if(cmd == "tell") {
		e = GetCommandPlayerSlotTargetFromTokenizedCommand(tokens, 1);
		if(e && tokens > ParseCommandPlayerSlotTarget_firsttoken)
		{
			Say(self, FALSE, e, substring(s, argv_start_index(ParseCommandPlayerSlotTarget_firsttoken), argv_end_index(-1) - argv_start_index(ParseCommandPlayerSlotTarget_firsttoken)), TRUE);
		}
		else
		{
			if(tokens > ParseCommandPlayerSlotTarget_firsttoken)
				trigger_magicear_processmessage_forallears(self, -1, world, substring(s, argv_start_index(ParseCommandPlayerSlotTarget_firsttoken), argv_end_index(-1) - argv_start_index(ParseCommandPlayerSlotTarget_firsttoken)));
			sprint(self, "ERROR: usage: tell # playerid text...\n");
		}
		//clientcommand(self, formatmessage(s));
	} else if(cmd == "info") {
		cmd = cvar_string_builtin(strcat("sv_info_", argv(1))); // This needed fixed for the cvar check
		if(cmd == "")
			sprint(self, "ERROR: unsupported info command\n");
		else
			wordwrap_sprint(cmd, 1111);
	} else if(cmd == "suggestmap") {
		sprint(self, strcat(MapVote_Suggest(argv(1)), "\n"));
	} else if(cmd == "timeout") {
		if not(self.flags & FL_CLIENT)
			return;
		if(cvar("sv_timeout")) {
			if(self.classname == "player") {
				if(votecalled)
					sprint(self, "^7Error: you can not call a timeout while a vote is active!\n");
				else
					evaluateTimeout();
			}
			else
				sprint(self, "^7Error: only players can call a timeout!\n");
		}
	} else if(cmd == "timein") {
		if not(self.flags & FL_CLIENT)
			return;
		if(cvar("sv_timeout")) {
			evaluateTimein();
		}
	} else if(cmd == "teamstatus") {
		Score_NicePrint(self);
	} else if(cmd == "cvar_changes") {
		sprint(self, cvar_changes);
	} else if(CheatCommand(tokens)) {
	} else {
		//if(ctf_clientcommand())
		//	return;
		// grep for Cmd_AddCommand_WithClientCommand to find them all
		if(cmd != "status")
		//if(cmd != "say") // handled above
		//if(cmd != "say_team") // handled above
		if(cmd != "kill")
		if(cmd != "pause")
		if(cmd != "ping")
		if(cmd != "name")
		if(cmd != "color")
		if(cmd != "rate")
		if(cmd != "pmodel")
		if(cmd != "playermodel")
		if(cmd != "playerskin")
		if(cmd != "prespawn")
		if(cmd != "spawn")
		if(cmd != "begin")
		if(cmd != "pings")
		if(cmd != "sv_startdownload")
		if(cmd != "download")
		{
			print("WARNING: Invalid clientcommand by ", self.netname, ": ", s, "\n");
			return;
		}

		if(self.jointime > 0 && time > self.jointime + 10 && time > self.nickspamtime) // allow any changes in the first 10 seconds since joining
		if(cmd == "name" || cmd == "playermodel") // TODO also playerskin and color?
		{
			if(self.nickspamtime == 0 || time > self.nickspamtime + cvar("g_nick_flood_timeout"))
				// good, no serious flood
				self.nickspamcount = 1;
			else
				self.nickspamcount += 1;
			self.nickspamtime = time + cvar("g_nick_flood_penalty");

			if (timeoutStatus == 2) //when game is paused, no flood protection
				self.nickspamcount = self.nickspamtime = 0;
		}

		clientcommand(self,s);
	}
}

void ReadyRestartForce()
{
	local entity e;

	bprint("^1Server is restarting...\n");

	VoteReset();

	// clear overtime
	if (checkrules_overtimesadded > 0 && g_race_qualifying != 2) {
		//we have to decrease timelimit to its original value again!!
		float newTL;
		newTL = cvar("timelimit");
		newTL -= checkrules_overtimesadded * cvar("timelimit_overtime");
		cvar_set("timelimit", ftos(newTL));
	}

	checkrules_suddendeathend = checkrules_overtimesadded = checkrules_suddendeathwarning = 0;


	readyrestart_happened = 1;
	game_starttime = time;
	if(!g_ca)
		game_starttime += RESTART_COUNTDOWN;
	restart_mapalreadyrestarted = 0; //reset this var, needed when cvar sv_ready_restart_repeatable is in use

	inWarmupStage = 0; //once the game is restarted the game is in match stage

	//reset the .ready status of all players (also spectators)
	FOR_EACH_CLIENTSLOT(e)
		e.ready = 0;
	readycount = 0;
	Nagger_ReadyCounted(); // NOTE: this causes a resend of that entity, and will also turn off warmup state on the client

	if(cvar("teamplay_lockonrestart") && teams_matter) {
		lockteams = 1;
		bprint("^1The teams are now locked.\n");
	}

	//initiate the restart-countdown-announcer entity
	if(cvar("sv_ready_restart_after_countdown"))
	{
		restartTimer = spawn();
		restartTimer.think = restartTimer_Think;
		restartTimer.nextthink = game_starttime;
	}

	//after a restart every players number of allowed timeouts gets reset, too
	if(cvar("sv_timeout"))
	{
		FOR_EACH_REALPLAYER(e)
			e.allowedTimeouts = cvar("sv_timeout_number");
	}

	//reset map immediately if this cvar is not set
	if (!cvar("sv_ready_restart_after_countdown"))
		reset_map(TRUE);

	if(cvar("sv_eventlog"))
		GameLogEcho(":restart");
}

void ReadyRestart()
{
	// no arena, assault support yet...
	if(g_arena | g_assault | gameover | intermission_running | race_completing)
		localcmd("restart\n");
	else
		localcmd("\nsv_hook_gamerestart;");

	ReadyRestartForce();

	// reset ALL scores, but only do that at the beginning
	//of the countdown if sv_ready_restart_after_countdown is off!
	//Otherwise scores could be manipulated during the countdown!
	if (!cvar("sv_ready_restart_after_countdown"))
		Score_ClearAll();
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

	r = p = 0;

	FOR_EACH_REALPLAYER(e)
	{
		p += 1;
		if(e.ready)
			r += 1;
	}

	readycount = r;

	Nagger_ReadyCounted();

	if(r) // at least one is ready
	if(r == p) // and, everyone is ready
		ReadyRestart();
}

/**
 * Restarts the map after the countdown is over (and cvar sv_ready_restart_after_countdown
 * is set)
 */
void restartTimer_Think() {
	restart_mapalreadyrestarted = 1;
	reset_map(TRUE);
	Score_ClearAll();
	remove(self);
	return;
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
void evaluateTimeout() {
	if (inWarmupStage && !g_warmup_allow_timeout)
		return sprint(self, "^7Error: You can not call a timeout in warmup-stage!\n");
	if (time < game_starttime )
		return sprint(self, "^7Error: You can not call a timeout while the map is being restarted!\n");
	if (timeoutStatus != 2) {
		//if the map uses a timelimit make sure that timeout cannot be called right before the map ends
		if (cvar("timelimit")) {
			//a timelimit was used
			local float myTl;
			myTl = cvar("timelimit");

			local float lastPossibleTimeout;
			lastPossibleTimeout = (myTl*60) - cvar("sv_timeout_leadtime") - 1;

			if (lastPossibleTimeout < time - game_starttime)
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
	Announce("timeoutcalled");
}

/**
 * Checks whether a player is allowed to resume the game. If he is allowed to do it,
 * and the lead time for the timeout is still active, this countdown just will be aborted (the
 * game will never be paused). Otherwise the remainingTimeoutTime will be set to the corresponding
 * value of the cvar sv_timeout_resumetime.
 *
 * This function is called when a player issues the resumegame command.
 */
void evaluateTimein() {
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
