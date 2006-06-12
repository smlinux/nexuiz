
.float uzi_bulletcounter;
void W_Uzi_Attack (void)
{
	local entity flash;

	if (cvar("g_use_ammunition"))
	{
		if (self.uzi_bulletcounter == 1)
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_first_ammo");
		else
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_sustained_ammo");
	}
	W_SetupShot (self, '15 8 -8', TRUE, 0, "weapons/uzi_fire.ogg");
	if (!cvar("g_norecoil"))
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	self.attack_finished = time + cvar("g_balance_uzi_first_refire");

	if (self.uzi_bulletcounter == 1)
		fireBullet (w_shotorg, w_shotdir, cvar("g_balance_uzi_first_spread"), cvar("g_balance_uzi_first_damage"), IT_UZI, (self.uzi_bulletcounter & 3) == 0);
	else
		fireBullet (w_shotorg, w_shotdir, cvar("g_balance_uzi_sustained_spread"), cvar("g_balance_uzi_sustained_damage"), IT_UZI, (self.uzi_bulletcounter & 3) == 0);

	flash = spawn ();
	setorigin (flash, w_shotorg + v_forward * 17);
	setmodel (flash, "models/uziflash.md3");
	flash.angles = vectoangles (w_shotdir);
	flash.angles_z=flash.v_angle_z + random () * 180;
	flash.scale = 0.75;
	flash.alpha = 0.5;
	SUB_SetFade (flash, time, 0.2);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;

	// casing code
	if (cvar("g_casings") >= 2)
		SpawnCasing (w_shotorg + v_forward * 10, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3);
}

// weapon frames
void()	uzi_fire1_02 =
{
	if (self.button0 && self.weapon == self.switchweapon)
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
		self.button0 = bot_aim(1000000, 0, 0.001, FALSE);
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
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI, "uzi", IT_NAILS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= cvar("g_balance_uzi_first_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= cvar("g_balance_uzi_sustained_ammo");
	return TRUE;
};
