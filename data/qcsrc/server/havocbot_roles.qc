
.float havocbot_role_timeout;
.void() havocbot_previous_role;
.void() havocbot_role;
float bot_ignore_bots;

float canreach(entity e)
{
	return vlen(self.origin - e.origin) < 1500;
}

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

	if( item.weapons )
	{
		if( self.weapons & item.weapons == item.weapons )
			rating = 0.5 + bound(0, skill / 20, 0.5);
		else
			rating = 1;
		
		if( bot_custom_weapon )
		{
			for(i = WEP_FIRST; i < WEP_LAST ; ++i){		
				if( power2of(i-1) & item.weapons  != item.weapons )
					continue;

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

	if (item.armorvalue)
	if (self.armorvalue < item.max_armorvalue * 0.5)
		rating = rating + max(0, 1 - self.armorvalue / (item.max_armorvalue * 0.5));

	if (item.health)
	if (self.health < item.max_health * 0.5)
	{
		rating = rating + max(0, 1 - self.health / (item.max_health * 0.5));
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
	local float t, noteam;
	noteam = ((self.team == 0) || !teams_matter); // fteqcc sucks

	FOR_EACH_PLAYER(head)
	{
		if (self != head)
		if (head.health > 0)
		if ((noteam && (!bot_ignore_bots || clienttype(head) == CLIENTTYPE_REAL)) || head.team != self.team)
		{
			if (vlen(head.origin - org) > sradius)
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


void() havocbot_role_ctf_middle;
void() havocbot_role_ctf_defense;
void() havocbot_role_ctf_offense;
void() havocbot_role_ctf_interceptor;

void havocbot_goalrating_ctf_carrieritems(float ratingscale, vector org, float sradius)
{
	local entity head;
	local float t;
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// look for health and armor only
		if (head.solid) // must be possible to pick up (respawning items don't count)
		if (head.health || head.armorvalue)
		if (vlen(head.origin - org) < sradius)
		{
			// debugging
			//if (!head.bot_pickupevalfunc || head.model == "")
			//	eprint(head);
			// get the value of the item
			t = head.bot_pickupevalfunc(self, head) * 0.0001;
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
};

entity ctf_worldflaglist;
.entity ctf_worldflagnext;
void havocbot_goalrating_ctf_ourflag(float ratingscale)
{
	local entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
};

void havocbot_goalrating_ctf_enemyflag(float ratingscale)
{
	local entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team != head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
		navigation_routerating(head, ratingscale, 10000);
};

void havocbot_goalrating_ctf_enemybase(float ratingscale)
{
	// div0: needs a change in the CTF code
};

void havocbot_goalrating_ctf_ourstolenflag(float ratingscale)
{
	local entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (self.team == head.team)
			break;
		head = head.ctf_worldflagnext;
	}
	if (head)
	if (head.cnt != FLAG_BASE)
		navigation_routerating(head, ratingscale, 10000);
};

void havocbot_goalrating_ctf_droppedflags(float ratingscale)
{
	local entity head;
	head = ctf_worldflaglist;
	while (head)
	{
		if (head.cnt != FLAG_BASE) // flag is carried or out in the field
			navigation_routerating(head, ratingscale, 10000);
		head = head.ctf_worldflagnext;
	}
};

// CTF: (always teamplay)

//role rogue: (is this used?)
//pick up items and dropped flags (with big rating boost to dropped flags)
void havocbot_role_ctf_rogue()
{
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_droppedflags(5000);
		//havocbot_goalrating_enemyplayers(3000, self.origin, 3000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

//role flag carrier:
//pick up armor and health
//go to our flag spot
.float bot_cantfindflag;
void havocbot_role_ctf_carrier()
{
	if (self.flagcarried == world)
	{
		dprint("changing role to middle\n");
		self.havocbot_role = havocbot_role_ctf_middle;
		self.havocbot_role_timeout = 0;
		return;
	}
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourflag(50000);
		if (navigation_bestgoal)
			self.bot_cantfindflag = time + 10;
		else if (time > self.bot_cantfindflag)
		{
			// can't navigate to our own flag :(
			Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');
		}
		havocbot_goalrating_ctf_carrieritems(1000, self.origin, 1000);
		navigation_goalrating_end();
	}
};

//role offense:
//pick up armor and health
//if rockets < 25 || health < 100, change role to middle
//if carrying flag, change role to flag carrier
//if our flag taken, change role to interceptor
//(60-90 second timer) change role to middle
//go to enemy flag
void havocbot_role_ctf_offense()
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		self.bot_cantfindflag = time + 10;
		return;
	}
	// check our flag
	f = ctf_worldflaglist;
	while (f)
	{
		if (self.team == f.team)
			break;
		f = f.ctf_worldflagnext;
	}
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_previous_role = self.havocbot_role;
		self.havocbot_role = havocbot_role_ctf_interceptor;
		self.havocbot_role_timeout = 0;
		return;
	}
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 30 + 60;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to middle\n");
		self.havocbot_role = havocbot_role_ctf_middle;
		self.havocbot_role_timeout = 0;
		return;
	}
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_enemyflag(30000);
		havocbot_goalrating_ctf_enemybase(20000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

//role interceptor (temporary role):
//pick up items
//if carrying flag, change role to flag carrier
//if our flag is back, change role to previous role
//follow our flag
//go to least recently visited area
void havocbot_role_ctf_interceptor()
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		self.bot_cantfindflag = time + 10;
		return;
	}
	// check our flag
	f = ctf_worldflaglist;
	while (f)
	{
		if (self.team == f.team)
			break;
		f = f.ctf_worldflagnext;
	}
	if (f.cnt == FLAG_BASE)
	{
		dprint("changing role back\n");
		self.havocbot_role = self.havocbot_previous_role;
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(50000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

//role middle:
//pick up items
//if carrying flag, change role to flag carrier
//if our flag taken, change role to interceptor
//if see flag (of either team) follow it (this has many implications)
//(10-20 second timer) change role to defense or offense
//go to least recently visited area
void havocbot_role_ctf_middle()
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		self.bot_cantfindflag = time + 10;
		return;
	}
	// check our flag
	f = ctf_worldflaglist;
	while (f)
	{
		if (self.team == f.team)
			break;
		f = f.ctf_worldflagnext;
	}
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_previous_role = self.havocbot_role;
		self.havocbot_role = havocbot_role_ctf_interceptor;
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
			self.havocbot_role = havocbot_role_ctf_offense;
		}
		else
		{
			dprint("changing role to defense\n");
			self.havocbot_role = havocbot_role_ctf_defense;
		}
		self.havocbot_role_timeout = 0;
		return;
	}

	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(50000);
		havocbot_goalrating_ctf_droppedflags(30000);
		//havocbot_goalrating_enemyplayers(1000, self.origin, 1000);
		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

//role defense:
//if rockets < 25 || health < 100, change role to middle
//if carrying flag, change role to flag carrier
//if our flag taken, change role to interceptor
//(30-50 second timer) change role to middle
//move to nearest unclaimed defense spot
void havocbot_role_ctf_defense()
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		self.bot_cantfindflag = time + 10;
		return;
	}
	// check our flag
	f = ctf_worldflaglist;
	while (f)
	{
		if (self.team == f.team)
			break;
		f = f.ctf_worldflagnext;
	}
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_previous_role = self.havocbot_role;
		self.havocbot_role = havocbot_role_ctf_interceptor;
		self.havocbot_role_timeout = 0;
		return;
	}
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + random() * 20 + 30;
	if (time > self.havocbot_role_timeout)
	{
		dprint("changing role to middle\n");
		self.havocbot_role = havocbot_role_ctf_middle;
		self.havocbot_role_timeout = 0;
		return;
	}
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_ctf_ourstolenflag(200000);
		havocbot_goalrating_ctf_droppedflags(50000);
		havocbot_goalrating_items(10000, f.origin, 10000);
		navigation_goalrating_end();
	}
	/*
	// FIXME: place info_ctf_defensepoint entities in CTF maps and use them
	// change position occasionally
	if (time > self.bot_strategytime || self.goalentity.classname != "info_ctf_defensepoint")
	{
		self.bot_strategytime = time + random() * 45 + 15;
		self.goalentity = world;
		head = findchain(classname, "info_ctf_defensepoint");
		while (head)
		{
			if (time > head.count)
			{
				self.goalentity = head;
				head.chain = world;
			}
			head = head.chain;
		}
		// if there are no defensepoints defined, switch to middle
		if (self.goalentity == world)
		{
			dprint("changing role to middle\n");
			self.havocbot_role = havocbot_role_ctf_middle;
			self.havocbot_role_timeout = 0;
			return;
		}
	}
	// keep anyone else from taking this spot
	if (self.goalentity != world)
		self.goalentity.count = time + 0.5;
	*/
};

// CTF:
// choose a role according to the situation
void() havocbot_role_dm;
void havocbot_chooserole_ctf()
{
	local float r;
	dprint("choose CTF role...\n");
	if (self.team == COLOR_TEAM3 || self.team == COLOR_TEAM4)
		self.havocbot_role = havocbot_role_ctf_rogue;
	else
	{
		r = random() * 3;
		if (r < 1)
			self.havocbot_role = havocbot_role_ctf_offense;
		else if (r < 2)
			self.havocbot_role = havocbot_role_ctf_middle;
		else
			self.havocbot_role = havocbot_role_ctf_defense;
	}
};

//DOM:
//go to best items, or control points you don't own
void havocbot_role_dom()
{
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
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(20000, self.origin, 20000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
};

//Race:
//go to next checkpoint, and annoy enemies
.float race_checkpoint;
void havocbot_role_race()
{
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
	dprint("choose a role...\n");
	navigation_routetogoal(world);
	self.bot_strategytime = -1;
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

