float maxspawned;
float numspawned;
float arena_roundbased;
.float spawned;
.entity spawnqueue_next;
.entity spawnqueue_prev;
.float spawnqueue_in;
entity spawnqueue_first;
entity spawnqueue_last;
entity champion;
float warmup;
float allowed_to_spawn;
float player_cnt;
.float caplayer;

void PutObserverInServer();
void PutClientInServer();
void(entity e) ReturnFlag;
void dom_controlpoint_setup();
void onslaught_generator_reset();
void onslaught_controlpoint_reset();
void func_breakable_reset();
void assault_objective_reset();
void target_assault_roundend_reset();

/**
 * Resets the state of all clients, items, flags, runes, keys, weapons, waypoints, ... of the map.
 * Sets the 'warmup' global variable.
 */
void reset_map(float dorespawn)
{
	entity oldself;
	oldself = self;

	if(g_arena && cvar("g_arena_warmup"))
		warmup = time + cvar("g_arena_warmup");
	else if(g_ca) {
		warmup = time + cvar("g_ca_warmup");
		allowed_to_spawn = 1;
	}

	lms_lowest_lives = 999;
	lms_next_place = player_count;

	race_ReadyRestart();
	
	for(self = world; (self = nextent(self)); )
	if(clienttype(self) == CLIENTTYPE_NOTACLIENT)
	{
		if(self.reset)
		{
			self.reset();
			continue;
		}

		if(self.team_saved)
			self.team = self.team_saved;

		if(self.flags & FL_PROJECTILE) // remove any projectiles left
		{
			stopsound(self, CHAN_PAIN);
			remove(self);
		}
	}

	// Waypoints and assault start come LAST
	for(self = world; (self = nextent(self)); )
	if(clienttype(self) == CLIENTTYPE_NOTACLIENT)
	{
		if(self.reset2)
		{
			self.reset2();
			continue;
		}
	}

	// Moving the player reset code here since the player-reset depends
	// on spawnpoint entities which have to be reset first --blub
	if(dorespawn)
	FOR_EACH_CLIENT(self) {
		if(self.flags & FL_CLIENT)				// reset all players
		{
			if(g_arena)
			{
				if(self.spawned)
					PutClientInServer();
				else
					PutObserverInServer();
			}
			else if(g_ca && self.caplayer) {
				self.classname = "player";
				PutClientInServer();
			}
			else
			{
				/*
				only reset players if a restart countdown is active
				this can either be due to cvar sv_ready_restart_after_countdown having set
				restart_mapalreadyrestarted to 1 after the countdown ended or when
				sv_ready_restart_after_countdown is not used and countdown is still running
				*/
				if (restart_mapalreadyrestarted || (time < game_starttime))
				{
					//NEW: changed behaviour so that it prevents that previous spectators/observers suddenly spawn as players
					if (self.classname == "player") {
						//PlayerScore_Clear(self);
						if(g_lms)
							PlayerScore_Add(self, SP_LMS_LIVES, LMS_NewPlayerLives());
						self.killcount = 0;
						//stop the player from moving so that he stands still once he gets respawned
						self.velocity = '0 0 0';
						self.avelocity = '0 0 0';
						self.movement = '0 0 0';
						PutClientInServer();
					}
				}
			}
		}
	}

	if(g_keyhunt)
		kh_Controller_SetThink(cvar("g_balance_keyhunt_delay_round")+(game_starttime - time), "", kh_StartRound);

	if(g_arena || g_ca)
	if(champion && champion.classname == "player" && player_cnt > 1)
		UpdateFrags(champion, +1);

	self = oldself;
}

void Spawnqueue_Insert(entity e)
{
	if(e.spawnqueue_in)
		return;
	dprint(strcat("Into queue: ", e.netname, "\n"));
	e.spawnqueue_in = TRUE;
	e.spawnqueue_prev = spawnqueue_last;
	e.spawnqueue_next = world;
	if(spawnqueue_last)
		spawnqueue_last.spawnqueue_next = e;
	spawnqueue_last = e;
	if(!spawnqueue_first)
		spawnqueue_first = e;
}

void Spawnqueue_Remove(entity e)
{
	if(!e.spawnqueue_in)
		return;
	dprint(strcat("Out of queue: ", e.netname, "\n"));
	e.spawnqueue_in = FALSE;
	if(e == spawnqueue_first)
		spawnqueue_first = e.spawnqueue_next;
	if(e == spawnqueue_last)
		spawnqueue_last = e.spawnqueue_prev;
	if(e.spawnqueue_prev)
		e.spawnqueue_prev.spawnqueue_next = e.spawnqueue_next;
	if(e.spawnqueue_next)
		e.spawnqueue_next.spawnqueue_prev = e.spawnqueue_prev;
	e.spawnqueue_next = world;
	e.spawnqueue_prev = world;
}

void Spawnqueue_Unmark(entity e)
{
	if(!e.spawned)
		return;
	e.spawned = FALSE;
	numspawned = numspawned - 1;
}

void Spawnqueue_Mark(entity e)
{
	if(e.spawned)
		return;
	e.spawned = TRUE;
	numspawned = numspawned + 1;
}

