void info_player_start (void)
{
	self.classname = "info_player_deathmatch";
}

void info_player_deathmatch (void)
{
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
		if (spot.team == teamcheck)
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
	string spotname;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	spotname = "info_player_deathmatch";
	teamcheck = 0;

	if(!anypoint && cvar("g_ctf") )
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
	if (random() > 0.5 || spawn_allbad || spawn_allgood)
		spot = Spawn_RandomPoint(firstspot);
	else
		spot = Spawn_FurthestPoint(firstspot, playerlist);

	if (!spot)
		error ("PutClientInServer: no start points on level");

	return spot;
}

/*
=============
CheckPlayerModel

Checks if the argument string can be a valid playermodel.
Returns a valid one in doubt.
=============
*/
string CheckPlayerModel(string plyermodel) {
	if( substring(plyermodel,0,14) != "models/player/") plyermodel = "models/player/marine.zym";

	/* Possible Fixme: Check if server can open the model?
	   This would kill custom models, however. */

	return plyermodel;
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
	spot = SelectSpawnPoint (FALSE);
	RemoveGrapplingHook(self); // Wazat's Grappling Hook

	if(self.frags == 0 && cvar("g_lms") && self.killcount != -666)
		bprint (strcat("^4", self.netname, "^4 has no more lives left\n"));
	else if(self.killcount != -666)
		bprint (strcat("^4", self.netname, "^4 is spectating now\n"));

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
	self.dead_time = 0;
	self.dead_frame = 0;
	self.die_frame = 0;
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
	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 14));
	self.oldorigin = self.origin;
	self.items = 0;
	self.model = "";
	self.modelindex = 0;
	self.weapon = 0;
	self.weaponmodel = "";
	self.weaponframe = 0;
	self.weaponentity = world;
	self.killcount = -666;
	if(!cvar("g_lms"))
		self.frags = -666;
 	//stuffcmd(self, "set viewsize 120 \n");
//	bprint (strcat("^4", self.netname, "^4 is spectating now\n"));
}


