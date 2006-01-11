void W_RicochetRocket_Explode ();

void W_RicochetRocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		other = self;
		W_RicochetRocket_Explode();
	}
}

entity W_Launch_RicochetRocket (vector org, vector vel, float rocket_grav, float num, float totalbounces)
{
	local entity gren;

	gren = spawn ();
	gren.classname = "rocket";
	gren.solid = SOLID_BBOX;
	gren.movetype = MOVETYPE_BOUNCEMISSILE;
	gren.gravity = rocket_grav;//0.01;
	setmodel(gren, "models/rocket.md3");
	if(self.classname == "player")
	{
		gren.owner = self;
		setsize(gren, '-6 -6 -3', '6 6 3');
	}
	else
	{
		gren.owner = self.owner;
		setsize(gren, '0 0 0', '0 0 0');
	}
	setorigin(gren, org);

	gren.cnt = num;				// what # this one is
	gren.count = totalbounces;	// how many missiles this missile splits into

	gren.nextthink = time + 10;
	gren.think = W_RicochetRocket_Explode;
	gren.touch = W_RicochetRocket_Explode;
	gren.velocity = vel;
	gren.angles = vectoangles (gren.velocity);

	gren.colormod = 2 * '1 1 0';

	return gren;
}

// bounce off the wall, then become volatile
void W_RicochetRocket_NullTouch ()
{
	self.delay = self.delay - 1;
	if(self.delay <= 0)
		self.touch = SUB_Null;

	//self.touch = W_RicochetRocket_Explode;
	//self.think = self.touch;
	//self.nextthink = time + 10;
	//self.angles = vectoangles(self.velocity);
}

void W_RicochetRocket_Update ()
{
	self.angles = vectoangles(self.velocity);
	if(self.wait < time && self.delay <= 0)
	{
		self.touch = W_RicochetRocket_Explode;
		self.think = W_RicochetRocket_Explode;
		self.nextthink = time + 10;
	}
	else
	{
		self.think = W_RicochetRocket_Update;
		self.nextthink = time + 0.1;
	}
}

void W_RicochetRocket_Explode ()
{
	vector	org2, vel, dir;
	float num, spread, bouncecount;
	string rocketid;
	entity e;

	if(other != self && other.classname == self.classname)
	{
		self.angles = vectoangles(self.velocity);
		return; // don't touch other ricochet rockets
	}

	if(self.cnt <= 1)
	{
		rocketid = "";
	}
	else
		rocketid = ftos(self.cnt);

	spread = cvar(strcat("g_balance_ricochet_spread",rocketid));

	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);
	sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar(strcat("g_balance_ricochet_damage",rocketid)), cvar(strcat("g_balance_ricochet_edgedamage",rocketid)), cvar(strcat("g_balance_ricochet_radius",rocketid)), world, cvar(strcat("g_balance_ricochet_force",rocketid)), WEP_SOLDIER_SPECIAL);

	bouncecount = cvar("g_balance_ricochet_bouncecount");

	if(self.cnt >= bouncecount)
	{
		// don't spawn more rockets
		remove(self);
		return;
	}

	self.solid = SOLID_NOT;

	self.cnt = self.cnt + 1;

	if(self.cnt <= 1)
	{
		rocketid = "";
	}
	else
		rocketid = ftos(self.cnt);

	//bprint("Rocket", ftos(self.cnt-1));
	//bprint(" splits ", ftos(self.count), "times\n");

	num = self.count;
	dir = normalize(self.velocity);
	while(num)
	{
		vel_x = dir_x + crandom()*spread;
		vel_y = dir_y + crandom()*spread;
		vel_z = dir_z + crandom()*spread;
		vel = normalize(vel) * cvar(strcat("g_balance_ricochet_speed",rocketid));
		e = W_Launch_RicochetRocket(org2, vel, 
			cvar(strcat("g_balance_ricochet_gravity",rocketid)), 
			self.cnt, cvar(strcat("g_balance_ricochet_splitcount",rocketid)) );
		//if(other != self) // touched something else, not detonated by damage
		{
			// going to hit the same thing that detonated this rocket;
			// avoid that by bouncing off before setting an explosion touch
			e.touch = W_RicochetRocket_NullTouch;
			e.delay = cvar("g_balance_ricochet_nulltouches");
			e.wait = time + cvar("g_balance_ricochet_nulltime");
			e.think = W_RicochetRocket_Update;
			e.nextthink = time + 0.1;//4;
		}
		e.scale = 0.3 + 0.4*(1 - (self.cnt / bouncecount));
		num = num - 1;
	}

	remove (self);
}

void SoldierSpecial()
{
	entity e;
	if(self.special_time > time)
		return;
	self.special_time = time + cvar("g_balance_ricochet_firerate");

	local vector org;

	sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;
	e = W_Launch_RicochetRocket(org, v_forward * cvar("g_balance_ricochet_speed"), cvar("g_balance_ricochet_gravity"), 1, cvar("g_balance_ricochet_splitcount"));
	// first rocket takes damage, others don't
	e.takedamage = DAMAGE_YES;
	e.damageforcescale = 4;
	e.health = 30;
	e.event_damage = W_RicochetRocket_Damage;
}



void SoldierGrenade(float req)
{
	if(req == WR_GRENADE1)
	{
		if(W_ThrowGrenade(W_MirvGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_mirv_refire");
	}
	else if(req == WR_GRENADE2)
	{
		if(W_ThrowGrenade(W_FragGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_frag_refire");
	}
}

void SoldierPreThink()
{
}

void SoldierPostThink()
{
}

void BecomeSoldier(float portion)
{
	self.max_health = cvar("g_balance_class_soldier_health") * portion;

	self.max_armor = cvar("g_balance_class_soldier_armor") * portion;

	self.mass = cvar("g_balance_class_soldier_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP3;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(150 * portion);
	self.ammo_rockets = floor(12 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = TF_CLASS_SOLDIER;		// TF P.C.
	SetMaxAmmoFor (CLASS_SOLDIER);
}
