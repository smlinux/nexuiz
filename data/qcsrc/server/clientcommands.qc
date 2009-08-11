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
		if(votecalled)
			WriteString(MSG_ENTITY, votecalledvote_display);
		else
			WriteString(MSG_ENTITY, "");
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

float drag_lastcnt;
void DragBox_Think()
{
	if(self.aiment && self.enemy)
	{
		self.origin_x = (self.aiment.origin_x + self.enemy.origin_x) * 0.5;
		self.origin_y = (self.aiment.origin_y + self.enemy.origin_y) * 0.5;
		self.origin_z = (self.aiment.origin_z + self.enemy.origin_z) * 0.5;
		self.maxs_x = fabs(self.aiment.origin_x - self.enemy.origin_x) * 0.5;
		self.maxs_y = fabs(self.aiment.origin_y - self.enemy.origin_y) * 0.5;
		self.maxs_z = fabs(self.aiment.origin_z - self.enemy.origin_z) * 0.5;
		self.mins = -1 * self.maxs;
		setorigin(self, self.origin); setsize(self, self.mins, self.maxs); // link edict
	}

	if(self.cnt == -1) // actually race_place -1
	{
		// show "10 10" for qualifying spawns
		setmodel(self.killindicator, "models/sprites/10.spr32");
		setmodel(self.killindicator.killindicator, "models/sprites/10.spr32");
	}
	else if(self.cnt == -2) // actually race_place 0
	{
		// show "10 0" for loser spawns
		setmodel(self.killindicator, "models/sprites/10.spr32");
		setmodel(self.killindicator.killindicator, "models/sprites/0.spr32");
	}
	else
	{
		setmodel(self.killindicator, strcat("models/sprites/", ftos(mod(self.cnt, 10)), ".spr32"));
		setmodel(self.killindicator.killindicator, strcat("models/sprites/", ftos(floor(self.cnt / 10)), ".spr32"));
	}

	self.nextthink = time;
}

