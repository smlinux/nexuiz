void info_player_start (void)
{
	info_player_deathmatch();
}

void info_player_deathmatch (void)
{
	self.classname = "info_player_deathmatch";
	relocate_spawnpoint();
}

float spawn_allbad;
float spawn_allgood;
entity Spawn_FilterOutBadSpots(entity firstspot, entity playerlist, float mindist, float teamcheck)
{
	local entity spot, player, nextspot, previousspot, newfirstspot;
	local float pcount;
	spot = firstspot;
	newfirstspot = world;
	previousspot = world;
	spawn_allgood = TRUE;
	spawn_allbad = TRUE;
	while (spot)
	{
		nextspot = spot.chain;
		// count team mismatches as bad spots

		local float spotactive;
		spotactive = 1;

		// filter out spots for assault
		if(spot.target != "") {
			local entity ent;
			ent = find(world, targetname, spot.target);
			while(ent) {
				if(ent.classname == "target_objective")
					if(ent.health < 0 || ent.health >= ASSAULT_VALUE_INACTIVE)
						spotactive = 0;
				ent = find(ent, targetname, spot.target);
			}
		}

		if (spot.team == teamcheck && spotactive > 0)
		{
			pcount = 0;
			player = playerlist;
			while (player)
			{
				if (player != self)
				if (vlen(player.origin - spot.origin) < mindist)
					pcount = pcount + 1;
				player = player.chain;
			}
			if (!pcount)
			{
				spawn_allbad = FALSE;
				if (newfirstspot)
					previousspot.chain = spot;
				else
					newfirstspot = spot;
				previousspot = spot;
				spot.chain = world;
			}
			else
				spawn_allgood = FALSE;
		}
		spot = nextspot;
	}
	// if we couldn't find ANY good points, return the original list
	if (!newfirstspot)
		newfirstspot = firstspot;
	return newfirstspot;
}

entity Spawn_RandomPoint(entity firstspot)
{
	local entity spot;
	local float numspots;
	// count number of spots
	numspots = 0;
	spot = firstspot;
	while (spot)
	{
		numspots = numspots + 1;
		spot = spot.chain;
	}
	// pick a random one
	numspots = numspots * random();
	spot = firstspot;
	while (spot.chain && numspots >= 1)
	{
		numspots = numspots - 1;
		spot = spot.chain;
	}
	return spot;
}

