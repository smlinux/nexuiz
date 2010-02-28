#ifdef REGISTER_WEAPON
REGISTER_WEAPON(NEX, w_nex, IT_CELLS, 7, WEP_FLAG_NORMAL | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "nex", "nex", "Nex");
#else
void SendCSQCNexBeamParticle() {
	vector v;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
	
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, v_x);
	WriteCoord(MSG_BROADCAST, v_y);
	WriteCoord(MSG_BROADCAST, v_z);
}

void W_Nex_Attack (void)
{
	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	W_SetupShot (self, TRUE, 5, "weapons/nexfire.wav", cvar("g_balance_nex_damage"));

	yoda = 0;
	FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, cvar("g_balance_nex_damage"), cvar("g_balance_nex_force"), cvar("g_balance_nex_damagefalloff_mindist"), cvar("g_balance_nex_damagefalloff_maxdist"), cvar("g_balance_nex_damagefalloff_halflife"), cvar("g_balance_nex_damagefalloff_forcehalflife"), WEP_NEX);

	if(yoda && flying)
		AnnounceTo(self, "yoda");

	//beam and muzzle flash done on client
	SendCSQCNexBeamParticle();
	
	// flash and burn the wall
	if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		Damage_DamageInfo(trace_endpos, cvar("g_balance_nex_damage"), 0, 0, cvar("g_balance_nex_force") * w_shotdir, WEP_NEX, self);

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_cells = self.ammo_cells - cvar("g_balance_nex_ammo");
}

void spawnfunc_weapon_nex (void); // defined in t_items.qc

float w_nex(float req)
{
	if (req == WR_AIM)
		self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		{
			if (weapon_prepareattack(0, cvar("g_balance_nex_refire")))
			{
				W_Nex_Attack();
				weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_nex_animtime"), w_ready);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/nexflash.md3");
		precache_model ("models/weapons/g_nex.md3");
		precache_model ("models/weapons/v_nex.md3");
		precache_model ("models/weapons/h_nex.dpm");
		precache_sound ("weapons/nexfire.wav");
		precache_sound ("weapons/nexwhoosh1.wav");
		precache_sound ("weapons/nexwhoosh2.wav");
		precache_sound ("weapons/nexwhoosh3.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_NEX);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_nex_ammo");
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "has been vaporized by";
	return TRUE;
};
#endif
