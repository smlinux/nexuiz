void() crylink_ready_01;
void() crylink_fire1_01;
void() crylink_fire2_01;
void() crylink_deselect_01;
void() crylink_select_01;

float() crylink_check = 
{
	if (self.ammo_cells > 0) 
		return TRUE; 
	return FALSE;
};

void(float req) w_crylink =
{
	if (req == WR_IDLE)
		crylink_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(crylink_check, crylink_check, crylink_fire1_01, 0.2);
	else if (req == WR_FIRE2)
		weapon_prepareattack(crylink_check, crylink_check, crylink_fire2_01, 0.2);
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
	te_smallflash(self.origin);
	RadiusDamage (self, self.owner, 45, 0, 3, world, 55, IT_CRYLINK);
	remove (self);
}

void W_Crylink_Attack (void) //(float postion)
{
	entity	proj;

	sound (self, CHAN_WEAPON, "weapons/crylink2.wav", 1, ATTN_NORM);
	
	makevectors(self.v_angle);
	proj = spawn ();
	proj.owner = self;
	proj.classname = "spike";

	proj.movetype = MOVETYPE_FLY; 
	proj.solid = SOLID_BBOX;
	
	setmodel (proj, "models/plasma.mdl");
	setsize (proj, '0 0 0', '0 0 0');
	setorigin (proj, self.origin + self.view_ofs + v_forward * 10 + v_right * 5 + v_up * -14);

	proj.velocity = v_forward * 4000;
	proj.velocity = proj.velocity + v_right * ( crandom() * 50 );
	proj.velocity = proj.velocity + v_up * ( crandom() * 50 );
	proj.touch = W_Crylink_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 9;

	proj.glow_color = 10;
	proj.glow_size = 30;

	proj.effects = proj.effects | EF_ADDITIVE;

	self.attack_finished = time + 0.20;
	self.ammo_cells = self.ammo_cells - 0.2;
}

void W_Crylink_Attack2 (void)
{


}


// weapon frames 
void()	crylink_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, crylink_ready_01); self.weaponentity.state = WS_READY;};
void()	crylink_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	crylink_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	crylink_fire1_01 =	
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, crylink_ready_01);
};
void()	crylink_fire2_01 =	
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, crylink_ready_01);
};
void()	crylink_fire3_01 =	
{
	weapon_doattack(crylink_check, crylink_check, W_Crylink_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, crylink_ready_01);
};

