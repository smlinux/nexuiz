void Item_ClearRespawnEffect (void) {
	self.effects = 0;
}

void Item_Respawn (void)
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "misc/itemrespawn.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);

	// Savage: Add simple Respawn effect and make sure it gets removed
	if(self.effects == 0) {
		self.effects = EF_STARDUST;
		self.think = Item_ClearRespawnEffect;
		self.nextthink = time + 0.1;
	}
}

void Item_Touch (void)
{

	local entity oldself;
	local float	_switchweapon;

	if (other.classname != "player")
		return;
	if (other.deadflag)
		return;
	if (self.solid != SOLID_TRIGGER)
		return;

	if(self.buttonuse && !other.buttonuse)
		return; // player must press "use" button to pick this up

	if (self.classname == "droppedweapon")
	{
		// don't allow my owner to accidentally pick me up again just after dropping me
		if(self.enemy == other && self.delay > time)
			return;
	}

	// Savage: Remove the respawn effect if still present
	if(self.effects == EF_STARDUST)
		self.effects = 0;


	sound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);

	SpyCloakFlicker(other);

	// if the player is using their best weapon before items are given, they
	// probably want to switch to an even better weapon after items are given
	_switchweapon = other.switchweapon == w_getbestweapon(other);

	if (self.ammo_shells)
		other.ammo_shells = min (other.ammo_shells + self.ammo_shells, 999);
	if (self.ammo_nails)
		other.ammo_nails = min (other.ammo_nails + self.ammo_nails, 999);
	if (self.ammo_rockets)
		other.ammo_rockets = min (other.ammo_rockets + self.ammo_rockets, 999);
	if (self.ammo_cells)
		other.ammo_cells = min (other.ammo_cells + self.ammo_cells, 999);

	if (self.weapon == WEP_UZI)					W_GiveWeapon (other, WEP_UZI, "Machine gun", self.mass);
	if (self.weapon == WEP_SHOTGUN)				W_GiveWeapon (other, WEP_SHOTGUN, "Shotgun", self.mass);
	if (self.weapon == WEP_GRENADE_LAUNCHER)	W_GiveWeapon (other, WEP_GRENADE_LAUNCHER, "Mortar", self.mass);
	if (self.weapon == WEP_ELECTRO)				W_GiveWeapon (other, WEP_ELECTRO, "Electro", self.mass);
	if (self.weapon == WEP_NEX)					W_GiveWeapon (other, WEP_NEX, "Nex", self.mass);
	if (self.weapon == WEP_HAGAR)				W_GiveWeapon (other, WEP_HAGAR, "Hagar", self.mass);
	if (self.weapon == WEP_ROCKET_LAUNCHER)		W_GiveWeapon (other, WEP_ROCKET_LAUNCHER, "Rocket Launcher", self.mass);
	if (self.weapon == WEP_CRYLINK)				W_GiveWeapon (other, WEP_CRYLINK, "Crylink", self.mass);

	if (self.strength_finished)
		other.strength_finished = max(other.strength_finished, time) + cvar("g_balance_powerup_strength_time");
	if (self.invincible_finished)
		other.invincible_finished = max(other.invincible_finished, time) + cvar("g_balance_powerup_invincible_time");
	//if (self.speed_finished)
	//	other.speed_finished = max(other.speed_finished, time) + cvar("g_balance_powerup_speed_time");
	//if (self.slowmo_finished)
	//	other.slowmo_finished = max(other.slowmo_finished, time) + (cvar("g_balance_powerup_slowmo_time") * cvar("g_balance_powerup_slowmo_speed"));

	if (self.max_health)
	{
		other.health = other.health + self.max_health;
		DelayHealthRot(other);
	}
	if (self.armorvalue)
	{
		other.armorvalue = other.armorvalue + self.armorvalue;
		DelayArmorRot(other);
	}

	oldself = self;
	self = other;

	if (_switchweapon)
		self.switchweapon = w_getbestweapon(self);

	//W_UpdateWeapon ();
	//W_UpdateAmmo ();
	weapon_action(self.weapon, WR_UPDATECOUNTS);

	self = oldself;

	if (self.classname == "droppedweapon")
		remove (self);
	else
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		self.nextthink = time + self.respawntime;
		self.think = Item_Respawn;
		setorigin (self, self.origin);
	}
}

// Savage: used for item garbage-collection
// TODO: perhaps nice special effect?
void RemoveItem(void) = {
	remove(self);
}


