
void W_Nex_Attack (void)
{
	float flying;
	if not(g_minstagib || g_instagib)
		flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	W_SetupShot (self, '25 4 -4', TRUE, 5, "weapons/nexfire.wav");
	//W_SetupShot (self, '25 8 -8', TRUE, 2, "weapons/nexfire.wav"); // TODO: move model down a little

	// assure that nexdamage is high enough in minstagib
	if (g_minstagib || g_instagib)
		FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, 1000, 800, WEP_NEX);
	else
	{
		yoda = 0;
		FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, cvar("g_balance_nex_damage"), cvar("g_balance_nex_force"), WEP_NEX);

		if(yoda)
			if(flying)
				announce(self, "announcer/male/yoda.ogg");
	}

	pointparticles(particleeffectnum("nex_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	// beam effect
	trailparticles(world, particleeffectnum("nex_beam"), w_shotorg, trace_endpos);
	// flash and burn the wall
	if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		pointparticles(particleeffectnum("nex_impact"), trace_endpos - w_shotdir * 6, '0 0 0', 1);
	// play a sound
	soundat (self, trace_endpos, CHAN_PROJECTILE, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);

	if (cvar("g_use_ammunition") && !g_instagib)
	{
		if (g_minstagib)
			self.ammo_cells = self.ammo_cells - 1;
		else
			self.ammo_cells = self.ammo_cells - cvar("g_balance_nex_ammo");
	}
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
			announce(self, "announcer/robotic/terminated.ogg");
		}
		if (self.health == 10)
		{
			centerprint(self, "^11^7 second left to find some ammo\n");
			Damage(self, self, self, 5, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/1.ogg");
		}
		if (self.health == 20)
		{
			centerprint(self, "^12^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/2.ogg");
		}
		if (self.health == 30)
		{
			centerprint(self, "^13^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/3.ogg");
		}
		if (self.health == 40)
		{
			centerprint(self, "^14^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/4.ogg");
		}
		if (self.health == 50)
		{
			centerprint(self, "^15^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/5.ogg");
		}
		if (self.health == 60)
		{
			centerprint(self, "^36^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/6.ogg");
		}
		if (self.health == 70)
		{
			centerprint(self, "^37^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/7.ogg");
		}
		if (self.health == 80)
		{
			centerprint(self, "^38^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/8.ogg");
		}
		if (self.health == 90)
		{
			centerprint(self, "^39^7 seconds left to find some ammo\n");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/9.ogg");
		}
		if (self.health == 100)
		{
			centerprint(self, "get some ammo or\nyou'll be dead in ^310^7 seconds...");
			Damage(self, self, self, 10, DEATH_NOAMMO, self.origin, '0 0 0');
			announce(self, "announcer/robotic/10.ogg");
		}
	}
	self.minstagib_nextthink = time + 1;
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
			if(g_minstagib)
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
		else if (self.BUTTON_ATCK2)
		{
			if (g_minstagib)
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
		if(g_minstagib)
			w_laser(WR_PRECACHE);
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_NEX);
	else if (req == WR_CHECKAMMO1)
	{
		if (g_minstagib)
			return self.ammo_cells >= 1;
		else
			return self.ammo_cells >= cvar("g_balance_nex_ammo");
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "has been vaporized by";
	else if (req == WR_SPAWNFUNC)
		spawnfunc_weapon_nex();
	return TRUE;
};
