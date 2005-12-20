void() bombletts_ready_01;
void() bombletts_fire1_01;
void() bombletts_deselect_01;
void() bombletts_select_01;

float() bombletts_check =
{
	return TRUE;
}

void(float req) w_bombletts =
{
	if (req == WR_IDLE)
		bombletts_ready_01();
	else if (req == WR_FIRE1)
		weapon_prepareattack(bombletts_check, bombletts_check, bombletts_fire1_01, cvar("g_balance_bombletts_refire"));
	else if (req == WR_RAISE)
		bombletts_select_01();
	else if (req == WR_UPDATECOUNTS)
		self.currentammo = 1;
	else if (req == WR_DROP)
		bombletts_deselect_01();
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_BOMBLETTS, "w_bombletts.zym", IT_ROCKETS);
		//self.weaponentity.colormod = '0 4 0';
		//self.weaponentity.scale = 0.65;
	}
	else if (req == WR_CHECKAMMO)
		weapon_hasammo = bombletts_check();
}

void W_Bombletts_Explode (void)
{
	vector	org2;
	org2 = findbetterlocation (self.origin);
	te_explosion (org2);
	effect (org2, "models/sprites/grenadeexplosion.spr32", 0, 20, 30);
	sound (self, CHAN_BODY, "weapons/grenade_impact.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_bombletts_damage"), cvar("g_balance_bombletts_edgedamage"), cvar("g_balance_bombletts_radius"), world, cvar("g_balance_bombletts_force"), WEP_BOMBLETTS);

	remove (self);
}

void W_Bombletts_Touch (void)
{
	sound (self, CHAN_IMPACT, "weapons/grenade_bounce.wav", 1, ATTN_NORM);
	self.velocity = self.velocity * cvar("g_balance_bombletts_bounce_speed");
}

void W_Bombletts_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
		W_Bombletts_Explode();
}

void W_Bombletts_Think (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		W_Bombletts_Explode ();
		return;
	}
	if (self.owner)
	{
		if (self.owner.deadflag)
			self.owner = self;
		else if (self.owner.wpn == WEP_BOMBLETTS && self.owner.button3)
			W_Bombletts_Explode ();
	}
}

void W_Bombletts_Attack (void)
{
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
	setmodel(gren, "models/grenademodel.md3");
	setsize(gren, '-6 -6 -3', '6 6 3');
	setorigin(gren, org);

	gren.cnt = time + 1.5 + random()*0.5;
	gren.think = W_Bombletts_Think;
	gren.nextthink = time + 0.1;
	//gren.think = W_Bombletts_Explode;
	gren.touch = W_Bombletts_Touch;
	gren.takedamage = DAMAGE_YES;
	gren.health = 2;
	//gren.damageforcescale = 4;
	gren.event_damage = W_Bombletts_Damage;
	gren.velocity = v_forward * cvar("g_balance_bombletts_speed")
		+ v_up * cvar("g_balance_bombletts_speed_up");
	gren.avelocity = '100 150 100';

	gren.angles = vectoangles (gren.velocity);

	gren.scale = 0.5;
	gren.colormod = '1 .5 0'*4;//'0 0 1.9';

	self.clip_pipegrenades = self.clip_pipegrenades - 1;
	if (self.clip_pipegrenades <= 0)
	{
		DoReload (4, 6);	// weapon type 4 is Pipe Grenade, and reload 6 Grenades.
	}
}

// weapon frames

void()	bombletts_ready_01 =	{weapon_thinkf(WFRAME_IDLE, 0.1, bombletts_ready_01); self.weaponentity.state = WS_READY;};
void()	bombletts_select_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_ready); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');};
void()	bombletts_deselect_01 =	{weapon_thinkf(-1, cvar("g_balance_weaponswitchdelay"), w_clear); weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);};
void()	bombletts_fire1_01 =
{
	weapon_doattack(bombletts_check, bombletts_check, W_Bombletts_Attack);
	weapon_thinkf(WFRAME_FIRE1, 0.3, bombletts_ready_01);
};