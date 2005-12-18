void EngineerSpecial()
{
	sprint(self, "Not done yet\n");
}

void EngineerGrenade(float req)
{
	if(req == WR_GRENADE1)
	{
		if(W_ThrowGrenade(W_ArmorGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_armor_refire");
	}
	else if(req == WR_GRENADE2)
	{

		self.grenade_time = time + 2;
	}
}

void EngineerPreThink()
{
}

void EngineerPostThink()
{
}

void BecomeEngineer(float portion)
{
	self.max_health = cvar("g_balance_class_engineer_health") * portion;

	self.max_armor = cvar("g_balance_class_engineer_armor") * portion;

	self.mass = cvar("g_balance_class_engineer_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(20 * portion);
	self.ammo_rockets = floor(1 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = 9;		// TF P.C.
	SetMaxAmmoFor (32);
}
