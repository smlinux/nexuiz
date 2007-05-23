
void W_Plasma_Explode (void)
{
	vector org2;
	org2 = findbetterlocation (self.origin, 8);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, 79);
	WriteCoord (MSG_BROADCAST, org2_x);
	WriteCoord (MSG_BROADCAST, org2_y);
	WriteCoord (MSG_BROADCAST, org2_z);
	WriteCoord (MSG_BROADCAST, 0);		// SeienAbunae: groan... Useless clutter
	WriteCoord (MSG_BROADCAST, 0);
	WriteCoord (MSG_BROADCAST, 0);
	WriteByte (MSG_BROADCAST, 155);

	self.event_damage = SUB_Null;
	if (self.movetype == MOVETYPE_BOUNCE)
		RadiusDamage (self, self.owner, cvar("g_balance_electro_secondary_damage"), cvar("g_balance_electro_secondary_edgedamage"), cvar("g_balance_electro_secondary_radius"), world, cvar("g_balance_electro_secondary_force"), IT_ELECTRO);
	else
		RadiusDamage (self, self.owner, cvar("g_balance_electro_primary_damage"), cvar("g_balance_electro_primary_edgedamage"), cvar("g_balance_electro_primary_radius"), world, cvar("g_balance_electro_primary_force"), IT_ELECTRO);
	sound (self, CHAN_BODY, "weapons/electro_impact.wav", 1, ATTN_NORM);

	remove (self);
}

void W_Plasma_Explode_Combo (void) {
	vector org2;

	org2 = findbetterlocation (self.origin, 8);
	te_spikequad(self.origin);

	sound (self, CHAN_BODY, "weapons/electro_impact_combo.wav", 1, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_electro_combo_damage"), cvar("g_balance_electro_combo_edgedamage"), cvar("g_balance_electro_combo_radius"), world, cvar("g_balance_electro_combo_force"), IT_ELECTRO);
	te_explosionrgb(org2, '0.5 0.5 1');
	remove (self);
}

void W_Plasma_Touch (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
		remove(self);
		return;
	}
	if (other.takedamage == DAMAGE_AIM) {
		W_Plasma_Explode ();
	} else {
		sound (self, CHAN_IMPACT, "weapons/electro_bounce.wav", 1, ATTN_NORM);
	}
}

void W_Plasma_TouchExplode (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		sound (self, CHAN_BODY, "misc/null.wav", 1, ATTN_NORM);
		remove(self);
		return;
	}
	W_Plasma_Explode ();
}

void W_Plasma_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.takedamage = DAMAGE_NO;
		self.nextthink = time;
		if (inflictor.classname == "plasma_chain" || inflictor.classname == "plasma_prim")
		{
			// change owner to whoever caused the combo explosion
			self.owner = inflictor.owner;
			self.classname = "plasma_chain";
			self.think = W_Plasma_Explode_Combo;
		}
		else
			self.think = W_Plasma_Explode;
	}
}

void() W_Electro_Attack
{
	local entity proj;

	W_SetupShot (self, '11 8 -8', FALSE, 2, "weapons/electro_fire.wav");

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_electro_primary_damage");
	proj.think = W_Plasma_Explode;
	proj.nextthink = time + cvar("g_balance_electro_primary_lifetime");
	proj.solid = SOLID_BBOX;
	setorigin(proj, w_shotorg);

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_electro_primary_ammo");
	proj.effects = EF_BRIGHTFIELD | EF_LOWPRECISION;
	proj.movetype = MOVETYPE_FLY;
	proj.velocity = w_shotdir * cvar("g_balance_electro_primary_speed");
	W_SetupProjectileVelocity(proj);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	proj.flags = FL_PROJECTILE;
	setmodel(proj, "models/elaser.mdl"); // precision set above
	setsize(proj, '0 0 0', '0 0 0');

	// LordHavoc: disabled because no one likes this sound and it sometimes never stops due to packet loss
	//sound (proj, CHAN_BODY, "weapons/electro_fly.wav", 1, ATTN_NORM);
}

void() W_Electro_Attack2
{
	local entity proj;

	W_SetupShot (self, '8 4.5 -13', FALSE, 2, "weapons/electro_fire2.wav");

	proj = spawn ();
	proj.classname = "plasma";
	proj.owner = self;
	proj.think = W_Plasma_Explode;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = cvar("g_balance_electro_secondary_damage");
	proj.nextthink = time + cvar("g_balance_electro_secondary_lifetime");
	proj.solid = SOLID_BBOX;
	setorigin(proj, w_shotorg);

	if (cvar("g_use_ammunition"))
		self.ammo_cells = self.ammo_cells - cvar("g_balance_electro_secondary_ammo");
	proj.effects = EF_LOWPRECISION;
	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.velocity = v_forward * cvar("g_balance_electro_secondary_speed") + v_up * cvar("g_balance_electro_secondary_speed_up");
	W_SetupProjectileVelocity(proj);
	proj.touch = W_Plasma_Touch;
	setmodel(proj, "models/ebomb.mdl"); // precision set above
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = 4;
	proj.health = 5;
	proj.event_damage = W_Plasma_Damage;
	proj.flags = FL_PROJECTILE;

	// LordHavoc: disabled because no one likes this sound and it sometimes never stops due to packet loss
	//sound (proj, CHAN_BODY, "weapons/electro_fly.wav", 1, ATTN_NORM);
}

.float bot_secondary_electromooth;
float(float req) w_electro =
{
	if (req == WR_AIM)
	{
		self.button0=FALSE;
		self.button3=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_electromooth = 0;
		if(self.bot_secondary_electromooth == 0)
		{
			if(bot_aim(cvar("g_balance_electro_primary_speed"), 0, cvar("g_balance_electro_primary_lifetime"), FALSE))
			{
				self.button0 = TRUE;
				if(random() < 0.01) self.bot_secondary_electromooth = 1;
			}
		}
		else
		{
			if(bot_aim(cvar("g_balance_electro_secondary_speed"), cvar("g_balance_grenadelauncher_secondary_speed_up"), cvar("g_balance_electro_secondary_lifetime"), TRUE))
			{
				self.button3 = TRUE;
				if(random() < 0.03) self.bot_secondary_electromooth = 0;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.button0)
		if (weapon_prepareattack(0, cvar("g_balance_electro_primary_refire")))
		{
			W_Electro_Attack();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_primary_animtime"), w_ready);
		}
		if (self.button3)
		if (weapon_prepareattack(1, cvar("g_balance_electro_secondary_refire")))
		{
			W_Electro_Attack2();
			weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_electro_secondary_animtime"), w_ready);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/ebomb.mdl");
		precache_model ("models/elaser.mdl");
		precache_model ("models/weapons/g_electro.md3");
		precache_model ("models/weapons/v_electro.md3");
		precache_model ("models/weapons/w_electro.zym");
		precache_sound ("weapons/electro_bounce.wav");
		precache_sound ("weapons/electro_fire.wav");
		precache_sound ("weapons/electro_fire2.wav");
		precache_sound ("weapons/electro_fly.wav");
		precache_sound ("weapons/electro_impact.wav");
		precache_sound ("weapons/electro_impact_combo.wav");
	}
	else if (req == WR_SETUP)
		weapon_setup(WEP_ELECTRO, "electro", IT_CELLS);
	else if (req == WR_CHECKAMMO1)
		return self.ammo_cells >= cvar("g_balance_electro_primary_ammo");
	else if (req == WR_CHECKAMMO2)
		return self.ammo_cells >= cvar("g_balance_electro_secondary_ammo");
	return TRUE;
};
