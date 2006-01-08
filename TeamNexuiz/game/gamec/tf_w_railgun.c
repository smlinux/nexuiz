void() railgun_ready_01;
void() railgun_fire1_01;
void() railgun_deselect_01;
void() railgun_select_01;

float() railgun_check =
{
	if (self.ammo_shells >= 5)
		return TRUE;
	return FALSE;
};

void(float req) w_railgun =
{
	if (req == WR_IDLE)
		railgun_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(railgun_check, railgun_check, railgun_fire1_01, .5/*cvar("g_balance_nex_refire")*/);
	else if (req == WR_RAISE)
		railgun_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = floor(self.ammo_shells/* / 5*/);
	else if (req == WR_DROP)
		railgun_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_RAILGUN, "w_railgun.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = railgun_check();
};


void W_RailGun_Attack (void)
{
	local vector org;
	local vector end;
	local entity flash;

	sound (self, CHAN_WEAPON, "weapons/RailGunfire.wav", 1, ATTN_NORM);
	self.punchangle_x = -5;
	org = self.origin + self.view_ofs + v_forward * 5 + v_right * 14 + v_up * -7;
	end = self.origin + self.view_ofs + v_forward * 4096;

//	FireRailgunBullet (org, end, cvar("g_balance_railgun_damage"), WEP_RAILGUN);
	FireRailgunBullet (org, end, 35, WEP_RAILGUN);		//temp -- i want to add area damage

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
	PointSound (trace_endpos, "weapons/RailGunimpact.wav", 1, ATTN_NORM);

	if (cvar("g_instagib") == 0)
//		self.ammo_cells = self.ammo_cells - 5;
		self.ammo_shells = self.ammo_shells - 5;

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
void()	railgun_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, railgun_ready_01); self.weaponentity.state = WS_READY;};
void()	railgun_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	railgun_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	railgun_fire1_01 =
{
	weapon_doattack(railgun_check, railgun_check, W_RailGun_Attack);
//	weapon_thinkf(WFRAME_FIRE1, 0.3, railgun_ready_01);
	weapon_thinkf(WFRAME_FIRE1, 0.9, railgun_ready_01);
};
