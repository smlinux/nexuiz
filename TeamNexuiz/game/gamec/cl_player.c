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

void player_cooloff();
void BodyFakePhysics()
{
	self.think = BodyFakePhysics;
	self.nextthink = time;

	SV_PlayerPhysics();

	player_cooloff();
}

void CopyBody2(float keepvelocity, float testbody)
{
	local entity oldself;
	if (self.effects & EF_NODRAW)
		return;
	oldself = self;
	self = spawn();
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.mass = oldself.mass;
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.event_damage = oldself.event_damage;
	self.frame = oldself.frame;
	self.health = oldself.health;
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
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);//'-16 -16 -24',  '16 16 5');
	self.oldorigin = oldself.origin;
	// move any fire burning me to the corpse
	if(oldself.onfire != world)
	{
		self.onfire = oldself.onfire;		// corpse is now on fire
		self.onfire.enemy = self;		// burn corpse instead of me when I respawn
		oldself.onfire = world;			// I'm not on fire anymore
		setattachment(self.onfire, self, "");
	}

	if(testbody)
	{
		self.armorvalue = oldself.armorvalue;
		self.think = BodyFakePhysics;
		self.nextthink = time;
	}
	
	self = oldself;
}

void CopyBody(float keepvelocity)
{
	CopyBody2(keepvelocity, FALSE);
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

	if (self.is_feigning == 1)
	{
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
		{
			self.frame = $run;
		}
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
	{
		if (self.crouch)
			self.frame = $duckwalk;
		else
			self.frame = $jump;
	}
}
//End change by Supajoe on 11:44 PM EST 11/16/03 (Subject: Player animations)


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
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 800, 1000);
		te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 400, 1000);

		// make a meaty mess
		TossGib (self, "models/gibs/eye.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/bloodyskull.md3", self.origin, '0 0 600',0);

		TossGib (world, "models/gibs/gib1.md3", self.origin, self.velocity,0);
		//TossGib (world, "models/gibs/gib2.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib1.mdl", self.origin, self.velocity,0);
		//TossGib (world, "models/gibs/gib3.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib2.mdl", self.origin, self.velocity,0);
		//TossGib (world, "models/gibs/gib4.md3", self.origin, self.velocity,0);
		TossGib (world, "models/gibs/gib3.mdl", self.origin, self.velocity,0);

		// these destory on impact
		TossGib (world, "models/gibs/gib5.md3", self.origin, '-500 0 450',1);
		//TossGib (world, "models/gibs/gib6.md3", self.origin, '0 500 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 -500 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '500 0 450',1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, self.velocity,1);
		TossGib (world, "models/gibs/chunk.mdl", self.origin, '0 0 450',1);

		sound (trace_ent, CHAN_VOICE, "misc/gib.wav", 1, ATTN_NORM);

	}
}

void PlayerKilled (float unnatural_death, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.class == CLASS_SPY)
		SpyDecloak();

	// fixes death while reloading glitch
	inflictor.reload_time = 0;
	// fixes flash effects staying after death bug
	self.FlashTime = 0;
	stuffcmd(inflictor, "v_cshift 0 0 0 0\n");
	
	// throw a weapon
	SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.wpn5.weapon);//self.weapon);
	// print an obituary message
	Obituary (attacker, self, deathtype);
	// Drop flag or any carried item
	TeamFortress_RemoveTimers ();
	// Make sure corpse cant take tfgoal items
	self.is_dead = 1;
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
	if(!unnatural_death)
	{
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
	}
	else
	{
		self.die_frame = $dead2;
		self.dead_frame = $dead2;
		if(self.health > -1)
			self.health = -1;
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

float PlayerShouldDie (entity inflictor, entity attacker, float damage, float deathtype)
{
	// returns true if player should die from this source of damage.
	// If so, don't block this damage in any way

	if(damage > 2000)
		return TRUE;

	if(    deathtype == DEATH_FALL
		|| deathtype == DEATH_TELEFRAG
		|| deathtype == DEATH_DROWN
		|| deathtype == DEATH_HURTTRIGGER
		|| deathtype == DEATH_LAVA
		|| deathtype == DEATH_SLIME
		|| deathtype == DEATH_KILL
		|| deathtype == DEATH_CLASSCHANGE
//		|| deathtype == DEATH_BURNING
		|| deathtype == DEATH_LASERGATE
		)
		return TRUE;

	return FALSE;
}

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local float take, save, damagearmor;

	 te_blood (hitloc, force, damage);
	if (self.pain_finished < time)		//Don't switch pain sequences like crazy
	{
		if (random() > 0.5)
			self.pain_frame = $pain1;
		else
			self.pain_frame = $pain2;
		self.pain_finished = time + 0.5;	//Supajoe
	}

	if(self.class == CLASS_MEDIC)
	{
		if(deathtype == DEATH_BURNING)
			damage = 0;	// being on fire or near burning targets does nothing to medics
		// the flame thrower, flame rockets, and hotbombs also do minimal damage
		else if(deathtype == WEP_FLAMER ||
				deathtype == WEP_ROCKET_INCENDIARY ||
				deathtype == WEP_HOTBOMBS)
			damage = damage * cvar("g_balance_class_medic_flame_takedamage");
	}

	// how much damage to deal to armor
	damagearmor = bound(0, damage * 0.2 * (self.armorvalue / 50) * cvar("g_balance_armor_takedamage"), self.armorvalue);
	// how much damage armor blocks
	save = bound(0, damage * (self.armorvalue / 100) * cvar("g_balance_armor_effectiveness"), damage);
	// how much damage to deal to player
	take = bound(0, damage - save, damage);

	// if being telefragged or killed by a death trigger etc, don't block that
	if(PlayerShouldDie(inflictor, attacker, damage, deathtype))
	{
		if(take < damage)
			take = damage; // deal full damage
	}
	else
	{
		// keep the damage the armor allowed through, and further reduce it if the player is using the shield
		if(self.class == CLASS_SCOUT)
			take = SpecialShieldProtect(take);
	}

	if (save > 10)
		sound (self, CHAN_IMPACT, "misc/armorimpact.wav", 1, ATTN_NORM);
	if (take > 10)
		sound (self, CHAN_IMPACT, "misc/bodyimpact1.wav", 1, ATTN_NORM);
	if (take > 30)
		sound (self, CHAN_IMPACT, "misc/bodyimpact2.wav", 1, ATTN_NORM);

	if (take > 50)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);
	if (take > 100)
		TossGib (world, "models/gibs/chunk.mdl", hitloc, force * -0.1,1);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - damagearmor;
		self.health = self.health - take;
	}

	DelayHealthRegen(self);
	DelayArmorRegen(self);


	self.dmg_save = self.dmg_save + max(save - 10, 0);
	self.dmg_take = self.dmg_take + max(take - 10, 0);
	self.dmg_inflictor = inflictor;
	if (self.health <= 2)
	{
		PlayerKilled(FALSE, inflictor, attacker, damage, deathtype, hitloc, force);

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

