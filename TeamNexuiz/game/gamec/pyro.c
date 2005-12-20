

void W_NapalmGlob_Think (void)
{
	if(self.wait < time)
	{
		remove(self);
		return;
	}
	self.nextthink = time + cvar("g_balance_napalm_glob_damagerate");

	RadiusDamage (self, self.owner, cvar("g_balance_napalm_glob_damage"), cvar("g_balance_napalm_glob_edgedamage"), cvar("g_balance_napalm_glob_radius"), world, cvar("g_balance_napalm_glob_force"), WEP_PYRO_SPECIAL);
}

void W_NapalmGlob_Touch (void)
{
	if(self.count)
		return;

	self.movetype = MOVETYPE_NONE;

	self.count = 1;
}

void W_NapalmSpitGlob(vector org, vector vel)
{
	entity gren;

	gren = spawn ();
	gren.owner = self.owner;
	gren.classname = "napalm";
	gren.movetype = MOVETYPE_TOSS;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/plasma.mdl");
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, org);

	gren.nextthink = time + 0.1;
	gren.think = W_NapalmGlob_Think;
	gren.touch = W_NapalmGlob_Touch;
	gren.wait = time + cvar("g_balance_napalm_glob_duration");
	gren.gravity = cvar("g_balance_napalm_glob_gravity");
	gren.velocity = vel;
	gren.avelocity = '100 150 100';
	gren.count = 0;

	gren.angles = vectoangles (gren.velocity);

	gren.scale = 5;
	gren.colormod = '5 0 0';
	//gren.glow_size = cvar("g_balance_napalm_glob_radius");	// glow at damage radius
	//gren.glow_color = 236;//250; // red
}

void W_Napalm_Explode (void)
{
	vector	org2, vel, vel2, vels, ang;
	float num, angsize;

	setsize(self, '0 0 0', '0 0 0');

	org2 = findbetterlocation (self.origin);
	//te_explosion (org2);
	//effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
	sound (self, CHAN_BODY, "misc/gib.wav", 1, ATTN_NORM);

//	RadiusDamage (self, self.owner, cvar("g_balance_napalm_damage"), cvar("g_balance_napalm_edgedamage"), cvar("g_balance_napalm_radius"), world, cvar("g_balance_napalm_force"), WEP_PYRO_SPECIAL);

	traceline(org2, org2 - '0 0 30', TRUE, self);
	if(trace_fraction < 1)
		vels = '0 0 1';
	else
		vels = '0 0 -1';

	num = cvar("g_balance_napalm_numglobs");
	angsize = 360 / (num - 1);
	ang_y = self.angles_y;
	while(num > 0)
	{
		if(num == 1)
		{
			vel = '0 0 0';
		}
		else
		{
			ang_y = ang_y + angsize;
			makevectors(ang);
			vel_x = v_forward_x;
			vel_y = v_forward_y;
			//vel_x = vels_x + crandom()*0.8;
			//vel_y = vels_y + crandom()*0.8;
		}
		vel2_z = vels_z + crandom()*0.8;
		vel = normalize(vel);
		vel2 = normalize(vel2);
		W_NapalmSpitGlob(org2, vel*cvar("g_balance_napalm_glob_speedh") + vel2*cvar("g_balance_napalm_glob_speedv"));
		num = num - 1;
	}

	remove (self);
}

void PyroSpecial()
{
	if(self.special_time > time)
		return;
	self.special_time = time + cvar("g_balance_napalm_firerate");

	local entity gren;
	local vector org;

	sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/plasma.mdl");
	setsize(gren, '-6 -6 -3', '6 6 3');
	setorigin(gren, org);

	gren.nextthink = time + 5;
	gren.think = W_Napalm_Explode;
	gren.touch = W_Napalm_Explode;
	gren.velocity = v_forward * cvar("g_balance_napalm_speed")
		+ v_up * cvar("g_balance_napalm_speed_up");
	gren.avelocity = '100 150 100';

	gren.angles = vectoangles (gren.velocity);

	gren.scale = 8;
	gren.colormod = '5 0 0';
}


void PyroGrenade(float req)
{
	if(req == WR_GRENADE1)
	{
		if(W_ThrowGrenade(W_ConcussionGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_concussion_refire");
	}
	else if(req == WR_GRENADE2)
	{
		if(W_ThrowGrenade(W_Firebomb))
			self.grenade_time = time + cvar("g_balance_grenade_firebomb_refire");
	}
}

void PyroPreThink()
{
}

void PyroPostThink()
{
}

void BecomePyro(float portion)
{
	self.max_health = cvar("g_balance_class_pyro_health") * portion;

	self.max_armor = cvar("g_balance_class_pyro_armor") * portion;

	self.mass = cvar("g_balance_class_pyro_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;//w_getbestweapon(self);
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(150 * portion);
	self.ammo_rockets = floor(14 * portion);
	self.ammo_cells = floor(6 * portion);
	self.playerclass = 7;		// TF P.C.
	SetMaxAmmoFor (8);
}
