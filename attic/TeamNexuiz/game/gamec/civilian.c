/*
			-=[Team:Nexuiz]=-
		Class:				Civilian
		Grenade 1 type:		none
		Grenade 2 type:		none
		Weapon 1:			Ball Launcher (on enabled maps)
		Weapon 2:			none
		Weapon 3:			none
		Weapon 4:			none
		Special 1:			none
		Special 2:			none
		Purpose:			Generally used in hostage rescue scenario maps (hunted, border1) and also
							sports maps like tn_soccer and sandrena.
*/

void BecomeCivilian(float portion)
{
	self.max_health = cvar("g_balance_class_civilian_health") * portion;

	self.max_armor = cvar("g_balance_class_civilian_armor") * portion;

	self.mass = cvar("g_balance_class_civilian_mass");

	SetPlayerSpeed(self);

	self.items = 0/*IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4*/;
	self.switchweapon = 0;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(20 * portion);
	self.ammo_rockets = floor(1 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = TF_CLASS_CIVILIAN;		// TF P.C.
	SetMaxAmmoFor (CLASS_CIVILIAN);
}

void CivilianPreThink()
{
}

void CivilianPostThink()
{
}