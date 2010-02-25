#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HLAC, w_hlac, IT_CELLS, 6, WEP_FLAG_NORMAL | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "hlac", "hlac", "Heavy Laser Assault Cannon");
#else
.float HLAC_bulletcounter;
void W_HLAC_Touch (void)
{
	PROJECTILE_TOUCH;

	self.event_damage = SUB_Null;

    RadiusDamage (self, self.owner, cvar("g_balance_hlac_primary_damage"), cvar("g_balance_hlac_primary_edgedamage"), cvar("g_balance_hlac_primary_radius"), world, cvar("g_balance_hlac_primary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_HLAC_Touch2 (void)
{
	PROJECTILE_TOUCH;

	self.event_damage = SUB_Null;

    RadiusDamage (self, self.owner, cvar("g_balance_hlac_secondary_damage"), cvar("g_balance_hlac_secondary_edgedamage"), cvar("g_balance_hlac_secondary_radius"), world, cvar("g_balance_hlac_secondary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_HLAC_Attack (void)
{
	local entity missile;
    float spread;

    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
    {
        self.ammo_cells = self.ammo_cells - cvar("g_balance_hlac_primary_ammo");
    }

    spread = cvar("g_balance_hlac_primary_spread_min") + (cvar("g_balance_hlac_primary_spread_add") * self.HLAC_bulletcounter);
    spread = min(spread,cvar("g_balance_hlac_primary_spread_max"));
    if(self.crouch)
        spread = spread * cvar("g_balance_hlac_primary_spread_crouchmod");

	W_SetupShot (self, FALSE, 3, "weapons/lasergun_fire.wav", cvar("g_balance_hlac_primary_damage"));
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	missile = spawn ();
	missile.owner = self;
	missile.classname = "hlacbolt";
	// missile.dmg = issecondary;
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = cvar("g_balance_hlac_primary_damage");

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocity(missile, cvar("g_balance_hlac_primary_speed"), spread);
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + cvar("g_balance_hlac_primary_lifetime");

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);
}

void W_HLAC_Attack2f (void)
{
	local entity missile;
    float spread;

    spread = cvar("g_balance_hlac_secondary_spread");


    if(self.crouch)
        spread = spread * cvar("g_balance_hlac_secondary_spread_crouchmod");

	W_SetupShot (self, FALSE, 3, "weapons/lasergun_fire.wav", cvar("g_balance_hlac_secondary_damage"));
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "hlacbolt";
	// missile.dmg = issecondary;
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = cvar("g_balance_hlac_secondary_damage");

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocity(missile, cvar("g_balance_hlac_secondary_speed"), spread);
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_HLAC_Touch2;
	missile.think = SUB_Remove;

    missile.nextthink = time + cvar("g_balance_hlac_secondary_lifetime");

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC | HITTYPE_SECONDARY;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);
}

void W_HLAC_Attack2 (void)
{
    float i;

    if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
    {
        self.ammo_cells = self.ammo_cells - cvar("g_balance_hlac_secondary_ammo");
    }

    for(i=cvar("g_balance_hlac_secondary_shots");i>0;--i)
        W_HLAC_Attack2f();

	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
}

// weapon frames
void HLAC_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}

	if (self.BUTTON_ATCK)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO1))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}

		ATTACK_FINISHED(self) = time + cvar("g_balance_hlac_primary_refire") * W_WeaponRateFactor();
		W_HLAC_Attack();
		self.HLAC_bulletcounter = self.HLAC_bulletcounter + 1;
        weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hlac_primary_refire"), HLAC_fire1_02);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hlac_primary_animtime"), w_ready);
	}
};

void spawnfunc_weapon_hlac (void)
{
	weapon_defaultspawnfunc(WEP_HLAC);
}

float w_hlac(float req)
{
	if (req == WR_AIM)
        self.BUTTON_ATCK = bot_aim(cvar("g_balance_hlac_primary_speed"), 0, cvar("g_balance_hlac_primary_lifetime"), FALSE);
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_hlac_primary_refire")))
		{
			self.HLAC_bulletcounter = 0;
			W_HLAC_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hlac_primary_refire"), HLAC_fire1_02);
		}

		if (self.BUTTON_ATCK2 && cvar("g_balance_hlac_secondary"))
		if (weapon_prepareattack(1, cvar("g_balance_hlac_secondary_refire")))
		{
			W_HLAC_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_hlac_secondary_animtime"), w_ready);
		}

	}
	else if (req == WR_PRECACHE)
	{
        precache_model ("models/weapons/g_hlac.md3");
		precache_model ("models/weapons/v_hlac.md3");
		precache_model ("models/weapons/h_hlac.dpm");
		precache_sound ("weapons/lasergun_fire.wav");

	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_HLAC);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_hlac_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= cvar("g_balance_hlac_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "should have used a smaller gun";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "was cut down by";
	return TRUE;
};
#endif
