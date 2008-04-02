
.float gravity;
const vector proj_color = '1 1 1';

.entity realowner;

void W_Crylink_Think (void)
{
	self.nextthink = self.count;
	self.angles = vectoangles(self.velocity);
	if (time >= self.count)
		remove(self);
}

void W_Crylink_Touch (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	pointparticles(particleeffectnum("crylink_impact"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_primary_damage"), cvar("g_balance_crylink_primary_edgedamage"), cvar("g_balance_crylink_primary_radius"), world, cvar("g_balance_crylink_primary_force"), IT_CRYLINK);
	if (self.cnt <= 0 || other.takedamage != DAMAGE_NO)
	{
		remove (self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time;
	self.owner = world;
}

void W_Crylink_Touch2 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	pointparticles(particleeffectnum("crylink_impact"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_secondary_damage"), cvar("g_balance_crylink_secondary_edgedamage"), cvar("g_balance_crylink_secondary_radius"), world, cvar("g_balance_crylink_secondary_force"), IT_CRYLINK);
	if (self.cnt <= 0 || other.takedamage != DAMAGE_NO)
	{
		remove (self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.nextthink = time;
	self.owner = world;
}

void W_Crylink_Attack (void)
{
	local float counter, shots;
	local entity proj;
	local vector s;

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_primary_ammo");

	W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/crylink_fire.wav");

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
		proj.solid = SOLID_BBOX;
		//proj.gravity = 0.001;

		setmodel (proj, "models/plasmatrail.mdl"); // precision set below
		setsize (proj, '0 0 0', '0 0 0');
		setorigin (proj, w_shotorg);

		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else if (counter == 1)
			s = '0 0 1';
		else if (counter == 2)
			s = '0 -0.71 -0.71';
		else if (counter == 3)
			s = '0 0.71 -0.71';
		else
			s = randomvec();
		s = s * cvar("g_balance_crylink_primary_spread");
		proj.velocity = (w_shotdir + v_right * s_y + v_up * s_z) * cvar("g_balance_crylink_primary_speed");
//		proj.velocity = (w_shotdir + randomvec() * cvar("g_balance_crylink_primary_spread")) * cvar("g_balance_crylink_primary_speed");
		W_SetupProjectileVelocity(proj);
		proj.touch = W_Crylink_Touch;
		proj.count = time + cvar("g_balance_crylink_primary_lifetime");
		proj.think = W_Crylink_Think;
		proj.nextthink = proj.count;
		proj.cnt = cvar("g_balance_crylink_primary_bounces");

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.effects = EF_LOWPRECISION;
		proj.flags = FL_PROJECTILE;
		proj.colormod = proj_color;
		counter = counter + 1;
	}
}

void W_Crylink_Attack2 (void)
{
	local float counter, shots;
	local entity proj;

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_secondary_ammo");

	W_SetupShot (self, '25 8 -8', FALSE, 2, "weapons/crylink_fire.wav");

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
		proj.solid = SOLID_BBOX;
		//proj.gravity = 0.001;

		setmodel (proj, "models/plasmatrail.mdl"); // precision set below
		setsize (proj, '0 0 0', '0 0 0');
		setorigin (proj, w_shotorg);

		proj.velocity = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * cvar("g_balance_crylink_secondary_spread")) * cvar("g_balance_crylink_secondary_speed");
		W_SetupProjectileVelocity(proj);
		proj.touch = W_Crylink_Touch2;
		proj.count = time + cvar("g_balance_crylink_primary_lifetime");
		proj.think = W_Crylink_Think;
		proj.nextthink = proj.count;
		proj.cnt = cvar("g_balance_crylink_secondary_bounces");

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.effects = EF_LOWPRECISION;
		proj.flags = FL_PROJECTILE;
		proj.colormod = proj_color;
		counter = counter + 1;
	}
}


/*
// experimental lightning gun
void W_Crylink_Attack3 (void)
{
	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_primary_ammo");
	W_SetupShot (self, '25 8 -8', TRUE, 0, "weapons/crylink_fire.wav");

	traceline_antilag(self, w_shotorg, w_shotorg + w_shotdir * 1000, FALSE, self, self.ping * 0.001);

	pointparticles(particleeffectnum("lightning_muzzleflash", w_shotorg, w_shotdir * 1000, 1);
	pointparticles(particleeffectnum("lightning_impact", trace_endpos, trace_plane_normal * 1000, 1);
	trailparticles(world, particleeffectnum("lightning_beam", w_shotorg, trace_endpos);

	if (trace_fraction < 1)
		Damage(trace_ent, self, self, cvar("g_balance_crylink_primary_damage"), IT_CRYLINK, trace_endpos, '0 0 0');
}
*/

float(float req) w_crylink =
{
	if (req == WR_AIM)
	{
		if (random() > 0.15)
			self.button0 = bot_aim(cvar("g_balance_crylink_primary_speed"), 0, cvar("g_balance_crylink_primary_lifetime"), FALSE);
		else
			self.button3 = bot_aim(cvar("g_balance_crylink_secondary_speed"), 0, cvar("g_balance_crylink_secondary_lifetime"), FALSE);
	}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_crylink_primary_refire")))
		{
			W_Crylink_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_crylink_primary_animtime"), w_ready);
		}
		if (self.button3)
		if (weapon_prepareattack(1, cvar("g_balance_crylink_secondary_refire")))
		{
			W_Crylink_Attack2();
			weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_crylink_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/plasma.mdl");
		precache_model ("models/plasmatrail.mdl");
		precache_model ("models/weapons/g_crylink.md3");
		precache_model ("models/weapons/v_crylink.md3");
		precache_model ("models/weapons/w_crylink.zym");
		precache_sound ("weapons/crylink_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_CRYLINK, "crylink", IT_CELLS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_crylink_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= cvar("g_balance_crylink_secondary_ammo");
	else if (req == WR_REGISTER)
		weapon_register(WEP_CRYLINK, min(cvar("g_balance_crylink_primary_ammo"), cvar("g_balance_crylink_secondary_ammo")));
	return TRUE;
};
