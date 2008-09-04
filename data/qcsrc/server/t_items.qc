floatfield Item_CounterField(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return ammo_shells;
		case IT_NAILS:       return ammo_nails;
		case IT_ROCKETS:     return ammo_rockets;
		case IT_CELLS:       return ammo_cells;
		case IT_5HP:         return health;
		case IT_25HP:        return health;
		case IT_HEALTH:      return health;
		case IT_ARMOR_SHARD: return armorvalue;
		case IT_ARMOR:       return armorvalue;
		// add more things here (health, armor)
		default:             error("requested item has no counter field");
	}
}

string Item_CounterFieldName(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return "shells";
		case IT_NAILS:       return "nails";
		case IT_ROCKETS:     return "rockets";
		case IT_CELLS:       return "cells";
		// add more things here (health, armor)
		default:             error("requested item has no counter field name");
	}
}

void Item_SpawnByWeaponCode(float it)
{
	weapon_action(it, WR_SPAWNFUNC);
}

.float max_armorvalue;

void Item_Respawn (void)
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_TRIGGER, "misc/itemrespawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);

	//pointparticles(particleeffectnum("item_respawn"), self.origin + self.mins_z * '0 0 1' + '0 0 48', '0 0 0', 1);
	pointparticles(particleeffectnum("item_respawn"), self.origin + 0.5 * (self.mins + self.maxs), '0 0 0', 1);
}

