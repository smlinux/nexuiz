void(float imp) W_SwitchWeapon;

void W_Laser_Touch (void)
{
	vector	dir;
	vector org2;

	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}

	if (other == self.owner)
		return;

	dir = normalize (self.owner.origin - self.origin);
	org2 = findbetterlocation (self.origin, 8);

	te_knightspike(org2);


	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_laser_damage"), cvar("g_balance_laser_edgedamage"), cvar("g_balance_laser_radius"), world, cvar("g_balance_laser_force"), IT_LASER);
	sound (self, CHAN_BODY, "weapons/laserimpact.ogg", 1, ATTN_NORM);

	remove (self);
}

void W_Laser_Attack (void)
{
	local entity missile;

	W_SetupShot (self, '15 8 -8', FALSE, 3, "weapons/lasergun_fire.ogg");
	//te_customflash(w_shotorg, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	missile.classname = "laserbolt";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_laser_damage");

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, w_shotorg);

	missile.velocity = w_shotdir * cvar("g_balance_laser_speed");
	W_SetupProjectileVelocity(missile);
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + cvar("g_balance_laser_lifetime");

	missile.effects = EF_NOSHADOW | EF_FULLBRIGHT | EF_FULLBRIGHT | EF_LOWPRECISION;
	missile.flags = FL_PROJECTILE;
}

float(float req) w_laser =
{
	if (req == WR_AIM)
		self.button0 = bot_aim(cvar("g_balance_laser_speed"), 0, cvar("g_balance_laser_lifetime"), FALSE);
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_laser_refire")))
		{
			W_Laser_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_laser_animtime"), w_ready);
		}
		if (self.button3)
		if (client_hasweapon(self, self.cnt, TRUE, FALSE))
			W_SwitchWeapon (self.cnt);
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_LASER, "laser", 0);
	else if (req == WR_CHECKAMMO1)
		return TRUE;
	else if (req == WR_CHECKAMMO2)
		return TRUE;
	return TRUE;
};
