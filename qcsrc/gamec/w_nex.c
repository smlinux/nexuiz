void() nex_ready_01;
void() nex_fire1_01;
void() nex_fire2_01;
void() nex_deselect_01;
void() nex_select_01;

float() nex_check = 
{
	if (self.ammo_cells > 0) 
		return TRUE; 
	return FALSE;
};

void(float req) w_nex =
{
	if (req == WR_IDLE)
		nex_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(nex_check, nex_check, nex_fire1_01, 1);
	else if (req == WR_FIRE2)
		weapon_prepareattack(nex_check, nex_check, nex_fire2_01, 1);
	else if (req == WR_RAISE)
		nex_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_cells;
	else if (req == WR_DROP)
		nex_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_NEX, "w_nex.zym", IT_CELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = nex_check();
};		 


void W_Nex_Attack (void)
{
	vector	org;
	vector	dir;
	entity 	explosion;

	sound (self, CHAN_WEAPON, "weapons/nexfire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	makevectors(self.v_angle);
	org = self.origin + self.view_ofs + v_forward * 18 + v_right * 8 + v_up * -5;
	te_smallflash(org);

	FireRailgunBullet (org, self.origin + self.view_ofs + v_forward * 4096, 800, IT_NEX);

	self.attack_finished = time + 1;

	if (!(game & GAME_INSTAGIB))
		self.ammo_cells = self.ammo_cells - 1;
}

void W_Nex_Attack2 (void)
{
	makevectors(self.v_angle);
}

// weapon frames 
void()	nex_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, nex_ready_01); self.weaponentity.state = WS_READY;};
void()	nex_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	nex_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	nex_fire1_01 =	
{
	weapon_doattack(nex_check, nex_check, W_Nex_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, nex_ready_01);
};
void()	nex_fire2_01 =	
{
	weapon_doattack(nex_check, nex_check, W_Nex_Attack);
	weapon_thinkf(WFRAME_FIRE2, 0.5, nex_ready_01);
};