float Item_GiveTo(entity item, entity player)
{
	float _switchweapon;
	float pickedup;
	float it;
	float i;
	entity e;

	// if nothing happens to player, just return without taking the item
	pickedup = FALSE;
	_switchweapon = FALSE;

	if (g_minstagib)
	{
		_switchweapon = TRUE;
		if (item.ammo_cells)
		{
			pickedup = TRUE;
			// play some cool sounds ;)
			centerprint(player, "\n");
			if(player.health <= 5)
				announce(player, "announcer/robotic/lastsecond.ogg");
			else if(player.health < 50)
				announce(player, "announcer/robotic/narrowly.ogg");
			// sound not available
			// else if(item.items == IT_CELLS)
			//	play2(player, "announce/robotic/ammo.ogg");

			if (item.weapons & WEPBIT_MINSTANEX)
				W_GiveWeapon (player, WEP_MINSTANEX, "Nex");
			if (item.ammo_cells)
				player.ammo_cells = min (player.ammo_cells + cvar("g_minstagib_ammo_drop"), 999);
			player.health = 100;
		}

		// extralife powerup
		if (item.max_health)
		{
			pickedup = TRUE;
			// sound not available
			// play2(player, "announce/robotic/extra.ogg\nplay2 announce/robotic/_lives.ogg");
			player.armorvalue = player.armorvalue + cvar("g_minstagib_extralives");
			sprint(player, "^3You picked up some extra lives\n");
		}

		// invis powerup
		if (item.strength_finished)
		{
			pickedup = TRUE;
			// sound not available
			// play2(player, "announce/robotic/invisible.ogg");
			player.strength_finished = max(player.strength_finished, time) + cvar("g_balance_powerup_strength_time");
		}

		// speed powerup
		if (item.invincible_finished)
		{
			pickedup = TRUE;
			// sound not available
			// play2(player, "announce/robotic/speed.ogg");
			player.invincible_finished = max(player.invincible_finished, time) + cvar("g_balance_powerup_strength_time");
		}
	}
	else
	{
		if (cvar("deathmatch") == 2 || cvar("g_weapon_stay"))
		{
			if (item.flags & FL_WEAPON && player.weapons & item.weapons && item.classname != "droppedweapon")
				return 0;
			if (player.weapons & item.weapons && item.flags & FL_TOSSED)	// don't let players stack ammo by tossing weapons
				return 0;
		}

		// in case the player has autoswitch enabled do the following:
		// if the player is using their best weapon before items are given, they
		// probably want to switch to an even better weapon after items are given
		if (player.autoswitch)
		if (player.switchweapon == w_getbestweapon(player))
			_switchweapon = TRUE;

		if (item.ammo_shells)
		if (player.ammo_shells < g_pickup_shells_max)
		{
			pickedup = TRUE;
			player.ammo_shells = min (player.ammo_shells + item.ammo_shells, g_pickup_shells_max);
		}
		if (item.ammo_nails)
		if (player.ammo_nails < g_pickup_nails_max)
		{
			pickedup = TRUE;
			player.ammo_nails = min (player.ammo_nails + item.ammo_nails, g_pickup_nails_max);
		}
		if (item.ammo_rockets)
		if (player.ammo_rockets < g_pickup_rockets_max)
		{
			pickedup = TRUE;
			player.ammo_rockets = min (player.ammo_rockets + item.ammo_rockets, g_pickup_rockets_max);
		}
		if (item.ammo_cells)
		if (player.ammo_cells < g_pickup_cells_max)
		{
			pickedup = TRUE;
			player.ammo_cells = min (player.ammo_cells + item.ammo_cells, g_pickup_cells_max);
		}

		if (item.flags & FL_WEAPON)
		if ((it = item.weapons - (item.weapons & player.weapons)))
		{
			pickedup = TRUE;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
			{
				e = get_weaponinfo(i);
				if(it & e.weapons)
					W_GiveWeapon (player, e.weapon, item.netname);
			}
		}

		if (item.strength_finished)
		{
			pickedup = TRUE;
			player.strength_finished = max(player.strength_finished, time) + cvar("g_balance_powerup_strength_time");
		}
		if (item.invincible_finished)
		{
			pickedup = TRUE;
			player.invincible_finished = max(player.invincible_finished, time) + cvar("g_balance_powerup_invincible_time");
		}
		//if (item.speed_finished)
		//{
		//	pickedup = TRUE;
		//	player.speed_finished = max(player.speed_finished, time) + cvar("g_balance_powerup_speed_time");
		//}
		//if (item.slowmo_finished)
		//{
		//	pickedup = TRUE;
		//	player.slowmo_finished = max(player.slowmo_finished, time) + (cvar("g_balance_powerup_slowmo_time") * cvar("g_balance_powerup_slowmo_speed"));
		//}

		if (item.health)
		if (player.health < item.max_health)
		{
			pickedup = TRUE;
			player.health = min(player.health + item.health, item.max_health);
			player.pauserothealth_finished = max(player.pauserothealth_finished, time + cvar("g_balance_pause_health_rot"));
		}
		if (item.armorvalue)
		if (player.armorvalue < item.max_armorvalue)
		{
			pickedup = TRUE;
			player.armorvalue = min(player.armorvalue + item.armorvalue, item.max_armorvalue);
			player.pauserotarmor_finished = max(player.pauserotarmor_finished, time + cvar("g_balance_pause_armor_rot"));
		}
	}

	// always eat teamed entities
	if(item.team)
		pickedup = TRUE;

	if (!pickedup)
		return 0;

	sound (player, CHAN_AUTO, item.item_pickupsound, VOL_BASE, ATTN_NORM);
	if (_switchweapon)
		W_SwitchWeapon_Force(player, w_getbestweapon(item));

	return 1;
}

