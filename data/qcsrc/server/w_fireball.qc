#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FIREBALL, w_fireball, IT_ROCKETS, 9, WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "fireball", "fireball", "Fireball");
#else
.float bot_secondary_fireballmooth; // whatever a mooth is
.vector fireball_impactvec;
.float fireball_secondarytime;

void W_Fireball_Explode (void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = SUB_Null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.owner.health + self.owner.armorvalue);
	RadiusDamage (self, self.realowner, cvar("g_balance_fireball_secondary_damage"), cvar("g_balance_fireball_secondary_edgedamage"), cvar("g_balance_fireball_secondary_radius"), world, cvar("g_balance_fireball_secondary_force"), self.projectiledeathtype, other);
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, cvar("g_balance_fireball_secondary_bfgradius"), 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, cvar("g_balance_fireball_secondary_bfgradius")); e; e = e.chain)
		if(e != self.owner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.owner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / cvar("g_balance_fireball_secondary_bfgradius")));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);
			Damage(e, self, self.realowner, cvar("g_balance_fireball_secondary_bfgdamage") * points, self.projectiledeathtype | HITTYPE_BOUNCE | HITTYPE_SPLASH, e.origin + e.view_ofs, cvar("g_balance_fireball_secondary_bfgforce") * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);

			Damage_RecordDamage(self.owner, self.projectiledeathtype, cvar("g_balance_fireball_secondary_bfgdamage") * points);
		}
	}

	remove (self);
}

void W_Fireball_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	W_Fireball_Explode ();
}

void W_Fireball_LaserPlay(float dt, float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;

	if(damage <= 0)
		return;

	RandomSelection_Init();
	for(e = WarpZone_FindRadius(self.origin, dist, TRUE); e; e = e.chain)
	if(e != self.owner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.owner || IsDifferentTeam(e, self))
	{
		p = e.origin;
		p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
		p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
		p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
		d = vlen(WarpZone_UnTransformOrigin(e, self.origin) - p);
		if(d < dist)
		{
			e.fireball_impactvec = p;
			RandomSelection_Add(e, 0, string_null, 1 / (1 + d), !Fire_IsBurning(e));
		}
	}
	if(RandomSelection_chosen_ent)
	{
		d = vlen(WarpZone_UnTransformOrigin(RandomSelection_chosen_ent, self.origin) - RandomSelection_chosen_ent.fireball_impactvec);
		d = damage + (edgedamage - damage) * (d / dist);
		Fire_AddDamage(RandomSelection_chosen_ent, self.realowner, d * burntime, burntime, self.projectiledeathtype | HITTYPE_BOUNCE);
		//trailparticles(self, particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec);
		pointparticles(particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec - self.origin, 1);
	}
}

void W_Fireball_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		W_Fireball_Explode();
		return;
	}

	W_Fireball_LaserPlay(0.1, cvar("g_balance_fireball_secondary_laserradius"), cvar("g_balance_fireball_secondary_laserdamage"), cvar("g_balance_fireball_secondary_laseredgedamage"), cvar("g_balance_fireball_secondary_laserburntime"));

	self.nextthink = time + 0.1;
}

void W_Fireball_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.cnt = 1;
		W_PrepareExplosionByDamage(attacker, W_Fireball_Explode);
	}
}

void W_Fireball_Attack2()
{
	local entity proj;

	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", cvar("g_balance_fireball_secondary_damage") + cvar("g_balance_fireball_secondary_bfgdamage"));

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_fireball_secondary_damage");
	proj.pushltime = time + cvar("g_balance_fireball_secondary_lifetime");
	proj.use = W_Fireball_Explode;
	proj.think = W_Fireball_Think;
	proj.nextthink = time;
	proj.health = cvar("g_balance_fireball_secondary_health");
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = cvar("g_balance_fireball_secondary_damageforcescale");
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_secondary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);
}

