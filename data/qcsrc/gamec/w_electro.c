void() electro_ready_01;
void() electro_fire1_01;
void() electro_fire2_01;
void() electro_deselect_01;
void() electro_select_01;

float() electro_check =
{
	if (self.ammo_cells > 2)
		return TRUE;
	return FALSE;
};

void(float req) w_electro =
{
	if (req == WR_IDLE)
		electro_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(electro_check, electro_check, electro_fire1_01, cvar("g_balance_electro_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(electro_check, electro_check, electro_fire2_01, cvar("g_balance_electro_refire"));
	else if (req == WR_RAISE)
		electro_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_cells;
	else if (req == WR_DROP)
		electro_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_ELECTRO, "w_electro.zym", IT_CELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = electro_check();
};

void W_Plasma_Explode (void)
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);

	self.event_damage = SUB_Null;
	if (self.movetype == MOVETYPE_BOUNCE)
		RadiusDamage (self, self.owner, cvar("g_balance_electro_damage") * 0.33, cvar("g_balance_electro_edgedamage") * 0.33, cvar("g_balance_electro_radius"), world, cvar("g_balance_electro_force") * 0.33, IT_ELECTRO);
	else
		RadiusDamage (self, self.owner, cvar("g_balance_electro_damage"), cvar("g_balance_electro_edgedamage"), cvar("g_balance_electro_radius"), world, cvar("g_balance_electro_force"), IT_ELECTRO);
	sound (self, CHAN_BODY, "weapons/electro_impact.ogg", 1, ATTN_NORM);

	remove (self);
}

void W_Plasma_Explode_Combo (void) {
	float  combocoredamage;
	float  comboedgedamage;
	vector org2;
		
	combocoredamage = cvar("g_balance_electro_combo_coredamage");
	comboedgedamage = cvar("g_balance_electro_combo_edgedamage");

	org2 = findbetterlocation (self.origin);
	effect (org2, "models/sprites/electrocombo.spr32", 0, 30, 35);
	sound (self, CHAN_BODY, "weapons/electro_impact_combo.ogg", 1, ATTN_NORM);
	
	self.event_damage = SUB_Null;
	if (self.movetype == MOVETYPE_BOUNCE)
		RadiusDamage (self, self.owner, (cvar("g_balance_electro_damage") * 0.33) + combocoredamage, (cvar("g_balance_electro_edgedamage") * 0.33) + comboedgedamage, cvar("g_balance_electro_radius"), world, cvar("g_balance_electro_force") * 0.33, IT_ELECTRO);
	else
		RadiusDamage (self, self.owner, cvar("g_balance_electro_damage") + combocoredamage, cvar("g_balance_electro_edgedamage") + comboedgedamage, cvar("g_balance_electro_radius"), world, cvar("g_balance_electro_force"), IT_ELECTRO);
	//te_customflash(org2, 150, 5, '0.5 0.5 1');
	te_explosionrgb(org2, '0.5 0.5 1');
	remove (self);	
}

void W_Plasma_Check_Combo (void) {
	entity	targ;
	vector	blastorigin;	
	float   combotarget;
	float 	rad;
	rad = cvar("g_balance_electro_radius");
	blastorigin = (self.origin + (self.mins + self.maxs) * 0.5);
	targ = findradius (blastorigin, rad / 2);
	combotarget = 0;
	while (targ) {	
		if (targ != self) {
			if (world != targ) {
				if (targ.classname == "plasma") {
					combotarget = 1;
				}
			}
		}
		targ = targ.chain;
	}
	
	if (combotarget == 1) {
		self.classname = "plasma_chain";
		W_Plasma_Explode_Combo ();
	} else {
		W_Plasma_Explode ();
	}
}

void W_Plasma_Touch (void)
{
	if (other.takedamage == DAMAGE_AIM) {
		W_Plasma_Explode ();
	} else {
		sound (self, CHAN_IMPACT, "weapons/electro_bounce.ogg", 1, ATTN_NORM);
	}
}

void W_Plasma_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(inflictor.classname == "plasma_chain") {
		self.classname = "plasma_chain";
		W_Plasma_Explode_Combo ();
	} else {
		self.health = self.health - damage;
		if (self.health <= 0) {
			W_Plasma_Explode ();
		}
	}
}

