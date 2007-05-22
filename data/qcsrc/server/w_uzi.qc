.float uzi_bulletcounter;
void W_Uzi_Attack (void)
{
	local entity flash, flash2;

	if (cvar("g_use_ammunition"))
	{
		if (self.uzi_bulletcounter == 1)
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_first_ammo");
		else
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_sustained_ammo");
	}
	W_SetupShot (self, '11 5.5 -8', TRUE, 0, "weapons/uzi_fire.wav");
	if (!cvar("g_norecoil"))
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	self.attack_finished = time + cvar("g_balance_uzi_first_refire");

	if (self.uzi_bulletcounter == 1)
		fireBullet (w_shotorg, w_shotdir, cvar("g_balance_uzi_first_spread"), cvar("g_balance_uzi_first_damage"), cvar("g_balance_uzi_first_force"), IT_UZI, TRUE);
	else
		fireBullet (w_shotorg, w_shotdir, cvar("g_balance_uzi_sustained_spread"), cvar("g_balance_uzi_sustained_damage"), cvar("g_balance_uzi_sustained_force"), IT_UZI, (self.uzi_bulletcounter & 3) == 0);

	// muzzle flash for 1st person view
	flash = spawn();
	setorigin(flash, '53 5 0');
	setmodel(flash, "models/uziflash.md3"); // precision set below
	setattachment(flash, self.weaponentity, "bone01");
	flash.owner = self;
	flash.viewmodelforclient = self;
	flash.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	flash.scale = 1.2;
	SUB_SetFade(flash, time, 0.2);

	// muzzle flash for 3rd person view
	flash2 = spawn();
	setorigin(flash2, '43 1 8');
	setmodel(flash2, "models/uziflash.md3"); // precision set below
	setattachment(flash2, self.exteriorweaponentity, "");
	SUB_SetFade(flash2, time, 0.2);

	// common properties
	flash.angles_z = flash2.angles_z = flash.v_angle_z + random() * 180;
	flash.alpha = flash2.alpha = 0.5;
	flash.effects = flash2.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;

	// casing code
	if (cvar("g_casings") >= 2)
		SpawnCasing (w_shotorg + v_forward * 10, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3);
}

// weapon frames
void()	uzi_fire1_02 =
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	if (self.button0)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		{
			self.switchweapon = w_getbestweapon(self);
			if (self.switchweapon != self.weapon)
				self.cnt = self.weapon;
			w_ready();
			return;
		}
		self.attack_finished = time + cvar("g_balance_uzi_refire");
		self.uzi_bulletcounter = self.uzi_bulletcounter + 1;
		W_Uzi_Attack();
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), w_ready);
};

float(float req) w_uzi =
{
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin)<750)
			self.button0 = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.button3 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_uzi_refire")))
		{
			self.uzi_bulletcounter = 1;
			W_Uzi_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
		}
		if (self.button3)
		if (weapon_prepareattack(1, cvar("g_balance_uzi_refire")))
		{
			self.uzi_bulletcounter = 1;
			W_Uzi_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/tracer.mdl");
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_uzi.md3");
		precache_model ("models/weapons/v_uzi.md3");
		precache_model ("models/weapons/w_uzi.zym");
		precache_sound ("weapons/ric1.wav");
		precache_sound ("weapons/ric2.wav");
		precache_sound ("weapons/ric3.wav");
		precache_sound ("weapons/tink1.wav");
		precache_sound ("weapons/uzi_fire.wav");
		if (cvar("g_casings") >= 2)
			precache_model ("models/casing_bronze.mdl");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI, "uzi", IT_NAILS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= cvar("g_balance_uzi_first_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= cvar("g_balance_uzi_sustained_ammo");
	return TRUE;
};
