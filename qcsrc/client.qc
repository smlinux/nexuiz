
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

	self.deadflag = DEAD_NO;

	self.view_ofs = PL_VIEW_OFS;
	self.angles = spot.angles;

	self.viewzoom = 0.6;
	
	mdlrandom = crandom();
	if (mdlrandom>-0.9)
		setmodel (self, "models/player/insurrectionist.zym");
	if (mdlrandom>-0.8)
		setmodel (self, "models/player/mulder.zym");
	if (mdlrandom>-0.6)
		setmodel (self, "models/player/lurk.zym");
	if (mdlrandom>-0.4)
		setmodel (self, "models/player/grunt.zym");
	if (mdlrandom>-0.3)
		setmodel (self, "models/player/pyria.zym");
	if (mdlrandom>-0.2)
		setmodel (self, "models/player/headhunter.zym");
	if (mdlrandom>0.0)
		setmodel (self, "models/player/jeandarc.zym");
	if (mdlrandom>0.1)
		setmodel (self, "models/player/marine.zym");
	if (mdlrandom>0.2)
		setmodel (self, "models/player/robot.zym");
	if (mdlrandom>0.4)
		setmodel (self, "models/player/pyria.zym");
	if (mdlrandom>0.6)
		setmodel (self, "models/player/shock.zym");
	if (mdlrandom>0.7)
		setmodel (self, "models/player/lycanthrope.zym");
	if (mdlrandom>0.8)
		setmodel (self, "models/player/specop.zym");
	if (mdlrandom>0.9)
		setmodel (self, "models/player/visitant.zym");


	setsize (self, PL_MIN, PL_MAX);
	setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
	// don't reset back to last position, even if new position is stuck in solid
	self.oldorigin = self.origin;

//	self.items = IT_LASER | IT_UZI| IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
//	self.weapon = IT_UZI;

	if (game & GAME_INSTAGIB)
	{
		self.items = IT_NEX;
		self.weapon = IT_NEX;
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_rockets = 0;
		self.ammo_cells = 999;
	}
	else if (game & GAME_ROCKET_ARENA)
	{
		self.items = IT_ROCKET_LAUNCHER;
		self.weapon = IT_ROCKET_LAUNCHER;
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_rockets = 999;
		self.ammo_cells = 0;
	}
	else
	{
		self.items = IT_LASER | IT_UZI;
		self.weapon = IT_UZI;
		self.ammo_shells = 0;
		self.ammo_nails = 25;
		self.ammo_rockets = 0;
		self.ammo_cells = 0;
	}

	if (game & GAME_FULLBRIGHT_PLAYERS)
		self.effects = EF_FULLBRIGHT;

	self.event_damage = PlayerDamage;

	self.statdraintime = time + 5;
	self.button0 = self.button1 = self.button2 = self.button3 = 0;

	W_UpdateWeapon ();
	W_UpdateAmmo ();

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
	if (!(self.flags & FL_ONGROUND))
		return;
	if (!(self.flags & FL_JUMPRELEASED))
		return;

	self.velocity_z = self.velocity_z + 250;

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
}

void respawn(void)
{
	CopyBody();
	PutClientInServer();
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
	if (BotPreFrame())
		return;
	if (!self.hasaliases)
	    DoAliases();

	if (self.deadflag != DEAD_NO)
	{
		player_anim ();
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

	if (self.button4)
	{
		if (self.weapon == IT_ROCKET_LAUNCHER)
			W_ThirdAttack ();
		if (self.attack_finished < time && !self.button0 && !self.button3)
			W_ThirdAttack ();
	}

	if (self.button3)
	{
		if (self.weapon == IT_GRENADE_LAUNCHER)
			W_SecondaryAttack ();
		if (self.weapon == IT_ROCKET_LAUNCHER)
			W_SecondaryAttack ();
		if (self.attack_finished < time && !self.button0)
			W_SecondaryAttack ();
	}
	
	if (self.attack_finished < time)
	if (self.button0)
		W_Attack ();
	
	if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	if (self.weapon == IT_NEX && self.button3)
		self.viewzoom = 0.4;
	else if (self.viewzoom != 1)
		self.viewzoom = self.viewzoom + 0.1;

	if (self.statdraintime < time)
	{
		// GAME_REGENERATION does fast health regeneration up to 200. Note that your armour doesn't rot anymore either.
		// Sajt - go ahead and tweak this, I just guessed some values :)
		if (game & GAME_REGENERATION)
		{
			if (self.health < 200)
				self.health = self.health + 2;

			self.statdraintime = time + 0.25;
		}
		else
		{
			if (self.health < 25)
				self.health = self.health + 3;
			if (self.health < 50)
				self.health = self.health + 2;
			if (self.health < 100)
				self.health = self.health + 1;
			if (self.health > 100)
				self.health = self.health - 1;
			if (self.health > 150)
				self.health = self.health - 2;
			if (self.health > 200)
				self.health = self.health - 4;
			if (self.health > 250)
				self.health = self.health - 6;
			if (self.armorvalue > 100)
				self.armorvalue = self.armorvalue - 1;

			self.statdraintime = time + 1;
		}
	}
	player_anim ();
	weapon_anim ();

	if (TetrisPreFrame()) return;
	self.angles_y=self.v_angle_y + 90;   // temp

}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
void PlayerPostThink (void)
{
	if (BotPostFrame())
		return;
	if (self.health > 0)
	if (self.impulse)
		ImpulseCommands ();
	if (TetrisPostFrame()) return;
}