void() W_Electro_Attack
{
	local entity proj;
	local vector org;
	local float postion;

	postion = self.electrocount;
	sound (self, CHAN_WEAPON, "weapons/electro_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}

	self.punchangle_x = -2;

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - 2;

	if (self.electrocount == 0)
	{
		self.electrocount = 1;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -14;
	}
	else if (self.electrocount == 1)
	{
		self.electrocount = 2;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 10 + v_up * -12;
	}
	else
	{
		self.electrocount = 0;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 15 + v_up * -14;
	}

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = self;
	proj.think = W_Plasma_Explode;
	proj.nextthink = time + 2;
	proj.solid = SOLID_BBOX;
	setorigin(proj, org);

	/*
	if (self.button3)
	{
		self.ammo_cells = self.ammo_cells - 1;
		proj.effects = EF_FULLBRIGHT;
		proj.movetype = MOVETYPE_BOUNCE;
		proj.velocity = v_forward * cvar("g_balance_electro_ballspeed") + v_up * cvar("g_balance_electro_ballspeed_up");
		proj.touch = W_Plasma_Touch;
		setmodel(proj, "models/ebomb.mdl");
		setsize(proj, '-6 -6 -3', '6 6 3');
		proj.takedamage = DAMAGE_YES;
		proj.damageforcescale = 4;
		proj.health = 5;
		proj.event_damage = W_Plasma_Damage;
	}
	else
	*/
	{
		if (cvar("g_use_ammunition"))
			self.ammo_cells = self.ammo_cells - 2;
		proj.effects = EF_BRIGHTFIELD | EF_FULLBRIGHT;
		proj.movetype = MOVETYPE_FLY;
		proj.velocity = v_forward * cvar("g_balance_electro_speed");
		proj.angles = vectoangles(proj.velocity);
		proj.touch = W_Plasma_Check_Combo;
		setmodel(proj, "models/elaser.mdl");
		setsize(proj, '0 0 0', '0 0 0');
	}
	sound (proj, CHAN_BODY, "weapons/electro_fly.wav", 1, ATTN_NORM);
}

void() W_Electro_Attack2
{
	local entity proj;
	local vector org;
	local float postion;

	postion = self.electrocount;
	sound (self, CHAN_WEAPON, "weapons/electro_fire2.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH) {
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);
	}
	
	self.punchangle_x = -2;

	if (self.electrocount == 0)
	{
		self.electrocount = 1;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -14;
	}
	else if (self.electrocount == 1)
	{
		self.electrocount = 2;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 10 + v_up * -12;
	}
	else
	{
		self.electrocount = 0;
		org = self.origin + self.view_ofs + v_forward * 15 + v_right * 15 + v_up * -14;
	}

	proj = spawn ();
	proj.classname = "plasma";
	proj.owner = self;
	proj.think = W_Plasma_Explode;
	proj.nextthink = time + 2;
	proj.solid = SOLID_BBOX;
	setorigin(proj, org);

	//if (self.button3)
	{
		if (cvar("g_use_ammunition"))
			self.ammo_cells = self.ammo_cells - 1;
		proj.effects = EF_ADDITIVE;
		proj.glow_size = 50;
		proj.glow_color = 45;
		proj.movetype = MOVETYPE_BOUNCE;
		proj.velocity = v_forward * cvar("g_balance_electro_ballspeed") + v_up * cvar("g_balance_electro_ballspeed_up");
		proj.touch = W_Plasma_Touch;
		setmodel(proj, "models/ebomb.mdl");
		setsize(proj, '-6 -6 -3', '6 6 3');
		proj.takedamage = DAMAGE_YES;
		proj.damageforcescale = 4;
		proj.health = 5;
		proj.event_damage = W_Plasma_Damage;
	}
	//else
	/*
	{
		self.ammo_cells = self.ammo_cells - 2;
		proj.effects = EF_BRIGHTFIELD | EF_FULLBRIGHT;
		proj.movetype = MOVETYPE_FLY;
		proj.velocity = v_forward * cvar("g_balance_electro_speed");
		proj.angles = vectoangles(proj.velocity);
		proj.touch = W_Plasma_Explode;
		setmodel(proj, "models/elaser.mdl");
		setsize(proj, '0 0 0', '0 0 0');
	}
	*/
	sound (proj, CHAN_BODY, "weapons/electro_fly.wav", 1, ATTN_NORM);
}

// weapon frames

void()	electro_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, electro_ready_01); self.weaponentity.state = WS_READY;};
void()	electro_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	electro_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
/*
void()	electro_fire1_01 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, electro_ready_01);
};
*/
/*
void()  electro_fire1_03 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_ready_01);
}
void()  electro_fire1_02 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_fire1_03);
}
void()  electro_fire1_01 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_fire1_02);
}
*/
void()	electro_fire1_01 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_ready_01);
};
void()  electro_fire2_03 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_ready_01);
}
void()  electro_fire2_02 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_fire2_03);
}
void()  electro_fire2_01 =
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack2);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_refire3"), electro_fire2_02);
}