void W_Fireball_AttackEffect(float i, vector f_diff)
{
	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 0, "", 0);
	w_shotorg += f_diff_x * v_up + f_diff_y * v_right;
	pointparticles(particleeffectnum("fireball_preattack_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
}

void W_Fireball_Attack2_Frame4()
{
	W_Fireball_Attack2();
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_fireball_secondary_animtime"), w_ready);
}

void W_Fireball_Attack2_Frame3()
{
	W_Fireball_AttackEffect(0, '+1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_fireball_secondary_animtime"), W_Fireball_Attack2_Frame4);
}

void W_Fireball_Attack2_Frame2()
{
	W_Fireball_AttackEffect(0, '-1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_fireball_secondary_animtime"), W_Fireball_Attack2_Frame3);
}

void W_Fireball_Attack2_Frame1()
{
	W_Fireball_AttackEffect(1, '+1.25 -3.75 0');
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_fireball_secondary_animtime"), W_Fireball_Attack2_Frame2);
}

void W_Fireball_Attack2_Frame0()
{
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_fireball_secondary_ammo");

	W_Fireball_AttackEffect(0, '-1.25 -3.75 0');
	sound (self, CHAN_WEAPON, "weapons/fireball_prefire2.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_fireball_secondary_animtime"), W_Fireball_Attack2_Frame1);
}

void W_Firemine_Think()
{
	if(time > self.pushltime)
	{
		remove(self);
		return;
	}

	// make it "hot" once it leaves its owner
	if(self.owner)
	{
		if(vlen(self.origin - self.owner.origin - self.owner.view_ofs) > cvar("g_balance_fireball_primary_laserradius"))
		{
			self.cnt += 1;
			if(self.cnt == 3)
				self.owner = world;
		}
		else
			self.cnt = 0;
	}

	W_Fireball_LaserPlay(0.1, cvar("g_balance_fireball_primary_laserradius"), cvar("g_balance_fireball_primary_laserdamage"), cvar("g_balance_fireball_primary_laseredgedamage"), cvar("g_balance_fireball_primary_laserburntime"));

	self.nextthink = time + 0.1;
}

void W_Firemine_Touch (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM)
	if(Fire_AddDamage(other, self.realowner, cvar("g_balance_fireball_primary_damage"), cvar("g_balance_fireball_primary_damagetime"), self.projectiledeathtype | HITTYPE_HEADSHOT) >= 0)
	{
		remove(self);
		return;
	}
	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void W_Fireball_Attack1()
{
	local entity proj;
	vector f_diff;
	float c;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_fireball_primary_ammo");

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", cvar("g_balance_fireball_primary_damage"));
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, self);
	w_shotorg = trace_endpos;

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = self;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_fireball_primary_damage");
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = cvar("g_balance_fireball_primary_damageforcescale");
	proj.pushltime = time + cvar("g_balance_fireball_primary_lifetime");
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_primary);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;

	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void spawnfunc_weapon_fireball (void)
{
	weapon_defaultspawnfunc(WEP_FIREBALL);
}

float w_fireball(float req)
{
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if (self.bot_secondary_fireballmooth == 0)
		{
			if(bot_aim(cvar("g_balance_fireball_primary_speed"), cvar("g_balance_fireball_primary_speed_up"), cvar("g_balance_fireball_primary_lifetime"), TRUE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_fireballmooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_fireball_secondary_speed"), 0, cvar("g_balance_fireball_secondary_lifetime"), FALSE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.02) self.bot_secondary_fireballmooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_fireball_primary_refire")))
		{
			W_Fireball_Attack1();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_fireball_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		if (time >= self.fireball_secondarytime)
		if (weapon_prepareattack(1, cvar("g_balance_fireball_secondary_refire")))
		{
			W_Fireball_Attack2_Frame0();
			self.fireball_secondarytime = time + cvar("g_balance_fireball_secondary_refire2");
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_fireball.md3");
		precache_model ("models/weapons/v_fireball.md3");
		precache_model ("models/weapons/h_fireball.dpm");
		precache_model ("models/sphere/sphere.md3");
		precache_sound ("weapons/fireball_fire.wav");
		precache_sound ("weapons/fireball_fire2.wav");
		precache_sound ("weapons/fireball_prefire2.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_FIREBALL);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_rockets >= cvar("g_balance_fireball_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_rockets >= cvar("g_balance_fireball_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = "should have used a smaller gun";
		else
			w_deathtypestring = "forgot about some firemine";
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				if(w_deathtype & HITTYPE_SPLASH) // BFG effect
				{
					w_deathtypestring = "could not hide from #'s fireball";
				}
				else // laser
				{
					w_deathtypestring = "saw the pretty lights of #'s fireball";
				}
			}
			else if(w_deathtype & HITTYPE_SPLASH)
				w_deathtypestring = "got too close to #'s fireball";
			else
				w_deathtypestring = "tasted #'s fireball";
		}
		else
		{
			if(w_deathtype & HITTYPE_HEADSHOT)
				w_deathtypestring = "tried to catch #'s firemine";
			else
				w_deathtypestring = "fatefully ignored #'s firemine";
		}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.fireball_secondarytime = time;
	}
	return TRUE;
};
#endif
