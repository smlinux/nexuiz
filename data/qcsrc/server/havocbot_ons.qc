#define HAVOCBOT_ONS_ROLE_NONE 		0
#define HAVOCBOT_ONS_ROLE_DEFENSE	2
#define HAVOCBOT_ONS_ROLE_ASSISTANT	4
#define HAVOCBOT_ONS_ROLE_OFFENSE	8

.float havocbot_role_flags;
.float havocbot_attack_time;

.void() havocbot_role;
.void() havocbot_previous_role;

void() havocbot_role_ons_defense;
void() havocbot_role_ons_offense;
void() havocbot_role_ons_assistant;

void(entity bot) havocbot_ons_reset_role;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_items;
void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers;

.float isshielded;
.float iscaptured;
.float islinked;
.float isgenneighbor_blue, iscpneighbor_blue;
.float isgenneighbor_red, iscpneighbor_red;

float havocbot_pickupevalfunc(entity item);

void havocbot_goalrating_ons_offenseitems(float ratingscale, vector org, float sradius)
{
	local entity head;
	local float t, i, c, needarmor, needweapons;

	// Needs armor/health?
	if(self.health<100)
		needarmor = TRUE;

	// Needs weapons?
	for(i = WEP_FIRST; i < WEP_LAST ; ++i)
	{
		// Find weapon
		if((get_weaponinfo(i)).weapons & self.weapons)
		if(++c>=4)
			break;
	}

	if(c<4)
		needweapons = TRUE;

	if(!needweapons && !needarmor)
		return;

//	dprint(self.netname, " needs weapons ", ftos(needweapons) , "\n");
//	dprint(self.netname, " needs armor ", ftos(needarmor) , "\n");

	// See what is around
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		// gather health and armor only
		if (head.solid)
		if ( ((head.health || head.armorvalue) && needarmor) || (head.weapons && needweapons ) )
		if (vlen(head.origin - org) < sradius)
		{
			t = havocbot_pickupevalfunc(head);
			if (t > 0)
				navigation_routerating(head, t * ratingscale, 500);
		}
		head = head.chain;
	}
};

void havocbot_role_ons_setrole(entity bot, float role)
{
	dprint(strcat(bot.netname," switched to "));
	switch(role)
	{
		case HAVOCBOT_ONS_ROLE_DEFENSE:
			dprint("defense");
			bot.havocbot_role = havocbot_role_ons_defense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_DEFENSE;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_ASSISTANT:
			dprint("assistant");
			bot.havocbot_role = havocbot_role_ons_assistant;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_ASSISTANT;
			bot.havocbot_role_timeout = 0;
			break;
		case HAVOCBOT_ONS_ROLE_OFFENSE:
			dprint("offense");
			bot.havocbot_role = havocbot_role_ons_offense;
			bot.havocbot_role_flags = HAVOCBOT_ONS_ROLE_OFFENSE;
			bot.havocbot_role_timeout = 0;
			break;
	}
	dprint("\n");
};

float havocbot_ons_teamcount(entity bot, float role)
{
	local float c;
	local entity head;

	FOR_EACH_PLAYER(head)
	if(head.team==self.team)
	if(head.havocbot_role_flags & role)
		++c;

	return c;
};

