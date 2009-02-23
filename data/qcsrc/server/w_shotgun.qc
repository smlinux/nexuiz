
void W_Shotgun_Attack (void)
{
	float	sc;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	local entity flash;

	bullets = cvar("g_balance_shotgun_primary_bullets");
	d = cvar("g_balance_shotgun_primary_damage");
	f = cvar("g_balance_shotgun_primary_force");
	spread = cvar("g_balance_shotgun_primary_spread");
	bulletspeed = cvar("g_balance_shotgun_primary_speed");
	bulletconstant = cvar("g_balance_shotgun_primary_bulletconstant");

	W_SetupShot (self, '28 8 -10', TRUE, 5, "weapons/shotgun_fire.wav");
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN, 0, 1, bulletconstant);
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_primary_ammo");

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, cvar("g_balance_shotgun_primary_ammo"));

	// casing code
	if (cvar("g_casings") >= 1)
		SpawnCasing (w_shotorg - v_forward * 10, ((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1);

	// muzzle flash for 1st person view
	flash = spawn();
	setorigin(flash, '5 0 0');
	setmodel(flash, "models/uziflash.md3"); // precision set below
	setattachment(flash, self.weaponentity, "bone02");
	flash.owner = self;
	flash.viewmodelforclient = self;
	flash.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.angles_z = flash.v_angle_z + random() * 180;
	flash.alpha = 1;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;

}

void W_Shotgun_Attack2 (void)
{
	float	sc;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	local entity flash;

	bullets = cvar("g_balance_shotgun_secondary_bullets");
	d = cvar("g_balance_shotgun_secondary_damage");
	f = cvar("g_balance_shotgun_secondary_force");
	spread = cvar("g_balance_shotgun_secondary_spread");
	bulletspeed = cvar("g_balance_shotgun_secondary_speed");
	bulletconstant = cvar("g_balance_shotgun_secondary_bulletconstant");

	W_SetupShot (self, '25 8 -8', TRUE, 5, "weapons/shotgun_fire.wav");
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN | HITTYPE_SECONDARY, 0, 1, bulletconstant);
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_shells = self.ammo_shells - cvar("g_balance_shotgun_secondary_ammo");

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, cvar("g_balance_shotgun_secondary_ammo"));

	// casing code
	if (cvar("g_casings") >= 1)
		SpawnCasing (w_shotorg - v_forward * 10, ((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1);

	flash = spawn();
	setorigin(flash, '53 5 0');
	setmodel(flash, "models/uziflash.md3"); // precision set below
	setattachment(flash, self.weaponentity, "bone01");
	flash.owner = self;
	flash.viewmodelforclient = self;
	flash.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	flash.scale = 1.2;
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.angles_z = flash.v_angle_z + random() * 180;
	flash.alpha = 1;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
}

// weapon frames
void shotgun_fire2_03()
{
	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_shotgun_secondary_animtime"), w_ready);
}
void shotgun_fire2_02()
{
	W_Shotgun_Attack2();
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_03);
}

void spawnfunc_weapon_shotgun(); // defined in t_items.qc

float w_shotgun(float req)
{
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin)>200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_shotgun_primary_refire")))
		{
			W_Shotgun_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_shotgun_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_shotgun_secondary_refire")))
		{
			W_Shotgun_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_shotgun_secondary_animtime"), shotgun_fire2_02);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_shotgun.md3");
		precache_model ("models/weapons/v_shotgun.md3");
		precache_model ("models/weapons/w_shotgun.zym");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_SHOTGUN);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_shells >= cvar("g_balance_shotgun_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_shells >= cvar("g_balance_shotgun_secondary_ammo") * 3;
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
	{
		w_deathtypestring = "was gunned by"; // unchecked: SECONDARY
	}
	return TRUE;
};
