void(float imp) W_SwitchWeapon;

void W_Laser_Touch (void)
{
	vector	dir;
	vector org2;
	vector normal;

	PROJECTILE_TOUCH;

	normal = trace_plane_normal;
	dir = normalize (self.owner.origin - self.origin);

	self.event_damage = SUB_Null;
	if (self.dmg)
		RadiusDamage (self, self.owner, cvar("g_balance_laser_secondary_damage"), cvar("g_balance_laser_secondary_edgedamage"), cvar("g_balance_laser_secondary_radius"), world, cvar("g_balance_laser_secondary_force"), self.projectiledeathtype, other);
	else
		RadiusDamage (self, self.owner, cvar("g_balance_laser_primary_damage"), cvar("g_balance_laser_primary_edgedamage"), cvar("g_balance_laser_primary_radius"), world, cvar("g_balance_laser_primary_force"), self.projectiledeathtype, other);

	remove (self);
}

void W_Laser_Attack (float issecondary)
{
	local entity missile;

	W_SetupShot (self, '25 8 -8', FALSE, 3, "weapons/lasergun_fire.wav");
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "laserbolt";
	missile.dmg = issecondary;
	missile.bot_dodge = TRUE;
	if (issecondary)
		missile.bot_dodgerating = cvar("g_balance_laser_secondary_damage");
	else
		missile.bot_dodgerating = cvar("g_balance_laser_primary_damage");

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	missile.projectiledeathtype = WEP_LASER;
	if(issecondary)
		missile.projectiledeathtype |= HITTYPE_SECONDARY;

	setmodel (missile, "null"); // precision set below
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, w_shotorg);

	if (issecondary)
		missile.velocity = w_shotdir * cvar("g_balance_laser_secondary_speed");
	else
		missile.velocity = w_shotdir * cvar("g_balance_laser_primary_speed");
	W_SetupProjectileVelocity(missile);
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	if (issecondary)
		missile.nextthink = time + cvar("g_balance_laser_secondary_lifetime");
	else
		missile.nextthink = time + cvar("g_balance_laser_primary_lifetime");

	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_LASER);
}

float w_laser(float req)
{
	local float r1;
	local float r2;
	if (req == WR_AIM)
	{
		if(cvar("g_balance_laser_secondary"))
		{
			r1 = cvar("g_balance_laser_primary_damage");
			r2 = cvar("g_balance_laser_secondary_damage");
			if (random() * (r2 + r1) > r1)
				self.BUTTON_ATCK2 = bot_aim(cvar("g_balance_laser_secondary_speed"), 0, cvar("g_balance_laser_secondary_lifetime"), FALSE);
			else
				self.BUTTON_ATCK = bot_aim(cvar("g_balance_laser_primary_speed"), 0, cvar("g_balance_laser_primary_lifetime"), FALSE);
		}
		else
			self.BUTTON_ATCK = bot_aim(cvar("g_balance_laser_primary_speed"), 0, cvar("g_balance_laser_primary_lifetime"), FALSE);
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		if (weapon_prepareattack(0, cvar("g_balance_laser_primary_refire")))
		{
			W_Laser_Attack(FALSE);
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_laser_primary_animtime"), w_ready);
		}
		if (self.BUTTON_ATCK2)
		{
			if(cvar("g_balance_laser_secondary"))
			{
				if (weapon_prepareattack(0, cvar("g_balance_laser_secondary_refire")))
				{
					W_Laser_Attack(TRUE);
					weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_laser_secondary_animtime"), w_ready);
				}
			}
			else
			{
				if(self.switchweapon == WEP_LASER) // don't do this if already switching
					W_SwitchWeapon (self.cnt);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/v_laser.md3");
		precache_model ("models/weapons/w_laser.zym");
		precache_sound ("weapons/lasergun_fire.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_LASER);
	else if (req == WR_CHECKAMMO1)
		return TRUE;
	else if (req == WR_CHECKAMMO2)
		return TRUE;
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "lasered himself to hell";
	else if (req == WR_KILLMESSAGE)
	{
		w_deathtypestring = "was lasered to death by"; // unchecked: SPLASH
	}
	return TRUE;
};
