$frame die1 die2 draw duck duckwalk duckjump duckidle idle
$frame jump pain1 pain2 shoot taunt run runbackwards
$frame strafeleft straferight dead1 dead2

//Begin change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)
void player_run (void);
void player_stand (void)
{
	if (self.movement_x || self.movement_y)		// ?
		player_run ();
	else
	{
		if (self.attack_finished > time)
			self.frame = $shoot;
		else if (self.pain_finished > time)
			self.frame = self.pain_frame;
		else	self.frame = $idle;

		self.think = player_stand;
		self.nextthink = time + 0.05;
	}
}

void player_run (void)
{
	if (!self.movement_x && !self.movement_y)	// ?
		player_stand ();
	else
	{
		if (self.movement_x != 0)	//Forward or backward movement
			{
				if (self.movement_x > 0)	//Are we moving forward or backward?
					self.frame = $run;
				else	self.frame = $runbackwards;
			}
		else if (self.movement_y != 0)	//Right or left movement
			{
				if (self.movement_y > 0)	//Are we moving right or left?
					self.frame = $straferight;
				else	self.frame = $strafeleft;
			}
		else if (self.attack_finished > time)
			self.frame = $shoot;
		else if (self.pain_finished > time)
			self.frame = self.pain_frame;

		self.think = player_run;
		self.nextthink = time + 0.05;
	}
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)

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

	if (self.pain_finished < time)		//Don't switch pain sequences like crazy
		{
		if (random() > 0.5)
			self.pain_frame = $pain1;
		else	self.pain_frame = $pain2;

		self.pain_finished = time + 0.5;	//Supajoe
		}
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

//Supajoe: Working on this
//	if (random() > 0.5)
//		self.frame = $die1;
//	else	self.frame = $die2;

	PlayerWeaponThrow ();
}