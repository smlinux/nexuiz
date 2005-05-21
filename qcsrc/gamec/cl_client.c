void info_player_start (void)
{
	self.classname = "info_player_deathmatch";
}

void info_player_deathmatch (void)
{
}

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity SelectSpawnPoint (void)
{
	local entity spot, thing;
	local float pcount;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	spot = lastspawn;
	while (1)
	{
		spot = find(spot, classname, "info_player_deathmatch");
		if (spot != world)
		{
			if (spot == lastspawn)
				return lastspawn;
			pcount = 0;
			thing = findradius(spot.origin, 70);
			while(thing)
			{
				if (thing.classname == "player")
					pcount = pcount + 1;
				thing = thing.chain;
			}
			if (pcount == 0)
			{
				lastspawn = spot;
				return spot;
			}
		}
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
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
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
	self.flags = FL_CLIENT;
	self.takedamage = DAMAGE_YES;
	self.effects = 0;
	self.health = cvar("g_balance_health_start");
	self.armorvalue = cvar("g_balance_armor_start");
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

	self.viewzoom = 0.6;

	// Savage: Insufficient check for invalid playermodels
	if( substring(self.playermodel,0,14) != "models/player/") self.playermodel = "models/player/marine.zym";

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
	ClientInRankings();
	bprint ("^4",self.netname);
	bprint (" connected\n");
	stuffcmd(self, "exec maps/");
	stuffcmd(self, mapname);
	stuffcmd(self, ".cfg\n");
}

/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
void ClientDisconnect (void)
{
	ClientDisconnected();
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
	if (self.owner.buttonchat)
		self.effects = 0;
	else
		self.effects = EF_NODRAW;
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
		self.chatbubbleentity.think = ChatBubbleThink;
		self.chatbubbleentity.nextthink = time;
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr");
		setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		self.chatbubbleentity.effects = EF_NODRAW;
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

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

.float watersound_finished;
void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			Damage (self, world, world, 5, DEATH_DROWN, self.origin, '0 0 0');
			self.pain_finished = time + 0.5;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watersound_finished < time)
	{
		self.watersound_finished = time + 0.5;
		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/lava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slime.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_WATER)
		//	sound (self, CHAN_BODY, "player/water.wav", 1, ATTN_NORM);
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.1;
			Damage (self, world, world, 3 * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.1;
			Damage (self, world, world, 1 * self.waterlevel, DEATH_SLIME, self.origin, '0 0 0');
		}
	}

	if ( !(self.flags & FL_INWATER) )
	{

		//if (self.watertype == CONTENT_LAVA)
		//	sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_WATER)
		//	sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		//if (self.watertype == CONTENT_SLIME)
		//	sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
};

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
	if (self.health > maxh)
		self.health = bound(0, self.health + (maxh - self.health) * cvar("g_balance_health_rot") * frametime, 1000);
	else if (time > self.pain_finished)
		self.health = bound(0, self.health + (maxh- self.health) * cvar("g_balance_health_regen") * frametime, 1000);
	if (self.armorvalue > maxa)
		self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_rot") * frametime, 1000);
	else if (time > self.pain_finished)
		self.armorvalue = bound(0, self.armorvalue + (maxa - self.armorvalue) * cvar("g_balance_armor_regen") * frametime, 1000);
}

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
.float attack_finished;
void PlayerPreThink (void)
{
	local vector m1, m2;

	if (BotPreFrame())
		return;

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
		m1 = self.mins;
		m2 = self.maxs;
		precache_model (self.playermodel);
		setmodel (self, self.playermodel);
		setsize (self, m1, m2);
	}

	if (self.skin != stof(self.playerskin))
		self.skin = stof(self.playerskin);

	W_WeaponFrame();

	if (self.button4)
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

	self.angles_y=self.v_angle_y + 90;   // temp

	WaterMove ();
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
	float soundrandom;
	if (BotPostFrame())
		return;
	CheckRules_Player();
	UpdateChatBubble();
	UpdateColorModHack();
	if (self.deadflag == DEAD_NO)
	if (self.impulse)
		ImpulseCommands ();
	if (intermission_running)
		return;		// intermission or finale

	// VorteX: landing on floor, landing damage etc.
	// LordHavoc: removed 'big fall' death code that VorteX added
	if (self.flags & FL_ONGROUND)
	{
		if (self.jump_flag < -100 && !self.watertype == CONTENT_WATER) // HitGround
		{
			soundrandom = random() * 4;
			if (soundrandom < 1)
				sound (self, CHAN_BODY, "misc/hitground1.wav", 1, ATTN_NORM);
			else if (soundrandom < 2)
				sound (self, CHAN_BODY, "misc/hitground2.wav", 1, ATTN_NORM);
			else if (soundrandom < 3)
				sound (self, CHAN_BODY, "misc/hitground3.wav", 1, ATTN_NORM);
			else if (soundrandom < 4)
				sound (self, CHAN_BODY, "misc/hitground4.wav", 1, ATTN_NORM);
			if (self.jump_flag < -650) // landing damage
			{
				local float dm;
				dm = bound(0, 0.1*(fabs(self.jump_flag) - 600), 5);
				Damage (self, world, world, dm, DEATH_FALL, self.origin, '0 0 0');
			}
			self.jump_flag = 0;
		}
	}
	else
		self.jump_flag = self.velocity_z;

	//if (TetrisPostFrame()) return;
}
