
.float havocbot_role_timeout;
.void() havocbot_previous_role;
.void() havocbot_role;
float bot_ignore_bots;

.float max_armorvalue;
float havocbot_pickupevalfunc(entity item)
{
	float i, j, rating, base, position, need_shells, need_nails, need_rockets, need_cells;
	rating = 0;

	base = item.bot_pickupbasevalue;

	need_shells = self.weapons & WEPBIT_SHOTGUN;
	need_nails = self.weapons & WEPBIT_UZI;
	need_cells = self.weapons & ( WEPBIT_HOOK | WEPBIT_HLAC | WEPBIT_MINSTANEX | WEPBIT_NEX | WEPBIT_ELECTRO | WEPBIT_CRYLINK );
	need_rockets = self.weapons & ( WEPBIT_ROCKET_LAUNCHER | WEPBIT_GRENADE_LAUNCHER | WEPBIT_HAGAR | WEPBIT_SEEKER );

	// Rate ammo items
	if (item.ammo_shells)
	if (self.ammo_shells < g_pickup_shells_max && need_cells )
		rating = rating + max(0, 1 - self.ammo_shells / g_pickup_shells_max);

	if (item.ammo_nails)
	if (self.ammo_nails < g_pickup_nails_max && need_nails )
		rating = rating + max(0, 1 - self.ammo_nails / g_pickup_nails_max);

	if (item.ammo_rockets)
	if (self.ammo_rockets < g_pickup_rockets_max && need_rockets)
		rating = rating + max(0, 1 - self.ammo_rockets / g_pickup_rockets_max);

	if (item.ammo_cells)
	if (self.ammo_cells < g_pickup_cells_max && need_cells)
		rating = rating + max(0, 1 - self.ammo_cells / g_pickup_cells_max);

	// Rate health items (aim to grab half the max capacity)
	if (item.armorvalue)
	if (self.armorvalue < item.max_armorvalue * 0.5)
		rating = rating + max(0, 1 - self.armorvalue / (item.max_armorvalue * 0.5));

	if (item.health)
	if (self.health < item.max_health * 0.5)
	{
		rating = rating + max(0, 1 - self.health / (item.max_health * 0.5));
	}

	// Rate weapons
	if( item.weapons )
	{
		// See if I have it already
		if( self.weapons & item.weapons == item.weapons )
		{
			// If I can pick it up
			if(rating)
			if not(cvar("g_weapon_stay"))
			{
				// Skilled bots will grab more
				local float divisor = 2;
				rating += bound(0, skill / (10*divisor), 1/divisor);
			}
		}
		else
			rating += 1;

		// If custom weapon priorities for bots is enabled rate most wanted weapons higher
		if( bot_custom_weapon && rating )
		{
			for(i = WEP_FIRST; i < WEP_LAST ; ++i)
			{
				// Find weapon
				if( power2of(i-1) & item.weapons  != item.weapons )
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
					base = BOT_PICKUP_RATING_LOW + ( (BOT_PICKUP_RATING_HIGH - BOT_PICKUP_RATING_LOW) * (position / WEP_LAST ));
					break;
				}
			}
		}
	}

	// TODO: if the item is not recognized then default to item.bot_pickupevalfunc(self, item);
	return base * rating;
};

void havocbot_goalrating_items(float ratingscale, vector org, float sradius)
{
	local entity head;
	local entity player;
	local float rating, d, discard, distance, friend_distance, enemy_distance;
	ratingscale = ratingscale * 0.0001; // items are rated around 10000 already
	head = findchainfloat(bot_pickup, TRUE);

	while (head)
	{
		distance = vlen(head.origin - org);
		friend_distance = 10000; enemy_distance = 10000;
		rating = 0;

		if(!head.solid || distance > sradius || (head == self.ignoregoal && time < self.ignoregoaltime) )
		{
			head = head.chain;
			continue;
		}

		// Check if the item can be picked up safely
		if(head.classname == "droppedweapon")
		{
			traceline(head.origin, head.origin + '0 0 -1500', TRUE, world);

			d = pointcontents(trace_endpos + '0 0 1');
			if(d & CONTENT_WATER || d & CONTENT_SLIME || d & CONTENT_LAVA)
			{
				head = head.chain;
				continue;
			}
			if(tracebox_hits_trigger_hurt(head.origin, head.mins, head.maxs, trace_endpos))
			{
				head = head.chain;
				continue;
			}
		}
		else
		{
			// Ignore items under water
			traceline(head.origin + head.maxs, head.origin + head.maxs, MOVE_NORMAL, head);
			if(trace_dpstartcontents & DPCONTENTS_LIQUIDSMASK)
			{
				head = head.chain;
				continue;
			}
		}

		if(teams_matter)
		{
			discard = FALSE;

			FOR_EACH_PLAYER(player)
			{

				if ( self == player || player.deadflag )
					continue;

				d = vlen(player.origin - head.origin); // distance between player and item

				if ( player.team == self.team )
				{
					if ( clienttype(player) != CLIENTTYPE_REAL || discard )
						continue;

					if( d > friend_distance)
						continue;

					friend_distance = d;

					discard = TRUE;

					if( head.health && player.health > self.health )
						continue;

					if( head.armorvalue && player.armorvalue > self.armorvalue)
						continue;

					if( head.weapons )
					if( (player.weapons & head.weapons) != head.weapons)
						continue;

					if (head.ammo_shells && player.ammo_shells > self.ammo_shells)
						continue;

					if (head.ammo_nails && player.ammo_nails > self.ammo_nails)
						continue;

					if (head.ammo_rockets && player.ammo_rockets > self.ammo_rockets)
						continue;

					if (head.ammo_cells && player.ammo_cells > self.ammo_cells )
						continue;

					discard = FALSE;
				}
				else
				{
					// If enemy only track distances
					// TODO: track only if visible ?
					if( d < enemy_distance )
						enemy_distance = d;
				}
			}

			// Rate the item only if no one needs it, or if an enemy is closer to it
			if (	(enemy_distance < friend_distance && distance < enemy_distance) ||
				(friend_distance > cvar("bot_ai_friends_aware_pickup_radius") ) || !discard )
			{
			//	rating = head.bot_pickupevalfunc(self, head);
				rating = havocbot_pickupevalfunc(head);
			}
		}
		else
		{
		//	rating = head.bot_pickupevalfunc(self, head);
			rating = havocbot_pickupevalfunc(head);
		}

		if(rating > 0)
			navigation_routerating(head, rating * ratingscale, 2000);
		head = head.chain;
	}
};

