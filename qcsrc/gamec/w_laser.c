void() laser_ready_01;
void() laser_fire1_01;
void() laser_fire2_01;
void() laser_fire3_01;
void() laser_deselect_01;
void() laser_select_01;

float() laser_check = {return TRUE;};

void(float req) w_laser =
{
	if (req == WR_IDLE)
		laser_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(laser_check, laser_check, laser_fire1_01, 0.4);
	else if (req == WR_FIRE2)
		weapon_prepareattack(laser_check, laser_check, laser_fire2_01, 0.3);
	else if (req == WR_FIRE3)
		weapon_prepareattack(laser_check, laser_check, laser_fire3_01, 0.3);
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

	/*
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_FLAMEJET);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155); */

	

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 15, 20, 50, world, 200, IT_LASER);
	sound (self, CHAN_IMPACT, "weapons/laserimpact.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Laser_Attack (void)
{
	weapon_shotdir(18, 5, -12);
	// self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);
	sound (self, CHAN_WEAPON, "weapons/crylink.wav", 1, ATTN_NORM);
	//org = self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14;	
	FireRailgunBullet (self.shotorg, self.origin + self.shotdir*4096, 25, IT_LASER);
	te_spark(trace_endpos, self.shotdir, 55);
	self.attack_finished = time + 0.400;
}

void W_Laser_Attack2 (void)
{
	entity	missile;

	makevectors(self.v_angle);

	sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "spike";

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	setmodel (missile, "models/laser.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 1000;
	missile.velocity = missile.velocity + v_right * ( crandom() * 45 );
	missile.velocity = missile.velocity + v_up * ( crandom() * 25 );
	missile.angles = vectoangles (missile.velocity);
	missile.glow_color = 250; // 244, 250
	missile.glow_size = 30;
	missile.touch = W_Laser_Touch;
	missile.think = SUB_Remove;
	missile.nextthink = time + 9;

	missile.effects = missile.effects | EF_ADDITIVE;

	self.punchangle_x = random () - 0.5;
	self.punchangle_y = random () - 0.5;
	self.punchangle_z = random () - 0.5;

	self.attack_finished = time + 0.3;
}

// weapon frames 

void()	laser_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, laser_ready_01); self.weaponentity.state = WS_READY;};
void()	laser_select_01 =	{weapon_thinkf(-1, 0.3, w_ready); weapon_boblayer1(16, '0 0 0');};
void()	laser_deselect_01 =	{weapon_thinkf(-1, 0.3, w_clear); weapon_boblayer1(16, '0 20 -40');};
void()	laser_fire1_01 =	
{
	weapon_doattack(laser_check, laser_check, W_Laser_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, laser_ready_01);
};
void()	laser_fire2_01 =	
{
	weapon_doattack(laser_check, laser_check, W_Laser_Attack2);
	weapon_thinkf(WFRAME_FIRE1, 0.2, laser_ready_01);
};
void()	laser_fire3_01 =	
{
	weapon_doattack(laser_check, laser_check, W_Laser_Attack2);
	weapon_thinkf(WFRAME_FIRE1, 0.2, laser_ready_01);
};

