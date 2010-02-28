#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CAMPINGRIFLE, w_campingrifle, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "campingrifle", "campingrifle", "Rifle");
#else
//Camping rifle Primary mode: manually operated bolt*, Secondary: full automatic**
//* Manually operating the bolt means that all the power of the gas is used to propell the bullet. In this mode the bolt is prevented from moving backwards in response to the firing of the bullet.
//** In fully automatic mode some of the gas is used to extract and reload the next cartrige, thus there is less power and range.

.float campingrifle_accumulator;

float W_CampingRifle_CheckMaxBullets(float checkammo)
{
	float maxbulls;
	maxbulls = cvar("g_balance_campingrifle_magazinecapacity");
	if(!maxbulls)
		maxbulls = 8; // match HUD
	if(checkammo)
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
			maxbulls = min(maxbulls, floor(self.ammo_nails / min(cvar("g_balance_campingrifle_primary_ammo"), cvar("g_balance_campingrifle_secondary_ammo"))));
	if(self.campingrifle_bulletcounter > maxbulls || !cvar("g_balance_campingrifle_magazinecapacity"))
		self.campingrifle_bulletcounter = maxbulls;
	return (self.campingrifle_bulletcounter == maxbulls);
}

void W_CampingRifle_ReloadedAndReady()
{
	float t;
	self.campingrifle_bulletcounter = cvar("g_balance_campingrifle_magazinecapacity");
	W_CampingRifle_CheckMaxBullets(TRUE);
	t = ATTACK_FINISHED(self) - cvar("g_balance_campingrifle_reloadtime") - 1;
	ATTACK_FINISHED(self) = t;
	w_ready();
}

void W_CampingRifle_Reload()
{
	float t;

	W_CampingRifle_CheckMaxBullets(TRUE);
	if (self.campingrifle_bulletcounter >= cvar("g_balance_campingrifle_magazinecapacity"))
		return;

	if(self.ammo_nails < min(cvar("g_balance_campingrifle_primary_ammo"), cvar("g_balance_campingrifle_secondary_ammo")))
	{
		self.campingrifle_bulletcounter = -1; // reload later
		return;
	}
	
	if (self.weaponentity)
	{
		if (self.weaponentity.wframe == WFRAME_RELOAD)
			return;

		// allow to switch away while reloading, but this will cause a new reload!
		self.weaponentity.state = WS_READY;
	}

	sound (self, CHAN_WEAPON2, "weapons/campingrifle_reload.wav", VOL_BASE, ATTN_NORM);

	t = max(time, ATTACK_FINISHED(self)) + cvar("g_balance_campingrifle_reloadtime") + 1;
	ATTACK_FINISHED(self) = t;

	weapon_thinkf(WFRAME_RELOAD, cvar("g_balance_campingrifle_reloadtime"), W_CampingRifle_ReloadedAndReady);

	self.campingrifle_bulletcounter = -1;
}

void W_CampingRifle_CheckReloadAndReady()
{
	w_ready();
	if (self.campingrifle_bulletcounter <= 0)
		W_CampingRifle_Reload();
	else
		w_ready();
}

void W_CampingRifle_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant)
{
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_nails -= pAmmo;

	if(deathtype & HITTYPE_SECONDARY)
		W_SetupShot (self, cvar("g_antilag_bullets") && pSpeed >= cvar("g_antilag_bullets"), 2, "weapons/campingrifle_fire2.wav", cvar("g_balance_campingrifle_secondary_damage"));
	else
		W_SetupShot (self, cvar("g_antilag_bullets") && pSpeed >= cvar("g_antilag_bullets"), 2, "weapons/campingrifle_fire.wav", cvar("g_balance_campingrifle_primary_damage"));

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);

	if(self.BUTTON_ZOOM) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	}

	fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, (cvar("g_balance_campingrifle_tracer") ? EF_RED : EF_BLUE), 1, pBulletConstant);
	endFireBallisticBullet();

	if (cvar("g_casings") >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, self);
	
	self.campingrifle_bulletcounter = self.campingrifle_bulletcounter - 1;
	W_CampingRifle_CheckMaxBullets(TRUE);
}

void W_CampingRifle_Attack()
{
	W_CampingRifle_FireBullet(cvar("g_balance_campingrifle_primary_spread"), cvar("g_balance_campingrifle_primary_damage"), cvar("g_balance_campingrifle_primary_headshotaddeddamage"), cvar("g_balance_campingrifle_primary_force"), cvar("g_balance_campingrifle_primary_speed"), cvar("g_balance_campingrifle_primary_lifetime"), cvar("g_balance_campingrifle_primary_ammo"), WEP_CAMPINGRIFLE, cvar("g_balance_campingrifle_primary_bulletconstant"));
}

