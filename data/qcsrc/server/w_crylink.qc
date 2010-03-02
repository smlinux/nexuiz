#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CRYLINK, w_crylink, IT_CELLS, 6, WEP_FLAG_NORMAL | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "crylink", "crylink", "Crylink");
#else
.float gravity;

.entity realowner;

// NO bounce protection, as bounces are limited!
void W_Crylink_Touch (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;
	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = cvar("g_balance_crylink_primary_bouncedamagefactor");
	if(self.alpha)
		f *= self.alpha;
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_primary_damage") * f, cvar("g_balance_crylink_primary_edgedamage") * f, cvar("g_balance_crylink_primary_radius"), world, cvar("g_balance_crylink_primary_force") * f, self.projectiledeathtype, other);
	if (finalhit)
	{
		remove (self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void W_Crylink_Touch2 (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;
	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = cvar("g_balance_crylink_secondary_bouncedamagefactor");
	if(self.alpha)
		f *= self.alpha;
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_secondary_damage") * f, cvar("g_balance_crylink_secondary_edgedamage") * f, cvar("g_balance_crylink_secondary_radius"), world, cvar("g_balance_crylink_secondary_force") * f, self.projectiledeathtype, other);
	if (finalhit)
	{
		remove (self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void W_Crylink_Attack (void)
{
	local float counter, shots;
	local entity proj;
	local vector s;
	vector forward, right, up;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_primary_ammo");

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", (cvar("g_balance_crylink_primary_damage")*cvar("g_balance_crylink_primary_shots")));
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = cvar("g_balance_crylink_primary_shots");
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	while (counter < shots)
	{
		proj = spawn ();
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = cvar("g_balance_crylink_primary_damage");

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * cvar("g_balance_crylink_primary_spread") * g_weaponspreadfactor;
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, cvar("g_balance_crylink_primary_speed"), 0, 0, 0);
		proj.touch = W_Crylink_Touch;
		if(counter == 0)
			SUB_SetFade(proj, time + cvar("g_balance_crylink_primary_middle_lifetime"), cvar("g_balance_crylink_primary_middle_fadetime"));
		else if(counter <= 3)
			SUB_SetFade(proj, time + cvar("g_balance_crylink_primary_star_lifetime"), cvar("g_balance_crylink_primary_star_fadetime"));
		else
			SUB_SetFade(proj, time + cvar("g_balance_crylink_primary_other_lifetime"), cvar("g_balance_crylink_primary_other_fadetime"));
		proj.cnt = cvar("g_balance_crylink_primary_bounces");
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;

		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		counter = counter + 1;
	}
}

void W_Crylink_Attack2 (void)
{
	local float counter, shots;
	local entity proj;

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_secondary_ammo");

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire2.wav", (cvar("g_balance_crylink_secondary_damage")*cvar("g_balance_crylink_secondary_shots")));

	shots = cvar("g_balance_crylink_secondary_shots");
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	while (counter < shots)
	{
		proj = spawn ();
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = cvar("g_balance_crylink_secondary_damage");

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK | HITTYPE_SECONDARY;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');

		W_SetupProjectileVelocityEx(proj, (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * cvar("g_balance_crylink_secondary_spread") * g_weaponspreadfactor), v_up, cvar("g_balance_crylink_secondary_speed"), 0, 0, 0);
		proj.touch = W_Crylink_Touch2;
		if(counter == (shots - 1) / 2)
			SUB_SetFade(proj, time + cvar("g_balance_crylink_secondary_middle_lifetime"), cvar("g_balance_crylink_secondary_middle_fadetime"));
		else
			SUB_SetFade(proj, time + cvar("g_balance_crylink_secondary_line_lifetime"), cvar("g_balance_crylink_secondary_line_fadetime"));
		proj.cnt = cvar("g_balance_crylink_secondary_bounces");
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;

		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		counter = counter + 1;
	}
}

void spawnfunc_weapon_crylink (void)
{
	weapon_defaultspawnfunc(WEP_CRYLINK);
}

float w_crylink(float req)
{
	if (req == WR_AIM)
	{
		if (random() > 0.15)
			self.BUTTON_ATCK = bot_aim(cvar("g_balance_crylink_primary_speed"), 0, cvar("g_balance_crylink_primary_middle_lifetime"), FALSE);
		else
			self.BUTTON_ATCK2 = bot_aim(cvar("g_balance_crylink_secondary_speed"), 0, cvar("g_balance_crylink_secondary_middle_lifetime"), FALSE);
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_crylink_primary_refire")))
		{
			W_Crylink_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_crylink_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2 && cvar("g_balance_crylink_secondary"))
		if (weapon_prepareattack(1, cvar("g_balance_crylink_secondary_refire")))
		{
			W_Crylink_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_crylink_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_crylink.md3");
		precache_model ("models/weapons/v_crylink.md3");
		precache_model ("models/weapons/h_crylink.dpm");
		precache_sound ("weapons/crylink_fire.wav");
		precache_sound ("weapons/crylink_fire2.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_CRYLINK);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_crylink_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= cvar("g_balance_crylink_secondary_ammo");
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = "succeeded at self-destructing themself with the Crylink";
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = "could not hide from #'s Crylink"; // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = "was too close to #'s Crylink"; // unchecked: SECONDARY
		else
			w_deathtypestring = "took a close look at #'s Crylink"; // unchecked: SECONDARY
	}
	return TRUE;
};
#endif