entity Spawn_FurthestPoint(entity firstspot, entity playerlist)
{
	local entity best, spot, player;
	local float bestrating, rating;
	best = world;
	bestrating = -1000000;
	spot = firstspot;
	while (spot)
	{
		rating = 1000000000;
		player = playerlist;
		while (player)
		{
			if (player != self)
				rating = min(rating, vlen(player.origin - spot.origin));
			player = player.chain;
		}
		rating = rating + random() * 16;
		if (bestrating < rating)
		{
			best = spot;
			bestrating = rating;
		}
		spot = spot.chain;
	}
	return best;
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
	local entity spot, firstspot, playerlist;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	teamcheck = 0;

	if(!anypoint && (g_ctf || g_assault))
		teamcheck = self.team;

	// get the list of players
	playerlist = findchain(classname, "player");
	// get the entire list of spots
	firstspot = findchain(classname, "info_player_deathmatch");
	// filter out the bad ones
	// (note this returns the original list if none survived)
	firstspot = Spawn_FilterOutBadSpots(firstspot, playerlist, 100, teamcheck);

	// there is 50/50 chance of choosing a random spot or the furthest spot
	// (this means that roughly every other spawn will be furthest, so you
	// usually won't get fragged at spawn twice in a row)
	if (arena_roundbased)
	{
		firstspot = Spawn_FilterOutBadSpots(firstspot, playerlist, 800, teamcheck);
		spot = Spawn_RandomPoint(firstspot);
	}
	else if (random() > 0.5 || spawn_allbad || spawn_allgood)
		spot = Spawn_RandomPoint(firstspot);
	else
		spot = Spawn_FurthestPoint(firstspot, playerlist);

	if (!spot)
	{
		if(cvar("spawn_debug"))
			GotoNextMap();
		else
			error ("PutClientInServer: no start points on level");
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

	if(self.flags & FL_NOTARGET) // we don't need LOD for spectators
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

void UpdateVoiceMessages();
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
	UpdateVoiceMessages();
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
	spot = SelectSpawnPoint (TRUE);
	RemoveGrapplingHook(self); // Wazat's Grappling Hook

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}

	DropAllRunes(self);
	kh_Key_DropAll(self, TRUE);

	if(self.flagcarried)
		DropFlag(self.flagcarried);

	WaypointSprite_PlayerDead();

	DistributeFragsAmongTeam(self, self.team, 1);

	if(self.frags <= 0 && self.frags > -666 && g_lms && self.killcount != -666)
		bprint ("^4", self.netname, "^4 has no more lives left\n");
	else if(self.killcount != -666)
		bprint ("^4", self.netname, "^4 is spectating now\n");

	self.classname = "observer";
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
	self.deaths = 0;
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
	self.oldorigin = self.origin;
	self.items = 0;
	self.model = "";
	self.modelindex = 0;
	self.weapon = 0;
	self.weaponmodel = "";
	self.weaponentity = world;
	self.killcount = -666;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	self.customizeentityforclient = Client_customizeentityforclient;

	if(g_arena)
	{
		if(self.frags != -2)
		{
			Spawnqueue_Insert(self);
		}
		else
		{
			Spawnqueue_Unmark(self);
			Spawnqueue_Remove(self);
		}
	}
	else if(!g_lms)
		self.frags = -666;
}


/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/
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
	if(g_lms && self.frags < 1)
		self.classname = "observer";

	if(g_arena)
	if(!self.spawned)
		self.classname = "observer";

	if(self.classname == "player") {
		entity	spot;

		spot = SelectSpawnPoint (FALSE);

		RemoveGrapplingHook(self); // Wazat's Grappling Hook

		self.classname = "player";
		self.iscreature = TRUE;
		self.movetype = MOVETYPE_WALK;
		self.solid = SOLID_SLIDEBOX;
		self.flags = FL_CLIENT;
		self.takedamage = DAMAGE_AIM;
		self.effects = 0;
		self.air_finished = time + 12;
		self.dmg = 2;

		self.ammo_shells = start_ammo_shells;
		self.ammo_nails = start_ammo_nails;
		self.ammo_rockets = start_ammo_rockets;
		self.ammo_cells = start_ammo_cells;
		self.health = start_health;
		self.armorvalue = start_armorvalue;
		self.items = start_items;
		self.switchweapon = start_switchweapon;
		self.weapon = 0;
		self.jump_interval = time;

		self.spawnshieldtime = time + cvar("g_spawnshieldtime");
		self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
		self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
		self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
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

		self.viewzoom = 0.6;
		self.has_zoomed = 0;

		self.customizeentityforclient = Client_customizeentityforclient;

		if(cvar("sv_defaultcharacter") == 1) {
			local string defaultmodel;
			defaultmodel = cvar_string("sv_defaultplayermodel");
			setmodel_lod (self, defaultmodel);
			self.skin = stof(cvar_string("sv_defaultplayerskin"));
		} else {
			self.playermodel = CheckPlayerModel(self.playermodel);
			setmodel_lod (self, self.playermodel);
			if(teams_matter)
			{
				float s;
				s = stof(self.playerskin);
				if(s >= 0 && s < 3)
					self.skin = s;
				else if(s == 6)
					self.skin = 6;
				else
					self.skin = 0;
			}
			else
				self.skin = stof(self.playerskin);
		}
		if(!teams_matter)
			if(strlen(cvar_string("sv_defaultplayercolors")))
				setcolor(self, cvar("sv_defaultplayercolors"));

		self.crouch = FALSE;
		self.view_ofs = PL_VIEW_OFS;
		setsize (self, PL_MIN, PL_MAX);
		self.spawnorigin = spot.origin;
		setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
		// don't reset back to last position, even if new position is stuck in solid
		self.oldorigin = self.origin;

		if(g_arena)
		{
			Spawnqueue_Remove(self);
			Spawnqueue_Mark(self);
		}

		self.event_damage = PlayerDamage;

		self.bot_attack = TRUE;

		self.statdraintime = time + 5;
		self.button0 = self.button1 = self.button2 = self.button3 = 0;

		if(self.killcount == -666) {
			self.killcount = 0;
			if(!g_arena)
			if(!g_lms)
				self.frags = 0;
		}

		self.cnt = WEP_LASER;
		self.nixnex_lastchange_id = -1;

		CL_SpawnWeaponentity();
		self.alpha = default_player_alpha;
		self.colormod = '1 1 1' * cvar("g_player_brightness");
		self.exteriorweaponentity.alpha = default_weapon_alpha;

		self.lms_nextcheck = time + cvar("g_lms_campcheck_interval")*2;
		self.lms_traveled_distance = 0;

		if(cvar("spawn_debug"))
		{
			sprint(self, strcat("spawnpoint origin:  ", vtos(spot.origin), "\n"));
			remove(spot);	// usefull for checking if there are spawnpoints, that let drop through the floor
		}

		//stuffcmd(self, "chase_active 0");
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");

		if (cvar("g_spawnsound"))
			sound (self, CHAN_AUTO, "misc/spawn.wav", 1, ATTN_NORM);

		if(g_assault) {
			if(self.team == assault_attacker_team)
				centerprint(self, "You are attacking!\n");
			else
				centerprint(self, "You are defending!\n");
		}

	} else if(self.classname == "observer") {
		PutObserverInServer ();
	}
}

