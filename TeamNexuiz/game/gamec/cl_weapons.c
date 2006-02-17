
// generic weapons table
// add new weapons here
void (float wreq) w_railgun;
void (float wreq) w_healgun;
void (float wreq) w_mac;
void (float wreq) w_pistol;
void(float wpn, float wrequest) weapon_action =
{
	if ((self.reload_time + .25) > time || self.is_feigning == 1) { 
		return; }
	if (wpn == WEP5)
	{
		wpn = self.wpn5.weapon;

		// various extra weapons the player can equip
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
		return;
	}
	else if(self.class == CLASS_SCOUT)
	{
		if (wpn == WEP1)
			w_shotgun(wrequest);
		else if (wpn == WEP2)
			w_grapple(wrequest);
		else if (wpn == WEP3)
			w_uzi(wrequest);
		else if (wpn == WEP4)
			w_crylink(wrequest);
	}
	else if(self.class == CLASS_SPY)
	{
		if (wpn == WEP1)
			w_laser(wrequest);
		else if (wpn == WEP2)
			w_uzi(wrequest);		//later be replaced with tranq gun
		else if (wpn == WEP3)
			w_shotgun(wrequest);
//			w_uzi(wrequest);
		else if (wpn == WEP4)
			w_mac(wrequest);
//			w_uzi(wrequest);
	}
	else if(self.class == CLASS_SOLDIER)
	{
		if (wpn == WEP1)
			w_pistol(wrequest);
			//w_shotgun(wrequest);
		else if (wpn == WEP2)
			w_shotgun(wrequest);
			//w_namek(wrequest);
		else if (wpn == WEP3)
			w_namek(wrequest);
//			w_electro(wrequest);
		else if (wpn == WEP4)
			w_rlauncher(wrequest);
	}
	else if(self.class == CLASS_PYRO)
	{
		if (wpn == WEP1)
			w_bombletts(wrequest);
		else if (wpn == WEP2)
			w_flamer(wrequest);
		else if (wpn == WEP3)
			w_rincendiary(wrequest);
		else if (wpn == WEP4)
			w_hotbombs(wrequest);
	}
	else if(self.class == CLASS_MEDIC)
	{
		if (wpn == WEP1)
			w_healgun(wrequest);
		else if (wpn == WEP2)
			w_shotgun(wrequest);
		else if (wpn == WEP3)
			w_laser(wrequest);
		else if (wpn == WEP4)
			w_uzi(wrequest);
	}
	else if(self.class == CLASS_ENGINEER)
	{
		if (wpn == WEP1)
			w_laser(wrequest);
		else if (wpn == WEP2)
			w_railgun(wrequest);
		else if (wpn == WEP3)
			w_shotgun(wrequest);
			//w_electro(wrequest);
		else if (wpn == WEP4)
			w_electro(wrequest);
			//w_rlauncher(wrequest);
	}
	else
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
	}

};

void () CheckTeamClass =
{
	if (self.impulse_wait > time)	// So the GUI menus doesnt flicker
		return;
	if (self.playerclass < 1)		// Bring up menu if no team/class
	{
		if (self.team_no < 1)
		{
			stuffcmd(self, "set scmenu_directmenu TeamSelect; togglemenu\n");
		}
		else 
		{
			stuffcmd(self, "set scmenu_directmenu ClassSelect; togglemenu\n");
		}
		self.impulse_wait = time + .5;
		return;
	}
};

// switch between weapons
void(float imp) W_SwitchWeapon
{
/*	if (self.reload_time > time - .1)
	{
		return;
	}*/
	weapon_hasammo = TRUE;
	if (!client_hasweapon(self, imp, TRUE))
	{
		if (!weapon_hasammo)
//			sprint(self, "You don't have any ammo for that weapon\n");
			TeamNexuiz_HUD_ShowSign(self, NO_AMMO_WARNING);
		else
			sprint(self, "You don't own that weapon\n");
	}
	else
		self.switchweapon = imp;
};

// next weapon
void() W_NextWeapon =
{
	local float weaponwant, i;

	weaponwant = self.switchweapon + 1;
	if (weaponwant < WEP_FIRST)
		weaponwant = WEP_LAST;
	if (weaponwant > WEP_LAST)
		weaponwant = WEP_FIRST;
	weapon_hasammo = TRUE;
	i = 0;
	while(!client_hasweapon(self, weaponwant, TRUE))
	{
		i = i + 1;
		if(i >= 20)
			return; // failed; there's probably some weird problem causing an infinite loop
		weaponwant = weaponwant + 1;
		if (weaponwant < WEP_FIRST)
			weaponwant = WEP_LAST;
		if (weaponwant > WEP_LAST)
			weaponwant = WEP_FIRST;
	}
	self.switchweapon = weaponwant;
};

