void() rlauncher_ready_01;
void() rlauncher_fire1_01;
void() rlauncher_fire2_01;
void() rlauncher_fire3_01;
void() rlauncher_deselect_01;
void() rlauncher_select_01;

float() rlauncher_check = 
{
	if (self.ammo_rockets > 0) 
		return TRUE; 
	return FALSE;
};

void(float req) w_rlauncher =
{
	if (req == WR_IDLE)
		rlauncher_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(rlauncher_check, rlauncher_check, rlauncher_fire1_01, 1.5);
	else if (req == WR_FIRE2)
		weapon_prepareattack(rlauncher_check, rlauncher_check, rlauncher_fire2_01, 1.5);
	else if (req == WR_FIRE3)
		weapon_prepareattack(rlauncher_check, rlauncher_check, rlauncher_fire3_01, 1.5);
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


void W_Rocket_Explode (entity ignore)
{
	ImpactEffect (self, IT_ROCKET_LAUNCHER);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, 130, 50, 170, ignore, 600, IT_ROCKET_LAUNCHER);

	remove (self);
}

void W_Rocket_Think (void)
{
	W_Rocket_Explode (world);
}

void W_Rocket_Touch (void)
{
	if (other == self.owner)
		return;
	else if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	else
		W_Rocket_Explode (world);
}

void W_Rocket_Damage (vector hitloc, float damage, entity inflictor, entity attacker, float deathtype)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Rocket_Explode(world);
}

void W_Rocket_Attack (void)
{
	entity	missile;
	vector	org;
	makevectors (self.v_angle);
	sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = 4;
	missile.health = 10;
	missile.event_damage = W_Rocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocketmissile.mdl");
	setsize (missile, '0 0 0', '0 0 0');

	org = self.origin + self.view_ofs + v_forward * 20 + v_right * 4 + v_up * -15;

	setorigin (missile, org);
	missile.velocity = v_forward * 850;
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch ;
	missile.think = W_Rocket_Think;
	missile.nextthink = time + 9;

	self.attack_finished = time + 1.5;

	if (!(game & GAME_ROCKET_ARENA))
		self.ammo_rockets = self.ammo_rockets - 1;
}

void W_Rocket_Attack2 (void)
{
	entity	proj;
	proj = findradius (self.origin, 50000);
	while (proj)
	{
		if (proj.classname == "missile" && proj.owner == self)
		{
			proj.nextthink = time;
		}
		proj = proj.chain;
	}

	self.attack_finished = time;
}


void W_Rocket_Attack3 (void)
{

}

// weapon frames 

void()	rlauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, rlauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	rlauncher_select_01 =	{weapon_thinkf(-1, 0.3, w_ready); weapon_boblayer1(16, '0 0 0');};
void()	rlauncher_deselect_01 =	{weapon_thinkf(-1, 0.3, w_clear); weapon_boblayer1(16, '0 20 -40');};
void()	rlauncher_fire1_01 =	
{
	weapon_doattack(rlauncher_check, rlauncher_check, W_Rocket_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, rlauncher_ready_01);
};
void()	rlauncher_fire2_01 =	
{
	weapon_doattack(rlauncher_check, rlauncher_check, W_Rocket_Attack2);
	weapon_thinkf(WFRAME_FIRE2, 0.3, rlauncher_ready_01);
};
void()	rlauncher_fire3_01 =	
{
	weapon_doattack(rlauncher_check, rlauncher_check, W_Rocket_Attack3);
	weapon_thinkf(WFRAME_FIRE2, 0.3, rlauncher_ready_01);
};