void StartItem (string itemmodel, string pickupsound, float defaultrespawntime, string itemname, float itemid, float itemflags)
{
	if ((cvar("g_instagib") == 1) | (cvar("g_rocketarena") == 1))
	{
		remove (self);
		return;
	}
	self.mdl = itemmodel;
	self.noise = pickupsound;
	// let mappers override respawntime
	if (!self.respawntime)
		self.respawntime = defaultrespawntime;
	self.netname = itemname;
	if(itemflags & FL_WEAPON)
		self.weapon = itemid;
	else
		self.items = itemid;
	self.flags = FL_ITEM | itemflags;
	setmodel (self, self.mdl);
	if (itemflags & FL_WEAPON)
	{
		setorigin (self, self.origin + '0 0 22');
		setsize (self, '-12 -12 -12', '12 12 12');
	}
	else
	{
		setorigin (self, self.origin + '0 0 15');
	//	setsize (self, '-8 -8 -5', '8 8 8');
	}
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	self.touch = Item_Touch;

	if (itemflags & FL_POWERUP)
		self.effects = self.effects | EF_ADDITIVE;

	// Savage: remove thrown items after a certain period of time ("garbage collection")
	if (self.classname == "droppedweapon")
	{
		self.think = RemoveItem;
		self.nextthink = time + 60;
	}

	if (cvar("g_fullbrightitems"))
		self.effects = self.effects | EF_FULLBRIGHT;

}

void weapon_uzi (void) {self.buttonuse=1;self.mass=0.25;self.ammo_nails = 120;StartItem ("models/weapons/g_uzi.md3", "weapons/weaponpickup.wav", 15, "Uzi", WEP_UZI, FL_WEAPON);}
void weapon_shotgun (void) {self.buttonuse=1;self.mass=0.15;self.ammo_shells = 15;StartItem ("models/weapons/g_shotgun.md3", "weapons/weaponpickup.wav", 15, "Shotgun", WEP_SHOTGUN, FL_WEAPON);}
void weapon_grenadelauncher (void) {self.buttonuse=1;self.mass=2;self.ammo_rockets = 15;StartItem ("models/weapons/g_gl.md3", "weapons/weaponpickup.wav", 15, "Grenade Launcher", WEP_GRENADE_LAUNCHER, FL_WEAPON);}
void weapon_electro (void) {self.buttonuse=1;self.mass=1.8;self.ammo_cells = 25;StartItem ("models/weapons/g_electro.md3", "weapons/weaponpickup.wav", 15, "Electro", WEP_ELECTRO, FL_WEAPON);}
void weapon_crylink (void) {self.buttonuse=1;self.mass=0.6;self.ammo_cells = 25;StartItem ("models/weapons/g_crylink.md3", "weapons/weaponpickup.wav", 15, "Crylink", WEP_CRYLINK, FL_WEAPON);}
void weapon_nex (void) {self.buttonuse=1;self.mass=1.5;self.ammo_cells = 25;StartItem ("models/weapons/g_nex.md3", "weapons/weaponpickup.wav", 15, "Nex Gun", WEP_NEX, FL_WEAPON);}
void weapon_hagar (void) {self.buttonuse=1;self.mass=1;self.ammo_rockets = 15;StartItem ("models/weapons/g_hagar.md3", "weapons/weaponpickup.wav", 15, "Hagar", WEP_HAGAR, FL_WEAPON);}
void weapon_rocketlauncher (void) {self.buttonuse=1;self.mass=2.5;self.ammo_rockets = 15;StartItem ("models/weapons/g_rl.md3", "weapons/weaponpickup.wav", 15, "Rocket Launcher", WEP_ROCKET_LAUNCHER, FL_WEAPON);}

void(entity pl, float typ) PrintGrenadeType = 
{
	local string st;
	if (typ == TF_FLARE_OFF)
	{
		st = "Normal";
	}/*
	else
	{
		if (typ == 2)
		{
			st = "Concussion";
		}
		else
		{
			if (typ == 3)
			{
				st = "Nail";
			}
			else
			{
				if (typ == 4)
				{
					st = "Mirv";
				}
				else
				{
					if (typ == 5)
					{
						st = "Napalm";
					}
					else
					{
						if (typ == 6)
						{
							st = "Flare";
						}
						else
						{
							if (typ == 7)
							{
								st = "Gas";
							}
							else
							{
								if (typ == 8)
								{
									st = "EMP";
								}
								else
								{
									if (typ == 9)
									{
										st = "Flash";
									}
								}
							}
						}
					}
				}
			}
		}
	}*/
	sprint(pl, st);
};

