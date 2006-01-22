void() pistol_ready_01;
void() pistol_fire1_01;
void() pistol_fire2_01;
void() pistol_deselect_01;
void() pistol_select_01;

float() pistol_check =
{
	if (self.ammo_shells >= 1)
		return TRUE;
	return FALSE;
};

void(float req) w_pistol =
{
	if (self.next_pistol_fire > time)
		return;
	if (req == WR_IDLE)
		pistol_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(pistol_check, pistol_check, pistol_fire1_01, cvar("g_balance_pistol_refire"));
	else if (req == WR_FIRE2)
		stuffcmd(self, "reload\n");
	else if (req == WR_RAISE)
		pistol_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_shells;
	else if (req == WR_DROP)
		pistol_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_PISTOL, "w_soldpistol.zym", IT_SHELLS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = pistol_check();
};

void W_Pistol_Attack (void)
{
	local vector org;
	float	sc;
	float	bullets;
	float	d;
	float	spread;

	local vector end;
	local vector trueaim;
	org = self.origin + self.view_ofs;
	end = self.origin + self.view_ofs + v_forward * 4096;
	traceline(org,end,TRUE,self);
	
	trueaim = trace_endpos;

	sound (self, CHAN_WEAPON, "weapons/pistol_fire.wav", 1, ATTN_NORM);
	bullets = cvar("g_balance_pistol_bullets");

	d = cvar("g_balance_pistol_damage");

	org = self.origin + self.view_ofs + (v_right * 1) - (v_up * 1) + (v_forward * 25);
	spread = cvar("g_balance_pistol_spread");
	for (sc = 0;sc < bullets;sc = sc + 1)
//		fireBullet (org, v_forward, spread, d, IT_PISTOL, sc < 3);
		fireBullet (org, normalize(trueaim - org), spread, d, WEP_PISTOL, sc < 3);
	if (cvar("g_use_ammunition"))
		self.ammo_shells = self.ammo_shells - 1;

/*		local entity e;
		e = spawn();
		e.owner = self;
		e.movetype = MOVETYPE_FLY;
		e.solid = SOLID_NOT;
		e.think = SUB_Remove;
		e.nextthink = time + vlen(trace_endpos - self.origin) / 6000;
		e.velocity = v_forward * 1000;
		e.angles = vectoangles (v_forward);
		e.scale = .3;
//		soonmodel (e, "models/tracer.mdl", .1);
		setmodel (e, "models/tracer.mdl");
		setsize (e, '0 0 0', '0 0 0');
		setorigin (e, org);
		e.effects = e.effects | EF_ADDITIVE;*/


	// casing code
	if (cvar("g_casings") >= 1)
	{
		org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 10);
		SpawnCasing (org, ((random () * 50 + 50) * v_right) - ((random () * 25 + 25) * v_forward) - ((random () * 5 + 10) * v_up), 2, v_forward,'0 250 0', 100, 1);
	}

	org = self.origin + self.view_ofs + (v_right * 6) - (v_up * 8) + (v_forward * 20);
	//W_Smoke(org, v_forward, 12);
	//te_smallflash(org);

	self.punchangle_x = -1;

	self.clip_pistol = self.clip_pistol - 1;
	if (self.clip_pistol <= 0)
	{
		DoReload (1, CLIP_MAX_PISTOL);	// weapon type 1 is pistol
	}
}
// weapon frames

void()	pistol_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, pistol_ready_01); self.weaponentity.state = WS_READY;};
void()	pistol_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	pistol_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	pistol_fire1_01 =
{
	self.pistol_fired = 1;
	weapon_doattack(pistol_check, pistol_check, W_Pistol_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_pistol_refire2"), pistol_ready_01);
};
void()  pistol_fire2_03 =
{
	weapon_doattack(pistol_check, pistol_check, W_Pistol_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_pistol_refire2"), pistol_ready_01);
}
void()  pistol_fire2_02 =
{
	weapon_doattack(pistol_check, pistol_check, W_Pistol_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_pistol_refire2"), pistol_fire2_03);
}
void()  pistol_fire2_01 =
{
	weapon_doattack(pistol_check, pistol_check, W_Pistol_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_pistol_refire2"), pistol_fire2_02);
}