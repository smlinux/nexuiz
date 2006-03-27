// generic weapons table
// add new weapons here
void(float wpn, float wrequest) weapon_action =
{
	if (wpn == WEP_LASER)
		w_laser(wrequest);
	else if (wpn == WEP_SHOTGUN)
		w_shotgun(wrequest);
	else if (wpn == WEP_UZI)
		w_uzi(wrequest);
	else if (wpn == WEP_GRENADE_LAUNCHER)
		w_glauncher(wrequest);
	else if (wpn == WEP_ELECTRO)
		w_electro(wrequest);
	else if (wpn == WEP_CRYLINK)
		w_crylink(wrequest);
	else if (wpn == WEP_NEX)
		w_nex(wrequest);
	else if (wpn == WEP_HAGAR)
		w_hagar(wrequest);
	else if (wpn == WEP_ROCKET_LAUNCHER)
		w_rlauncher(wrequest);
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
	weapon_hasammo = TRUE;
	if (!client_hasweapon(self, imp, TRUE))
	{
		if (!weapon_hasammo)
			sprint(self, "You don't have any ammo for that weapon\n");
		else
			sprint(self, "You don't own that weapon\n");
	}
	else
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
	weapon_hasammo = TRUE;
	while(!client_hasweapon(self, weaponwant, TRUE))
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
	weapon_hasammo = TRUE;
	while(!client_hasweapon(self, weaponwant, TRUE))
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
	if (!self.weaponentity || self.health < 1)
		return; // Dead player can't use weapons and injure impulse commands

	if(!self.switchweapon)
	{
		self.weapon = 0;
		self.weaponentity.state = 0;
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
			weapon_action(self.weapon, WR_UPDATECOUNTS);
			weapon_action(self.weapon, WR_RAISE);
		}
		else if (self.weaponentity.state == WS_READY)
		{
			sound (self, CHAN_WEAPON, "weapons/weapon_switch.ogg", 1, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// VorteX: add player model weapon deselect frame here
			// setcustomframe(PlayerWeaponDrop);
			weapon_action(self.weapon, WR_DROP);
		}
	}

	if (self.button0)
		weapon_action(self.weapon, WR_FIRE1);
	if (self.button3)
		weapon_action(self.weapon, WR_FIRE2);

	// do weapon think
	if (time >= self.weapon_nextthink)
		if (self.weapon_nextthink > 0)
			self.weapon_think();

	// weapon bobbing and script actions
	local float bobintensity, q1pitching, framespeed, diff;
	local vector vel, realorg, layer1, boblayer;

	bobintensity = cvar("g_viewweapon_bobintensity"); // weapon bob intensity
	q1pitching = fabs(cvar("g_viewweapon_q1pitching")); // q1 style of "bob" when looking up and down

	realorg = self.weaponentity.origin + self.weaponentity.view_ofs;
	realorg = realorg - self.weaponentity.finaldest; // finaldest is last bob position

	// VorteX: actually this is needed for weapon screen offset
	if (q1pitching)
	{
		self.weaponentity.view_ofs_x = q1pitching*bound(-5.5, self.v_angle_x/45, 5.5);
		self.weaponentity.view_ofs_z = q1pitching*bound(-1.5, self.v_angle_x/60, 1.5);
	}

	// weapon origin interpolation, layer 1
	if (realorg != self.weaponentity.pos1)
	{
		framespeed = frametime*self.weaponentity.lip*10; // lip is speed of origin changing (of layer1)
		diff = vlen(realorg - self.weaponentity.pos1);
		// VorteX: add speed modifier (haste)?
		layer1 = frametime*10*self.weaponentity.lip*normalize(self.weaponentity.pos1 - realorg);
		if (diff <= vlen(layer1))
			layer1 = normalize(self.weaponentity.pos1 - realorg)*diff;
	}

	// weapon bobbing (q3-style)
	if (self.flags & FL_ONGROUND && self.waterlevel < 2)
	{
		// VorteX: only xy velocity matters
		vel_x = self.velocity_x;
		vel_y = self.velocity_y;
		framespeed = vlen(vel);
		// Y axis
		diff = bobintensity*framespeed/300;
		self.weaponentity.destvec_y = self.weaponentity.destvec_y + frametime*10;
		boblayer_y = diff*cos(self.weaponentity.destvec_y + 90);
		// Z axis
		diff = bobintensity*framespeed/540;
		self.weaponentity.destvec_z = self.weaponentity.destvec_z + frametime*20;
		boblayer_z = diff*cos(self.weaponentity.destvec_z);
		self.weaponentity.finaldest = boblayer;
	}
	else if (self.waterlevel > 0)
	{// swim, all velocity matters
		// X axis
		framespeed = vlen(self.velocity);
		diff = bobintensity*framespeed/100;
		self.weaponentity.destvec_x = self.weaponentity.destvec_x + frametime*6;
		boblayer_x = diff*cos(self.weaponentity.destvec_x);
		self.weaponentity.finaldest = boblayer;
	}
	else
		self.weaponentity.finaldest = '0 0 0';
	self.weaponentity.origin = realorg + boblayer + layer1 - self.weaponentity.view_ofs;
};

