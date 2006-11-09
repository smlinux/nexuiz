/*

  */

//move to tfdefs:
.entity building;
.float ammo_metal;

// Menus/Menu Input references
void () Menu_EngineerFix_Tesla;
void (float inp) Menu_EngineerFix_Tesla_Input;
void () Menu_Need_TeamNexuiz;
void () Menu_Engineer;
void () Menu_EngineerFix_Extractor;
void (float inp) Menu_EngineerFix_Extractor_Input;

// Resets the menu
void() ResetMenu = 
{
	if (self.StatusBarSize == TF_FLARE_LIT)
	{
		CenterPrint(self, "\n");
	}
	else
	{
		self.StatusRefreshTime = time + 0.1;
	}
	self.menu_count = 25;
	self.current_menu = TF_FLARE_OFF;
};

// This calls the function which displays the menu
void () Player_Menu =
{
	if ((self.menu_count > 25.000000))
	{
		self.menu_count = 0.000000;
	}
	else
	{
		self.menu_count = (self.menu_count + 1.000000);
		return;
	}
	if (self.current_menu == 666)
	{
		//Menu_Blah()
		return;
	}
	else if ((self.current_menu == 18))
	{
		Menu_EngineerFix_Tesla ();
	}
	else if (self.current_menu == MENU_NEED_TN)
	{
		Menu_Need_TeamNexuiz ();
	}
	else if (self.current_menu == MENU_ENGINEER_BUILD)
	{
		Menu_Engineer ();
	}
	else if (self.current_menu == MENU_EXTRACTOR)
	{
		Menu_EngineerFix_Extractor ();
	}
	
	else
	{
		self.current_menu = TF_FLARE_LIT;
	}
};

void(float menu_no) DisplayMenu = 
{
	self.current_menu = menu_no;
	if (menu_no == 2)
	{
		//Menu_Team();				// menu team & menu class are now handled by GUIs (see cl_client.c)
	}
	else
	{
		if (menu_no == 3)
		{
			//Menu_Class();
		}
	}
};

// Menu input (user can press 0 - 9)
void(float inp) Menu_Input = 
{
	if (self.current_menu == 18)
	{
		Menu_EngineerFix_Tesla_Input (inp);
	}
	if (self.current_menu == MENU_EXTRACTOR)
	{
		Menu_EngineerFix_Extractor_Input (inp);
	}
};

// Tesla Menu
void () Menu_EngineerFix_Tesla =
{
	CenterPrint (self, "Tesla Modification Lab: ^16^7 Upgrades Max\n[^11^7] Upgrade Voltage           - 1u\n[^12^7] Upgrade Amperage          - 1u\n[^13^7] Upgrade Power Supply      - 1u\n[^14^7] Make TeslaTurret(tm)      - 2u\n[^15^7] Improved Targeting System - 2u\n[^16^7] Add Spy Detector          - 4u\n[^17^7] Repair and Recharge           \n[^18^7] Dismantle                     \n[^19^7] Îïôèéîç                       ");
};

void () Menu_Need_TeamNexuiz =
{
		CenterPrint(self, "^7Hello, welcome to a Team:Nexuiz server version ",TN_VERSION,"\n\n^5If you see this message it means that\n you do not have the Team:Nexuiz mod installed.\n\n^3To get the mod, please follow the instructions at:\nhttp://avirox.devretro.com/temp/teamnexuiz/TN_how_to.txt\n");
}

