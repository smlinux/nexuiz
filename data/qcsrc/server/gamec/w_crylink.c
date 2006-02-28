void() crylink_ready_01;
void() crylink_fire1_01;
void() crylink_fire2_01;
void() crylink_deselect_01;
void() crylink_select_01;

.float gravity;
const vector proj_color = '1 1 1';

float() crylink_check =
{
	if (self.ammo_cells >= cvar("g_balance_crylink_primary_ammo"))
		return TRUE;
	return FALSE;
};

float() crylink_check2 =
{
	if (self.ammo_cells >= cvar("g_balance_crylink_secondary_ammo"))
		return TRUE;
	return FALSE;
};

void(float req) w_crylink =
{
	if (req == WR_IDLE)
		crylink_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(crylink_check, crylink_check, crylink_fire1_01, cvar("g_balance_crylink_primary_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(crylink_check2, crylink_check2, crylink_fire2_01, cvar("g_balance_crylink_secondary_refire"));
	else if (req == WR_RAISE)
		crylink_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_cells;
	else if (req == WR_DROP)
		crylink_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_CRYLINK, "w_crylink.zym", IT_CELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = crylink_check() + crylink_check2();
};

.entity realowner;
void W_Crylink_Touch (void)
{
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_primary_damage"), cvar("g_balance_crylink_primary_edgedamage"), cvar("g_balance_crylink_primary_radius"), world, cvar("g_balance_crylink_primary_force"), IT_CRYLINK);
	//te_smallflash(self.origin);
	if (other.takedamage == DAMAGE_AIM)
	{
		remove (self);
		return;
	}
	self.owner = world;
	self.touch = SUB_Null;
	setmodel (self, "models/plasma.mdl");
	setsize (self, '0 0 0', '0 0 0');
	self.gravity = 0;
	self.glow_size = 0;
	self.glow_color = 0;
	self.think = SUB_Remove;
	self.movetype = MOVETYPE_NONE;
	self.effects = EF_FULLBRIGHT | EF_LOWPRECISION;
	SUB_SetFade(self, time, 1);
	//remove (self);
}

void W_Crylink_Touch2 (void)
{
	RadiusDamage (self, self.realowner, cvar("g_balance_crylink_secondary_damage"), cvar("g_balance_crylink_secondary_edgedamage"), cvar("g_balance_crylink_secondary_radius"), world, cvar("g_balance_crylink_secondary_force"), IT_CRYLINK);
	//te_smallflash(self.origin);
	if (other.takedamage == DAMAGE_AIM)
	{
		remove (self);
		return;
	}
	self.owner = world;
	self.touch = SUB_Null;
	setmodel (self, "models/plasma.mdl");
	setsize (self, '0 0 0', '0 0 0');
	self.gravity = 0;
	self.glow_size = 0;
	self.glow_color = 0;
	self.think = SUB_Remove;
	self.movetype = MOVETYPE_NONE;
	self.effects = EF_FULLBRIGHT | EF_LOWPRECISION;
	SUB_SetFade(self, time, 1);
	//remove (self);
}

void W_Crylink_Attack (void)
{
	local float counter, shots;
	local vector org;
	local entity proj;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/crylink_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_primary_ammo");
	self.punchangle_x = -2;
	org = self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14;
	te_smallflash(org);

	shots = cvar("g_balance_crylink_primary_shots");
	while (counter < shots)
	{
		proj = spawn ();
		proj.realowner = proj.owner = self;
		proj.classname = "spike";

		proj.movetype = MOVETYPE_BOUNCE;
		proj.solid = SOLID_BBOX;
		proj.gravity = 0.001;

		setmodel (proj, "models/plasmatrail.mdl");
		setsize (proj, '0 0 0', '0 0 0');
		setorigin (proj, org);

		proj.velocity = (normalize(trueaim - org) + randomvec() * cvar("g_balance_crylink_primary_spread")) * cvar("g_balance_crylink_primary_speed");
		proj.touch = W_Crylink_Touch;
		proj.think = SUB_Remove;
		proj.nextthink = time + cvar("g_balance_crylink_primary_lifetime");

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.effects = EF_NOSHADOW | EF_FULLBRIGHT | EF_LOWPRECISION;
		proj.colormod = proj_color;
		counter = counter + 1;
	}
}

void W_Crylink_Attack2 (void)
{
	local float counter, shots;
	local vector org;
	local entity proj;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/crylink_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_secondary_ammo");
	self.punchangle_x = -2;
	org = self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14;
	te_smallflash(org);

	shots = cvar("g_balance_crylink_secondary_shots");
	while (counter < shots)
	{
		proj = spawn ();
		proj.realowner = proj.owner = self;
		proj.classname = "spike";

		proj.movetype = MOVETYPE_BOUNCE;
		proj.solid = SOLID_BBOX;
		proj.gravity = 0.001;

		setmodel (proj, "models/plasmatrail.mdl");
		setsize (proj, '0 0 0', '0 0 0');
		setorigin (proj, org);

		proj.velocity = (normalize(trueaim - org) + ((counter / shots) * 2 - 1) * v_right * cvar("g_balance_crylink_secondary_spread")) * cvar("g_balance_crylink_secondary_speed");
		proj.touch = W_Crylink_Touch2;
		proj.think = SUB_Remove;
		proj.nextthink = time + cvar("g_balance_crylink_secondary_lifetime");

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.effects = EF_NOSHADOW | EF_FULLBRIGHT | EF_LOWPRECISION;
		proj.colormod = proj_color;
		counter = counter + 1;
	}
}


// weapon frames
void()	crylink_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, crylink_ready_01); self.weaponentity.state = WS_READY;};
void()	crylink_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	crylink_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	crylink_fire1_01 =
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_crylink_primary_animtime"), crylink_ready_01);
};
void()	crylink_fire2_01 =
{
	weapon_doattack(crylink_check2, crylink_check2, W_Crylink_Attack2);
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_crylink_secondary_animtime"), crylink_ready_01);
};

/*
// experimental lightning gun
void W_Crylink_Attack3 (void)
{
	local vector org, dir;

	local vector trueaim;
	trueaim = W_TrueAim();

	sound (self, CHAN_WEAPON, "weapons/crylink_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_crylink_primary_ammo");
	//self.punchangle_x = -2;
	org = self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14;

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	dir = normalize(trueaim - org);
	traceline_hitcorpse(self, org, org + dir * 1000, FALSE, self);

	te_smallflash(org);
	te_plasmaburn(trace_endpos);
	te_lightning2(self, org, trace_endpos);

	if (trace_fraction < 1)
		Damage(trace_ent, self, self, cvar("g_balance_crylink_primary_damage"), IT_CRYLINK, trace_endpos, '0 0 0');
}
void()	crylink_fire1_01 =
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack3);
	if (self.button0)
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_crylink_primary_animtime"), crylink_fire1_01);
	else
		weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_crylink_primary_animtime"), crylink_ready_01);
};
*/

