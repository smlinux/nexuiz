void() namek_ready_01;
void() namek_fire1_01;
void() namek_fire2_01;
void() namek_deselect_01;
void() namek_select_01;

float() namek_check =
{
	if (self.ammo_nails > 2)
		return TRUE;
	return FALSE;
};

void(float req) w_namek =
{
	if (req == WR_IDLE)
		namek_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(namek_check, namek_check, namek_fire1_01, cvar("g_balance_namek_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(namek_check, namek_check, namek_fire2_01, cvar("g_balance_namek_refire2"));
	else if (req == WR_RAISE)
		namek_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = floor(self.ammo_nails / 2);
	else if (req == WR_DROP)
		namek_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_NAMEK, "w_namek.zym", IT_CELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = namek_check();
};

void W_Namek_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	te_spark(self.origin, normalize(self.velocity) * -70 - '0 0 100', 30);

	if(other.takedamage)
		Damage (other, self, self.owner, self.dmg, WEP_NAMEK, self.origin, normalize(self.velocity) * cvar("g_balance_namek_force"));

	remove (self);
}

void FireNamekBullet(vector org, vector vel, float damage, float brange)
{
	entity proj;
	float livetime;

	livetime = brange / vlen(vel);

	//bprint(ftos(livetime), ": ", ftos(brange), ", ", ftos(vlen(vel)), "\n");

	proj = spawn ();
	proj.classname = "spike";
	proj.owner = self;
	proj.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	proj.think = SUB_Remove;
	proj.nextthink = time + livetime;
	proj.solid = SOLID_BBOX;
	proj.movetype = MOVETYPE_FLY;
	proj.dmg = damage;
	setorigin(proj, org);

	proj.velocity = vel;
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Namek_Touch;
	setmodel(proj, "models/weapons/namekb.mdl");
	setsize(proj, '0 0 0', '0 0 0');
}

void W_Namek_Attack()
{
	vector org, dir;
	float spread, brange, brange2;

	sound (self, CHAN_WEAPON, "weapons/namek_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	self.ammo_nails = self.ammo_nails - 2;

	org = self.origin + self.view_ofs + v_forward * 10 + v_right * 15 + v_up * -14;

	spread = cvar("g_balance_namek_spread");
	dir_x = v_forward_x + crandom()*spread;
	dir_y = v_forward_y + crandom()*spread;
	dir_z = v_forward_z + crandom()*spread;
	dir = normalize(dir);

	brange = cvar("g_balance_namek_range_min");
	brange2 = cvar("g_balance_namek_range_max") - brange;
	brange = brange + random()*brange2;

	FireNamekBullet(org, dir * cvar("g_balance_namek_speed"), cvar("g_balance_namek_damage"), brange);
}

void W_Namek_Attack2()
{
	vector org;
	float brange;

	sound (self, CHAN_WEAPON, "weapons/namek_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	self.ammo_nails = self.ammo_nails - 2;

	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 10 + v_up * -14;
	brange = cvar("g_balance_namek_range2");

	FireNamekBullet(org + '0 0 1', v_forward * cvar("g_balance_namek_speed2"), cvar("g_balance_namek_damage2"), brange);
	FireNamekBullet(org - '0 0 2', v_forward * cvar("g_balance_namek_speed2"), cvar("g_balance_namek_damage2"), brange);
}

// weapon frames

void()	namek_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, namek_ready_01); self.weaponentity.state = WS_READY;};
void()	namek_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	namek_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	namek_fire1_01 =
{
	weapon_doattack(namek_check, namek_check, W_Namek_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_namek_refire") - 0.05, namek_ready_01);
};
void()	namek_fire2_01 =
{
	weapon_doattack(namek_check, namek_check, W_Namek_Attack2);
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_namek_refire2") - 0.05, namek_ready_01);
};

