void() rincendiary_ready_01;
void() rincendiary_fire1_01;
void() rincendiary_deselect_01;
void() rincendiary_select_01;

float() rincendiary_check =
{
	if (self.ammo_rockets >= 5)
		return TRUE;
	return FALSE;
};

void(float req) w_rincendiary =
{
	if (req == WR_IDLE)
		rincendiary_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(rincendiary_check, rincendiary_check, rincendiary_fire1_01, cvar("g_balance_incendiaryrocket_refire"));
	else if (req == WR_RAISE)
		rincendiary_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = floor(self.ammo_rockets / 5);
	else if (req == WR_DROP)
		rincendiary_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_ROCKET_INCENDIARY, "w_rli.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = rincendiary_check();
};


void W_IncendiaryRocket_Explode (void)
{
	vector	org2;
	entity head;

	float flametime, flamedmg, flamerate, flameedge, flameradius, distratio;

	flameradius =	cvar("g_balance_incendiaryrocket_burnradius");
	flamedmg =		cvar("g_balance_incendiaryrocket_burndamage");
	flamerate =		cvar("g_balance_incendiaryrocket_burnrate");
	flametime =		cvar("g_balance_incendiaryrocket_burntime");
	flameedge =		cvar("g_balance_incendiaryrocket_burnedge_ratio");

	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/rocketexplosion.spr32", 0, 20, 40);
	sound (self, CHAN_BODY, "weapons/rocket_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_incendiaryrocket_damage"), cvar("g_balance_incendiaryrocket_edgedamage"), cvar("g_balance_incendiaryrocket_radius"), world, cvar("g_balance_incendiaryrocket_force"), WEP_ROCKET_INCENDIARY);

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

void W_IncendiaryRocket_Think (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		W_IncendiaryRocket_Explode ();
		return;
	}
	if (self.owner)
	{
		if (self.owner.deadflag)
			self.owner = self;
		else if (self.owner.wpn == WEP_ROCKET_INCENDIARY && self.owner.button3)
			W_IncendiaryRocket_Explode ();
	}
}

void W_IncendiaryRocket_Touch (void)
{
	if (pointcontents (self.origin) == CONTENT_SKY)
	{
		remove (self);
		return;
	}
	else
		W_IncendiaryRocket_Explode ();
}

void W_IncendiaryRocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_IncendiaryRocket_Explode();
}

void W_IncendiaryRocket_Attack (void)
{
	local entity missile;
	local entity flash;
	local vector org;
	local vector end;

	local vector trueaim;
	org = self.origin + self.view_ofs;
	end = self.origin + self.view_ofs + v_forward * 4096;
	traceline(org,end,TRUE,self);
	trueaim = trace_endpos;

	sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);
	if (cvar("g_rocketarena") == 0 && cvar("g_use_ammunition") == 1)
		self.ammo_rockets = self.ammo_rockets - 5;
	self.punchangle_x = -4;
	org = self.origin + self.view_ofs + v_forward * 15 + v_right * 3 + v_up * -11;
	te_smallflash(org);

	missile = spawn ();
	missile.owner = self;
	missile.classname = "missile";

	missile.takedamage = DAMAGE_YES;
	//missile.damageforcescale = 4;
	missile.health = 30;
	missile.event_damage = W_IncendiaryRocket_Damage;

	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	setmodel (missile, "models/rocket.md3");
	setsize (missile, '0 0 0', '0 0 0');

	setorigin (missile, org);
	missile.velocity = normalize(trueaim - org) * cvar("g_balance_incendiaryrocket_speed");
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_IncendiaryRocket_Touch;
	missile.think = W_IncendiaryRocket_Think;
	missile.nextthink = time;
	missile.cnt = time + 9;
	sound (missile, CHAN_BODY, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);

	flash = spawn ();
	setorigin (flash, org);
	setmodel (flash, "models/flash.md3");
	flash.velocity = v_forward * 20;
	flash.angles = vectoangles (flash.velocity);
	SUB_SetFade (flash, time, 0.4);
	flash.effects = flash.effects | EF_ADDITIVE | EF_FULLBRIGHT;
}

// weapon frames

void()	rincendiary_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, rincendiary_ready_01); self.weaponentity.state = WS_READY;};
void()	rincendiary_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	rincendiary_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	rincendiary_fire1_01 =
{
	weapon_doattack(rincendiary_check, rincendiary_check, W_IncendiaryRocket_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, rincendiary_ready_01);
};