void havocbot_goalrating_controlpoints(float ratingscale, vector org, float sradius)
{
	local entity head;
	head = findchain(classname, "dom_controlpoint");
	while (head)
	{
		if (vlen(head.origin - org) < sradius)
		{
			if(head.cnt > -1) // this is just being fought for
				navigation_routerating(head, ratingscale, 5000);
			else if(head.goalentity.cnt == 0) // unclaimed point
				navigation_routerating(head, ratingscale * 0.5, 5000);
			else if(head.goalentity.team != self.team) // other team's point
				navigation_routerating(head, ratingscale * 0.2, 5000);
		}
		head = head.chain;
	}
};

/*
// LordHavoc: this function was already unused, but for waypoints to be a
// useful goal the bots would have to seek out the least-recently-visited
// ones, not the closest
void havocbot_goalrating_waypoints(float ratingscale, vector org, float sradius)
{
	local entity head;
	head = findchain(classname, "waypoint");
	while (head)
	{
		if (vlen(head.origin - org) < sradius && vlen(head.origin - org) > 100)
			navigation_routerating(head, ratingscale, 2000);
		head = head.chain;
	}
};
*/

void havocbot_goalrating_enemyplayers(float ratingscale, vector org, float sradius)
{
	local entity head;
	local float t, noteam, distance;
	noteam = ((self.team == 0) || !teams_matter); // fteqcc sucks

	if (cvar("bot_nofire"))
		return;

	// don't chase players if we're under water
	if(self.waterlevel>WATERLEVEL_WETFEET)
		return;

	FOR_EACH_PLAYER(head)
	{
		// TODO: Merge this logic with the bot_shouldattack function
		if (self != head)
		if (head.health > 0)
		if ((noteam && (!bot_ignore_bots || clienttype(head) == CLIENTTYPE_REAL)) || head.team != self.team)
		{
			distance = vlen(head.origin - org);
			if (distance < 100 || distance > sradius)
				continue;

			if(g_minstagib)
			if(head.items & IT_STRENGTH)
				continue;

			// rate only visible enemies
			/*
			traceline(self.origin + self.view_ofs, head.origin, MOVE_NOMONSTERS, self);
			if (trace_fraction < 1 || trace_ent != head)
				continue;
			*/

			if(head.flags & FL_INWATER || head.flags & FL_PARTIALGROUND)
				continue;

			// not falling
			if(head.flags & FL_ONGROUND == 0)
			{
				traceline(head.origin, head.origin + '0 0 -1500', TRUE, world);
				t = pointcontents(trace_endpos + '0 0 1');
				if( t != CONTENT_SOLID )
				if(t & CONTENT_WATER || t & CONTENT_SLIME || t & CONTENT_LAVA)
					continue;
				if(tracebox_hits_trigger_hurt(head.origin, head.mins, head.maxs, trace_endpos))
					continue;
			}

			t = (self.health + self.armorvalue ) / (head.health + head.armorvalue );
			navigation_routerating(head, t * ratingscale, 2000);
		}
	}
};

// choose a role according to the situation
void() havocbot_role_dm;

//DOM:
//go to best items, or control points you don't own
void havocbot_role_dom()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_controlpoints(10000, self.origin, 15000);
		havocbot_goalrating_items(8000, self.origin, 8000);
		//havocbot_goalrating_enemyplayers(3000, self.origin, 2000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
};

//DM:
//go to best items
void havocbot_role_dm()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(20000, self.origin, 10000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
};