/*
=============
SetNewParms
=============
*/
void SetNewParms (void)
{

}

/*
=============
SetChangeParms
=============
*/
void SetChangeParms (void)
{

}

/*
=============
ClientKill

Called when a client types 'kill' in the console
=============
*/
void ClientKill (void)
{
	Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');
}

void FixClientCvars(entity e)
{
	float t;
	// send prediction settings to the client
	stuffcmd(e, "\nin_bindmap 0 0\n");
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

	// notify about available teams
	if(teamplay)
	{
		CheckAllowedTeams(e);
		t = 0; if(c1 >= 0) t |= 1; if(c2 >= 0) t |= 2; if(c3 >= 0) t |= 4; if(c4 >= 0) t |= 8;
		stuffcmd(e, strcat("set _teams_available ", ftos(t), "\n"));
	}
	else
		stuffcmd(e, "set _teams_available 0\n");
}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
string ColoredTeamName(float t);
//void dom_player_join_team(entity pl);
void ClientConnect (void)
{
	local string s;
	float wep;

	if(Ban_IsClientBanned(self))
	{
		s = strcat("^1NOTE:^7 banned client ", self.netaddress, " just tried to enter\n");
		dropclient(self);
		bprint(s);
		return;
	}

	self.classname = "player_joining";
	self.flags = self.flags | FL_CLIENT;
	self.version_nagtime = time + 10 + random() * 10;

	if(player_count<0)
	{
		dprint("BUG player count is lower than zero, this cannot happen!\n");
		player_count = 0;
	}

	bot_clientconnect();

	//if(g_domination)
	//	dom_player_join_team(self);

	//JoinBestTeam(self, FALSE);

	if((cvar("sv_spectate") == 1 && !g_lms) || cvar("g_campaign")) {
		self.classname = "observer";
	} else {
		self.classname = "player";
		campaign_bots_may_start = 1;
	}

	self.playerid = (playerid_last = playerid_last + 1);
	if(cvar("sv_eventlog"))
	{
		if(clienttype(self) == CLIENTTYPE_REAL)
			s = "player";
		else
			s = "bot";
		GameLogEcho(strcat(":join:", ftos(self.playerid), ":", s, ":", self.netname), TRUE);
		s = strcat(":team:", ftos(self.playerid), ":");
		s = strcat(s, ftos(self.team));
		GameLogEcho(s, FALSE);
	}

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

	stuffcmd(self, strcat("exec maps/", mapname, ".cfg\n"));
	// TODO: is this being used for anything else than cd tracks?
	// Remember: SVC_CDTRACK exists. Maybe it should be used.

	FixClientCvars(self);

	// waypoint sprites
	WaypointSprite_InitClient(self);

	// Wazat's grappling hook
	SetGrappleHookBindings();

	// get autoswitch state from player when he toggles it
	stuffcmd(self, "alias autoswitch \"set cl_autoswitch $1 ; cmd autoswitch $1\"\n");

	// get version info from player
	stuffcmd(self, "cmd clientversion $gameversion\n");

	// send all weapon info strings
	stuffcmd(self, "register_bestweapon clear\n"); // clear the Quake stuff
	wep = WEP_FIRST;
	while (wep <= WEP_LAST)
	{
		weapon_action(wep, WR_REGISTER);
		wep = wep + 1;
	}

	// get other cvars from player
	GetCvars(0);

	// set cvar for team scoreboard
	if (teams_matter)
	{
		local float t;
		t = cvar("teamplay");
		// we have to stuff the correct teamplay value because if this is a listen server, this changes the teamplay mode of the server itself, which is bad
		stuffcmd(self, strcat("set teamplay ", ftos(t), "\n"));
	}
	else
		stuffcmd(self, "set teamplay 0\n");

	if(g_lms)
	{
		self.frags = LMS_NewPlayerLives();
		if(!self.frags)
			self.frags = -666;
	}
	else if(g_arena)
	{
		self.classname = "observer";
		Spawnqueue_Insert(self);
	}

	bot_relinkplayerlist();

	self.jointime = time;
}

