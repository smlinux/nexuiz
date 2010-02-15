#define ITEM_RESPAWN_TICKS 10

#define ITEM_RESPAWNTIME(i)         ((i).respawntime + crandom() * (i).respawntimejitter)
	// range: respawntime - respawntimejitter .. respawntime + respawntimejitter
#define ITEM_RESPAWNTIME_INITIAL(i) (ITEM_RESPAWN_TICKS + random() * ((i).respawntime + (i).respawntimejitter - ITEM_RESPAWN_TICKS))
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

float Item_Customize()
{
	if(self.spawnshieldtime)
		return TRUE;
	if(self.weapons != (self.weapons & other.weapons))
	{
		self.colormod = '0 0 0';
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		self.alpha = 0.5 + 0.5 * g_ghost_items; // halfway more alpha
		return TRUE;
	}
	else
	{
		if(g_ghost_items)
		{
			self.colormod = stov(cvar_string("g_ghost_items_color"));
			if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
				self.glowmod = self.colormod;
			self.alpha = g_ghost_items;
			return TRUE;
		}
		else
			return FALSE;
	}
}

void Item_Show (entity e, float mode)
{
	e.effects &~= EF_ADDITIVE | EF_STARDUST | EF_FULLBRIGHT | EF_NODEPTHTEST;
	if (mode > 0)
	{
		// make the item look normal, and be touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER;
		e.colormod = '0 0 0';
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		e.alpha = 0;
		e.customizeentityforclient = func_null;

		e.spawnshieldtime = 1;
	}
	else if (mode < 0)
	{
		// hide the item completely
		e.model = string_null;
		e.solid = SOLID_NOT;
		e.colormod = '0 0 0';
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		e.alpha = 0;
		e.customizeentityforclient = func_null;

		e.spawnshieldtime = 1;
	}
	else if((e.flags & FL_WEAPON) && (g_weapon_stay == 3))
	{
		// make the item translucent green and not touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER; // can STILL be picked up!
		e.colormod = '0 0 0';
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		e.effects |= EF_STARDUST;
		e.customizeentityforclient = Item_Customize;

		e.spawnshieldtime = 0; // field indicates whether picking it up may give you anything other than the weapon
	}
	else if(g_ghost_items)
	{
		// make the item translucent green and not touchable
		e.model = e.mdl;
		e.solid = SOLID_NOT;
		e.colormod = stov(cvar_string("g_ghost_items_color"));
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		e.alpha = g_ghost_items;
		e.customizeentityforclient = func_null;

		e.spawnshieldtime = 1;
	}
	else
	{
		// hide the item completely
		e.model = string_null;
		e.solid = SOLID_NOT;
		e.colormod = stov(cvar_string("g_ghost_items_color"));
		if(cvar("gameversion") >= 20600) // only do this for 2.6 and above FIXME remove this check when making 2.6
			self.glowmod = self.colormod;
		e.alpha = 0;
		e.customizeentityforclient = func_null;

		e.spawnshieldtime = 1;
	}

	if (e.strength_finished || e.invincible_finished)
		e.effects |= EF_ADDITIVE | EF_FULLBRIGHT;
	if (cvar("g_nodepthtestitems"))
		e.effects |= EF_NODEPTHTEST;
	if (cvar("g_fullbrightitems"))
		e.effects |= EF_FULLBRIGHT;

	// relink entity (because solid may have changed)
	setorigin(e, e.origin);
}

