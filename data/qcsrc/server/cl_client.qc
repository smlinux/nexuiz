.float spectatee_status;
.float zoomstate;
.float bloodloss_timer;

.entity clientdata;
float ClientData_Send(entity to, float sf)
{
	if(to != self.owner)
	{
		error("wtf");
		return FALSE;
	}

	entity e;

	e = to;
	if(to.classname == "spectator")
		e = to.enemy;

	sf = 0;

	if(e.race_completed)
		sf |= 1; // forced scoreboard
	if(to.spectatee_status)
		sf |= 2; // spectator ent number follows
	if(e.zoomstate)
		sf |= 4; // zoomed
	if(e.porto_v_angle_held)
		sf |= 8; // angles held
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_CLIENTDATA);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 2)
		WriteByte(MSG_ENTITY, to.spectatee_status);
	
	if(sf & 8)
	{
		WriteAngle(MSG_ENTITY, e.v_angle_x);
		WriteAngle(MSG_ENTITY, e.v_angle_y);
	}

	return TRUE;
}

void ClientData_Attach()
{
	Net_LinkEntity(self.clientdata = spawn(), FALSE, 0, ClientData_Send);
	self.clientdata.drawonlytoclient = self;
	self.clientdata.owner = self;
}

void ClientData_Detach()
{
	remove(self.clientdata);
	self.clientdata = world;
}

void ClientData_Touch(entity e)
{
	e.clientdata.SendFlags = 1;

	// make it spectatable
	entity e2;
	FOR_EACH_REALCLIENT(e2)
	{
		if(e2 != e)
			if(e2.classname == "spectator")
				if(e2.enemy == e)
					e2.clientdata.SendFlags = 1;
	}
}


#define SPAWNPOINT_SCORE frags

.string netname_previous;

void spawnfunc_info_player_survivor (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_start (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_deathmatch (void)
{
	self.classname = "info_player_deathmatch";
	relocate_spawnpoint();
}

void spawnpoint_use()
{
	if(teams_matter)
	if(have_team_spawns)
	{
		self.team = activator.team;
		some_spawn_has_been_used = 1;
	}
};

// Returns:
//   -1 if a spawn can't be used
//   otherwise, a weight of the spawnpoint
float Spawn_Score(entity spot, entity playerlist, float teamcheck)
{
	float shortest, thisdist;
	entity player;

	// filter out spots for the wrong team
	if(teamcheck)
	if(spot.team != teamcheck)
		return -1;

	if(race_spawns)
		if(spot.target == "")
			return -1;

	// filter out spots for assault
	if(spot.target != "") {
		local entity ent;
		float good, found;
		ent = find(world, targetname, spot.target);
		while(ent) {
			if(ent.classname == "target_objective")
			{
				found = 1;
				if(ent.health < 0 || ent.health >= ASSAULT_VALUE_INACTIVE)
					return -1;
				good = 1;
			}
			else if(ent.classname == "trigger_race_checkpoint")
			{
				found = 1;
				if(self.classname == "player") // spectators may spawn everywhere
				{
					if(g_race_qualifying)
					{
						// spawn at first
						if(ent.race_checkpoint != 0)
							return -1;
						if(spot.race_place != race_lowest_place_spawn)
							return -1;
					}
					else
					{
						if(ent.race_checkpoint != race_PreviousCheckpoint(self.race_checkpoint))
							return -1;
						float pl;
						pl = self.race_place;
						if(pl > race_highest_place_spawn)
							pl = 0;
						if(spot.race_place != pl)
							return -1;
					}
				}
				good = 1;
			}
			ent = find(ent, targetname, spot.target);
		}

		if(found && !good)
			return -1;
	}

	player = playerlist;
	shortest = vlen(world.maxs - world.mins);
	for(player = playerlist; player; player = player.chain)
		if (player != self)
		{
			thisdist = vlen(player.origin - spot.origin);
			if (thisdist < shortest)
				shortest = thisdist;
		}
	return shortest;
}

float spawn_allbad;
float spawn_allgood;
entity Spawn_FilterOutBadSpots(entity firstspot, entity playerlist, float mindist, float teamcheck)
{
	local entity spot, spotlist, spotlistend;
	spawn_allgood = TRUE;
	spawn_allbad = TRUE;

	spotlist = world;
	spotlistend = world;

	for(spot = firstspot; spot; spot = spot.chain)
	{
		spot.SPAWNPOINT_SCORE = Spawn_Score(spot, playerlist, teamcheck);

		if(cvar("spawn_debugview"))
		{
			setmodel(spot, "models/runematch/rune.mdl");
			if(spot.SPAWNPOINT_SCORE < mindist)
			{
				spot.colormod = '1 0 0';
				spot.scale = 1;
			}
			else
			{
				spot.colormod = '0 1 0';
				spot.scale = spot.SPAWNPOINT_SCORE / mindist;
			}
		}

		if(spot.SPAWNPOINT_SCORE >= 0) // spawning allowed here
		{
			if(spot.SPAWNPOINT_SCORE < mindist)
			{
				// too short distance
				spawn_allgood = FALSE;
			}
			else 
			{
				// perfect
				spawn_allbad = FALSE;

				if(spotlistend)
					spotlistend.chain = spot;
				spotlistend = spot;
				if(!spotlist)
					spotlist = spot;

				/*
				if(teamcheck)
				if(spot.team != teamcheck)
					error("invalid spawn added");

				print("added ", etos(spot), "\n");
				*/
			}
		}
	}
	if(spotlistend)
		spotlistend.chain = world;

	/*
		entity e;
		if(teamcheck)
			for(e = spotlist; e; e = e.chain)
			{
				print("seen ", etos(e), "\n");
				if(e.team != teamcheck)
					error("invalid spawn found");
			}
	*/

	return spotlist;
}

entity Spawn_WeightedPoint(entity firstspot, float lower, float upper, float exponent)
{
	// weight of a point: bound(lower, mindisttoplayer, upper)^exponent
	// multiplied by spot.cnt (useful if you distribute many spawnpoints in a small area)
	local entity spot;

	RandomSelection_Init();
	for(spot = firstspot; spot; spot = spot.chain)
		RandomSelection_Add(spot, 0, string_null, pow(bound(lower, spot.SPAWNPOINT_SCORE, upper), exponent) * spot.cnt, spot.SPAWNPOINT_SCORE >= lower);

	return RandomSelection_chosen_ent;
}

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity SelectSpawnPoint (float anypoint)
{
	local float teamcheck;
	local entity firstspot_new;
	local entity spot, firstspot, playerlist;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	teamcheck = 0;

	if(!anypoint && have_team_spawns)
		teamcheck = self.team;

	// get the list of players
	playerlist = findchain(classname, "player");
	// get the entire list of spots
	firstspot = findchain(classname, "info_player_deathmatch");
	// filter out the bad ones
	// (note this returns the original list if none survived)
	firstspot_new = Spawn_FilterOutBadSpots(firstspot, playerlist, 100, teamcheck);
	if(!firstspot_new)
		firstspot_new = Spawn_FilterOutBadSpots(firstspot, playerlist, -1, teamcheck);
	firstspot = firstspot_new;

	// there is 50/50 chance of choosing a random spot or the furthest spot
	// (this means that roughly every other spawn will be furthest, so you
	// usually won't get fragged at spawn twice in a row)
	if (arena_roundbased)
	{
		firstspot_new = Spawn_FilterOutBadSpots(firstspot, playerlist, 800, teamcheck);
		if(firstspot_new)
			firstspot = firstspot_new;
		spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
	}
	else if (random() > cvar("g_spawn_furthest"))
		spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
	else
		spot = Spawn_WeightedPoint(firstspot, 1, 5000, 5); // chooses a far far away spawnpoint

	if(cvar("spawn_debugview"))
	{
		print("spot mindistance: ", ftos(spot.SPAWNPOINT_SCORE), "\n");

		entity e;
		if(teamcheck)
			for(e = firstspot; e; e = e.chain)
				if(e.team != teamcheck)
					error("invalid spawn found");
	}

	if (!spot)
	{
		if(cvar("spawn_debug"))
			GotoNextMap();
		else
		{
			if(some_spawn_has_been_used)
				return world; // team can't spawn any more, because of actions of other team
			else
				error("Cannot find a spawn point - please fix the map!");
		}
	}

	return spot;
}

/*
=============
CheckPlayerModel

Checks if the argument string can be a valid playermodel.
Returns a valid one in doubt.
=============
*/
string FallbackPlayerModel = "models/player/marine.zym";
string CheckPlayerModel(string plyermodel) {
	if(strlen(plyermodel) < 4)
		return FallbackPlayerModel;
	if( substring(plyermodel,0,14) != "models/player/")
		return FallbackPlayerModel;
	else if(cvar("sv_servermodelsonly"))
	{
		if(substring(plyermodel,strlen(plyermodel)-4,4) != ".zym")
		if(substring(plyermodel,strlen(plyermodel)-4,4) != ".dpm")
		if(substring(plyermodel,strlen(plyermodel)-4,4) != ".md3")
		if(substring(plyermodel,strlen(plyermodel)-4,4) != ".psk")
			return FallbackPlayerModel;
#ifdef ALLOW_VARIABLE_LOD
		// forbid the LOD models
		if(substring(plyermodel, strlen(plyermodel)-6,2) == "_1")
			return FallbackPlayerModel;
		if(substring(plyermodel, strlen(plyermodel)-6,2) == "_2")
			return FallbackPlayerModel;
#endif
		if(plyermodel != strtolower(plyermodel))
			return FallbackPlayerModel;
		if(!fexists(plyermodel))
			return FallbackPlayerModel;
	}
	return plyermodel;
}

/*
=============
Client_customizeentityforclient

LOD reduction
=============
*/
float Client_customizeentityforclient()
{
#ifdef ALLOW_VARIABLE_LOD
	// self: me
	// other: the player viewing me
	float distance;
	float f;

	if(self.classname != "player")
		return TRUE;

	if(other.cvar_cl_playerdetailreduction <= 0)
	{
		if(other.cvar_cl_playerdetailreduction <= -2)
			self.modelindex = self.modelindex_lod2;
		else if(other.cvar_cl_playerdetailreduction <= -1)
			self.modelindex = self.modelindex_lod1;
		else
			self.modelindex = self.modelindex_lod0;
	}
	else
	{
		distance = vlen(self.origin - other.origin);
		f = (distance + 100.0) * other.cvar_cl_playerdetailreduction;
		if(f > 10000)
			self.modelindex = self.modelindex_lod2;
		else if(f > 5000)
			self.modelindex = self.modelindex_lod1;
		else
			self.modelindex = self.modelindex_lod0;
	}
#endif

	return TRUE;
}

void UpdatePlayerSounds();
void setmodel_lod(entity e, string modelname)
{
#ifdef ALLOW_VARIABLE_LOD
	string s;

	// FIXME: this only supports 3-letter extensions
	s = strcat(substring(modelname, 0, strlen(modelname) - 4), "_1", substring(modelname, 0, strlen(modelname) - 4));
	if(fexists(s))
	{
		precache_model(s);
		setmodel(e, s); // players have high precision
		self.modelindex_lod1 = self.modelindex;
	}
	else
		self.modelindex_lod1 = -1;

	s = strcat(substring(modelname, 0, strlen(modelname) - 4), "_2", substring(modelname, 0, strlen(modelname) - 4));
	if(fexists(s))
	{
		precache_model(s);
		setmodel(e, s); // players have high precision
		self.modelindex_lod2 = self.modelindex;
	}
	else
		self.modelindex_lod2 = -1;

	precache_model(modelname);
	setmodel(e, modelname); // players have high precision
	self.modelindex_lod0 = self.modelindex;

	if(self.modelindex_lod1 < 0)
		self.modelindex_lod1 = self.modelindex;

	if(self.modelindex_lod2 < 0)
		self.modelindex_lod2 = self.modelindex;
#else
	precache_model(modelname);
	setmodel(e, modelname); // players have high precision
#endif
	player_setupanimsformodel();
	UpdatePlayerSounds();
}

/*
=============
PutObserverInServer

putting a client as observer in the server
=============
*/
void PutObserverInServer (void)
{
	entity	spot;

	race_PreSpawnObserver();

	spot = SelectSpawnPoint (TRUE);
	if(!spot)
		error("No spawnpoints for observers?!?\n");
	RemoveGrapplingHook(self); // Wazat's Grappling Hook

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}

	DropAllRunes(self);
	kh_Key_DropAll(self, TRUE);

	Portal_ClearAll(self);

	if(self.flagcarried)
		DropFlag(self.flagcarried, world, world);
	if(self.ballcarried)
		DropBall(self.ballcarried, self.origin + self.ballcarried.origin, self.velocity);

	WaypointSprite_PlayerDead();
	
	if(self.killcount != -666)
	{
		if(g_lms)
		{
			if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0)
				bprint ("^4", self.netname, "^4 has no more lives left\n");
			else
				bprint ("^4", self.netname, "^4 is spectating now\n"); // TODO turn this into a proper forfeit?
		}
		else
			bprint ("^4", self.netname, "^4 is spectating now\n");
	}

	PlayerScore_Clear(self); // clear scores when needed

	self.spectatortime = time;
	
	self.classname = "observer";
	self.iscreature = FALSE;
	self.health = -666;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	self.flags = FL_CLIENT | FL_NOTARGET;
	self.armorvalue = 666;
	self.effects = 0;
	self.armorvalue = cvar("g_balance_armor_start");
	self.pauserotarmor_finished = 0;
	self.pauserothealth_finished = 0;
	self.pauseregen_finished = 0;
	self.damageforcescale = 0;
	self.death_time = 0;
	self.dead_frame = 0;
	self.alpha = 0;
	self.scale = 0;
	self.fade_time = 0;
	self.pain_frame = 0;
	self.pain_finished = 0;
	self.strength_finished = 0;
	self.invincible_finished = 0;
	self.pushltime = 0;
	self.think = SUB_Null;
	self.nextthink = 0;
	self.hook_time = 0;
	self.runes = 0;
	self.deadflag = DEAD_NO;
	self.angles = spot.angles;
	self.angles_z = 0;
	self.fixangle = TRUE;
	self.crouch = FALSE;

	self.view_ofs = PL_VIEW_OFS;
	setorigin (self, spot.origin);
	setsize (self, '0 0 0', '0 0 0');
	self.prevorigin = self.origin;
	self.items = 0;
	self.weapons = 0;
	self.model = "";
	self.modelindex = 0;
	self.weapon = 0;
	self.weaponmodel = "";
	self.weaponentity = world;
	self.exteriorweaponentity = world;
	self.killcount = -666;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	self.customizeentityforclient = Client_customizeentityforclient;

	self.team = -1;

	if(g_arena)
	{
		if(self.version_mismatch)
		{
			Spawnqueue_Unmark(self);
			Spawnqueue_Remove(self);
		}
		else
		{
			Spawnqueue_Insert(self);
		}
	}
	else if(g_lms)
	{
		// Only if the player cannot play at all
		if(PlayerScore_Add(self, SP_LMS_RANK, 0) == 666)
			self.frags = FRAGS_SPECTATOR;
		else
			self.frags = FRAGS_LMS_LOSER;
	}
	else
		self.frags = FRAGS_SPECTATOR;
}