void() GetGrenadePossibility = 
{
	if (random() < 0.5)
	{
		return TF_FLARE_LIT;
	}
	if (random() < 0.5)
	{
		if (other.tp_grenades_1 != TF_FLARE_LIT && other.no_grenades_1 < 4)
		{
			other.no_grenades_1 = other.no_grenades_1 + TF_FLARE_OFF;
			sprint(other, "You found a ");
			PrintGrenadeType(other, other.tp_grenades_1);
			sprint(other, " grenade\n");
			return TF_FLARE_OFF;
		}
	}/*
	else
	{
		if (other.tp_grenades_2 != TF_FLARE_LIT && other.no_grenades_2 < 4)
		{
			other.no_grenades_2 = other.no_grenades_2 + TF_FLARE_OFF;
			sprint(other, 2, "You found a ");
			PrintGrenadeType(other, other.tp_grenades_2);
			sprint(other, 2, " grenade\n");
			return TF_FLARE_OFF;
		}
	}*/
	sprint(other, "WOOOO\n");
	return TF_FLARE_LIT;
};

void item_rockets (void) {GetGrenadePossibility();self.ammo_rockets = 15;StartItem ("models/items/a_rockets.md3", "misc/itempickup.wav", 15, "rockets", IT_ROCKETS, 0);}
void item_bullets (void) {self.ammo_nails = 120;StartItem ("models/items/a_bullets.mdl", "misc/itempickup.wav", 15, "bullets", IT_NAILS, 0);}
void item_cells (void) {self.ammo_cells = 25;StartItem ("models/items/a_cells.md3", "misc/itempickup.wav", 15, "cells", IT_CELLS, 0);}
void item_shells (void) {self.ammo_shells = 25;StartItem ("models/items/a_shells.md3", "misc/itempickup.wav", 15, "shells", IT_SHELLS, 0);}

void item_armor1 (void) {self.armorvalue = 5;StartItem ("models/items/g_a1.md3", "misc/armor1.wav", 15, "Armor Shard", 0, 0);}
void item_armor25 (void) {self.armorvalue = 100;StartItem ("models/items/g_a25.md3", "misc/armor25.wav", 30, "Armor", 0, 0);}
void item_health1 (void) {self.max_health = 5;StartItem ("models/items/g_h1.md3", "misc/minihealth.wav", 15, "5 Health", 0, 0);}
void item_health25 (void) {self.max_health = 25;StartItem ("models/items/g_h25.md3", "misc/mediumhealth.wav", 15, "25 Health", 0, 0);}
void item_health100 (void) {self.max_health = 100;StartItem ("models/items/g_h100.md3", "misc/megahealth.wav", 30, "100 Health", 0, 0);}

void item_strength (void) {self.strength_finished = 30;StartItem ("models/items/g_strength.md3", "misc/powerup.wav", 120, "Strength Powerup", IT_STRENGTH, FL_POWERUP);}
void item_invincible (void) {self.invincible_finished = 30;StartItem ("models/items/g_invincible.md3", "misc/powerup.wav", 120, "Invulnerability", IT_INVINCIBLE, FL_POWERUP);}
//void item_speed (void) {self.speed_finished = 30;StartItem ("models/items/g_speed.md3", "misc/powerup.wav", 120, "Speed Powerup", IT_SPEED, FL_POWERUP);}
//void item_slowmo (void) {self.slowmo_finished = 30;StartItem ("models/items/g_slowmo.md3", "misc/powerup.wav", 120, "Slow Motion", IT_SLOWMO, FL_POWERUP);}

void misc_models (void)
{
	precache_model (self.model);
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
}


void SpawnThrownWeapon (vector org, float w)
{
	return;				// Not in tf, eh? We need to add backpacks! :P

	local entity oldself;

	if (w == IT_LASER)
		return;

	oldself = self;
	self = spawn();
	// this will cause it to be removed later
	self.classname = "droppedweapon";

	setorigin(self, org);
	if(oldself.health <= 2)
		self.velocity = randomvec() * 100 + '0 0 200';
	else
	{
		makevectors(oldself.angles); // not v_angle; we don't care for up/down motion
		self.velocity = v_forward*150 + '0 0 100';
	}

	SUB_SetFade(self, time + 10, 1);

	// delay re-pickup by owner, i.e. don't let my owner pick me up by accident
	self.enemy = oldself;
	self.delay = time + 2;

	if (w == WEP_UZI)
		weapon_uzi ();
	else if (w == WEP_SHOTGUN)
		weapon_shotgun ();
	else if (w == WEP_GRENADE_LAUNCHER)
		weapon_grenadelauncher ();
	else if (w == WEP_ELECTRO)
		weapon_electro ();
	else if (w == WEP_CRYLINK)
		weapon_crylink ();
	else if (w == WEP_NEX)
		weapon_nex ();
	else if (w == WEP_HAGAR)
		weapon_hagar ();
	else if (w == WEP_ROCKET_LAUNCHER)
		weapon_rocketlauncher ();
	else
	{
		remove(self);
	}

	self = oldself;
}

