void W_Hagar_Explode (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin, 12);
	pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.realowner, cvar("g_balance_hagar_primary_damage"), cvar("g_balance_hagar_primary_edgedamage"), cvar("g_balance_hagar_primary_radius"), world, cvar("g_balance_hagar_primary_force"), WEP_HAGAR);

	remove (self);
}

void W_Hagar_Explode2 (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin, 12);
	pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_PROJECTILE, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.realowner, cvar("g_balance_hagar_secondary_damage"), cvar("g_balance_hagar_secondary_edgedamage"), cvar("g_balance_hagar_secondary_radius"), world, cvar("g_balance_hagar_secondary_force"), WEP_HAGAR);

	remove (self);
}

void W_Hagar_Touch (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	if (other == self.owner)
		return;

	self.think ();
}

void W_Hagar_Touch2 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}

	if(self.cnt > 0 || other.takedamage == DAMAGE_AIM) {
		self.think();
	} else {
		self.cnt++;
		pointparticles(particleeffectnum("hagar_bounce"), self.origin, self.velocity, 1);
		self.angles = vectoangles (self.velocity);
		self.owner = world;
	}
}

void W_Hagar_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		self.think ();
}

void W_Hagar_Attack (void)
{
	local entity missile;

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_primary_ammo");
	W_SetupShot (self, '25 5 -8', FALSE, 2, "weapons/hagar_fire.wav");
	//W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/hagar_fire.wav"); // TODO: move model a little to the right

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_hagar_primary_damage");
	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + cvar("g_balance_hagar_primary_lifetime");
	missile.solid = SOLID_BBOX;
	missile.scale = 0.4; // BUG: the model is too big
	setorigin (missile, w_shotorg);
	setmodel (missile, "models/hagarmissile.mdl"); // precision set below
	setsize (missile, '0 0 0', '0 0 0');
	//missile.takedamage = DAMAGE_YES;
	//missile.damageforcescale = 4;
	//missile.health = 10;
	//missile.event_damage = W_Hagar_Damage;
	missile.effects = EF_LOWPRECISION;
	missile.modelflags = MF_GRENADE;

	missile.movetype = MOVETYPE_FLY;
	missile.velocity = (w_shotdir + randomvec() * cvar("g_balance_hagar_primary_spread")) * cvar("g_balance_hagar_primary_speed");
	W_SetupProjectileVelocity(missile);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
}

void W_Hagar_Attack2 (void)
{
	local entity missile;

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_secondary_ammo");
	W_SetupShot (self, '25 5 -8', FALSE, 2, "weapons/hagar_fire.wav");
	//W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/hagar_fire.wav"); // TODO: move model a little to the right

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_hagar_secondary_damage");
	missile.touch = W_Hagar_Touch2;
	missile.cnt = 0;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + cvar("g_balance_hagar_secondary_lifetime");
	missile.solid = SOLID_BBOX;
	missile.scale = 0.4; // BUG: the model is too big
	setorigin (missile, w_shotorg);
	setmodel (missile, "models/hagarmissile.mdl"); // precision set below
	setsize (missile, '0 0 0', '0 0 0');
	//missile.takedamage = DAMAGE_YES;
	//missile.damageforcescale = 4;
	//missile.health = 10;
	//missile.event_damage = W_Hagar_Damage;
	missile.effects = EF_LOWPRECISION;
	missile.modelflags = MF_GRENADE;

	missile.movetype = MOVETYPE_BOUNCEMISSILE;
	missile.velocity = (w_shotdir + randomvec() * cvar("g_balance_hagar_secondary_spread")) * cvar("g_balance_hagar_secondary_speed");
	W_SetupProjectileVelocity(missile);
	missile.avelocity = '100 10 10';

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
}

void spawnfunc_weapon_hagar (void)
{
	weapon_defaultspawnfunc(WEP_HAGAR, 5000);
}

float w_hagar(float req)
{
	if (req == WR_AIM)
		if (random()>0.15)
			self.BUTTON_ATCK = bot_aim(cvar("g_balance_hagar_primary_speed"), 0, cvar("g_balance_hagar_primary_lifetime"), FALSE);
		else
		{
			// not using secondary_speed since these are only 15% and should cause some ricochets without re-aiming
			self.BUTTON_ATCK2 = bot_aim(cvar("g_balance_hagar_primary_speed"), 0, cvar("g_balance_hagar_primary_lifetime"), FALSE);
		}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_hagar_primary_refire")))
		{
			W_Hagar_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hagar_primary_refire"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_hagar_secondary_refire")))
		{
			W_Hagar_Attack2();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hagar_secondary_refire"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/hagarmissile.mdl");
		precache_model ("models/weapons/g_hagar.md3");
		precache_model ("models/weapons/v_hagar.md3");
		precache_model ("models/weapons/w_hagar.zym");
		precache_sound ("weapons/hagar_fire.wav");
		precache_sound ("weapons/hagexp1.wav");
		precache_sound ("weapons/hagexp2.wav");
		precache_sound ("weapons/hagexp3.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAGAR, "hagar");
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_hagar_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_hagar_secondary_ammo");
	// else if (req == WR_SUICIDEMESSAGE) // TODO
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "was pummeled by";
	else if (req == WR_SPAWNFUNC)
		spawnfunc_weapon_hagar();
	return TRUE;
};
