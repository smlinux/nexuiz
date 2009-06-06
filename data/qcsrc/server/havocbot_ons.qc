#define HAVOCBOT_ONS_ROLE_NONE 		0
#define HAVOCBOT_ONS_ROLE_DEFENSE	2
#define HAVOCBOT_ONS_ROLE_ASSISTANT	4
#define HAVOCBOT_ONS_ROLE_OFFENSE	8

.float havocbot_role_flags;

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
float (entity controlpoint, float team) onslaught_controlpoint_can_be_linked;
float (entity controlpoint, float team) onslaught_controlpoint_attackable;

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

void havocbot_goalrating_ons_controlpoints_attack(float ratingscale)
{
	local entity cps, cp, wp, bestwp;
	local float radius, found, bestcounter, status;

	for (cps = findchain(classname, "onslaught_controlpoint_shield"); cps; cps = cps.chain)
	{
		// Found its corresponding onslaught_controlpoint entity (...)
		for (cp = findradius(cps.origin, 100); cp; cp = cp.chain)
		{
			if(cp.classname=="onslaught_controlpoint")
				break;
		}

		if(cp==world)
			continue;

		status = onslaught_controlpoint_attackable(cp, self.team);

		dprint(self.classname," found a controlpoint with status ",ftos(status),"\n");

		if(status==1 || status == 3)
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

				if(found)
					break;
			}

			if(bestwp)
			{
				navigation_routerating(bestwp, ratingscale, 10000);
				bestwp.cnt += 1;
			}
			dprint("attackable controlpoint found at ", vtos(cp.origin) ,"\n");
		}
		else if(status==2 || status==4)
		{
			// Should be touched
			if not(bot_waypoints_for_items)
			{
				navigation_routerating(cp, ratingscale, 10000);
				return;
			}

			for (wp = findradius(cp.origin,100); wp; wp = wp.chain)
			{
				if(wp.classname=="waypoint")
				{
					navigation_routerating(wp, ratingscale, 10000);
					return;
				}
			}
			dprint("touchable controlpoint found at ", vtos(cp.origin) ,"\n");
		}
	}
};

void havocbot_goalrating_ons_generator_attack(float ratingscale)
{
	local entity g, wp, bestwp;
	local float radius, found, bestcounter;

	for (g = findchain(classname, "onslaught_generator"); g; g = g.chain)
	{
		if(g.team == self.team || g.isshielded)
			continue;

		// Should be attacked
		// Rate waypoints near it
		found = FALSE;
		bestwp = world;
		bestcounter = 99999999999;
		for(radius=0; radius<1500 && !found; radius+=500)
		{
			for(wp=findradius(g.origin,radius); wp; wp=wp.chain)
			{
				if(wp.classname=="waypoint")
				if(checkpvs(wp.origin,g))
				{
					found = TRUE;
					if(wp.cnt<bestcounter)
					{
						bestwp = wp;
						bestcounter = wp.cnt;
					}
				}
			}

			if(found)
				break;
		}

		if(bestwp)
		{
			dprint("waypoints found around generator\n");
			navigation_routerating(bestwp, ratingscale, 10000);
			bestwp.cnt += 1;
		}
		else
		{
			dprint("generator found without waypoints around\n");
			// if there aren't waypoints near the generator go straight to it
			navigation_routerating(g, ratingscale, 10000);
		}
	}
};

void havocbot_role_ons_offense()
{
	if(self.deadflag != DEAD_NO)
	{
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

	if (self.bot_strategytime < time)
	{
		navigation_goalrating_start();
		havocbot_goalrating_enemyplayers(20000, self.origin, 500);
		havocbot_goalrating_ons_generator_attack(20000);
		havocbot_goalrating_ons_controlpoints_attack(20000);
		havocbot_goalrating_items(15000, self.origin, 1000);
		havocbot_goalrating_items(2500, self.origin, 10000);
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
