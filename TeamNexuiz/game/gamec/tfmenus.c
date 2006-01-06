/*

  */

//move to tfdefs:
.entity building;

// Menus/Menu Input references
void () Menu_EngineerFix_Tesla;
void (float inp) Menu_EngineerFix_Tesla_Input;

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
	if ((self.current_menu == 18))
	{
		Menu_EngineerFix_Tesla_Input (inp);
	}
};

// Tesla Menu
void () Menu_EngineerFix_Tesla =
{
	CenterPrint (self, "Tesla Modification Lab: ^16^7 Upgrades Max\n[^11^7] Upgrade Voltage           - 1u\n[^12^7] Upgrade Amperage          - 1u\n[^13^7] Upgrade Power Supply      - 1u\n[^14^7] Make TeslaTurret(tm)      - 2u\n[^15^7] Improved Targeting System - 2u\n[^16^7] Add Spy Detector          - 4u\n[^17^7] Repair and Recharge           \n[^18^7] Dismantle                     \n[^19^7] Îïôèéîç                       ");
};

// Tesla Menu Input
void (float inp) Menu_EngineerFix_Tesla_Input =
{
	local string temp;
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