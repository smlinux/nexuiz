void() nex_ready_01;
void() nex_fire1_01;
void() nex_deselect_01;
void() nex_select_01;

float() nex_check =
{
	if (self.ammo_cells >= 5)
		return TRUE;
	return FALSE;
};

void(float req) w_nex =
{
	if (req == WR_IDLE)
		nex_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(nex_check, nex_check, nex_fire1_01, cvar("g_balance_nex_refire"));
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
	local vector org;
	local vector end;
	local entity flash;

	sound (self, CHAN_WEAPON, "weapons/nexfire.wav", 1, ATTN_NORM);
	self.punchangle_x = -5;
	org = self.origin + self.view_ofs + v_forward * 5 + v_right * 14 + v_up * -7;
	end = self.origin + self.view_ofs + v_forward * 4096;

	FireRailgunBullet (org, end, cvar("g_balance_nex_damage"), IT_NEX);

	// trace as if shot started inside gun
	traceline (org, end, TRUE, self);
	// show as if shot started outside of gun
	org = self.origin + self.view_ofs + v_forward * 28 + v_right * 14 + v_up * -7;
	// muzzleflash light
	te_smallflash (org);
	// beam effect
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 76);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	// flash and burn the wall
	te_plasmaburn (trace_endpos);
	/*
	// flame effect at impact
	dir = trace_plane_normal * 100;
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_FLAMEJET);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, dir_x);
	WriteCoord (MSG_BROADCAST, dir_y);
	WriteCoord (MSG_BROADCAST, dir_z);
	WriteByte (MSG_BROADCAST, 255);
	*/
	// play a sound
	PointSound (trace_endpos, "weapons/neximpact.wav", 1, ATTN_NORM);

	if (cvar("g_instagib") == 0)
		self.ammo_cells = self.ammo_cells - 5;

	flash = spawn ();
	org = self.origin + self.view_ofs + v_forward * 33 + v_right * 14 + v_up * -7;
	setorigin (flash, org);
	setmodel (flash, "models/nexflash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT;
}

// weapon frames
void()	nex_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, nex_ready_01); self.weaponentity.state = WS_READY;};
void()	nex_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	nex_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	nex_fire1_01 =
{
	weapon_doattack(nex_check, nex_check, W_Nex_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, nex_ready_01);
};