void Item_Touch (void)
{
	entity e, head;
	float n;

	// remove the item if it's currnetly in a NODROP brush or hits a NOIMPACT surface (such as sky)
	if (((trace_dpstartcontents | trace_dphitcontents) & DPCONTENTS_NODROP) || (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
	{
		remove(self);
		return;
	}
	if (other.classname != "player")
		return;
	if (other.deadflag)
		return;
	if (self.solid != SOLID_TRIGGER)
		return;
	if (self.owner == other)
		return;

	if(!Item_GiveTo(self, other))
		return;

	if (self.classname == "droppedweapon")
		remove (self);
	else if((self.flags & FL_WEAPON) && !self.team && (cvar("deathmatch") == 2 || cvar("g_weapon_stay")))
		return;
	else
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		if(self.team)
		{
			RandomSelection_Init();
			for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
				RandomSelection_Add(head, 0, 1, 0);
			e = RandomSelection_chosen_ent;
		}
		else
			e = self;
		e.nextthink = time + self.respawntime;
		e.think = Item_Respawn;
	}
}

void Item_FindTeam()
{
	entity head, e;

	if(self.effects & EF_NODRAW)
	{
		// marker for item team search
		dprint("Initializing item team ", ftos(self.team), "\n");
		RandomSelection_Init();
		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
			RandomSelection_Add(head, 0, 1, 0);
		e = RandomSelection_chosen_ent;

		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
		{
			if(head != e)
			{
				// make it a non-spawned item
				head.solid = SOLID_NOT;
				head.model = string_null;
			}
			head.effects = head.effects - (head.effects & EF_NODRAW);
		}
	}
}

// Savage: used for item garbage-collection
// TODO: perhaps nice special effect?
void RemoveItem(void) /*FIXDECL*/
{
	remove(self);
}

// pickup evaluation functions
// these functions decide how desirable an item is to the bots

float generic_pickupevalfunc(entity player, entity item) {return item.bot_pickupbasevalue;};

float weapon_pickupevalfunc(entity player, entity item)
{
	// if we already have the weapon, rate it 1/5th normal value
	if ((player.weapons & item.weapons) == item.weapons)
		return item.bot_pickupbasevalue * 0.2;
	return item.bot_pickupbasevalue;
};

float commodity_pickupevalfunc(entity player, entity item)
{
	float c;
	c = 0;
	// TODO: figure out if the player even has the weapon this ammo is for?
	// may not affect strategy much though...
	// find out how much more ammo/armor/health the player can hold
	if (item.ammo_shells)
	if (player.ammo_shells < g_pickup_shells_max)
		c = c + max(0, 1 - player.ammo_shells / g_pickup_shells_max);
	if (item.ammo_nails)
	if (player.ammo_nails < g_pickup_nails_max)
		c = c + max(0, 1 - player.ammo_nails / g_pickup_nails_max);
	if (item.ammo_rockets)
	if (player.ammo_rockets < g_pickup_rockets_max)
		c = c + max(0, 1 - player.ammo_rockets / g_pickup_rockets_max);
	if (item.ammo_cells)
	if (player.ammo_cells < g_pickup_cells_max)
		c = c + max(0, 1 - player.ammo_cells / g_pickup_cells_max);
	if (item.armorvalue)
	if (player.armorvalue < item.max_armorvalue)
		c = c + max(0, 1 - player.armorvalue / item.max_armorvalue);
	if (item.health)
	if (player.health < item.max_health)
		c = c + max(0, 1 - player.health / item.max_health);

	return item.bot_pickupbasevalue * c;
};


.float is_item;
void StartItem (string itemmodel, string pickupsound, float defaultrespawntime, string itemname, float itemid, float weaponid, float itemflags, float(entity player, entity item) pickupevalfunc, float pickupbasevalue)
{
	startitem_failed = FALSE;

	// is it a dropped weapon?
	if (self.classname == "droppedweapon")
	{
		// it's a dropped weapon
		self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_TRIGGER;
		// Savage: remove thrown items after a certain period of time ("garbage collection")
		self.think = RemoveItem;
		self.nextthink = time + 60;
		// don't drop if in a NODROP zone (such as lava)
		traceline(self.origin, self.origin, MOVE_NORMAL, self);
		if (trace_dpstartcontents & DPCONTENTS_NODROP)
		{
			startitem_failed = TRUE;
			remove(self);
			return;
		}
	}
	else
	{
		// it's a level item
		if(self.spawnflags & 1)
			self.noalign = 1;
		if (self.noalign)
			self.movetype = MOVETYPE_NONE;
		else
			self.movetype = MOVETYPE_TOSS;
		self.solid = SOLID_TRIGGER;
		// do item filtering according to game mode and other things
		if (!self.noalign)
		{
			// first nudge it off the floor a little bit to avoid math errors
			setorigin(self, self.origin + '0 0 1');
			// set item size before we spawn a spawnfunc_waypoint
			if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
				setsize (self, '-16 -16 0', '16 16 48');
			else
				setsize (self, '-16 -16 0', '16 16 32');
			// note droptofloor returns FALSE if stuck/or would fall too far
			droptofloor();
			waypoint_spawnforitem(self);
		}

		if(teams_matter)
		{
			if(self.notteam)
			{
				print("removed non-teamplay ", self.classname, "\n");
				startitem_failed = TRUE;
				remove (self);
				return;
			}
		}
		else
		{
			if(self.notfree)
			{
				print("removed non-FFA ", self.classname, "\n");
				startitem_failed = TRUE;
				remove (self);
				return;
			}
		}

		if(self.notq3a)
		{
			// We aren't TA or something like that, so we keep the Q3A entities
			print("removed non-Q3A ", self.classname, "\n");
			startitem_failed = TRUE;
			remove (self);
			return;
		}

		/*
		 * can't do it that way, as it would break maps
		 * TODO make a target_give like entity another way, that perhaps has
		 * the weapon name in a key
		if(self.targetname)
		{
			// target_give not yet supported; maybe later
			print("removed targeted ", self.classname, "\n");
			startitem_failed = TRUE;
			remove (self);
			return;
		}
		*/

		if(cvar("spawn_debug") >= 2)
		{
			entity otheritem;
			for(otheritem = findradius(self.origin, 3); otheritem; otheritem = otheritem.chain)
			{
				if(otheritem.is_item)
				{
					dprint("XXX Found duplicated item: ", itemname, vtos(self.origin));
					dprint(" vs ", otheritem.netname, vtos(otheritem.origin), "\n");
					error("Mapper sucks.");
				}
			}
			self.is_item = TRUE;
		}

		weaponsInMap |= weaponid;

		if(g_lms || g_rocketarena)
		{
			startitem_failed = TRUE;
			remove(self);
			return;
		}
		else if (g_minstagib)
		{
			// don't remove dropped items and powerups
			if (self.classname != "minstagib")
			{
				startitem_failed = TRUE;
				remove (self);
				return;
			}
		}
		else if ((!cvar("g_pickup_items") || g_nixnex) && itemid != IT_STRENGTH && itemid != IT_INVINCIBLE && itemid != IT_HEALTH)
		{
			startitem_failed = TRUE;
			remove (self);
			return;
		}

		precache_model (itemmodel);
		precache_sound (pickupsound);
		precache_sound ("misc/itemrespawn.wav");

		if((itemid & (IT_STRENGTH | IT_INVINCIBLE | IT_HEALTH | IT_ARMOR | IT_KEY1 | IT_KEY2)) || (weaponid & WEPBIT_ALL))
			self.target = "###item###"; // for finding the nearest item using find()
	}

	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = pickupevalfunc;
	self.bot_pickupbasevalue = pickupbasevalue;
	self.mdl = itemmodel;
	self.item_pickupsound = pickupsound;
	// let mappers override respawntime
	if (!self.respawntime)
		self.respawntime = defaultrespawntime;
	self.netname = itemname;
	self.items = itemid;
	self.weapons = weaponid;
	self.flags = FL_ITEM | itemflags;
	self.touch = Item_Touch;
	setmodel (self, self.mdl); // precision set below
	self.effects |= EF_LOWPRECISION;
	if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
		setsize (self, '-16 -16 0', '16 16 48');
	else
		setsize (self, '-16 -16 0', '16 16 32');
	if (itemflags & FL_WEAPON)
	{
		// neutral team color for pickup weapons
		self.colormap = 160 * 1024 + 160;
	}

	if (cvar("g_fullbrightitems"))
		self.effects = self.effects | EF_FULLBRIGHT;
	
	if(self.team)
	{
		self.effects = self.effects | EF_NODRAW; // marker for item team search
		InitializeEntity(self, Item_FindTeam, INITPRIO_FINDTARGET);
	}
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
			"weapons/weaponpickup.wav", 15,
			"MinstaNex", 0, WEPBIT_MINSTANEX, FL_WEAPON, generic_pickupevalfunc, 1000);
		return;
	}

	local float rnd;
	self.classname = "minstagib";

	// replace rocket launchers and nex guns with ammo cells
	if (itemid == IT_CELLS)
	{
		self.ammo_cells = 1;
		StartItem ("models/items/a_cells.md3",
			"misc/itempickup.wav", 45,
			"Nex Ammo", IT_CELLS, 0, 0, generic_pickupevalfunc, 100);
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
			"misc/powerup.wav", 120,
			"Invisibility", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 1000);
	}
	// replace with extra lives
	if (itemid == IT_NAILS)
	{
		self.max_health = 1;
		StartItem ("models/items/g_h100.md3",
			"misc/megahealth.wav", 120,
			"Extralife", IT_NAILS, 0, FL_POWERUP, generic_pickupevalfunc, 1000);

	}
	// replace with speed
	if (itemid == IT_INVINCIBLE)
	{
		self.effects = EF_ADDITIVE;
		self.invincible_finished = 30;
		StartItem ("models/items/g_invincible.md3",
			"misc/powerup_shield.wav", 120,
			"Speed", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, 1000);
	}

}

