void W_Hook_Explode2 (void)
{
	vector org2;

	org2 = findbetterlocation (self.origin, 12);
	pointparticles(particleeffectnum("hookbomb_explode"), org2, '0 0 0', 1);
	sound (self, CHAN_PROJECTILE, "weapons/hookbomb_impact.wav", VOL_BASE, ATTN_NORM);

	self.event_damage = SUB_Null;
	RadiusDamage (self, self.owner, cvar("g_balance_hook_secondary_damage"), cvar("g_balance_hook_secondary_edgedamage"), cvar("g_balance_hook_secondary_radius"), self.owner, cvar("g_balance_hook_secondary_force"), self.projectiledeathtype, other);

	remove(self);
}

void W_Hook_Touch2 (void)
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	self.use();
}

void W_Hook_Attack2()
{
	local entity gren;

	if not(self.items & IT_UNLIMITED_AMMO)
		self.ammo_cells = self.ammo_cells - cvar("g_balance_hook_secondary_ammo");
	W_SetupShot (self, '25 6 -8', FALSE, 4, "weapons/hookbomb_fire.wav");

	gren = spawn ();
	gren.owner = self;
	gren.classname = "hookbomb";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = cvar("g_balance_hook_secondary_damage");
	gren.movetype = MOVETYPE_TOSS;
	gren.solid = SOLID_BBOX;
	gren.effects = EF_LOWPRECISION;
	gren.modelflags = MF_TRACER2;
	gren.projectiledeathtype = WEP_HOOK | HITTYPE_SECONDARY;
	setmodel(gren, "models/grenademodel.md3"); // precision set above // FIXME replace
	setsize(gren, '0 0 0', '0 0 0');
	setorigin(gren, w_shotorg);

	gren.nextthink = time + cvar("g_balance_hook_secondary_lifetime");
	gren.think = adaptor_think2use;
	gren.use = W_Hook_Explode2;
	gren.touch = W_Hook_Touch2;
	gren.velocity = '0 0 1' * cvar("g_balance_hook_secondary_speed");
	gren.gravity = cvar("g_balance_hook_secondary_gravity");
	//W_SetupProjectileVelocity(gren); // just falling down!

	gren.angles = '0 0 0';
	gren.flags = FL_PROJECTILE;
}

void spawnfunc_weapon_hook (void)
{
	if(g_grappling_hook) // offhand hook
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}
	weapon_defaultspawnfunc(WEP_HOOK);
}

float w_hook(float req)
{
	if (req == WR_AIM)
	{
		// ... sorry ...
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK || self.BUTTON_HOOK)
		{
			if(!self.hook)
			if not(self.hook_state & HOOK_WAITING_FOR_RELEASE)
			if (weapon_prepareattack(0, cvar("g_balance_hook_primary_refire")))
			{
				if not(self.items & IT_UNLIMITED_AMMO)
					self.ammo_cells = self.ammo_cells - cvar("g_balance_hook_primary_ammo");
				self.hook_state |= HOOK_FIRING;
				weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hook_primary_animtime"), w_ready);
			}
		}

		if (self.BUTTON_ATCK2)
		{
			if (weapon_prepareattack(1, cvar("g_balance_hook_secondary_refire")))
			{
				W_Hook_Attack2();
				weapon_thinkf(WFRAME_FIRE1, cvar("g_balance_hook_secondary_animtime"), w_ready);
			}
		}

		if (self.BUTTON_CROUCH)
		{
			self.hook_state (-) HOOK_PULLING;
			if (self.BUTTON_ATCK || self.BUTTON_HOOK)
				self.hook_state (-) HOOK_RELEASING;
			else
				self.hook_state |= HOOK_RELEASING;
		}
		else
		{
			self.hook_state |= HOOK_PULLING;
			self.hook_state (-) HOOK_RELEASING;

			if (self.BUTTON_ATCK || self.BUTTON_HOOK)
			{
				// already fired
				if(self.hook)
					self.hook_state |= HOOK_WAITING_FOR_RELEASE;
			}
			else
			{
				self.hook_state |= HOOK_REMOVING;
				self.hook_state (-) HOOK_WAITING_FOR_RELEASE;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_hookgun.md3");
		precache_model ("models/weapons/v_hookgun.md3");
		precache_model ("models/weapons/w_hookgun.zym");
		precache_sound ("weapons/hook_fire.wav");
		precache_sound ("weapons/hook_impact.wav");
		precache_sound ("weapons/hookbomb_fire.wav");
		precache_sound ("weapons/hookbomb_impact.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HOOK);
	}
	else if (req == WR_CHECKAMMO1)
	{
		return self.ammo_cells >= cvar("g_balance_hook_primary_ammo");
	}
	else if (req == WR_CHECKAMMO2)
	{
		return self.ammo_cells >= cvar("g_balance_hook_secondary_ammo");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = "did the impossible";
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = "has run into #'s gravity bomb";
	return TRUE;
};
