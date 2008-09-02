.float porto_grenade_id;

void W_Porto_Explode (void)
{
	remove(self);
}

void W_Porto_Touch1 (void)
{
	print(vtos(trace_plane_normal), "\n");
	if(self.porto_grenade_id == 0)
	{
		self.porto_grenade_id = time;
		if(!Portal_SpawnInPortalAtTrace(self.owner, self.velocity, self.porto_grenade_id))
			remove(self);
	}
	else
	{
		Portal_SpawnOutPortalAtTrace(self.owner, self.velocity, self.porto_grenade_id);
		remove(self);
	}
}

void W_Porto_Attack (void)
{
	local entity gren;

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_porto_primary_ammo");
	W_SetupShot (self, '0 0 0', FALSE, 4, "weapons/grenade_fire.wav");

	//pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = self;
	gren.classname = "porto";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = 200;
	gren.movetype = MOVETYPE_BOUNCEMISSILE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_LOWPRECISION;
	gren.modelflags = MF_GRENADE;
	setmodel(gren, "models/grenademodel.md3"); // precision set above
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_porto_primary_lifetime");
	gren.think = W_Porto_Explode;
	gren.touch = W_Porto_Touch1;
	gren.velocity = w_shotdir * cvar("g_balance_porto_primary_speed");
	W_SetupProjectileVelocity(gren);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
}

void W_Porto_Attack2 (void)
{
	// nothing yet (maybe find the last one and detonate it?)
}

void spawnfunc_weapon_porto (void)
{
	weapon_defaultspawnfunc(WEP_PORTO, 5000);
}

float w_porto(float req)
{
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if(bot_aim(cvar("g_balance_porto_primary_speed"), 0, cvar("g_balance_grenadelauncher_primary_lifetime"), FALSE))
			self.BUTTON_ATCK = TRUE;
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_porto_primary_refire")))
		{
			W_Porto_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_porto_primary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/grenademodel.md3");
		precache_model ("models/weapons/g_porto.md3");
		precache_model ("models/weapons/v_porto.md3");
		precache_model ("models/weapons/w_porto.zym");
		precache_sound ("weapons/grenade_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_PORTO);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_porto_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "felt # doing the impossible";
	else if (req == WR_SPAWNFUNC)
		spawnfunc_weapon_porto();
	return TRUE;
};