/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
void(entity e) DropFlag;
.entity chatbubbleentity;
.entity teambubbleentity;
void ClientDisconnect (void)
{
	float save;
	if(cvar("sv_eventlog"))
		GameLogEcho(strcat(":part:", ftos(self.playerid)), FALSE);
	bprint ("^4",self.netname);
	bprint ("^4 disconnected\n");

	if (self.chatbubbleentity)
	{
		remove (self.chatbubbleentity);
		self.chatbubbleentity = world;
	}

	if (self.teambubbleentity)
	{
		remove (self.teambubbleentity);
		self.teambubbleentity = world;
	}

	WaypointSprite_PlayerGone();

	DropAllRunes(self);
	kh_Key_DropAll(self, TRUE);

	if(self.flagcarried)
		DropFlag(self.flagcarried);

	DistributeFragsAmongTeam(self, self.team, 1);

	save = self.flags;
	self.flags = self.flags - (self.flags & FL_CLIENT);
	bot_relinkplayerlist();
	self.flags = save;

	// remove laserdot
	if(self.weaponentity)
		if(self.weaponentity.lasertarget)
			remove(self.weaponentity.lasertarget);

	if(g_arena)
	{
		Spawnqueue_Unmark(self);
		Spawnqueue_Remove(self);
	}

	// free cvars
	GetCvars(-1);
}

.float buttonchat;
void() ChatBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.chatbubbleentity != self)
	{
		self.owner.chatbubbleentity = world;
		remove(self);
		return;
	}
	setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1');
	if (self.owner.buttonchat && !self.owner.deadflag)
		self.model = self.mdl;
	else
		self.model = "";
};

void() UpdateChatBubble =
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
		setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		self.chatbubbleentity.mdl = self.chatbubbleentity.model;
		self.chatbubbleentity.model = "";
		self.chatbubbleentity.effects = EF_LOWPRECISION;
	}
}


void() TeamBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.teambubbleentity != self)
	{
		self.owner.teambubbleentity = world;
		remove(self);
		return;
	}
