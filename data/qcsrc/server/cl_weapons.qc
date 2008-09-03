// switch between weapons
void W_SwitchWeapon(float imp)
{
	if (self.weapon != imp)
	if (client_hasweapon(self, imp, TRUE, TRUE))
		W_SwitchWeapon_Force(self, imp);
};

float W_GetCycleWeapon(entity pl, string weaponorder, float dir, float imp, float complain)
{
	float n, i, weaponwant, first_valid, prev_valid, switchtonext, switchtolast;
	n = tokenize(weaponorder);
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;

	if(dir == 0)
		switchtonext = 1;

	for(i = 0; i < n; ++i)
	{
		weaponwant = stof(argv(i));

		if(imp >= 0)
			if((get_weaponinfo(weaponwant)).impulse != imp)
				continue;

		if(client_hasweapon(pl, weaponwant, TRUE, FALSE))
		{
			if(switchtonext)
				return weaponwant;
			if(!first_valid)
				first_valid = weaponwant;
			if(weaponwant == pl.switchweapon)
			{
				if(dir >= 0)
					switchtonext = 1;
				else if(prev_valid)
					return prev_valid;
				else
					switchtolast = 1;
			}
			prev_valid = weaponwant;
		}
	}
	if(first_valid)
	{
		if(switchtolast)
			return prev_valid;
		else
			return first_valid;
	}
	// complain
	if(complain)
	{
		for(i = 0; i < n; ++i)
		{
			weaponwant = stof(argv(i));
			if(imp >= 0)
				if((get_weaponinfo(weaponwant)).impulse != imp)
					continue;
			client_hasweapon(pl, weaponwant, TRUE, TRUE);
		}
	}
	return 0;
}

void W_CycleWeapon(string weaponorder, float dir)
{
	float w;
	w = W_GetCycleWeapon(self, weaponorder, dir, -1, 1);
	if(w > 0)
		W_SwitchWeapon(w);
}

void W_NextWeaponOnImpulse(float imp)
{
	float w;
	w = W_GetCycleWeapon(self, self.cvar_cl_weaponpriority, +1, imp, 1);
	if(w > 0)
		W_SwitchWeapon(w);
}