float RestrictSkin(float s)
{
	if(!teams_matter)
		return s;
	if(s == 6)
		return 6;
	return mod(s, 3);
}

void FixPlayermodel()
{
	local string defaultmodel;
	local float defaultskin, chmdl, oldskin;
	local vector m1, m2;

	defaultmodel = "";

	if(cvar("sv_defaultcharacter") == 1) {
		defaultskin = 0;

		if(teams_matter)
		{
			defaultmodel = cvar_string(strcat("sv_defaultplayermodel_", Team_ColorNameLowerCase(self.team)));
			defaultskin = cvar(strcat("sv_defaultplayerskin_", Team_ColorNameLowerCase(self.team)));
		}

		if(defaultmodel == "")
		{
			defaultmodel = cvar_string("sv_defaultplayermodel");
			defaultskin = cvar("sv_defaultplayerskin");
		}
	}

	if(self.modelindex == 0 && self.deadflag == DEAD_NO)
	{
		if(self.model != "")
			bprint("\{1}^1Player ", self.netname, "^1 has a zero modelindex, trying to fix...\n");
		self.model = ""; // force the != checks to return true
	}

	if(defaultmodel != "")
	{
		if (defaultmodel != self.model)
		{
			m1 = self.mins;
			m2 = self.maxs;
			setmodel_lod (self, defaultmodel);
			setsize (self, m1, m2);
		}

		self.skin = defaultskin;
		self.species = player_getspecies();
	} else {
		if (self.playermodel != self.model)
		{
			self.playermodel = CheckPlayerModel(self.playermodel);
			m1 = self.mins;
			m2 = self.maxs;
			setmodel_lod (self, self.playermodel);
			setsize (self, m1, m2);
			chmdl = TRUE;
		}

		oldskin = self.skin;
		self.skin = RestrictSkin(stof(self.playerskin));

		if(chmdl || oldskin != self.skin)
			self.species = player_getspecies(); // model or skin has changed
	}

	if(!teams_matter)
		if(strlen(cvar_string("sv_defaultplayercolors")))
			if(self.clientcolors != cvar("sv_defaultplayercolors"))
				setcolor(self, cvar("sv_defaultplayercolors"));
}

void PlayerTouchExplode(entity p1, entity p2)
{
	vector org;
	org = (p1.origin + p2.origin) * 0.5;
	org_z += (p1.mins_z + p2.mins_z) * 0.5;

	te_explosion(org);

	entity e;
	e = spawn();
	setorigin(e, org);
	RadiusDamage(e, world, g_touchexplode_damage, g_touchexplode_edgedamage, g_touchexplode_radius, world, g_touchexplode_force, DEATH_TOUCHEXPLODE, world);
	remove(e);
}

