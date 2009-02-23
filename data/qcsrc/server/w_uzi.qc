// leilei's fancy muzzleflash stuff
void W_Uzi_Flash_Go() {
	if (self.frame > 10){
		SUB_Remove();
		return;
	}
	self.frame = self.frame + 2;
	self.alpha = self.alpha - 0.2;
	self.think = W_Uzi_Flash_Go;
	self.nextthink = time + 0.02;
};

.float uzi_bulletcounter;
void W_Uzi_Attack (float deathtype)
{
	local entity flash, flash2;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		if (self.uzi_bulletcounter == 1)
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_first_ammo");
		else
			self.ammo_nails = self.ammo_nails - cvar("g_balance_uzi_sustained_ammo");
	}
	W_SetupShot (self, '23 8 -9.5', TRUE, 0, "weapons/uzi_fire.wav");
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + cvar("g_balance_uzi_first_refire");

	if (self.uzi_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, cvar("g_balance_uzi_first_spread"), cvar("g_balance_uzi_speed"), 5, cvar("g_balance_uzi_first_damage"), 0, cvar("g_balance_uzi_first_force"), deathtype, 0, 1, cvar("g_balance_uzi_bulletconstant"));
	else
		fireBallisticBullet(w_shotorg, w_shotdir, cvar("g_balance_uzi_sustained_spread"), cvar("g_balance_uzi_speed"), 5, cvar("g_balance_uzi_sustained_damage"), 0, cvar("g_balance_uzi_sustained_force"), deathtype, 0, 1, cvar("g_balance_uzi_bulletconstant"));

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	// muzzle flash for 1st person view
	flash = spawn();
	setorigin(flash, '5 0 0');
	setmodel(flash, "models/uziflash.md3"); // precision set below
	setattachment(flash, self.weaponentity, "bone02");
	flash.owner = self;
	flash.viewmodelforclient = self;
	flash.customizeentityforclient = CL_Weaponentity_CustomizeEntityForClient;
	//SUB_SetFade(flash, time + 0.06, 0);
	flash.think = W_Uzi_Flash_Go;
	flash.nextthink = time + 0.02;
	flash.frame = 2;

	// muzzle flash for 3rd person view
	flash2 = spawn();
	setorigin(flash2, '43 1 8');
	setmodel(flash2, "models/uziflash.md3"); // precision set below
	setattachment(flash2, self.exteriorweaponentity, "");
	//SUB_SetFade(flash2, time + 0.06, 0);
	flash2.think = W_Uzi_Flash_Go;
	flash2.nextthink = time + 0.02;
	flash2.frame = 2;
	// common properties
	flash.angles_z = flash2.angles_z = flash.v_angle_z + random() * 180;
	flash.alpha = flash2.alpha = 1;
	flash.effects = flash2.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;

	// casing code
	if (cvar("g_casings") >= 2)
		SpawnCasing (w_shotorg - v_forward * 10, ((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3);
}

// weapon frames
void uzi_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	if (self.BUTTON_ATCK)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.uzi_bulletcounter = self.uzi_bulletcounter + 1;
		W_Uzi_Attack(WEP_UZI);
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), w_ready);
};

void spawnfunc_weapon_machinegun(); // defined in t_items.qc

float w_uzi(float req)
{
	if (req == WR_AIM)
		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_uzi_refire")))
		{
			self.uzi_bulletcounter = 1;
			W_Uzi_Attack(WEP_UZI);
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), uzi_fire1_02);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_uzi_refire")))
		{
			self.uzi_bulletcounter = 1;
			W_Uzi_Attack(WEP_UZI | HITTYPE_SECONDARY);
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_uzi_sustained_refire"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_uzi.md3");
		precache_model ("models/weapons/v_uzi.md3");
		precache_model ("models/weapons/w_uzi.zym");
		precache_sound ("weapons/uzi_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_UZI);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= cvar("g_balance_uzi_first_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= cvar("g_balance_uzi_first_ammo");
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "was sniped by";
		else
			w_deathtypestring = "was riddled full of holes by";
	}
	return TRUE;
};
