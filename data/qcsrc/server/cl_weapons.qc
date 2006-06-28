
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

// think function for tossed weapons
void() thrown_wep_think
{
	self.solid = SOLID_TRIGGER;
	self.owner = world;
	SUB_SetFade(self, time + 20, 1);
	setorigin(self, self.origin);
};

// toss current weapon
void() W_ThrowWeapon
{
	local float w, ammo;
	local entity wep, e;

	e = self;
	wep = spawn();
	self = wep;
	w = e.weapon;
	setorigin(wep, e.origin);
	makevectors(e.angles);
	wep.classname = "droppedweapon";
	wep.velocity = e.velocity * 0.5 + v_forward * 750;
	SUB_SetFade(wep, time + 20, 1);

	if(w == WEP_SHOTGUN)
	{
		w = IT_SHOTGUN;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_shotgun();
		ammo = min(e.ammo_shells, wep.ammo_shells);
		wep.ammo_shells = ammo;
		e.ammo_shells -= ammo;
	}
	else if(w == WEP_UZI)
	{
		w = IT_UZI;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_uzi();
		ammo = min(e.ammo_nails, wep.ammo_nails);
		wep.ammo_nails = ammo;
		e.ammo_nails -= ammo;
	}
	else if(w == WEP_GRENADE_LAUNCHER)
	{
		w = IT_GRENADE_LAUNCHER;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_grenadelauncher();
		ammo = min(e.ammo_rockets, wep.ammo_rockets);
		wep.ammo_rockets = ammo;
		e.ammo_rockets -= ammo;
	}
	else if(w == WEP_ELECTRO)
	{
		w = IT_ELECTRO;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_electro();
		ammo = min(e.ammo_cells, wep.ammo_cells);
		wep.ammo_cells = ammo;
		e.ammo_cells -= ammo;
	}
	else if(w == WEP_CRYLINK)
	{
		w = IT_CRYLINK;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_crylink();
		ammo = min(e.ammo_cells, wep.ammo_cells);
		wep.ammo_cells = ammo;
		e.ammo_cells -= ammo;
	}
	else if(w == WEP_NEX)
	{
		w = IT_NEX;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_nex();
		ammo = min(e.ammo_cells, wep.ammo_cells);
		wep.ammo_cells = ammo;
		e.ammo_cells -= ammo;
	}
	else if(w == WEP_HAGAR)
	{
		w = IT_HAGAR;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_hagar();
		ammo = min(e.ammo_rockets, wep.ammo_rockets);
		wep.ammo_rockets = ammo;
		e.ammo_rockets -= ammo;
	}
	else if(w == WEP_ROCKET_LAUNCHER)
	{
		w = IT_ROCKET_LAUNCHER;
		if(!(e.items & w))
		{
			remove(wep);
			return;
		}
		weapon_rocketlauncher();
		ammo = min(e.ammo_rockets, wep.ammo_rockets);
		wep.ammo_rockets = ammo;
		e.ammo_rockets -= ammo;
	}

	if(e.items & w)
		sprint(e, strcat("You dropped the ^2", wep.netname, "\n"));
	wep.owner = e;
	setorigin(wep, wep.origin);
	wep.nextthink = time + 0.5;
	wep.think = thrown_wep_think;
	wep.classname = "droppedweapon";
	e.items = e.items - (e.items & w);
	e.switchweapon = w_getbestweapon(e);
	wep.colormap = e.colormap;
	if (e.switchweapon != e.weapon)
		e.cnt = e.weapon;
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
			sound (self, CHAN_WEAPON, "weapons/weapon_switch.ogg", 1, ATTN_NORM);
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
			self.weapon_think();
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
				self.ammo_shells = 999;
				self.ammo_nails = 999;
				self.ammo_rockets = 999;
				self.ammo_cells = 999;
			}
			self.nixnex_nextincr = time + cvar("g_balance_nixnex_incrtime");
			if(dt >= 1 && dt <= 5)
				self.nixnex_lastinfotime = -42;
			else
			{
				centermsg_free(CENTERMSG_NIXNEXCOUNT);
				centermsg_set(CENTERMSG_NIXNEX, strcat("^2Active weapon: ^3", W_Name(nixnex_weapon)));
			}
		}
		if(self.nixnex_lastinfotime != dt)
		{
			self.nixnex_lastinfotime = dt; // initial value 0 should count as "not seen"
			if(dt >= 1 && dt <= 5)
			{
				centermsg_set(CENTERMSG_NIXNEXCOUNT, strcat("^3", ftos(dt), "^2 seconds until weapon change..."));
				centermsg_set(CENTERMSG_NIXNEX, strcat("Next weapon: ^3", W_Name(nixnex_nextweapon)));
			}
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
			self.items = self.items + IT_LASER;
		self.items = self.items - (self.items & weapon_translateindextoflag(nixnex_weapon)) + weapon_translateindextoflag(nixnex_weapon);

		if(self.switchweapon != nixnex_weapon)
			if(!client_hasweapon(self, self.switchweapon, TRUE, FALSE))
				if(client_hasweapon(self, nixnex_weapon, TRUE, FALSE))
					W_SwitchWeapon(nixnex_weapon);
	}
}