/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/
//void() ctf_playerchanged;
void PutClientInServer (void)
{
	if(clienttype(self) == CLIENTTYPE_BOT)
	{
		self.classname = "player";
	}
	else if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}

	// player is dead and becomes observer
	// FIXME fix LMS scoring for new system
	if(g_lms)
	{
		if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0)
			self.classname = "observer";
	}

	if(g_arena)
	if(!self.spawned)
		self.classname = "observer";

	if(self.classname == "player") {
		entity spot, oldself;

		if(self.team < 0)
			JoinBestTeam(self, FALSE, TRUE);

		race_PreSpawn();

		spot = SelectSpawnPoint (FALSE);
		if(!spot)
		{
			centerprint(self, "Sorry, no spawnpoints available!\nHope your team can fix it...");
			return; // spawn failed
		}

		RemoveGrapplingHook(self); // Wazat's Grappling Hook
		self.campingrifle_bulletcounter = 0;

		self.classname = "player";
		self.wasplayer = TRUE;
		self.iscreature = TRUE;
		self.movetype = MOVETYPE_WALK;
		self.solid = SOLID_SLIDEBOX;
		self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
		self.frags = FRAGS_PLAYER;
		if(independent_players)
			MAKE_INDEPENDENT_PLAYER(self);
		self.flags = FL_CLIENT;
		self.takedamage = DAMAGE_AIM;
		if(g_minstagib)
			self.effects = EF_FULLBRIGHT;
		else
			self.effects = 0;
		self.air_finished = time + 12;
		self.dmg = 2;

		if(inWarmupStage)
		{
			self.ammo_shells = warmup_start_ammo_shells;
			self.ammo_nails = warmup_start_ammo_nails;
			self.ammo_rockets = warmup_start_ammo_rockets;
			self.ammo_cells = warmup_start_ammo_cells;
			self.ammo_fuel = warmup_start_ammo_fuel;
			self.health = warmup_start_health;
			self.armorvalue = warmup_start_armorvalue;
			self.weapons = warmup_start_weapons;
		}
		else
		{
			self.ammo_shells = start_ammo_shells;
			self.ammo_nails = start_ammo_nails;
			self.ammo_rockets = start_ammo_rockets;
			self.ammo_cells = start_ammo_cells;
			self.ammo_fuel = start_ammo_fuel;
			self.health = start_health;
			self.armorvalue = start_armorvalue;
			self.weapons = start_weapons;
		}
		self.items = start_items;
		self.switchweapon = w_getbestweapon(self);
		self.cnt = self.switchweapon;
		self.weapon = 0;
		self.jump_interval = time;

		self.spawnshieldtime = time + cvar("g_spawnshieldtime");
		self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
		self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
		self.pauserotfuel_finished = time + cvar("g_balance_pause_fuel_rot_spawn");
		self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
		//extend the pause of rotting if client was reset at the beginning of the countdown
		if(!cvar("sv_ready_restart_after_countdown") && time < game_starttime) { // TODO why is this cvar NOTted?
			self.spawnshieldtime += game_starttime - time;
			self.pauserotarmor_finished += game_starttime - time;
			self.pauserothealth_finished += game_starttime - time;
			self.pauseregen_finished += game_starttime - time;
		}
		self.damageforcescale = 2;
		self.death_time = 0;
		self.dead_frame = 0;
		self.alpha = 0;
		self.scale = 0;
		self.fade_time = 0;
		self.pain_frame = 0;
		self.pain_finished = 0;
		self.strength_finished = 0;
		self.invincible_finished = 0;
		self.pushltime = 0;
		//self.speed_finished = 0;
		//self.slowmo_finished = 0;
		// players have no think function
		self.think = SUB_Null;
		self.nextthink = 0;
		self.hook_time = 0;
		self.dmg_team = 0;

		self.metertime = 0;

		self.runes = 0;

		self.deadflag = DEAD_NO;

		self.angles = spot.angles;

		self.angles_z = 0; // never spawn tilted even if the spot says to
		self.fixangle = TRUE; // turn this way immediately
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.punchangle = '0 0 0';
		self.punchvector = '0 0 0';
		self.oldvelocity = self.velocity;

		msg_entity = self;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_SPAWN);
		});

		self.customizeentityforclient = Client_customizeentityforclient;

		self.model = "";
		FixPlayermodel();

		self.crouch = FALSE;
		self.view_ofs = PL_VIEW_OFS;
		setsize (self, PL_MIN, PL_MAX);
		self.spawnorigin = spot.origin;
		setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
		// don't reset back to last position, even if new position is stuck in solid
		self.oldorigin = self.origin;
		self.prevorigin = self.origin;
		self.lastrocket = world; // stop rocket guiding, no revenge from the grave!

		if(g_arena)
		{
			Spawnqueue_Remove(self);
			Spawnqueue_Mark(self);
		}

		self.event_damage = PlayerDamage;

		self.bot_attack = TRUE;

		self.statdraintime = time + 5;
		self.BUTTON_ATCK = self.BUTTON_JUMP = self.BUTTON_ATCK2 = 0;

		if(self.killcount == -666) {
			PlayerScore_Clear(self);
			self.killcount = 0;
		}

		self.cnt = WEP_LASER;
		self.nixnex_lastchange_id = -1;

		CL_SpawnWeaponentity();
		self.alpha = default_player_alpha;
		self.colormod = '1 1 1' * cvar("g_player_brightness");
		self.exteriorweaponentity.alpha = default_weapon_alpha;

		self.lms_nextcheck = time + cvar("g_lms_campcheck_interval")*2;
		self.lms_traveled_distance = 0;
		self.speedrunning = FALSE;

		race_PostSpawn(spot);

		if(cvar("spawn_debug"))
		{
			sprint(self, strcat("spawnpoint origin:  ", vtos(spot.origin), "\n"));
			remove(spot);	// usefull for checking if there are spawnpoints, that let drop through the floor
		}

		//stuffcmd(self, "chase_active 0");
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");

		if (cvar("g_spawnsound"))
			sound (self, CHAN_TRIGGER, "misc/spawn.wav", VOL_BASE, ATTN_NORM);

		if(g_assault) {
			if(self.team == assault_attacker_team)
				centerprint(self, "You are attacking!");
			else
				centerprint(self, "You are defending!");
		}

		target_voicescript_clear(self);

		oldself = self;
		self = spot;
			activator = oldself;
				SUB_UseTargets();
			activator = world;
		self = oldself;

	} else if(self.classname == "observer") {
		PutObserverInServer ();
	}

	//if(g_ctf)
	//	ctf_playerchanged();
}

float ClientInit_SendEntity(entity to, float sf)
{
	float i;
	WriteByte(MSG_ENTITY, ENT_CLIENT_INIT);
	WriteByte(MSG_ENTITY, g_nexball_meter_period * 32);
	for(i = 1; i <= 24; ++i)
		WriteByte(MSG_ENTITY, (get_weaponinfo(i)).impulse + 1);
	WriteCoord(MSG_ENTITY, hook_shotorigin_x);
	WriteCoord(MSG_ENTITY, hook_shotorigin_y);
	WriteCoord(MSG_ENTITY, hook_shotorigin_z);

	if(sv_foginterval && world.fog != "")
		WriteString(MSG_ENTITY, world.fog);
	else
		WriteString(MSG_ENTITY, "");
	WriteByte(MSG_ENTITY, cvar("g_balance_armor_blockpercent") * 255.0);
	return TRUE;
}

void ClientInit_Spawn()
{
	Net_LinkEntity(spawn(), FALSE, 0, ClientInit_SendEntity);
}

/*
=============
SetNewParms
=============
*/
void SetNewParms (void)
{
	// initialize parms for a new player
	parm1 = -(86400 * 366);
}

/*
=============
SetChangeParms
=============
*/
void SetChangeParms (void)
{
	// save parms for level change
	parm1 = self.parm_idlesince - time;
}

/*
=============
DecodeLevelParms
=============
*/
void DecodeLevelParms (void)
{
	// load parms
	self.parm_idlesince = parm1;
	if(self.parm_idlesince == -(86400 * 366))
		self.parm_idlesince = time;

	// whatever happens, allow 60 seconds of idling directly after connect for map loading
	self.parm_idlesince = max(self.parm_idlesince, time - sv_maxidle + 60);
}

/*
=============
ClientKill

Called when a client types 'kill' in the console
=============
*/

void ClientKill_Now_TeamChange()
{
	if(self.killindicator_teamchange == -1)
	{
		self.team = -1;
		JoinBestTeam( self, FALSE, FALSE );
	}
	else
		SV_ChangeTeam(self.killindicator_teamchange - 1);
}

void ClientKill_Now()
{
	if(self.killindicator_teamchange)
		ClientKill_Now_TeamChange();

	// in any case:
	Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');

	if(self.killindicator)
	{
		dprint("Cleaned up after a leaked kill indicator.\n");
		remove(self.killindicator);
		self.killindicator = world;
	}
}
void KillIndicator_Think()
{
	if (!self.owner.modelindex)
	{
		self.owner.killindicator = world;
		remove(self);
		return;
	}

	if(self.cnt <= 0)
	{
		self = self.owner;
		ClientKill_Now(); // no oldself needed
		return;
	}
	else
	{
		if(self.cnt <= 10)
			setmodel(self, strcat("models/sprites/", ftos(self.cnt), ".spr32"));
		if(clienttype(self.owner) == CLIENTTYPE_REAL)
		{
			if(self.cnt <= 10)
				announce(self.owner, strcat("announcer/robotic/", ftos(self.cnt), ".wav"));
			if(self.owner.killindicator_teamchange)
			{
				if(self.owner.killindicator_teamchange == -1)
					centerprint(self.owner, strcat("Changing team in ", ftos(self.cnt), " seconds"));
				else
					centerprint(self.owner, strcat("Changing to ", ColoredTeamName(self.owner.killindicator_teamchange), " in ", ftos(self.cnt), " seconds"));
			}
			else
				centerprint(self.owner, strcat("^1Suicide in ", ftos(self.cnt), " seconds"));
		}
		self.nextthink = time + 1;
		self.cnt -= 1;
	}
}

void ClientKill_TeamChange (float targetteam) // 0 = don't change, -1 = auto
{
	float killtime;
	entity e;
	killtime = cvar("g_balance_kill_delay");

	self.killindicator_teamchange = targetteam;

	if(!self.killindicator)
	{
		if(killtime <= 0 || !self.modelindex || self.deadflag != DEAD_NO)
		{
			ClientKill_Now();
		}
		else
		{
			self.killindicator = spawn();
			self.killindicator.owner = self;
			self.killindicator.scale = 0.5;
			setattachment(self.killindicator, self, "");
			setorigin(self.killindicator, '0 0 52');
			self.killindicator.think = KillIndicator_Think;
			self.killindicator.nextthink = time + (self.lip) * 0.05;
			self.killindicator.cnt = ceil(killtime);
			self.killindicator.count = bound(0, ceil(killtime), 10);
			sprint(self, strcat("^1You'll be dead in ", ftos(self.killindicator.cnt), " seconds\n"));

			for(e = world; (e = find(e, classname, "body")) != world; )
			{
				if(e.enemy != self)
					continue;
				e.killindicator = spawn();
				e.killindicator.owner = e;
				e.killindicator.scale = 0.5;
				setattachment(e.killindicator, e, "");
				setorigin(e.killindicator, '0 0 52');
				e.killindicator.think = KillIndicator_Think;
				e.killindicator.nextthink = time + (e.lip) * 0.05;
				e.killindicator.cnt = ceil(killtime);
			}
			self.lip = 0;
		}
	}
	if(self.killindicator)
	{
		if(targetteam)
			self.killindicator.colormod = TeamColor(targetteam);
		else
			self.killindicator.colormod = '0 0 0';
	}
}

void ClientKill (void)
{
	ClientKill_TeamChange(0);
}

void DoTeamChange(float destteam)
{
	float t, c0;
	if(!teams_matter)
	{
		if(destteam >= 0)
			SetPlayerColors(self, destteam);
		return;
	}
	if(self.classname == "player")
	if(destteam == -1)
	{
		CheckAllowedTeams(self);
		t = FindSmallestTeam(self, TRUE);
		switch(self.team)
		{
			case COLOR_TEAM1: c0 = c1; break;
			case COLOR_TEAM2: c0 = c2; break;
			case COLOR_TEAM3: c0 = c3; break;
			case COLOR_TEAM4: c0 = c4; break;
			default:          c0 = 999;
		}
		switch(t)
		{
			case 1:
				if(c0 > c1)
					destteam = COLOR_TEAM1;
				break;
			case 2:
				if(c0 > c2)
					destteam = COLOR_TEAM2;
				break;
			case 3:
				if(c0 > c3)
					destteam = COLOR_TEAM3;
				break;
			case 4:
				if(c0 > c4)
					destteam = COLOR_TEAM4;
				break;
		}
		if(destteam == -1)
			return;
	}
	if(destteam == self.team && destteam >= 0 && !self.killindicator)
		return;
	ClientKill_TeamChange(destteam);
}

