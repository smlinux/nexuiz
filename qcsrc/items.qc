
void Item_Respawn (void)
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "misc/itemrespawn.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
}

void Item_Touch (void)
{
	entity	oldself;

	if (self.solid != SOLID_TRIGGER)
		return;

	if (other.classname != "player" && other.classname != "bot")
		return;
	if (other.health <= 0)
		return;
		
	if (self.ammo_shells){
		other.ammo_shells = min (other.ammo_shells + self.ammo_shells, 100);
		sound (self, CHAN_BODY, "misc/itempickup.wav", 1, ATTN_NORM); }
	if (self.ammo_nails){
		other.ammo_nails = min (other.ammo_nails + self.ammo_nails, 200);
		sound (self, CHAN_BODY, "misc/itempickup.wav", 1, ATTN_NORM); }
	if (self.ammo_rockets){
		other.ammo_rockets = min (other.ammo_rockets + self.ammo_rockets, 100);
		sound (self, CHAN_BODY, "misc/itempickup.wav", 1, ATTN_NORM); }
	if (self.ammo_cells) {
		other.ammo_cells = min (other.ammo_cells + self.ammo_cells, 100);
		sound (self, CHAN_BODY, "misc/itempickup.wav", 1, ATTN_NORM); }
		
	if (self.flags & FL_WEAPON)
	{
		sound (self, CHAN_BODY, "weapons/weaponpickup.wav", 1, ATTN_NORM);
		if (self.items & IT_UZI)					W_GiveWeapon (other, IT_UZI);
		else if (self.items & IT_SHOTGUN)			W_GiveWeapon (other, IT_SHOTGUN);
		else if (self.items & IT_GRENADE_LAUNCHER)	W_GiveWeapon (other, IT_GRENADE_LAUNCHER);
		else if (self.items & IT_ELECTRO)			W_GiveWeapon (other, IT_ELECTRO);
		else if (self.items & IT_NEX)				W_GiveWeapon (other, IT_NEX);
		else if (self.items & IT_HAGAR)				W_GiveWeapon (other, IT_HAGAR);
		else if (self.items & IT_ROCKET_LAUNCHER)	W_GiveWeapon (other, IT_ROCKET_LAUNCHER);
		else if (self.items & IT_CRYLINK)			W_GiveWeapon (other, IT_CRYLINK);
	}
		
	if (self.max_health){
		other.health = min (other.health + self.max_health, 250);
		sound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);}
	
	if (other.classname == "player")
	{
		sprint (other, "You got the ");
		sprint (other, self.netname);
		sprint (other, "\n");
	}
	
	oldself = self;
	self = other;
	
	W_UpdateWeapon ();
	W_UpdateAmmo ();
	
	self = oldself;
	

	if (self.norespawn)
	{
		remove (self);
	}
	else
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		self.nextthink = time + self.respawntime;
		self.think = Item_Respawn;
	}
}

void StartItem (void)
{
	self.flags = self.flags | FL_ITEM;
	setmodel (self, self.mdl);
	setsize (self, '-8 -8 -8', '8 8 8');
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	self.touch = Item_Touch;
}

void StartWeapon (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
	{
		remove (self);
		return;
	}

	self.flags = FL_ITEM | FL_WEAPON;
	setmodel (self, self.mdl);
	setsize (self, '-12 -12 -12', '12 12 12');
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	self.touch = Item_Touch;
}

