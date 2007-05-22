
void W_Nex_Attack (void)
{
	//w_shotorg = self.origin + self.view_ofs + v_forward * 5 + v_right * 14 + v_up * -7;
	W_SetupShot (self, '5 14 -8', TRUE, 5, "weapons/nexfire.wav");

	// assure that nexdamage is high enough in minstagib
	if (cvar("g_minstagib"))
		FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, 1000, 800, IT_NEX);
	else
		FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, cvar("g_balance_nex_damage"), cvar("g_balance_nex_force"), IT_NEX);

	// show as if shot started outside of gun
	// muzzleflash light
	//te_smallflash (w_shotorg + w_shotdir * 24);
	// beam effect
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 76);
	WriteCoord (MSG_BROADCAST, w_shotorg_x + w_shotdir_x * 18);
	WriteCoord (MSG_BROADCAST, w_shotorg_y + w_shotdir_y * 18);
	WriteCoord (MSG_BROADCAST, w_shotorg_z + w_shotdir_z * 18);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	// flash and burn the wall
	if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		te_plasmaburn (trace_endpos - w_shotdir * 6);
	// play a sound
	PointSound (trace_endpos, "weapons/neximpact.wav", 1, ATTN_NORM);

	if (cvar("g_use_ammunition") && !cvar("g_instagib"))
	{
		if (cvar("g_minstagib"))
			self.ammo_cells = self.ammo_cells - 1;
		else
			self.ammo_cells = self.ammo_cells - cvar("g_balance_nex_ammo");
	}

	/*
	local entity flash;
	flash = spawn ();
	setorigin (flash, self.origin + self.view_ofs + v_forward * 33 + v_right * 14 + v_up * -7);
	flash.angles = vectoangles (w_shotdir);
	//setattachment(flash, self.weaponentity, "bone01");
	//flash.origin = '150 0 0';
	//setattachment(flash, self.weaponentity, "");
	//flash.origin = '150 -16 -8';
	//flash.angles_z = 90;
	//flash.scale = 4;
	setmodel (flash, "models/nexflash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	*/
}


.float minstagib_nextthink;
void minstagib_ammocheck (void)
{
	if (time < self.minstagib_nextthink || self.deadflag || gameover)
		return;

	if (self.ammo_cells <= 0)
	{
		if (self.health == 5)
		{
			centerprint(self, "you're dead now...\n");
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/terminated.ogg");
		}
		if (self.health == 10)
		{
			centerprint(self, "^11^7 second left to find some ammo\n");
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/1.ogg");
		}
		if (self.health == 20)
		{
			centerprint(self, "^12^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/2.ogg");
		}
		if (self.health == 30)
		{
			centerprint(self, "^13^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/3.ogg");
		}
		if (self.health == 40)
		{
			centerprint(self, "^14^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/4.ogg");
		}
		if (self.health == 50)
		{
			centerprint(self, "^15^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/5.ogg");
		}
		if (self.health == 60)
		{
			centerprint(self, "^36^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/6.ogg");
		}
		if (self.health == 70)
		{
			centerprint(self, "^37^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/7.ogg");
		}
		if (self.health == 80)
		{
			centerprint(self, "^38^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/8.ogg");
		}
		if (self.health == 90)
		{
			centerprint(self, "^39^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/9.ogg");
		}
		if (self.health == 100)
		{
			centerprint(self, "get some ammo or\nyou'll be dead in ^310^7 seconds...");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			play2(self, "announcer/robotic/10.ogg");
		}
	}
	self.minstagib_nextthink = time + 1;
}

float(float req) w_nex =
{
	if (req == WR_AIM)
		self.button0 = bot_aim(1000000, 0, 1, FALSE);
	else if (req == WR_THINK)
	{
		if (self.button0)
		{
			if(cvar("g_minstagib"))
			{
				if (weapon_prepareattack(0, cvar("g_balance_minstagib_nex_refire")))
				{
					W_Nex_Attack();
					weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_minstagib_nex_animtime"), w_ready);
				}
			}
			else
			{
				if (weapon_prepareattack(0, cvar("g_balance_nex_refire")))
				{
					W_Nex_Attack();
					weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_nex_animtime"), w_ready);
				}
			}
		}
		else if (self.button3)
		{
			if (cvar("g_minstagib"))
			{
				if (self.jump_interval <= time)
				{
					self.jump_interval = time + 0.9;
					W_Laser_Attack(FALSE);
				}
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/nexflash.md3");
		precache_model ("models/weapons/g_nex.md3");
		precache_model ("models/weapons/v_nex.md3");
		precache_model ("models/weapons/w_nex.zym");
		precache_sound ("weapons/nexfire.wav");
		precache_sound ("weapons/neximpact.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_NEX, "nex", IT_CELLS);
	else if (req == WR_CHECKAMMO1)
	{
		if (cvar("g_minstagib"))
			return self.ammo_cells >= 1;
		else
			return self.ammo_cells >= cvar("g_balance_nex_ammo");
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	return TRUE;
};