// prev weapon
void() W_PreviousWeapon =
{
	local float weaponwant, i;

	weaponwant = self.switchweapon - 1;
	if (weaponwant < WEP_FIRST)
		weaponwant = WEP_LAST;
	if (weaponwant > WEP_LAST)
		weaponwant = WEP_FIRST;
	weapon_hasammo = TRUE;
	i = 0;
	while(!client_hasweapon(self, weaponwant, TRUE))
	{
		i = i + 1;
		if(i >= 20)
			return; // failed; there's probably some weird problem causing an infinite loop
		weaponwant = weaponwant - 1;
		if (weaponwant < WEP_FIRST)
			weaponwant = WEP_LAST;
		if (weaponwant > WEP_LAST)
			weaponwant = WEP_FIRST;
	}
	self.switchweapon = weaponwant;
};

void () Use_Function;
// Brought back weapon frame
void() W_WeaponFrame =
{
	if (self.current_menu > 0)				// calls the text menu display
	{
		Player_Menu ();
		if ((self.impulse > 0) && (self.impulse < 11))
		{
			Menu_Input (self.impulse);
		}
	}
	if(self.buttonuse)
		Use_Function();		// for engineer and medic, though I'm putting this in engineer.c...

	if (self.button0 || self.button2 || self.button3  || self.button4)
		CheckTeamClass();
	if (!self.weaponentity || self.health <= 0)
		return; // Dead player can't use weapons and injure impulse commands

	if (cvar("g_antilag"))
	{
		// if aiming at a player and the original trace won't hit that player
		// anymore, try aiming at the player's new position
		if (self.cursor_trace_ent)
		{
			if (self.cursor_trace_ent.takedamage)
			{
				traceline(self.origin + self.view_ofs, self.cursor_trace_endpos, FALSE, self);
				if (trace_ent != self.cursor_trace_ent)
				{
					traceline(self.origin + self.view_ofs, self.cursor_trace_ent.origin + (self.cursor_trace_ent.mins + self.cursor_trace_ent.maxs) * 0.5, FALSE, self);
					if (trace_ent == self.cursor_trace_ent)
						self.cursor_trace_endpos = trace_endpos;
				}
			}
		}
		self.v_angle = vectoangles(self.cursor_trace_endpos - (self.origin + self.view_ofs));
		self.v_angle_x = 0 - self.v_angle_x;
	}

	makevectors(self.v_angle);

	// Change weapon
	if (self.weapon != self.switchweapon && self.is_feigning != 1)
	{
		//bprint("switching weapon: ");
		//bprint(ftos(self.weapon));
		//bprint(" --> ");
		//bprint(ftos(self.switchweapon));
		//bprint("\n");

		//self.weaponentity.state = WS_CLEAR;
		if (self.weaponentity.state == WS_CLEAR)
		{
			//bprint("switching in\n");
			self.weaponentity.state = WS_RAISE;
			weapon_action(self.switchweapon, WR_SETUP);
			// VorteX: add player model weapon select frame here
			// setcustomframe(PlayerWeaponRaise);
			weapon_action(self.weapon, WR_UPDATECOUNTS);
			weapon_action(self.weapon, WR_RAISE);
		}
		else if (self.weaponentity.state == WS_READY)
		{
			//bprint("switching out\n");
			sound (self, CHAN_WEAPON, "weapons/weapon_switch.wav", 1, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// VorteX: add player model weapon deselect frame here
			// setcustomframe(PlayerWeaponDrop);
			weapon_action(self.weapon, WR_DROP);
		}
	}

	if (self.button0)
	{
		if (self.pistol_fired == 1)				// code so that if fire is held down with pistol,
		{										//// it will not keep firing automatically.
			self.next_pistol_fire = time + .2;
		}
		weapon_action(self.weapon, WR_FIRE1);
	}
	if (self.button3)
		weapon_action(self.weapon, WR_FIRE2);

	if (!self.button0 && self.pistol_fired == 1)
		self.pistol_fired = 0;
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