/**
 * If roundbased arena game mode is active, it centerprints the texts for the
 * player when player is waiting for the countdown to finish.
 * Blocks the players movement while countdown is active.
 * Unblocks the player once the countdown is over.
 * 
 * Called in PlayerPostThink()
 */
float roundStartTime_prev; // prevent networkspam
void Arena_Warmup()
{
	float f;
	string msg;

	if((!g_arena && !g_ca) || (g_arena && !arena_roundbased) || (time < game_starttime))
		return;

	f = floor(warmup - time + 1);

	allowed_to_spawn = 0;

	if(g_ca && (player_cnt < 2 || inWarmupStage))
		allowed_to_spawn = 1;

	msg = NEWLINES;
	if(time < warmup && !inWarmupStage)
	{
		if (g_ca)
			allowed_to_spawn = 1;
		if(champion && g_arena)
			msg = strcat("The Champion is ", champion.netname, "^7\n");
			//centerprint(self, strcat(msg, "The Champion is ", champion.netname, "^7\n"));

		if(f != roundStartTime_prev) {
			msg = strcat(msg, "Round will start in ", ftos(f),"\n");
			//centerprint(self, strcat("Round will start in ", ftos(f),"\n"));
			roundStartTime_prev = f;
			if(f == 5)
				Announce("prepareforbattle");
			else if(f == 3)
				Announce("3");
			else if(f == 2)
				Announce("2");
			else if(f == 1)
				Announce("1");

			centerprint(self, msg);
		}

		if (g_arena) {
			if(self.spawned && self.classname == "player")
				self.movetype = MOVETYPE_NONE;

			self.velocity = '0 0 0';
			self.avelocity = '0 0 0';
			self.movement = '0 0 0';
			//self.fixangle = TRUE;
		}
	}

	else if(f > -1 && f != roundStartTime_prev)
	{
		roundStartTime_prev = f;
		Announce("begin");
		centerprint(self, "^1Begin!\n");	

		if(g_ca) {
			player_cnt = 0;

			FOR_EACH_CLIENT(self) {
			if (self.classname == "player")
				player_cnt += 1;
			}		
		}
	}

	if(self.classname == "player" && self.health > 0)
		self.movetype = MOVETYPE_WALK;
}

float next_round;
/**
 * This function finds out whether an arena round is over 1 player is left.
 * It determines the last player who's still alive and saves it's entity reference
 * in the global variable 'champion'. Then the new enemy/enemies are put into the server.
 * 
 * Gets called in StartFrame()
 */
void Spawnqueue_Check()
{
	if(time < warmup + 1 || inWarmupStage)
		return;

	if(g_ca) {
		// check the amount of spawned players in each team
		float redspawned, bluespawned;
		FOR_EACH_CLIENT(self) {
			if (self.classname == "player") {
				if (self.team == COLOR_TEAM1) redspawned += 1;
				else if (self.team == COLOR_TEAM2) bluespawned += 1;
			}
		}

		if(player_cnt < 2 && (redspawned && bluespawned)) {
			reset_map(TRUE);
		}
		else if(player_cnt < 2) {
			FOR_EACH_CLIENT(self) 
			if(self.classname == "player")
				centerprint(self, strcat("^1Need at least 2 players to play CA", "^7\n"));

			allowed_to_spawn = 1;
			return;
		}
		else if(!next_round)
			if((redspawned && bluespawned == 0) || (bluespawned && redspawned == 0)) {
				next_round = time + 5;

				champion = find(world, classname, "player");
				string champion_team;
				if(champion.team == COLOR_TEAM1) {
					champion_team = "^1Red team";
					play2all("ctf/red_capture.wav");
				}
				else if(champion.team == COLOR_TEAM2) {
					champion_team = "^4Blue team";
					play2all("ctf/blue_capture.wav");
				}
				FOR_EACH_CLIENT(self) centerprint(self, strcat(champion_team, "^7 wins the round.", "^7\n"));	
			else if(!redspawned && !bluespawned) {
				FOR_EACH_CLIENT(self) centerprint(self, strcat("^7Round tied.", "^7\n"));
				next_round = time + 5;
			}
		}

		if((next_round && next_round < time))
		{
			next_round = 0;
			reset_map(TRUE);
		}
	} else { // arena
		//extend next_round if it isn't set yet and only 1 player is spawned
		if(!next_round)
		if(numspawned < 2)
			next_round = time + 3;

		if(!arena_roundbased || (next_round && next_round < time && player_count > 1))
		{
			next_round = 0;

			if(arena_roundbased)
			{
				champion = find(world, classname, "player");
				while(champion && champion.deadflag)
					champion = find(champion, classname, "player");
				reset_map(TRUE);
			}

			while(numspawned < maxspawned && spawnqueue_first)
			{
				self = spawnqueue_first;

				bprint ("^4", self.netname, "^4 is the next challenger\n");

				Spawnqueue_Remove(self);
				Spawnqueue_Mark(self);

				self.classname = "player";
				PutClientInServer();
			}
		}
	}
}
