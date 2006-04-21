void() glauncher_ready_01;
void() glauncher_fire1_01;
void() glauncher_fire2_01;
void() glauncher_deselect_01;
void() glauncher_select_01;

float() glauncher_check =
{
	if (self.ammo_rockets >= cvar("g_balance_grenadelauncher_primary_ammo"))
		return TRUE;
	return FALSE;
};

float() glauncher_check2 =
{
	if (self.ammo_rockets >= cvar("g_balance_grenadelauncher_secondary_ammo"))
		return TRUE;
	return FALSE;
};

void(float req) w_glauncher =
{
	if (req == WR_IDLE)
		glauncher_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(glauncher_check, glauncher_check, glauncher_fire1_01, cvar("g_balance_grenadelauncher_primary_refire"));
	else if (req == WR_FIRE2)
		weapon_prepareattack(glauncher_check2, glauncher_check2, glauncher_fire2_01, cvar("g_balance_grenadelauncher_secondary_refire"));
	else if (req == WR_RAISE)
		glauncher_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = self.ammo_rockets;
	else if (req == WR_DROP)
		glauncher_deselect_01();
	else if (req == WR_SETUP)
		weapon_setup(WEP_GRENADE_LAUNCHER, "w_gl.zym", IT_ROCKETS);
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = glauncher_check() + glauncher_check2();
};

void W_Grenade_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/grenexpl.spr", 0, 12, 35);
	sound (self, CHAN_BODY, "weapons/grenade_impact.ogg", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_primary_damage"), cvar("g_balance_grenadelauncher_primary_edgedamage"), cvar("g_balance_grenadelauncher_primary_radius"), world, cvar("g_balance_grenadelauncher_primary_force"), IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_Explode2 (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin, 12);
	te_explosion (org2);
	//effect (org2, "models/sprites/grenexpl.spr", 0, 12, 35);
	sound (self, CHAN_BODY, "weapons/grenade_impact.ogg", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_grenadelauncher_secondary_damage"), cvar("g_balance_grenadelauncher_secondary_edgedamage"), cvar("g_balance_grenadelauncher_secondary_radius"), world, cvar("g_balance_grenadelauncher_secondary_force"), IT_GRENADE_LAUNCHER);

	remove (self);
}

void W_Grenade_Touch1 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	W_Grenade_Explode ();
}

void W_Grenade_Touch2 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	if (other.takedamage == DAMAGE_AIM)
		self.think ();
	else
	{
		float r;
		r = random() * 3;
		if(r < 1)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce1.ogg", 1, ATTN_NORM);
		else if(r < 2)
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce2.ogg", 1, ATTN_NORM);
		else
			sound (self, CHAN_IMPACT, "weapons/grenade_bounce3.ogg", 1, ATTN_NORM);
	}
}

void W_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.owner = attacker;
		self.think ();
	}
}

void W_Grenade_Attack (void)
{
	local entity gren;
	local vector org;

	sound (self, CHAN_WEAPON, "weapons/grenade_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	self.punchangle_x = -4;
	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_primary_ammo");
	org = W_MuzzleOrigin (self, '24 8 -10');

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_NOSHADOW;
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, org);

	gren.nextthink = time + cvar("g_balance_grenadelauncher_primary_lifetime");
	gren.think = W_Grenade_Explode;
	gren.touch = W_Grenade_Touch1;
	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_primary_speed") + v_up * cvar("g_balance_grenadelauncher_primary_speed_up");
	gren.avelocity_x = random () * -500 - 500;

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
}

void W_Grenade_Attack2 (void)
{
	local entity gren;
	local vector org;

	sound (self, CHAN_WEAPON, "weapons/grenade_fire.ogg", 1, ATTN_NORM);
	if (self.items & IT_STRENGTH)
		sound (self, CHAN_AUTO, "weapons/strength_fire.ogg", 1, ATTN_NORM);

	self.punchangle_x = -4;
	if (cvar("g_use_ammunition"))
		self.ammo_rockets = self.ammo_rockets - cvar("g_balance_grenadelauncher_secondary_ammo");
	org = W_MuzzleOrigin (self, '24 8 -10');

	gren = spawn ();
	gren.owner = self;
	gren.classname = "grenade";
	gren.movetype = MOVETYPE_BOUNCE;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_NOSHADOW;
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '0 0 -3', '0 0 -3');
	setorigin(gren, org);

	gren.nextthink = time + cvar("g_balance_grenadelauncher_secondary_lifetime");
	gren.think = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;
	gren.takedamage = DAMAGE_YES;
	gren.health = 10;
	gren.damageforcescale = 4;
	gren.event_damage = W_Grenade_Damage;
	gren.velocity = v_forward * cvar("g_balance_grenadelauncher_secondary_speed") + v_up * cvar("g_balance_grenadelauncher_secondary_speed_up");
	gren.avelocity = '100 150 100';

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
}

// weapon frames

void()	glauncher_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, glauncher_ready_01); self.weaponentity.state = WS_READY;};
void()	glauncher_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	glauncher_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	glauncher_fire1_01 =
{
	weapon_doattack(glauncher_check, glauncher_check, W_Grenade_Attack);
	weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_grenadelauncher_primary_animtime"), glauncher_ready_01);
};
void()	glauncher_fire2_01 =
{
	weapon_doattack(glauncher_check2, glauncher_check2, W_Grenade_Attack2);
	weapon_thinkf(WFRAME_FIRE2, cvar("g_balance_grenadelauncher_secondary_animtime"), glauncher_ready_01);
};
