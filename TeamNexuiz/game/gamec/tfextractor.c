// Team:Nexuiz Metal Extractor
//
// Idea by:				avirox/Wazat
// Implementation:		avirox

void () Extractor_Idle =
{
	// add some flashy effects/animations here or something
	//
	self.ammo_metal = self.ammo_metal + 5;
	if (self.ammo_metal >= BUILDING_EXTRACTOR_MAXMETAL)
	{
		self.ammo_metal = BUILDING_EXTRACTOR_MAXMETAL;
		if (self.ammo_shells != 1)
		{
			sprint(self.real_owner, "One of your metal extractors is full!\n");
			self.ammo_shells = 1;
		}
	}

	if (self.ammo_cells == 0)
		self.nextthink = time + 8;
	else if (self.ammo_cells == 1)
		self.nextthink = time + 6;
	else if (self.ammo_cells == 2)
		self.nextthink = time + 4;
};

void (entity gun) Engineer_UseExtractor =
{
	local entity dist_checker;

	self.current_menu = MENU_EXTRACTOR;
	self.menu_count = 25;
	self.building = gun;
	dist_checker = spawn ();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = (time + 0.3);
};