//	setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1');  // bandwidth hog. setattachment does this now
	if (self.owner.buttonchat || self.owner.deadflag)
		self.model = "";
	else
		self.model = self.mdl;

};

float() TeamBubble_customizeentityforclient
{
	return (self.owner != other && self.owner.team == other.team && other.killcount > -666);
}

void() UpdateTeamBubble =
{
	if (!self.modelindex || !cvar("teamplay"))
		return;
	// spawn a teambubble entity if needed
	if (!self.teambubbleentity && cvar("teamplay"))
	{
		self.teambubbleentity = spawn();
		self.teambubbleentity.owner = self;
		self.teambubbleentity.exteriormodeltoclient = self;
		self.teambubbleentity.think = TeamBubbleThink;
		self.teambubbleentity.nextthink = time;
		setmodel(self.teambubbleentity, "models/misc/teambubble.spr"); // precision set below
//		setorigin(self.teambubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.teambubbleentity, self.teambubbleentity.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.teambubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.teambubbleentity.mdl = self.teambubbleentity.model;
		self.teambubbleentity.model = self.teambubbleentity.mdl;
		self.teambubbleentity.customizeentityforclient = TeamBubble_customizeentityforclient;
		self.teambubbleentity.effects = EF_LOWPRECISION;
	}
}

// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
/*void() UpdateColorModHack =
{
	local float c;
	c = self.clientcolors & 15;
	// LordHavoc: only bothering to support white, green, red, yellow, blue
	     if (teamplay == 0) self.colormod = '0 0 0';
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
	PutClientInServer();
}

void player_powerups (void)
{
	if (g_minstagib)
	{
		self.effects = EF_FULLBRIGHT;
		if (self.items & IT_STRENGTH)
		{
			if (time > self.strength_finished)
			{
				self.alpha = default_player_alpha;
				self.exteriorweaponentity.alpha = default_weapon_alpha;
				self.items = self.items - (self.items & IT_STRENGTH);
				sprint(self, "^3Invisibility has worn off\n");
			}
		}
		else
		{
			if (time < self.strength_finished)
			{
				self.alpha = cvar("g_minstagib_invis_alpha");
				self.exteriorweaponentity.alpha = cvar("g_minstagib_invis_alpha");
				self.items = self.items | IT_STRENGTH;
				sprint(self, "^3You are invisible\n");
			}
		}

		if (self.items & IT_INVINCIBLE)
		{
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

	self.effects = self.effects - (self.effects & (EF_RED | EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT));
	if (self.items & IT_STRENGTH)
	{
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
	float maxh, maxa, limith, limita, max_mod, regen_mod, rot_mod, limit_mod;
	maxh = cvar("g_balance_health_stable");
	maxa = cvar("g_balance_armor_stable");
	limith = cvar("g_balance_health_limit");
	limita = cvar("g_balance_armor_limit");

	if (g_minstagib || (g_lms && !cvar("g_lms_regenerate")))
		return;

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
	limith = limith * limit_mod;
	limita = limita * limit_mod;

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
	if (self.armorvalue > limita)
		self.armorvalue = limita;

	// if player rotted to death...  die!
	if(self.health < 1)
		self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
}

/*
======================
spectate mode routines
======================
*/
void SpectateCopy(entity spectatee) {
	self.armortype = spectatee.armortype;
	self.armorvalue = spectatee.armorvalue;
	self.currentammo = spectatee.currentammo;
	self.effects = spectatee.effects;
	self.health = spectatee.health;
	self.impulse = 0;
	self.items = spectatee.items;
	self.punchangle = spectatee.punchangle;
	self.view_ofs = spectatee.view_ofs;
	self.v_angle = spectatee.v_angle;
	self.viewzoom = spectatee.viewzoom;
	self.velocity = spectatee.velocity;
	self.dmg_take = spectatee.dmg_take;
	self.dmg_save = spectatee.dmg_save;
	self.dmg_inflictor = spectatee.dmg_inflictor;
	self.angles = spectatee.v_angle;
	self.fixangle = TRUE;
	setorigin(self, spectatee.origin);
	setsize(self, spectatee.mins, spectatee.maxs);
}