void FixClientCvars(entity e)
{
	// send prediction settings to the client
	stuffcmd(e, "\nin_bindmap 0 0\n");
	/*
	 * we no longer need to stuff this. Remove this comment block if you feel 
	 * 2.3 and higher (or was it 2.2.3?) don't need these any more
	stuffcmd(e, strcat("cl_gravity ", ftos(cvar("sv_gravity")), "\n"));
	stuffcmd(e, strcat("cl_movement_accelerate ", ftos(cvar("sv_accelerate")), "\n"));
	stuffcmd(e, strcat("cl_movement_friction ", ftos(cvar("sv_friction")), "\n"));
	stuffcmd(e, strcat("cl_movement_maxspeed ", ftos(cvar("sv_maxspeed")), "\n"));
	stuffcmd(e, strcat("cl_movement_airaccelerate ", ftos(cvar("sv_airaccelerate")), "\n"));
	stuffcmd(e, strcat("cl_movement_maxairspeed ", ftos(cvar("sv_maxairspeed")), "\n"));
	stuffcmd(e, strcat("cl_movement_stopspeed ", ftos(cvar("sv_stopspeed")), "\n"));
	stuffcmd(e, strcat("cl_movement_jumpvelocity ", ftos(cvar("sv_jumpvelocity")), "\n"));
	stuffcmd(e, strcat("cl_movement_stepheight ", ftos(cvar("sv_stepheight")), "\n"));
	stuffcmd(e, strcat("set cl_movement_friction_on_land ", ftos(cvar("sv_friction_on_land")), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_qw ", ftos(cvar("sv_airaccel_qw")), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_sideways_friction ", ftos(cvar("sv_airaccel_sideways_friction")), "\n"));
	stuffcmd(e, "cl_movement_edgefriction 1\n");
	 */
}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
//void ctf_clientconnect();
string ColoredTeamName(float t);
void DecodeLevelParms (void);
//void dom_player_join_team(entity pl);
void ClientConnect (void)
{
	local string s;
	float t;

	if(self.flags & FL_CLIENT)
	{
		print("Warning: ClientConnect, but already connected!\n");
		return;
	}

	if(Ban_MaybeEnforceBan(self))
		return;

	DecodeLevelParms();

	self.classname = "player_joining";

	self.flags = FL_CLIENT;
	self.version_nagtime = time + 10 + random() * 10;

	if(player_count<0)
	{
		dprint("BUG player count is lower than zero, this cannot happen!\n");
		player_count = 0;
	}

	PlayerScore_Attach(self);
	ClientData_Attach();

	bot_clientconnect();

	race_PreSpawnObserver();

	//if(g_domination)
	//	dom_player_join_team(self);

	JoinBestTeam(self, FALSE, FALSE); // if the team number is valid, keep it

	if((cvar("sv_spectate") == 1 && !g_lms) || cvar("g_campaign")) {
		self.classname = "observer";
	} else {
		if(teams_matter)
		{
			if(cvar("g_balance_teams") || cvar("g_balance_teams_force"))
			{
				self.classname = "player";
				campaign_bots_may_start = 1;
			}
			else
			{
				self.classname = "observer"; // do it anyway
			}
		}
		else
		{
			self.classname = "player";
			campaign_bots_may_start = 1;
		}
	}

	self.playerid = (playerid_last = playerid_last + 1);
	if(cvar("sv_eventlog"))
	{
		if(clienttype(self) == CLIENTTYPE_REAL)
			GameLogEcho(strcat(":join:", ftos(self.playerid), ":", ftos(num_for_edict(self)), ":", self.netaddress, ":", self.netname));
		else
			GameLogEcho(strcat(":join:", ftos(self.playerid), ":", ftos(num_for_edict(self)), ":bot:", self.netname));
		s = strcat(":team:", ftos(self.playerid), ":");
		s = strcat(s, ftos(self.team));
		GameLogEcho(s);
	}
	self.netname_previous = strzone(self.netname);

	//stuffcmd(self, "set tmpviewsize $viewsize \n");

	bprint ("^4",self.netname);
	bprint ("^4 connected");

	if(g_domination || g_ctf)
	{
		bprint(" and joined the ");
		bprint(ColoredTeamName(self.team));
	}

	bprint("\n");

	self.welcomemessage_time = 0;

	stuffcmd(self, strcat(clientstuff, "\n"));
	stuffcmd(self, strcat("exec maps/", mapname, ".cfg\n"));
	stuffcmd(self, "cl_particles_reloadeffects\n");

	FixClientCvars(self);

	// spawnfunc_waypoint sprites
	WaypointSprite_InitClient(self);

	// Wazat's grappling hook
	SetGrappleHookBindings();

	// get autoswitch state from player when he toggles it
	stuffcmd(self, "alias autoswitch \"set cl_autoswitch $1 ; cmd autoswitch $1\"\n"); // default.cfg-ed in 2.4.1

	// get version info from player
	stuffcmd(self, "cmd clientversion $gameversion\n");

	// get other cvars from player
	GetCvars(0);

	// set cvar for team scoreboard
	stuffcmd(self, strcat("set teamplay ", ftos(teamplay), "\n"));

	// notify about available teams
	if(teams_matter)
	{
		CheckAllowedTeams(self);
		t = 0; if(c1 >= 0) t |= 1; if(c2 >= 0) t |= 2; if(c3 >= 0) t |= 4; if(c4 >= 0) t |= 8;
		stuffcmd(self, strcat("set _teams_available ", ftos(t), "\n"));
	}
	else
		stuffcmd(self, "set _teams_available 0\n");

	stuffcmd(self, strcat("set gametype ", ftos(game), "\n"));

	if(g_arena)
	{
		self.classname = "observer";
		Spawnqueue_Insert(self);
	}
	/*else if(g_ctf)
	{
		ctf_clientconnect();
	}*/

	if(teams_matter || sv_cheats)
		attach_entcs();

	bot_relinkplayerlist();

	self.spectatortime = time;
	if(blockSpectators)
	{
		sprint(self, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
	}

	self.jointime = time;
	self.allowedTimeouts = cvar("sv_timeout_number");

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		if(cvar("g_bugrigs"))
			stuffcmd(self, "cl_cmd settemp chase_active 1\n");
	}

	if(g_lms)
	{
		if(PlayerScore_Add(self, SP_LMS_LIVES, LMS_NewPlayerLives()) <= 0)
		{
			PlayerScore_Add(self, SP_LMS_RANK, 666);
			self.frags = FRAGS_SPECTATOR;
		}
	}

	if(!sv_foginterval && world.fog != "")
		stuffcmd(self, strcat("\nfog ", world.fog, "\nr_fog_exp2 0\nr_drawfog 1\n"));

	SoundEntity_Attach(self);

	if(cvar("g_hitplots"))
	{
		self.hitplotfh = fopen(strcat("hits-", matchid, "-", ftos(self.playerid), ".plot"), FILE_WRITE);
		fputs(self.hitplotfh, strcat("#name ", self.netname, "\n"));
	}
	else
		self.hitplotfh = -1;
}

/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
.entity chatbubbleentity;
.entity teambubbleentity;
void ReadyCount();
void ClientDisconnect (void)
{
	if not(self.flags & FL_CLIENT)
	{
		print("Warning: ClientDisconnect without ClientConnect\n");
		return;
	}

	if(self.hitplotfh >= 0)
	{
		fclose(self.hitplotfh);
		self.hitplotfh = -1;
	}

	bot_clientdisconnect();

	if(self.entcs)
		detach_entcs();
	
	if(cvar("sv_eventlog"))
		GameLogEcho(strcat(":part:", ftos(self.playerid)));
	bprint ("^4",self.netname);
	bprint ("^4 disconnected\n");
	
	SoundEntity_Detach(self);

	DropAllRunes(self);
	kh_Key_DropAll(self, TRUE);

	Portal_ClearAll(self);

	if(self.flagcarried)
		DropFlag(self.flagcarried, world, world);
	if(self.ballcarried)
		DropBall(self.ballcarried, self.origin + self.ballcarried.origin, self.velocity);

	// Here, everything has been done that requires this player to be a client.

	self.flags &~= FL_CLIENT;

	if (self.chatbubbleentity)
		remove (self.chatbubbleentity);

	if (self.teambubbleentity)
		remove (self.teambubbleentity);

	if (self.killindicator)
		remove (self.killindicator);

	WaypointSprite_PlayerGone();

	bot_relinkplayerlist();

	// remove laserdot
	if(self.weaponentity)
		if(self.weaponentity.lasertarget)
			remove(self.weaponentity.lasertarget);

	if(g_arena)
	{
		Spawnqueue_Unmark(self);
		Spawnqueue_Remove(self);
	}

	ClientData_Detach();
	PlayerScore_Detach(self);

	if(self.netname_previous)
		strunzone(self.netname_previous);

	ClearPlayerSounds();

	self.playerid = 0;
	ReadyCount();

	// free cvars
	GetCvars(-1);
}

.float BUTTON_CHAT;
void ChatBubbleThink()
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.chatbubbleentity != self)
	{
		if(self.owner) // but why can that ever be world?
			self.owner.chatbubbleentity = world;
		remove(self);
		return;
	}
	if (self.owner.BUTTON_CHAT && !self.owner.deadflag)
		self.model = self.mdl;
	else
		self.model = "";
};

void UpdateChatBubble()
{
	if (!self.modelindex)
		return;
	// spawn a chatbubble entity if needed
	if (!self.chatbubbleentity)
	{
		self.chatbubbleentity = spawn();
		self.chatbubbleentity.owner = self;
		self.chatbubbleentity.exteriormodeltoclient = self;
		self.chatbubbleentity.think = ChatBubbleThink;
		self.chatbubbleentity.nextthink = time;
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr"); // precision set below
		//setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.chatbubbleentity, '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.chatbubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.chatbubbleentity.mdl = self.chatbubbleentity.model;
		self.chatbubbleentity.model = "";
		self.chatbubbleentity.effects = EF_LOWPRECISION;
	}
}


