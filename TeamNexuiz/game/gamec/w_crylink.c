void() crylink_ready_01;
void() crylink_fire1_01;
void() crylink_deselect_01;
void() crylink_select_01;

.float gravity;

float() crylink_check =
{
	if (self.ammo_cells >= 1)
		return TRUE;
	return FALSE;
};

void(float req) w_crylink =
{
	if (req == WR_IDLE)
		crylink_ready_01();
	else if (req == WR_FIRE1 || req == WR_FIRE2)
		weapon_prepareattack(crylink_check, crylink_check, crylink_fire1_01, cvar("g_balance_crylink_refire"));
	else if (req == WR_RAISE)
		crylink_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_cells;
	else if (req == WR_DROP)
		crylink_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_CRYLINK, "w_crylink.zym", IT_CELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = crylink_check();
};


void W_Crylink_Touch (void)
{
	self.event_damage = SUB_Null;
	//te_smallflash(self.origin);
	RadiusDamage (self, self.owner, cvar("g_balance_crylink_damage"), cvar("g_balance_crylink_edgedamage"), cvar("g_balance_crylink_radius"), world, cvar("g_balance_crylink_force"), WEP_CRYLINK);
	self.touch = SUB_Null;
	setmodel (self, "models/plasma.mdl");
	setsize (self, '0 0 0', '0 0 0');
	self.gravity = 1;
	self.glow_size = 0;
	self.glow_color = 0;
	self.think = SUB_Remove;
	//self.movetype = MOVETYPE_NONE;
	self.effects = EF_LOWPRECISION;
	SUB_SetFade(self, time, 1);
	//remove (self);
}

void W_Crylink_Attack (void)
{
	local float counter;
	local vector org;
	local entity proj;
	local vector end;

	local vector trueaim;
	org = self.origin + self.view_ofs;
	end = self.origin + self.view_ofs + v_forward * 4096;
	traceline(org,end,TRUE,self);
	
	trueaim = trace_endpos;

	sound (self, CHAN_WEAPON, "weapons/crylink.ogg", 1, ATTN_NORM);
	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - 1;
	self.punchangle_x = -2;
	org = self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14;
	te_smallflash(org);

	while (counter < 5)
	{
		proj = spawn ();
		proj.owner = self;
		proj.classname = "spike";

		proj.movetype = MOVETYPE_BOUNCE;
		proj.solid = SOLID_BBOX;
		proj.gravity = 0.001;

		setmodel (proj, "models/plasmatrail.mdl");
		setsize (proj, '0 0 0', '0 0 0');
		setorigin (proj, org);

		if (self.button3)
			proj.velocity = (normalize(trueaim - org) + (counter / 2 - 1) * v_right * cvar("g_balance_crylink_spread")) * cvar("g_balance_crylink_speed");
		else
			proj.velocity = (normalize(trueaim - org) + (counter / 5) * randomvec() * cvar("g_balance_crylink_spread")) * cvar("g_balance_crylink_speed");
		proj.touch = W_Crylink_Touch;
		proj.think = SUB_Remove;
		proj.nextthink = time + 9;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.effects = proj.effects | EF_FULLBRIGHT;
		//proj.effects = proj.effects | EF_ADDITIVE;
		proj.effects = proj.effects | EF_LOWPRECISION;
		counter = counter + 1;
	}

	self.clip_crylink -= 1;
	if (self.clip_crylink <= 0)
	{
		DoReload (2, CLIP_MAX_CRYLINK);	// Crylink is weapon 2, reloads for max clip of weapon.
	}
}


// weapon frames
void()	crylink_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, crylink_ready_01); self.weaponentity.state = WS_READY;};
void()	crylink_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	crylink_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	crylink_fire1_01 =
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, crylink_ready_01);
};

