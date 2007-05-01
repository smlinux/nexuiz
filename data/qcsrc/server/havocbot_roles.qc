
.float havocbot_role_timeout;
.void() havocbot_previous_role;
.float bot_strategytime;
.void() havocbot_role;
float bot_ignore_bots;

float(entity e) canreach =
{
	return vlen(self.origin - e.origin) < 1500;
}

void(float ratingscale, vector org, float sradius) havocbot_goalrating_items =
{
	local entity head;
	local float t;
	head = findchainfloat(bot_pickup, TRUE);
	while (head)
	{
		if (head.solid) // must be possible to pick up (respawning items don't count)
		if (vlen(head.origin - org) < sradius)
		{
			// debugging
			//if (!head.bot_pickupevalfunc || head.model == "")
			//	eprint(head);
			// get the value of the item
			t = head.bot_pickupevalfunc(self, head) * 0.0001;
			if (t > 0)
				navigation_routerating(head, t * ratingscale);
		}
		head = head.chain;
	}
};

void(float ratingscale, vector org, float sradius) havocbot_goalrating_controlpoints =
{
	local entity head;
	head = findchain(classname, "dom_controlpoint");
	while (head)
	{
		if (vlen(head.origin - org) < sradius)
		{
			if(head.cnt > -1) // this is just being fought for
				navigation_routerating(head, ratingscale);
			else if(head.goalentity.cnt == 0) // unclaimed point
				navigation_routerating(head, ratingscale * 0.5);
			else if(head.goalentity.team != self.team) // other team's point
				navigation_routerating(head, ratingscale * 0.2);
		}
		head = head.chain;
	}
};

void(float ratingscale, vector org, float sradius) havocbot_goalrating_waypoints =
{
	local entity head;
	head = findchain(classname, "waypoint");
	while (head)
	{
		if (vlen(head.origin - org) < sradius && vlen(head.origin - org) > 100)
			navigation_routerating(head, ratingscale);
		head = head.chain;
	}
};

void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers =
{
	local entity head;
	local float t, noteam;
	ratingscale = ratingscale * 1200;
	noteam = ((self.team == 0) || (teamplay == 0)); // fteqcc sucks
	//dprint("teamplay is "); dprint(ftos(teamplay)); dprint(", own team is ");
	//dprint(ftos(self.team)); dprint(" -> noteam is "); dprint(ftos(noteam));
	//dprint("\n");

	FOR_EACH_PLAYER(head)
	{
		if (self != head)
		if (head.health > 0)
		if ((noteam && (!bot_ignore_bots || clienttype(head) == CLIENTTYPE_REAL)) || head.team != self.team)
		if (vlen(head.origin - org) < sradius)
		{
			t = head.frags + 25;
			if (t < 1)
				t = 1;
			t = t / (head.health + head.armortype * head.armorvalue);
			if (t > 0)
			{
				//dprint("found: "); dprint(head.netname); dprint("\n");
				navigation_routerating(head, t * ratingscale);
			}
		}
	}
};


void() havocbot_role_ctf_middle;
void() havocbot_role_ctf_defense;
void() havocbot_role_ctf_offense;
void() havocbot_role_ctf_interceptor;

void(float ratingscale, vector org, float sradius) havocbot_goalrating_ctf_carrieritems =
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
				navigation_routerating(head, t * ratingscale);
		}
		head = head.chain;
	}
};

void(float ratingscale) havocbot_goalrating_ctf_ourflag =
{
	local entity head;
	if (self.team == COLOR_TEAM1) // red
		head = find(world, classname, "item_flag_team1"); // red flag
	else // blue
		head = find(world, classname, "item_flag_team2"); // blue flag
	navigation_routerating(head, ratingscale);
};

void(float ratingscale) havocbot_goalrating_ctf_enemyflag =
{
	local entity head;
	if (self.team == COLOR_TEAM1) // red
		head = find(world, classname, "item_flag_team2"); // blue flag
	else // blue
		head = find(world, classname, "item_flag_team1"); // red flag
	navigation_routerating(head, ratingscale);
};

void(float ratingscale) havocbot_goalrating_ctf_enemybase =
{
	// div0: needs a change in the CTF code
};

void(float ratingscale) havocbot_goalrating_ctf_ourstolenflag =
{
	local entity head;
	if (self.team == COLOR_TEAM1) // red
		head = find(world, classname, "item_flag_team1"); // red flag
	else // blue
		head = find(world, classname, "item_flag_team2"); // blue flag
	if (head.cnt != FLAG_BASE)
		navigation_routerating(head, ratingscale);
};

void(float ratingscale) havocbot_goalrating_ctf_droppedflags =
{
	local entity redflag, blueflag;

	redflag = find(world, classname, "item_flag_team1");
	blueflag = find(world, classname, "item_flag_team2");

	if (redflag == world)
		error("havocbot: item_flag_team1 missing\n");
	if (blueflag == world)
		error("havocbot: item_flag_team2 missing\n");

	if (redflag.cnt != FLAG_BASE) // red flag is carried or out in the field
		navigation_routerating(redflag, ratingscale);
	if (blueflag.cnt != FLAG_BASE) // blue flag is carried or out in the field
		navigation_routerating(blueflag, ratingscale);
};

