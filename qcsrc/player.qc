$frame die1 die2 draw duck duckwalk duckjump duckidle idle
$frame jump pain1 pain2 shoot taunt run runbackwards
$frame strafeleft straferight dead1 dead2

void player_run (void);
void player_stand (void)
{
	if (self.movement_x || self.movement_y)		// ?
		player_run ();
	else
	{
			self.frame = $idle;

		self.think = player_stand;
		self.nextthink = time + 0.05;
	}
}

void player_run (void)
{
	vector	ang;
	float	a;

	if (!self.movement_x && !self.movement_y)	// ?
		player_stand ();
	else
	{
		ang = vectoangles (self.velocity);

		a = angc (self.v_angle_y, ang_y);
		
		if (a < 45 && a >= -45)
			self.frame = $run;
		else if (a < 135 && a >= 45)
			self.frame = $straferight;
		else if (a >= -135 && a < -45)
			self.frame = $strafeleft;
		else
			self.frame = $runbackwards;

		self.think = player_run;
		self.nextthink = time + 0.05;
	}
}

void PlayerWeaponThrow (void)
{
	local entity	item;
	local entity	backup;

	item = spawn();

	backup = self;
	self = item;

	self.origin = backup.origin - '0 0 24';
	
	self.velocity_z = 300;
	self.velocity_x = -100 + (random() * 200);
	self.velocity_y = -100 + (random() * 200);
	self.norespawn = 1;

	if	(backup.weapon == IT_LASER)
		remove (self);
	else if (backup.weapon == IT_UZI)
		weapon_uzi ();
	else if (backup.weapon == IT_SHOTGUN)
		weapon_shotgun ();
	else if (backup.weapon == IT_GRENADE_LAUNCHER)
		weapon_grenadelauncher ();
	else if (backup.weapon == IT_ELECTRO)
		weapon_electro ();
	else if (backup.weapon == IT_CRYLINK)
		weapon_crylink ();
	else if (backup.weapon == IT_NEX)
		weapon_nex ();
	else if (backup.weapon == IT_HAGAR)
		weapon_hagar ();
	else if (backup.weapon == IT_ROCKET_LAUNCHER)
		weapon_rocketlauncher ();

	self = backup;

	stuffcmd(self, "chase_active 1");
}

void PlayerHurt (vector hitloc, float damage)
{
	te_blood (hitloc, '0 0 20', floor (damage / 2));
}

void PlayerDie (void)
{
	self.avelocity = '0 0 0';
	self.movetype = MOVETYPE_TOSS;
	self.weaponmodel = "";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.death_time = time + 1;
	self.dead_angles = self.angles;
	self.dead_angles_x = 0;
	self.deadflag = DEAD_DEAD;

	PlayerWeaponThrow ();
}