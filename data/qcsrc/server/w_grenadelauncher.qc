
void W_Grenade_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/grenexpl.spr", 0, 12, 35);
	sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_primary_damage"), cvar("g_balance_grenadelauncher_primary_edgedamage"), cvar("g_balance_grenadelauncher_primary_radius"), world, cvar("g_balance_grenadelauncher_primary_force"), IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_Explode2 (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/grenexpl.spr", 0, 12, 35);
	sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_secondary_damage"), cvar("g_balance_grenadelauncher_secondary_edgedamage"), cvar("g_balance_grenadelauncher_secondary_radius"), world, cvar("g_balance_grenadelauncher_secondary_force"), IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_Touch1 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	W_Grenade_Explode ();
}

void W_Grenade_Touch2 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	if (other.takedamage == DAMAGE_AIM)
		self.think ();
	else
	{
		float r;
		r = random() * 6;
		if(r < 1)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce1.wav", 1, ATTN_NORM);
		else if(r < 2)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce2.wav", 1, ATTN_NORM);
		else if(r < 3)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce3.wav", 1, ATTN_NORM);
		else if(r < 4)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce4.wav", 1, ATTN_NORM);
		else if(r < 5)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce5.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce6.wav", 1, ATTN_NORM);
	}
}

void W_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.owner = attacker;
		self.think ();
	}
}

void W_Grenade_Attack (void)
{
	local entity gren;

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_primary_ammo");
	W_SetupShot (self, '11 8 -8', FALSE, 4, "weapons/grenade_fire.wav");

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = cvar("g_balance_grenadelauncher_primary_damage");
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_LOWPRECISION;
	setmodel(gren, "models/grenademodel.md3"); // precision set above
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_grenadelauncher_primary_lifetime");
	gren.think = W_Grenade_Explode;
	gren.touch = W_Grenade_Touch1;
	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_primary_speed") + v_up * cvar("g_balance_grenadelauncher_primary_speed_up");
	W_SetupProjectileVelocity(gren);
	gren.avelocity_x = random () * -500 - 500;

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
}

void W_Grenade_Attack2 (void)
{
	local entity gren;

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_secondary_ammo");
	W_SetupShot (self, '11 8 -8', FALSE, 4, "weapons/grenade_fire.wav");

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = cvar("g_balance_grenadelauncher_secondary_damage");
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_LOWPRECISION;
	setmodel(gren, "models/grenademodel.md3"); // precision set above
	setsize(gren, '0 0 -3', '0 0 -3');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_grenadelauncher_secondary_lifetime");
	gren.think = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;
	gren.takedamage = DAMAGE_YES;
	gren.health = 10;
	gren.damageforcescale = 4;
	gren.event_damage = W_Grenade_Damage;
	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_secondary_speed") + v_up * cvar("g_balance_grenadelauncher_secondary_speed_up");
	W_SetupProjectileVelocity(gren);
	gren.avelocity = '100 150 100';

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
}

.float bot_secondary_grenademooth;
float(float req) w_glauncher =
{
	if (req == WR_AIM)
	{
		self.button0 = FALSE;
		self.button3 = FALSE;
		if (self.bot_secondary_grenademooth == 0)
		{
			if(bot_aim(cvar("g_balance_grenadelauncher_primary_speed"), cvar("g_balance_grenadelauncher_primary_speed_up"), cvar("g_balance_grenadelauncher_primary_lifetime"), TRUE))
			{
				self.button0 = TRUE;
				if(random() < 0.01) self.bot_secondary_grenademooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_grenadelauncher_secondary_speed"), cvar("g_balance_grenadelauncher_secondary_speed_up"), cvar("g_balance_grenadelauncher_secondary_lifetime"), TRUE))
			{
				self.button3 = TRUE;
				if(random() < 0.02) self.bot_secondary_grenademooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_grenadelauncher_primary_refire")))
		{
			W_Grenade_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_grenadelauncher_primary_animtime"), w_ready);
		}
		if (self.button3)
		if (weapon_prepareattack(1, cvar("g_balance_grenadelauncher_secondary_refire")))
		{
			W_Grenade_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_grenadelauncher_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/grenademodel.md3");
		precache_model ("models/weapons/g_gl.md3");
		precache_model ("models/weapons/v_gl.md3");
		precache_model ("models/weapons/w_gl.zym");
		precache_sound ("weapons/grenade_bounce1.wav");
		precache_sound ("weapons/grenade_bounce2.wav");
		precache_sound ("weapons/grenade_bounce3.wav");
		precache_sound ("weapons/grenade_bounce4.wav");
		precache_sound ("weapons/grenade_bounce5.wav");
		precache_sound ("weapons/grenade_bounce6.wav");
		precache_sound ("weapons/grenade_fire.wav");
		precache_sound ("weapons/grenade_impact.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_GRENADE_LAUNCHER, "gl", IT_ROCKETS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_grenadelauncher_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_grenadelauncher_secondary_ammo");
	return TRUE;
};