/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/
void PutClientInServer (void)
{
	if(clienttype(self) ==  CLIENTTYPE_BOT)
	{
		self.classname = "player";
	}

	// player is dead and becomes observer
	if(cvar("g_lms") && self.frags < 1)
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
		self.health = cvar("g_balance_health_start");
		self.armorvalue = cvar("g_balance_armor_start");
		self.spawnshieldtime = time + cvar("g_spawnshieldtime");
		self.pauserotarmor_finished = time + 10;
		self.pauserothealth_finished = time + 10;
		self.pauseregen_finished = 0;
		self.damageforcescale = 2;
		self.death_time = 0;
		self.dead_time = 0;
		self.dead_frame = 0;
		self.die_frame = 0;
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
		self.weapon = 0;
		self.switchweapon = 0;
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

		if(cvar("sv_defaultcharacter") == 1) {
			local string defaultmodel;
			defaultmodel = CheckPlayerModel(cvar_string("sv_defaultplayermodel"));

			precache_model (defaultmodel);
			setmodel (self, defaultmodel);
			self.skin = stof(cvar_string("sv_defaultplayerskin"));
		} else {
			self.playermodel = CheckPlayerModel(self.playermodel);

			precache_model (self.playermodel);
			setmodel (self, self.playermodel);
			self.skin = stof(self.playerskin);

		}

		self.crouch = FALSE;
		self.view_ofs = PL_VIEW_OFS;
		setsize (self, PL_MIN, PL_MAX);
		setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
		// don't reset back to last position, even if new position is stuck in solid
		self.oldorigin = self.origin;

		if(cvar("g_lms"))
		{
			self.ammo_shells = cvar("g_lms_start_ammo_shells");
			self.ammo_nails = cvar("g_lms_start_ammo_nails");
			self.ammo_rockets = cvar("g_lms_start_ammo_rockets");
			self.ammo_cells = cvar("g_lms_start_ammo_cells");
			self.health = cvar("g_lms_start_health");
			self.armorvalue = cvar("g_lms_start_armor");
		}
		else if (cvar("g_use_ammunition")) {
			self.ammo_shells = cvar("g_start_ammo_shells");
			self.ammo_nails = cvar("g_start_ammo_nails");
			self.ammo_rockets = cvar("g_start_ammo_rockets");
			self.ammo_cells = cvar("g_start_ammo_cells");
		} else {
			self.ammo_shells = 999;
			self.ammo_nails = 999;
			self.ammo_rockets = 999;
			self.ammo_cells = 999;
		}

		self.items = 0;
		if (cvar("g_start_weapon_laser") || cvar("g_lms"))
		{
			self.items = self.items | IT_LASER;
			self.switchweapon = WEP_LASER;
		}
		if (cvar("g_start_weapon_shotgun") || cvar("g_lms"))
		{
			self.items = self.items | IT_SHOTGUN;
			self.switchweapon = WEP_SHOTGUN;
		}
		if (cvar("g_start_weapon_uzi") || cvar("g_lms"))
		{
			self.items = self.items | IT_UZI;
			self.switchweapon = WEP_UZI;
		}
		if (cvar("g_start_weapon_grenadelauncher") || cvar("g_lms"))
		{
			self.items = self.items | IT_GRENADE_LAUNCHER;
			self.switchweapon = WEP_GRENADE_LAUNCHER;
		}
		if (cvar("g_start_weapon_electro") || cvar("g_lms"))
		{
			self.items = self.items | IT_ELECTRO;
			self.switchweapon = WEP_ELECTRO;
		}
		if (cvar("g_start_weapon_crylink") || cvar("g_lms"))
		{
			self.items = self.items | IT_CRYLINK;
			self.switchweapon = WEP_CRYLINK;
		}
		if (cvar("g_start_weapon_nex") || cvar("g_lms"))
		{
			self.items = self.items | IT_NEX;
			self.switchweapon = WEP_NEX;
		}
		if (cvar("g_start_weapon_hagar") || cvar("g_lms"))
		{
			self.items = self.items | IT_HAGAR;
			self.switchweapon = WEP_HAGAR;
		}
		if (cvar("g_start_weapon_rocketlauncher") || cvar("g_lms"))
		{
			self.items = self.items | IT_ROCKET_LAUNCHER;
			self.switchweapon = WEP_ROCKET_LAUNCHER;
		}

		if(cvar("g_instagib"))
		{
			self.items = IT_NEX;
			self.switchweapon = WEP_NEX;
			self.ammo_cells = 999;
		}

		if(cvar("g_rocketarena"))
		{
			self.items = IT_ROCKET_LAUNCHER;
			self.switchweapon = WEP_ROCKET_LAUNCHER;
			self.ammo_rockets = 999;
		}

		if(cvar("g_nixnex"))
		{
			self.items = 0;
			// will be done later
		}

		if(cvar("g_minstagib"))
		{
			self.health = 100;
			self.armorvalue = 0;
			self.items = IT_NEX;
			self.switchweapon = WEP_NEX;
			self.ammo_cells = cvar("g_minstagib_ammo_start");
			self.extralives = 0;
			self.jump_interval = time;
		}

		self.event_damage = PlayerDamage;

		self.statdraintime = time + 5;
		self.button0 = self.button1 = self.button2 = self.button3 = 0;

		if(self.killcount == -666) {
			self.killcount = 0;
			self.frags = 0;
		}

		self.cnt = WEP_LASER;
		self.nixnex_lastchange_id = -1;

		/*
		W_UpdateWeapon();
		W_UpdateAmmo();
		*/
		CL_SpawnWeaponentity();
		self.alpha = 1;
		self.exteriorweaponentity.alpha = 1;

		self.lms_nextcheck = time + cvar("g_lms_campcheck_interval")*2;
		self.lms_traveled_distance = 0;

		//stuffcmd(self, "chase_active 0");
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");
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
	self.classname = "player_joining";

	if(player_count<0) player_count = 0;

	//if(cvar("g_domination"))
	//	dom_player_join_team(self);

	//JoinBestTeam(self, FALSE);

	if(cvar("sv_spectate") == 1 && !cvar("g_lms")) {
		self.classname = "observer";
	} else {
		self.classname = "player";
	}

	//stuffcmd(self, "set tmpviewsize $viewsize \n");

	bprint ("^4",self.netname);
	bprint ("^4 connected");

	if(cvar("g_domination") || cvar("g_ctf"))
	{
		bprint(" and joined the ");
		bprint(ColoredTeamName(self.team));
	}

	bprint("\n");

	self.welcomemessage_time = time + cvar("welcome_message_time");
	self.welcomemessage_time2 = 0;

	stuffcmd(self, strcat("exec maps/", mapname, ".cfg\n"));
	// send prediction settings to the client
	stuffcmd(self, strcat("cl_movement_maxspeed ", ftos(cvar("sv_maxspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_maxairspeed ", ftos(cvar("sv_maxairspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_accelerate ", ftos(cvar("sv_accelerate")), "\n"));
	stuffcmd(self, strcat("cl_movement_friction ", ftos(cvar("sv_friction")), "\n"));
	stuffcmd(self, strcat("cl_movement_stopspeed ", ftos(cvar("sv_stopspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_jumpvelocity ", ftos(cvar("g_balance_jumpheight")), "\n"));
	stuffcmd(self, strcat("cl_movement_stepheight ", ftos(cvar("sv_stepheight")), "\n"));
	stuffcmd(self, strcat("set cl_movement_friction_on_land ", ftos(cvar("sv_friction_on_land")), "\n"));
	stuffcmd(self, strcat("cl_movement_edgefriction 0\n"));
	// Wazat's grappling hook
	SetGrappleHookBindings();

	// get autoswitch state from player
	stuffcmd(self, "alias autoswitch \"set cl_autoswitch $1; cmd autoswitch $1\"\n");
	stuffcmd(self, "cmd autoswitch $cl_autoswitch\n");

	// get version info from player
	stuffcmd(self, "cmd clientversion $gameversion\n");

	// set cvar for team scoreboard
	stuffcmd(self, strcat("set teamplay ", ftos(teams_matter), "\n"));

	if(cvar("g_lms"))
	{
		self.frags = cvar("fraglimit");
		// no fraglimit was set, so player gets 999 lives
		if(self.frags < 1)
			self.frags = 999;

		// disallow player to join after the worst player has lost g_lms_last_join lives
		// if "g_lms_join_anytime" new players spawn with same amount of lives as the worst active player
		if(((cvar("fraglimit") - cvar("g_lms_last_join")) > lms_lowest_lives && !cvar("g_lms_join_anytime")) || lms_lowest_lives < 1)
		{
			self.frags = -1;
			lms_dead_count += 1;
		}
		else if(cvar("fraglimit") > lms_lowest_lives)
		{
			self.frags = lms_lowest_lives;
		}
	}

	player_count += 1;
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

	DropAllRunes(self);

	if(self.flagcarried)
		DropFlag(self.flagcarried);

	// decrease player count for lms
	player_count -= 1;
	// player was dead, decrease dead count
	if(cvar("g_lms") && self.frags < 1)
		lms_dead_count -= 1;
	//stuffcmd(self, "set viewsize $tmpviewsize \n");
}

.float buttonchat;
void() ChatBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.chatbubbleentity != self)
	{
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
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr");
		setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		self.chatbubbleentity.mdl = self.chatbubbleentity.model;
		self.chatbubbleentity.model = "";
	}
}


void() TeamBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.teambubbleentity != self)
	{
		remove(self);
		return;
	}
//	setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1');  // bandwidth hog. setattachment does this now
	if (self.owner.buttonchat || self.owner.deadflag)
		self.model = "";
	else
		self.model = self.mdl;

};

.float() customizeentityforclient;
float() ChatBubble_customizeentityforclient = {return (self.owner.team == other.team && other.killcount > -666);};

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
		setmodel(self.teambubbleentity, "models/misc/teambubble.spr");
//		setorigin(self.teambubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.teambubbleentity, self.teambubbleentity.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.teambubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.teambubbleentity.mdl = self.teambubbleentity.model;
		self.teambubbleentity.model = self.teambubbleentity.mdl;
		self.teambubbleentity.customizeentityforclient = ChatBubble_customizeentityforclient;
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

void UpdatePlayerColors () {
	if(self.weaponentity) {
		self.weaponentity.colormap = self.colormap;
		self.exteriorweaponentity.colormap = self.colormap;
   	}
}
/*
=============
PlayerJump

When you press the jump key
=============
*/
void PlayerJump (void)
{
	float mjumpheight;

	mjumpheight = cvar("g_balance_jumpheight");
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 200;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		return;
	}


	if (!(self.flags & FL_ONGROUND))
		return;

	if (!(self.flags & FL_JUMPRELEASED))
		return;

	if(cvar("g_runematch"))
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				mjumpheight = mjumpheight * cvar("g_balance_rune_speed_combo_jumpheight");
			else
				mjumpheight = mjumpheight * cvar("g_balance_rune_speed_jumpheight");
		}
		else if(self.runes & CURSE_SLOW)
		{
			mjumpheight = mjumpheight * cvar("g_balance_curse_slow_jumpheight");
		}
	}

	if(cvar("g_minstagib") && (self.items & IT_INVINCIBLE))
	{
		mjumpheight = mjumpheight * cvar("g_balance_rune_speed_jumpheight");
	}

	self.velocity_z = self.velocity_z + mjumpheight;
	self.oldvelocity_z = self.velocity_z;

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};


