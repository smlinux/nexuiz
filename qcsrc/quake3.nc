//***********************
//QUAKE 3 ENTITIES - So people can play quake3 maps with the nexuiz weapons
//***********************
void weapon_machinegun (void)
{
	self.mdl = "models/weapons/g_uzi.md3";
	self.items = IT_UZI;
	self.ammo_nails = 50;
	self.netname = "Uzi";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_plasmagun (void)
{
	self.mdl = "models/weapons/g_electro.md3";
	self.items = IT_ELECTRO;
	self.ammo_cells = 10;
	self.netname = "Electro";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_lightning (void)
{
	self.mdl = "models/weapons/g_crylink.md3";
	self.items = IT_CRYLINK;
	self.ammo_cells = 10;
	self.netname = "Crylink";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_railgun (void)
{
	self.mdl = "models/weapons/g_nex.md3";
	self.items = IT_NEX;
	self.ammo_cells = 10;
	self.netname = "Nex Gun";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_bfg (void)
{
	self.mdl = "models/weapons/g_hagar.md3";
	self.items = IT_HAGAR;
	self.ammo_rockets = 6;
	self.netname = "Hagar";
	self.respawntime = 30;
	StartWeapon ();
}

void item_slugs (void)
{
	self.mdl = "models/items/a_cells.md3";
	self.ammo_cells = 50;
	self.netname = "cells";
	self.respawntime = 30;
	StartItem ();
}

void item_grenades (void)
{
	self.mdl = "models/items/a_rockets.md3";
	self.ammo_rockets = 25;
	self.netname = "rockets";
	self.respawntime = 30;
	StartItem ();
}

void item_lightning (void)
{
	self.mdl = "models/items/a_cells.md3";
	self.ammo_cells = 50;
	self.netname = "cells";
	self.respawntime = 30;
	StartItem ();
}

void item_armorshard (void)
{
	self.mdl = "models/items/g_a1.md3";
	self.armorvalue = 1;
	self.netname = "Armor Shard";
	self.respawntime = 120;
	StartItem ();
}

void item_armorbody (void)
{
	self.mdl = "models/items/g_a25.md3";
	self.armorvalue = 25;
	self.netname = "Armor";
	self.respawntime = 120;
	StartItem ();
}

void item_health_small (void)
{
	self.mdl = "models/items/g_h1.md3";
	self.max_health = 1;
	self.netname = "1 health";
	self.respawntime = 120;
	StartItem ();
}

void item_health_large (void)
{
	self.mdl = "models/items/g_h25.md3";
	self.max_health = 25;
	self.netname = "25 health";
	self.respawntime = 120;
	StartItem ();
}

void item_health_mega (void)
{
	self.mdl = "models/items/g_h100.md3";
	self.max_health = 100;
	self.netname = "100 health";
	self.respawntime = 120;
	StartItem ();
}