float minst_no_auto_cells;
void minst_remove_item (void) {
	if(minst_no_auto_cells)
		remove(self);
}

float weaponswapping;

void weapon_defaultspawnfunc(float wpn, float weight)
{
	entity e;
	var .float ammofield;
	e = get_weaponinfo(wpn);

	if(e.items && e.items != IT_SUPERWEAPON)
	{
		ammofield = Item_CounterField(e.items);
		if(!self.ammofield)
			self.ammofield = cvar(strcat("g_pickup_", Item_CounterFieldName(e.items)));
	}

	StartItem (e.model, "weapons/weaponpickup.wav", 15, e.message, 0, e.weapons, FL_WEAPON, weapon_pickupevalfunc, weight);
	if (self.modelindex) // don't precache if self was removed
		weapon_action(e.weapon, WR_PRECACHE);
}

void spawnfunc_weapon_shotgun (void);
void spawnfunc_weapon_uzi (void) {
	if(!weaponswapping)
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_SHOTGUN, 2500);
		return;
	}
	weapon_defaultspawnfunc(WEP_UZI, 5000);
}

void spawnfunc_weapon_shotgun (void) {
	if(!weaponswapping)
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_UZI, 5000);
		return;
	}
	weapon_defaultspawnfunc(WEP_SHOTGUN, 2500);
}

