void W_Reload()
{
	if(self.switchweapon == self.weapon)
	if(self.weaponentity.state == WS_READY)
		weapon_action(self.weapon, WR_RELOAD);
}

// switch between weapons
void W_SwitchWeapon(float imp)
{
	if (self.switchweapon != imp)
	{
		if (client_hasweapon(self, imp, TRUE, TRUE))
			W_SwitchWeapon_Force(self, imp);
	}
	else
	{
		W_Reload();
	}
};

.float weaponcomplainindex;
float W_GetCycleWeapon(entity pl, string weaponorder, float dir, float imp, float complain)
{
	// We cannot tokenize in this function, as GiveItems calls this
	// function. Thus we must use car/cdr.
	float weaponwant, first_valid, prev_valid, switchtonext, switchtolast, c;
	string rest;
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;

	if(dir == 0)
		switchtonext = 1;

	c = 0;

	rest = weaponorder;
	while(rest != "")
	{
		weaponwant = stof(car(rest)); rest = cdr(rest);
		if(imp >= 0)
			if((get_weaponinfo(weaponwant)).impulse != imp)
				continue;

		++c;

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
	// complain (but only for one weapon on the button that has been pressed)
	if(complain)
	{
		self.weaponcomplainindex += 1;
		c = mod(self.weaponcomplainindex, c) + 1;
		rest = weaponorder;
		while(rest != "")
		{
			weaponwant = stof(car(rest)); rest = cdr(rest);
			if(imp >= 0)
				if((get_weaponinfo(weaponwant)).impulse != imp)
					continue;

			--c;
			if(c == 0)
			{
				client_hasweapon(pl, weaponwant, TRUE, TRUE);
				break;
			}
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
void W_NextWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponpriority_hudselector_0, -1);
	else if(list == 1)
		W_CycleWeapon(weaponpriority_hudselector_1, -1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon(float list)
{
	if(list == 0)
		W_CycleWeapon(weaponpriority_hudselector_0, +1);
	else if(list == 1)
		W_CycleWeapon(weaponpriority_hudselector_1, +1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, +1);
}

string W_FixWeaponOrder_AllowIncomplete(string order)
{
	return W_FixWeaponOrder(order, 0);
}

string W_FixWeaponOrder_ForceComplete(string order)
{
	if(order == "")
		order = W_NumberWeaponOrder(cvar_string("cl_weaponpriority"));
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

void thrown_wep_think()
{
	self.solid = SOLID_TRIGGER;
	self.owner = world;
	SUB_SetFade(self, time + 20, 1);
}

// returns amount of ammo used as string, or -1 for failure, or 0 for no ammo count
string W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo)
{
	entity oldself, wep;
	float wa, thisammo, i, j;
	string s;
	var .float ammofield;

	wep = spawn();

	setorigin(wep, org);
	wep.classname = "droppedweapon";
	wep.velocity = velo;
	wep.owner = wep.enemy = own;
	wep.flags |= FL_TOSSED;
	wep.colormap = own.colormap;

	wa = W_AmmoItemCode(wpn);
	if(wa == IT_SUPERWEAPON || wa == 0)
	{
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
		wep.think = thrown_wep_think;
		wep.nextthink = time + 0.5;
		return "";
	}
	else
	{
		s = "";
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
		if(doreduce)
		{
			for(i = 0, j = 1; i < 24; ++i, j *= 2)
			{
				if(wa & j)
				{
					ammofield = Item_CounterField(j);
					thisammo = min(own.ammofield, wep.ammofield);
					wep.ammofield = thisammo;
					own.ammofield -= thisammo;
					s = strcat(s, " and ", ftos(thisammo), " ", Item_CounterFieldName(j));
				}
			}
			s = substring(s, 5, -1);
		}
		wep.think = thrown_wep_think;
		wep.nextthink = time + 0.5;
		return s;
	}
}

float W_IsWeaponThrowable(float w)
{
	float wb, wa;
	wb = W_WeaponBit(w);
	if(!wb)
		return 0;
	wa = W_AmmoItemCode(w);
	if(start_weapons & wb)
	{
		if(wa == IT_SUPERWEAPON && start_items & IT_UNLIMITED_SUPERWEAPONS)
			return 0;
		if(wa != IT_SUPERWEAPON && start_items & IT_UNLIMITED_WEAPON_AMMO)
			return 0;
		// start weapons that take no ammo can't be dropped (this prevents dropping the laser, as long as it continues to use no ammo)
		if(wa == 0)
			return 0;
	}

	return 1;
}

// toss current weapon
void W_ThrowWeapon(vector velo, vector delta, float doreduce)
{
	local float w, wb;
	string a;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if (g_weaponarena)
		return;
	if (g_lms)
		return;
	if (g_nixnex)
		return;
	if (g_nexball && w == WEP_GRENADE_LAUNCHER)
		return;
	if (!cvar("g_pickup_items"))
		return;
	if (g_ca)
		return;
	if(!cvar("g_weapon_throwable"))
		return;
	if(cvar("g_weapon_stay") == 1)
		return;
	if(!W_IsWeaponThrowable(w))
		return;

	wb = W_WeaponBit(w);
	if(self.weapons & wb != wb)
		return;

	self.weapons &~= wb;
	W_SwitchWeapon_Force(self, w_getbestweapon(self));
	a = W_ThrowNewWeapon(self, w, doreduce, self.origin + delta, velo);
	if not(a)
		return;
	if(self.health >= 1)
	{
		if(a == "")
			sprint(self, strcat("You dropped the ^2", W_Name(w), "\n"));
		else
			sprint(self, strcat("You dropped the ^2", W_Name(w), " with ", a, "\n"));
	}
};

// Bringed back weapon frame
void W_WeaponFrame()
{
	vector fo, ri, up;

	if (frametime)
		self.weapon_frametime = frametime;

	if(((arena_roundbased || g_ca) && time < warmup) || ((time < game_starttime) && !cvar("sv_ready_restart_after_countdown")))
		return;

	if (!self.weaponentity || self.health < 1)
		return; // Dead player can't use weapons and injure impulse commands

	if(!self.switchweapon)
	{
		self.weapon = 0;
		self.weaponentity.state = WS_CLEAR;
		self.weaponname = "";
		self.items &~= IT_AMMO;
		return;
	}

	makevectors(self.v_angle);
	fo = v_forward; // save them in case the weapon think functions change it
	ri = v_right;
	up = v_up;

	// Change weapon
	if (self.weapon != self.switchweapon)
	{
		if (self.weaponentity.state == WS_CLEAR)
		{
			setanim(self, self.anim_draw, FALSE, TRUE, TRUE);
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
			if(ATTACK_FINISHED(self) <= time + self.weapon_frametime * 0.5)
			{
#endif
			// UGLY WORKAROUND: play this on CHAN_WEAPON2 so it can't cut off fire sounds
			sound (self, CHAN_WEAPON2, "weapons/weapon_switch.wav", VOL_BASE, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// set up weapon switch think in the future, and start drop anim
			weapon_thinkf(WFRAME_DONTCHANGE, cvar("g_balance_weaponswitchdelay"), w_clear);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
#ifndef INDEPENDENT_ATTACK_FINISHED
			}
#endif
		}
	}

	// LordHavoc: network timing test code
	//if (self.button0)
	//	print(ftos(frametime), " ", ftos(time), " >= ", ftos(ATTACK_FINISHED(self)), " >= ", ftos(self.weapon_nextthink), "\n");

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
		if(wb && ((self.weapons & wb) == 0))
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			wb = 0;
		}
		if(wb)
		{
			v_forward = fo;
			v_right = ri;
			v_up = up;
			weapon_action(self.weapon, WR_THINK);
		}
		if (time + self.weapon_frametime * 0.5 >= self.weapon_nextthink)
		{
			if(self.weapon_think)
			{
				v_forward = fo;
				v_right = ri;
				v_up = up;
				self.weapon_think();
			}
			else
				bprint("\{1}^1ERROR: undefined weapon think function for ", self.netname, "\n");
		}
	}

	// don't let attack_finished fall behind when not firing (must be after weapon_setup calls!)
	//if (ATTACK_FINISHED(self) < time)
	//	ATTACK_FINISHED(self) = time;

	//if (self.weapon_nextthink < time)
	//	self.weapon_nextthink = time;

	// update currentammo incase it has changed
#if 0
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
#endif
};

float nixnex_weapon;
float nixnex_weapon_ammo;
float nixnex_nextchange;
float nixnex_nextweapon;
float nixnex_nextweapon_ammo;
.float nixnex_lastchange_id;
.float nixnex_lastinfotime;
.float nixnex_nextincr;

float NixNex_CanChooseWeapon(float wpn)
{
	entity e;
	e = get_weaponinfo(wpn);
	if(!e.weapons) // skip dummies
		return FALSE;
	if(g_weaponarena)
	{
		if not(g_weaponarena & e.weapons)
			return FALSE;
	}
	else
	{
		if(wpn == WEP_LASER && g_nixnex_with_laser)
			return FALSE;
		if not(e.spawnflags & WEP_FLAG_NORMAL)
			return FALSE;
	}
	return TRUE;
}
void Nixnex_ChooseNextWeapon()
{
	float j;
	RandomSelection_Init();
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		if(NixNex_CanChooseWeapon(j))
			RandomSelection_Add(world, j, string_null, 1, (j != nixnex_weapon));
	nixnex_nextweapon = RandomSelection_chosen_float;
	nixnex_nextweapon_ammo = W_AmmoItemCode(nixnex_nextweapon);
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
			nixnex_weapon_ammo = nixnex_nextweapon_ammo;
			nixnex_nextweapon = 0;
			nixnex_nextchange = time + cvar("g_balance_nixnex_roundtime");
			//weapon_action(nixnex_weapon, WR_PRECACHE); // forget it, too slow
		}
		
		if(nixnex_nextchange != self.nixnex_lastchange_id) // this shall only be called once per round!
		{
			self.nixnex_lastchange_id = nixnex_nextchange;
			if (self.items & IT_UNLIMITED_WEAPON_AMMO)
			{
				self.ammo_shells = (nixnex_weapon_ammo & IT_SHELLS) ?
					cvar("g_pickup_shells_max") : 0;
				self.ammo_nails = (nixnex_weapon_ammo & IT_NAILS) ?
					cvar("g_pickup_nails_max") : 0;
				self.ammo_rockets = (nixnex_weapon_ammo & IT_ROCKETS) ?
					cvar("g_pickup_rockets_max") : 0;
				self.ammo_cells = (nixnex_weapon_ammo & IT_CELLS) ?
					cvar("g_pickup_cells_max") : 0;
				self.ammo_fuel = (nixnex_weapon_ammo & IT_FUEL) ?
					cvar("g_pickup_fuel_max") : 0;
			}
			else
			{
				self.ammo_shells = (nixnex_weapon_ammo & IT_SHELLS) ?
					cvar("g_balance_nixnex_ammo_shells") : 0;
				self.ammo_nails = (nixnex_weapon_ammo & IT_NAILS) ?
					cvar("g_balance_nixnex_ammo_nails") : 0;
				self.ammo_rockets = (nixnex_weapon_ammo & IT_ROCKETS) ?
					cvar("g_balance_nixnex_ammo_rockets") : 0;
				self.ammo_cells = (nixnex_weapon_ammo & IT_CELLS) ?
					cvar("g_balance_nixnex_ammo_cells") : 0;
				self.ammo_fuel = (nixnex_weapon_ammo & IT_FUEL) ?
					cvar("g_balance_nixnex_ammo_fuel") : 0;
			}
			self.nixnex_nextincr = time + cvar("g_balance_nixnex_incrtime");
			if(dt >= 1 && dt <= 5)
				self.nixnex_lastinfotime = -42;
			else
				centerprint(self, strcat("\n\n^2Active weapon: ^3", W_Name(nixnex_weapon)));
		}
		if(self.nixnex_lastinfotime != dt)
		{
			self.nixnex_lastinfotime = dt; // initial value 0 should count as "not seen"
			if(dt >= 1 && dt <= 5)
				centerprint(self, strcat("^3", ftos(dt), "^2 seconds until weapon change...\n\nNext weapon: ^3", W_Name(nixnex_nextweapon), "\n"));
		}

		if(!(self.items & IT_UNLIMITED_WEAPON_AMMO) && time > self.nixnex_nextincr)
		{
			if (nixnex_weapon_ammo & IT_SHELLS)
				self.ammo_shells = self.ammo_shells + cvar("g_balance_nixnex_ammoincr_shells");
			else if (nixnex_weapon_ammo & IT_NAILS)
				self.ammo_nails = self.ammo_nails + cvar("g_balance_nixnex_ammoincr_nails");
			else if (nixnex_weapon_ammo & IT_ROCKETS)
				self.ammo_rockets = self.ammo_rockets + cvar("g_balance_nixnex_ammoincr_rockets");
			else if (nixnex_weapon_ammo & IT_CELLS)
				self.ammo_cells = self.ammo_cells + cvar("g_balance_nixnex_ammoincr_cells");
			if (nixnex_weapon_ammo & IT_FUEL) // hook uses cells and fuel
				self.ammo_fuel = self.ammo_fuel + cvar("g_balance_nixnex_ammoincr_fuel");
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