void W_CampingRifle_Attack2()
{
	W_CampingRifle_FireBullet(cvar("g_balance_campingrifle_secondary_spread"), cvar("g_balance_campingrifle_secondary_damage"), cvar("g_balance_campingrifle_secondary_headshotaddeddamage"), cvar("g_balance_campingrifle_secondary_force"), cvar("g_balance_campingrifle_secondary_speed"), cvar("g_balance_campingrifle_secondary_lifetime"), cvar("g_balance_campingrifle_secondary_ammo"), WEP_CAMPINGRIFLE | HITTYPE_SECONDARY, cvar("g_balance_campingrifle_secondary_bulletconstant"));
}

void spawnfunc_weapon_campingrifle (void)
{
	weapon_defaultspawnfunc(WEP_CAMPINGRIFLE);
}

.float bot_secondary_campingriflemooth;
float w_campingrifle(float req)
{
	float full;
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
		if(self.campingrifle_bulletcounter < 0) // forced reload (e.g. because interrupted)
		{
			if(self.switchweapon == self.weapon)
			if(self.weaponentity.state == WS_READY)
				W_CampingRifle_Reload();
		}
		else
		{
			self.campingrifle_accumulator = bound(time - cvar("g_balance_campingrifle_bursttime"), self.campingrifle_accumulator, time);
			if (self.BUTTON_ATCK)
			if (time >= self.campingrifle_accumulator + cvar("g_balance_campingrifle_primary_burstcost"))
			if (weapon_prepareattack(0, cvar("g_balance_campingrifle_primary_refire")))
			{
				W_CampingRifle_Attack();
				weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_campingrifle_primary_animtime"), W_CampingRifle_CheckReloadAndReady);
				self.campingrifle_accumulator += cvar("g_balance_campingrifle_primary_burstcost");
			}
			if (self.BUTTON_ATCK2)
			if (time >= self.campingrifle_accumulator + cvar("g_balance_campingrifle_secondary_burstcost"))
			if (weapon_prepareattack(1, cvar("g_balance_campingrifle_secondary_refire")))
			{
				W_CampingRifle_Attack2();
				weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_campingrifle_secondary_animtime"), W_CampingRifle_CheckReloadAndReady);
				self.campingrifle_accumulator += cvar("g_balance_campingrifle_secondary_burstcost");
			}
		}
	}
	else if (req == WR_PRECACHE)
	{		
		precache_model ("models/weapons/g_campingrifle.md3");
		precache_model ("models/weapons/v_campingrifle.md3");
		precache_model ("models/weapons/h_campingrifle.dpm");
		precache_sound ("weapons/campingrifle_reload.wav");
		precache_sound ("weapons/campingrifle_fire.wav");
		precache_sound ("weapons/campingrifle_fire2.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CAMPINGRIFLE);

		full = W_CampingRifle_CheckMaxBullets(TRUE);
		if(cvar("g_balance_campingrifle_auto_reload_after_changing_weapons"))
			if(!full)
				self.campingrifle_bulletcounter = -1;
	}
	else if (req == WR_CHECKAMMO1)
		return self.ammo_nails >= cvar("g_balance_campingrifle_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_nails >= cvar("g_balance_campingrifle_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "shot themself automatically";
		else
			w_deathtypestring = "sniped themself somehow";
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
	else if (req == WR_RELOAD)
	{
		W_CampingRifle_Reload();
	}
	else if (req == WR_RESETPLAYER)
	{
		self.campingrifle_accumulator = time - cvar("g_balance_campingrifle_bursttime");
		self.campingrifle_bulletcounter = cvar("g_balance_campingrifle_magazinecapacity");
		W_CampingRifle_CheckMaxBullets(FALSE);
	}
	return TRUE;
};
#endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     «[êKg|∫^f∆,9ﬁ@™	w_deathtypestring = "sniped themself somehow";
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
	else if (req == WR_RELOAD)
	{
		W_CampingRifle_Reload();
	}
	else if (req == WR_RESETPLAYER)
	{
		self.campingrifle_accumulator = time - cvar("g_balance_campingrifle_bursttime");
		self.campingrifle_bulletcounter = cvar("g_balance_campingrifle_magazinecapacity");
		W_CampingRifle_CheckMaxBullets(FALSE);
	}
	return TRUE;
};
#endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     tÏá{≥Ìo∏?~·Ö—	w_deathtypestring = "sniped themself somehow";
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
	else if (req == WR_RELOAD)
	{
		W_CampingRifle_Reload();
	}
	else if (req == WR_RESETPLAYER)
	{
		self.campingrifle_accumulator = time - cvar("g_balance_campingrifle_bursttime");
		self.campingrifle_bulletcounter = cvar("g_balance_campingrifle_magazinecapacity");
		W_CampingRifle_CheckMaxBullets(FALSE);
	}
	return TRUE;
};
#endif
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     