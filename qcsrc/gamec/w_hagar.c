void() hagar_ready_01;
void() hagar_fire1_01;
void() hagar_fire2_01;
void() hagar_fire3_01;
void() hagar_deselect_01;
void() hagar_select_01;

float() hagar_check = 
{
	if (self.ammo_rockets > 0) 
		return TRUE; 
	return FALSE;
};

void(float req) w_hagar =
{
	if (req == WR_IDLE)
		hagar_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire1_01, 0.2);
	else if (req == WR_FIRE2)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire2_01, 0.2);
	else if (req == WR_FIRE3)
		weapon_prepareattack(hagar_check, hagar_check, hagar_fire3_01, 0);
	else if (req == WR_RAISE)
		hagar_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		hagar_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_HAGAR, "w_hagar.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = hagar_check();
};		 

void W_Hagar_Explode (void)
{
	ImpactEffect (self, IT_HAGAR);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 40, 15, 70, world, 100, IT_HAGAR);

	remove (self);
}

void W_Hagar_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}

	W_Hagar_Explode ();
}

void W_Hagar_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Hagar_Explode();
}

void W_Hagar_Attack (void)
{
	entity	missile;

	makevectors(self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Hagar_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 2000;
	missile.velocity = missile.velocity + v_right * ( crandom() * 70 );
	missile.velocity = missile.velocity + v_up * ( crandom() * 30 );
	missile.angles = vectoangles (missile.velocity);
	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + 10;

	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Hagar_Attack2 (void)
{
	entity	missile;

	sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);

	makevectors(self.v_angle);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 5;
	missile.event_damage = W_Hagar_Damage;

	setmodel (missile, "models/hagarmissile.mdl");
	setsize (missile, '-6 -6 -3', '6 6 3');

	setorigin (missile, self.origin + self.view_ofs + v_forward * 18 + v_right * 5 + v_up * -12);

	missile.velocity = v_forward * 1400 + v_up * 100;
	missile.angles = vectoangles (missile.velocity);
	missile.avelocity = '100 10 10';

	missile.touch = W_Hagar_Touch;
	missile.think = W_Hagar_Explode;
	missile.nextthink = time + 10;

	self.attack_finished = time + 0.2;
	self.ammo_rockets = self.ammo_rockets - 0.25;
}

void W_Hagar_Attack3 (void)
{
	entity	proj;
	makevectors(self.v_angle);
	proj = findradius (self.origin, 50000);
	while (proj)
	{
		if (proj.classname == "missile" && proj.owner == self)
		{
			proj.velocity = proj.velocity - v_up * 500;
			proj.velocity = proj.velocity - v_forward * 1000;
		}
		proj = proj.chain;
	}

	self.attack_finished = time;
}


// weapon frames 
void()	hagar_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, hagar_ready_01); self.weaponentity.state = WS_READY;};
void()	hagar_select_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	hagar_deselect_01 =	{weapon_thinkf(-1, PLAYER_WEAPONSELECTION_DELAY, w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	hagar_fire1_01 =	
{
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.15, hagar_ready_01);
};
void()	hagar_fire2_01 =	
{
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.15, hagar_ready_01);
};
void()	hagar_fire3_01 =	
{
	weapon_doattack(hagar_check, hagar_check, W_Hagar_Attack3);
	weapon_thinkf(WFRAME_FIRE2, 0.15, hagar_ready_01);
};