// next weapon
void W_NextWeapon()
{
	W_CycleWeapon(self.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon()
{
	W_CycleWeapon(self.cvar_cl_weaponpriority, +1);
}

string W_FixWeaponOrder(string order, float complete)
{
	string neworder;
	float i, n, w;

	n = tokenize(order);
	for(i = 0; i < n; ++i)
	{
		w = stof(argv(i));
		if(w >= WEP_FIRST && w <= WEP_LAST && w == floor(w))
			neworder = strcat(neworder, ftos(w), " ");
	}

	if(complete)
	{
		n = tokenize(neworder);
		for(w = WEP_LAST; w >= WEP_FIRST; --w)
		{
			for(i = 0; i < n; ++i)
				if(stof(argv(i)) == w)
					break;
			if(i == n) // not found
				neworder = strcat(neworder, ftos(w), " ");
		}
	}
	
	return substring(neworder, 0, strlen(neworder) - 1);
}

string W_FixWeaponOrder_AllowIncomplete(string order)
{
	return W_FixWeaponOrder(order, 0);
}

string W_FixWeaponOrder_ForceComplete(string order)
{
	if(order == "")
		order = cvar_string("cl_weaponpriority");
	return W_FixWeaponOrder(order, 1);
}

float w_getbestweapon(entity e)
{ 
	return W_GetCycleWeapon(e, e.cvar_cl_weaponpriority, 0, -1, 0);
};

// generic weapons table
// TODO should they be macros instead?
float weapon_action(float wpn, float wrequest)
{
	return (get_weaponinfo(wpn)).weapon_func(wrequest);
};

string W_Name(float weaponid)
{
	return (get_weaponinfo(weaponid)).message;
}

float W_WeaponBit(float wpn)
{
	return (get_weaponinfo(wpn)).weapons;
}

float W_AmmoItemCode(float wpn)
{
	return (get_weaponinfo(wpn)).items;
}

// think function for tossed weapons
void thrown_wep_think()
{
	self.solid = SOLID_TRIGGER;
	self.owner = world;
	SUB_SetFade(self, time + 20, 1);
	setorigin(self, self.origin);
};

// toss current weapon
void W_ThrowWeapon(vector velo, vector delta, float doreduce)
{
	local float w, ammo, wb, wa;
	local entity wep, e;
	local .float ammofield;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if (w == WEP_LASER)
		return;
	if (g_rocketarena)
		return;
	if (g_lms)
		return;
	if (g_nixnex)
		return;
	if (!cvar("g_pickup_items"))
		return;

	e = self;
	wep = spawn();
	self = wep;

	setorigin(wep, e.origin + delta);
	makevectors(e.angles);
	wep.classname = "droppedweapon";
	wep.velocity = velo; // e.velocity * 0.5 + v_forward * 750;
	SUB_SetFade(wep, time + 20, 1);

	wa = W_AmmoItemCode(w);
	if(wa == IT_SUPERWEAPON || wa == 0)
	{
		wb = W_WeaponBit(w);
		if(!(e.weapons & wb))
		{
			remove(wep);
			goto leave;
		}
		Item_SpawnByWeaponCode(w);
		if(startitem_failed)
			goto leave;
		if(e.weapons & wb)
			if(e.health >= 1)
				sprint(e, strcat("You dropped the ^2", wep.netname, "\n"));
	}
	else
	{
		ammofield = Item_CounterField(wa);
		wb = W_WeaponBit(w);
		if(!(e.weapons & wb))
		{
			remove(wep);
			goto leave;
		}
		Item_SpawnByWeaponCode(w);
		if(startitem_failed)
			goto leave;
		if(doreduce)
		{
			ammo = min(e.ammofield, wep.ammofield);
			wep.ammofield = ammo;
			e.ammofield -= ammo;
		}
		if(e.weapons & wb)
			if(e.health >= 1)
				sprint(e, strcat("You dropped the ^2", wep.netname, " with ", ftos(wep.ammofield), " ammo", "\n"));
	}

	wep.owner = e;
	setorigin(wep, wep.origin);
	wep.nextthink = time + 0.5;
	wep.think = thrown_wep_think;
	wep.classname = "droppedweapon";
	wep.flags = wep.flags | FL_TOSSED;
	e.weapons = e.weapons - (e.weapons & wb);
	wep.colormap = e.colormap;
	W_SwitchWeapon_Force(e, w_getbestweapon(e));

:leave
	self = e;
};

// Bringed back weapon frame
void W_WeaponFrame()
{
	if((arena_roundbased && time < warmup) || ((time < restart_countdown) && !cvar("sv_ready_restart_after_countdown")))
		return;

	if (!self.weaponentity || self.health < 1)
		return; // Dead player can't use weapons and injure impulse commands

	if(!self.switchweapon)
	{
		self.weapon = 0;
		self.weaponentity.state = WS_CLEAR;
		return;
	}

	makevectors(self.v_angle);

	// Change weapon
	if (self.weapon != self.switchweapon)
	{
		if (self.weaponentity.state == WS_CLEAR)
		{
			player_setanim(self.anim_draw, FALSE, TRUE, TRUE);
			self.weaponentity.state = WS_RAISE;
			weapon_action(self.switchweapon, WR_SETUP);
			// VorteX: add player model weapon select frame here
			// setcustomframe(PlayerWeaponRaise);
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_weaponswitchdelay"), w_ready);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
		}
		else if (self.weaponentity.state == WS_READY)
		{
#ifndef INDEPENDENT_ATTACK_FINISHED
			if(ATTACK_FINISHED(self) <= time + frametime * 0.5)
			{
#endif
			sound (self, CHAN_WEAPON, "weapons/weapon_switch.wav", VOL_BASE, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// set up weapon switch think in the future, and start drop anim
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_weaponswitchdelay"), w_clear);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
#ifndef INDEPENDENT_ATTACK_FINISHED
			}
#endif
		}
	}

	float wb;
	wb = W_WeaponBit(self.weapon);

	// call the think code which may fire the weapon
	// and do so multiple times to resolve framerate dependency issues if the
	// server framerate is very low and the weapon fire rate very high
	local float c;
	c = 0;
	while (c < 5)
	{
		c = c + 1;
		if(wb && self.weapons & wb == 0)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			wb = 0;
		}
		if(wb)
			weapon_action(self.weapon, WR_THINK);
		if (time + frametime * 0.5 >= self.weapon_nextthink)
			self.weapon_think();
	}

	// don't let attack_finished fall behind when not firing (must be after weapon_setup calls!)
	//if (ATTACK_FINISHED(self) < time)
	//	ATTACK_FINISHED(self) = time;

	//if (self.weapon_nextthink < time)
	//	self.weapon_nextthink = time;

	// update currentammo incase it has changed
	if (self.items & IT_CELLS)
		self.currentammo = self.ammo_cells;
	else if (self.items & IT_ROCKETS)
		self.currentammo = self.ammo_rockets;
	else if (self.items & IT_NAILS)
		self.currentammo = self.ammo_nails;
	else if (self.items & IT_SHELLS)
		self.currentammo = self.ammo_shells;
	else
		self.currentammo = 1;

};

float nixnex_weapon;
float nixnex_nextchange;
float nixnex_nextweapon;
.float nixnex_lastchange_id;
.float nixnex_lastinfotime;
.float nixnex_nextincr;

void Nixnex_ChooseNextWeapon()
{
	float numberof, id;
	numberof = WEP_LAST - WEP_FIRST; // all but the current one
	if(g_nixnex_with_laser)
		numberof = numberof - 1;
	id = WEP_FIRST + ceil(random() * numberof) - 1;

	if(g_nixnex_with_laser) // skip the laser if needed
		id = id + 1;

	if(id >= nixnex_weapon) // skip the current weapon
		id = id + 1;

	if(id < WEP_FIRST) // can't happen, but to be sure...
	{
		dprint("Won't happen (id < WEP_FIRST)\n");
		id = WEP_FIRST;
	}
	if(id > WEP_LAST) // either
	{
		dprint("Won't happen (id > WEP_LAST)\n");
		id = WEP_LAST;
	}

	nixnex_nextweapon = id;
}

void Nixnex_GiveCurrentWeapon()
{
	float dt;
	if(g_nixnex)
	{
		if(!nixnex_nextweapon)
			Nixnex_ChooseNextWeapon();

		dt = ceil(nixnex_nextchange - time);

		if(dt <= 0)
		{
			nixnex_weapon = nixnex_nextweapon;
			nixnex_nextweapon = 0;
			nixnex_nextchange = time + cvar("g_balance_nixnex_roundtime");
			//weapon_action(nixnex_weapon, WR_PRECACHE); // forget it, too slow
		}

		if(nixnex_nextchange != self.nixnex_lastchange_id) // this shall only be called once per round!
		{
			self.nixnex_lastchange_id = nixnex_nextchange;
			if (cvar("g_use_ammunition"))
			{
				self.ammo_shells = cvar("g_balance_nixnex_ammo_shells");
				self.ammo_nails = cvar("g_balance_nixnex_ammo_nails");
				self.ammo_rockets = cvar("g_balance_nixnex_ammo_rockets");
				self.ammo_cells = cvar("g_balance_nixnex_ammo_cells");
			}
			else
			{
				self.ammo_shells = cvar("g_pickup_shells_max");
				self.ammo_nails = cvar("g_pickup_nails_max");
				self.ammo_rockets = cvar("g_pickup_rockets_max");
				self.ammo_cells = cvar("g_pickup_cells_max");
			}
			self.nixnex_nextincr = time + cvar("g_balance_nixnex_incrtime");
			if(dt >= 1 && dt <= 5)
				self.nixnex_lastinfotime = -42;
			else
				centerprint(self, strcat("\n\n^2Active weapon: ^3", W_Name(nixnex_weapon), "\n"));
		}
		if(self.nixnex_lastinfotime != dt)
		{
			self.nixnex_lastinfotime = dt; // initial value 0 should count as "not seen"
			if(dt >= 1 && dt <= 5)
				centerprint(self, strcat("^3", ftos(dt), "^2 seconds until weapon change...\n\nNext weapon: ^3", W_Name(nixnex_nextweapon), "\n"));
		}

		if(cvar("g_use_ammunition") && time > self.nixnex_nextincr)
		{
			self.ammo_shells = self.ammo_shells + cvar("g_balance_nixnex_ammoincr_shells");
			self.ammo_nails = self.ammo_nails + cvar("g_balance_nixnex_ammoincr_nails");
			self.ammo_rockets = self.ammo_rockets + cvar("g_balance_nixnex_ammoincr_rockets");
			self.ammo_cells = self.ammo_cells + cvar("g_balance_nixnex_ammoincr_cells");
			self.nixnex_nextincr = time + cvar("g_balance_nixnex_incrtime");
		}

		self.weapons = 0;
		if(g_nixnex_with_laser)
			self.weapons = self.weapons | WEPBIT_LASER;
		self.weapons = self.weapons | W_WeaponBit(nixnex_weapon);

		if(self.switchweapon != nixnex_weapon)
			if(!client_hasweapon(self, self.switchweapon, TRUE, FALSE))
				if(client_hasweapon(self, nixnex_weapon, TRUE, FALSE))
					W_SwitchWeapon(nixnex_weapon);
	}
}

void RegisterWeapons()
{
	// %weaponaddpoint
	register_weapon(WEP_LASER,            w_laser,     0,              1, 1, "laser",     "laser",           "Laser");
	register_weapon(WEP_SHOTGUN,          w_shotgun,   IT_SHELLS,      2, 1, "shotgun",   "shotgun",         "Shotgun");
	register_weapon(WEP_UZI,              w_uzi,       IT_NAILS,       3, 1, "uzi",       "uzi",             "Machine Gun");
	register_weapon(WEP_GRENADE_LAUNCHER, w_glauncher, IT_ROCKETS,     4, 1, "gl",        "grenadelauncher", "Mortar");
	register_weapon(WEP_ELECTRO,          w_electro,   IT_CELLS,       5, 1, "electro",   "electro",         "Electro");
	register_weapon(WEP_CRYLINK,          w_crylink,   IT_CELLS,       6, 1, "crylink",   "crylink",         "Crylink");
	register_weapon(WEP_NEX,              w_nex,       IT_CELLS,       7, 1, "nex",       "nex",             "Nex");
	register_weapon(WEP_HAGAR,            w_hagar,     IT_ROCKETS,     8, 1, "hagar",     "hagar",           "Hagar");
	register_weapon(WEP_ROCKET_LAUNCHER,  w_rlauncher, IT_ROCKETS,     9, 1, "rl",        "rocketlauncher",  "Rocket Launcher");
	register_weapon(WEP_PORTO,            w_porto,     IT_SUPERWEAPON, 0, 0, "porto" ,    "porto",           "Port-O-Launch");
	register_weapon(WEP_MINSTANEX,        w_minstanex, IT_CELLS,       7, 0, "minstanex", "minstanex",       "MinstaNex");
}
