void info_player_start (void)
{
	self.classname = "info_player_deathmatch";
}

void info_player_deathmatch (void)
{
}

float spawn_goodspots, spawn_badspots;
entity Spawn_ClassifyPoints(entity firstspot, entity playerlist, float mindist, float goodspotnum, float badspotnum)
{
	local entity spot, player;
	local float pcount;
	spawn_goodspots = 0;
	spawn_badspots = 0;
	spot = firstspot;
	while (spot)
	{
		pcount = 0;
		player = playerlist;
		while (player)
		{
			if (player != self)
			if (vlen(player.origin - spot.origin) < 100)
				pcount = pcount + 1;
			player = player.chain;
		}
		if (pcount)
		{
			if (spawn_goodspots >= badspotnum)
				return spot;
			spawn_badspots = spawn_badspots + 1;
		}
		else
		{
			if (spawn_goodspots >= goodspotnum)
				return spot;
			spawn_goodspots = spawn_goodspots + 1;
		}
		spot = find(spot, classname, "info_player_deathmatch");
	}
	return firstspot;
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
		spot = find(spot, classname, "info_player_deathmatch");
	}
	return best;
}

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity SelectSpawnPoint (void)
{
	local entity spot, firstspot, playerlist;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	playerlist = findchain(classname, "player");
	firstspot = find(world, classname, "info_player_deathmatch");
	Spawn_ClassifyPoints(firstspot, playerlist, 100, 1000000, 1000000);
	// first check if there are ANY good spots
	if (spawn_goodspots > 0)
	{
		// good spots exist, there is 50/50 chance of choosing a random good
		// spot or the furthest spot
		// (this means that roughly every other spawn will be furthest, so you
		// usually won't get fragged at spawn twice in a row)
		if (random() > 0.5)
			spot = Spawn_ClassifyPoints(firstspot, playerlist, 100, min(floor(random() * spawn_goodspots), spawn_goodspots - 1), 1000000);
		else
			spot = Spawn_FurthestPoint(firstspot, playerlist);
	}
	else
	{
		// no good spots exist, pick a random bad spot
		spot = Spawn_ClassifyPoints(firstspot, playerlist, 100, 1000000, min(floor(random() * spawn_badspots), spawn_badspots - 1));
	}

	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

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
PutClientInServer

Called when a client spawns in the server
=============
*/
void PutClientInServer (void)
{
	entity	spot;

	spot = SelectSpawnPoint ();

	self.classname = "player";
	self.iscreature = TRUE;
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
	self.flags = FL_CLIENT;
	self.takedamage = DAMAGE_AIM;
	self.effects = 0;
	self.health = cvar("g_balance_health_start");
	self.armorvalue = cvar("g_balance_armor_start");
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
	//self.speed_finished = 0;
	//self.slowmo_finished = 0;
	// players have no think function
	self.think = SUB_Null;
	self.nextthink = 0;

	self.deadflag = DEAD_NO;

	self.angles = spot.angles;
	self.fixangle = TRUE; // turn this way immediately
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;

	self.viewzoom = 0.6;


	self.playermodel = CheckPlayerModel(self.playermodel);

	precache_model (self.playermodel);
	setmodel (self, self.playermodel);
	self.skin = stof(self.playerskin);
	self.crouch = FALSE;
	self.view_ofs = PL_VIEW_OFS;
	setsize (self, PL_MIN, PL_MAX);
	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
	// don't reset back to last position, even if new position is stuck in solid
	self.oldorigin = self.origin;

//	self.items = IT_LASER | IT_UZI| IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
//	self.weapon = IT_UZI;

	if (cvar("g_instagib") == 1)
	{
		self.items = IT_NEX;
		self.switchweapon = WEP_NEX;
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_rockets = 0;
		self.ammo_cells = 999;
	}
	else if (cvar("g_rocketarena") == 1)
	{
		self.items = IT_ROCKET_LAUNCHER;
		self.switchweapon = WEP_ROCKET_LAUNCHER;
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_rockets = 999;
		self.ammo_cells = 0;
	}
	else
	{
		self.items = IT_LASER | IT_SHOTGUN;
		self.switchweapon = WEP_SHOTGUN;
		self.ammo_shells = 50;
		self.ammo_nails = 0;
		self.ammo_rockets = 0;
		self.ammo_cells = 0;
	}

	if (cvar("g_fullbrightplayers") == 1)
		self.effects = EF_FULLBRIGHT;

	self.event_damage = PlayerDamage;

	self.statdraintime = time + 5;
	self.button0 = self.button1 = self.button2 = self.button3 = 0;

	/*
	W_UpdateWeapon();
	W_UpdateAmmo();
	*/
	CL_SpawnWeaponentity();

	//stuffcmd(self, "chase_active 0");
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
void ClientConnect (void)
{
	bprint ("^4",self.netname);
	bprint (" connected\n");
	stuffcmd(self, strcat("exec maps/", mapname, ".cfg\n"));
	// send prediction settings to the client
	stuffcmd(self, strcat("cl_movement_maxspeed ", ftos(cvar("sv_maxspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_maxairspeed ", ftos(cvar("sv_maxairspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_accelerate ", ftos(cvar("sv_accelerate")), "\n"));
	stuffcmd(self, strcat("cl_movement_friction ", ftos(cvar("sv_friction")), "\n"));
	stuffcmd(self, strcat("cl_movement_stopspeed ", ftos(cvar("sv_stopspeed")), "\n"));
	stuffcmd(self, strcat("cl_movement_jumpvelocity ", ftos(cvar("g_balance_jumpheight")), "\n"));
	stuffcmd(self, strcat("cl_movement_stepheight ", ftos(cvar("sv_stepheight")), "\n"));
	stuffcmd(self, strcat("cl_movement_edgefriction 0\n"));
}

/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
void ClientDisconnect (void)
{
	bprint ("^4",self.netname);
	bprint (" disconnected\n");
}

.entity chatbubbleentity;
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

// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
void() UpdateColorModHack =
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
};

/*
=============
PlayerJump

When you press the jump key
=============
*/
void PlayerJump (void)
{
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

	self.velocity_z = self.velocity_z + cvar("g_balance_jumpheight");
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
}

void player_regen (void)
{
	local float maxh;
	local float maxa;
	maxh = cvar("g_balance_health_stable");
	maxa = cvar("g_balance_armor_stable");
	if (time > self.pauserothealth_finished)
	if (self.health > maxh)
		self.health = bound(0, self.health + (maxh - self.health) * cvar("g_balance_health_rot") * frametime, 1000);
	if (time > self.pauserotarmor_finished)
	if (self.armorvalue > maxa)
		self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime, 1000);
	if (time > self.pauseregen_finished)
	{
		if (self.health < maxh)
			self.health = bound(0, self.health + (maxh- self.health) * cvar("g_balance_health_regen") * frametime, 1000);
		if (self.armorvalue < maxa)
			self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_regen") * frametime, 1000);
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
	local vector m1, m2;

//	MauveBot_AI();

	CheckRules_Player();

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
			if (!self.button0 && !self.button2 && !self.button3)
				self.deadflag = DEAD_RESPAWNABLE;
		}
		else if (self.deadflag == DEAD_RESPAWNABLE)
		{
			if (self.button0 || self.button2 || self.button3  || self.button4)
				respawn();
		}
		return;
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

	if (self.playermodel != self.model)
	{
		self.playermodel = CheckPlayerModel(self.playermodel);
		m1 = self.mins;
		m2 = self.maxs;
		precache_model (self.playermodel);
		setmodel (self, self.playermodel);
		setsize (self, m1, m2);
	}

	// Savage: Check for nameless players
	if (strlen(self.netname) < 1) {
		self.netname = "Player";
		stuffcmd(self, "name Player\n");
	}

	if (self.skin != stof(self.playerskin))
		self.skin = stof(self.playerskin);

	W_WeaponFrame();

	if (self.button4 || (self.weapon == WEP_NEX && self.button3))
	{
		if (self.viewzoom > 0.4)
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
}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
void PlayerPostThink (void)
{
	CheckRules_Player();
	UpdateChatBubble();
	UpdateColorModHack();
	if (self.deadflag == DEAD_NO)
	if (self.impulse)
		ImpulseCommands ();
	if (intermission_running)
		return;		// intermission or finale

	//if (TetrisPostFrame()) return;
}
