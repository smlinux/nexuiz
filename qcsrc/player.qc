$frame die1 die2 draw duck duckwalk duckjump duckidle idle
$frame jump pain1 pain2 shoot taunt run runbackwards
$frame strafeleft straferight dead1 dead2 forwardright
$frame forwardleft backright backleft

// changes by LordHavoc on 03/29/04 and 03/30/04 at Vermeulen's request
// merged player_run and player_stand to player_anim
// added death animations to player_anim
// can now spawn thrown weapons from anywhere, not just from players
// thrown weapons now fade out after 20 seconds
// created PlayerGib function
// PlayerDie no longer uses hitloc or damage
// PlayerDie now supports dying animations as well as gibbing
// cleaned up PlayerDie a lot
// added CopyBody

void CopyBody()
{
	local entity oldself;
	if (self.effects & EF_NODRAW)
		return;
	oldself = self;
	self = spawn();
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.event_damage = oldself.event_damage;
	self.frame = oldself.frame;
	self.health = oldself.health;
	self.model = oldself.model;
	self.modelindex = oldself.modelindex;
	self.movetype = oldself.movetype;
	self.nextthink = oldself.nextthink;
	self.norespawn = TRUE;
	self.skin = oldself.skin;
	self.solid = oldself.solid;
	self.takedamage = oldself.takedamage;
	self.think = oldself.think;
	self.velocity = oldself.velocity;
	self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, '-16 -16 -24',  '16 16 5');
	self = oldself;
}

void player_anim (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (time > self.dead_time)
			self.frame = self.dead_frame;
		else
			self.frame = self.die_frame;
		return;
	}


	if (self.crouch) 
	{
		if (self.movement_x * self.movement_x + self.movement_y * self.movement_y > 20)
			self.frame = $duckwalk;
		else
			self.frame = $duckidle;
	}
	else if ((self.movement_x * self.movement_x + self.movement_y * self.movement_y) > 20)
	{
		if (self.movement_x > 0 && self.movement_y == 0)
			self.frame = $run;
		else if (self.movement_x < 0 && self.movement_y == 0)
			self.frame = $runbackwards;
		else if (self.movement_x == 0 && self.movement_y > 0)
			self.frame = $straferight;
		else if (self.movement_x == 0 && self.movement_y < 0)
			self.frame = $strafeleft;
		else if (self.movement_x > 0 && self.movement_y > 0)
			self.frame = $forwardright;
		else if (self.movement_x > 0 && self.movement_y < 0)
			self.frame = $forwardleft;
		else if (self.movement_x < 0 && self.movement_y > 0)
			self.frame = $backright;
		else if (self.movement_x < 0 && self.movement_y < 0)
			self.frame = $backleft;
		else
			self.frame = $run;
	}
	else if (self.pain_finished > time)
		self.frame = self.pain_frame;
	else if (self.attack_finished > time)
		self.frame = $shoot;
	else
		self.frame = $idle;

	if (!(self.flags & FL_ONGROUND))
		self.frame = $idle;
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)

