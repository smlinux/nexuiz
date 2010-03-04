#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HAGAR, w_hagar, IT_ROCKETS, 8, WEP_FLAG_NORMAL | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "hagar", "hagar", "Hagar");
#else
// NO bounce protection, as bounces are limited!
void W_Hagar_Explode (void)
{
	self.event_damage = SUB_Null;
	RadiusDamage (self, self.realowner, cvar("g_balance_hagar_primary_damage"), cvar("g_balance_hagar_primary_edgedamage"), cvar("g_balance_hagar_primary_radius"), world, cvar("g_balance_hagar_primary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_Hagar_Explode2 (void)
{
	self.event_damage = SUB_Null;
	RadiusDamage (self, self.realowner, cvar("g_balance_hagar_secondary_damage"), cvar("g_balance_hagar_secondary_edgedamage"), cvar("g_balance_hagar_secondary_radius"), world, cvar("g_balance_hagar_secondary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_Hagar_Touch (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void W_Hagar_Touch2 (void)
{
	PROJECTILE_TOUCH;

	if(self.cnt > 0 || other.takedamage == DAMAGE_AIM) {
		self.use();
	} else {
		self.cnt++;
		pointparticles(particleeffectnum("hagar_bounce"), self.origin, self.velocity, 1);
		self.angles = vectoangles (self.velocity);
		self.owner = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
	}
}

void W_Hagar_Attack (void)
{
	local entity missile;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_primary_ammo");
	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", cvar("g_balance_hagar_primary_damage"));

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_hagar_primary_damage");
	missile.touch = W_Hagar_Touch;
	missile.use = W_Hagar_Explode;
	missile.think = adaptor_think2use;
	missile.nextthink = time + cvar("g_balance_hagar_primary_lifetime");
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR;
	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	missile.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_primary);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR, TRUE);
}

void W_Hagar_Attack2 (void)
{
	local entity missile;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_secondary_ammo");
	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", cvar("g_balance_hagar_secondary_damage"));
	//W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav"); // TODO: move model a little to the right

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_hagar_secondary_damage");
	missile.touch = W_Hagar_Touch2;
	missile.cnt = 0;
	missile.use = W_Hagar_Explode2;
	missile.think = adaptor_think2use;
	missile.nextthink = time + cvar("g_balance_hagar_secondary_lifetime_min") + random() * cvar("g_balance_hagar_secondary_lifetime_rand");
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR | HITTYPE_SECONDARY;
	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	missile.movetype = MOVETYPE_BOUNCEMISSILE;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_secondary);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR_BOUNCING, TRUE);
}

void spawnfunc_weapon_hagar (void)
{
	weapon_defaultspawnfunc(WEP_HAGAR);
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
		if (self.BUTTON_ATCK2 && cvar("g_balance_hagar_secondary"))
		if (weapon_prepareattack(1, cvar("g_balance_hagar_secondary_refire")))
		{
			W_Hagar_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_hagar_secondary_refire"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_hagar.md3");
		precache_model ("models/weapons/v_hagar.md3");
		precache_model ("models/weapons/h_hagar.dpm");
		precache_sound ("weapons/hagar_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAGAR);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_hagar_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_hagar_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "played with tiny rockets";
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE) // must be secondary; unchecked: SPLASH
			w_deathtypestring = "hoped #'s missiles wouldn't bounce";
		else // unchecked: SPLASH, SECONDARY
			w_deathtypestring = "was pummeled by";
	}
	return TRUE;
};
#endif
