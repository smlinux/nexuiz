/* --- Evaluation functions ---
UrreBots select items to hunt for based on distance and if the item is valuable to them
The returning float is added to the travel distance when searching
Higher numbers are crummier
-1 means definite unwanted goal*/

float() ShellsEval =
{
	local float f;

	f = 1000;
	if (self.ammo_shells > 40)
		f = f + 500;
	if (self.items & IT_SHOTGUN)
		f = f - 250;
	if (self.ammo_shells >= 100)
		f = -1;
	return f;
};

float() NailsEval =
{
	local float f;

	f = 1000;
	if (self.ammo_nails > 120)
		f = f + 200;
	else if (self.items & IT_UZI)
		f = f - 250;
	if (self.ammo_nails >= 200)
		f = -1;
	return f;
};

float() RocketsEval =
{
	local float f;

	f = 1000;
	if (self.ammo_rockets > 30)
		f = f + 50;
	if ((self.items & IT_ROCKET_LAUNCHER) || (self.items & IT_GRENADE_LAUNCHER) || (self.items & IT_HAGAR))
		f = f - 400;
	if (self.ammo_rockets >= 100)
		f = -1;
	return f;
};

float() CellsEval =
{
	local float f;

	f = 1000;
	if ((self.items & IT_CRYLINK) || (self.items & IT_NEX) || (self.items & IT_ELECTRO))
		f = f - 400;
	if (self.ammo_cells >= 100)
		f = -1;
	return f;
};

float() Health5Eval =
{
	local float f, f2;

	f2 = self.health * 0.01;
	f = 800 * f2;

	if (f < 20)
		f = 20;
	return f;
};

float() Health25Eval =
{
	local float f, f2;

	f2 = self.health * 0.01;
	f = 400 * f2;

	if (f < 20)
		f = 20;
	return f;
};

float() Health100Eval =
{
	local float f;

	f = 100;

	return f;
};

float() Armor5Eval =
{
	local float f;

	f = 800;

	if (self.health < 50)
		f = f - 300;
	return f;
};

float() Armor100Eval =
{
	local float f;

	f = 250;

	if (self.health < 50)
		f = f - 80;
	return f;
};

float() EEval =
{
	local float f;

	f = 250;
	return f;
};

float() UEval =
{
	local float f;

	f = 500;
	return f;
};

float() CLEval =
{
	local float f;

	f = 500;
	return f;
};

float() HEval =
{
	local float f;

	f = 500;
	return f;
};

float() NGEval =
{
	local float f;

	f = 200;
	return f;
};

float() SGEval =
{
	local float f;

	f = 1000;
	return f;
};

float() GLEval =
{
	local float f;

	f = 300;
	return f;
};

float() RLEval =
{
	local float f;

	f = 100;
	return f;
};

float() InvEval =
{
	return 50;
};

float() StrengthEval =
{
	return 50;
};

float() RuneEval =
{
	return 10; // this is the goal of the gamemode, so we want these things above all else
};

float(entity dompoint) DomPointEval =
{
	if (dompoint.enemy.team != self.team)
		return 50;
	return -1;
};

float() BadEval =
{
	return -1;
};

/* --- ItemEvals ---
Called at load, to give all pickable items their evaluation function
Also assigns their current navnode (makes for faster evaluation)*/

void() ItemEvals =
{
	local entity e;

	e = findchainflags(flags, FL_ITEM);
	while (e)
	{
		e.goallist = FindCurrentNavNode((e.absmin + e.absmax)*0.5, e.mins, e.maxs);
		if (e.goallist == world)
		{
			dprint ("Warning: Found no navnode for item\n");
			e.evalfunc = BadEval;
		}
		else
		{
			if (e.items & IT_SHELLS)
				e.evalfunc = ShellsEval;
			else if (e.items & IT_NAILS)
				e.evalfunc = NailsEval;
			else if (e.items & IT_ROCKETS)
				e.evalfunc = RocketsEval;
			else if (e.items & IT_CELLS)
				e.evalfunc = CellsEval;
			else if (e.max_health == 5)
				e.evalfunc = Health5Eval;
			else if (e.max_health == 25)
				e.evalfunc = Health25Eval;
			else if (e.max_health & 100)
				e.evalfunc = Health100Eval;
			else if (e.armorvalue == 5)
				e.evalfunc = Armor5Eval;
			else if (e.armorvalue == 100)
				e.evalfunc = Armor100Eval;				
			else if (e.items & IT_UZI)
				e.evalfunc = UEval;
			else if (e.items & IT_SHOTGUN)
				e.evalfunc = SGEval;
			else if (e.items & IT_GRENADE_LAUNCHER)
				e.evalfunc = GLEval;
			else if (e.items & IT_ELECTRO)
				e.evalfunc = EEval;
			else if (e.items & IT_CRYLINK)
				e.evalfunc = CLEval;
			else if (e.items & IT_NEX)
				e.evalfunc = NGEval;
			else if (e.items & IT_HAGAR)
				e.evalfunc = HEval;
			else if (e.items & IT_ROCKET_LAUNCHER)
				e.evalfunc = RLEval;
			else if (e.items & IT_STRENGTH)
				e.evalfunc = StrengthEval;
			else if (e.items & IT_INVINCIBLE)
				e.evalfunc = InvEval;
			else if (e.classname == "dom_controlpoint")
				e.evalfunc = DomPointEval;
			else
			{
				dprint ("Warning: Unknown item\n");
				e.evalfunc = BadEval;
			}
		}
		e = e.chain;
	}
};

/* --- DistEvalItems ---
This function adds the items assigned navnode's travel cost to the item
Used for goal evaluation*/

void() DistEvalItems =
{
	local float f;
	local vector v;
	local entity e;

	e = findchainflags(flags, FL_ITEM);
	while (e)
	{
		if (e.flags & FL_ONGROUND)
		if (!e.goallist)
		{
			e.goallist = FindCurrentNavNode((e.absmin + e.absmax)*0.5, e.mins, e.maxs);
			if (e.classname == "droppedweapon")
			{
				if (e.items & IT_UZI)
					e.evalfunc = UEval;
				else if (e.items & IT_SHOTGUN)
					e.evalfunc = SGEval;
				else if (e.items & IT_GRENADE_LAUNCHER)
					e.evalfunc = GLEval;
				else if (e.items & IT_ELECTRO)
					e.evalfunc = EEval;
				else if (e.items & IT_CRYLINK)
					e.evalfunc = CLEval;
				else if (e.items & IT_NEX)
					e.evalfunc = NGEval;
				else if (e.items & IT_HAGAR)
					e.evalfunc = HEval;
				else if (e.items & IT_ROCKET_LAUNCHER)
					e.evalfunc = RLEval;
				else
				{
					dprint ("Warning: Unknown item\n");
					e.evalfunc = BadEval;
				}
			}
			else if (e.runes)
				e.evalfunc = RuneEval;
			else
			{
				dprint ("Warning: Unknown item\n");
				e.evalfunc = BadEval;
			}
		}

		v = e.absmin + e.absmax * 0.5;
		f = vlen(v - e.goallist.pointl);
		e.costl = e.goallist.costl + f;
		e = e.chain;
	}
};
