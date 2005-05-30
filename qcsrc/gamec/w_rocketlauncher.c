void() rlauncher_ready_01;
void() rlauncher_fire1_01;
void() rlauncher_deselect_01;
void() rlauncher_select_01;

float() rlauncher_check =
{
	if (self.ammo_rockets >= 3)
		return TRUE;
	return FALSE;
};

void(float req) w_rlauncher =
{
	if (req == WR_IDLE)
		rlauncher_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(rlauncher_check, rlauncher_check, rlauncher_fire1_01, cvar("g_balance_rocketlauncher_refire"));
	else if (req == WR_RAISE)
		rlauncher_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		rlauncher_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_ROCKET_LAUNCHER, "w_rl.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = rlauncher_check();
};


void W_Rocket_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);
	sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_rocketlauncher_damage"), cvar("g_balance_rocketlauncher_edgedamage"), cvar("g_balance_rocketlauncher_radius"), world, cvar("g_balance_rocketlauncher_force"), IT_ROCKET_LAUNCHER);

	remove (self);
}

void W_Rocket_Think (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		W_Rocket_Explode ();
		return;
	}
	if (self.owner)
	{
		if (self.owner.deadflag)
			self.owner = self;
		else if (self.owner.weapon == WEP_ROCKET_LAUNCHER && self.owner.button3)
			W_Rocket_Explode ();
	}
}

void W_Rocket_Touch (void)
{
	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	else
		W_Rocket_Explode ();
}

void W_Rocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Rocket_Explode();
}

void W_Rocket_Attack (void)
{
	local entity missile;
	local entity flash;
	local vector org;
	sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);
	if (cvar("g_rocketarena") == 0)
		self.ammo_rockets = self.ammo_rockets - 3;
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 3 + v_up * -11;
	te_smallflash(org);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 30;
	missile.event_damage = W_Rocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocket.md3");
	setsize (missile, '0 0 0', '0 0 0');

	setorigin (missile, org);
	missile.velocity = v_forward * cvar("g_balance_rocketlauncher_speed");
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch;
	missile.think = W_Rocket_Think;
	missile.nextthink = time;
	missile.cnt = time + 9;
	sound (missile, CHAN_BODY, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);

	flash = spawn ();
	setorigin (flash, org);
	setmodel (flash, "models/flash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT;
}

// weapon frames

void()	rlauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, rlauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	rlauncher_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	rlauncher_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	rlauncher_fire1_01 =
{
	weapon_doattack(rlauncher_check, rlauncher_check, W_Rocket_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, rlauncher_ready_01);
};