void SpectateUpdate() {
	if(!self.enemy)
			PutObserverInServer();

	if (self != self.enemy) {
		if(self.enemy.flags & FL_NOTARGET)
			PutObserverInServer();
		SpectateCopy(self.enemy);
		//msg_entity = self;
		//WriteByte(MSG_ONE, SVC_SETANGLE);
		//WriteAngle(MSG_ONE, self.enemy.v_angle_x);
		//WriteAngle(MSG_ONE, self.enemy.v_angle_y);
		//WriteAngle(MSG_ONE, self.enemy.v_angle_z);
	}
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
		SpectateUpdate();
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
				play2(self, strcat("announcer/robotic/", ftos(number), ".ogg"));
		}
	}
}

void LeaveSpectatorMode()
{
	if(!cvar("teamplay") || cvar("g_campaign") || cvar("g_balance_teams")) {
		self.classname = "player";
		if(cvar("g_campaign") || cvar("g_balance_teams"))
			JoinBestTeam(self, 0);
		if(cvar("g_campaign"))
			campaign_bots_may_start = 1;
		PutClientInServer();
		if(!(self.flags & FL_NOTARGET))
			bprint ("^4", self.netname, "^4 is playing now\n");
		centerprint(self,"");
		return;
	} else {
		stuffcmd(self,"menu_showteamselect\n");
		return;
	}
}

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
void() ctf_setstatus;
.float vote_nagtime;
void PlayerPreThink (void)
{
	// version nagging
	if(self.version_nagtime)
		if(self.cvar_g_nexuizversion)
			if(time > self.version_nagtime)
			{
				if(strstr(self.cvar_g_nexuizversion, "svn", 0) < 0)
					if(self.cvar_g_nexuizversion != cvar_string("g_nexuizversion"))
					{
						dprint("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "\n");
						sprint(self, strcat("\{1}^1NOTE: ^7the server is running ^3Nexuiz ", cvar_string("g_nexuizversion"), "^7, you have ^3Nexuiz ", self.cvar_g_nexuizversion, "\n"));
					}
				self.version_nagtime = 0;
			}

	// vote nagging
	if(self.cvar_scr_centertime)
		if(time > self.vote_nagtime)
		{
			VoteNag();
			self.vote_nagtime = time + self.cvar_scr_centertime * 0.6;
		}

	// GOD MODE info
	if(!(self.flags & FL_GODMODE)) if(self.max_armorvalue)
	{
		sprint(self, strcat("godmode saved you ", ftos(self.max_armorvalue), " units of damage, cheater!\n"));
		self.max_armorvalue = 0;
	}

	if(self.classname == "player") {
		local vector m1, m2;

//		if(self.netname == "Wazat")
//			bprint(self.classname, "\n");

		CheckRules_Player();

		if(self.button7)
			PrintWelcomeMessage(self);

		if(g_lms || !cvar("sv_spectate"))
		if((time - self.jointime) <= cvar("welcome_message_time"))
			PrintWelcomeMessage(self);

		if (intermission_running)
		{
			IntermissionThink ();	// otherwise a button could be missed between
			return;					// the think tics
		}

		if(time > self.teleport_time)
		{
			self.effects = self.effects - (self.effects & EF_NODRAW);
			if(self.weaponentity)
				self.weaponentity.flags = self.weaponentity.flags - (self.weaponentity.flags & EF_NODRAW);
		}

		Nixnex_GiveCurrentWeapon();

		if(frametime > 0) // don't do this in cl_movement frames, just in server ticks
			UpdateSelectedPlayer();

		if (self.deadflag != DEAD_NO)
		{
			float button_pressed, force_respawn;
			player_anim();
			button_pressed = (self.button0 || self.button2 || self.button3 || self.button6 || self.buttonuse);
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
					respawn();
			}
			ShowRespawnCountdown();
			return;
		}

		if(g_lms && !self.deadflag && cvar("g_lms_campcheck_interval"))
		{
			vector dist;

			// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
			dist = self.oldorigin - self.origin;
			dist_z = 0;
			self.lms_traveled_distance += fabs(vlen(dist));

			if((cvar("g_campaign") && !campaign_bots_may_start) || (time < restart_countdown))
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

		if (self.button5 && !self.hook.state)
		{
			if (!self.crouch)
			{
				self.crouch = TRUE;
				self.view_ofs = PL_CROUCH_VIEW_OFS;
				setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
				player_setanim(self.anim_duck, FALSE, TRUE, TRUE);
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

		if(cvar("sv_defaultcharacter") == 1) {
			local string defaultmodel;
			defaultmodel = cvar_string("sv_defaultplayermodel");

			if (defaultmodel != self.model)
			{
				m1 = self.mins;
				m2 = self.maxs;
				setmodel_lod (self, defaultmodel);
				setsize (self, m1, m2);
			}

			if (self.skin != cvar("sv_defaultplayerskin"))
				self.skin = cvar("sv_defaultplayerskin");
		} else {
			if (self.playermodel != self.model)
			{
				self.playermodel = CheckPlayerModel(self.playermodel);
				m1 = self.mins;
				m2 = self.maxs;
				setmodel_lod (self, self.playermodel);
				setsize (self, m1, m2);
			}

			if(teams_matter)
			{
				if (self.skin != math_mod(stof(self.playerskin), NUM_PLAYERSKINS_TEAMPLAY))
					self.skin = math_mod(stof(self.playerskin), NUM_PLAYERSKINS_TEAMPLAY);
			}
			else
			{
				if (self.skin != stof(self.playerskin))
					self.skin = stof(self.playerskin);
			}
		}
		if(!teams_matter)
			if(strlen(cvar_string("sv_defaultplayercolors")))
				if(self.clientcolors != cvar("sv_defaultplayercolors"))
					setcolor(self, cvar("sv_defaultplayercolors"));

		GrapplingHookFrame();

		W_WeaponFrame();

		{
			float zoomfactor, zoomspeed, zoomdir;
			zoomfactor = self.cvar_cl_zoomfactor;
			if(zoomfactor < 1 || zoomfactor > 16)
				zoomfactor = 2.5;
			zoomspeed = self.cvar_cl_zoomspeed;
			if(zoomspeed >= 0) // < 0 is instant zoom
				if(zoomspeed < 0.5 || zoomspeed > 16)
					zoomspeed = 3.5;

			zoomdir = self.button4;
			if(self.button3)
				if(self.weapon == WEP_NEX)
					if(!g_minstagib)
						zoomdir = 1;

			if(zoomdir)
				self.has_zoomed = 1;

			if(self.has_zoomed)
			{
				if(zoomspeed <= 0) // instant zoom
				{
					if(zoomdir)
						self.viewzoom = 1 / zoomfactor;
					else
						self.viewzoom = 1;
				}
				else
				{
					// geometric zoom would be:
					//   self.viewzoom = bound(1 / zoomfactor, self.viewzoom * pow(zoomfactor, (zoomdir ? -1 : 1) * frametime * zoomspeed), 1);
					// however, testing showed that arithmetic/harmonic zoom works better
					if(zoomdir)
						// self.viewzoom = 1 / bound(1, 1 / self.viewzoom + (zoomdir ? 1 : -1) * frametime * zoomspeed * (zoomfactor - 1), zoomfactor);
						// zoom in = arithmetic: 1x, 2x, 3x, 4x, ..., 8x
						self.viewzoom = 1 / bound(1, 1 / self.viewzoom + frametime * zoomspeed * (zoomfactor - 1), zoomfactor);
					else
						// self.viewzoom = bound(1 / zoomfactor, self.viewzoom + (zoomdir ? -1 : 1) * frametime * zoomspeed * (1 - 1 / zoomfactor), 1);
						// zoom out = harmonic: 8/1x, 8/2x, 8/3x, 8/4x, ..., 8/8x
						self.viewzoom = bound(1 / zoomfactor, self.viewzoom + frametime * zoomspeed * (1 - 1 / zoomfactor), 1);
				}
			}
			else
				self.viewzoom = min(1, self.viewzoom + frametime); // spawn zoom-in
		}

		player_powerups();
		player_regen();
		player_anim();

		if (g_minstagib)
			minstagib_ammocheck();

		ctf_setstatus();
		kh_setstatus();

		//self.angles_y=self.v_angle_y + 90;   // temp

		//if (TetrisPreFrame()) return;
	} else if(gameover) {
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between
		return;
	} else if(self.classname == "observer") {

		if (self.flags & FL_JUMPRELEASED) {
			if (self.button2 && self.version == cvar("gameversion")) {
				self.welcomemessage_time = 0;
				self.flags = self.flags - FL_JUMPRELEASED;
				LeaveSpectatorMode();
				return;
			} else if(self.button0 && self.version == cvar("gameversion")) {
				self.welcomemessage_time = 0;
				self.flags = self.flags - FL_JUMPRELEASED;
				if(SpectateNext() == 1) {
					self.classname = "spectator";
				}
			}
        	} else {
        		if (!(self.button0 || self.button2)) {
				self.flags = self.flags | FL_JUMPRELEASED;
        		}
		}
		PrintWelcomeMessage(self);
	} else if(self.classname == "spectator") {
		if (self.flags & FL_JUMPRELEASED) {
			if (self.button2 && self.version == cvar("gameversion")) {
				self.welcomemessage_time = 0;
				self.flags = self.flags - FL_JUMPRELEASED;
				LeaveSpectatorMode();
				return;
			} else if(self.button0) {
				self.welcomemessage_time = 0;
				self.flags = self.flags - FL_JUMPRELEASED;
				if(SpectateNext() == 1) {
					self.classname = "spectator";
				} else {
					self.classname = "observer";
					PutClientInServer();
				}
			} else if (self.button3) {
				self.welcomemessage_time = 0;
				self.flags = self.flags - FL_JUMPRELEASED;
				self.classname = "observer";
				PutClientInServer();
			} else {
				SpectateUpdate();
			}
	        } else {
	        	if (!(self.button0 || self.button3)) {
				self.flags = self.flags | FL_JUMPRELEASED;
        		}
		}
		PrintWelcomeMessage(self);
		self.flags = self.flags | FL_CLIENT | FL_NOTARGET;
	}
}


/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
void PlayerPostThink (void)
{
	// Savage: Check for nameless players
	if (strlen(self.netname) < 1) {
		self.netname = "Player";
		stuffcmd(self, "seta _cl_name Player\n");
	}

	if(self.classname == "player") {
		CheckRules_Player();
		UpdateChatBubble();
		UpdateTeamBubble();
		if (self.impulse)
			ImpulseCommands();
		if (intermission_running)
			return;		// intermission or finale

		//PrintWelcomeMessage(self);
		//if (TetrisPostFrame()) return;
	
		// restart countdown
		if(time < restart_countdown)
		{
			string s;
			float sec;

			sec = ceil(restart_countdown-time);
			s = strcat(NEWLINES, "^1Game starts in ", ftos(sec), " seconds");
			centerprint(self, s);
			self.movetype = MOVETYPE_NONE;		
			self.velocity = '0 0 0';
			self.avelocity = '0 0 0';
			self.movement = '0 0 0';
		}
		else if(self.movetype == MOVETYPE_NONE)
		{
			self.movetype = MOVETYPE_WALK;
			centerprint(self, "\n");
		}
	} else if (self.classname == "observer") {
		//do nothing
	} else if (self.classname == "spectator") {
		//do nothing
	}

	Arena_Warmup();
}
