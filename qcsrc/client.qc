
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
	self.health = 125;
	self.damageforcescale = 2;

	self.ammo_shells = 100;
	self.ammo_nails = 100;
	self.ammo_rockets = 100;
	self.ammo_cells = 100;

	self.deadflag = DEAD_NO;

	self.view_ofs = PL_VIEW_OFS;
	self.angles = spot.angles;
	setmodel (self, "models/player/player.zym");
	setsize (self, PL_MIN, PL_MAX);
	setorigin (self, spot.origin);

	self.items = IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER;
	self.weapon = IT_UZI;

	self.event_hurt = PlayerHurt;
	self.event_die = PlayerDie;

	self.statdraintime = time + 5;
	self.button0 = self.button1 = self.button2 = self.button3 = 0;

	W_UpdateWeapon ();
	W_UpdateAmmo ();

	stuffcmd(self, "chase_active 0");
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
	if (self.deadflag != DEAD_NO)
	{
		if (self.death_time < time)
			PutClientInServer();

		return;
	}
	if (!(self.flags & FL_ONGROUND))
		return;
	if (!(self.flags & FL_JUMPRELEASED))
		return;

	self.velocity_z = self.velocity_z + 300;

	self.flags = self.flags - FL_ONGROUND;
	self.flags = self.flags - FL_JUMPRELEASED;
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

	if (self.button3)
	{
		if (self.weapon == IT_GRENADE_LAUNCHER)
			W_SecondaryAttack ();
		if (self.attack_finished < time && self.button0 != 1)
			W_SecondaryAttack ();
	}

	if (self.attack_finished < time)
	{
		if (self.button0)
			W_Attack ();
	}

	if (self.button2)
		PlayerJump ();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	if (self.deadflag != DEAD_NO)
	{
		self.angles = self.dead_angles;
		return;
	}

	if (self.weapon == IT_NEX && self.button3)
		self.viewzoom = 0.3;
	else if (self.weapon == IT_LASER && self.button3)
		self.viewzoom = 0.6;
	else if (self.viewzoom != 1)
		self.viewzoom = 1;

	if (self.statdraintime < time)
	{
		if (self.health > 100)
			self.health = self.health - 1;
		if (self.armorvalue > 100)
			self.armorvalue = self.armorvalue - 1;

		self.statdraintime = time + 1;
	}

	self.angles_y=self.v_angle_y + 90;   // temp

	player_stand ();
	weapon_stand ();
	if (TetrisPreFrame()) return;
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

	ImpulseCommands ();
	if (TetrisPostFrame()) return;
}