//float ctf_clientcommand();
float readyrestart_happened;
.float lms_spectate_warning;
void spawnfunc_func_breakable();
void SV_ParseClientCommand(string s) {
	string cmd;
	float tokens, f, effectnum;
	vector start, end;
	entity e, oldself;

	tokens = tokenize_console(s);

	if(GameCommand_Vote(s, self)) {
		return;
	} else if(GameCommand_MapVote(argv(0))) {
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
		if not(self.flags & FL_CLIENT)
			return;
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
			self.version_mismatch = 1;
			PutClientInServer();
		} else if(cvar("g_campaign") || cvar("g_balance_teams") || cvar("g_balance_teams_force")) {
			//JoinBestTeam(self, FALSE, TRUE);
		} else if(teams_matter && !cvar("sv_spectate")) {
			self.classname = "observer";
			stuffcmd(self,"menu_showteamselect\n");
		}
	} else if(argv(0) == "reportcvar") { // old system
		if(substring(argv(2), 0, 1) == "$") // undefined cvar: use the default value on the server then
		{
			s = strcat(substring(s, argv_start_index(0), argv_end_index(1) - argv_start_index(0)), " \"", cvar_defstring(argv(1)), "\"");
			tokens = tokenize_console(s);
		}
		GetCvars(1);
	} else if(argv(0) == "sentcvar") { // new system
		if(tokens == 2) // undefined cvar: use the default value on the server then
		{
			s = strcat(substring(s, argv_start_index(0), argv_end_index(1) - argv_start_index(0)), " \"", cvar_defstring(argv(1)), "\"");
			tokens = tokenize_console(s);
		}
		GetCvars(1);
	} else if(argv(0) == "spectate") {
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
			if(blockSpectators)
				sprint(self, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
			PutClientInServer();
		}
	} else if(argv(0) == "join") {
		if not(self.flags & FL_CLIENT)
			return;
		if(!g_arena)
		if (self.classname != "player" && !lockteams)
		{
			if(isJoinAllowed()) {
				self.classname = "player";
				PlayerScore_Clear(self);
				bprint ("^4", self.netname, "^4 is playing now\n");
				PutClientInServer();
				if(cvar("g_campaign"))
					campaign_bots_may_start = 1;
			}
			else {
				//player may not join because of g_maxplayers is set
				centerprint_atprio(self, CENTERPRIO_MAPVOTE, PREVENT_JOIN_TEXT);
			}
		}
	} else if( argv(0) == "selectteam" ) {
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
	} else if(argv(0) == "ready") {
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
	} else if(argv(0) == "maplist") {
		sprint(self, maplist_reply);
	} else if(argv(0) == "lsmaps") {
		sprint(self, lsmaps_reply);
	} else if(argv(0) == "records") {
		sprint(self, records_reply);
	} else if(argv(0) == "voice") {
		if(tokens >= 3)
			VoiceMessage(argv(1), substring(s, argv_start_index(2), argv_end_index(-1) - argv_start_index(2)));
		else
			VoiceMessage(argv(1), "");
	} else if(argv(0) == "say") {
		if(tokens >= 2)
			Say(self, FALSE, world, substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		//clientcommand(self, formatmessage(s));
	} else if(argv(0) == "say_team") {
		if(tokens >= 2)
			Say(self, TRUE, world, substring(s, argv_start_index(1), argv_end_index(-1) - argv_start_index(1)), 1);
		//clientcommand(self, formatmessage(s));
	} else if(argv(0) == "tell") {
		e = GetCommandPlayerSlotTargetFromTokenizedCommand(tokens, 1);
		if(e && tokens > ParseCommandPlayerSlotTarget_firsttoken)
			Say(self, FALSE, e, substring(s, argv_start_index(ParseCommandPlayerSlotTarget_firsttoken), argv_end_index(-1) - argv_start_index(ParseCommandPlayerSlotTarget_firsttoken)), 1);
		else
			sprint(self, "ERROR: usage: tell # playerid text...\n");
		//clientcommand(self, formatmessage(s));
	} else if(argv(0) == "info") {
		cmd = cvar_string(strcat("sv_info_", argv(1)));
		if(cmd == "")
			sprint(self, "ERROR: unsupported info command\n");
		else
			wordwrap_sprint(cmd, 1111);
	} else if(argv(0) == "suggestmap") {
		sprint(self, strcat(MapVote_Suggest(argv(1)), "\n"));
	} else if(argv(0) == "timeout") {
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
	} else if(argv(0) == "timein") {
		if not(self.flags & FL_CLIENT)
			return;
		if(cvar("sv_timeout")) {
			evaluateTimein();
		}
	} else if(argv(0) == "teamstatus") {
		Score_NicePrint(self);
	} else if(argv(0) == "cvar_changes") {
		sprint(self, cvar_changes);
	} else if(argv(0) == "pointparticles") {
		if((sv_cheats || self.maycheat) && tokens == 5)
		{
			// arguments:
			//   effectname
			//   origin (0..1, on crosshair line)
			//   velocity
			//   howmany
			effectnum = particleeffectnum(argv(1));
			f = stof(argv(2));
			start = (1-f) * self.origin + f * self.cursor_trace_endpos;
			end = stov(argv(3));
			f = stof(argv(4));
			pointparticles(effectnum, start, end, f);
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd pointparticles effectname position(0..1) velocityvector multiplier\n");
	} else if(argv(0) == "trailparticles") {
		if((sv_cheats || self.maycheat) && tokens == 2)
		{
			// arguments:
			//   effectname
			effectnum = particleeffectnum(argv(1));
			W_SetupShot(self, FALSE, FALSE, "",0);
			traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
			trailparticles(self, effectnum, w_shotorg, trace_endpos);
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd trailparticles effectname\n");
	} else if(argv(0) == "make") {
		if((sv_cheats || self.maycheat) && tokens == 3)
		{
			// arguments:
			//   modelname mode
			f = stof(argv(2));
			W_SetupShot(self, FALSE, FALSE, "", 0);
			traceline(w_shotorg, w_shotorg + w_shotdir * 2048, MOVE_NORMAL, self);
			if((trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT) || trace_fraction == 1)
			{
				sprint(self, "cannot make stuff there (bad surface)\n");
			}
			else
			{
				oldself = self;
				self = spawn();
				self.model = strzone(argv(1));
				self.mdl = "rocket_explode";
				self.health = 1000;
				self.origin = trace_endpos;
				self.effects = EF_NOMODELFLAGS;
				if(f == 1)
				{
					self.angles = fixedvectoangles2(trace_plane_normal, v_forward);
					self.angles = AnglesTransform_Multiply(self.angles, '-90 0 0'); // so unrotated models work
				}
				spawnfunc_func_breakable();
				// now, is it valid?
				if(f == 0)
				{
					tracebox(self.origin, self.mins, self.maxs, self.origin, MOVE_NORMAL, self);
					if(trace_startsolid)
					{
						sprint(oldself, "cannot make stuff there (no space)\n");
						remove(self);
					}
				}
				self = oldself;
			}
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd make models/... 0/1/2\n");
	} else if(argv(0) == "penalty") {
		if((sv_cheats || self.maycheat) && tokens == 3)
			race_ImposePenaltyTime(self, stof(argv(1)), argv(2));
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd penalty 5.0 AHAHAHAHAHAHAH))\n");
	} else if(argv(0) == "dragbox_spawn") {
		if(sv_cheats || self.maycheat)
		{
			e = spawn();
			e.classname = "dragbox_box";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = -1; // black
			setmodel(e, "null"); // network it
			if(tokens == 4)
				e.cnt = stof(argv(1));
			else
				e.cnt = max(0, drag_lastcnt);

			e.aiment = spawn();
			e.aiment.classname = "dragbox_corner_1";
			e.aiment.owner = e;
			setmodel(e.aiment, "models/marker.md3");
			e.aiment.skin = 0;
			setsize(e.aiment, '0 0 0', '0 0 0');
			if(tokens == 4)
				setorigin(e.aiment, stov(argv(2)));
			else
				setorigin(e.aiment, self.cursor_trace_endpos);

			e.enemy = spawn();
			e.enemy.classname = "dragbox_corner_2";
			e.enemy.owner = e;
			setmodel(e.enemy, "models/marker.md3");
			e.enemy.skin = 1;
			setsize(e.enemy, '0 0 0', '0 0 0');
			end = normalize(self.cursor_trace_start - e.aiment.origin);
			end_x = (end_x > 0) * 2 - 1;
			end_y = (end_y > 0) * 2 - 1;
			end_z = (end_z > 0) * 2 - 1;
			if(tokens == 4)
				setorigin(e.enemy, stov(argv(3)));
			else
				setorigin(e.enemy, e.aiment.origin + 32 * end);

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 -8');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 8');
		}
		else
			sprint(self, "Usage: sv_cheats 1; r_showbboxes 1.5; restart; cmd dragbox_spawn\n");
	} else if(argv(0) == "dragpoint_spawn") {
		if(sv_cheats || self.maycheat)
		{
			e = spawn();
			e.classname = "dragpoint";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = 0; // nothing special
			setmodel(e, "models/marker.md3");
			setsize(e, PL_MIN, PL_MAX);
			e.skin = 2;
			if(tokens == 3)
				e.cnt = stof(argv(1));
			else
				e.cnt = drag_lastcnt;
			if(tokens == 3)
				setorigin(e, stov(argv(2)));
			else
			{
				setorigin(e, self.cursor_trace_endpos + normalize(self.cursor_trace_start - self.cursor_trace_endpos));
				move_out_of_solid(e);
			}

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 40');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 56');
		}
		else
			sprint(self, "Usage: sv_cheats 1; r_showbboxes 1.5; restart; cmd dragbox_spawn\n");
	} else if(argv(0) == "drag_remove") {
		if(sv_cheats || self.maycheat)
		{
			RandomSelection_Init();
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			for(e = world; (e = find(e, classname, "dragpoint")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			if(RandomSelection_chosen_ent)
			{
				remove(RandomSelection_chosen_ent.killindicator.killindicator);
				remove(RandomSelection_chosen_ent.killindicator);
				if(RandomSelection_chosen_ent.aiment)
					remove(RandomSelection_chosen_ent.aiment);
				if(RandomSelection_chosen_ent.enemy)
					remove(RandomSelection_chosen_ent.enemy);
				remove(RandomSelection_chosen_ent);
			}
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_remove\n");
	} else if(argv(0) == "drag_setcnt") {
		if((sv_cheats || self.maycheat) && tokens >= 2)
		{
			RandomSelection_Init();
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			for(e = world; (e = find(e, classname, "dragpoint")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			if(RandomSelection_chosen_ent)
			{
				if(substring(argv(1), 0, 1) == "*")
					RandomSelection_chosen_ent.cnt = drag_lastcnt = RandomSelection_chosen_ent.cnt + stof(substring(argv(1), 1, -1));
				else
					RandomSelection_chosen_ent.cnt = drag_lastcnt = stof(argv(1));
			}
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_setcnt cnt\n");
	} else if(argv(0) == "drag_save") {
		if((sv_cheats || self.maycheat) && tokens >= 2)
		{
			f = fopen(argv(1), FILE_WRITE);
			fputs(f, "cmd drag_clear\n");
			for(e = world; (e = find(e, classname, "dragbox_box")); )
			{
				fputs(f, strcat("cmd dragbox_spawn ", ftos(e.cnt), " \"", vtos(e.aiment.origin), "\" \"", vtos(e.enemy.origin), "\"\n"));
			}
			for(e = world; (e = find(e, classname, "dragpoint")); )
			{
				fputs(f, strcat("cmd dragpoint_spawn ", ftos(e.cnt), " \"", vtos(e.origin), "\"\n"));
			}
			fclose(f);
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
	} else if(argv(0) == "drag_saveraceent") {
		if((sv_cheats || self.maycheat) && tokens >= 2)
		{
			f = fopen(argv(1), FILE_WRITE);
			for(e = world; (e = find(e, classname, "dragbox_box")); )
			{
				fputs(f, "{\n");
				fputs(f, "\"classname\" \"trigger_race_checkpoint\"\n");
				fputs(f, strcat("\"origin\" \"", ftos(e.absmin_x), " ", ftos(e.absmin_y), " ", ftos(e.absmin_z), "\"\n"));
				fputs(f, strcat("\"maxs\" \"", ftos(e.absmax_x - e.absmin_x), " ", ftos(e.absmax_y - e.absmin_y), " ", ftos(e.absmax_z - e.absmin_z), "\"\n"));
				fputs(f, strcat("\"cnt\" \"", ftos(e.cnt), "\"\n"));
				fputs(f, strcat("\"targetname\" \"checkpoint", ftos(e.cnt), "\"\n"));
				fputs(f, "}\n");
			}
			for(e = world; (e = find(e, classname, "dragpoint")); )
			{
				start = '0 0 0';
				effectnum = 0;
				for(oldself = world; (oldself = find(oldself, classname, "dragbox_box")); )
				{
					if(e.cnt <= 0 && oldself.cnt == 0 || e.cnt == oldself.cnt)
					{
						start = start + oldself.origin;
						++effectnum;
					}
				}
				start *= 1 / effectnum;
				fputs(f, "{\n");
				fputs(f, "\"classname\" \"info_player_race\"\n");
				fputs(f, strcat("\"angle\" \"", ftos(vectoyaw(start - e.origin)), "\"\n"));
				fputs(f, strcat("\"origin\" \"", ftos(e.origin_x), " ", ftos(e.origin_y), " ", ftos(e.origin_z), "\"\n"));
				if(e.cnt == -2)
				{
					fputs(f, "\"target\" \"checkpoint0\"\n");
					fputs(f, "\"race_place\" \"0\"\n");
				}
				else if(e.cnt == -1)
				{
					fputs(f, "\"target\" \"checkpoint0\"\n");
					fputs(f, "\"race_place\" \"-1\"\n");
				}
				else
				{
					fputs(f, strcat("\"target\" \"checkpoint", ftos(e.cnt), "\"\n"));
					if(e.cnt == 0)
					{
						// these need race_place
						// counting...
						effectnum = 1;
						for(oldself = world; (oldself = find(oldself, classname, "dragpoint")); )
						if(oldself.cnt == 0)
						{
							if(vlen(oldself.origin - start) < vlen(e.origin - start))
								++effectnum;
							else if(vlen(oldself.origin - start) == vlen(e.origin - start) && num_for_edict(oldself) < num_for_edict(e))
								++effectnum;
						}
						fputs(f, strcat("\"race_place\" \"", ftos(effectnum), "\"\n"));
					}
				}
				fputs(f, "}\n");
			}
			fclose(f);
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
	} else if(argv(0) == "drag_clear") {
		if(sv_cheats || self.maycheat)
		{
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_1")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_2")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragpoint")); )
				remove(e);
			for(e = world; (e = find(e, classname, "drag_digit")); )
				remove(e);
		}
		else
			sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_clear\n");
	} else {
		//if(ctf_clientcommand())
		//	return;
		cmd = argv(0);
		// grep for Cmd_AddCommand_WithClientCommand to find them all
		if(cmd != "status")
		if(cmd != "max")
		if(cmd != "monster")
		if(cmd != "scrag")
		if(cmd != "wraith")
		if(cmd != "gimme")
		if(cmd != "god")
		if(cmd != "notarget")
		if(cmd != "fly")
		if(cmd != "noclip")
		if(cmd != "give")
		//if(cmd != "say") // handled above
		//if(cmd != "say_team") // handled above
		if(cmd != "tell")
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
	game_starttime = time + RESTART_COUNTDOWN;
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
	play2all("announcer/robotic/timeoutcalled.wav");
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