//Race:
//go to next checkpoint, and annoy enemies
.float race_checkpoint;
void havocbot_role_race()
{
	if(self.deadflag != DEAD_NO)
		return;

	entity e;
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		/*
		havocbot_goalrating_items(100, self.origin, 10000);
		havocbot_goalrating_enemyplayers(500, self.origin, 20000);
		*/

		for(e = world; (e = find(e, classname, "trigger_race_checkpoint")) != world; )
		{
			if(e.cnt == self.race_checkpoint)
			{
				navigation_routerating(e, 1000000, 5000);
			}
			else if(self.race_checkpoint == -1)
			{
				navigation_routerating(e, 1000000, 5000);
			}
		}

		navigation_goalrating_end();
	}
};

void havocbot_chooserole_dm()
{
	self.havocbot_role = havocbot_role_dm;
};

void havocbot_chooserole_race()
{
	self.havocbot_role = havocbot_role_race;
};

void havocbot_chooserole_dom()
{
	self.havocbot_role = havocbot_role_dom;
};






entity kh_worldkeylist;
.entity kh_worldkeynext;
void havocbot_goalrating_kh(float ratingscale_team, float ratingscale_dropped, float ratingscale_enemy)
{
	local entity head;
	for (head = kh_worldkeylist; head; head = head.kh_worldkeynext)
	{
		if(head.owner == self)
			continue;
		if(!kh_tracking_enabled)
		{
			// if it's carried by our team we know about it
			// otherwise we have to see it to know about it
			if(!head.owner || head.team != self.team)
			{
				traceline(self.origin + self.view_ofs, head.origin, MOVE_NOMONSTERS, self);
				if (trace_fraction < 1 && trace_ent != head)
					continue; // skip what I can't see
			}
		}
		if(!head.owner)
			navigation_routerating(head, ratingscale_dropped, 100000);
		else if(head.team == self.team)
			navigation_routerating(head, ratingscale_team, 100000);
		else
			navigation_routerating(head, ratingscale_enemy, 100000);
	}
};

void() havocbot_role_kh_carrier;
void() havocbot_role_kh_defense;
void() havocbot_role_kh_offense;
void() havocbot_role_kh_freelancer;
void havocbot_role_kh_carrier()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (!(self.items & IT_KEY1))
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();

		if(kh_Key_AllOwnedByWhichTeam() == self.team)
			havocbot_goalrating_kh(100000, 1, 1); // bring home
		else
			havocbot_goalrating_kh(40000, 40000, 1000); // play defensively

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void havocbot_role_kh_defense()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.items & IT_KEY1)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		float key_owner_team;
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();

		key_owner_team = kh_Key_AllOwnedByWhichTeam();
		if(key_owner_team == self.team)
			havocbot_goalrating_kh(100000, 1, 1); // defend key carriers
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(40000, 10000, 1); // play defensively
		else
			havocbot_goalrating_kh(1, 1, 100000); // ATTACK ANYWAY

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

void havocbot_role_kh_offense()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.items & IT_KEY1)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 20;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to freelancer\n");
		self.havocbot_role = havocbot_role_kh_freelancer;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		float key_owner_team;

		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();

		key_owner_team = kh_Key_AllOwnedByWhichTeam();
		if(key_owner_team == self.team)
			havocbot_goalrating_kh(100000, 1, 1); // defend anyway
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(1, 10000, 40000); // play offensively
		else
			havocbot_goalrating_kh(1, 1, 100000); // ATTACK! EMERGENCY!

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

void havocbot_role_kh_freelancer()
{
	if(self.deadflag != DEAD_NO)
		return;

	if (self.items & IT_KEY1)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_kh_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 10 + 10;
	if (time > self.havocbot_role_timeout)
	{
		if (random() < 0.5)
		{
			dprint("changing role to offense\n");
			self.havocbot_role = havocbot_role_kh_offense;
		}
		else
		{
			dprint("changing role to defense\n");
			self.havocbot_role = havocbot_role_kh_defense;
		}
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		float key_owner_team;

		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();

		key_owner_team = kh_Key_AllOwnedByWhichTeam();
		if(key_owner_team == self.team)
			havocbot_goalrating_kh(100000, 1, 1); // defend anyway
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(10000, 40000, 10000); // prefer dropped keys
		else
			havocbot_goalrating_kh(1, 1, 100000); // ATTACK ANYWAY

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

void havocbot_chooserole_kh()
{
	local float r;

	if(self.deadflag != DEAD_NO)
		return;

	r = random() * 3;
	if (r < 1)
		self.havocbot_role = havocbot_role_kh_offense;
	else if (r < 2)
		self.havocbot_role = havocbot_role_kh_defense;
	else
		self.havocbot_role = havocbot_role_kh_freelancer;
};

void havocbot_chooserole()
{
	dprint("choosing a role...\n");
	navigation_clearroute();
	self.bot_strategytime = 0;
	if (g_ctf)
		havocbot_chooserole_ctf();
	else if (g_domination)
		havocbot_chooserole_dom();
	else if (g_keyhunt)
		havocbot_chooserole_kh();
	else if (g_race)
		havocbot_chooserole_race();
	else // assume anything else is deathmatch
		havocbot_chooserole_dm();
};

