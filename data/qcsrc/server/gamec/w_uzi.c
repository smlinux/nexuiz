void() uzi_ready_01;
void() uzi_fire1_01;
void() uzi_deselect_01;
void() uzi_select_01;

float() uzi_check =
{
	if (self.ammo_nails >= cvar("g_balance_uzi_first_ammo"))
		return TRUE;
	return FALSE;
};

float() uzi_check2 =
{
	if (self.ammo_nails >= cvar("g_balance_uzi_sustained_ammo"))
		return TRUE;
	return FALSE;
};

void(float req) w_uzi =
{
	if (req == WR_IDLE)
		uzi_ready_01();
	else if (req == WR_AIM)
		self.button0 = bot_aim(1000000, 0, 0.001, FALSE);
	else if (req == WR_FIRE1 || req == WR_FIRE2)
		weapon_prepareattack(uzi_check, uzi_check, uzi_fire1_01, cvar("g_balance_uzi_refire"));
	else if (req == WR_RAISE)
		uzi_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_nails;
	else if (req == WR_DROP)
		uzi_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI, "w_uzi.zym", IT_NAILS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = uzi_check();
};

.float uzi_bulletcounter;
void W_Uzi_Attack (void)
{
	local vector org;

	local vector trueaim;
	trueaim = W_TrueAim();

	entity flash;
	sound (self, CHAN_WEAPON, "weapons/uzi_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	if (cvar("g_use_ammunition"))
	{
		if (self.uzi_bulletcounter == 1)
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_first_ammo");
		else
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_sustained_ammo");
	}
	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	org = W_MuzzleOrigin (self, '32 6 -8');

	// this attack_finished just enforces a cooldown at the end of a burst
	self.attack_finished = time + cvar("g_balance_uzi_first_refire");

	if (self.uzi_bulletcounter == 1)
		fireBullet (org, normalize(trueaim - org), cvar("g_balance_uzi_first_spread"), cvar("g_balance_uzi_first_damage"), IT_UZI, (self.uzi_bulletcounter & 3) == 0);
	else
		fireBullet (org, normalize(trueaim - org), cvar("g_balance_uzi_sustained_spread"), cvar("g_balance_uzi_sustained_damage"), IT_UZI, (self.uzi_bulletcounter & 3) == 0);

	flash = spawn ();
//	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 10) + (v_forward * 40);
	setorigin (flash, org);
	setmodel (flash, "models/uziflash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	flash.angles_z=flash.v_angle_z + random () * 180;
	flash.scale = 0.75;
	flash.alpha = 0.5;
	SUB_SetFade (flash, time, 0.2);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;

	// casing code
	if (cvar("g_casings") >= 2)
	{
		org = W_MuzzleOrigin (self, '15 6 -8');
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3);
	}
}
// weapon frames

void()	uzi_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, uzi_ready_01); self.weaponentity.state = WS_READY;};
void()	uzi_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	uzi_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	uzi_fire1_02 =
{
	if (self.button0 && self.weapon == self.switchweapon)
	{
		self.uzi_bulletcounter = self.uzi_bulletcounter + 1;
		weapon_doattack(uzi_check2, uzi_check2, W_Uzi_Attack);
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_ready_01);
};
void()	uzi_fire1_01 =
{
	self.uzi_bulletcounter = 1;
	weapon_doattack(uzi_check, uzi_check, W_Uzi_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
};

