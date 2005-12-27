void Item_ClearRespawnEffect (void) {
	self.effects = self.effects - (self.effects & EF_STARDUST);
}

void Item_Respawn (void)
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "misc/itemrespawn.ogg", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);

	// Savage: Add simple Respawn effect and make sure it gets removed
	self.effects = self.effects | EF_STARDUST;
	self.think = Item_ClearRespawnEffect;
	self.nextthink = time + 0.1;
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
	if (self.health && other.health >= other.max_health)
		return;
	// Savage: Remove the respawn effect if still present
	self.effects = self.effects - (self.effects & EF_STARDUST);

	sound (self, CHAN_BODY, self.noise, 1, ATTN_NORM);

	// in case the player has autoswitch enabled do the following:
	// if the player is using their best weapon before items are given, they
	// probably want to switch to an even better weapon after items are given
	_switchweapon = (other.autoswitch && (other.switchweapon == w_getbestweapon(other)));

	if (cvar("g_minstagib"))
	{
		if (self.ammo_cells)
		{
			// play some cool sounds ;)
			centerprint(other, "\n");
			if(other.health <= 5)
				stuffcmd(other, "play2 announcer/robotic/lastsecond.ogg\n");
			else if(other.health < 50)
				stuffcmd(other, "play2 announcer/robotic/narrowly.ogg\n");
			// sound not available
			// else if(self.items == IT_CELLS)
			//	stuffcmd(other, "play2 announce/robotic/ammo.ogg\n");
			
			if (self.items & IT_NEX)
				W_GiveWeapon (other, IT_NEX, "Nex");
			if (self.ammo_cells)
				other.ammo_cells = min (other.ammo_cells + cvar("g_minstagib_ammo_drop"), 999);
			other.health = 100;
		}

		// extralife powerup
		if (self.max_health)
		{
			// sound not available
			// stuffcmd(other, "play2 announce/robotic/extra.ogg\nplay2 announce/robotic/_lives.ogg\n");
			other.extralives = other.extralives + cvar("g_minstagib_extralives");
			other.armorvalue = other.extralives;
			sprint(other, "^3You picked up some extra lives\n");
		}

		// invis powerup
		if (self.strength_finished)
		{
			// sound not available
			// stuffcmd(other, "play2 announce/robotic/invisible.ogg\n");
			other.strength_finished = max(other.strength_finished, time) + cvar("g_balance_powerup_strength_time");
		}
		
		// speed powerup
		if (self.invincible_finished)
		{
			// sound not available
			// stuffcmd(other, "play2 announce/robotic/speed.ogg\n");
			other.invincible_finished = max(other.invincible_finished, time) + cvar("g_balance_powerup_strength_time");
		}
	}
	else
	{
		if (self.ammo_shells)
			other.ammo_shells = min (other.ammo_shells + self.ammo_shells, 999);
		if (self.ammo_nails)
			other.ammo_nails = min (other.ammo_nails + self.ammo_nails, 999);
		if (self.ammo_rockets)
			other.ammo_rockets = min (other.ammo_rockets + self.ammo_rockets, 999);
		if (self.ammo_cells)
			other.ammo_cells = min (other.ammo_cells + self.ammo_cells, 999);

		if (self.items & IT_UZI)		W_GiveWeapon (other, IT_UZI, "Machine gun");
		if (self.items & IT_SHOTGUN)		W_GiveWeapon (other, IT_SHOTGUN, "Shotgun");
		if (self.items & IT_GRENADE_LAUNCHER)	W_GiveWeapon (other, IT_GRENADE_LAUNCHER, "Mortar");
		if (self.items & IT_ELECTRO)		W_GiveWeapon (other, IT_ELECTRO, "Electro");
		if (self.items & IT_NEX)		W_GiveWeapon (other, IT_NEX, "Nex");
		if (self.items & IT_HAGAR)		W_GiveWeapon (other, IT_HAGAR, "Hagar");
		if (self.items & IT_ROCKET_LAUNCHER)	W_GiveWeapon (other, IT_ROCKET_LAUNCHER, "Rocket Launcher");
		if (self.items & IT_CRYLINK)		W_GiveWeapon (other, IT_CRYLINK, "Crylink");

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
			other.pauserothealth_finished = max(other.pauserothealth_finished, time + 5);
		}
		if (self.health && other.health < other.max_health)
			other.health = min(other.health + self.health, other.max_health);
		if (self.armorvalue)
		{
			other.armorvalue = other.armorvalue + self.armorvalue;
			other.pauserotarmor_finished = max(other.pauserotarmor_finished, time + 5);
		}
	}

	sound (other, CHAN_AUTO, self.item_pickupsound, 1, ATTN_NORM);
	
	oldself = self;
	self = other;

	if (_switchweapon)
		self.switchweapon = w_getbestweapon(self);

	//w_updateweapon ();
	//w_updateammo ();
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
	if (!cvar("g_pickup_items") && !cvar("g_minstagib") && !cvar("g_lms"))
	{
		remove (self);
		return;
	}

	if (cvar("g_minstagib"))
	{
		// don't remove dropped items and powerups
		if (self.classname != "droppedweapon" && 
		    self.classname != "minstagib")
		{
			remove (self);
			return;
		}
	}

	if(cvar("g_lms") && (self.classname != "droppedweapon"))
	{
		remove(self);
		return;
	}

	if(cvar("g_instagib") || cvar("g_rocketarena"))
	{
		remove(self);
		return;
	}

	self.mdl = itemmodel;
	//self.noise = pickupsound;
	self.item_pickupsound = pickupsound;
	// let mappers override respawntime
	if (!self.respawntime)
		self.respawntime = defaultrespawntime;
	self.netname = itemname;
	self.items = itemid;
	self.flags = FL_ITEM | itemflags;
	setmodel (self, self.mdl);
	if (itemflags & FL_WEAPON)
	{
		setorigin (self, self.origin + '0 0 22');
		setsize (self, '-12 -12 -12', '12 12 12');
		
		// neutral team color for pickup weapons
		self.colormap = 160 * 1024 + 160;
	}
	else
	{
		setorigin (self, self.origin + '0 0 15');
	//	setsize (self, '-8 -8 -5', '8 8 8');
	}
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;
	self.touch = Item_Touch;

	// Savage: remove thrown items after a certain period of time ("garbage collection")
	if (self.classname == "droppedweapon")
	{
		self.think = RemoveItem;
		self.nextthink = time + 60;
	}

	if (cvar("g_fullbrightitems"))
		self.effects = self.effects | EF_FULLBRIGHT;

}

