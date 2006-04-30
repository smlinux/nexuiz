void() laser_ready_01;
void() laser_fire1_01;
void() laser_deselect_01;
void() laser_select_01;

float() laser_check = {return TRUE;};

void(float req) w_laser =
{
	if (req == WR_IDLE)
		laser_ready_01();
	else if (req == WR_AIM)
		self.button0 = bot_aim(cvar("g_balance_laser_primary_speed"), 0, cvar("g_balance_laser_primary_lifetime"), FALSE);
	else if (req == WR_FIRE1)
		weapon_prepareattack(laser_check, laser_check, laser_fire1_01, cvar("g_balance_laser_refire"));
	else if (req == WR_FIRE2)
	{
		weapon_hasammo = TRUE;
		if (client_hasweapon(self, self.cnt, TRUE))
			self.switchweapon = self.cnt;
	}
	else if (req == WR_RAISE)
		laser_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = 1;
	else if (req == WR_DROP)
		laser_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_LASER, "w_laser.zym", 0);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = laser_check();
};

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

	/*
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_FLAMEJET);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);

	te_customflash(self.origin, 160, 0.2, '1 0 0');
	*/

	te_knightspike(org2);


	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_laser_damage"), cvar("g_balance_laser_edgedamage"), cvar("g_balance_laser_radius"), world, cvar("g_balance_laser_force"), IT_LASER);
	sound (self, CHAN_BODY, "weapons/laserimpact.ogg", 1, ATTN_NORM);

	remove (self);
}

void W_Laser_Attack (void)
{
	local entity missile;
	local vector org;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	self.punchangle_x = -3;

	org = W_MuzzleOrigin (self, '24 9 -9');
	//te_customflash(org, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	missile.classname = "laserbolt";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = cvar("g_balance_laser_damage");

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);

	missile.velocity = normalize(trueaim - org) * cvar("g_balance_laser_speed");
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + cvar("g_balance_laser_lifetime");

	missile.effects = EF_NOSHADOW | EF_FULLBRIGHT | EF_FULLBRIGHT | EF_LOWPRECISION;
	missile.flags = FL_PROJECTILE;
}

// weapon frames

void()	laser_ready_01 =
{
	weapon_thinkf(WFRAME_IDLE, 0.1, laser_ready_01);
	self.weaponentity.state = WS_READY;
};
void()	laser_select_01 =
{
	weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready);
	weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
};
void()	laser_deselect_01 =
{
	weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear);
	weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
};
void()	laser_fire1_01 =
{
	weapon_doattack(laser_check, laser_check, W_Laser_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_laser_animtime"), laser_ready_01);
};
