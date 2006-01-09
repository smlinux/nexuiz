void() laser_ready_01;
void() laser_fire1_01;
void() laser_deselect_01;
void() laser_select_01;

float() laser_check = {return TRUE;};

void(float req) w_laser =
{
	if (req == WR_IDLE)
		laser_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(laser_check, laser_check, laser_fire1_01, cvar("g_balance_laser_refire"));
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

	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	dir = normalize (self.owner.origin - self.origin);

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


	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_laser_damage"), cvar("g_balance_laser_edgedamage"), cvar("g_balance_laser_radius"), world, cvar("g_balance_laser_force"), IT_LASER);
	sound (self, CHAN_BODY, "weapons/laserimpact.ogg", 1, ATTN_NORM);

	remove (self);
}

void W_Laser_Attack (void)
{
	local entity missile;
	local vector org;

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}
	
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;
	//te_customflash(org, 160, 0.2, '1 0 0');

	missile = spawn ();
	missile.owner = self;
	missile.classname = "laserbolt";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, org);

	missile.velocity = v_forward * cvar("g_balance_laser_speed");
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 9;

	missile.effects = EF_FULLBRIGHT | EF_FULLBRIGHT | EF_LOWPRECISION;
}

// weapon frames

void()	laser_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, laser_ready_01); self.weaponentity.state = WS_READY;};
void()	laser_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	laser_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	laser_fire1_01 =
{
	weapon_doattack(laser_check, laser_check, W_Laser_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, laser_ready_01);
};

