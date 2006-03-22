void() hagar_ready_01;
void() hagar_fire1_01;
void() hagar_fire2_01;
void() hagar_deselect_01;
void() hagar_select_01;

float() hagar_check =
{
	if (self.ammo_rockets >= cvar("g_balance_hagar_primary_ammo"))
		return TRUE;
	return FALSE;
};

float() hagar_check2 =
{
	if (self.ammo_rockets >= cvar("g_balance_hagar_secondary_ammo"))
		return TRUE;
	return FALSE;
};

void(float req) w_hagar =
{
	if (req == WR_IDLE)
		hagar_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire1_01, cvar("g_balance_hagar_primary_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire2_01, cvar("g_balance_hagar_secondary_refire"));
	else if (req == WR_RAISE)
		hagar_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		hagar_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAGAR, "w_hagar.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = hagar_check() + hagar_check2();
};

void W_Hagar_Explode (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/hagar.spr", 0, 12, 35);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_BODY, "weapons/hagexp1.ogg", 1, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_BODY, "weapons/hagexp2.ogg", 1, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_BODY, "weapons/hagexp3.ogg", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hagar_primary_damage"), cvar("g_balance_hagar_primary_edgedamage"), cvar("g_balance_hagar_primary_radius"), world, cvar("g_balance_hagar_primary_force"), IT_HAGAR);

	remove (self);
}

void W_Hagar_Explode2 (void)
{
	vector	org2;
	float b;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/hagar.spr", 0, 12, 35);
	b = crandom();
	if (b<-0.7)
		sound (self, CHAN_BODY, "weapons/hagexp1.ogg", 1, ATTN_NORM);
	else if (b<0.4)
		sound (self, CHAN_BODY, "weapons/hagexp2.ogg", 1, ATTN_NORM);
	else if (b<1)
		sound (self, CHAN_BODY, "weapons/hagexp3.ogg", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hagar_secondary_damage"), cvar("g_balance_hagar_secondary_edgedamage"), cvar("g_balance_hagar_secondary_radius"), world, cvar("g_balance_hagar_secondary_force"), IT_HAGAR);

	remove (self);
}

void W_Hagar_Touch (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	if (other == self.owner)
		return;

	self.think ();
}

void W_Hagar_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		self.think ();
}

void W_Hagar_Attack (void)
{
	local entity missile;
	local vector org;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_primary_ammo");
	self.punchangle_x = -2;
	org = W_MuzzleOrigin (self, '18 5 -8');

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";
	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + cvar("g_balance_hagar_primary_lifetime");
	missile.solid = SOLID_BBOX;
	missile.scale = 0.4; // BUG: the model is too big
	setorigin (missile, org);
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	//missile.takedamage = DAMAGE_YES;
	//missile.damageforcescale = 4;
	//missile.health = 10;
	//missile.event_damage = W_Hagar_Damage;
	missile.effects = EF_LOWPRECISION | EF_NOSHADOW | EF_FULLBRIGHT;

	missile.movetype = MOVETYPE_FLY;
	missile.velocity = (normalize(trueaim - org) + randomvec() * cvar("g_balance_hagar_primary_spread")) * cvar("g_balance_hagar_primary_speed");

	missile.angles = vectoangles (missile.velocity);
}

void W_Hagar_Attack2 (void)
{
	local entity missile;
	local vector org;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_hagar_secondary_ammo");
	self.punchangle_x = -2;
	org = W_MuzzleOrigin (self, '18 5 -8');

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";
	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + cvar("g_balance_hagar_secondary_lifetime");
	missile.solid = SOLID_BBOX;
	missile.scale = 0.4; // BUG: the model is too big
	setorigin (missile, org);
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	//missile.takedamage = DAMAGE_YES;
	//missile.damageforcescale = 4;
	//missile.health = 10;
	//missile.event_damage = W_Hagar_Damage;
	missile.effects = EF_LOWPRECISION | EF_NOSHADOW | EF_FULLBRIGHT;

	missile.movetype = MOVETYPE_TOSS;
	missile.velocity = (v_forward + randomvec() * cvar("g_balance_hagar_secondary_spread")) * cvar("g_balance_hagar_secondary_speed") + v_up * cvar("g_balance_hagar_secondary_speed_up");
	missile.avelocity = '100 10 10';

	missile.angles = vectoangles (missile.velocity);
}

// weapon frames
void()	hagar_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, hagar_ready_01); self.weaponentity.state = WS_READY;};
void()	hagar_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	hagar_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	hagar_fire1_01 =
{
	self.attack_finished = time + cvar("g_balance_hagar_primary_refire");
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hagar_primary_refire"), hagar_ready_01);
};
void()	hagar_fire2_01 =
{
	self.attack_finished = time + cvar("g_balance_hagar_secondary_refire");
	weapon_doattack(hagar_check2, hagar_check2, W_Hagar_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hagar_secondary_refire"), hagar_ready_01);
};