void spawnfunc_weapon_nex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time + cvar("sys_ticrate");
		return;
	}
	weapon_defaultspawnfunc(WEP_NEX, 10000);
}

void spawnfunc_weapon_minstanex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time + cvar("sys_ticrate");
		return;
	}
	weapon_defaultspawnfunc(WEP_MINSTANEX, 10000);
}

void spawnfunc_weapon_rocketlauncher (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time + cvar("sys_ticrate");
		return;
	}
	weapon_defaultspawnfunc(WEP_ROCKET_LAUNCHER, 10000);
}

void spawnfunc_item_rockets (void) {
	if(!self.ammo_rockets)
		self.ammo_rockets = g_pickup_rockets;
	StartItem ("models/items/a_rockets.md3", "misc/itempickup.wav", 15, "rockets", IT_ROCKETS, 0, 0, commodity_pickupevalfunc, 3000);
}

void spawnfunc_item_shells (void);
void spawnfunc_item_bullets (void) {
	if(!weaponswapping)
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_shells();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_nails)
		self.ammo_nails = g_pickup_nails;
	StartItem ("models/items/a_bullets.mdl", "misc/itempickup.wav", 15, "bullets", IT_NAILS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_cells (void) {
	if(!self.ammo_cells)
		self.ammo_cells = g_pickup_cells;
	StartItem ("models/items/a_cells.md3", "misc/itempickup.wav", 15, "cells", IT_CELLS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_shells (void) {
	if(!weaponswapping)
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_bullets();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_shells)
		self.ammo_shells = g_pickup_shells;
	StartItem ("models/items/a_shells.md3", "misc/itempickup.wav", 15, "shells", IT_SHELLS, 0, 0, commodity_pickupevalfunc, 500);
}

void spawnfunc_item_armor_small (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorsmall;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorsmall_max;
	StartItem ("models/items/g_a1.md3", "misc/armor1.wav", 15, "5 Armor", IT_ARMOR_SHARD, 0, 0, commodity_pickupevalfunc, 1000);
}

void spawnfunc_item_armor_medium (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armormedium;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armormedium_max;
	StartItem ("models/items/g_armormedium.md3", "misc/armor1.wav", 20, "25 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_armor_large (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorlarge;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorlarge_max;
	StartItem ("models/items/g_a25.md3", "misc/armor25.wav", 30, "100 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_health_small (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthsmall_max;
	if(!self.health)
		self.health = g_pickup_healthsmall;
	StartItem ("models/items/g_h1.md3", "misc/minihealth.wav", 15, "5 Health", IT_5HP, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_health_medium (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthmedium_max;
	if(!self.health)
		self.health = g_pickup_healthmedium;
	StartItem ("models/items/g_h25.md3", "misc/mediumhealth.wav", 15, "25 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_health_large (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthlarge_max;
	if(!self.health)
		self.health = g_pickup_healthlarge;
	StartItem ("models/items/g_h50.md3", "misc/mediumhealth.wav", 20, "50 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_health_mega (void) {
	if(!cvar("g_powerup_superhealth"))
		return;

	if(g_arena && !cvar("g_arena_powerups"))
		return;

	if(g_minstagib) {
		minstagib_items(IT_NAILS);
	} else {
		if(!self.max_health)
			self.max_health = g_pickup_healthmega_max;
		if(!self.health)
			self.health = g_pickup_healthmega;
		StartItem ("models/items/g_h100.md3", "misc/megahealth.wav", 30, "100 Health", IT_HEALTH, 0, 0, commodity_pickupevalfunc, 20000);
	}
}

// support old misnamed entities
void spawnfunc_item_armor1() { spawnfunc_item_armor_small(); }  // FIXME: in Quake this is green armor, in Nexuiz maps it is an armor shard
void spawnfunc_item_armor25() { spawnfunc_item_armor_large(); }
void spawnfunc_item_health1() { spawnfunc_item_health_small(); }
void spawnfunc_item_health25() { spawnfunc_item_health_medium(); }
void spawnfunc_item_health100() { spawnfunc_item_health_mega(); }

void spawnfunc_item_strength (void) {
	if(!cvar("g_powerup_strength"))
		return;

	if(g_arena && !cvar("g_arena_powerups"))
		return;

	if(g_minstagib) {
		minstagib_items(IT_STRENGTH);
	} else {
		precache_sound("weapons/strength_fire.wav");
		self.strength_finished = 30;
		self.effects = EF_ADDITIVE;
		StartItem ("models/items/g_strength.md3", "misc/powerup.wav", 120, "Strength Powerup", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}

void spawnfunc_item_invincible (void) {
	if(!cvar("g_powerup_shield"))
		return;

	if(g_arena && !cvar("g_arena_powerups"))
		return;

	if(g_minstagib) {
		minstagib_items(IT_INVINCIBLE);
	} else {
		self.invincible_finished = 30;
		self.effects = EF_ADDITIVE;
		StartItem ("models/items/g_invincible.md3", "misc/powerup_shield.wav", 120, "Invulnerability", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}
//void item_speed (void) {self.speed_finished = 30;StartItem ("models/items/g_speed.md3", "misc/powerup.wav", 120, "Speed Powerup", IT_SPEED, FL_POWERUP, generic_pickupevalfunc, 10000);}
//void item_slowmo (void) {self.slowmo_finished = 30;StartItem ("models/items/g_slowmo.md3", "misc/powerup.wav", 120, "Slow Motion", IT_SLOWMO, FL_POWERUP, generic_pickupevalfunc, 10000);}

void spawnfunc_item_minst_cells (void) {
	if (g_minstagib)
	{
		minst_no_auto_cells = 1;
		minstagib_items(IT_CELLS);
	}
	else
		remove(self);
}

// compatibility:
void spawnfunc_item_quad (void) {self.classname = "item_strength";spawnfunc_item_strength();}

void spawnfunc_misc_models (void)
{
	SetBrushEntityModel();
}

void func_wall_use (void)
{
	if(teams_matter)
	{
		if(activator.team)
			self.colormap = (activator.team - 1) * 0x11;
		else
			self.colormap = 0x00;
	}
	else
		self.colormap = ceil(random() * 256) - 1;
	self.colormap |= 1024; // RENDER_COLORMAPPED
}

void spawnfunc_func_wall (void)
{
	SetBrushEntityModel();
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
}