void SpawnThrownWeapon (vector org, float w)
{
	local entity oldself;

	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
		return;
	if (w == IT_LASER)
		return;

	oldself = self;
	self = spawn();

	setorigin(self, org);
	self.velocity = randomvec() * 100 + '0 0 200';
	self.norespawn = 1;
	//SUB_SetFade(self, time + 20);

	if (w == IT_UZI)
		weapon_uzi ();
	else if (w == IT_SHOTGUN)
		weapon_shotgun ();
	else if (w == IT_GRENADE_LAUNCHER)
		weapon_grenadelauncher ();
	else if (w == IT_ELECTRO)
		weapon_electro ();
	else if (w == IT_CRYLINK)
		weapon_crylink ();
	else if (w == IT_NEX)
		weapon_nex ();
	else if (w == IT_HAGAR)
		weapon_hagar ();
	else //if (w == IT_ROCKET_LAUNCHER)
		weapon_rocketlauncher ();

	self = oldself;
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	te_blood (hitloc, force, damage);
	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);
	save = bound(0, damage * 0.6, self.armorvalue);
	take = bound(0, damage - save, damage);
	self.armorvalue = self.armorvalue - save;
	self.health = self.health - take;
	self.dmg_save = self.dmg_save + save;
	self.dmg_take = self.dmg_take + take;
	self.dmg_inflictor = inflictor;
	if (self.health <= -50)
	{
		// don't use any animations as a gib
		self.frame = 0;
		self.dead_frame = 0;
		self.die_frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';
		// make a juicy mess
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 500, 2000);
		// make a meaty mess
		TossGib (world, "models/gibs/gib1.md3", self.origin, self.velocity);
		TossGib (world, "models/gibs/gib2.mdl", self.origin, self.velocity);
		TossGib (world, "models/gibs/gib3.mdl", self.origin, self.velocity);
		TossGib (world, "models/gibs/gib4.mdl", self.origin, self.velocity);
		TossGib (world, "models/gibs/bloodyskull.md3", self.origin, self.velocity);
		TossGib (self, "models/gibs/eye.md3", self.origin, self.velocity);
		sound (trace_ent, CHAN_VOICE, "misc/gib.wav", 1, ATTN_NORM);
	}
}

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	if (attacker == self)
		if (game & GAME_NO_SELF_DAMAGE)
			return;

	te_blood (hitloc, force, damage);
	if (self.pain_finished < time)		//Don't switch pain sequences like crazy
	{
		if (random() > 0.5)
			self.pain_frame = $pain1;
		else
			self.pain_frame = $pain2;
		self.pain_finished = time + 0.5;	//Supajoe
	}

	if (game & GAME_INSTAGIB)
		damage = self.health + 75;

	save = bound(0, damage * 0.6, self.armorvalue);
	take = bound(0, damage - save, damage);
	self.armorvalue = self.armorvalue - save;
	self.health = self.health - take;
	self.dmg_save = self.dmg_save + save;
	self.dmg_take = self.dmg_take + take;
	self.dmg_inflictor = inflictor;
	if (self.health <= 0)
	{
		// print an obituary message
		Obituary (attacker, self, deathtype);
		// make the corpse upright (not tilted)
		self.angles_x = 0;
		self.angles_z = 0;
		// don't spin
		self.avelocity = '0 0 0';
		// no weapon when dead
		self.weaponmodel = "";
		// view from the floor
		self.view_ofs = '0 0 -8';
		// toss the corpse
		self.movetype = MOVETYPE_TOSS;
		// shootable corpse
		self.solid = SOLID_CORPSE;
		// don't stick to the floor
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		// dying animation
		self.deadflag = DEAD_DYING;
		// when to allow respawn
		self.death_time = time + 0.5;
		// when to switch to the dead_frame
		self.dead_time = time + 1.5;
		if (random() < 0.5)
		{
			self.die_frame = $die1;
			self.dead_frame = $dead1;
		}
		else
		{
			self.die_frame = $die2;
			self.dead_frame = $dead2;
		}
		// start the animation
		player_anim();
		// throw a weapon
		SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.weapon);
		// set damage function to corpse damage
		self.event_damage = PlayerCorpseDamage;
		// call the corpse damage function just in case it wants to gib
		self.event_damage(inflictor, attacker, 0, deathtype, hitloc, force);
		// set up to fade out later
		SUB_SetFade (self, time + 12 + random () * 4);
		// Sajt - added this, but I'm not sure the powerups are even implemented? This might act strange because
		//        there is no code handled to disable powerups when their time is up...
		if (game & GAME_STRENGTH_GAIN)
		{
			if (attacker.strength_finished < time)
				attacker.strength_finished = time;
			attacker.strength_finished = attacker.strength_finished + 5;
			attacker.items = attacker.items | IT_STRENGTH;
		}
	}
}