void TeamBubbleThink()
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.teambubbleentity != self)
	{
		if(self.owner) // but why can that ever be world?
			self.owner.teambubbleentity = world;
		remove(self);
		return;
	}
//	setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1');  // bandwidth hog. setattachment does this now
	if (self.owner.BUTTON_CHAT || self.owner.deadflag || self.owner.killindicator)
		self.model = "";
	else
		self.model = self.mdl;

};

float TeamBubble_customizeentityforclient()
{
	return (self.owner != other && self.owner.team == other.team && other.killcount > -666);
}

void UpdateTeamBubble()
{
	if (!self.modelindex || !teams_matter)
		return;
	// spawn a teambubble entity if needed
	if (!self.teambubbleentity && teams_matter)
	{
		self.teambubbleentity = spawn();
		self.teambubbleentity.owner = self;
		self.teambubbleentity.exteriormodeltoclient = self;
		self.teambubbleentity.think = TeamBubbleThink;
		self.teambubbleentity.nextthink = time;
		setmodel(self.teambubbleentity, "models/misc/teambubble.spr"); // precision set below
//		setorigin(self.teambubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.teambubbleentity, '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.teambubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.teambubbleentity.mdl = self.teambubbleentity.model;
		self.teambubbleentity.model = self.teambubbleentity.mdl;
		self.teambubbleentity.customizeentityforclient = TeamBubble_customizeentityforclient;
		self.teambubbleentity.effects = EF_LOWPRECISION;
	}
}

// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
/*void UpdateColorModHack()
{
	local float c;
	c = self.clientcolors & 15;
	// LordHavoc: only bothering to support white, green, red, yellow, blue
	     if (!teams_matter) self.colormod = '0 0 0';
	else if (c ==  0) self.colormod = '1.00 1.00 1.00';
	else if (c ==  3) self.colormod = '0.10 1.73 0.10';
	else if (c ==  4) self.colormod = '1.73 0.10 0.10';
	else if (c == 12) self.colormod = '1.22 1.22 0.10';
	else if (c == 13) self.colormod = '0.10 0.10 1.73';
	else self.colormod = '1 1 1';
};*/

void respawn(void)
{
	CopyBody(1);
	self.effects |= EF_NODRAW; // prevent another CopyBody
	PutClientInServer();
}

void play_countdown(float finished, string samp)
{
	if(clienttype(self) == CLIENTTYPE_REAL)
		if(floor(finished - time - frametime) != floor(finished - time))
			if(finished - time < 6)
				sound (self, CHAN_AUTO, samp, VOL_BASE, ATTN_NORM);
}

/**
 * When sv_timeout is used this function returs strings like
 * "Timeout begins in 2 seconds!\n" or "Timeout ends in 23 seconds!\n".
 * Called by centerprint functions
 * @param addOneSecond boolean, set to 1 if the welcome-message centerprint asks for the text
 */
string getTimeoutText(float addOneSecond) {
	if (!cvar("sv_timeout") || !timeoutStatus)
		return "";

	local string retStr;
	if (timeoutStatus == 1) {
		if (addOneSecond == 1) {
			retStr = strcat("Timeout begins in ", ftos(remainingLeadTime + 1), " seconds!\n");
		}
		else {
			retStr = strcat("Timeout begins in ", ftos(remainingLeadTime), " seconds!\n");
		}
		return retStr;
	}
	else if (timeoutStatus == 2) {
		if (addOneSecond) {
			retStr = strcat("Timeout ends in ", ftos(remainingTimeoutTime + 1), " seconds!\n");
			//don't show messages like "Timeout ends in 0 seconds"...
			if ((remainingTimeoutTime + 1) > 0)
				return retStr;
			else
				return "";
		}
		else {
			retStr = strcat("Timeout ends in ", ftos(remainingTimeoutTime), " seconds!\n");
			//don't show messages like "Timeout ends in 0 seconds"...
			if (remainingTimeoutTime > 0)
				return retStr;
			else
				return "";
		}
	}
	else return "";
}

void player_powerups (void)
{
	if((self.items & IT_USING_JETPACK) && !self.deadflag)
	{
		SoundEntity_StartSound(self, CHAN_PLAYER, "misc/jetpack_fly.wav", VOL_BASE, ATTN_IDLE);
		self.modelflags |= MF_ROCKET;
	}
	else
	{
		SoundEntity_StopSound(self, CHAN_PLAYER);
		self.modelflags &~= MF_ROCKET;
	}

	self.effects &~= (EF_RED | EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT);

	if(!self.modelindex || self.deadflag) // don't apply the flags if the player is gibbed
		return;

	if (g_minstagib)
	{
		self.effects |= EF_FULLBRIGHT;

		if (self.items & IT_STRENGTH)
		{
			play_countdown(self.strength_finished, "misc/poweroff.wav");
			if (time > self.strength_finished)
			{
				self.alpha = default_player_alpha;
				self.exteriorweaponentity.alpha = default_weapon_alpha;
				self.items &~= IT_STRENGTH;
				sprint(self, "^3Invisibility has worn off\n");
			}
		}
		else
		{
			if (time < self.strength_finished)
			{
				self.alpha = g_minstagib_invis_alpha;
				self.exteriorweaponentity.alpha = g_minstagib_invis_alpha;
				self.items |= IT_STRENGTH;
				sprint(self, "^3You are invisible\n");
			}
		}

		if (self.items & IT_INVINCIBLE)
		{
			play_countdown(self.invincible_finished, "misc/poweroff.wav");
			if (time > self.invincible_finished)
			{
				self.items = self.items - (self.items & IT_INVINCIBLE);
				sprint(self, "^3Speed has worn off\n");
			}
		}
		else
		{
			if (time < self.invincible_finished)
			{
				self.items = self.items | IT_INVINCIBLE;
				sprint(self, "^3You are on speed\n");
			}
		}
		return;
	}

	if (self.items & IT_STRENGTH)
	{
		play_countdown(self.strength_finished, "misc/poweroff.wav");
		self.effects = self.effects | (EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT);
		if (time > self.strength_finished)
		{
			self.items = self.items - (self.items & IT_STRENGTH);
			sprint(self, "^3Strength has worn off\n");
		}
	}
	else
	{
		if (time < self.strength_finished)
		{
			self.items = self.items | IT_STRENGTH;
			sprint(self, "^3Strength infuses your weapons with devastating power\n");
		}
	}
	if (self.items & IT_INVINCIBLE)
	{
		play_countdown(self.invincible_finished, "misc/poweroff.wav");
		self.effects = self.effects | (EF_RED | EF_ADDITIVE | EF_FULLBRIGHT);
		if (time > self.invincible_finished)
		{
			self.items = self.items - (self.items & IT_INVINCIBLE);
			sprint(self, "^3Shield has worn off\n");
		}
	}
	else
	{
		if (time < self.invincible_finished)
		{
			self.items = self.items | IT_INVINCIBLE;
			sprint(self, "^3Shield surrounds you\n");
		}
	}

	if (cvar("g_fullbrightplayers"))
		self.effects = self.effects | EF_FULLBRIGHT;

	// midair gamemode: damage only while in the air
	// if in midair mode, being on ground grants temporary invulnerability
	// (this is so that multishot weapon don't clear the ground flag on the
	// first damage in the frame, leaving the player vulnerable to the
	// remaining hits in the same frame)
	if (self.flags & FL_ONGROUND)
	if (g_midair)
		self.spawnshieldtime = max(self.spawnshieldtime, time + cvar("g_midair_shieldtime"));

	if (time >= game_starttime)
	if (time < self.spawnshieldtime)
		self.effects = self.effects | (EF_ADDITIVE | EF_FULLBRIGHT);
}

float CalcRegen(float current, float stable, float regenfactor)
{
	if(current > stable)
		return current;
	else if(current > stable - 0.25) // when close enough, "snap"
		return stable;
	else
		return min(stable, current + (stable - current) * regenfactor * frametime);
}

void player_regen (void)
{
	float maxh, maxa, maxf, limith, limita, limitf, max_mod, regen_mod, rot_mod, limit_mod;
	maxh = cvar("g_balance_health_stable");
	maxa = cvar("g_balance_armor_stable");
	maxf = cvar("g_balance_fuel_stable");
	limith = cvar("g_balance_health_limit");
	limita = cvar("g_balance_armor_limit");
	limitf = cvar("g_balance_fuel_limit");

	max_mod = regen_mod = rot_mod = limit_mod = 1;

	if (self.runes & RUNE_REGEN)
	{
		if (self.runes & CURSE_VENOM) // do we have both rune/curse?
		{
			regen_mod = cvar("g_balance_rune_regen_combo_regenrate");
			max_mod = cvar("g_balance_rune_regen_combo_hpmod");
			limit_mod = cvar("g_balance_rune_regen_combo_limitmod");
		}
		else
		{
			regen_mod = cvar("g_balance_rune_regen_regenrate");
			max_mod = cvar("g_balance_rune_regen_hpmod");
			limit_mod = cvar("g_balance_rune_regen_limitmod");
		}
	}
	else if (self.runes & CURSE_VENOM)
	{
		max_mod = cvar("g_balance_curse_venom_hpmod");
		if (self.runes & RUNE_REGEN) // do we have both rune/curse?
			rot_mod = cvar("g_balance_rune_regen_combo_rotrate");
		else
			rot_mod = cvar("g_balance_curse_venom_rotrate");
		limit_mod = cvar("g_balance_curse_venom_limitmod");
		//if (!self.runes & RUNE_REGEN)
		//	rot_mod = cvar("g_balance_curse_venom_rotrate");
	}
	maxh = maxh * max_mod;
	//maxa = maxa * max_mod;
	//maxf = maxf * max_mod;
	limith = limith * limit_mod;
	limita = limita * limit_mod;
	//limitf = limitf * limit_mod;

	if (!g_minstagib && (!g_lms || cvar("g_lms_regenerate")))
	{
		if (self.armorvalue > maxa)
		{
			if (time > self.pauserotarmor_finished)
			{
				self.armorvalue = max(maxa, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime);
				self.armorvalue = max(maxa, self.armorvalue - cvar("g_balance_armor_rotlinear") * frametime);
			}
		}
		else if (self.armorvalue < maxa)
		{
			if (time > self.pauseregen_finished)
			{
				self.armorvalue = CalcRegen(self.armorvalue, maxa, cvar("g_balance_armor_regen"));
				self.armorvalue = min(maxa, self.armorvalue + cvar("g_balance_armor_regenlinear") * frametime);
			}
		}
		if (self.armorvalue > limita)
			self.armorvalue = limita;

		if (self.health > maxh)
		{
			if (time > self.pauserothealth_finished)
			{
				self.health = max(maxh, self.health + (maxh - self.health) * rot_mod*cvar("g_balance_health_rot") * frametime);
				self.health = max(maxh, self.health - rot_mod*cvar("g_balance_health_rotlinear") * frametime);
			}
		}
		else if (self.health < maxh)
		{
			if (time > self.pauseregen_finished)
			{
				self.health = CalcRegen(self.health, maxh, regen_mod * cvar("g_balance_health_regen"));
				self.health = min(maxh, self.health + regen_mod*cvar("g_balance_health_regenlinear") * frametime);
			}
		}
		if (self.health > limith)
			self.health = limith;

		// if player rotted to death...  die!
		if(self.health < 1)
			self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
	}

	if (self.ammo_fuel > maxf)
	{
		if (time > self.pauserotfuel_finished)
		{
			self.ammo_fuel = max(maxf, self.ammo_fuel + (maxf - self.ammo_fuel) * rot_mod*cvar("g_balance_fuel_rot") * frametime);
			self.ammo_fuel = max(maxf, self.ammo_fuel - rot_mod*cvar("g_balance_fuel_rotlinear") * frametime);
		}
	}
	else if (self.ammo_fuel < maxf)
	{
		if(self.items & IT_FUEL_REGEN)
		{
			if (time > self.pauseregen_finished)
			{
				self.ammo_fuel = CalcRegen(self.ammo_fuel, maxf, regen_mod * cvar("g_balance_fuel_regen"));
				self.ammo_fuel = min(maxf, self.ammo_fuel + regen_mod*cvar("g_balance_fuel_regenlinear") * frametime);
			}
		}
	}
	if (self.ammo_fuel > limitf)
		self.ammo_fuel = limitf;
}

