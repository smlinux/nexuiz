void() glauncher_ready_01;
void() glauncher_fire1_01;
void() glauncher_deselect_01;
void() glauncher_select_01;

float() glauncher_check =
{
	if (self.ammo_rockets >= 2)
		return TRUE;
	return FALSE;
};

void(float req) w_glauncher =
{
	if (req == WR_IDLE)
		glauncher_ready_01();
	else if (req == WR_FIRE1 || req == WR_FIRE2)
		weapon_prepareattack(glauncher_check, glauncher_check, glauncher_fire1_01, cvar("g_balance_grenadelauncher_refire"));
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

	self.event_damage = SUB_Null;
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
	local entity gren;
	local vector org;

	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	self.ammo_rockets = self.ammo_rockets - 2;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;
	te_smallflash(org);

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '-6 -6 -3', '6 6 3');
	setorigin(gren, org);

	if (self.button3)
	{
		gren.nextthink = time + 2.5;
		gren.think = W_Grenade_Explode;
		gren.touch = W_Grenade_Touch;
		gren.takedamage = DAMAGE_YES;
		gren.health = 10;
		gren.damageforcescale = 4;
		gren.event_damage = W_Grenade_Damage;
		gren.velocity = v_forward * cvar("g_balance_grenadelauncher_speed2") + v_up * cvar("g_balance_grenadelauncher_speed2_up");
		gren.avelocity = '100 150 100';
	}
	else
	{
		gren.nextthink = time + 30;
		gren.think = W_Grenade_Explode;
		gren.touch = W_Grenade_Explode;
		gren.velocity = v_forward * cvar("g_balance_grenadelauncher_speed") + v_up * cvar("g_balance_grenadelauncher_speed_up");
		gren.avelocity_x = random () * -500 - 500;
	}

	gren.angles = vectoangles (gren.velocity);
}

// weapon frames

void()	glauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, glauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	glauncher_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	glauncher_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	glauncher_fire1_01 =
{
	weapon_doattack(glauncher_check, glauncher_check, W_Grenade_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, glauncher_ready_01);
};