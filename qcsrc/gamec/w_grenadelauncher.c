void() glauncher_ready_01;
void() glauncher_fire1_01;
void() glauncher_fire2_01;
void() glauncher_deselect_01;
void() glauncher_select_01;

float() glauncher_check =
{
	if (self.ammo_rockets >= 3)
		return TRUE;
	return FALSE;
};

void(float req) w_glauncher =
{
	if (req == WR_IDLE)
		glauncher_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(glauncher_check, glauncher_check, glauncher_fire1_01, 0.8);
	else if (req == WR_FIRE2)
		weapon_prepareattack(glauncher_check, glauncher_check, glauncher_fire2_01, 1);
	else if (req == WR_RAISE)
		glauncher_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		glauncher_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_GRENADE_LAUNCHER, "w_gl.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = glauncher_check();
};

void W_Grenade_Explode (void)
{
	ImpactEffect (self, IT_GRENADE_LAUNCHER);

	self.event_damage = nullfunction;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_damage"), cvar("g_balance_grenadelauncher_edgedamage"), cvar("g_balance_grenadelauncher_radius"), world, cvar("g_balance_grenadelauncher_force"), IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_Touch (void)
{
	if (other.classname == "player" || other.classname == "corpse")
		W_Grenade_Explode ();
	else
	sound (self, CHAN_BODY, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
}

void W_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Grenade_Explode();
}

void W_Grenade_Attack (void)
{
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;

	entity gren;

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '-6 -6 -3', '6 6 3');
	setorigin(gren, self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12);
	gren.health = 1;
	gren.takedamage = DAMAGE_YES;
	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_speed") + v_up * cvar("g_balance_grenadelauncher_speed_up");
	gren.avelocity_x = random () * -500 - 500;
	setsize (gren, gren.mins, gren.maxs);
	gren.angles = vectoangles (gren.velocity);
	gren.touch = W_Grenade_Explode;
	gren.think = W_Grenade_Explode;
	gren.nextthink = time + 30;
	self.ammo_rockets = self.ammo_rockets - 3;


	self.attack_finished = time + 0.8;
}

void W_Grenade_Attack2 (void)
{

	entity	gren;
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -4;

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";

	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;

	gren.takedamage = DAMAGE_YES;
	gren.damageforcescale = 4;
	gren.health = 10;
	gren.event_damage = W_Grenade_Damage;

	setmodel (gren, "models/grenademodel.md3");
	setsize (gren, '-6 -6 -3', '6 6 3');

	setorigin (gren, self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12);

	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_speed2") + v_up * cvar("g_balance_grenadelauncher_speed2_up");
	gren.angles = vectoangles (gren.velocity);
	gren.avelocity = '100 150 100';

	gren.touch = W_Grenade_Explode;
	//gren.think = W_Grenade_FuseExplode;
	//gren.nextthink = time + 5;

	self.attack_finished = time + 1;
	self.ammo_rockets = self.ammo_rockets - 3;
}

// weapon frames

void()	glauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, glauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	glauncher_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	glauncher_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	glauncher_fire1_01 =
{
	weapon_doattack(glauncher_check, glauncher_check, W_Grenade_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, glauncher_ready_01);
};
void()	glauncher_fire2_01 =
{
	weapon_doattack(glauncher_check, glauncher_check, W_Grenade_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.8, glauncher_ready_01);
};