// Tesla Menu Input
void (float inp) Menu_EngineerFix_Tesla_Input =
{
	local float cost;
	local float maxcells;

	if (((self.classname != "player") || (self.building == world)))
	{
		return;
	}

	if ((inp == 1))
	{
		if ((self.building.ammo_shells >= 3))
		{
			sprint (self, "You can only upgrade voltage 3 times\n");
		}
		else
		{
			if ((self.building.currentammo >= 6))
			{
				sprint (self, "You can only have ˜ upgrades on the gun\n");
			}
			else
			{
				if ((self.ammo_cells >= 100))
				{
					self.ammo_cells = (self.ammo_cells - 100);
					self.building.ammo_shells = (self.building.ammo_shells + 1);
					self.building.waitmin = ((self.building.ammo_shells + 2) * (self.building.ammo_nails + 2));
					self.building.currentammo = (self.building.currentammo + 1);
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 2))
	{
		if ((self.building.ammo_nails >= 3))
		{
			sprint (self, "You can only upgrade amperage 3 times\n");
		}
		else
		{
			if ((self.building.currentammo >= 6))
			{
				sprint (self, "You can only have ˜ upgrades on the gun\n");
			}
			else
			{
				if ((self.ammo_cells >= 100))
				{
					self.ammo_cells = (self.ammo_cells - 100);
					self.building.ammo_nails = (self.building.ammo_nails + 1);
					self.building.waitmin = ((self.building.ammo_shells + 2) * (self.building.ammo_nails + 2));
					self.building.currentammo = (self.building.currentammo + 1);
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 3))
	{
		if ((self.building.ammo_rockets >= 3))
		{
			sprint (self, "You can only upgrade the capacitor 3 times\n");
		}
		else
		{
			if ((self.building.currentammo >= 6))
			{
				sprint (self, "You can only have ˜ upgrades on the gun\n");
			}
			else
			{
				if ((self.ammo_cells >= 100))
				{
					self.ammo_cells = (self.ammo_cells - 100);
					self.building.ammo_rockets = (self.building.ammo_rockets + 1);
					self.building.currentammo = (self.building.currentammo + 1);
					if ((self.building.ammo_rockets == 1))
					{
						self.building.max_health = (self.building.max_health + 100);
						self.building.health = (self.building.health + 100);
						self.building.ammo_cells = 120;
					}
					else
					{
						if ((self.building.ammo_rockets == 2))
						{
							self.building.max_health = (self.building.max_health + 150);
							self.building.health = (self.building.health + 150);
							self.building.ammo_cells = 200;
						}
						else
						{
							if ((self.building.ammo_rockets == 3))
							{
								self.building.max_health = (self.building.max_health + 150);
								self.building.health = (self.building.health + 150);
								self.building.ammo_cells = 300;
							}
						}
					}
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 4))
	{
		if ((self.building.tf_items & 2))
		{
			sprint (self, "It is already a turret!\n");
		}
		else
		{
			if ((self.building.currentammo > (6 - 2)))
			{
				sprint (self, "This requires two upgrades, sorry\n");
			}
			else
			{
				if ((self.ammo_cells >= (2 * 100)))
				{
					self.ammo_cells = (self.ammo_cells - (2 * 100));
					if ((self.ammo_cells < 0))
					{
						self.ammo_cells = 0;
					}
					self.building.currentammo = (self.building.currentammo + 2);
					if ((self.building.tf_items & 2))
					{
						sprint (self, "Gun is already deployed\n");
					}
					else
					{
						self.building.origin_z = (self.building.origin_z + 15);
						if (0)
						{
							sprint (self, "You need a clear area to launch\n");
							self.building.origin_z = (self.building.origin_z - 15);
						}
						else
						{
							self.building.origin_z = (self.building.origin_z + 25);
							sprint (self, "You turretize your tesla\n");
							self.has_turretized_tesla = 1;
							self.building.angles_z = 180;
							self.building.flags = (self.building.flags - (self.building.flags & 512));
							self.building.movetype = 5;
							self.building.velocity_z = 200;
							setsize (self.building, '-16.000000 -16.000000 -40.000000', '16.000000 16.000000 -10.000000');
							self.building.tf_items = (self.building.tf_items | 2);
						}
					}
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 5))
	{
		if ((self.building.tf_items & 1))
		{
			sprint (self, "It already has an improved targeter\n");
		}
		else
		{
			if ((self.building.currentammo > (6 - 2)))
			{
				sprint (self, "This requires two upgrades, hence the '2u'...\n");
			}
			else
			{
				if ((self.ammo_cells >= (2 * 100)))
				{
					self.ammo_cells = (self.ammo_cells - (2 * 100));
					if ((self.ammo_cells < 0))
					{
						self.ammo_cells = 0;
					}
					self.building.currentammo = (self.building.currentammo + 2);
					self.building.tf_items = (self.building.tf_items | 1);
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 6))
	{
		if ((self.building.tf_items & 1024))
		{
			sprint (self, "You already built a spy detector\n");
		}
		else
		{
			if ((self.building.currentammo > (6 - 4)))
			{
				sprint (self, "Spy detector takes 4 upgrades\n");
			}
			else
			{
				if ((self.ammo_cells >= (2 * 100)))
				{
					self.ammo_cells = (self.ammo_cells - (4 * 100));
					if ((self.ammo_cells < 0))
					{
						self.ammo_cells = 0;
					}
					self.building.currentammo = (self.building.currentammo + 4);
					self.building.tf_items = (self.building.tf_items | 1024);
				}
				else
				{
					sprint (self, "You need more cells to upgrade the tesla\n");
				}
			}
		}
	}
	if ((inp == 7))
	{
		if ((self.building.health < self.building.max_health))
		{
			cost = (self.building.max_health - self.building.health) / 2;
			if ((self.ammo_cells >= cost))
			{
				self.ammo_cells = (self.ammo_cells - cost);
				self.building.health = self.building.max_health;
			}
		}
		if ((self.building.ammo_rockets == 0))
		{
			maxcells = 120;
		}
		else
		{
			if ((self.building.ammo_rockets == 1))
			{
				maxcells = 120;
			}
			else
			{
				if ((self.building.ammo_rockets == 2))
				{
					maxcells = 200;
				}
				else
				{
					if ((self.building.ammo_rockets == 3))
					{
						maxcells = 300;
					}
				}
			}
		}
		cost = maxcells - self.building.ammo_cells;
		if ((cost > self.ammo_cells))
		{
			cost = self.ammo_cells;
		}
		self.ammo_cells = (self.ammo_cells - cost);
		self.building.ammo_cells = (self.building.ammo_cells + cost);
	}
	if ((inp == 8))
	{
		sprint (self, "You dismantle the Tesla Gun.\n");
		self.ammo_cells = (self.ammo_cells + (150 / 2));
		self.building.real_owner.has_tesla = 0;
		self.building.real_owner.has_turretized_tesla = 0;
		if ((self.building.real_owner.team_no != self.team_no))
		{
			self.real_frags = (self.real_frags + 1);
			if (!(toggleflags & 128))
			{
				self.frags = self.real_frags;
			}
		}
		if ((self.building.real_owner != self))
		{
			sprint (self.building.real_owner, self.netname); 
			sprint (self.building.real_owner, " dismantled your Tesla Coil.\n");
			teamsprint (self.building.real_owner.team_no, self.building.real_owner, self.netname);
			teamsprint (self.building.real_owner.team_no, self.building.real_owner, " dismantled ");
			teamsprint (self.building.real_owner.team_no, self.building.real_owner, self.building.real_owner.netname);
			teamsprint (self.building.real_owner.team_no, self.building.real_owner, "'s Tesla Coil.\n");
		}
		dremove (self.building);
	}
	if (((inp >= 1) && (inp <= 9)))
	{
		ResetMenu ();
		self.impulse = 0;
		bound_other_ammo (self);
		if ((self.armorvalue == 0))
		{
			self.armortype = 0;
			self.armorclass = 0;
			self.items = (self.items - (self.items & ((8192 | 16384) | 32768)));
		}
		W_SetCurrentAmmo ();
	}
};

// Engineer extractor
void () Menu_EngineerFix_Extractor =
{
	local string level;
	local string hp;
	local string obj_metal;

	level = ftos(self.building.ammo_cells + 1);
	hp = ftos(self.building.health);
	obj_metal = ftos(self.building.ammo_metal);

	CenterPrint (self, "^7[^6Metal Extractor^7]\n^1Level: ^3",level,"\n^1Health: ^3",hp,"\n^1Metal: ^3",obj_metal,"\n\n[^11^7] Extract Metal\n[^12^7] Repair Extractor\n[^13^7] Nothing\n");
};

void (float inp) Menu_EngineerFix_Extractor_Input =
{
	if (inp == 1)
	{
		if (self.building.ammo_metal > 0)
		{
			local float tmp_flt;
			tmp_flt = self.maxammo_metal - self.ammo_metal;
			if (tmp_flt == 0)
				sprint(self, "You have reached your carrying capacity for metal\n");
			else
			{
				if (tmp_flt > self.building.ammo_metal)
				{
					self.ammo_metal = self.ammo_metal + self.building.ammo_metal;
					self.building.ammo_metal = 0;
				}
				else
				{
					if ((self.ammo_metal + self.building.ammo_metal) > self.maxammo_metal)
					{
						self.building.ammo_metal = self.building.ammo_metal - (self.maxammo_metal - self.ammo_metal);
						self.ammo_metal = self.maxammo_metal;
					}
					else
					{
						self.ammo_metal = self.ammo_metal + self.building.ammo_metal;
						self.building.ammo_metal = 0;
					}
				}
			}
		}
		else
		{
			sprint(self, "There is no metal to extract from this unit\n");
		}
	}

	if ((inp >= 1) && (inp <= 9))
	{
		ResetMenu ();
		self.impulse = 0;
		W_SetCurrentAmmo();
	}
};
// Engineer build menu
void () Menu_Engineer =
{
	local string line1;
	local string line2;
	local string line3;
	local string line4;
	local string line5;
	local string costline;
	local string cost1;
	local string cost2;

/*	if (self.has_dispenser == 1)
	{
		line1 = "“.. Destroy Dispenser             \n";
	}
	else
	{
//		line1 = "“.. Build Ammo&Armor Dispenser    \n";
		cost1 = "^3";
		if (self.ammo_cells < BUILDING_DISPENSER_NEEDCELLS)
			cost1 = "^1";
		cost1 = strcat(cost1,"   cells^7: ",ftos(BUILDING_DISPENSER_NEEDCELLS), "\n");
		costline = cost1;
		line1 = strcat("“.. Build Ammo&Armor Dispenser    \n",costline,"\n");
	}*/
	if (self.has_sentry == 1)
	{
		line2 = "[^12^7] Destroy Sentry Gun            \n";
	}
	else
	{
		//if (self.ammo_cells >= BUILDING_SENTRY_NEEDCELLS && self.ammo_metal >= BUILDING_SENTRY_NEEDMETAL)
	//	{
		cost1 = "^3";
		cost2 = "^3";
		if (self.ammo_cells < BUILDING_SENTRY_NEEDCELLS)
			cost1 = "^1";
		cost1 = strcat(cost1,"   cells^7: ",ftos(BUILDING_SENTRY_NEEDCELLS));
		if (self.ammo_metal < BUILDING_SENTRY_NEEDMETAL)
			cost2 = "^1";
		cost2 = strcat(cost2,"    metal^7: ",ftos(BUILDING_SENTRY_NEEDMETAL), "\n");
		costline = strcat(cost1," ",cost2);
		line2 = strcat("[^12^7] Build Sentry Gun              \n",costline);

	}
	if (self.has_tesla == 1)
	{
		line3 = "[^13^7] Destroy Tesla Sentry Gun      \n";
	}
	else
	{
//		if (self.ammo_cells >= BUILDING_TESLA_NEEDCELLS && self.ammo_metal >= BUILDING_TESLA_NEEDMETAL)
//		{
		cost1 = "^3";
		cost2 = "^3";
		if (self.ammo_cells < BUILDING_TESLA_NEEDCELLS)
			cost1 = "^1";
		cost1 = strcat(cost1,"   cells^7: ",ftos(BUILDING_TESLA_NEEDCELLS));
		if (self.ammo_metal < BUILDING_TESLA_NEEDMETAL)
			cost2 = "^1";
		cost2 = strcat(cost2,"   metal^7: ",ftos(BUILDING_TESLA_NEEDMETAL), "\n");
		costline = strcat(cost1," ",cost2);
		line3 = strcat("[^13^7] Build Tesla Sentry Gun        \n",costline);

	}
	if (self.has_teleporter != 0) //CH messy, yes
	{
		if (self.has_teleporter == 1 && self.ammo_cells >= BUILDING_TELEPAD_NEEDCELLS && self.ammo_metal >= BUILDING_TELEPAD_NEEDMETAL)
			line4 = "... Build a Teleporter Pad        \n.®® Destroy a Teleporter Pad      \n";
		else if (self.has_teleporter == 1 && self.ammo_cells >= BUILDING_TELEPAD_NEEDCELLS && self.ammo_metal >= BUILDING_TELEPAD_NEEDMETAL)
			line4 = ".®® Destroy a Teleporter Pad      \n";
		if (self.has_teleporter == 2)
			line4 = ".®® Destroy Both Teleporter Pads  \n";
		}
//	else if (self.ammo_cells >= 90 && self.tf_items & 131072)
		else if (self.ammo_cells >= BUILDING_TELEPAD_NEEDCELLS && self.ammo_metal >= BUILDING_TELEPAD_NEEDMETAL)
			line4 = "... Build a Teleporter Pad        \n                                  \n";
		else
			line4 = "                                  \n";

//	if (self.ammo_cells >= BUILDING_EXTRACTOR_NEEDCELLS)
//	if (self.has_extractor > 3)
//		line5 = "^1... Build Metal Extractor         \n";
	
	cost1 = "^3";
	if (self.ammo_cells < BUILDING_EXTRACTOR_NEEDCELLS)
		cost1 = "^1";
	cost1 = strcat(cost1,"   cells^7: ",ftos(BUILDING_EXTRACTOR_NEEDCELLS),"                  ");
	costline = cost1;
	if (self.has_extractor >= 3)
		line5 = strcat("[^16^7] ^1Build Metal Extractor         \n",costline,"\n\n");
	else
		line5 = strcat("[^16^7] Build Metal Extractor         \n",costline,"\n\n");

	local string strn;
	local string metalcnt;
	metalcnt = ftos(self.ammo_metal);

	// Dispenser moved down here
	if (self.has_dispenser == 1)
	{
		line1 = "[^11^7] Destroy Dispenser             \n";
	}
	else
	{
		cost1 = "^3";
		if (self.ammo_cells < BUILDING_DISPENSER_NEEDCELLS)
			cost1 = "^1";
		cost1 = strcat(cost1,"   cells^7: ",ftos(BUILDING_DISPENSER_NEEDCELLS),"                  ");
		costline = cost1;
		line1 = strcat("^7[^11^7] Build Ammo&Armor Dispenser  \n",costline,"\n");
	}

	strn = strcat("^7Engineer Build Menu\n ^3Metal: [",metalcnt,"]\n^3Cells: [",ftos(self.ammo_cells),"]\n\n", line1, strcat(line2, line3, line4), strcat(line5, "... Nothing                       \n\n"));
	CenterPrint(self, strn);
};