// CTF: (always teamplay)

//role rogue: (is this used?)
//pick up items and dropped flags (with big rating boost to dropped flags)
void() havocbot_role_ctf_rogue =
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
void() havocbot_role_ctf_carrier =
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
		havocbot_goalrating_ctf_ourflag(5000);
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
void() havocbot_role_ctf_offense =
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	// check our flag
	if (self.team == COLOR_TEAM1) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
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
	if (self.ammo_rockets < 15 || time > self.havocbot_role_timeout)
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
		havocbot_goalrating_ctf_ourstolenflag(5000);
		havocbot_goalrating_ctf_enemyflag(3000);
		havocbot_goalrating_ctf_enemybase(2000);
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
void() havocbot_role_ctf_interceptor =
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	// check our flag
	if (self.team == COLOR_TEAM1) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
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
		havocbot_goalrating_ctf_ourstolenflag(5000);
		havocbot_goalrating_ctf_droppedflags(5000);
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
void() havocbot_role_ctf_middle =
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	// check our flag
	if (self.team == COLOR_TEAM1) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
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
	if (self.ammo_rockets >= 25)
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
		havocbot_goalrating_ctf_ourstolenflag(5000);
		havocbot_goalrating_ctf_droppedflags(3000);
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
void() havocbot_role_ctf_defense =
{
	local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	// check our flag
	if (self.team == COLOR_TEAM1) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
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
	if (self.ammo_rockets < 15 || time > self.havocbot_role_timeout)
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
		havocbot_goalrating_ctf_ourstolenflag(20000);
		havocbot_goalrating_ctf_droppedflags(500);
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
void() havocbot_chooserole_ctf =
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
void() havocbot_role_dom =
{
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_controlpoints(10000, self.origin, 15000);
		havocbot_goalrating_items(8000, self.origin, 8000);
		//havocbot_goalrating_enemyplayers(1, self.origin, 2000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
};

//DM:
//go to best items
void() havocbot_role_dm =
{
	if (self.bot_strategytime < time)
	{
		self.bot_strategytime = time + cvar("bot_ai_strategyinterval");
		navigation_goalrating_start();
		havocbot_goalrating_items(10000, self.origin, 10000);
		havocbot_goalrating_enemyplayers(1, self.origin, 20000);
		//havocbot_goalrating_waypoints(1, self.origin, 1000);
		navigation_goalrating_end();
	}
};

void() havocbot_chooserole_dm =
{
	self.havocbot_role = havocbot_role_dm;
};

void() havocbot_chooserole_dom =
{
	self.havocbot_role = havocbot_role_dom;
};






void(float ratingscale_team, float ratingscale_dropped, float ratingscale_enemy) havocbot_goalrating_kh =
{
	local entity head;
	for(head = world; (head = find(head, classname, "item_kh_key")); )
	{
		if(head.owner == self)
			continue;
		if(!kh_tracking_enabled)
			if(!head.owner || head.team == self.team)
				continue; // skip what I can't see
		if(!head.owner)
			navigation_routerating(head, ratingscale_dropped);
		else if(head.team == self.team)
			navigation_routerating(head, ratingscale_team);
		else
			navigation_routerating(head, ratingscale_enemy);
	}
};

void() havocbot_role_kh_carrier;
void() havocbot_role_kh_defense;
void() havocbot_role_kh_offense;
void() havocbot_role_kh_freelancer;
void() havocbot_role_kh_carrier =
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
			havocbot_goalrating_kh(10000, 1, 1); // bring home
		else
			havocbot_goalrating_kh(4000, 4000, 100); // play defensively

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
}

void() havocbot_role_kh_defense =
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
			havocbot_goalrating_kh(10000, 1, 1); // defend key carriers
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(4000, 1000, 1); // play defensively
		else
			havocbot_goalrating_kh(1, 1, 10000); // ATTACK ANYWAY

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

void() havocbot_role_kh_offense =
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
			havocbot_goalrating_kh(10000, 1, 1); // defend anyway
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(1, 1000, 4000); // play offensively
		else
			havocbot_goalrating_kh(1, 1, 10000); // ATTACK! EMERGENCY!

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};

void() havocbot_role_kh_freelancer =
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
			havocbot_goalrating_kh(10000, 1, 1); // defend anyway
		else if(key_owner_team == -1)
			havocbot_goalrating_kh(1000, 4000, 1000); // prefer dropped keys
		else
			havocbot_goalrating_kh(1, 1, 10000); // ATTACK ANYWAY

		havocbot_goalrating_items(10000, self.origin, 10000);
		navigation_goalrating_end();
	}
};





void() havocbot_chooserole_kh =
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

void() havocbot_chooserole =
{
	dprint("choose a role...\n");
	navigation_routetogoal(world);
	self.bot_strategytime = -1;
	if (cvar("g_ctf"))
		havocbot_chooserole_ctf();
	else if (cvar("g_domination"))
		havocbot_chooserole_dom();
	else if (cvar("g_keyhunt"))
		havocbot_chooserole_kh();
	else // assume anything else is deathmatch
		havocbot_chooserole_dm();
};

