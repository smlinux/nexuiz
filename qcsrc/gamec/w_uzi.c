void() uzi_ready_01;
void() uzi_fire1_01;
void() uzi_fire2_01;
void() uzi_deselect_01;
void() uzi_select_01;

float() uzi_check = 
{
	if (self.ammo_nails > 0)
		return TRUE;
	return FALSE;
};

void(float req) w_uzi =
{
	if (req == WR_IDLE)
		uzi_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(uzi_check, uzi_check, uzi_fire1_01, 0.075);
	else if (req == WR_FIRE2)
		weapon_prepareattack(uzi_check, uzi_check, uzi_fire2_01, 0.4);
	else if (req == WR_RAISE)
		uzi_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_nails;
	else if (req == WR_DROP)
		uzi_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI, "w_uzi.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = uzi_check();
};		 

void W_Uzi_Attack (void)
{
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", 1, ATTN_NORM);

	fireBullet (self.origin + self.view_ofs, v_forward, 0.025, 4, IT_UZI);

	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	self.punchangle_z = random () - 0.5;

	self.attack_finished = time + 0.075;
	self.ammo_nails = self.ammo_nails - 1;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 1) + (v_forward * 15);
	SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 2);
	//W_Smoke(org, v_forward, 12);
}

void W_Uzi_Attack2 (void)
{
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", 1, ATTN_NORM);

	fireBullet (self.origin + self.view_ofs, v_forward, 1, 4, IT_UZI);

	self.attack_finished = time + 0.16;
	self.ammo_nails = self.ammo_nails - 1;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 1) + (v_forward * 20);
	SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 2);
}
// weapon frames 

void()	uzi_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, uzi_ready_01); self.weaponentity.state = WS_READY;};
void()	uzi_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	uzi_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	uzi_fire1_01 =	
{
	weapon_doattack(uzi_check, uzi_check, W_Uzi_Attack);
	if (self.button0)
		weapon_thinkf(WFRAME_FIRE1, 0.075, uzi_fire1_01);
	else
		weapon_thinkf(WFRAME_FIRE1, 0.075, uzi_ready_01);
};
void()	uzi_fire2_01 =	
{
	weapon_doattack(uzi_check, uzi_check, W_Uzi_Attack2);
	if (self.button0)
		weapon_thinkf(WFRAME_FIRE2, 0.16, uzi_fire2_01);
	else
		weapon_thinkf(WFRAME_FIRE2, 0.1, uzi_ready_01);
};