void weapon_uzi (void)
{
	self.mdl = "models/weapons/g_uzi.md3";
	self.items = IT_UZI;
	self.ammo_nails = 50;
	self.netname = "Uzi";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_shotgun (void)
{
	self.mdl = "models/weapons/g_shotgun.md3";
	self.items = IT_SHOTGUN;
	self.ammo_shells = 10;
	self.netname = "Shotgun";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_grenadelauncher (void)
{
	self.mdl = "models/weapons/g_gl.md3";
	self.items = IT_GRENADE_LAUNCHER;
	self.ammo_rockets = 3;
	self.netname = "Grenade Launcher";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_electro (void)
{
	self.mdl = "models/weapons/g_electro.md3";
	self.items = IT_ELECTRO;
	self.ammo_cells = 10;
	self.netname = "Electro";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_crylink (void)
{
	self.mdl = "models/weapons/g_crylink.md3";
	self.items = IT_CRYLINK;
	self.ammo_cells = 10;
	self.netname = "Crylink";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_nex (void)
{
	self.mdl = "models/weapons/g_nex.md3";
	self.items = IT_NEX;
	self.ammo_cells = 10;
	self.netname = "Nex Gun";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_hagar (void)
{
	self.mdl = "models/weapons/g_hagar.md3";
	self.items = IT_HAGAR;
	self.ammo_rockets = 6;
	self.netname = "Hagar";
	self.respawntime = 30;
	StartWeapon ();
}

void weapon_rocketlauncher (void)
{
	self.mdl = "models/weapons/g_rl.md3";
	self.items = IT_ROCKET_LAUNCHER;
	self.ammo_rockets = 5;
	self.netname = "Rocket Launcher";
	self.respawntime = 30;
	StartWeapon ();
}

void item_rockets (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
	{
		remove (self);
		return;
	}

	self.mdl = "models/items/a_rockets.md3";
	self.ammo_rockets = 25;
	self.netname = "rockets";
	self.respawntime = 30;
	StartItem ();
}

void item_bullets (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
	{
		remove (self);
		return;
	}

	self.mdl = "models/items/a_bullets.zym";
	self.ammo_nails = 100;
	self.netname = "bullets";
	self.respawntime = 30;
	StartItem ();
}

void item_cells (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
	{
		remove (self);
		return;
	}

	self.mdl = "models/items/a_cells.md3";
	self.ammo_cells = 50;
	self.netname = "cells";
	self.respawntime = 30;
	StartItem ();
}

void item_shells (void)
{
	if (game & (GAME_INSTAGIB | GAME_ROCKET_ARENA))
	{
		remove (self);
		return;
	}

	self.mdl = "models/items/a_shells.md3";
	self.ammo_shells = 50;
	self.netname = "shells";
	self.respawntime = 30;
	StartItem ();
}

void item_strength (void)
{
	self.mdl = "models/items/g_strength.zym";
	self.items = IT_STRENGTH;
	self.netname = "Strength Powerup";
	self.respawntime = 120;
	StartItem ();
}

void item_invincible (void)
{
	self.mdl = "models/items/g_invincible.zym";
	self.items = IT_INVINCIBLE;
	self.netname = "Invulnerability";
	self.respawntime = 120;
	StartItem ();
}

void item_speed (void)
{
	self.mdl = "models/items/g_speed.zym";
	self.items = IT_SPEED;
	self.netname = "Speed Powerup";
	self.respawntime = 120;
	StartItem ();
}

void item_slowmo (void)
{
	self.mdl = "models/items/g_slowmo.zym";
	self.items = IT_SLOWMO;
	self.netname = "Slow Motion!";
	self.respawntime = 120;
	StartItem ();
}

void item_armor1 (void)
{
	self.mdl = "models/items/g_a1.md3";
	self.armorvalue = 1;
	self.netname = "Armor Shard";
	self.respawntime = 120;
	StartItem ();
}

void item_armor25 (void)
{
	self.mdl = "models/items/g_a25.md3";
	self.armorvalue = 25;
	self.netname = "Armor";
	self.respawntime = 120;
	StartItem ();
}

void item_health1 (void)
{
	self.mdl = "models/items/g_h1.md3";
	self.max_health = 1;
	self.netname = "1 health";
	self.respawntime = 120;
	StartItem ();
}

void item_health25 (void)
{
	self.mdl = "models/items/g_h25.md3";
	self.max_health = 25;
	self.netname = "25 health";
	self.respawntime = 120;
	StartItem ();
}

void item_health100 (void)
{
	self.mdl = "models/items/g_h100.md3";
	self.noise = "misc/megahealth.wav";
	self.max_health = 100;
	self.netname = "100 health";
	self.respawntime = 120;
	StartItem ();
}

void misc_models (void)
{
	precache_model (self.model);
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
}


