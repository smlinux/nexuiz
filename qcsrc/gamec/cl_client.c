
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

}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
void ClientConnect (void)
{
	//ClientInRankings();
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
	//ClientDisconnected();
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
			self.armorvalue = bound(100, self.armorvalue + (100 - self.armorvalue) * 0.05 * frametime, 1000);
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
	//if (BotPreFrame())
	//	return;
	if (!self.hasaliases)
	    DoAliases();

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
	//if (BotPostFrame())
	//	return;
	if (self.health > 0)
	if (self.impulse)
		ImpulseCommands ();

	// VorteX: landing on floor, landing damage etc.
	if (self.flags & FL_ONGROUND)
	{
		if (fabs(self.jump_flag) > 100)
		{
			if (self.jump_flag < -100 && !self.watertype == CONTENT_WATER) // HitGround
			{
				soundrandom = random() * 3;
				if (soundrandom < 1)
					sound (self, CHAN_BODY, "misc/hitground1.wav", 1, ATTN_NORM);
				if (soundrandom < 2)
					sound (self, CHAN_BODY, "misc/hitground2.wav", 1, ATTN_NORM);
				if (soundrandom < 3)
					sound (self, CHAN_BODY, "misc/hitground3.wav", 1, ATTN_NORM);
				if (soundrandom < 4)
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
	}
	else
	{
		if (self.jump_flag != -10000) // not in falling death
		{
			self.jump_flag = self.velocity_z;
			// check for falling into the void
			if (self.jump_flag < -700)
			{
				tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 -1'*2048, MOVE_NORMAL, self);
				if (trace_fraction == 1)
				{// VorteX: add player falling sound here
					self.jump_flag = -10000;
					self.lip = time + 1;
				}
			}
		}
		else
		{
			if (time < self.lip)
			{// prevent all inventory drop
				self.weapon = 0;
				Damage (self, world, world, 40000, DEATH_BIGFALL, '0 0 0', '0 0 0');
			}
		}
	}

	//if (TetrisPostFrame()) return;
}
