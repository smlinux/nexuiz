
// generic weapons table
// add new weapons here
float(float wpn, float wrequest) weapon_action =
{
	if (wpn == WEP_LASER)
		return w_laser(wrequest);
	else if (wpn == WEP_SHOTGUN)
		return w_shotgun(wrequest);
	else if (wpn == WEP_UZI)
		return w_uzi(wrequest);
	else if (wpn == WEP_GRENADE_LAUNCHER)
		return w_glauncher(wrequest);
	else if (wpn == WEP_ELECTRO)
		return w_electro(wrequest);
	else if (wpn == WEP_CRYLINK)
		return w_crylink(wrequest);
	else if (wpn == WEP_NEX)
		return w_nex(wrequest);
	else if (wpn == WEP_HAGAR)
		return w_hagar(wrequest);
	else if (wpn == WEP_ROCKET_LAUNCHER)
		return w_rlauncher(wrequest);
	return FALSE;
};

string W_Name(float weaponid)
{
	if(weaponid == WEP_LASER)             return "Laser";
	if(weaponid == WEP_UZI)               return "Machine Gun";
	if(weaponid == WEP_SHOTGUN)           return "Shotgun";
	if(weaponid == WEP_GRENADE_LAUNCHER)  return "Mortar";
	if(weaponid == WEP_ELECTRO)           return "Electro";
	if(weaponid == WEP_NEX)               return "Nex";
	if(weaponid == WEP_HAGAR)             return "Hagar";
	if(weaponid == WEP_ROCKET_LAUNCHER)   return "Rocket Launcher";
	if(weaponid == WEP_CRYLINK)           return "Crylink";
	return "@!#%'n Tuba";
}

float W_ItemCode(float wpn)
{
	switch(wpn)
	{
		case WEP_LASER:            return IT_LASER;
		case WEP_SHOTGUN:          return IT_SHOTGUN;
		case WEP_UZI:              return IT_UZI;
		case WEP_GRENADE_LAUNCHER: return IT_GRENADE_LAUNCHER;
		case WEP_ELECTRO:          return IT_ELECTRO;
		case WEP_CRYLINK:          return IT_CRYLINK;
		case WEP_NEX:              return IT_NEX;
		case WEP_HAGAR:            return IT_HAGAR;
		case WEP_ROCKET_LAUNCHER:  return IT_ROCKET_LAUNCHER;
		default:                   return 0;
	}
}

float W_AmmoItemCode(float wpn)
{
	switch(wpn)
	{
		case WEP_SHOTGUN:          return IT_SHELLS;
		case WEP_UZI:              return IT_NAILS;
		case WEP_GRENADE_LAUNCHER: return IT_ROCKETS;
		case WEP_ELECTRO:          return IT_CELLS;
		case WEP_CRYLINK:          return IT_CELLS;
		case WEP_NEX:              return IT_CELLS;
		case WEP_HAGAR:            return IT_ROCKETS;
		case WEP_ROCKET_LAUNCHER:  return IT_ROCKETS;
		default:                   return 0;
	}
}

// think function for tossed weapons
void() thrown_wep_think
{
	self.solid = SOLID_TRIGGER;
	self.owner = world;
	SUB_SetFade(self, time + 20, 1);
	setorigin(self, self.origin);
};

// toss current weapon
void(vector velo, vector delta, float doreduce) W_ThrowWeapon
{
	local float w, ammo;
	local entity wep, e;
	local .float ammofield;

	w = self.weapon;
	if(w == WEP_LASER)
		return;
	if(w == 0)
		return; // just in case

	e = self;
	wep = spawn();
	self = wep;

	setorigin(wep, e.origin + delta);
	makevectors(e.angles);
	wep.classname = "droppedweapon";
	wep.velocity = velo; // e.velocity * 0.5 + v_forward * 750;
	SUB_SetFade(wep, time + 20, 1);

	ammofield = Item_CounterField(W_AmmoItemCode(w));
	w = W_ItemCode(w);
	if(!(e.items & w))
	{
		remove(wep);
		goto leave;
	}
	Item_SpawnByItemCode(w);
	if(startitem_failed)
		goto leave;
	if(doreduce)
	{
		ammo = min(e.ammofield, wep.ammofield);
		wep.ammofield = ammo;
		e.ammofield -= ammo;
	}

	if(e.items & w)
		if(e.health >= 1)
			sprint(e, strcat("You dropped the ^2", wep.netname, " with ", ftos(wep.ammofield), " ammo", "\n"));

	wep.owner = e;
	setorigin(wep, wep.origin);
	wep.nextthink = time + 0.5;
	wep.think = thrown_wep_think;
	wep.classname = "droppedweapon";
	wep.flags = wep.flags | FL_TOSSED;
	e.items = e.items - (e.items & w);
	e.switchweapon = w_getbestweapon(e);
	wep.colormap = e.colormap;
	if (e.switchweapon != e.weapon)
		e.cnt = e.weapon;

:leave
	self = e;
};