float havocbot_goalrating_ons_controlpoints_attack(float ratingscale)
{
	local entity cp, wp, bestwp;
	local float radius, found, bestcounter;

	for (cp = findchain(classname, "onslaught_controlpoint"); cp; cp = cp.chain)
	{
		if(cp==world)
			continue;

		if(cp.isshielded)
			continue;

		if(self.team == COLOR_TEAM1)
		{
			if( (cp.isgenneighbor_blue || cp.iscpneighbor_blue) && !(cp.isgenneighbor_red || cp.iscpneighbor_red) )
				continue;
		}
		else if(self.team == COLOR_TEAM2)
		{
			if( (cp.isgenneighbor_red || cp.iscpneighbor_red) && !(cp.isgenneighbor_blue || cp.iscpneighbor_blue) )
				continue;
		}

		if(cp.goalentity)
		{
			// Should be attacked
			// Rate waypoints near it
			found = FALSE;
			bestwp = world;
			bestcounter = 99999999999;
			for(radius=0; radius<1000 && !found; radius+=500)
			{
				for(wp=findradius(cp.origin,radius); wp; wp=wp.chain)
				{
					if(!(wp.wpflags & WAYPOINTFLAG_GENERATED))
					if(wp.classname=="waypoint")
					if(checkpvs(wp.origin,cp))
					{
						found = TRUE;
						if(wp.cnt<bestcounter)
						{
							bestwp = wp;
							bestcounter = wp.cnt;
						}
					}
				}
			}

			if(bestwp)
			{
				navigation_routerating(bestwp, ratingscale, 10000);
				bestwp.cnt += 1;

				self.havocbot_attack_time = 0;
				if(checkpvs(self.view_ofs,cp))
				if(checkpvs(self.view_ofs,bestwp))
					self.havocbot_attack_time = time + 2;
			}
			else
			{
				navigation_routerating(cp, ratingscale, 10000);
			}
			dprint(self.netname, " found an attackable controlpoint at ", vtos(cp.origin) ,"\n");
		}
		else
		{
			dprint(self.netname, " found a touchable controlpoint at ", vtos(cp.origin) ,"\n");
			// Should be touched
			if not(bot_waypoints_for_items)
			{
				navigation_routerating(cp, ratingscale, 10000);
				return TRUE;
			}

			for (wp = findradius(cp.origin,100); wp; wp = wp.chain)
			{
				if(wp.classname=="waypoint")
				{
					navigation_routerating(wp, ratingscale, 10000);
					return TRUE;
				}
			}
			navigation_routerating(cp, ratingscale, 10000);
		}
	}
	return FALSE;
};

float havocbot_goalrating_ons_generator_attack(float ratingscale)
{
	local entity g, wp, bestwp;
	local float found, best;

	for (g = findchain(classname, "onslaught_generator"); g; g = g.chain)
	{
		if(g.team == self.team || g.isshielded)
			continue;

		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		bestwp = world;
		best = 99999999999;

		for(wp=findradius(g.origin,400); wp; wp=wp.chain)
		{
			if(wp.classname=="waypoint")
			if(checkpvs(wp.origin,g))
			{
				found = TRUE;
				if(wp.cnt<best)
				{
					bestwp = wp;
					best = wp.cnt;
				}
			}
		}

		if(bestwp)
		{
			dprint("waypoints found around generator\n");
			navigation_routerating(bestwp, ratingscale, 10000);
			bestwp.cnt += 1;

			self.havocbot_attack_time = 0;
			if(checkpvs(self.view_ofs,g))
			if(checkpvs(self.view_ofs,bestwp))
				self.havocbot_attack_time = time + 5;

			return TRUE;
		}
		else
		{
			dprint("generator found without waypoints around\n");
			// if there aren't waypoints near the generator go straight to it
			navigation_routerating(g, ratingscale, 10000);
			self.havocbot_attack_time = 0;
			return TRUE;
		}
	}
	return FALSE;
};

void havocbot_role_ons_offense()
{
	if(self.deadflag != DEAD_NO)
	{
		self.havocbot_attack_time = 0;
		havocbot_ons_reset_role(self);
		return;
	}

	// Set the role timeout if necessary
	if (!self.havocbot_role_timeout)
		self.havocbot_role_timeout = time + 120;

	if (time > self.havocbot_role_timeout)
	{
		havocbot_ons_reset_role(self);
		return;
	}

	if(self.havocbot_attack_time>time)
		return;

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 650);
		if(!havocbot_goalrating_ons_generator_attack(20000))
			havocbot_goalrating_ons_controlpoints_attack(20000);
		havocbot_goalrating_ons_offenseitems(10000, self.origin, 10000);
		navigation_goalrating_end();

		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
	}
};

void havocbot_role_ons_assistant()
{
	havocbot_ons_reset_role(self);
};

void havocbot_role_ons_defense()
{
	havocbot_ons_reset_role(self);
};

void havocbot_ons_reset_role(entity bot)
{
	local entity head;
	local float c;

	if(self.deadflag != DEAD_NO)
		return;

	// TODO: Defend control points or generator if necessary

	// if there is only me on the team switch to offense
	c = 0;
	FOR_EACH_PLAYER(head)
	if(head.team==self.team)
		++c;

	if(c==1)
	{
		havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
		return;
	}

	havocbot_role_ons_setrole(bot, HAVOCBOT_ONS_ROLE_OFFENSE);
};

void havocbot_chooserole_ons()
{
	havocbot_ons_reset_role(self);
};