/* replace items in minstagib
 * IT_STRENGTH	 = invisibility
 * IT_NAILS	 = extra lives
 * IT_INVINCIBLE = speed
 */
void minstagib_items (float itemid)
{
	// we don't want to replace dropped weapons ;)
	if (self.classname == "droppedweapon")
	{
		self.ammo_cells = 25;
		StartItem ("models/weapons/g_nex.md3", 
			"weapons/weaponpickup.ogg", 15, 
			"Nex Gun", IT_NEX, FL_WEAPON);
		return;
	}
	
	local float rnd;
	self.classname = "minstagib";
	
	// replace rocket launchers and nex guns with ammo cells
	if (itemid == IT_CELLS)
	{
		self.ammo_cells = 1;
		StartItem ("models/items/a_cells.md3", 
			"misc/itempickup.ogg", 45, 
			"Nex Ammo", IT_CELLS, 0);
		return;
	}

	// randomize
	rnd = random() * 3;
	if (rnd <= 1)
		itemid = IT_STRENGTH;
	else if (rnd <= 2)
		itemid = IT_NAILS;
	else
		itemid = IT_INVINCIBLE;
	
	// replace with invis
	if (itemid == IT_STRENGTH)
	{
		self.effects = EF_ADDITIVE;
		self.strength_finished = 30;
		StartItem ("models/items/g_strength.md3", 
			"misc/powerup.ogg", 120, 
			"Invisibility", IT_STRENGTH, FL_POWERUP);
	}
	// replace with extra lives
	if (itemid == IT_NAILS)
	{
		self.max_health = 1;
		StartItem ("models/items/g_h100.md3", 
			"misc/megahealth.ogg", 120, 
			"Extralife", IT_NAILS, FL_POWERUP);

	}
	// replace with ammo
	if (itemid == IT_INVINCIBLE)
	{
		self.effects = EF_ADDITIVE;
		self.invincible_finished = 30;
		StartItem ("models/items/g_invincible.md3", 
			"misc/powerup_shield.ogg", 120, 
			"Speed", IT_INVINCIBLE, FL_POWERUP);
	}

}

void weapon_uzi (void) {
	self.ammo_nails = 120;
	StartItem ("models/weapons/g_uzi.md3", "weapons/weaponpickup.ogg", 15, "Uzi", IT_UZI, FL_WEAPON);
}

void weapon_shotgun (void) {
	self.ammo_shells = 15;
	StartItem ("models/weapons/g_shotgun.md3", "weapons/weaponpickup.ogg", 15, "Shotgun", IT_SHOTGUN, FL_WEAPON);
}

void weapon_grenadelauncher (void) {
	self.ammo_rockets = 15;
	StartItem ("models/weapons/g_gl.md3", "weapons/weaponpickup.ogg", 15, "Grenade Launcher", IT_GRENADE_LAUNCHER, FL_WEAPON);
}

