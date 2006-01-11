
void SpyDecloak()
{
	if(!self.special_active)
		return;
	self.special_active = 0;
	ResetPlayerModel(self);
	if(self.health < 2)
		self.alpha = 0;
	else
		self.alpha = 0.1;
}

void SpyCloak()
{
	if(self.health <= cvar("g_balance_spy_cloak_min_health"))
	{
		sprint(self, "not healthy enough\n");
		return;
	}

	self.health = self.health - cvar("g_balance_spy_cloak_cost_start");

	self.alpha = 1;

	self.special_active = 1;
	self.special_time = time;
}

void SpySpecial()
{
	if(self.special_active)
	{
		SpyDecloak();
		return;
	}
	SpyCloak();
}

void SpyGrenade(float req)
{
	SpyDecloak();
	if(req == WR_GRENADE1)
	{
		if( W_ThrowGrenade(W_NailGrenade) )
			self.grenade_time = time + cvar("g_balance_grenade_nail_refire");
	}
	else if(req == WR_GRENADE2)
	{
	}
}

void SpyCloakFlicker(entity pl)
{
	if(pl.class != CLASS_SPY)
		return;
	if(!pl.special_active)
		return;

	pl.alpha = bound(0.001, pl.alpha + 0.3 + random()*0.2, 1);
}

void SpyPreThink()
{
	local vector m1, m2;
	local float desired_alpha, spd, min_health;

	if(self.special_active) // am I cloaked?
	{
		min_health = cvar("g_balance_spy_cloak_min_health");
		if(self.health < min_health || self.onfire != world || self.poison_damage)
		{// out of health
			SpyDecloak();
			return;
		}

		spd = vlen(self.velocity);
		spd = spd - self.speed*1.15; // spy can stay cloaked up to his max speed (plus some extra to keep from flickering on slopes), but any faster and he starts to show...
		if(spd <= 0)
			desired_alpha = 0;
		else
		{
			desired_alpha = bound(0, 
				cvar("g_balance_spy_move_alpha")*spd / self.speed, 
				cvar("g_balance_spy_move_alpha_max"));
		}


		// adjust alpha to reflect new value
		if(self.alpha < desired_alpha)
			self.alpha = bound(0.001, self.alpha + 0.1, 1);
		else if(self.alpha > desired_alpha)
			self.alpha = bound(0.001, self.alpha - 0.1, 1);

		// take health/armor cost
		self.health = bound(min_health,
			self.health - cvar("g_balance_spy_cloak_cost_upkeeph") * frametime,
			self.health);
		// take health/armor cost
		self.armorvalue = bound(0,
			self.armorvalue - cvar("g_balance_spy_cloak_cost_upkeepa") * frametime,
			self.armorvalue);

		if(self.health <= min_health)
		{// out of health
			SpyDecloak();
			return;
		}


		self.special_time = time + 0.1;

		// if I'm fully cloaked, set my model to nothing
		if(self.alpha < 0.01 && self.model != "")
		{
			m1 = self.mins;
			m2 = self.maxs;
			setmodel (self, "");
			setsize (self, m1, m2);
		}
		else if(self.alpha > 0.01 && self.model == "")
		{
			ResetPlayerModel(self);
		}

		self.alpha = bound(0.001, self.alpha, 1.0);

		// also cloak weapons
		self.weaponentity.alpha = 1 - 0.5*(1 - self.alpha);//self.alpha + 0.1;
		self.exteriorweaponentity.alpha = self.alpha; //self.weaponentity.alpha;
	}
	else
	{// decloaked
		if(self.alpha != 0)// && self.alpha != 1)
		{// not fully visible yet, keep phasing back in
			self.alpha = self.alpha + 0.1;
			self.weaponentity.alpha = 1 - (1 - self.alpha)*0.5;
			if(self.alpha > 1)
				self.alpha = self.weaponentity.alpha = 0;
		}
		//else
		//	self.weaponentity.alpha = 0;
	}


	
	/*	if(self.special_active) // am I cloaked?
	{
		if(self.health < 10)
		{// out of health
			SpyDecloak();
		}
		else if(self.model != "" && self.special_time <= time)
		{// not fully cloaked yet, but working on it
			self.alpha = self.alpha - 0.1;
			self.weaponentity.alpha = 1 - (1 - self.alpha)*0.5;//self.alpha + 0.1;
			self.special_time = time + 0.1;
			if(self.alpha < 0.1)
			{
				m1 = self.mins;
				m2 = self.maxs;
				setmodel (self, "");
				setsize (self, m1, m2);
				self.special_time = time + 1;
			}
		}
		else if(self.special_time <= time)
		{// fully cloaked, take health cost
			self.alpha = self.weaponentity.alpha = 0.25;
			self.special_time = time + 1;

			// reduce health & armor while cloaked
			self.health = self.health - 2;//3;
			if(self.armorvalue > 2)//3)
				self.armorvalue = self.armorvalue - 2;//3;
		}
	}
	else
	{// decloaked
		if(self.alpha != 0 && self.alpha != 1)
		{// not fully visible yet, keep phasing back in
			self.alpha = self.alpha + 0.1;
			self.weaponentity.alpha = 1 - (1 - self.alpha)*0.5;
			if(self.alpha > 1)
				self.alpha = 0;
		}
		else
			self.weaponentity.alpha = 0;
	}

	self.exteriorweaponentity.alpha = self.weaponentity.alpha;*/
}

void SpyPostThink()
{
}

void BecomeSpy(float portion)
{
	self.max_health = cvar("g_balance_class_spy_health") * portion;

	self.max_armor = cvar("g_balance_class_spy_armor") * portion;

	self.mass = cvar("g_balance_class_spy_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(50 * portion);
	self.ammo_rockets = floor(3 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = TF_CLASS_SPY;		// TF P.C.
	SetMaxAmmoFor (2);
	// fixme: also have off-hand grenade, different for each class
	// where to do that?
}
