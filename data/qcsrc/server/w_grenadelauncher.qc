#ifdef REGISTER_WEAPON
REGISTER_WEAPON(GRENADE_LAUNCHER, w_glauncher, IT_ROCKETS, 4, WEP_FLAG_NORMAL | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "gl", "grenadelauncher", "Mortar");
#else
void W_Grenade_Explode (void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.owner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.owner, "airshot");

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_primary_damage"), cvar("g_balance_grenadelauncher_primary_edgedamage"), cvar("g_balance_grenadelauncher_primary_radius"), world, cvar("g_balance_grenadelauncher_primary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_Grenade_Explode2 (void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.owner, other))
				if(IsFlying(other))
					AnnounceTo(self.owner, "airshot");

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_secondary_damage"), cvar("g_balance_grenadelauncher_secondary_edgedamage"), cvar("g_balance_grenadelauncher_secondary_radius"), world, cvar("g_balance_grenadelauncher_secondary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_Grenade_Touch1 (void)
{
	PROJECTILE_TOUCH;
	W_Grenade_Explode ();
}

void W_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM)
	{
		self.use ();
	}
	else
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CHAN_PROJECTILE, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
	}
}

void W_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		W_PrepareExplosionByDamage(attacker, self.think);
	}
}

void W_Grenade_Attack (void)
{
	local entity gren;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_primary_ammo");
	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/grenade_fire.wav", cvar("g_balance_grenadelauncher_primary_damage"));
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = cvar("g_balance_grenadelauncher_primary_damage");
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, w_shotorg);
	setsize(gren, '0 0 -3', '0 0 -3');

	gren.nextthink = time + cvar("g_balance_grenadelauncher_primary_lifetime");
	gren.think = adaptor_think2use;
	gren.use = W_Grenade_Explode;
	gren.touch = W_Grenade_Touch1;
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_primary);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);	
}

void W_Grenade_Attack2 (void)
{
	local entity gren;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_secondary_ammo");
	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 4, "weapons/grenade_fire.wav", cvar("g_balance_grenadelauncher_secondary_damage"));
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = cvar("g_balance_grenadelauncher_secondary_damage");
	gren.movetype = MOVETYPE_BOUNCE;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setsize(gren, '0 0 -3', '0 0 -3');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_grenadelauncher_secondary_lifetime");
	gren.think = adaptor_think2use;
	gren.use = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;
	gren.takedamage = DAMAGE_YES;
	gren.health = cvar("g_balance_grenadelauncher_secondary_health");
	gren.damageforcescale = cvar("g_balance_grenadelauncher_secondary_damageforcescale");
	gren.event_damage = W_Grenade_Damage;
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);
}

void spawnfunc_weapon_grenadelauncher (void)
{
	weapon_defaultspawnfunc(WEP_GRENADE_LAUNCHER);
}

.float bot_secondary_grenademooth;
float w_glauncher(float req)
{
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if (self.bot_secondary_grenademooth == 0)
		{
			if(bot_aim(cvar("g_balance_grenadelauncher_primary_speed"), cvar("g_balance_grenadelauncher_primary_speed_up"), cvar("g_balance_grenadelauncher_primary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_grenademooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_grenadelauncher_secondary_speed"), cvar("g_balance_grenadelauncher_secondary_speed_up"), cvar("g_balance_grenadelauncher_secondary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.02) self.bot_secondary_grenademooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_grenadelauncher_primary_refire")))
		{
			if(cvar("g_balance_grenadelauncher_primary2secondary"))
				W_Grenade_Attack2();
			else
				W_Grenade_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_grenadelauncher_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2 && !cvar("g_balance_grenadelauncher_primary2secondary"))
		if (weapon_prepareattack(1, cvar("g_balance_grenadelauncher_secondary_refire")))
		{
			W_Grenade_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_grenadelauncher_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_gl.md3");
		precache_model ("models/weapons/v_gl.md3");
		precache_model ("models/weapons/h_gl.dpm");
		precache_sound ("weapons/grenade_bounce1.wav");
		precache_sound ("weapons/grenade_bounce2.wav");
		precache_sound ("weapons/grenade_bounce3.wav");
		precache_sound ("weapons/grenade_bounce4.wav");
		precache_sound ("weapons/grenade_bounce5.wav");
		precache_sound ("weapons/grenade_bounce6.wav");
		precache_sound ("weapons/grenade_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_GRENADE_LAUNCHER);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_grenadelauncher_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_grenadelauncher_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "tried out his own grenade";
		else
			w_deathtypestring = "detonated";
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = "didn't see #'s grenade";
			else // unchecked: SECONDARY
				w_deathtypestring = "almost dodged #'s grenade";
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = "ate #'s grenade";
	}
	return TRUE;
};
#endif
