void() shotgun_ready_01;
void() shotgun_fire1_01;
void() shotgun_fire2_01;
void() shotgun_fire3_01;
void() shotgun_deselect_01;
void() shotgun_select_01;

float() shotgun_check = 
{
	if (self.ammo_shells > 0)
		return TRUE;
	return FALSE;
};

void(float req) w_shotgun =
{
	if (req == WR_IDLE)
		shotgun_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire1_01, 0.7);
	else if (req == WR_FIRE2)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire2_01, 0.7);
	else if (req == WR_FIRE3)
		weapon_prepareattack(shotgun_check, shotgun_check, shotgun_fire3_01, 0.7);
	else if (req == WR_RAISE)
		shotgun_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_shells;
	else if (req == WR_DROP)
		shotgun_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN, "w_shotgun.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = shotgun_check();
};		 

void W_Shotgun_Attack (void)
{
	float	sc;
	float	bullets;

	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/shotgun_fire.wav", 1, ATTN_NORM);
	bullets = 10;

	for (sc = bullets; sc > 0; sc = sc - 1)
		fireBullet (v_forward, 150, 5, IT_SHOTGUN);
	self.ammo_shells = self.ammo_shells - 1;
	self.attack_finished = time + 0.7;

	vector	org; // casing code
	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 4) + (v_forward * 15);
	SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 1);
}

void W_Shotgun_Attack2 (void)
{
}

// weapon frames 

void()	shotgun_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, shotgun_ready_01); self.weaponentity.state = WS_READY;};
void()	shotgun_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	shotgun_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	shotgun_fire1_01 =	
{
	weapon_doattack(shotgun_check, shotgun_check, W_Shotgun_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, shotgun_ready_01);
};
void()	shotgun_fire2_01 =	
{
	weapon_doattack(shotgun_check, shotgun_check, W_Shotgun_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.5, shotgun_ready_01);
};
void()	shotgun_fire3_01 =	
{
	weapon_doattack(shotgun_check, shotgun_check, W_Shotgun_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.5, shotgun_ready_01);
};


