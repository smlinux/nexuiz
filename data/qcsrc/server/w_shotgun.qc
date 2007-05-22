
void W_Shotgun_Attack (void)
{
	float	sc;
	float	bullets;
	float	d;
	float	f;
	float	spread;

	bullets = cvar("g_balance_shotgun_primary_bullets");
	d = cvar("g_balance_shotgun_primary_damage");
	f = cvar("g_balance_shotgun_primary_force");
	spread = cvar("g_balance_shotgun_primary_spread");

	W_SetupShot (self, '11 8 -8', TRUE, 5, "weapons/shotgun_fire.wav");
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet (w_shotorg, w_shotdir, spread, d, f, IT_SHOTGUN, sc < 3);
	if (cvar("g_use_ammunition"))
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_primary_ammo");

	W_Smoke(w_shotorg + v_forward * 8, v_forward, 12);
	//te_smallflash(w_shotorg);

	// casing code
	if (cvar("g_casings") >= 1)
		SpawnCasing (w_shotorg, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1);
}

void W_Shotgun_Attack2 (void)
{
	float	sc;
	float	bullets;
	float	d;
	float	f;
	float	spread;

	bullets = cvar("g_balance_shotgun_secondary_bullets");
	d = cvar("g_balance_shotgun_secondary_damage");
	f = cvar("g_balance_shotgun_secondary_force");
	spread = cvar("g_balance_shotgun_secondary_spread");

	W_SetupShot (self, '11 8 -8', TRUE, 5, "weapons/shotgun_fire.wav");
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet (w_shotorg, w_shotdir, spread, d, f, IT_SHOTGUN, sc < 3);
	if (cvar("g_use_ammunition"))
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_secondary_ammo");

	W_Smoke(w_shotorg + v_forward * 8, v_forward, 12);
	//te_smallflash(w_shotorg);

	// casing code
	if (cvar("g_casings") >= 1)
		SpawnCasing (w_shotorg, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1);
}

// weapon frames
void()  shotgun_fire2_03 =
{
	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), w_ready);
}
void()  shotgun_fire2_02 =
{
	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_03);
}

float(float req) w_shotgun =
{
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin)>200)
			self.button0 = bot_aim(1000000, 0, 0.001, FALSE);
		else
			self.button3 = bot_aim(1000000, 0, 0.001, FALSE);
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_shotgun_primary_refire")))
		{
			W_Shotgun_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_primary_animtime"), w_ready);
		}
		if (self.button3)
		if (weapon_prepareattack(1, cvar("g_balance_shotgun_secondary_refire")))
		{
			W_Shotgun_Attack2();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_02);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/tracer.mdl");
		precache_model ("models/weapons/g_shotgun.md3");
		precache_model ("models/weapons/v_shotgun.md3");
		precache_model ("models/weapons/w_shotgun.zym");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ric1.wav");
		precache_sound ("weapons/ric2.wav");
		precache_sound ("weapons/ric3.wav");
		precache_sound ("weapons/shotgun_fire.wav");
		precache_sound ("weapons/tink1.wav");
		if (cvar("g_casings") >= 1)
			precache_model ("models/casing_shell.mdl");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN, "shotgun", IT_SHELLS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_shells >= cvar("g_balance_shotgun_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_shells >= cvar("g_balance_shotgun_secondary_ammo") * 3;
	return TRUE;
};