float zoomstate_set;
void SetZoomState(float z)
{
	if(z != self.zoomstate)
		ClientData_Touch(self);
	zoomstate_set = 1;
}

void GetPressedKeys(void) {
	if (self.movement_x > 0) // get if movement keys are pressed
	{	// forward key pressed
		self.pressedkeys |= KEY_FORWARD;
		self.pressedkeys &~= KEY_BACKWARD;
	}
	else if (self.movement_x < 0)
	{	// backward key pressed
		self.pressedkeys |= KEY_BACKWARD;
		self.pressedkeys &~= KEY_FORWARD;
	}
	else
	{	// no x input
		self.pressedkeys &~= KEY_FORWARD;
		self.pressedkeys &~= KEY_BACKWARD;
	}
	
	if (self.movement_y > 0)
	{	// right key pressed
		self.pressedkeys |= KEY_RIGHT;
		self.pressedkeys &~= KEY_LEFT;
	}
	else if (self.movement_y < 0)
	{	// left key pressed
		self.pressedkeys |= KEY_LEFT;
		self.pressedkeys &~= KEY_RIGHT;
	}
	else
	{	// no y input
		self.pressedkeys &~= KEY_RIGHT;
		self.pressedkeys &~= KEY_LEFT;
	}
	
	if (self.BUTTON_JUMP) // get if jump and crouch keys are pressed
		self.pressedkeys |= KEY_JUMP;
	else
		self.pressedkeys &~= KEY_JUMP;
	if (self.BUTTON_CROUCH)
		self.pressedkeys |= KEY_CROUCH;
	else
		self.pressedkeys &~= KEY_CROUCH;
}

/*
======================
spectate mode routines
======================
*/
void SpectateCopy(entity spectatee) {
	self.armortype = spectatee.armortype;
	self.armorvalue = spectatee.armorvalue;
	self.ammo_cells = spectatee.ammo_cells;
	self.ammo_shells = spectatee.ammo_shells;
	self.ammo_nails = spectatee.ammo_nails;
	self.ammo_rockets = spectatee.ammo_rockets;
	self.ammo_fuel = spectatee.ammo_fuel;
	self.effects = spectatee.effects & EFMASK_CHEAP; // eat performance
	self.health = spectatee.health;
	self.impulse = 0;
	self.items = spectatee.items;
	self.metertime = spectatee.metertime;
	self.strength_finished = spectatee.strength_finished;
	self.invincible_finished = spectatee.invincible_finished;
	self.pressedkeys = spectatee.pressedkeys;
	self.weapons = spectatee.weapons;
	self.switchweapon = spectatee.switchweapon;
	self.weapon = spectatee.weapon;
	self.punchangle = spectatee.punchangle;
	self.view_ofs = spectatee.view_ofs;
	self.v_angle = spectatee.v_angle;
	self.velocity = spectatee.velocity;
	self.dmg_take = spectatee.dmg_take;
	self.dmg_save = spectatee.dmg_save;
	self.dmg_inflictor = spectatee.dmg_inflictor;
	self.angles = spectatee.v_angle;
	self.fixangle = TRUE;
	setorigin(self, spectatee.origin);
	setsize(self, spectatee.mins, spectatee.maxs);
	SetZoomState(spectatee.zoomstate);
}

float SpectateUpdate() {
	if(!self.enemy)
		return 0;

	if (self == self.enemy)
		return 0;
	
	if(self.enemy.classname != "player")
		return 0;

	SpectateCopy(self.enemy);

	return 1;
}

float SpectateNext() {
	other = find(self.enemy, classname, "player");
	if (!other) {
		other = find(other, classname, "player");
	}
	if (other) {
		self.enemy = other;
	}
	if(self.enemy.classname == "player") {
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self.enemy);
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");
		if(!SpectateUpdate())
			PutObserverInServer();
		return 1;
	} else {
		return 0;
	}
}

/*
=============
ShowRespawnCountdown()

Update a respawn countdown display.
=============
*/
void ShowRespawnCountdown()
{
	float number;
	if(self.deadflag == DEAD_NO) // just respawned?
		return;
	else
	{
		number = ceil(self.death_time - time);
		if(number <= 0)
			return;
		if(number <= self.respawn_countdown)
		{
			self.respawn_countdown = number - 1;
			if(ceil(self.death_time - (time + 0.5)) == number) // only say it if it is the same number even in 0.5s; to prevent overlapping sounds
				announce(self, strcat("announcer/robotic/", ftos(number), ".wav"));
		}
	}
}

void LeaveSpectatorMode()
{
	if(isJoinAllowed()) {
		if(!teams_matter || cvar("g_campaign") || cvar("g_balance_teams") || (self.wasplayer && cvar("g_changeteam_banned"))) {
			self.classname = "player";
			if(cvar("g_campaign") || cvar("g_balance_teams") || cvar("g_balance_teams_force"))
				JoinBestTeam(self, FALSE, TRUE);
			if(cvar("g_campaign"))
				campaign_bots_may_start = 1;
			PutClientInServer();
			if(self.classname == "player")
				bprint ("^4", self.netname, "^4 is playing now\n");
			if(!cvar("g_campaign"))
				centerprint(self,""); // clear MOTD
			return;
		} else {
			stuffcmd(self,"menu_showteamselect\n");
			return;
		}
	}
	else {
		//player may not join because of g_maxplayers is set
		centerprint_atprio(self, CENTERPRIO_MAPVOTE, PREVENT_JOIN_TEXT);
	}
}

/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return TRUE, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return bool TRUE if the player is allowed to join, false otherwise
 */
float isJoinAllowed() {
	if (!cvar("g_maxplayers"))
		return TRUE;

	local entity e;
	local float currentlyPlaying;
	FOR_EACH_REALPLAYER(e) {
		if(e.classname == "player")
			currentlyPlaying += 1;
	}
	if(currentlyPlaying < cvar("g_maxplayers"))
		return TRUE;

	return FALSE;
}

/**
 * Checks whether the client is an observer or spectator, if so, he will get kicked after
 * g_maxplayers_spectator_blocktime seconds
 */
void checkSpectatorBlock() {
	if(self.classname == "spectator" || self.classname == "observer") {
		if( time > (self.spectatortime + cvar("g_maxplayers_spectator_blocktime")) ) {
			sprint(self, "^7You were kicked from the server because you are spectator and spectators aren't allowed at the moment.\n");
			dropclient(self);
		}
	}
}

float vercmp_recursive(string v1, string v2)
{
	float dot1, dot2;
	string s1, s2;
	float r;

	dot1 = strstrofs(v1, ".", 0);
	dot2 = strstrofs(v2, ".", 0);
	if(dot1 == -1)
		s1 = v1;
	else
		s1 = substring(v1, 0, dot1);
	if(dot2 == -1)
		s2 = v2;
	else
		s2 = substring(v2, 0, dot2);

	r = stof(s1) - stof(s2);
	if(r != 0)
		return r;

	r = strcasecmp(s1, s2);
	if(r != 0)
		return r;

	if(dot1 == -1)
		if(dot2 == -1)
			return 0;
		else
			return -1;
	else
		if(dot2 == -1)
			return 1;
		else
			return vercmp_recursive(substring(v1, dot1 + 1, 999), substring(v2, dot2 + 1, 999));
}

float vercmp(string v1, string v2)
{
	if(strcasecmp(v1, v2) == 0) // early out check
		return 0;
	return vercmp_recursive(v1, v2);
}

void ObserverThink()
{
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.welcomemessage_time = 0;
			self.flags &~= FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK && !self.version_mismatch) {
			self.welcomemessage_time = 0;
			self.flags &~= FL_JUMPRELEASED;
			if(SpectateNext() == 1) {
				self.classname = "spectator";
			}
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_JUMP)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &~= FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
	}
	PrintWelcomeMessage(self);
}

void SpectatorThink()
{
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.welcomemessage_time = 0;
			self.flags &~= FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK) {
			self.welcomemessage_time = 0;
			self.flags &~= FL_JUMPRELEASED;
			if(SpectateNext() == 1) {
				self.classname = "spectator";
			} else {
				self.classname = "observer";
				PutClientInServer();
			}
		} else if (self.BUTTON_ATCK2) {
			self.welcomemessage_time = 0;
			self.flags &~= FL_JUMPRELEASED;
			self.classname = "observer";
			PutClientInServer();
		} else {
			if(!SpectateUpdate())
				PutObserverInServer();
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &~= FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
	}
	PrintWelcomeMessage(self);
	self.flags |= FL_CLIENT | FL_NOTARGET;
}

