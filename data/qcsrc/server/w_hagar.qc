void W_Hagar_Explode (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/hagar.spr", 0, 12, 35);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_BODY, "weapons/hagexp1.wav", 1, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_BODY, "weapons/hagexp2.wav", 1, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_BODY, "weapons/hagexp3.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hagar_primary_damage"), cvar("g_balance_hagar_primary_edgedamage"), cvar("g_balance_hagar_primary_radius"), world, cvar("g_balance_hagar_primary_force"), IT_HAGAR);

	remove (self);
}

void W_Hagar_Explode2 (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/hagar.spr", 0, 12, 35);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_BODY, "weapons/hagexp1.wav", 1, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_BODY, "weapons/hagexp2.wav", 1, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_BODY, "weapons/hagexp3.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hagar_secondary_damage"), cvar("g_balance_hagar_secondary_edgedamage"), cvar("g_balance_hagar_secondary_radius"), world, cvar("g_balance_hagar_secondary_force"), IT_HAGAR);

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
	W_SetupShot (self, '11 5 -8', FALSE, 2, "weapons/hagar_fire.wav");

	missile = spawn ();
	missile.owner = self;
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
	W_SetupShot (self, '11 5 -8', FALSE, 2, "weapons/hagar_fire.wav");

	missile = spawn ();
	missile.owner = self;
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

	missile.movetype = MOVETYPE_BOUNCEMISSILE;
	missile.velocity = (w_shotdir + randomvec() * cvar("g_balance_hagar_secondary_spread")) * cvar("g_balance_hagar_secondary_speed");
	W_SetupProjectileVelocity(missile);
	missile.avelocity = '100 10 10';

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
}

float(float req) w_hagar =
{
	if (req == WR_AIM)
		if (random()>0.15)
			self.button0 = bot_aim(cvar("g_balance_hagar_primary_speed"), 0, cvar("g_balance_hagar_primary_lifetime"), FALSE);
		else
		{
			// not using secondary_speed since these are only 15% and should cause some ricochets without re-aiming
			self.button3 = bot_aim(cvar("g_balance_hagar_primary_speed"), 0, cvar("g_balance_hagar_primary_lifetime"), FALSE);
		}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_hagar_primary_refire")))
		{
			W_Hagar_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hagar_primary_refire"), w_ready);
		}
		if (self.button3)
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
		weapon_setup(WEP_HAGAR, "hagar", IT_ROCKETS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_hagar_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_hagar_secondary_ammo");
	return TRUE;
};