void weapon_electro (void) {
	self.ammo_cells = 25;
	StartItem ("models/weapons/g_electro.md3", "weapons/weaponpickup.ogg", 15, "Electro", IT_ELECTRO, FL_WEAPON);
}

void weapon_crylink (void) {
	self.ammo_cells = 25;
	StartItem ("models/weapons/g_crylink.md3", "weapons/weaponpickup.ogg", 15, "Crylink", IT_CRYLINK, FL_WEAPON);
}

void weapon_nex (void) {
	if (cvar("g_minstagib")) {
		minstagib_items(IT_CELLS);
	} else {
		self.ammo_cells = 25;
		StartItem ("models/weapons/g_nex.md3", "weapons/weaponpickup.ogg", 15, "Nex Gun", IT_NEX, FL_WEAPON);
	}
}

void weapon_hagar (void) {
	self.ammo_rockets = 15;
	StartItem ("models/weapons/g_hagar.md3", "weapons/weaponpickup.ogg", 15, "Hagar", IT_HAGAR, FL_WEAPON);
}

void weapon_rocketlauncher (void) {
	if (cvar("g_minstagib")) {
		minstagib_items(IT_CELLS);
	} else {
		self.ammo_rockets = 15;
		StartItem ("models/weapons/g_rl.md3", "weapons/weaponpickup.ogg", 15, "Rocket Launcher", IT_ROCKET_LAUNCHER, FL_WEAPON);
	}
}

void item_rockets (void) {
	self.ammo_rockets = 15;
	StartItem ("models/items/a_rockets.md3", "misc/itempickup.ogg", 15, "rockets", IT_ROCKETS, 0);
}

void item_bullets (void) {
	self.ammo_nails = 120;
	StartItem ("models/items/a_bullets.mdl", "misc/itempickup.ogg", 15, "bullets", IT_NAILS, 0);
}

void item_cells (void) {
	self.ammo_cells = 25;
	StartItem ("models/items/a_cells.md3", "misc/itempickup.ogg", 15, "cells", IT_CELLS, 0);
}

void item_shells (void) {
	self.ammo_shells = 15;
	StartItem ("models/items/a_shells.md3", "misc/itempickup.ogg", 15, "shells", IT_SHELLS, 0);
}

void item_armor1 (void) {
	self.armorvalue = 5;
	StartItem ("models/items/g_a1.md3", "misc/armor1.wav", 15, "Armor Shard", 0, 0);
}

void item_armor25 (void) {
	self.armorvalue = 100;
	StartItem ("models/items/g_a25.md3", "misc/armor25.wav", 30, "Armor", 0, 0);
}

void item_health1 (void) {
	self.max_health = 5;
	StartItem ("models/items/g_h1.md3", "misc/minihealth.ogg", 15, "5 Health", 0, 0);
}

void item_health25 (void) {
	self.max_health = 25;
	StartItem ("models/items/g_h25.md3", "misc/mediumhealth.ogg", 15, "25 Health", 0, 0);
}

void item_health100 (void) {
	if(cvar("g_minstagib")) {
		minstagib_items(IT_NAILS);
	} else {
		self.max_health = 100;
		StartItem ("models/items/g_h100.md3", "misc/megahealth.ogg", 30, "100 Health", 0, 0);
	}
}

void item_strength (void) {
	if(cvar("g_minstagib")) {
		minstagib_items(IT_STRENGTH);
	} else {
		self.strength_finished = 30;
		self.effects = EF_ADDITIVE;StartItem ("models/items/g_strength.md3", "misc/powerup.ogg", 120, "Strength Powerup", IT_STRENGTH, FL_POWERUP);
	}
}

void item_invincible (void) {
	if(cvar("g_minstagib")) {
		minstagib_items(IT_INVINCIBLE);
	} else {
		self.invincible_finished = 30;
		self.effects = EF_ADDITIVE;
		StartItem ("models/items/g_invincible.md3", "misc/powerup_shield.ogg", 120, "Invulnerability", IT_INVINCIBLE, FL_POWERUP);
	}
}
//void item_speed (void) {self.speed_finished = 30;StartItem ("models/items/g_speed.md3", "misc/powerup.wav", 120, "Speed Powerup", IT_SPEED, FL_POWERUP);}
//void item_slowmo (void) {self.slowmo_finished = 30;StartItem ("models/items/g_slowmo.md3", "misc/powerup.wav", 120, "Slow Motion", IT_SLOWMO, FL_POWERUP);}

void misc_models (void)
{
	precache_model (self.model);
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
}


