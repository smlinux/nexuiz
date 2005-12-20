void() shotgun_ready_01;
void() shotgun_fire1_01;
void() shotgun_fire2_01;
void() shotgun_deselect_01;
void() shotgun_select_01;

float() shotgun_check =
{
//	if (self.ammo_shells >= 1)
		return TRUE;
//	return FALSE;
};

void(float req) w_shotgun =
{
	if (req == WR_IDLE)
		shotgun_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire1_01, cvar("g_balance_shotgun_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire2_01, cvar("g_balance_shotgun_loadclip"));
	else if (req == WR_RAISE)
		shotgun_select_01();
	else if (req == WR_UPDATECOUNTS)
		return;//self.currentammo = self.ammo_shells;
	else if (req == WR_DROP)
		shotgun_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN, "w_shotgun.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = shotgun_check();
};

void W_Shotgun_Attack (void)
{
	local vector org;
	float	sc;
	float	bullets;
	float	d;
	float	spread;

	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.wav", 1, ATTN_NORM);
	bullets = cvar("g_balance_shotgun_bullets");
	d = cvar("g_balance_shotgun_damage");

	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 5);
	spread = cvar("g_balance_shotgun_spread");
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBullet2 (org, v_forward, spread, d, WEP_SHOTGUN, sc < 3, cvar("g_balance_shotgun_force"));
	self.currentammo = self.currentammo - 1;

	// casing code
	if (cvar("g_casings") >= 1)
	{
		org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 10);
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 1);
	}

	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 20);
	W_Smoke(org, v_forward, 12);
	//te_smallflash(org);

	self.punchangle_x = -5;
}

// weapon frames

void()	shotgun_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, shotgun_ready_01); self.weaponentity.state = WS_READY;};
void()	shotgun_select_01 =	{
	self.currentammo = cvar("g_balance_shotgun_clipsize");
	weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
}
void()	shotgun_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};

void()	shotgun_reload_02 =
{
	self.currentammo = self.currentammo + 1;
	shotgun_ready_01(); // return to ready state if not already there
}

void()	shotgun_reload_01 =
{
	if(self.currentammo >= cvar("g_balance_shotgun_clipsize"))
	{ // already full
		if(self.weaponentity.state != WS_READY)
			shotgun_ready_01(); // return to ready state if not already there
		return;
	}
	// if we somehow reached negative, fix that first
	if(self.currentammo < 0)
		self.currentammo = 0;

	sound (self, CHAN_WEAPON, "weapons/shotgun_reload.wav", 1, ATTN_NORM);

	// load a shell
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_shotgun_loadclip2"), shotgun_reload_02);
}

// after firing, call this funtion to check if the shotgun is empty
void()	shotgun_checkempty_01 =
{
	if(self.currentammo >= 1)
	{ // we don't need to force a reload
		shotgun_ready_01();
		return;
	}
	// load a shell
	shotgun_reload_01();
}

void()	shotgun_fire1_01 =
{
	weapon_doattack(shotgun_check, shotgun_check, W_Shotgun_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_refire"), shotgun_checkempty_01);
}
void()  shotgun_fire2_01 =
{
	shotgun_reload_01();
}