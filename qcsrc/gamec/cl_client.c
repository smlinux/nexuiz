
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
	float mdlrandom;

	spot = SelectSpawnPoint ();

	self.classname = "player";
	self.movetype = MOVETYPE_WALK;
	self.solid = SOLID_SLIDEBOX;
	self.flags = FL_CLIENT;
	self.takedamage = DAMAGE_YES;
	self.effects = 0;
	self.health = 150;
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
	self.speed_finished = 0;
	self.slowmo_finished = 0;
	// players have no think function
	self.think = nullfunction;
	self.nextthink = 0;

	self.deadflag = DEAD_NO;

	self.view_ofs = PL_VIEW_OFS;
	self.angles = spot.angles;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';

	self.viewzoom = 0.6;

	setmodel (self, self.playermodel);
	self.skin = stof(self.playerskin);
	setsize (self, PL_MIN, PL_MAX);
	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
	// don't reset back to last position, even if new position is stuck in solid
	self.oldorigin = self.origin;

//	self.items = IT_LASER | IT_UZI| IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
//	self.weapon = IT_UZI;

	if (game & GAME_INSTAGIB)
	{
		self.items = IT_NEX;
		self.switchweapon = WEP_NEX;
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_rockets = 0;
		self.ammo_cells = 999;
	}
	else if (game & GAME_ROCKET_ARENA)
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
		self.ammo_shells = 25;
		self.ammo_nails = 0;
		self.ammo_rockets = 0;
		self.ammo_cells = 0;
	}

	if (game & GAME_FULLBRIGHT_PLAYERS)
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
	bprint (self.netname);
	bprint (" connected\n");
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
	bprint (self.netname);
	bprint (" disconnected\n");
}

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

	if (self.items & IT_SPEED)
		self.velocity_z = self.velocity_z + POWERUP_SPEED_JUMPVELOCITY;
	else
		self.velocity_z = self.velocity_z + JUMP_VELOCITY;

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

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
			Damage (self, world, world, 5, DEATH_DROWN, '0 0 0', '0 0 0');
			self.pain_finished = time + 0.5;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.2;
			Damage (self, world, world, 5, DEATH_LAVA, '0 0 0', '0 0 0');
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;
			Damage (self, world, world, 5, DEATH_SLIME, '0 0 0', '0 0 0');
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
	CopyBody();
	PutClientInServer();
}

void player_powerups (void)
{
	if (self.items & IT_STRENGTH)
	{
		if (time > self.strength_finished)
		{
			self.items = self.items - (self.items & IT_STRENGTH);
			sprint(self, "Strength has worn off\n");
		}
	}
	else
	{
		if (time < self.strength_finished)
		{
			self.items = self.items | IT_STRENGTH;
			sprint(self, "Strength infuses your weapons with devestating power\n");
		}
	}
	if (self.items & IT_INVINCIBLE)
	{
		if (time > self.invincible_finished)
		{
			self.items = self.items - (self.items & IT_INVINCIBLE);
			sprint(self, "Invincible has worn off\n");
		}
	}
	else
	{
		if (time < self.invincible_finished)
		{
			self.items = self.items | IT_INVINCIBLE;
			sprint(self, "Invincible shielding surrounds you\n");
		}
	}
	if (self.items & IT_SPEED)
	{
		if (time > self.speed_finished)
		{
			self.items = self.items - (self.items & IT_SPEED);
			sprint(self, "Speed has worn off\n");
		}
	}
	else
	{
		if (time < self.speed_finished)
		{
			self.items = self.items | IT_SPEED;
			sprint(self, "Speed makes you run faster than ever before\n");
		}
	}
	if (self.items & IT_SLOWMO)
	{
		if (time > self.slowmo_finished)
		{
			self.items = self.items - (self.items & IT_SLOWMO);
			sprint(self, "Slow Motion has worn off\n");
		}
	}
	else
	{
		if (time < self.slowmo_finished)
		{
			self.items = self.items | IT_SLOWMO;
			sprint(self, "Slow Motion slows time around you\n");
		}
	}
	/*
	self.items = self.items - (self.items & (IT_STRENGTH + IT_INVINCIBLE + IT_SLOWMO + IT_SPEED));
	if (time < self.strength_finished)
		self.items = self.items | IT_STRENGTH;
	if (time < self.invincible_finished)
		self.items = self.items | IT_INVINCIBLE;
	if (time < self.slowmo_finished)
		self.items = self.items | IT_SLOWMO;
	if (time < self.speed_finished)
		self.items = self.items | IT_SPEED;
	*/
}

void player_regen (void)
{
	// GAME_REGENERATION does fast health regeneration up to 200. Note that your armour doesn't rot anymore either.
	if (game & GAME_REGENERATION)
	{
		self.health = self.health + (200 - self.health) * 0.2 * frametime;
		self.armorvalue = bound(0, self.armorvalue, 1000);
	}
	else
	{
		self.health = bound(0, self.health + (100 - self.health) * 0.05 * frametime, 1000);
		if (self.armorvalue > 100)
			self.armorvalue = bound(100, self.armorvalue + (100 - self.armorvalue) * 0.1 * frametime, 1000);
	}
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

	if (self.playermodel != self.model)
	{
		m1 = self.mins;
		m2 = self.maxs;
		setmodel (self, self.playermodel);
		setsize (self, m1, m2);
		self.skin = stof(self.playerskin);
	}

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
	if (self.health > 0)
	if (self.impulse)
		ImpulseCommands ();

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
				Damage (self, world, world, dm, DEATH_FALL, '0 0 0', '0 0 0');
			}
			self.jump_flag = 0;
		}
	}
	else
		self.jump_flag = self.velocity_z;

	//if (TetrisPostFrame()) return;
}
