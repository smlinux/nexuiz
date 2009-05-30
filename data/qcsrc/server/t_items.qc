#define ITEM_RESPAWNTIME(i)         ((i).respawntime + crandom() * (i).respawntimejitter)
	// range: respawntime - respawntimejitter .. respawntime + respawntimejitter
#define ITEM_RESPAWNTIME_INITIAL(i) (10 + random() * ((i).respawntime + (i).respawntimejitter - 10))
	// range: 10 .. respawntime + respawntimejitter

floatfield Item_CounterField(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return ammo_shells;
		case IT_NAILS:       return ammo_nails;
		case IT_ROCKETS:     return ammo_rockets;
		case IT_CELLS:       return ammo_cells;
		case IT_FUEL:        return ammo_fuel;
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
		case IT_FUEL:        return "fuel";

		// add more things here (health, armor)
		default:             error("requested item has no counter field name");
	}
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

void Item_RespawnCountdown (void)
{
	if(self.count >= 5)
	{
		if(self.waypointsprite_attached)
			WaypointSprite_Kill(self.waypointsprite_attached);
		Item_Respawn();
	}
	else
	{
		self.nextthink = time + 1;
		self.count += 1;
		if(self.count == 1)
		{
			string name;
			vector rgb;
			name = string_null;
			if(g_minstagib)
			{
				switch(self.items)
				{
					case IT_STRENGTH:   name = "item-invis"; rgb = '0 0 1'; break;
					case IT_NAILS:      name = "item-extralife"; rgb = '1 0 0'; break;
					case IT_INVINCIBLE: name = "item-speed"; rgb = '1 0 1'; break;
				}
			}
			else
			{
				switch(self.items)
				{
					case IT_STRENGTH:   name = "item-strength"; rgb = '0 0 1'; break;
					case IT_INVINCIBLE: name = "item-shield"; rgb = '1 0 1'; break;
				}
			}
			switch(self.items)
			{
				case IT_FUEL_REGEN:     name = "item-fuelregen"; rgb = '1 0.5 0'; break;
				case IT_JETPACK:        name = "item-jetpack"; rgb = '0.5 0.5 0.5'; break;
			}
			if(name)
			{
				WaypointSprite_Spawn(name, 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, FALSE);
				if(self.waypointsprite_attached)
					WaypointSprite_UpdateTeamRadar(self.waypointsprite_attached, RADARICON_POWERUP, rgb);
			}
		}
		sound (self, CHAN_TRIGGER, "misc/itemrespawncountdown.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
		if(self.waypointsprite_attached)
			WaypointSprite_Ping(self.waypointsprite_attached);
	}
}

void Item_ScheduleRespawnIn(entity e, float t)
{
	if(e.flags & FL_POWERUP)
	{
		e.think = Item_RespawnCountdown;
		e.nextthink = time + max(0, t - 5);
		e.count = 0;
	}
	else
	{
		e.think = Item_Respawn;
		e.nextthink = time + t;
	}
}

void Item_ScheduleRespawn(entity e)
{
	Item_ScheduleRespawnIn(e, ITEM_RESPAWNTIME(e));
}

void Item_ScheduleInitialRespawn(entity e)
{
	Item_ScheduleRespawnIn(e, game_starttime - time + ITEM_RESPAWNTIME_INITIAL(e));
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
		if (item.ammo_fuel)
		if (player.ammo_fuel < g_pickup_fuel_max)
		{
			pickedup = TRUE;
			player.ammo_fuel = min(player.ammo_fuel + item.ammo_fuel, g_pickup_fuel_max);
			player.pauserotfuel_finished = max(player.pauserotfuel_finished, time + cvar("g_balance_pause_fuel_rot"));
		}
		if((it = (item.items - (item.items & player.items)) & IT_PICKUPMASK))
		{
			pickedup = TRUE;
			player.items |= it;
			sprint (player, strcat("You got the ^2", item.netname, "\n"));
		}

		_switchweapon = TRUE;
		if (item.ammo_cells)
		{
			pickedup = TRUE;
			// play some cool sounds ;)
			centerprint(player, "\n");
			if(player.health <= 5)
				announce(player, "announcer/robotic/lastsecond.wav");
			else if(player.health < 50)
				announce(player, "announcer/robotic/narrowly.wav");
			// sound not available
			// else if(item.items == IT_CELLS)
			//	play2(player, "announce/robotic/ammo.wav");

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
			// play2(player, "announce/robotic/extra.ogg\nplay2 announce/robotic/_lives.wav");
			player.armorvalue = player.armorvalue + cvar("g_minstagib_extralives");
			sprint(player, "^3You picked up some extra lives\n");
		}

		// invis powerup
		if (item.strength_finished)
		{
			pickedup = TRUE;
			// sound not available
			// play2(player, "announce/robotic/invisible.wav");
			player.strength_finished = max(player.strength_finished, time) + cvar("g_balance_powerup_strength_time");
		}

		// speed powerup
		if (item.invincible_finished)
		{
			pickedup = TRUE;
			// sound not available
			// play2(player, "announce/robotic/speed.wav");
			player.invincible_finished = max(player.invincible_finished, time) + cvar("g_balance_powerup_strength_time");
		}

		if (item.ammo_fuel)
		if (player.ammo_fuel < g_pickup_fuel_max)
		{
			pickedup = TRUE;
			player.ammo_fuel = min(player.ammo_fuel + item.ammo_fuel, g_pickup_fuel_max);
			player.pauserotfuel_finished = max(player.pauserotfuel_finished, time + cvar("g_balance_pause_fuel_rot"));
		}

	}
	else
	{
		if (g_weapon_stay == 1)
		if not(item.flags & FL_NO_WEAPON_STAY)
		if (item.flags & FL_WEAPON)
		{
			if(item.classname == "droppedweapon")
			{
				if (player.weapons & item.weapons)	// don't let players stack ammo by tossing weapons
					goto skip;
			}
			else
			{
				if (player.weapons & item.weapons)
					goto skip;
			}
		}

		// in case the player has autoswitch enabled do the following:
		// if the player is using their best weapon before items are given, they
		// probably want to switch to an even better weapon after items are given
		if (player.autoswitch)
		if (player.switchweapon == w_getbestweapon(player))
			_switchweapon = TRUE;

		if not(player.weapons & W_WeaponBit(player.switchweapon))
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
		if (item.ammo_fuel)
		if (player.ammo_fuel < g_pickup_fuel_max)
		{
			pickedup = TRUE;
			player.ammo_fuel = min(player.ammo_fuel + item.ammo_fuel, g_pickup_fuel_max);
			player.pauserotfuel_finished = max(player.pauserotfuel_finished, time + cvar("g_balance_pause_fuel_rot"));
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

		if((it = (item.items - (item.items & player.items)) & IT_PICKUPMASK))
		{
			pickedup = TRUE;
			player.items |= it;
			sprint (player, strcat("You got the ^2", item.netname, "\n"));
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

:skip
	// always eat teamed entities
	if(item.team)
		pickedup = TRUE;

	if (!pickedup)
		return 0;

	sound (player, CHAN_AUTO, item.item_pickupsound, VOL_BASE, ATTN_NORM);
	if (_switchweapon)
		if (player.switchweapon != w_getbestweapon(player))
			W_SwitchWeapon_Force(player, w_getbestweapon(player));

	return 1;
}

void Item_Touch (void)
{
	entity e, head;

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

	pointparticles(particleeffectnum("item_pickup"), self.origin, '0 0 0', 1);

	if (self.classname == "droppedweapon")
		remove (self);
	else if((self.flags & FL_WEAPON) && !(self.flags & FL_NO_WEAPON_STAY) && g_weapon_stay)
		return;
	else
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		if(self.team)
		{
			RandomSelection_Init();
			for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
				RandomSelection_Add(head, 0, string_null, head.cnt, 0);
			e = RandomSelection_chosen_ent;
		}
		else
			e = self;
		Item_ScheduleRespawn(e);
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
			RandomSelection_Add(head, 0, string_null, head.cnt, 0);
		e = RandomSelection_chosen_ent;
		e.state = 0;

		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
		{
			if(head != e)
			{
				// make it a non-spawned item
				head.solid = SOLID_NOT;
				head.model = string_null;
				head.state = 1; // state 1 = initially hidden item
			}
			head.effects &~= EF_NODRAW;
		}

		if(e.flags & FL_POWERUP) // do not spawn powerups initially!
		{
			e.solid = SOLID_NOT;
			e.model = string_null;
			Item_ScheduleInitialRespawn(e);
		}
	}
}

void Item_Reset()
{
	if(self.state == 1)
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
	}
	else
	{
		self.model = self.mdl;
		self.solid = SOLID_TRIGGER;
	}
	setorigin (self, self.origin);
	self.think = SUB_Null;
	self.nextthink = 0;

	if(self.flags & FL_POWERUP) // do not spawn powerups initially!
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		Item_ScheduleInitialRespawn(self);
	}
}

