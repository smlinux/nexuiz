void() hagar_ready_01;
void() hagar_fire1_01;
void() hagar_fire2_01;
void() hagar_deselect_01;
void() hagar_select_01;

float() hagar_check =
{
	if (self.ammo_rockets >= 1)
		return TRUE;
	return FALSE;
};

void(float req) w_hagar =
{
	if (req == WR_IDLE)
		hagar_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire1_01, cvar("g_balance_hagar_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire2_01, cvar("g_balance_hagar_refire"));
	else if (req == WR_RAISE)
		hagar_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		hagar_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAGAR, "w_hagar.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = hagar_check();
};

void W_Hagar_Explode (void)
{
	ImpactEffect (self, IT_HAGAR);

	self.event_damage = nullfunction;
	RadiusDamage (self, self.owner, cvar("g_balance_hagar_damage"), cvar("g_balance_hagar_edgedamage"), cvar("g_balance_hagar_radius"), world, cvar("g_balance_hagar_force"), IT_HAGAR);

	remove (self);
}

void W_Hagar_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	W_Hagar_Explode ();
}

void W_Hagar_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Hagar_Explode();
}

void W_Hagar_Attack (void)
{
	entity	missile;
	float	sped;

	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Hagar_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	missile.scale = 0.4;

	setorigin (missile, self.origin + self.view_ofs + v_forward * 25 + v_right * 5 + v_up * -8);

	sped = cvar("g_balance_hagar_speed");
	missile.velocity = v_forward * sped + v_right * crandom() * 0.035 * sped + v_up * crandom() * 0.015 * sped;
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + 10;

	self.ammo_rockets = self.ammo_rockets - 1;
	self.punchangle_x = -2;
}

void W_Hagar_Attack2 (void)
{
	entity	missile;

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	makevectors(self.v_angle);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 5;
	missile.event_damage = W_Hagar_Damage;

	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '-6 -6 -3', '6 6 3');

	setorigin (missile, self.origin + self.view_ofs + v_forward * 25 + v_right * 5 + v_up * -8);

	missile.scale = 0.4;

	missile.velocity = v_forward * cvar("g_balance_hagar_speed2") + v_up * cvar("g_balance_hagar_speed2_up");
	missile.angles = vectoangles (missile.velocity);
	missile.avelocity = '100 10 10';

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + 10;

	self.ammo_rockets = self.ammo_rockets - 1;
	self.punchangle_x = -2;
}

// weapon frames
void()	hagar_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, hagar_ready_01); self.weaponentity.state = WS_READY;};
void()	hagar_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	hagar_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	hagar_fire1_01 =
{
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, hagar_ready_01);
};
void()	hagar_fire2_01 =
{
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.15, hagar_ready_01);
};