float nixnex_weapon;
float nixnex_nextchange;
float nixnex_nextweapon;
.float nixnex_lastchange_id;
.float nixnex_lastinfotime;

void Nixnex_ChooseNextWeapon()
{
	float i, j;
	for(i = 0; i < 10; ++i)
	{
		j = ceil(random() * 9);
		if(j == 1)
			nixnex_nextweapon = WEP_LASER;
		else if(j == 2)
			nixnex_nextweapon = WEP_SHOTGUN;
		else if(j == 3)
			nixnex_nextweapon = WEP_UZI;
		else if(j == 4)
			nixnex_nextweapon = WEP_GRENADE_LAUNCHER;
		else if(j == 5)
			nixnex_nextweapon = WEP_ELECTRO;
		else if(j == 6)
			nixnex_nextweapon = WEP_CRYLINK;
		else if(j == 7)
			nixnex_nextweapon = WEP_NEX;
		else if(j == 8)
			nixnex_nextweapon = WEP_HAGAR;
		else if(j == 9)
			nixnex_nextweapon = WEP_ROCKET_LAUNCHER;
		else
		{
			bprint(strcat("Programmer too stupid error: ", ftos(j), " not in 1..9\n"));
			nixnex_nextweapon = WEP_LASER;
			break;
		}
		if(nixnex_nextweapon == WEP_LASER && cvar("g_start_weapon_laser"))
			continue;
		if(nixnex_nextweapon != nixnex_weapon)
			break;
	}
}

string W_Name(float weaponid)
{
	if(weaponid == WEP_LASER)             return "Laser";
	if(weaponid == WEP_UZI)               return "Machine gun";
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
			nixnex_nextchange = time + cvar("g_balance_nixnex_nextchange");
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

			// this only happens once a second, so...
			if(cvar("g_use_ammunition"))
			{
				self.ammo_shells = self.ammo_shells + cvar("g_balance_nixnex_ammoincr_shells");
				self.ammo_nails = self.ammo_nails + cvar("g_balance_nixnex_ammoincr_nails");
				self.ammo_rockets = self.ammo_rockets + cvar("g_balance_nixnex_ammoincr_rockets");
				self.ammo_cells = self.ammo_cells + cvar("g_balance_nixnex_ammoincr_cells");
				weapon_action(self.weapon, WR_UPDATECOUNTS);
			}
		}

		self.items = self.items - (self.items & (IT_LASER | IT_SHOTGUN | IT_UZI | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER));
		if(cvar("g_start_weapon_laser"))
			self.items = self.items + IT_LASER;
		self.items = self.items - (self.items & weapon_translateindextoflag(nixnex_weapon)) + weapon_translateindextoflag(nixnex_weapon);

		if(self.switchweapon != nixnex_weapon)
			if(!client_hasweapon(self, self.switchweapon, TRUE))
				if(client_hasweapon(self, nixnex_weapon, TRUE))
					W_SwitchWeapon(nixnex_weapon);
	}
}

