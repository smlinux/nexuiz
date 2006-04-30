void() nex_ready_01;
void() nex_fire1_01;
void() nex_deselect_01;
void() nex_select_01;
void() nex_selfkill;

float() nex_check =
{
	if (cvar("g_minstagib"))
	{
		if (self.ammo_cells >= 1)
			return TRUE;
	} else {
		if (self.ammo_cells >= cvar("g_balance_nex_ammo"))
			return TRUE;
	}
	return FALSE;
};

void nex_selfkill (void)
{
	if (!cvar("g_minstagib") || gameover)
		return;

	if (self.ammo_cells <= 0)
	{
		if (self.health == 5)
		{
			centerprint(self, "you're dead now...\n");
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/terminated.ogg\n");
		}
		if (self.health == 10)
		{
			centerprint(self, "^11^7 second left to find some ammo\n");
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/1.ogg\n");
		}
		if (self.health == 20)
		{
			centerprint(self, "^12^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/2.ogg\n");
		}
		if (self.health == 30)
		{
			centerprint(self, "^13^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/3.ogg\n");
		}
		if (self.health == 40)
		{
			centerprint(self, "^14^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/4.ogg\n");
		}
		if (self.health == 50)
		{
			centerprint(self, "^15^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/5.ogg\n");
		}
		if (self.health == 60)
		{
			centerprint(self, "^36^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/6.ogg\n");
		}
		if (self.health == 70)
		{
			centerprint(self, "^37^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/7.ogg\n");
		}
		if (self.health == 80)
		{
			centerprint(self, "^38^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/8.ogg\n");
		}
		if (self.health == 90)
		{
			centerprint(self, "^39^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/9.ogg\n");
		}
		if (self.health == 100)
		{
			weapon_prepareattack(nex_check, nex_check, nex_fire1_01, 1.0);
			centerprint(self, "get some ammo or\nyou'll be dead in ^310^7 seconds...");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			stuffcmd(self, "play2 announcer/robotic/10.ogg\n");
		}

	}
	self.think = nex_selfkill;
	self.nextthink = time + 1;

}

void(float req) w_nex =
{
	if (req == WR_IDLE)
		nex_ready_01();
	else if (req == WR_AIM)
		self.button0 = bot_aim(1000000, 0, 1, FALSE);
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
	local vector org, org2;
	local entity flash;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/nexfire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH && !cvar("g_minstagib"))
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	self.punchangle_x = -5;

	org = self.origin + self.view_ofs + v_forward * 5 + v_right * 14 + v_up * -7;
	traceline_hitcorpse(self, org, trueaim + normalize(trueaim - org) * 8192, TRUE, self);
	trueaim = trace_endpos;

	// assure that nexdamage is high enough in minstagib
	if (cvar("g_minstagib"))
		FireRailgunBullet (org, trueaim, 1000, IT_NEX);
	else
		FireRailgunBullet (org, trueaim, cvar("g_balance_nex_damage"), IT_NEX);

	// trace as if shot started inside gun
	traceline_hitcorpse (self,org, trueaim, TRUE, self);
	// show as if shot started outside of gun
	org = self.origin + self.view_ofs + v_forward * 35 + v_right * 14 + v_up * -8;
	org2 = self.origin + self.view_ofs + v_forward * 52 + v_right * 14 + v_up * -8;
	// muzzleflash light
	te_smallflash (org2);
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
	te_plasmaburn (findbetterlocation (trace_endpos, 6));
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
	PointSound (trace_endpos, "weapons/neximpact.ogg", 1, ATTN_NORM);

	if (cvar("g_use_ammunition") && !cvar("g_instagib"))
	{
		if (cvar("g_minstagib"))
			self.ammo_cells = self.ammo_cells - 1;
		else
			self.ammo_cells = self.ammo_cells - cvar("g_balance_nex_ammo");
	}

	flash = spawn ();
	org = self.origin + self.view_ofs + v_forward * 33 + v_right * 14 + v_up * -7;
	setorigin (flash, org);
	setmodel (flash, "models/nexflash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
}

// weapon frames
void()	nex_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, nex_ready_01); self.weaponentity.state = WS_READY;};
void()	nex_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0'); nex_selfkill();};
void()	nex_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	nex_fire1_01 =
{
	weapon_doattack(nex_check, nex_check, W_Nex_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_nex_animtime"), nex_ready_01);
};