.float touchexplode_time;

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
void() ctf_setstatus;
void() nexball_setstatus;
.float items_added;
void PlayerPreThink (void)
{
	self.stat_sys_ticrate = cvar("sys_ticrate");
	self.stat_game_starttime = game_starttime;
	self.stat_allow_oldnexbeam = cvar("g_allow_oldnexbeam");

	if(blockSpectators && frametime)
		// WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
		checkSpectatorBlock();
	
	zoomstate_set = 0;

	if(self.netname_previous != self.netname)
	{
		if(cvar("sv_eventlog"))
			GameLogEcho(strcat(":name:", ftos(self.playerid), ":", self.netname));
		if(self.netname_previous)
			strunzone(self.netname_previous);
		self.netname_previous = strzone(self.netname);
	}

	// version nagging
	if(self.version_nagtime)
		if(self.cvar_g_nexuizversion)
			if(time > self.version_nagtime)
			{
				if(strstr(self.cvar_g_nexuizversion, "svn", 0) < 0)
				{
					if(strstr(cvar_string("g_nexuizversion"), "svn", 0) >= 0)
					{
						dprint("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), " (beta)^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1\n");
						sprint(self, strcat("\{1}^1NOTE: ^7the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), " (beta)^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1\n"));
					}
					else
					{
						float r;
						r = vercmp(self.cvar_g_nexuizversion, cvar_string("g_nexuizversion"));
						if(r < 0)
						{
							dprint("^1NOTE^7 to ", self.netname, "^7 - ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7 is out, and you still have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1 - get the update from ^4http://www.nexuiz.com/^1!\n");
							sprint(self, strcat("\{1}^1NOTE: ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7 is out, and you still have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1 - get the update from ^4http://www.nexuiz.com/^1!\n"));
						}
						else if(r > 0)
						{
							dprint("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1\n");
							sprint(self, strcat("\{1}^1NOTE: ^7the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "^1\n"));
						}
					}
				}
				self.version_nagtime = 0;
			}

	// GOD MODE info
	if(!(self.flags & FL_GODMODE)) if(self.max_armorvalue)
	{
		sprint(self, strcat("godmode saved you ", ftos(self.max_armorvalue), " units of damage, cheater!\n"));
		self.max_armorvalue = 0;
	}

	if(frametime)
		antilag_record(self);

	if(self.classname == "player") {
//		if(self.netname == "Wazat")
//			bprint(self.classname, "\n");

		CheckRules_Player();

		PrintWelcomeMessage(self);

		if (intermission_running)
		{
			IntermissionThink ();	// otherwise a button could be missed between
			return;					// the think tics
		}

		if(self.teleport_time)
		if(time > self.teleport_time)
		{
			self.teleport_time = 0;
			self.effects = self.effects - (self.effects & EF_NODRAW);
		}

		Nixnex_GiveCurrentWeapon();

		if(frametime > 0) // don't do this in cl_movement frames, just in server ticks
			UpdateSelectedPlayer();

		//don't allow the player to turn around while game is paused!
		if(timeoutStatus == 2) {
			self.v_angle = self.lastV_angle;
			self.angles = self.lastV_angle;
			self.fixangle = TRUE;
		}

		if(frametime)
			player_powerups();

		if (self.deadflag != DEAD_NO)
		{
			float button_pressed, force_respawn;
			if(frametime)
				player_anim();
			button_pressed = (self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE);
			force_respawn = (g_lms || cvar("g_forced_respawn"));
			if (self.deadflag == DEAD_DYING)
			{
				if(force_respawn)
					self.deadflag = DEAD_RESPAWNING;
				else if(!button_pressed)
					self.deadflag = DEAD_DEAD;
			}
			else if (self.deadflag == DEAD_DEAD)
			{
				if(button_pressed)
					self.deadflag = DEAD_RESPAWNABLE;
			}
			else if (self.deadflag == DEAD_RESPAWNABLE)
			{
				if(!button_pressed)
					self.deadflag = DEAD_RESPAWNING;
			}
			else if (self.deadflag == DEAD_RESPAWNING)
			{
				if(time > self.death_time)
				{
					self.death_time = time + 1; // only retry once a second
					respawn();
				}
			}
			ShowRespawnCountdown();
			return;
		}

		if(g_touchexplode)
		if(time > self.touchexplode_time)
		if(self.classname == "player")
		if(self.deadflag == DEAD_NO)
		if not(IS_INDEPENDENT_PLAYER(self))
		FOR_EACH_PLAYER(other) if(self != other)
		{
			if(time > other.touchexplode_time)
			if(other.classname == "player")
			if(other.deadflag == DEAD_NO)
			if not(IS_INDEPENDENT_PLAYER(other))
			if(boxesoverlap(self.absmin, self.absmax, other.absmin, other.absmax))
			{
				PlayerTouchExplode(self, other);
				self.touchexplode_time = other.touchexplode_time = time + 0.2;
			}
		}

		if(g_lms && !self.deadflag && cvar("g_lms_campcheck_interval"))
		{
			vector dist;

			// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
			dist = self.prevorigin - self.origin;
			dist_z = 0;
			self.lms_traveled_distance += fabs(vlen(dist));

			if((cvar("g_campaign") && !campaign_bots_may_start) || (time < game_starttime))
			{
				self.lms_nextcheck = time + cvar("g_lms_campcheck_interval")*2;
				self.lms_traveled_distance = 0;
			}

			if(time > self.lms_nextcheck)
			{
				//sprint(self, "distance: ", ftos(self.lms_traveled_distance), "\n");
				if(self.lms_traveled_distance < cvar("g_lms_campcheck_distance"))
				{
					centerprint(self, cvar_string("g_lms_campcheck_message"));
					// FIXME KadaverJack: gibbing player here causes playermodel to bounce around, instead of eye.md3
					// I wasn't able to find out WHY that happens, so I put a workaround in place that shall prevent players from being gibbed :(
					Damage(self, self, self, bound(0, cvar("g_lms_campcheck_damage"), self.health + self.armorvalue * cvar("g_balance_armor_blockpercent") + 5), DEATH_CAMP, self.origin, '0 0 0');
				}
				self.lms_nextcheck = time + cvar("g_lms_campcheck_interval");
				self.lms_traveled_distance = 0;
			}
		}

		self.prevorigin = self.origin;

		if ((self.BUTTON_CROUCH && !self.hook.state) || self.health <= g_bloodloss)
		{
			if (!self.crouch)
			{
				self.crouch = TRUE;
				self.view_ofs = PL_CROUCH_VIEW_OFS;
				setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
				setanim(self, self.anim_duck, FALSE, TRUE, TRUE);
			}
		}
		else
		{
			if (self.crouch)
			{
				tracebox(self.origin, PL_MIN, PL_MAX, self.origin, FALSE, self);
				if (!trace_startsolid)
				{
					self.crouch = FALSE;
					self.view_ofs = PL_VIEW_OFS;
					setsize (self, PL_MIN, PL_MAX);
				}
			}
		}
		
		if(self.health <= g_bloodloss && self.deadflag == DEAD_NO)
		{
			if(self.bloodloss_timer < time)
			{
				self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
				self.bloodloss_timer = time + 0.5 + random() * 0.5;
			}
		}

		FixPlayermodel();

		GrapplingHookFrame();

		if(frametime)
		{
			self.items &~= self.items_added;

			W_WeaponFrame();

			self.items_added = 0;
			if(self.items & IT_JETPACK)
				if(self.items & IT_FUEL_REGEN || self.ammo_fuel >= 0.01)
					self.items_added |= IT_FUEL;

			self.items |= self.items_added;
		}

		player_regen();
		if(frametime)
			player_anim();

		if (g_minstagib)
			minstagib_ammocheck();

		ctf_setstatus();
		kh_setstatus();
		nexball_setstatus();

		self.dmg_team = max(0, self.dmg_team - cvar("g_teamdamage_resetspeed") * frametime);

		//self.angles_y=self.v_angle_y + 90;   // temp

		//if (TetrisPreFrame()) return;
	} else if(gameover) {
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between
		return;
	} else if(self.classname == "observer") {
		ObserverThink();
	} else if(self.classname == "spectator") {
		SpectatorThink();
	}

	if(!zoomstate_set)
		SetZoomState(self.BUTTON_ZOOM || (self.BUTTON_ATCK2 && self.weapon == WEP_NEX));

	float oldspectatee_status;
	oldspectatee_status = self.spectatee_status;
	if(self.classname == "spectator")
		self.spectatee_status = num_for_edict(self.enemy);
	else if(self.classname == "observer")
		self.spectatee_status = num_for_edict(self);
	else
		self.spectatee_status = 0;
	if(self.spectatee_status != oldspectatee_status)
	{
		ClientData_Touch(self);
		if(g_race)
			race_InitSpectator();
	}

	if(self.teamkill_soundtime)
	if(time > self.teamkill_soundtime)
	{
		self.teamkill_soundtime = 0;

		entity oldpusher, oldself;

		oldself = self; self = self.teamkill_soundsource;
		oldpusher = self.pusher; self.pusher = oldself;

		PlayerSound(playersound_teamshoot, CHAN_VOICE, VOICETYPE_LASTATTACKER_ONLY);

		self.pusher = oldpusher;
		self = oldself;
	}

	if(self.taunt_soundtime)
	if(time > self.taunt_soundtime)
	{
		self.taunt_soundtime = 0;
		PlayerSound(playersound_taunt, CHAN_VOICE, VOICETYPE_AUTOTAUNT);
	}

	target_voicescript_next(self);
}

// on dragger:
.entity dragentity;
.float draggravity;
.float dragspeed; // speed of mouse wheel action
.float dragdistance; // distance of dragentity's draglocalvector from view_ofs
.vector draglocalvector; // local attachment vector of the dragentity
.float draglocalangle;
// on draggee:
.entity draggedby;
.float dragmovetype;
void Drag_Begin(entity dragger, entity draggee, vector touchpoint)
{
	float tagscale;

	draggee.dragmovetype = draggee.movetype;
	draggee.draggravity = draggee.gravity;
	draggee.movetype = MOVETYPE_WALK;
	draggee.gravity = 0.00001;
	draggee.flags &~= FL_ONGROUND;
	draggee.draggedby = dragger;

	dragger.dragentity = draggee;

	dragger.dragdistance = vlen(touchpoint - dragger.origin - dragger.view_ofs);
	dragger.draglocalangle = draggee.angles_y - dragger.v_angle_y;
	touchpoint = touchpoint - gettaginfo(draggee, 0);
	tagscale = pow(vlen(v_forward), -2);
	dragger.draglocalvector_x = touchpoint * v_forward * tagscale;
	dragger.draglocalvector_y = touchpoint * v_right * tagscale;
	dragger.draglocalvector_z = touchpoint * v_up * tagscale;

	dragger.dragspeed = 64;
}

void Drag_Finish(entity dragger)
{
	entity draggee;
	draggee = dragger.dragentity;
	if(dragger)
		dragger.dragentity = world;
	draggee.draggedby = world;
	draggee.movetype = draggee.dragmovetype;
	draggee.gravity = draggee.draggravity;

	switch(draggee.movetype)
	{
		case MOVETYPE_TOSS:
		case MOVETYPE_WALK:
		case MOVETYPE_STEP:
		case MOVETYPE_FLYMISSILE:
		case MOVETYPE_BOUNCE:
		case MOVETYPE_BOUNCEMISSILE:
			break;
		default:
			draggee.velocity = '0 0 0';
			break;
	}

	if((draggee.flags & FL_ITEM) && (vlen(draggee.velocity) < 32))
	{
		draggee.velocity = '0 0 0';
		draggee.flags |= FL_ONGROUND; // floating items are FUN
	}
}

float Drag_IsDraggable(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(draggee.classname == "func_bobbing")
		return FALSE;
	if(draggee.classname == "door") // FIXME find out why these must be excluded, or work around the problem (trying to drag these causes like 4 fps)
		return FALSE;
	if(draggee.classname == "plat")
		return FALSE;
	if(draggee.classname == "func_button")
		return FALSE;
	if(draggee.model == "")
		return FALSE;
	if(draggee.classname == "spectator")
		return FALSE;
	if(draggee.classname == "observer")
		return FALSE;
	if(draggee.classname == "exteriorweaponentity")
		return FALSE;

	return TRUE;
}

float Drag_MayChangeAngles(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(substring(draggee.model, 0, 1) == "*")
		return FALSE;
	return TRUE;
}

void Drag_MoveForward(entity dragger)
{
	dragger.dragdistance += dragger.dragspeed;
}

void Drag_SetSpeed(entity dragger, float s)
{
	dragger.dragspeed = pow(2, s);
}

void Drag_MoveBackward(entity dragger)
{
	dragger.dragdistance = max(0, dragger.dragdistance - dragger.dragspeed);
}

void Drag_Update(entity dragger)
{
	vector curorigin, neworigin, goodvelocity;
	float f;
	entity draggee;

	draggee = dragger.dragentity;
	draggee.flags &~= FL_ONGROUND;

	curorigin = gettaginfo(draggee, 0);
	curorigin = curorigin + v_forward * dragger.draglocalvector_x + v_right * dragger.draglocalvector_y + v_up * dragger.draglocalvector_z;
	makevectors(dragger.v_angle);
	neworigin = dragger.origin + dragger.view_ofs + v_forward * dragger.dragdistance;
	goodvelocity = (neworigin - curorigin) * (1 / frametime);

	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle > 180)
		dragger.draglocalangle += 360;
	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle <= -180)
		dragger.draglocalangle -= 360;

	f = min(frametime * 10, 1);
	draggee.velocity = draggee.velocity * (1 - f) + goodvelocity * f;

	if(Drag_MayChangeAngles(draggee))
		draggee.angles_y = draggee.angles_y * (1 - f) + (dragger.v_angle_y + dragger.draglocalangle) * f;
	
	draggee.ltime = max(servertime + serverframetime, draggee.ltime); // fixes func_train breakage

	te_lightning1(dragger, dragger.origin + dragger.view_ofs, curorigin);
}

float Drag_CanDrag(entity dragger)
{
	return (dragger.deadflag == DEAD_NO) || (dragger.classname == "player");
}

float Drag_IsDragging(entity dragger)
{
	if(!dragger.dragentity)
		return FALSE;
	if(wasfreed(dragger.dragentity) || dragger.dragentity.draggedby != dragger)
	{
		dragger.dragentity = world;
		return FALSE;
	}
	if(!Drag_CanDrag(dragger) || !Drag_IsDraggable(dragger.dragentity))
	{
		Drag_Finish(dragger);
		return FALSE;
	}
	return TRUE;
}

void Drag_MoveDrag(entity from, entity to)
{
	if(from.draggedby)
	{
		to.draggedby = from.draggedby;
		to.draggedby.dragentity = to;
		from.draggedby = world;
	}
}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
.float idlekick_lasttimeleft;
.float race_penalty;
.float race_penalty_nagged;
.float race_penalty_nagtime;
void PlayerPostThink (void)
{
	// Savage: Check for nameless players
	if (strlen(self.netname) < 1) {
		self.netname = "Player";
		stuffcmd(self, "seta _cl_name Player\n");
	}

	if(sv_maxidle && frametime)
	{
		// WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
		float timeleft;
		timeleft = ceil(sv_maxidle - (time - self.parm_idlesince));
		if(timeleft <= 0)
		{
			bprint("^3", self.netname, "^3 was kicked for idling.\n");
			announce(self, "announcer/robotic/terminated.wav");
			dropclient(self);
			return;
		}
		else if(timeleft <= 10)
		{
			if(timeleft != self.idlekick_lasttimeleft)
			{
				centerprint_atprio(self, CENTERPRIO_IDLEKICK, strcat("^3Stop idling!\n^3Disconnecting in ", ftos(timeleft), "..."));
				announce(self, strcat("announcer/robotic/", ftos(timeleft), ".wav"));
			}
		}
		else
		{
			centerprint_expire(self, CENTERPRIO_IDLEKICK);
		}
		self.idlekick_lasttimeleft = timeleft;
	}

	if(sv_cheats)
		if(Drag_CanDrag(self))
			if(self.BUTTON_DRAG)
				if(!self.dragentity)
					if(self.cursor_trace_ent)
						if(Drag_IsDraggable(self.cursor_trace_ent))
						{
							if(self.cursor_trace_ent.draggedby)
								Drag_Finish(self.cursor_trace_ent.draggedby);
							if(self.cursor_trace_ent.tag_entity)
								detach_sameorigin(self.cursor_trace_ent);
							Drag_Begin(self, self.cursor_trace_ent, self.cursor_trace_endpos);
						}
	
	if(Drag_IsDragging(self))
	{
		if(self.BUTTON_DRAG)
		{
			if(self.impulse == 10 || self.impulse == 15 || self.impulse == 18)
			{
				Drag_MoveForward(self);
				self.impulse = 0;
			}
			else if(self.impulse == 12 || self.impulse == 16 || self.impulse == 19)
			{
				Drag_MoveBackward(self);
				self.impulse = 0;
			}
			else if(self.impulse >= 1 && self.impulse <= 9)
			{
				Drag_SetSpeed(self, self.impulse - 1);
			}
			else if(self.impulse == 14)
			{
				Drag_SetSpeed(self, 9);
			}

			if(frametime)
				Drag_Update(self);
		}
		else
		{
			Drag_Finish(self);
		}
	}

	if(self.classname == "player") {
		CheckRules_Player();
		UpdateChatBubble();
		UpdateTeamBubble();
		if (self.impulse)
			ImpulseCommands();
		if (intermission_running)
			return;		// intermission or finale

		//if (TetrisPostFrame()) return;

		// restart countdown
			if(time < game_starttime) {
				if (!cvar("sv_ready_restart_after_countdown"))
				{
					if(self.movement != '0 0 0' && g_race && !g_race_qualifying)
					{
						if(time < game_starttime - 2)
						{
							if(!self.race_penalty_nagged)
							{
								// TODO better notification for this!
								self.race_penalty_nagtime = 0;
								self.race_penalty_nagged = 1;
							}
						}
						else if(!self.race_penalty)
						{
							self.race_penalty_nagtime = 0;
							self.race_penalty = time + 5;
						}
					}
					if(time > self.race_penalty_nagtime)
					{
						if(self.race_penalty > time)
						{
							centerprint_atprio(self, CENTERPRIO_IDLEKICK, "^1FIVE SECONDS PENALTY.");
						}
						else if(self.race_penalty_nagged && time < game_starttime - 2)
						{
							centerprint_atprio(self, CENTERPRIO_IDLEKICK, "^1DO NOT MOVE DURING THE COUNTDOWN.");
						}
						self.race_penalty_nagtime = time + self.cvar_scr_centertime * 0.6;
					}
					self.movetype = MOVETYPE_NONE;		
					self.velocity = '0 0 0';
					self.avelocity = '0 0 0';
					self.movement = '0 0 0';
				}
			}
			else if (time < self.race_penalty)
			{
				self.movetype = MOVETYPE_NONE;		
				self.velocity = '0 0 0';
				self.avelocity = '0 0 0';
				self.movement = '0 0 0';
			}
			else
			{
				//allow the player to move again if sv_ready_restart_after_countdown is not used and countdown is over
				if (!cvar("sv_ready_restart_after_countdown"))
				{
					if(self.movetype == MOVETYPE_NONE)
					{
						self.movetype = MOVETYPE_WALK;
					}
					self.race_penalty = 0;
					self.race_penalty_nagged = 0;
				}
			}
		GetPressedKeys();
	} else if (self.classname == "observer") {
		//do nothing
	} else if (self.classname == "spectator") {
		//do nothing
	}

	/*
	float i;
	for(i = 0; i < 1000; ++i)
	{
		vector end;
		end = self.origin + '0 0 1024' + 512 * randomvec();
		tracebox(self.origin, self.mins, self.maxs, end, MOVE_NORMAL, self);
		if(trace_fraction < 1)
		if(!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		{
			print("I HIT SOLID: ", vtos(self.origin), " -> ", vtos(end), "\n");
			break;
		}
	}
	*/

	Arena_Warmup();

	//pointparticles(particleeffectnum("machinegun_impact"), self.origin + self.view_ofs + '0 0 7', '0 0 0', 1);
}
