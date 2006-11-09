void SpecialShieldThink()
{
	if(!self.owner.special_active || self.owner.health <= 0)
	{
		remove(self.enemy);
		remove(self);
		return;
	}
	self.nextthink = time;

	// let tag attachment handle this
	//setorigin(self, 0.5*(self.owner.absmin + self.owner.absmax));
	//self.velocity = self.owner.velocity;

	self.alpha = 0.3 + 0.3*((self.owner.special_time - time) / cvar("g_balance_shield_duration"));
	if(self.alpha < 0.05)
		self.alpha = 0.05;

	self.enemy.alpha = self.alpha;
	self.enemy.effects = self.effects;
};

void ActivateSpecialShield(float emergency_shield)
{
	vector org;
	entity e;
	if(self.special_time > time)
	{
		return; // currently active or recharging
	}

	sprint(self, "<==Shield activated!==>\n");

	self.special_active = 1;
	if(emergency_shield)
		self.special_time = time + cvar("g_balance_shield_emergency_duration");
	else
		self.special_time = time + cvar("g_balance_shield_duration");

	e = spawn();
	e.owner = self;
	e.think = SpecialShieldThink;
	e.nextthink = time;
	e.alpha = 1;

	e.colormod_x = 255;
	e.colormod_y = 0;
	e.colormod_z = 128;
	e.colormod = e.colormod * (1/255) * 1.2;

	e.effects = EF_ADDITIVE;

	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_NOT;

	org = 0.5*(self.absmin + self.absmax) - self.origin;

	setmodel(e, "models/misc/shield_s.mdl");
	setorigin(e, org + '0 0 16');//0.5*(self.absmin + self.absmax));

	setattachment(e, self, "");

	e.enemy = spawn();
	e.enemy.owner = e;
	e.enemy.alpha = 1;
	e.enemy.colormod = e.colormod;
	setmodel(e.enemy, e.model);

	// use viewmodelforclient, since setattachment makes it invisible to the player
	e.enemy.viewmodelforclient = self;
	setorigin(e.enemy, e.origin);//'0 0 0');//0.5*(self.absmin + self.absmax));

	//setattachment(e.enemy, e, "");
	//setorigin(e.enemy, e.origin);//0.5*(self.absmin + self.absmax));
}

float SpecialShieldProtect(float damage)
{
	// check for emergency activate
	if(!self.special_active && self.special_time < time) // shield is off but ready
	{
		if(damage > self.health - 5) // this attack will be lethal or dang-well close
			ActivateSpecialShield(TRUE); // emergency activate for less time, but save me
	}

	if(!self.special_active || self.special_time < time) // shield is off
		return damage; // don't alter damage


	damage = damage - damage * (cvar("g_balance_shield_protection") / 100);
	if(damage < 0)
		damage = 0;
	return damage;
}

void ScoutSpecial()
{
	ActivateSpecialShield(FALSE);
}

void () FireJetFlame =
{
	local entity missile;
	local vector org;
	local vector end;

	local vector trueaim;
	org = self.origin + self.view_ofs;
	end = self.origin + self.view_ofs + v_forward * 4096;
	traceline(org,end,TRUE,self);
	trueaim = trace_endpos;

	sound (self, CHAN_WEAPON, "weapons/flamer.wav", 1, ATTN_NORM);
	self.ammo_nails = self.ammo_nails - 4;
	org = self.origin + self.view_ofs/* + v_forward * 1 + v_right * 14 + v_up * -5*/;

	missile = spawn ();
	missile.owner = self;
	missile.classname = "flame";
	missile.think = W_Flamer_Dissipate;
	missile.nextthink = time + 0.01;
	//missile.touch = W_Flamer_Touch;
	missile.solid = SOLID_BBOX;
	setorigin (missile, org);
	setmodel (missile, "models/sprites/hagarexplosion.spr32");
	setsize (missile, '0 0 0', '0 0 0');
	missile.effects = EF_LOWPRECISION | EF_ADDITIVE;
	missile.alpha = 0.7;//0.3;
	missile.scale = 0.005;//0.015;//0.15;
	missile.colormod = '1 1 1'; // set full colors, then reduce later
	missile.frame = random() * 4 + 2;

	missile.movetype = MOVETYPE_BOUNCE;
	missile.gravity = -0.07; // fall lightly up
//	missile.velocity = (v_forward + v_right * crandom() * 0.035 + v_up * crandom() * 0.015) * cvar("g_balance_flamer_speed");
	missile.velocity = normalize(trueaim - org) * 600;

	missile.angles = vectoangles (missile.velocity);
};

void ScoutGrenade(float req)
{
	if(req == WR_GRENADE1)
	{
		if (self.ammo_rockets < JETJUMP_NEEDROCKETS)
		{
			sprint(self, "You need more rockets to power the JetPack\n");
			return;
		}
		FireJetFlame();
		self.jump_pad = 1;
		self.ammo_rockets = self.ammo_rockets - JETJUMP_NEEDROCKETS;
		self.velocity = v_forward * 900 + '0 0 250' + v_up * 100;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.grenade_time = time + 2;
	}
	else if(req == WR_GRENADE2)
	{
		if(W_ThrowGrenade(W_ConcussionGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_concussion_refire");		
//		self.grenade_time = time + 2;
	}
}


void ScoutPreThink()
{
	if(self.special_time != 0 && self.special_time < time)
	{
		// the timer has run out

		// shield was active, go into recharge mode
		if(self.special_active)
		{
			self.special_active = 0;
			self.special_time = time + cvar("g_balance_shield_recharge_time");
		}
		else
		{
			self.special_time = 0; // finished recharging; ready to activate again
		}
	}
}

void ScoutPostThink()
{
}

void BecomeScout(float portion)
{
	self.max_health = cvar("g_balance_class_scout_health") * portion;

	self.max_armor = cvar("g_balance_class_scout_armor") * portion;

	self.mass = cvar("g_balance_class_scout_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(150 * portion);
	self.ammo_rockets = floor(0 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = TF_CLASS_SCOUT;		// TF P.C.
	SetMaxAmmoFor (1);
}
