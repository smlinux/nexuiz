void() electro_ready_01;
void() electro_fire1_01;
void() electro_fire2_01;
void() electro_deselect_01;
void() electro_select_01;

float() electro_check = 
{
	if (self.ammo_cells > 0) 
		return TRUE; 
	return FALSE;
};

void(float req) w_electro =
{
	if (req == WR_IDLE)
		electro_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(electro_check, electro_check, electro_fire1_01, 0.4);
	else if (req == WR_FIRE2)
		weapon_prepareattack(electro_check, electro_check, electro_fire2_01, 2);
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


void W_Electro_Touch (void)
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);		// Sajt: Yeah.. I agree with him
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);
	self.event_damage = nullfunction;
	RadiusDamage (self, self.owner, 50, 10, 70, world, 50, IT_ELECTRO);
	sound (self, CHAN_IMPACT, "weapons/plasmahit.wav", 1, ATTN_NORM);
	remove (self);
}

void() W_Electro_Attack
{
	entity	proj;
	float postion;

	postion = self.electrocount;
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/electro_fire.wav", 1, ATTN_NORM);

	proj = spawn ();
	proj.owner = self;
	proj.classname = "spike";

	proj.movetype = MOVETYPE_FLY; 
	proj.solid = SOLID_BBOX;
	proj.effects = 1;
	
	vector org;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 7 + v_up * -9;

	te_smallflash(org);

	setmodel (proj, "models/elaser.mdl");
	setsize (proj, '0 0 0', '0 0 0');
	if (postion == 0)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -14);
	if (postion == 1)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 15 + v_right * 10 + v_up * -12);
	if (postion == 2)
	setorigin (proj, self.origin + self.view_ofs + v_forward * 15 + v_right * 15 + v_up * -14);

	proj.velocity = v_forward * 9999;
	proj.touch = W_Electro_Touch;
	proj.think = SUB_Remove;
	proj.nextthink = time + 1.5;

	proj.angles = vectoangles (proj.velocity);

	proj.effects = proj.effects | EF_ADDITIVE;

	self.attack_finished = time + 0.4;
	self.ammo_cells = self.ammo_cells - 1;
}

void W_Plasma_Explode (entity ignore)
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

	te_customflash (self.origin, 5000, 10, '0 0 1');

	self.event_damage = nullfunction;
	RadiusDamage (self, self.owner, 100, 50, 100, world, 50, IT_ELECTRO);
	sound (self, CHAN_IMPACT, "weapons/plasmahit.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Plasma_Explode2 (entity ignore)
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

	te_customflash (self.origin, 5000, 10, '0 0 1');

	self.event_damage = nullfunction;
	RadiusDamage (self, self.owner, 150, 50, 150, world, 150, IT_ELECTRO);
	sound (self, CHAN_IMPACT, "weapons/plasmahit.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Plasma_FuseExplode (void)
{
	W_Plasma_Explode2 (world);
}

void W_Plasma_Touch (void)
{
	if (other.classname == "player" || other.classname == "corpse")
		W_Plasma_Explode (other);
	else
		sound (self, CHAN_BODY, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
}

void W_Plasma_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Plasma_FuseExplode ();
}

void() W_Electro_Attack2
{
	entity	Plasma;
	float postion;

	postion = self.electrocount;
	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/electro_fire.wav", 1, ATTN_NORM);

	self.punchangle_x = -4;

	Plasma = spawn ();
	Plasma.owner = self;
	Plasma.classname = "grenade";
	Plasma.effects = 1;

	Plasma.movetype = MOVETYPE_BOUNCE;
	Plasma.solid = SOLID_BBOX;
	
	vector org;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 7 + v_up * -9;
	te_smallflash(org);

	Plasma.takedamage = DAMAGE_YES;
	Plasma.damageforcescale = 4;
	Plasma.health = 5;
	Plasma.event_damage = W_Plasma_Damage;

	setmodel (Plasma, "models/ebomb.mdl");
	setsize (Plasma, '-6 -6 -3', '6 6 3');

	if (postion == 0)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -14);
	if (postion == 1)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 15 + v_right * 10 + v_up * -12);
	if (postion == 2)
	setorigin (Plasma, self.origin + self.view_ofs + v_forward * 15 + v_right * 15 + v_up * -14);

	Plasma.velocity = v_forward * 900 + v_up * 200;
	Plasma.angles = vectoangles (Plasma.velocity);
	Plasma.avelocity_y = random () * -500 - 500;
	Plasma.avelocity_x = random () * -500 - 500;
	Plasma.avelocity_z = random () * -500 - 500;

	Plasma.touch = W_Plasma_Touch;
	Plasma.think = W_Plasma_FuseExplode;
	Plasma.nextthink = time + 2;

	Plasma.effects = Plasma.effects | EF_ADDITIVE;

	self.attack_finished = time + 1;
	self.ammo_cells = self.ammo_cells - 2;

}

// weapon frames 

void()	electro_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, electro_ready_01); self.weaponentity.state = WS_READY;};
void()	electro_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	electro_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	electro_fire1_01 =	
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack);
	
	self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;

	weapon_thinkf(WFRAME_FIRE1, 0.3, electro_ready_01);
};
void()	electro_fire2_01 =	
{
	weapon_doattack(electro_check, electro_check, W_Electro_Attack2);

	self.electrocount = self.electrocount + 1;
		if (self.electrocount == 3)
			self.electrocount = 0;

	weapon_thinkf(WFRAME_FIRE2, 0.3, electro_ready_01);
};