void respawn(void)
{
	CopyBody(1);
	PutClientInServer();
}

void player_powerups (void)
{
	if (cvar("g_minstagib"))
	{
		self.effects = EF_FULLBRIGHT;
		if (self.items & IT_STRENGTH)
		{
			if (time > self.strength_finished)
			{
				self.alpha = 1;
				self.exteriorweaponentity.alpha = 1;
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
			sprint(self, "^3Strength infuses your weapons with devestating power\n");
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
	if (cvar("g_midair"))
		self.spawnshieldtime = max(self.spawnshieldtime, time + cvar("g_midair_shieldtime"));

	if (time < self.spawnshieldtime)
		self.effects = self.effects | (EF_ADDITIVE | EF_FULLBRIGHT);
}

void player_regen (void)
{
	float maxh, maxa, max_mod, regen_mod, rot_mod;
	maxh = cvar("g_balance_health_stable");
	maxa = cvar("g_balance_armor_stable");

	if (cvar("g_minstagib") || (cvar("g_lms") && !cvar("g_lms_regenerate")))
		return;

	if(cvar("g_runematch"))
	{
		max_mod = regen_mod = rot_mod = 1;
		if (self.runes & RUNE_REGEN)
		{
			if (self.runes & CURSE_VENOM) // do we have both rune/curse?
			{
				regen_mod = cvar("g_balance_rune_regen_combo_regenrate");
				max_mod = cvar("g_balance_rune_regen_combo_hpmod");
			}
			else
			{
				regen_mod = cvar("g_balance_rune_regen_regenrate");
				max_mod = cvar("g_balance_rune_regen_hpmod");
			}
		}
		else if (self.runes & CURSE_VENOM)
		{
			max_mod = cvar("g_balance_curse_venom_hpmod");
			if (self.runes & RUNE_REGEN) // do we have both rune/curse?
				rot_mod = cvar("g_balance_rune_regen_combo_rotrate");
			else
				rot_mod = cvar("g_balance_curse_venom_rotrate");
			//if (!self.runes & RUNE_REGEN)
			//	rot_mod = cvar("g_balance_curse_venom_rotrate");
		}
		maxh = maxh * max_mod;
		//maxa = maxa * max_mod;

		if (time > self.pauserotarmor_finished)
		{
			if (self.armorvalue > maxa)
				self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime, 1000);
		}
		if (time > self.pauserothealth_finished)
		{
			if (self.health > maxh)
				self.health = bound(0, self.health + (maxh - self.health) * rot_mod*cvar("g_balance_health_rot") * frametime, 1000);
		}
		if (time > self.pauseregen_finished)
		{
			if (self.health < maxh)
				self.health = bound(0, self.health + (maxh- self.health) * regen_mod*cvar("g_balance_health_regen") * frametime, 1000);
			if (self.armorvalue < maxa)
				self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_regen") * frametime, 1000);
		}
	}
	else
	{
		if (time > self.pauserothealth_finished)
		if (self.health > maxh)
			self.health = bound(0, self.health + (maxh - self.health) * cvar("g_balance_health_rot") * frametime, 1000);
		if (time > self.pauserotarmor_finished)
		if (self.armorvalue > maxa)
			self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime, 1000);
		if (time > self.pauseregen_finished)
		{
			if (self.health < maxh)
				 self.health = bound(0, self.health + (maxh - self.health) * cvar("g_balance_health_regen") * frametime + 0.001, 1000);
			if (self.armorvalue < maxa)
				self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_regen") * frametime + 0.001, 1000);
		}
	}
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
	setorigin(self, spectatee.origin);
	setsize(self, spectatee.mins, spectatee.maxs);
}

void SpectateUpdate() {
	if (self != self.enemy) {
		SpectateCopy(self.enemy);
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETANGLE);
		WriteAngle(MSG_ONE, self.enemy.v_angle_x);
		WriteAngle(MSG_ONE, self.enemy.v_angle_y);
		WriteAngle(MSG_ONE, self.enemy.v_angle_z);
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
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
void PlayerPreThink (void)
{
	if(self.classname == "player") {
		local vector m1, m2;

//		MauveBot_AI();

//		if(self.netname == "Wazat")
//			bprint(strcat(self.classname, "\n"));

		CheckRules_Player();

		if(self.button7)
			PrintWelcomeMessage(self);

		if(cvar("g_lms") || !cvar("sv_spectate"))
		if((time - self.jointime) <= cvar("welcome_message_time"))
			PrintWelcomeMessage(self);

		if (intermission_running)
		{
			IntermissionThink ();	// otherwise a button could be missed between
			return;					// the think tics
		}

		if (self.deadflag != DEAD_NO)
		{
			player_anim();
			weapon_freeze();
			if (self.deadflag == DEAD_DYING)
			{
				if (time > self.dead_time)
					self.deadflag = DEAD_DEAD;
			}
			else if (self.deadflag == DEAD_DEAD)
			{
				if (cvar("g_lms") || cvar("g_forced_respawn"))
					self.button0 = self.button2 = self.button3 = 0;

				if (!self.button0 && !self.button2 && !self.button3)
					self.deadflag = DEAD_RESPAWNABLE;
			}
			else if (self.deadflag == DEAD_RESPAWNABLE)
			{
				if (self.button0  ||
				    self.button2  ||
				    self.button3  ||
				    self.button4  ||
				    cvar("g_lms") ||
				    cvar("g_forced_respawn"))
					respawn();
			}
			return;
		}

		if(cvar("g_lms") && !self.deadflag && cvar("g_lms_campcheck_interval"))
		{
			vector dist;

			// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
			dist = self.oldorigin - self.origin;
			dist_z = 0;
			self.lms_traveled_distance += fabs(vlen(dist));

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

		if (self.button5)
		{
			if (!self.crouch)
			{
				self.crouch = TRUE;
				self.view_ofs = PL_CROUCH_VIEW_OFS;
				setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
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
			defaultmodel = CheckPlayerModel(cvar_string("sv_defaultplayermodel"));

			if (defaultmodel != self.model)
			{
				m1 = self.mins;
				m2 = self.maxs;
				precache_model (defaultmodel);
				setmodel (self, defaultmodel);
				setsize (self, m1, m2);
			}

			if (self.skin != stof(cvar_string("sv_defaultplayerskin")))
				self.skin = stof(cvar_string("sv_defaultplayerskin"));
		} else {
			if (self.playermodel != self.model)
			{
				self.playermodel = CheckPlayerModel(self.playermodel);
				m1 = self.mins;
				m2 = self.maxs;
				precache_model (self.playermodel);
				setmodel (self, self.playermodel);
				setsize (self, m1, m2);
			}

			if (self.skin != stof(self.playerskin))
				self.skin = stof(self.playerskin);
		}
		// Savage: Check for nameless players
		if (strlen(self.netname) < 1) {
			self.netname = "Player";
			stuffcmd(self, "name Player\n");
		}

		GrapplingHookFrame();

		W_WeaponFrame();

		if (self.button4 || (self.weapon == WEP_NEX && self.button3))
		{
			if (cvar("g_minstagib") && self.button3)
			{
				if (self.jump_interval <= (time + 0.1))
				{
					self.jump_interval = time + 1;
					weapon_doattack(laser_check, laser_check, W_Laser_Attack);
				}
			}
			else if (self.viewzoom > 0.4)
				self.viewzoom = max (0.4, self.viewzoom - frametime * 2);
		}
		else if (self.viewzoom < 1.0)
			self.viewzoom = min (1.0, self.viewzoom + frametime);


		if (self.button2)
			PlayerJump ();
		else
			self.flags = self.flags | FL_JUMPRELEASED;

		player_powerups();
		player_regen();
		player_anim();

		//self.angles_y=self.v_angle_y + 90;   // temp

		if (self.waterlevel == 2)
			CheckWaterJump ();

		//if (TetrisPreFrame()) return;
	} else if(gameover) {
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between
		return;
	} else if(self.classname == "observer") {

		if (self.flags & FL_JUMPRELEASED) {
			if (self.button2 && self.version == cvar("gameversion")) {
				if(!cvar("teamplay")) {
					self.flags = self.flags & !FL_JUMPRELEASED;
					self.classname = "player";
					if(!cvar("g_lms"))
						bprint (strcat("^4", self.netname, "^4 is playing now\n"));
					PutClientInServer();
					centerprint(self,"");
					return;
				} else {
					self.flags = self.flags & !FL_JUMPRELEASED;
					stuffcmd(self,"menu_showteamselect\n");
					return;
				}
			} else if(self.button0 && self.version == cvar("gameversion")) {
				self.flags = self.flags & !FL_JUMPRELEASED;
				if(SpectateNext() == 1) {
					self.classname = "spectator";
				}
			}
        	} else {
        		if (!(self.button0 || self.button2)) {
				self.flags = self.flags | FL_JUMPRELEASED;
        		}
		}
		if(cvar("g_lms") && self.frags == 0)
			centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n^1You have no more lives left\nwait for next round\n\n\n^7press attack to spectate other players");
		else if(cvar("g_lms") && self.frags == -1)
			centerprint(self, "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n^1Match has already begun\nwait for next round\n\n\n^7press attack to spectate other players");
		else
			PrintWelcomeMessage(self);
			//centerprint(self, "\n\n\npress jump to play\npress attack to spectate other players");
	} else if(self.classname == "spectator") {

		if (self.flags & FL_JUMPRELEASED) {
			if (self.button2 && self.version == cvar("gameversion")) {
				if(!cvar("teamplay")) {
					self.flags = self.flags & !FL_JUMPRELEASED;
					self.classname = "player";
					if(!cvar("g_lms"))
						bprint (strcat("^4", self.netname, "^4 is playing now\n"));

					msg_entity = self;
					WriteByte(MSG_ONE, SVC_SETVIEW);
					WriteEntity(MSG_ONE, self);
					PutClientInServer();
					centerprint(self,"");
					return;
				} else {
					self.flags = self.flags & !FL_JUMPRELEASED;
					stuffcmd(self,"menu_showteamselect\n");
					return;
				}
			} else if(self.button0) {
				self.flags = self.flags & !FL_JUMPRELEASED;
				if(SpectateNext() == 1) {
					self.classname = "spectator";
				} else {
					self.classname = "observer";
					msg_entity = self;
					WriteByte(MSG_ONE, SVC_SETVIEW);
					WriteEntity(MSG_ONE, self);
					PutClientInServer();
				}
			} else if (self.button3) {
				self.flags = self.flags & !FL_JUMPRELEASED;
				self.classname = "observer";
				msg_entity = self;
				WriteByte(MSG_ONE, SVC_SETVIEW);
				WriteEntity(MSG_ONE, self);
				PutClientInServer();
			} else {
				SpectateUpdate();
			}
        } else {
        	if (!(self.button0 || self.button3)) {
			self.flags = self.flags | FL_JUMPRELEASED;
        	}
		}
		if (cvar("g_lms") && self.frags < 1)
			centerprint(self, strcat("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nspectating ", self.enemy.netname, "\n\n\n^7press attack for next player\npress attack2 for free fly mode"));
		else
			centerprint(self, strcat("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nspectating ", self.enemy.netname, "\n\n\n^7press jump to play\n^7press attack for next player\npress attack2 for free fly mode"));

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
	if(self.classname == "player") {
		CheckRules_Player();
		UpdateChatBubble();
		UpdateTeamBubble();
		UpdatePlayerColors();
		if (self.deadflag == DEAD_NO)
		if (self.impulse)
			ImpulseCommands ();
		if (intermission_running)
			return;		// intermission or finale

		//PrintWelcomeMessage(self);
		//if (TetrisPostFrame()) return;
	} else if (self.classname == "observer") {
		//do nothing
	} else if (self.classname == "spectator") {
		//do nothing
	}
}
