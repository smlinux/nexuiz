void() shotgun_ready_01;
void() shotgun_fire1_01;
void() shotgun_fire2_01;
void() shotgun_deselect_01;
void() shotgun_select_01;

float() shotgun_check =
{
	if (self.ammo_shells >= cvar("g_balance_shotgun_primary_ammo"))
		return TRUE;
	return FALSE;
};

float() shotgun_check2 =
{
	if (self.ammo_shells >= cvar("g_balance_shotgun_secondary_ammo"))
		return TRUE;
	return FALSE;
};

void(float req) w_shotgun =
{
	if (req == WR_IDLE)
		shotgun_ready_01();
	else if (req == WR_AIM)
		self.button0 = bot_aim(1000000, 0, 0.001, FALSE);
	else if (req == WR_FIRE1)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire1_01, cvar("g_balance_shotgun_primary_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(shotgun_check2, shotgun_check2, shotgun_fire2_01, cvar("g_balance_shotgun_secondary_refire"));
	else if (req == WR_RAISE)
		shotgun_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_shells;
	else if (req == WR_DROP)
		shotgun_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN, "w_shotgun.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = shotgun_check() + shotgun_check2();
};

void W_Shotgun_Attack (void)
{
	local vector org;
	float	sc;
	float	bullets;
	float	d;
	float	spread;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	bullets = cvar("g_balance_shotgun_primary_bullets");
	d = cvar("g_balance_shotgun_primary_damage");
	spread = cvar("g_balance_shotgun_primary_spread");

	org = W_MuzzleOrigin (self, '26 9 -10');
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet (org, normalize(trueaim - org), spread, d, IT_SHOTGUN, sc < 3);
	if (cvar("g_use_ammunition"))
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_primary_ammo");

	W_Smoke(org, v_forward, 12);
	//te_smallflash(org);

	// casing code
	if (cvar("g_casings") >= 1)
	{
		org = W_MuzzleOrigin (self, '10 10 -8');
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 1);
	}

	self.punchangle_x = -5;
}

void W_Shotgun_Attack2 (void)
{
	local vector org;
	float	sc;
	float	bullets;
	float	d;
	float	spread;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	bullets = cvar("g_balance_shotgun_secondary_bullets");
	d = cvar("g_balance_shotgun_secondary_damage");
	spread = cvar("g_balance_shotgun_secondary_spread");

	org = W_MuzzleOrigin (self, '26 9 -10');
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet (org, normalize(trueaim - org), spread, d, IT_SHOTGUN, sc < 3);
	if (cvar("g_use_ammunition"))
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_secondary_ammo");

	W_Smoke(org, v_forward, 12);
	//te_smallflash(org);

	// casing code
	if (cvar("g_casings") >= 1)
	{
		org = W_MuzzleOrigin (self, '10 10 -8');
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 1);
	}

	self.punchangle_x = -5;
}

// weapon frames

void()	shotgun_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, shotgun_ready_01); self.weaponentity.state = WS_READY;};
void()	shotgun_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	shotgun_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	shotgun_fire1_01 =
{
	weapon_doattack(shotgun_check, shotgun_check, W_Shotgun_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_primary_animtime"), shotgun_ready_01);
};
void()  shotgun_fire2_03 =
{
	weapon_doattack(shotgun_check2, shotgun_check2, W_Shotgun_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), shotgun_ready_01);
}
void()  shotgun_fire2_02 =
{
	weapon_doattack(shotgun_check2, shotgun_check2, W_Shotgun_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_03);
}
void()  shotgun_fire2_01 =
{
	weapon_doattack(shotgun_check2, shotgun_check2, W_Shotgun_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_02);
}
