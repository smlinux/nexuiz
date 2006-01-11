void() mac_ready_01;
void() mac_fire1_01;
void() mac_deselect_01;
void() mac_select_01;
void() mac_fire2_01;

float() mac_check =
{
	if (self.ammo_nails >= 1)
		return TRUE;
	return FALSE;
};

void(float req) w_mac =
{
	if (req == WR_IDLE)
		mac_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(mac_check, mac_check, mac_fire1_01, cvar("g_balance_mac_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(mac_check, mac_check, mac_fire2_01, cvar("g_balance_mac_refire2"));
	else if (req == WR_RAISE)
		mac_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_nails;
	else if (req == WR_DROP)
		mac_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_MAC, "w_mac.zym", IT_NAILS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = mac_check();
};

.float mac_bulletcounter;
void W_Mac_Attack (void)
{
	local vector org;
	entity flash;
	sound (self, CHAN_WEAPON, "weapons/mac_fire.wav", 1, ATTN_NORM);
	self.ammo_nails = self.ammo_nails - 1;
	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 15);

	// this attack_finished just enforces a cooldown at the end of a burst
	self.attack_finished = time + cvar("g_balance_mac_refire2");

	if (self.mac_bulletcounter == 1)
		fireBullet (org, v_forward, cvar("g_balance_mac_spread2"), cvar("g_balance_mac_damage2"), WEP_MAC, (self.mac_bulletcounter & 3) == 0);
	else
		fireBullet (org, v_forward, cvar("g_balance_mac_spread"), cvar("g_balance_mac_damage"), WEP_MAC, (self.mac_bulletcounter & 3) == 0);

	// casing code
	if (cvar("g_casings") >= 2)
	{
		org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 10);
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 2);
	}

	flash = spawn ();
	org = self.origin + self.view_ofs + (v_right * 12) - (v_up * 9) + (v_forward * 40);
	setorigin (flash, org);
	setmodel (flash, "models/uziflash.md3");	//temp use mac flash
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	flash.angles_z=flash.v_angle_z + random () * 180; 
	flash.scale = 0.75;
	flash.alpha = 0.5;
	SUB_SetFade (flash, time, 0.2);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT;
}

// weapon frames
void()	mac_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, mac_ready_01); self.weaponentity.state = WS_READY;};
void()	mac_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	mac_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	mac_fire1_01 =
{
	if (self.button0)
	{
		self.mac_bulletcounter = self.mac_bulletcounter + 1;
		weapon_doattack(mac_check, mac_check, W_Mac_Attack);
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_mac_refire"), mac_fire1_01);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_mac_refire"), mac_ready_01);
};

void()	mac_fire2_03 =
{
	self.mac_bulletcounter = 1;
	weapon_doattack(mac_check, mac_check, W_Mac_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_mac_refire"), mac_fire1_01);
};

void()	mac_fire2_02 =
{
	self.mac_bulletcounter = 1;
	weapon_doattack(mac_check, mac_check, W_Mac_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_mac_refire"), mac_fire2_03);
};

void()	mac_fire2_01 =
{
	self.mac_bulletcounter = 1;
	weapon_doattack(mac_check, mac_check, W_Mac_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_mac_refire"), mac_fire2_02);
};