// Savage: used for item garbage-collection
// TODO: perhaps nice special effect?
void RemoveItem(void)
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
void StartItem (string itemmodel, string pickupsound, float defaultrespawntime, float defaultrespawntimejitter, string itemname, float itemid, float weaponid, float itemflags, float(entity player, entity item) pickupevalfunc, float pickupbasevalue)
{
	startitem_failed = FALSE;

	// is it a dropped weapon?
	if (self.classname == "droppedweapon")
	{
		self.reset = SUB_Remove;
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
		self.reset = Item_Reset;
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

		if(g_lms)
		{
			startitem_failed = TRUE;
			remove(self);
			return;
		}
		else if (g_weaponarena && ((weaponid & WEPBIT_ALL) || (itemid & IT_AMMO)))
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
		precache_sound ("misc/itemrespawncountdown.wav");

		if((itemid & (IT_STRENGTH | IT_INVINCIBLE | IT_HEALTH | IT_ARMOR | IT_KEY1 | IT_KEY2)) || (weaponid & WEPBIT_ALL))
			self.target = "###item###"; // for finding the nearest item using find()
	}

	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = pickupevalfunc;
	self.bot_pickupbasevalue = pickupbasevalue;
	self.mdl = itemmodel;
	self.item_pickupsound = pickupsound;
	// let mappers override respawntime
	if(!self.respawntime) // both set
	{
		self.respawntime = defaultrespawntime;
		self.respawntimejitter = defaultrespawntimejitter;
	}
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
	if(itemflags & FL_WEAPON)
		self.modelflags |= MF_ROTATE;

	if (self.classname != "droppedweapon") // if dropped, colormap is already set up nicely
	if (itemflags & FL_WEAPON)
	{
		// neutral team color for pickup weapons
		self.colormap = 1024; // color shirt=0 pants=0 grey
	}

	if (cvar("g_fullbrightitems"))
		self.effects = self.effects | EF_FULLBRIGHT;

	self.state = 0;
	if(self.team)
	{
		if(!self.cnt)
			self.cnt = 1; // item probability weight
		self.effects = self.effects | EF_NODRAW; // marker for item team search
		InitializeEntity(self, Item_FindTeam, INITPRIO_FINDTARGET);
	}
	else if(self.flags & FL_POWERUP) // do not spawn powerups initially!
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		Item_ScheduleInitialRespawn(self);
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
			"weapons/weaponpickup.wav", 15, 0,
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
			"misc/itempickup.wav", 45, 0,
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
			"misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Invisibility", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
	// replace with extra lives
	if (itemid == IT_NAILS)
	{
		self.max_health = 1;
		StartItem ("models/items/g_h100.md3",
			"misc/megahealth.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Extralife", IT_NAILS, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_HIGH);

	}
	// replace with speed
	if (itemid == IT_INVINCIBLE)
	{
		self.effects = EF_ADDITIVE;
		self.invincible_finished = 30;
		StartItem ("models/items/g_invincible.md3",
			"misc/powerup_shield.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Speed", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}

}

float minst_no_auto_cells;
void minst_remove_item (void) {
	if(minst_no_auto_cells)
		remove(self);
}

float weaponswapping;
float internalteam;

void weapon_defaultspawnfunc(float wpn)
{
	entity e;
	float t;
	var .float ammofield;
	string s;
	entity oldself;
	float i, j;

	// set the respawntime in advance (so replaced weapons can copy it)

	if(!self.respawntime)
	{
		e = get_weaponinfo(wpn);
		if(e.items == IT_SUPERWEAPON)
		{
			self.respawntime = g_pickup_respawntime_powerup;
			self.respawntimejitter = g_pickup_respawntimejitter_powerup;
		}
		else
		{
			self.respawntime = g_pickup_respawntime_weapon;
			self.respawntimejitter = g_pickup_respawntimejitter_weapon;
		}
	}

	if(self.classname != "droppedweapon" && self.classname != "replacedweapon")
	{
		e = get_weaponinfo(wpn);
		s = cvar_string(strcat("g_weaponreplace_", e.netname));
		if(s == "0")
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
		t = tokenize_console(s);
		if(t >= 2)
		{
			self.team = --internalteam;
			oldself = self;
			for(i = 1; i < t; ++i)
			{
				s = argv(i);
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(e.netname == s)
					{
						self = spawn();
						copyentity(oldself, self);
						self.classname = "replacedweapon";
						weapon_defaultspawnfunc(j);
						break;
					}
				}
				if(j > WEP_LAST)
				{
					print("The weapon replace list for ", oldself.classname, " contains an unknown weapon ", s, ". Skipped.\n");
				}
			}
			self = oldself;
		}
		if(t >= 1)
		{
			s = argv(0);
			wpn = 0;
			for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if(e.netname == s)
				{
					wpn = j;
					break;
				}
			}
			if(j > WEP_LAST)
			{
				print("The weapon replace list for ", self.classname, " contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		if(wpn == 0)
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
	}

	e = get_weaponinfo(wpn);

	if(e.items && e.items != IT_SUPERWEAPON)
	{
		for(i = 0, j = 1; i < 24; ++i, j *= 2)
		{
			if(e.items & j)
			{
				ammofield = Item_CounterField(j);
				if(!self.ammofield)
					self.ammofield = cvar(strcat("g_pickup_", Item_CounterFieldName(j)));
			}
		}
	}
	else
	{
		self.flags |= FL_NO_WEAPON_STAY;
	}

	// weapon stay isn't supported for teamed weapons
	if(self.team)
		self.flags |= FL_NO_WEAPON_STAY;

	if(g_weapon_stay == 2 && self.classname != "droppedweapon")
	{
		self.ammo_shells = 0;
		self.ammo_nails = 0;
		self.ammo_cells = 0;
		self.ammo_rockets = 0;
		// weapon stay 2: don't use ammo on weapon pickups; instead
		// initialize all ammo types to the pickup ammo unless set by g_start_ammo_*
	}

	StartItem(e.model, "weapons/weaponpickup.wav", self.respawntime, self.respawntimejitter, e.message, 0, e.weapons, FL_WEAPON, weapon_pickupevalfunc, e.bot_pickupbasevalue);
	if (self.modelindex) // don't precache if self was removed
		weapon_action(e.weapon, WR_PRECACHE);
}

void spawnfunc_weapon_shotgun (void);
void spawnfunc_weapon_uzi (void) {
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_SHOTGUN);
		return;
	}
	weapon_defaultspawnfunc(WEP_UZI);
}

