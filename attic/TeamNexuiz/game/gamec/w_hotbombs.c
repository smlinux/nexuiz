void() hotbombs_ready_01;
void() hotbombs_fire1_01;
void() hotbombs_fire2_01;
void() hotbombs_deselect_01;
void() hotbombs_select_01;

float	AMMO_COST_HOTBOMBS = 5;

float() hotbombs_check =
{
	return TRUE;
}

float() hotbombs_check2 =
{
	if (self.ammo_cells >= AMMO_COST_HOTBOMBS)
		return TRUE;
	return FALSE;
}

void(float req) w_hotbombs =
{
	if (req == WR_IDLE)
		hotbombs_ready_01();
	else if (req == WR_FIRE1 || req == WR_FIRE2)
	{
		if(req == WR_FIRE2)
			weapon_prepareattack(hotbombs_check, hotbombs_check, hotbombs_fire2_01, cvar("g_balance_hotbombs_refire"));
		else
			weapon_prepareattack(hotbombs_check, hotbombs_check, hotbombs_fire1_01, cvar("g_balance_hotbombs_refire2"));
	}
	else if (req == WR_RAISE)
		hotbombs_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = floor(self.ammo_cells/AMMO_COST_HOTBOMBS);
	else if (req == WR_DROP)
		hotbombs_deselect_01();
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_BOMBLETTS, "w_hotbombs.zym", IT_ROCKETS);
		//self.weaponentity.colormod = '0 4 0';
		//self.weaponentity.scale = 0.65;
	}
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = hotbombs_check();
}

void W_Hotbomb_Explode (void)
{
	vector	org2;
	entity head;

	float flametime, flamedmg, flamerate, flameedge, flameradius, distratio;

	flameradius =	cvar("g_balance_hotbombs_burnradius");
	flamedmg =		cvar("g_balance_hotbombs_burndamage");
	flamerate =		cvar("g_balance_hotbombs_burnrate");
	flametime =		cvar("g_balance_hotbombs_burntime");
	flameedge =		cvar("g_balance_hotbombs_burnedge_ratio");

	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	if(random() > 0.5)
	{
		effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
		sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);
	}
	else
	{
		effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);
		sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);
	}


	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hotbombs_damage"), cvar("g_balance_hotbombs_edgedamage"), cvar("g_balance_hotbombs_radius"), world, cvar("g_balance_hotbombs_force"), WEP_HOTBOMBS);

	// fixme: need better way to set on fire...
	head = findradius(self.origin, flameradius);
	while(head)
	{
		if(head.takedamage == DAMAGE_AIM)//head.classname == "player" || head.classname == "turret")
		{
			traceline(self.origin, head.origin, TRUE, self);
			if(trace_fraction >= 1)
			{
				distratio = 1 - (vlen(head.origin - self.origin) / flameradius);
				IgniteTarget(head, self.owner,
					(flametime*flameedge) + (flametime - flameedge)*distratio,
					flamedmg,
					flamerate,
					TRUE);
			}
		}
		head = head.chain;
	}

	
	remove (self);
}

void W_Hotbomb_Detonate (entity gren)
{
	gren.classname = "hotbombdet";
	gren.takedamage = 0;
	gren.think = W_Hotbomb_Explode;
	gren.nextthink = time + random()*0.1;
	gren.movetype = MOVETYPE_TOSS;
}

void W_HotbombThink ()
{
	self.nextthink = time + 1;
	if(self.owner.class != CLASS_PYRO)
	{
		remove(self);
		return;
	}
	if(self.movetype == MOVETYPE_WALK)
	{
		if(!self.flags & FL_ONGROUND)
		{
			self.movetype = MOVETYPE_TOSS;
			//self.think = SUB_Null;
			//self.nextthink = -1;
		}

		self.velocity = self.velocity*0.9;

		if(vlen(self.velocity) < 25)
		{
			self.velocity = '0 0 0';
			self.movetype = MOVETYPE_TOSS;
			self.ltime = time + 0.5; // don't bounce or start over on accident
		}
		else
			self.nextthink = time + 0.1;
	}
}

