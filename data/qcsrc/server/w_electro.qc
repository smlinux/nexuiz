
void W_Plasma_Explode (void)
{
	vector org2;
	org2 = findbetterlocation (self.origin, 8);

	self.event_damage = SUB_Null;
	if (self.movetype == MOVETYPE_BOUNCE)
	{
		pointparticles(particleeffectnum("electro_ballexplode"), org2, '0 0 0', 1);
		RadiusDamage (self, self.owner, cvar("g_balance_electro_secondary_damage"), cvar("g_balance_electro_secondary_edgedamage"), cvar("g_balance_electro_secondary_radius"), world, cvar("g_balance_electro_secondary_force"), WEP_ELECTRO);
	}
	else
	{
		pointparticles(particleeffectnum("electro_impact"), org2, '0 0 0', 1);
		RadiusDamage (self, self.owner, cvar("g_balance_electro_primary_damage"), cvar("g_balance_electro_primary_edgedamage"), cvar("g_balance_electro_primary_radius"), world, cvar("g_balance_electro_primary_force"), WEP_ELECTRO);
	}
	sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);

	remove (self);
}

void W_Plasma_Explode_Combo (void) {
	vector org2;

	org2 = findbetterlocation (self.origin, 8);
	pointparticles(particleeffectnum("electro_combo"), org2, '0 0 0', 1);

	sound (self, CHAN_PROJECTILE, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_electro_combo_damage"), cvar("g_balance_electro_combo_edgedamage"), cvar("g_balance_electro_combo_radius"), world, cvar("g_balance_electro_combo_force"), WEP_ELECTRO);
	remove (self);
}

void W_Plasma_Touch (void)
{
	entity o;
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound (self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);
		remove(self);
		return;
	}
	if (other.takedamage == DAMAGE_AIM) {
		o = self.owner;
		W_Plasma_Explode ();
		if(other.classname == "player")
			if(IsDifferentTeam(o, other))
				if(IsFlying(other))
					announce(o, "announcer/male/electrobitch.ogg");
	} else {
		sound (self, CHAN_PROJECTILE, "weapons/electro_bounce.wav", VOL_BASE, ATTN_NORM);
	}
}

void W_Plasma_TouchExplode (void)
{
	entity o;
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound (self, CHAN_PROJECTILE, "misc/null.wav", VOL_BASE, ATTN_NORM);
		remove(self);
		return;
	}
	o = self.owner;
	W_Plasma_Explode ();
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(o, other))
				if(IsFlying(other))
					announce(o, "announcer/male/electrobitch.ogg");
}

void W_Plasma_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.takedamage = DAMAGE_NO;
		self.nextthink = time;
		if (inflictor.classname == "plasma_chain" || inflictor.classname == "plasma_prim")
		{
			// change owner to whoever caused the combo explosion
			self.owner = inflictor.owner;
			self.classname = "plasma_chain";
			self.think = W_Plasma_Explode_Combo;
		}
		else
			self.think = W_Plasma_Explode;
	}
}

void W_Electro_Attack()
{
	local entity proj;

	W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/electro_fire.wav");

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_electro_primary_damage");
	proj.think = W_Plasma_Explode;
	proj.nextthink = time + cvar("g_balance_electro_primary_lifetime");
	proj.solid = SOLID_BBOX;
	setorigin(proj, w_shotorg);

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_electro_primary_ammo");
	proj.effects = EF_BRIGHTFIELD | EF_LOWPRECISION;
	proj.movetype = MOVETYPE_FLY;
	proj.velocity = w_shotdir * cvar("g_balance_electro_primary_speed");
	W_SetupProjectileVelocity(proj);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	proj.flags = FL_PROJECTILE;
	setmodel(proj, "models/elaser.mdl"); // precision set above
	setsize(proj, '0 0 0', '0 0 0');

	// LordHavoc: disabled because no one likes this sound and it sometimes never stops due to packet loss
	//sound (proj, CHAN_PROJECTILE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
}

void W_Electro_Attack2()
{
	local entity proj;

	W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/electro_fire2.wav");

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma";
	proj.owner = self;
	proj.think = W_Plasma_Explode;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_electro_secondary_damage");
	proj.nextthink = time + cvar("g_balance_electro_secondary_lifetime");
	proj.solid = SOLID_BBOX;
	setorigin(proj, w_shotorg);

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_electro_secondary_ammo");
	proj.effects = EF_LOWPRECISION;
	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.velocity = (w_shotdir + randomvec() * cvar("g_balance_electro_secondary_spread")) * cvar("g_balance_electro_secondary_speed") + v_up * cvar("g_balance_electro_secondary_speed_up");
	W_SetupProjectileVelocity(proj);
	proj.touch = W_Plasma_Touch;
	setmodel(proj, "models/ebomb.mdl"); // precision set above
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = 4;
	proj.health = 5;
	proj.event_damage = W_Plasma_Damage;
	proj.flags = FL_PROJECTILE;

	// LordHavoc: disabled because no one likes this sound and it sometimes never stops due to packet loss
	//sound (proj, CHAN_PROJECTILE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
}

void spawnfunc_weapon_electro (void)
{
	weapon_defaultspawnfunc(WEP_ELECTRO, 5000);
}

.float bot_secondary_electromooth;
float w_electro(float req)
{
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_electromooth = 0;
		if(self.bot_secondary_electromooth == 0)
		{
			if(bot_aim(cvar("g_balance_electro_primary_speed"), 0, cvar("g_balance_electro_primary_lifetime"), FALSE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_electromooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_electro_secondary_speed"), cvar("g_balance_grenadelauncher_secondary_speed_up"), cvar("g_balance_electro_secondary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.03) self.bot_secondary_electromooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_electro_primary_refire")))
		{
			W_Electro_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_electro_secondary_refire")))
		{
			W_Electro_Attack2();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/ebomb.mdl");
		precache_model ("models/elaser.mdl");
		precache_model ("models/weapons/g_electro.md3");
		precache_model ("models/weapons/v_electro.md3");
		precache_model ("models/weapons/w_electro.zym");
		precache_sound ("weapons/electro_bounce.wav");
		precache_sound ("weapons/electro_fire.wav");
		precache_sound ("weapons/electro_fire2.wav");
		precache_sound ("weapons/electro_fly.wav");
		precache_sound ("weapons/electro_impact.wav");
		precache_sound ("weapons/electro_impact_combo.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_ELECTRO);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_electro_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= cvar("g_balance_electro_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "played with plasma";
	else if (req == WR_SPAWNFUNC)
		spawnfunc_weapon_electro();
	// else if (req == WR_KILLMESSAGE) // TODO
	return TRUE;
};
