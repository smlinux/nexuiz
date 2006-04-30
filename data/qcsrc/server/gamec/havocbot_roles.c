
.float havocbot_role_timeout;
.float bot_strategytime;
.void() havocbot_role;

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

void(float ratingscale, vector org, float sradius) havocbot_goalrating_enemyplayers =
{
	local entity head;
	local float t, noteam;
	ratingscale = ratingscale * 1200;
	noteam = self.team == 0 || teamplay == 0;
	head = findchain(classname, "player");
	while (head)
	{
		if (head.health > 0)
		if (head.team != self.team || noteam)
		if (vlen(head.origin - org) < sradius)
		{
			t = head.frags + 25;
			if (t < 1)
				t = 1;
			t = t / (head.health + head.armortype * head.armorvalue);
			if (t > 0)
				navigation_routerating(head, t * ratingscale);
		}
		head = head.chain;
	}
};


void() havocbot_role_ctf_middle;
void() havocbot_role_ctf_defense;
void() havocbot_role_ctf_offense;

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
	if (self.team == 5) // red
		head = find(world, classname, "item_flag_team1"); // red flag
	else // blue
		head = find(world, classname, "item_flag_team2"); // blue flag
	navigation_routerating(head, ratingscale);
};

void(float ratingscale) havocbot_goalrating_ctf_enemyflag =
{
	local entity head;
	if (self.team == 5) // red
		head = find(world, classname, "item_flag_team2"); // blue flag
	else // blue
		head = find(world, classname, "item_flag_team1"); // red flag
	navigation_routerating(head, ratingscale);
};

void(float ratingscale) havocbot_goalrating_ctf_ourstolenflag =
{
	local entity head;
	if (self.team == 5) // red
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
	//local entity f;
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	/*
	// check our flag
	if (self.team == 5) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_role = havocbot_role_ctf_interceptor;
		self.havocbot_role_timeout = 0;
		return;
	}
	*/
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
	if (self.flagcarried)
	{
		dprint("changing role to carrier\n");
		self.havocbot_role = havocbot_role_ctf_carrier;
		self.havocbot_role_timeout = 0;
		return;
	}
	/*
	// check our flag
	if (self.team == 5) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_role = havocbot_role_ctf_interceptor;
		self.havocbot_role_timeout = 0;
		return;
	}
	*/
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
	/*
	// check our flag
	if (self.team == 5) // red
		f = find(world, classname, "item_flag_team1");
	else // blue
		f = find(world, classname, "item_flag_team2");
	if (f.cnt != FLAG_BASE && canreach(f))
	{
		dprint("changing role to interceptor\n");
		self.havocbot_role = havocbot_role_ctf_interceptor;
		self.havocbot_role_timeout = 0;
		return;
	}
	*/
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
	if (self.team == 13)
		self.havocbot_role = havocbot_role_ctf_rogue;
	else
	{
		r = random() * 3;
		if (r < 0)
			self.havocbot_role = havocbot_role_ctf_offense;
		else if (r < 1)
			self.havocbot_role = havocbot_role_ctf_middle;
		else
			self.havocbot_role = havocbot_role_ctf_defense;
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
		//havocbot_goalrating_enemyplayers(2000, self.origin, 2000);
		navigation_goalrating_end();
	}
};

void() havocbot_chooserole_dm =
{
	self.havocbot_role = havocbot_role_dm;
};

void() havocbot_chooserole =
{
	dprint("choose a role...\n");
	navigation_routetogoal(world);
	self.bot_strategytime = -1;
	if (cvar("g_ctf"))
		havocbot_chooserole_ctf();
	else // assume anything else is deathmatch
		havocbot_chooserole_dm();
};