void W_Hotbombs_Touch (void)
{
	if(self.think != W_HotbombThink)
	{
		if(self.ltime > time)
			return;
		sound (self, CHAN_IMPACT, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
		if(self.flags & FL_ONGROUND)
		{
			self.movetype = MOVETYPE_WALK;
			self.think = W_HotbombThink;
			self.nextthink = time + 0.1;
		}
	}
}

void W_Hotbombs_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0 || deathtype == DEATH_BURNING)
	{
		W_Hotbomb_Detonate(self);
		//self.think = W_Hotbombs_Explode;
		//self.nextthink = time + random()*0.1;
		//self.takedamage = 0;
		//self.classname = "hotbombdet";
		//self.movetype = MOVETYPE_TOSS;
	}
}

void W_Hotbombs_Attack (void)
{
	local entity gren;
	local vector org;

	// only allow a limited number of hotbombs
	W_LimitNumEnts("hotbomb", cvar("g_balance_hotbombs_allowed") - 1, SUB_Remove);


	//sound (self, CHAN_WEAPON, "weapons/grenade_fire.wav", 1, ATTN_NORM);
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 5 + v_up * -12;
	self.ammo_cells = self.ammo_cells - AMMO_COST_HOTBOMBS;

	gren = spawn ();
	gren.create_time = time; // for W_LimitNumEnts
	gren.owner = self;
	gren.classname = "hotbomb";
	gren.movetype = MOVETYPE_WALK;
	gren.solid = SOLID_BBOX;
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '-6 -6 -3', '6 6 3');
	setorigin(gren, org);

	gren.nextthink = time + 100;
	gren.think = W_Hotbomb_Explode;
	gren.touch = W_Hotbombs_Touch;
	gren.takedamage = DAMAGE_YES;
	gren.health = 40; // a bit harder to destroy
	gren.damageforcescale = 4;
	gren.event_damage = W_Hotbombs_Damage;
	gren.velocity = v_forward * cvar("g_balance_hotbombs_speed");

	gren.angles = vectoangles (gren.velocity);
	gren.angles_x = -90;

	gren.scale = 2;
	//gren.colormod = '0.5 0.5 0.5';
}

void W_Hotbombs_Attack2 (void)
{
	local entity gren;
	gren = world;
	do
	{
		gren = find(gren, classname, "hotbomb");
		if(gren.owner == self)
		{
			W_Hotbomb_Detonate(gren);
		}
	}while(gren);
}

float W_Hotbombs_CheckEmpty ()
{
	local entity gren;

	if(hotbombs_check2())
		return FALSE; // I still have ammo, don't auto switch

	gren = world;
	do
	{
		gren = find(gren, classname, "hotbomb");
		if(gren.owner == self)
		{
			return FALSE; // I still have a grenade I can explode, don't auto switch
		}
	}while(gren);

	self.switchweapon = w_getbestweapon(self);
	return TRUE;
}

// weapon frames

void()	hotbombs_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, hotbombs_ready_01); self.weaponentity.state = WS_READY;};
void()	hotbombs_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	hotbombs_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	hotbombs_fire1_01 =
{
	if(W_Hotbombs_CheckEmpty())
		return; // auto-switch weapons and leave
	if(!hotbombs_check2())
		return; // can't use primary, but alt-fire will still work
	weapon_doattack(hotbombs_check, hotbombs_check, W_Hotbombs_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, hotbombs_ready_01);
};

void()	hotbombs_fire2_01 =
{
	if(W_Hotbombs_CheckEmpty())
		return; // out of ammo and no bombs to detonate
	weapon_doattack(hotbombs_check, hotbombs_check, W_Hotbombs_Attack2);
	weapon_thinkf(WFRAME_IDLE, 0.1, hotbombs_ready_01);
};
