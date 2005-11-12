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

.entity pusher;
.float pushltime;

void CopyBody(float keepvelocity)
{
	local entity oldself;
	if (self.effects & EF_NODRAW)
		return;
	oldself = self;
	self = spawn();
	self.iscreature = oldself.iscreature;
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.event_damage = oldself.event_damage;
	self.frame = oldself.frame;
	self.health = oldself.health;
	self.armorvalue = oldself.armorvalue;
	self.armortype = oldself.armortype;
	self.model = oldself.model;
	self.modelindex = oldself.modelindex;
	self.movetype = oldself.movetype;
	self.nextthink = oldself.nextthink;
	self.skin = oldself.skin;
	self.solid = oldself.solid;
	self.takedamage = oldself.takedamage;
	self.think = oldself.think;
	if (keepvelocity == 1)
		self.velocity = oldself.velocity;
	self.oldvelocity = self.velocity;
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);//'-16 -16 -24',  '16 16 5');
	self.oldorigin = oldself.origin;
	self = oldself;
}

void player_anim (void)
{
	if (self.deadflag != DEAD_NO)
	{
		if (time > self.dead_time)
		{
			if (self.maxs_z > 5)
				setsize(self, '-16 -16 -24', '16 16 5');
			self.frame = self.dead_frame;
		}
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
		self.frame = $jump;
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)

void SpawnThrownWeapon (vector org, float w)
{
	local entity oldself;

	if (!cvar("g_pickup_items"))
	if (!cvar("g_minstagib"))
		return;
	if (w == IT_LASER)
		return;

	oldself = self;
	self = spawn();
	// this will cause it to be removed later
	self.classname = "droppedweapon";

	setorigin(self, org);
	self.velocity = randomvec() * 100 + '0 0 200';
	SUB_SetFade(self, time + 20, 1);

	if (w == WEP_UZI)
		weapon_uzi ();
	else if (w == WEP_SHOTGUN)
		weapon_shotgun ();
	else if (w == WEP_GRENADE_LAUNCHER)
		weapon_grenadelauncher ();
	else if (w == WEP_ELECTRO)
		weapon_electro ();
	else if (w == WEP_CRYLINK)
		weapon_crylink ();
	else if (w == WEP_NEX)
		weapon_nex ();
	else if (w == WEP_HAGAR)
		weapon_hagar ();
	else if (w == WEP_ROCKET_LAUNCHER)
		weapon_rocketlauncher ();

	// making absolutely sure...
	self.classname = "droppedweapon";

	self = oldself;
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;
	te_blood (hitloc, force, damage);
	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	save = bound(0, damage * cvar("g_balance_armor_blockpercent"), self.armorvalue);
	take = bound(0, damage - save, damage);

	if (save > 10)
		sound (self, CHAN_IMPACT, "misc/armorimpact.wav", 1, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_IMPACT, "misc/bodyimpact2.wav", 1, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_IMPACT, "misc/bodyimpact1.wav", 1, ATTN_NORM);

	if (take > 50)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
	if (take > 100)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - save;
		self.health = self.health - take;
		// pause regeneration for 5 seconds
		self.pauseregen_finished = max(self.pauseregen_finished, time + 5);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
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
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 800, 1000);
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 400, 1000);

		// make a meaty mess
		TossGib (self, "models/gibs/eye.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/bloodyskull.md3", self.origin, '0 0 600',0);

		TossGib (world, "models/gibs/gib1.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib2.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib3.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib4.md3", self.origin, self.velocity,0);

		// these destory on impact
		TossGib (world, "models/gibs/gib5.md3", self.origin, '-500 0 450',1);
		TossGib (world, "models/gibs/gib6.md3", self.origin, '0 500 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 -500 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '500 0 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity,1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 0 450',1);

		sound (trace_ent, CHAN_VOICE, "misc/gib.wav", 1, ATTN_NORM);
	}
}

void DropAllRunes(entity pl);


void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save;

	te_blood (hitloc, force, damage);
	if (self.pain_finished < time)		//Don't switch pain sequences like crazy
	{
		if (random() > 0.5)
			self.pain_frame = $pain1;
		else
			self.pain_frame = $pain2;
		self.pain_finished = time + 0.5;	//Supajoe
	}

	if (!cvar("g_minstagib"))
	{
		save = bound(0, damage * cvar("g_balance_armor_blockpercent"), self.armorvalue);
		take = bound(0, damage - save, damage);
	}
	else
	{
		save = 0;
		take = damage;
	}

	if (save > 10)
		sound (self, CHAN_IMPACT, "misc/armorimpact.wav", 1, ATTN_NORM);
	else if (take > 30)
		sound (self, CHAN_IMPACT, "misc/bodyimpact2.wav", 1, ATTN_NORM);
	else if (take > 10)
		sound (self, CHAN_IMPACT, "misc/bodyimpact1.wav", 1, ATTN_NORM);

	if (take > 50)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
	if (take > 100)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.2,1);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - save;
		self.health = self.health - take;
		// pause regeneration for 5 seconds
		self.pauseregen_finished = max(self.pauseregen_finished, time + 5);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if(attacker == self)
	{
		// don't reset pushltime for self damage as it may be an attempt to
		// escape a lava pit or similar
		//self.pushltime = 0;
	}
	else if(attacker.classname == "player" || attacker.classname == "gib")
	{
		self.pusher = attacker;
		self.pushltime = time + cvar("g_maxpushtime");
	}
	else if(time < self.pushltime)
	{
		attacker = self.pusher;
		self.pushltime = max(self.pushltime, time + 0.6);
	}
	else
		self.pushltime = 0;

	if (self.health <= 2)
	{
		DropAllRunes(self);

		// throw a weapon
		SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.weapon);
		// print an obituary message
		Obituary (attacker, self, deathtype);
		// make the corpse upright (not tilted)
		self.angles_x = 0;
		self.angles_z = 0;
		// don't spin
		self.avelocity = '0 0 0';
		// no weapon when dead
		self.weaponmodel = "";
		w_clear();
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
		self.dead_time = time + 2;
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
		// set damage function to corpse damage
		self.event_damage = PlayerCorpseDamage;
		// call the corpse damage function just in case it wants to gib
		self.event_damage(inflictor, attacker, 0, deathtype, hitloc, force);
		// set up to fade out later
		SUB_SetFade (self, time + 12 + random () * 4, 1);
	}
}