// switch between weapons
void(float imp) W_SwitchWeapon
{
	if (self.weapon != imp)
	if (client_hasweapon(self, imp, TRUE, TRUE))
	{
		self.cnt = self.weapon;
		self.switchweapon = imp;
	}
};

// next weapon
void() W_NextWeapon =
{
	local float weaponwant, maxtries;

	maxtries = WEP_LAST;

	weaponwant = self.switchweapon + 1;
	if (weaponwant < WEP_FIRST)
		weaponwant = WEP_LAST;
	if (weaponwant > WEP_LAST)
		weaponwant = WEP_FIRST;
	while(!client_hasweapon(self, weaponwant, TRUE, FALSE))
	{
		if(!maxtries)
			return;

		maxtries -= 1;
		weaponwant = weaponwant + 1;
		if (weaponwant < WEP_FIRST)
			weaponwant = WEP_LAST;
		if (weaponwant > WEP_LAST)
			weaponwant = WEP_FIRST;
	}
	self.cnt = self.weapon;
	self.switchweapon = weaponwant;
};

// prev weapon
void() W_PreviousWeapon =
{
	local float weaponwant, maxtries;

	maxtries = WEP_LAST;

	weaponwant = self.switchweapon - 1;
	if (weaponwant < WEP_FIRST)
		weaponwant = WEP_LAST;
	if (weaponwant > WEP_LAST)
		weaponwant = WEP_FIRST;
	while(!client_hasweapon(self, weaponwant, TRUE, FALSE))
	{
		if(!maxtries)
			return;

		maxtries -= 1;
		weaponwant = weaponwant - 1;
		if (weaponwant < WEP_FIRST)
			weaponwant = WEP_LAST;
		if (weaponwant > WEP_LAST)
			weaponwant = WEP_FIRST;
	}
	self.cnt = self.weapon;
	self.switchweapon = weaponwant;
};

// Bringed back weapon frame
void() W_WeaponFrame =
{
	if(arena_roundbased)
	if(time < warmup)
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
			self.weaponentity.state = WS_RAISE;
			weapon_action(self.switchweapon, WR_SETUP);
			// VorteX: add player model weapon select frame here
			// setcustomframe(PlayerWeaponRaise);
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_weaponswitchdelay"), w_ready);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
		}
		else if (self.weaponentity.state == WS_READY)
		{
			sound (self, CHAN_WEAPON, "weapons/weapon_switch.wav", 1, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// set up weapon switch think in the future, and start drop anim
			weapon_thinkf(WFRAME_IDLE, cvar("g_balance_weaponswitchdelay"), w_clear);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
		}
	}

	// call the think code which may fire the weapon
	// and do so multiple times to resolve framerate dependency issues if the
	// server framerate is very low and the weapon fire rate very high
	local float c;
	c = 0;
	while (c < 5)
	{
		c = c + 1;
		weapon_action(self.weapon, WR_THINK);
		if (self.weapon_nextthink > 0 && time >= self.weapon_nextthink)
		{
			self.weapon_nextthink_lastframe = self.weapon_nextthink;
			self.weapon_think();
		}
	}

	// don't let attack_finished fall behind when not firing
	if (self.attack_finished < time)
		self.attack_finished = time;

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
	if(cvar("g_nixnex_with_laser"))
		numberof = numberof - 1;
	id = WEP_FIRST + ceil(random() * numberof) - 1;

	if(cvar("g_nixnex_with_laser")) // skip the laser if needed
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
	if(cvar("g_nixnex"))
	{
		if(!nixnex_nextweapon)
			Nixnex_ChooseNextWeapon();

		dt = ceil(nixnex_nextchange - time);

		if(dt <= 0)
		{
			nixnex_weapon = nixnex_nextweapon;
			nixnex_nextweapon = 0;
			nixnex_nextchange = time + cvar("g_balance_nixnex_roundtime");
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

		self.items = self.items - (self.items & (IT_LASER | IT_SHOTGUN | IT_UZI | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER));
		if(cvar("g_nixnex_with_laser"))
			self.items = self.items | IT_LASER;
		self.items = self.items | W_ItemCode(nixnex_weapon);

		if(self.switchweapon != nixnex_weapon)
			if(!client_hasweapon(self, self.switchweapon, TRUE, FALSE))
				if(client_hasweapon(self, nixnex_weapon, TRUE, FALSE))
					W_SwitchWeapon(nixnex_weapon);
	}
}

