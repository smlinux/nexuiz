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

void PutObserverInServer();
void PutClientInServer();
void(entity e) ReturnFlag;
void(entity e) removedecor;
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
void reset_map()
{
	entity oldself;
	oldself = self;

	if(g_arena)
	if(cvar("g_arena_warmup"))
		warmup = time + cvar("g_arena_warmup");

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

		if(self.use == SUB_DontUseTargets)
			self.use = SUB_UseTargets;

		if(self.classname == STR_ITEM_KH_KEY)
		{
			kh_Key_AssignTo(self, world);
			//if(self.owner)
			//	kh_Key_DropAll(self.owner, TRUE);
			kh_Key_Remove(self);
		}
		else if(self.classname == "droppedweapon"		// cleanup
				|| self.classname == "gib"
				|| self.classname == "body")
		{
			remove(self);
		}
		else if(self.items & (IT_KEY1 | IT_KEY2))
		{
			DropFlag(self, world, world);
			ReturnFlag(self);
		}
		else if(self.classname == "rune")
		{
			if(self.owner)
			if(self.owner.classname != "runematch_spawn_point")
				DropAllRunes(self.owner);
			rune_respawn();
		}
		else if(self.classname == "dom_controlpoint")
		{
			dom_controlpoint_setup();
		}
		else if(self.flags & FL_ITEM)			// reset items
		{
			if(self.state == 1)
			{
				self.model = string_null;
				self.solid = SOLID_NOT;
			}
			else
			{
				self.model = self.mdl;
				self.solid = SOLID_TRIGGER;
			}
			setorigin (self, self.origin);
			self.think = SUB_Null;
			self.nextthink = 0;
		}
		else if(self.flags & FL_PROJECTILE)		// remove any projectiles left
		{
			stopsound(self, CHAN_PROJECTILE);
			remove(self);
		}
		else if(self.isdecor)
		{
			removedecor(self);
		}
		else if(self.classname == "onslaught_generator")
		{
			onslaught_generator_reset();
		}
		else if(self.classname == "onslaught_controlpoint")
		{
			onslaught_controlpoint_reset();
		}
		// TODO properly reset Assault
		// General teambased game modes
		else if(self.classname == "func_breakable")
		{
			func_breakable_reset();
		}
		else if(self.classname == "func_assault_destructible")
		{
			func_breakable_reset();
		}
		else if(self.classname == "target_objective")
		{
			assault_objective_reset();
		}
		else if(self.classname == "target_assault_roundend")
		{
			target_assault_roundend_reset();
		}
	}

	// Waypoints and assault start come LAST
	for(self = world; (self = nextent(self)); )
	if(clienttype(self) == CLIENTTYPE_NOTACLIENT)
	{
		if(self.classname == "sprite_waypoint")
		{
			if(self.health | g_keyhunt)
				WaypointSprite_Kill(self);
		}
		else if(self.classname == "target_assault_roundstart")
		{
			self.use();
		}
		else if(self.classname == "trigger_gamestart")
		{
			if(self.wait)
			{
				self.think = self.use;
				self.nextthink = game_starttime + self.wait;
			}
			else
				self.use();
		}
	}

	// Moving the player reset code here since the player-reset depends
	// on spawnpoint entities which have to be reset first --blub
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
						PlayerScore_Clear(self);
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

	if(g_arena)
	if(champion)
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
void Arena_Warmup()
{
	float f;
	string msg;

	if(!g_arena || !arena_roundbased || (time < game_starttime))
		return;

	f = rint(warmup - time);

	msg = NEWLINES;
	if(time < warmup && self.spawned)
	{
		if(champion)
			msg = strcat(msg, "The Champion is ", champion.netname, "^7\n\n\n");

		if(f)
			msg = strcat(msg, "Round will start in ", ftos(f));
		else
		{
			if(self.spawned)
				msg = strcat(msg, "^1Fight!");
		}

		centerprint(self, msg);

		if(self.spawned)
			self.movetype = MOVETYPE_NONE;

		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.movement = '0 0 0';
		//self.fixangle = TRUE;
	}
	else if(self.movetype == MOVETYPE_NONE)
	{
		self.movetype = MOVETYPE_WALK;
		centerprint(self, "\n");
	}

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
	if(time < warmup + 1)
		return;

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
			reset_map();
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