void Item_Respawn (void)
{
	Item_Show(self, 1);
	if(!g_minstagib && self.items == IT_STRENGTH)
		sound (self, CHAN_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	else if(!g_minstagib && self.items == IT_INVINCIBLE)
		sound (self, CHAN_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	else
		sound (self, CHAN_TRIGGER, "misc/itemrespawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);

	//pointparticles(particleeffectnum("item_respawn"), self.origin + self.mins_z * '0 0 1' + '0 0 48', '0 0 0', 1);
	pointparticles(particleeffectnum("item_respawn"), self.origin + 0.5 * (self.mins + self.maxs), '0 0 0', 1);
}

void Item_RespawnCountdown (void)
{
	if(self.count >= ITEM_RESPAWN_TICKS)
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
				WaypointSprite_Spawn(name, 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, TRUE);
				if(self.waypointsprite_attached)
				{
					WaypointSprite_UpdateTeamRadar(self.waypointsprite_attached, RADARICON_POWERUP, rgb);
					//WaypointSprite_UpdateMaxHealth(self.waypointsprite_attached, ITEM_RESPAWN_TICKS + 1);
					WaypointSprite_UpdateBuildFinished(self.waypointsprite_attached, time + ITEM_RESPAWN_TICKS);
				}
			}
		}
		sound (self, CHAN_TRIGGER, "misc/itemrespawncountdown.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
		if(self.waypointsprite_attached)
		{
			WaypointSprite_Ping(self.waypointsprite_attached);
			//WaypointSprite_UpdateHealth(self.waypointsprite_attached, self.count);
		}
	}
}

void Item_ScheduleRespawnIn(entity e, float t)
{
	if(e.flags & FL_POWERUP)
	{
		e.think = Item_RespawnCountdown;
		e.nextthink = time + max(0, t - ITEM_RESPAWN_TICKS);
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
	Item_Show(e, 0);
	Item_ScheduleRespawnIn(e, ITEM_RESPAWNTIME(e));
}

void Item_ScheduleInitialRespawn(entity e)
{
	Item_Show(e, 0);
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
		if(item.spawnshieldtime)
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
				if (clienttype(player) == CLIENTTYPE_REAL)
				{
					if(player.health <= 5)
						AnnounceTo(player, "lastsecond");
					else if(player.health < 50)
						AnnounceTo(player, "narrowly");
				}
				// sound not available
				// else if(item.items == IT_CELLS)
				//	AnnounceTo(player, "ammo");

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
				// AnnounceTo(player, "_lives");
				player.armorvalue = player.armorvalue + cvar("g_minstagib_extralives");
				sprint(player, "^3You picked up some extra lives\n");
			}

			// invis powerup
			if (item.strength_finished)
			{
				pickedup = TRUE;
				// sound not available
				// AnnounceTo(player, "invisible");
				player.strength_finished = max(player.strength_finished, time) + cvar("g_balance_powerup_strength_time");
			}

			// speed powerup
			if (item.invincible_finished)
			{
				pickedup = TRUE;
				// sound not available
				// AnnounceTo(player, "speed");
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

		if(item.spawnshieldtime)
		{
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

		if(item.spawnshieldtime)
		{
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
	else if not(self.spawnshieldtime)
		return;
	else if((self.flags & FL_WEAPON) && !(self.flags & FL_NO_WEAPON_STAY) && (g_weapon_stay == 1 || g_weapon_stay == 2))
		return;
	else
	{
		if(self.team)
		{
			RandomSelection_Init();
			for(head = world; (head = findfloat(head, team, self.team)); )
			{
				if(head.flags & FL_ITEM)
				{
					Item_Show(head, -1);
					RandomSelection_Add(head, 0, string_null, head.cnt, 0);
				}
			}
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
		Item_Show(e, 1);

		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
		{
			if(head != e)
			{
				// make it a non-spawned item
				Item_Show(head, -1);
				head.state = 1; // state 1 = initially hidden item
			}
			head.effects &~= EF_NODRAW;
		}

		if(e.flags & FL_POWERUP) // do not spawn powerups initially!
			Item_ScheduleInitialRespawn(e);
	}
}

void Item_Reset()
{
	Item_Show(self, !self.state);
	setorigin (self, self.origin);
	self.think = SUB_Null;
	self.nextthink = 0;

	if(self.flags & FL_POWERUP) // do not spawn powerups initially!
		Item_ScheduleInitialRespawn(self);
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
	float c, i, j, position;

	// See if I have it already
	if(player.weapons & item.weapons == item.weapons)
	{
		// If I can pick it up
		if(g_weapon_stay == 1 || g_weapon_stay == 2 || !item.spawnshieldtime)
			c = 0;
		else if(player.ammo_cells || player.ammo_shells || player.ammo_nails || player.ammo_rockets)
		{
			// Skilled bots will grab more
			c = bound(0, skill / 10, 1) * 0.5;
		}
		else
			c = 0;
	}
	else
		c = 1;

	// If custom weapon priorities for bots is enabled rate most wanted weapons higher
	if( bot_custom_weapon && c )
	{
		for(i = WEP_FIRST; i < WEP_LAST ; ++i)
		{
			// Find weapon
			if( (get_weaponinfo(i)).weapons & item.weapons  != item.weapons )
				continue;

			// Find the highest position on any range
			position = -1;
			for(j = 0; j < WEP_LAST ; ++j){
				if(
						bot_weapons_far[j] == i ||
						bot_weapons_mid[j] == i ||
						bot_weapons_close[j] == i
				  )
				{
					position = j;
					break;
				}
			}

			// Rate it
			if (position >= 0 )
			{
				position = WEP_LAST - position;
				// item.bot_pickupbasevalue is overwritten here
				return (BOT_PICKUP_RATING_LOW + ( (BOT_PICKUP_RATING_HIGH - BOT_PICKUP_RATING_LOW) * (position / WEP_LAST ))) * c;
			}
		}
	}

	return item.bot_pickupbasevalue * c;
};

float commodity_pickupevalfunc(entity player, entity item)
{
	float c, i, need_shells, need_nails, need_rockets, need_cells;
	entity wi;
	c = 0;

	// Detect needed ammo
	for(i = WEP_FIRST; i < WEP_LAST ; ++i)
	{
		wi = get_weaponinfo(i);

		if not(wi.weapons & player.weapons)
			continue;

		if(wi.items & IT_SHELLS)
			need_shells = TRUE;
		else if(wi.items & IT_NAILS)
			need_nails = TRUE;
		else if(wi.items & IT_ROCKETS)
			need_rockets = TRUE;
		else if(wi.items & IT_CELLS)
			need_cells = TRUE;
	}

	// TODO: figure out if the player even has the weapon this ammo is for?
	// may not affect strategy much though...
	// find out how much more ammo/armor/health the player can hold
	if (need_shells)
	if (item.ammo_shells)
	if (player.ammo_shells < g_pickup_shells_max)
		c = c + max(0, 1 - player.ammo_shells / g_pickup_shells_max);
	if (need_nails)
	if (item.ammo_nails)
	if (player.ammo_nails < g_pickup_nails_max)
		c = c + max(0, 1 - player.ammo_nails / g_pickup_nails_max);
	if (need_rockets)
	if (item.ammo_rockets)
	if (player.ammo_rockets < g_pickup_rockets_max)
		c = c + max(0, 1 - player.ammo_rockets / g_pickup_rockets_max);
	if (need_cells)
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

		if(g_lms || g_ca)
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
		else if (g_nixnex)
		{
			local float rm;

			rm = 1;
			switch (itemid)
			{
				case IT_HEALTH:
				case IT_5HP:
				case IT_25HP:
				case IT_ARMOR:
				case IT_ARMOR_SHARD:
					if (cvar("g_nixnex_with_healtharmor"))
						rm = 0;
					break;
				case IT_STRENGTH:
				case IT_INVINCIBLE:
					if (cvar("g_nixnex_with_powerups"))
						rm = 0;
					break;
			}

			if(rm)
			{
				startitem_failed = TRUE;
				remove (self);
				return;
			}
		}
		else if (!cvar("g_pickup_items") && itemid != IT_STRENGTH && itemid != IT_INVINCIBLE && itemid != IT_HEALTH)
		{
			startitem_failed = TRUE;
			remove (self);
			return;
		}

		precache_model (itemmodel);
		precache_sound (pickupsound);
		precache_sound ("misc/itemrespawn.wav");
		precache_sound ("misc/itemrespawncountdown.wav");

		if(itemid == IT_STRENGTH)
			precache_sound ("misc/strength_respawn.wav");
		if(itemid == IT_INVINCIBLE)
			precache_sound ("misc/shield_respawn.wav");

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

	Item_Show(self, 1);
	self.state = 0;
	if(self.team)
	{
		if(!self.cnt)
			self.cnt = 1; // item probability weight
		self.effects = self.effects | EF_NODRAW; // marker for item team search
		InitializeEntity(self, Item_FindTeam, INITPRIO_FINDTARGET);
	}
	else if(self.flags & FL_POWERUP) // do not spawn powerups initially!
		Item_ScheduleInitialRespawn(self);
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

	if((g_arena || g_ca) && !cvar("g_arena_powerups"))
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

	if((g_arena || g_ca) && !cvar("g_arena_powerups"))
		return;

	if(g_minstagib) {
		minstagib_items(IT_STRENGTH);
	} else {
		precache_sound("weapons/strength_fire.wav");
		self.strength_finished = 30;
		StartItem ("models/items/g_strength.md3", "misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Strength Powerup", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}

void spawnfunc_item_invincible (void) {
	if(!cvar("g_powerup_shield"))
		return;

	if((g_arena || g_ca) && !cvar("g_arena_powerups"))
		return;

	if(g_minstagib) {
		minstagib_items(IT_INVINCIBLE);
	} else {
		self.invincible_finished = 30;
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

float GiveItems(entity e, float beginarg, float endarg);
void target_items_use (void)
{
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

	if(GiveItems(activator, 0, tokenize_console(self.netname)))
		centerprint(activator, self.message);
}

void spawnfunc_target_items (void)
{
	float n, i, j;
	entity e;

	if(g_nixnex)
	{
		// items triggers cannot work in nixnex (as they change weapons/ammo)
		remove(self);
		return;
	}

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
	if(argv(0) == "give")
	{
		self.netname = substring(self.netname, argv_start_index(1), argv_end_index(-1) - argv_start_index(1));
	}
	else
	{
		for(i = 0; i < n; ++i)
		{
			if     (argv(i) == "unlimited_ammo")         self.items |= IT_UNLIMITED_AMMO;
			else if(argv(i) == "unlimited_weapon_ammo")  self.items |= IT_UNLIMITED_WEAPON_AMMO;
			else if(argv(i) == "unlimited_superweapons") self.items |= IT_UNLIMITED_SUPERWEAPONS;
			else if(argv(i) == "strength")               self.items |= IT_STRENGTH;
			else if(argv(i) == "invincible")             self.items |= IT_INVINCIBLE;
			else if(argv(i) == "jetpack")                self.items |= IT_JETPACK;
			else if(argv(i) == "fuel_regen")             self.items |= IT_FUEL_REGEN;
			else
			for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if(argv(i) == e.netname)
				{
					self.weapons |= e.weapons;
					if(self.spawnflags == 0 || self.spawnflags == 2)
						weapon_action(e.weapon, WR_PRECACHE);
					break;
				}
			}
			if(j > WEP_LAST)
				print("target_items: invalid item ", argv(i), "\n");
		}

		string itemprefix, valueprefix;
		if(self.spawnflags == 0)
		{
			itemprefix = "";
			valueprefix = "";
		}
		else if(self.spawnflags == 1)
		{
			itemprefix = "max ";
			valueprefix = "max ";
		}
		else if(self.spawnflags == 2)
		{
			itemprefix = "min ";
			valueprefix = "min ";
		}
		else if(self.spawnflags == 4)
		{
			itemprefix = "minus ";
			valueprefix = "max ";
		}
		else
			error("invalid spawnflags");

		self.netname = "";
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_WEAPON_AMMO), "unlimited_weapon_ammo");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_SUPERWEAPONS), "unlimited_superweapons");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.strength_finished * !!(self.items & IT_STRENGTH), "strength");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.invincible_finished * !!(self.items & IT_INVINCIBLE), "invincible");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_JETPACK), "jetpack");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_FUEL_REGEN), "fuel_regen");
		if(self.ammo_shells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_shells), "shells");
		if(self.ammo_nails != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_nails), "nails");
		if(self.ammo_rockets != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_rockets), "rockets");
		if(self.ammo_cells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_cells), "cells");
		if(self.ammo_fuel != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_fuel), "fuel");
		if(self.health != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "health");
		if(self.armorvalue != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "armor");
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(e.weapons)
				self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.weapons & e.weapons), e.netname);
		}
	}
	self.netname = strzone(self.netname);
	//print(self.netname, "\n");

	n = tokenize_console(self.netname);
	for(i = 0; i < n; ++i)
	{
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
			{
				weapon_action(e.weapon, WR_PRECACHE);
				break;
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

// we no longer have the seeker
void spawnfunc_weapon_seeker()
{
	spawnfunc_weapon_fireball();
}


#define OP_SET 0
#define OP_MIN 1
#define OP_MAX 2
#define OP_PLUS 3
#define OP_MINUS 4

float GiveBit(entity e, .float fld, float bit, float op, float val)
{
	float v0, v1;
	v0 = (e.fld & bit);
	switch(op)
	{
		case OP_SET:
			if(val > 0)
				e.fld |= bit;
			else
				e.fld &~= bit;
			break;
		case OP_MIN:
		case OP_PLUS:
			if(val > 0)
				e.fld |= bit;
			break;
		case OP_MAX:
			if(val <= 0)
				e.fld &~= bit;
			break;
		case OP_MINUS:
			if(val > 0)
				e.fld &~= bit;
			break;
	}
	v1 = (e.fld & bit);
	return (v0 != v1);
}

float GiveValue(entity e, .float fld, float op, float val)
{
	float v0, v1;
	v0 = e.fld;
	switch(op)
	{
		case OP_SET:
			e.fld = val;
			break;
		case OP_MIN:
			e.fld = max(e.fld, val); // min 100 cells = at least 100 cells
			break;
		case OP_MAX:
			e.fld = min(e.fld, val);
			break;
		case OP_PLUS:
			e.fld += val;
			break;
		case OP_MINUS:
			e.fld -= val;
			break;
	}
	v1 = e.fld;
	return (v0 != v1);
}

void GiveSound(entity e, float v0, float v1, float t, string snd_incr, string snd_decr)
{
	if(v1 == v0)
		return;
	if(v1 <= v0 - t)
	{
		if(snd_decr != "")
			sound (e, CHAN_AUTO, snd_decr, VOL_BASE, ATTN_NORM);
	}
	else if(v0 >= v0 + t)
	{
		if(snd_incr != "")
			sound (e, CHAN_AUTO, snd_incr, VOL_BASE, ATTN_NORM);
	}
}

void GiveRot(entity e, float v0, float v1, .float rotfield, float rottime, .float regenfield, float regentime)
{
	if(v0 < v1)
		e.rotfield = max(e.rotfield, time + rottime);
	else if(v0 > v1)
		e.regenfield = max(e.regenfield, time + regentime);
}

#define PREGIVE(e,f) float save_##f; save_##f = (e).f
#define POSTGIVE_BIT(e,f,b,snd_incr,snd_decr) GiveSound((e), save_##f & (b), (e).f & (b), 0, snd_incr, snd_decr)
#define POSTGIVE_VALUE(e,f,t,snd_incr,snd_decr) GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)
#define POSTGIVE_VALUE_ROT(e,f,t,rotfield,rottime,regenfield,regentime,snd_incr,snd_decr) GiveRot((e), save_##f, (e).f, rotfield, rottime, regenfield, regentime); GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)

float GiveItems(entity e, float beginarg, float endarg)
{
	float got, i, j, val, op;
	float _switchweapon;
	entity wi;
	string cmd;

	val = 999;
	op = OP_SET;

	got = 0;

	_switchweapon = FALSE;
	if (e.autoswitch)
		if (e.switchweapon == w_getbestweapon(e))
			_switchweapon = TRUE;

	e.strength_finished = max(0, e.strength_finished - time);
	e.invincible_finished = max(0, e.invincible_finished - time);
	
	PREGIVE(e, items);
	PREGIVE(e, weapons);
	PREGIVE(e, strength_finished);
	PREGIVE(e, invincible_finished);
	PREGIVE(e, ammo_nails);
	PREGIVE(e, ammo_cells);
	PREGIVE(e, ammo_shells);
	PREGIVE(e, ammo_rockets);
	PREGIVE(e, ammo_fuel);
	PREGIVE(e, armorvalue);
	PREGIVE(e, health);

	for(i = beginarg; i < endarg; ++i)
	{
		cmd = argv(i);

		if(cmd == "0" || stof(cmd))
		{
			val = stof(cmd);
			continue;
		}
		switch(cmd)
		{
			case "no":
				op = OP_MAX;
				val = 0;
				continue;
			case "max":
				op = OP_MAX;
				continue;
			case "min":
				op = OP_MIN;
				continue;
			case "plus":
				op = OP_PLUS;
				continue;
			case "minus":
				op = OP_MINUS;
				continue;
			case "ALL":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				got += GiveValue(e, strength_finished, op, time + val);
				got += GiveValue(e, invincible_finished, op, time + val);
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
			case "all":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				got += GiveValue(e, health, op, val);
				got += GiveValue(e, armorvalue, op, val);
			case "allweapons":
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(wi.weapons)
						got += GiveBit(e, weapons, wi.weapons, op, val);
				}
			case "allammo":
				got += GiveValue(e, ammo_cells, op, val);
				got += GiveValue(e, ammo_shells, op, val);
				got += GiveValue(e, ammo_nails, op, val);
				got += GiveValue(e, ammo_rockets, op, val);
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			case "unlimited_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
				break;
			case "unlimited_weapon_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_WEAPON_AMMO, op, val);
				break;
			case "unlimited_superweapons":
				got += GiveBit(e, items, IT_UNLIMITED_SUPERWEAPONS, op, val);
				break;
			case "jetpack":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				break;
			case "fuel_regen":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				break;
			case "strength":
				got += GiveValue(e, strength_finished, op, val);
				break;
			case "invincible":
				got += GiveValue(e, invincible_finished, op, val);
				break;
			case "cells":
				got += GiveValue(e, ammo_cells, op, val);
				break;
			case "shells":
				got += GiveValue(e, ammo_shells, op, val);
				break;
			case "nails":
			case "bullets":
				got += GiveValue(e, ammo_nails, op, val);
				break;
			case "rockets":
				got += GiveValue(e, ammo_rockets, op, val);
				break;
			case "health":
				got += GiveValue(e, health, op, val);
				break;
			case "armor":
				got += GiveValue(e, armorvalue, op, val);
				break;
			case "fuel":
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			default:
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(cmd == wi.netname)
					{
						got += GiveBit(e, weapons, wi.weapons, op, val);
						break;
					}
				}
				if(j > WEP_LAST)
					print("give: invalid item ", cmd, "\n");
				break;
		}
		val = 999;
		op = OP_SET;
	}

	POSTGIVE_BIT(e, items, IT_FUEL_REGEN, "misc/itempickup.wav", string_null);
	POSTGIVE_BIT(e, items, IT_UNLIMITED_SUPERWEAPONS, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_UNLIMITED_WEAPON_AMMO, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_JETPACK, "misc/itempickup.wav", string_null);
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
	{
		wi = get_weaponinfo(j);
		if(wi.weapons)
		{
			POSTGIVE_BIT(e, weapons, wi.weapons, "weapons/weaponpickup.wav", string_null);
			if not(save_weapons & wi.weapons)
				if(e.weapons & wi.weapons)
					weapon_action(wi.weapon, WR_PRECACHE);
		}
	}
	POSTGIVE_VALUE(e, strength_finished, 1, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, invincible_finished, 1, "misc/powerup_shield.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, ammo_nails, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_cells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_shells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_rockets, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, ammo_fuel, 1, pauserotfuel_finished, cvar("g_balance_pause_fuel_rot"), pauseregen_finished, cvar("g_balance_pause_fuel_regen"), "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, armorvalue, 1, pauserotarmor_finished, cvar("g_balance_pause_armor_rot"), pauseregen_finished, cvar("g_balance_pause_health_regen"), "misc/armor25.wav", string_null);
	POSTGIVE_VALUE_ROT(e, health, 1, pauserothealth_finished, cvar("g_balance_pause_health_rot"), pauseregen_finished, cvar("g_balance_pause_health_regen"), "misc/megahealth.wav", string_null);

	if(e.strength_finished <= 0)
		e.strength_finished = 0;
	else
		e.strength_finished += time;
	if(e.invincible_finished <= 0)
		e.invincible_finished = 0;
	else
		e.invincible_finished += time;

	if not(e.weapons & W_WeaponBit(e.switchweapon))
		_switchweapon = TRUE;
	if(_switchweapon)
		W_SwitchWeapon_Force(e, w_getbestweapon(e));

	return got;
}