void spawnfunc_weapon_shotgun (void) {
	if(q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_UZI);
		return;
	}
	weapon_defaultspawnfunc(WEP_SHOTGUN);
}

void spawnfunc_weapon_nex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_NEX);
}

void spawnfunc_weapon_minstanex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_MINSTANEX);
}

void spawnfunc_weapon_rocketlauncher (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_ROCKET_LAUNCHER);
}

void spawnfunc_item_rockets (void) {
	if(!self.ammo_rockets)
		self.ammo_rockets = g_pickup_rockets;
	StartItem ("models/items/a_rockets.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "rockets", IT_ROCKETS, 0, 0, commodity_pickupevalfunc, 3000);
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
	StartItem ("models/items/a_bullets.mdl", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "bullets", IT_NAILS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_cells (void) {
	if(!self.ammo_cells)
		self.ammo_cells = g_pickup_cells;
	StartItem ("models/items/a_cells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "cells", IT_CELLS, 0, 0, commodity_pickupevalfunc, 2000);
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
	StartItem ("models/items/a_shells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "shells", IT_SHELLS, 0, 0, commodity_pickupevalfunc, 500);
}

void spawnfunc_item_armor_small (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorsmall;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorsmall_max;
	StartItem ("models/items/g_a1.md3", "misc/armor1.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Armor", IT_ARMOR_SHARD, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_armor_medium (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armormedium;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armormedium_max;
	StartItem ("models/items/g_armormedium.md3", "misc/armor10.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "25 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_armor_big (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorbig;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorbig_max;
	StartItem ("models/items/g_a50.md3", "misc/armor17_5.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "50 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_armor_large (void) {
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorlarge;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorlarge_max;
	StartItem ("models/items/g_a25.md3", "misc/armor25.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

void spawnfunc_item_health_small (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthsmall_max;
	if(!self.health)
		self.health = g_pickup_healthsmall;
	StartItem ("models/items/g_h1.md3", "misc/minihealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Health", IT_5HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_health_medium (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthmedium_max;
	if(!self.health)
		self.health = g_pickup_healthmedium;
	StartItem ("models/items/g_h25.md3", "misc/mediumhealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "25 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_health_large (void) {
	if(!self.max_health)
		self.max_health = g_pickup_healthlarge_max;
	if(!self.health)
		self.health = g_pickup_healthlarge;
	StartItem ("models/items/g_h50.md3", "misc/mediumhealth.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "50 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
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
		StartItem ("models/items/g_h100.md3", "misc/megahealth.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Health", IT_HEALTH, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
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
		StartItem ("models/items/g_strength.md3", "misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Strength Powerup", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
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
		StartItem ("models/items/g_invincible.md3", "misc/powerup_shield.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Shield", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}

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

float target_item_func_set(float a, float b)
{
	if(b == 0)
		return a;
	else if(b < 0)
		return 0;
	else
		return b;
}

float target_item_func_min(float a, float b)
{
	if(b == 0)
		return a;
	else if(b < 0)
		return 0;
	else
		return min(a, b);
}

float target_item_func_max(float a, float b)
{
	return max(a, b);
}

float target_item_func_bitset(float a, float b)
{
	return b;
}

float target_item_func_and(float a, float b)
{
	return a & b;
}

float target_item_func_itembitset(float a, float b)
{
	return (a - (a & (IT_PICKUPMASK | IT_STRENGTH | IT_INVINCIBLE))) | b;
}

float target_item_func_itemand(float a, float b)
{
	return (a - (a & (IT_PICKUPMASK | IT_STRENGTH | IT_INVINCIBLE))) | (a & b);
}

float target_item_func_or(float a, float b)
{
	return a | b;
}

float target_item_func_andnot(float a, float b)
{
	return a - (a & b);
}

float target_item_changed;
void target_item_change(float binary, .float field, float(float a, float b) func, string sound_increase, string sound_decrease)
{
	float n, d;
	n = func(activator.field, self.field);

	if(binary)
	{
		d = n & activator.field;
		if(d != n) // bits added?
			d = +1;
		else if(d != activator.field) // bits removed?
			d = -1;
		else
			d = 0;
	}
	else
		d = n - activator.field;

	if(d < 0)
	{
		if(sound_decrease != "")
			sound (activator, CHAN_AUTO, sound_decrease, VOL_BASE, ATTN_NORM);
		target_item_changed = 1;
	}
	else if(d > 0)
	{
		if(sound_increase != "")
			sound (activator, CHAN_AUTO, sound_increase, VOL_BASE, ATTN_NORM);
		target_item_changed = 1;
	}
	activator.field = n;
}

void target_items_use (void)
{
	float h0, a0;

	if(activator.classname == "droppedweapon")
	{
		EXACTTRIGGER_TOUCH;
		remove(activator);
		return;
	}

	if(activator.classname != "player")
		return;
	if(activator.deadflag != DEAD_NO)
		return;
	EXACTTRIGGER_TOUCH;

	entity e;
	for(e = world; (e = find(e, classname, "droppedweapon")); )
		if(e.enemy == activator)
			remove(e);

	float _switchweapon;
	_switchweapon = FALSE;
	if (activator.autoswitch)
		if (activator.switchweapon == w_getbestweapon(activator))
			_switchweapon = TRUE;

	a0 = activator.armorvalue;
	h0 = activator.health;
	target_item_changed = 0;

	if(self.spawnflags == 0) // SET
	{
		target_item_change(0, ammo_shells, target_item_func_set, "misc/itempickup.wav", "");
		target_item_change(0, ammo_nails, target_item_func_set, "misc/itempickup.wav", "");
		target_item_change(0, ammo_rockets, target_item_func_set, "misc/itempickup.wav", "");
		target_item_change(0, ammo_cells, target_item_func_set, "misc/itempickup.wav", "");
		target_item_change(0, ammo_fuel, target_item_func_set, "misc/itempickup.wav", "");
		target_item_change(0, health, target_item_func_set, "misc/megahealth.wav", "");
		target_item_change(0, armorvalue, target_item_func_set, "misc/armor25.wav", "");
		target_item_change(1, items, target_item_func_itembitset, "misc/powerup.wav", "misc/poweroff.wav");
		target_item_change(1, weapons, target_item_func_bitset, "weapons/weaponpickup.wav", "");

		if((self.items & activator.items) & IT_STRENGTH)
			activator.strength_finished = time + self.strength_finished;
		if((self.items & activator.items) & IT_INVINCIBLE)
			activator.invincible_finished = time + self.invincible_finished;
	}
	else if(self.spawnflags == 1) // AND/MIN
	{
		target_item_change(0, ammo_shells, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_nails, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_rockets, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_cells, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_fuel, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, health, target_item_func_min, "misc/megahealth.wav", "");
		target_item_change(0, armorvalue, target_item_func_min, "misc/armor25.wav", "");
		target_item_change(1, items, target_item_func_itemand, "misc/powerup.wav", "misc/poweroff.wav");
		target_item_change(1, weapons, target_item_func_and, "weapons/weaponpickup.wav", "");

		if((self.items & activator.items) & IT_STRENGTH)
			activator.strength_finished = min(activator.strength_finished, time + self.strength_finished);
		if((self.items & activator.items) & IT_INVINCIBLE)
			activator.invincible_finished = min(activator.invincible_finished, time + self.invincible_finished);
	}
	else if(self.spawnflags == 2) // OR/MAX
	{
		target_item_change(0, ammo_shells, target_item_func_max, "misc/itempickup.wav", "");
		target_item_change(0, ammo_nails, target_item_func_max, "misc/itempickup.wav", "");
		target_item_change(0, ammo_rockets, target_item_func_max, "misc/itempickup.wav", "");
		target_item_change(0, ammo_cells, target_item_func_max, "misc/itempickup.wav", "");
		target_item_change(0, ammo_fuel, target_item_func_max, "misc/itempickup.wav", "");
		target_item_change(0, health, target_item_func_max, "misc/megahealth.wav", "");
		target_item_change(0, armorvalue, target_item_func_max, "misc/armor25.wav", "");
		target_item_change(1, items, target_item_func_or, "misc/powerup.wav", "misc/poweroff.wav");
		target_item_change(1, weapons, target_item_func_or, "weapons/weaponpickup.wav", "");

		if((self.items & activator.items) & IT_STRENGTH)
			activator.strength_finished = max(activator.strength_finished, time + self.strength_finished);
		if((self.items & activator.items) & IT_INVINCIBLE)
			activator.invincible_finished = max(activator.invincible_finished, time + self.invincible_finished);
	}
	else if(self.spawnflags == 4) // ANDNOT/MIN
	{
		target_item_change(0, ammo_shells, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_nails, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_rockets, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_cells, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, ammo_fuel, target_item_func_min, "misc/itempickup.wav", "");
		target_item_change(0, health, target_item_func_min, "misc/megahealth.wav", "");
		target_item_change(0, armorvalue, target_item_func_min, "misc/armor25.wav", "");
		target_item_change(1, items, target_item_func_andnot, "misc/powerup.wav", "misc/poweroff.wav");
		target_item_change(1, weapons, target_item_func_andnot, "weapons/weaponpickup.wav", "");

		if((self.items & activator.items) & IT_STRENGTH)
			activator.strength_finished = min(activator.strength_finished, time + self.strength_finished);
		if((self.items & activator.items) & IT_INVINCIBLE)
			activator.invincible_finished = min(activator.invincible_finished, time + self.invincible_finished);
	}

	if not(activator.items & IT_STRENGTH)
		activator.strength_finished = 0;
	if not(activator.items & IT_INVINCIBLE)
		activator.invincible_finished = 0;

	if(activator.health > h0)
		activator.pauserothealth_finished = max(activator.pauserothealth_finished, time + cvar("g_balance_pause_health_rot"));
	else if(activator.health < h0)
		activator.pauseregen_finished = max(activator.pauseregen_finished, time + cvar("g_balance_pause_health_regen"));

	if(activator.armorvalue > a0)
		activator.pauserotarmor_finished = max(activator.pauserothealth_finished, time + cvar("g_balance_pause_health_rot"));

	if not(activator.weapons & W_WeaponBit(activator.switchweapon))
		_switchweapon = TRUE;
	if(_switchweapon)
		W_SwitchWeapon_Force(activator, w_getbestweapon(activator));

	if(target_item_changed)
		centerprint(activator, self.message);
}

void spawnfunc_target_items (void)
{
	float n, i, j;
	entity e;
	self.use = target_items_use;
	if(!self.strength_finished)
		self.strength_finished = cvar("g_balance_powerup_strength_time");
	if(!self.invincible_finished)
		self.invincible_finished = cvar("g_balance_powerup_invincible_time");

	precache_sound("misc/itempickup.wav");
	precache_sound("misc/itempickup.wav");
	precache_sound("misc/itempickup.wav");
	precache_sound("misc/itempickup.wav");
	precache_sound("misc/megahealth.wav");
	precache_sound("misc/armor25.wav");
	precache_sound("misc/powerup.wav");
	precache_sound("misc/poweroff.wav");
	precache_sound("weapons/weaponpickup.wav");

	n = tokenize_console(self.netname);
	for(i = 0; i < n; ++i)
	{
		if(argv(i) == "unlimited_ammo")         self.items |= IT_UNLIMITED_AMMO;
		if(argv(i) == "unlimited_weapon_ammo")  self.items |= IT_UNLIMITED_WEAPON_AMMO;
		if(argv(i) == "unlimited_superweapons") self.items |= IT_UNLIMITED_SUPERWEAPONS;
		if(argv(i) == "strength")               self.items |= IT_STRENGTH;
		if(argv(i) == "invincible")             self.items |= IT_INVINCIBLE;
		if(argv(i) == "jetpack")                self.items |= IT_JETPACK;
		if(argv(i) == "fuel_regen")             self.items |= IT_FUEL_REGEN;
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
			{
				self.weapons |= e.weapons;
				if(self.spawnflags == 0 || self.spawnflags == 2)
					weapon_action(e.weapon, WR_PRECACHE);
			}
		}
	}
}

void spawnfunc_item_fuel(void)
{
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel;
	StartItem ("models/items/g_fuel.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "Fuel", IT_FUEL, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_fuel_regen(void)
{
	if(start_items & IT_FUEL_REGEN)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_fuelregen.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Fuel regenerator", IT_FUEL_REGEN, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_jetpack(void)
{
	if(g_grappling_hook)
		return; // sorry, but these two can't coexist (same button); spawn fuel instead
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel_jetpack;
	if(start_items & IT_JETPACK)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_jetpack.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Jet pack", IT_JETPACK, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}
