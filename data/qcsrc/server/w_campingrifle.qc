//Camping rifle Primary mode: manually operated bolt*, Secondary: full automatic** --MikeeUSA--
//* Manually operating the bolt means that all the power of the gas is used to propell the bullet. In this mode the bolt is prevented from moving backwards in response to the firing of the bullet.
//** In fully automatic mode some of the gas is used to extract and reload the next cartrige, thus there is less power and range.

.float campingrifle_bulletcounter;

void W_Campingrifle_Reload()
{
	if (self.campingrifle_bulletcounter <= 0)
		return;
	
	sound (self, CHAN_WEAPON2, "weapons/campingrifle_reload.wav", VOL_BASE, ATTN_NORM);
	ATTACK_FINISHED(self) = time + cvar("g_balance_campingrifle_reloadtime");
	self.campingrifle_bulletcounter = 0;
}

void W_Campingrifle_CheckReload()
{
	if (self.campingrifle_bulletcounter >= cvar("g_balance_campingrifle_magazinecapacity"))
		W_Campingrifle_Reload();
}

void W_CampingRifle_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype)
{
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_nails -= pAmmo;

	W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/campingrifle_fire.wav");
	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);

	fireBallisticBullet(w_shotorg, v_forward /* no TrueAim for this weapon */, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, EF_RED, 1);
	
	self.campingrifle_bulletcounter = self.campingrifle_bulletcounter + 1;
	W_Campingrifle_CheckReload();
}

void W_Campingrifle_Attack()
{
	W_CampingRifle_FireBullet(cvar("g_balance_campingrifle_primary_spread"), cvar("g_balance_campingrifle_primary_damage"), cvar("g_balance_campingrifle_primary_headshotaddeddamage"), cvar("g_balance_campingrifle_primary_force"), cvar("g_balance_campingrifle_primary_speed"), cvar("g_balance_campingrifle_primary_lifetime"), cvar("g_balance_campingrifle_primary_ammo"), WEP_CAMPINGRIFLE);
}

void W_Campingrifle_Attack2()
{
	W_CampingRifle_FireBullet(cvar("g_balance_campingrifle_secondary_spread"), cvar("g_balance_campingrifle_secondary_damage"), cvar("g_balance_campingrifle_secondary_headshotaddeddamage"), cvar("g_balance_campingrifle_secondary_force"), cvar("g_balance_campingrifle_secondary_speed"), cvar("g_balance_campingrifle_secondary_lifetime"), cvar("g_balance_campingrifle_secondary_ammo"), WEP_CAMPINGRIFLE | HITTYPE_SECONDARY);
}

void spawnfunc_weapon_campingrifle (void)
{
	weapon_defaultspawnfunc(WEP_CAMPINGRIFLE);
}

.float bot_secondary_campingriflemooth;
float w_campingrifle(float req)
{
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_campingriflemooth = 0;
		if(self.bot_secondary_campingriflemooth == 0)
		{
			if(bot_aim(cvar("g_balance_campingrifle_primary_speed"), 0, cvar("g_balance_campingrifle_primary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_campingriflemooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_campingrifle_secondary_speed"), 0, cvar("g_balance_campingrifle_secondary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.03) self.bot_secondary_campingriflemooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_campingrifle_primary_refire")))
		{
			W_Campingrifle_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_campingrifle_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (weapon_prepareattack(1, cvar("g_balance_campingrifle_secondary_refire")))
		{
			W_Campingrifle_Attack2();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_campingrifle_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{		
		precache_model ("models/tracer.mdl");
		precache_model ("models/weapons/g_campingrifle.md3");
		precache_model ("models/weapons/v_campingrifle.md3");
		precache_model ("models/weapons/w_campingrifle.zym");
		precache_sound ("weapons/campingrifle_reload.wav");
		precache_sound ("weapons/ric1.wav");
		precache_sound ("weapons/ric2.wav");
		precache_sound ("weapons/ric3.wav");
		precache_sound ("weapons/campingrifle_fire.wav");
		if (cvar("g_casings") >= 2)
		{
			precache_sound ("weapons/brass1.wav");
			precache_sound ("weapons/brass2.wav");
			precache_sound ("weapons/brass3.wav");
			precache_model ("models/casing_bronze.mdl");
		}
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CAMPINGRIFLE);
		W_Campingrifle_Reload();
	}
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= cvar("g_balance_campingrifle_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= cvar("g_balance_campingrifle_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "shot himself automatically";
		else
			w_deathtypestring = "sniped himself somehow";
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_BOUNCE)
				w_deathtypestring = "failed to hide from #'s bullet hail";
			else
				w_deathtypestring = "died in #'s bullet hail";
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = "failed to hide from #'s rifle";
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = "got hit in the head by #";
				else
					w_deathtypestring = "was sniped by #";
			}
		}
	}
	return TRUE;
};
