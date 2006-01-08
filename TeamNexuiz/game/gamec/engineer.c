.float option, opton5;
.float has_mine;
void () MagnetMineTouch;
void () MagTimer;
void () RemoveMagnetMine;
//tesla
void () Tesla_Die;
void () Tesla_Pain;
void () Tesla_Idle;
void () Tesla_Touch;

void () SUB_NULL;

//temp
void (entity bld) CheckBelowBuilding;
void (entity gunhead) CheckSentry;
void () Sentry_Rotate;
float () Sentry_FindTarget;
void () Sentry_FoundTarget;
void () Sentry_HuntTarget;
void () Sentry_Pain;
void () Sentry_Die;

void EngineerSpecial()
{
	//	sprint(self, "Not done yet\n");	
	// this is gonna contain build menu eventually
};

/*==========================
 TF Engineer Build Function
 =========================*/
void(entity gunhead) CheckSentry = 
{
	local vector dist;
	local entity gunbase;
	gunbase = gunhead.trigger_field;
	dist = gunbase.origin - gunhead.origin;
	if (vlen(dist) > 15)
	{
		bprint(self.real_owner.netname);
		bprint("'s sentry gun malfunctioned\n");
		Sentry_Die();
	}
};

void () TeamFortress_EngineerBuild =
{
	local entity te;

	if ((self.is_building == 0))
	{
//		if ((((self.ammo_cells < 100) && (self.has_dispenser == 0)) && (self.has_sentry == 0)))
//		{
//			CenterPrint (self, "You don't have enough metal to \nbuild anything.\n\n");
//			return;
//		}
		self.current_menu = 15;
		self.menu_count = 25;
	}
	else
	{
		if ((self.is_building == 1))
		{
			sprint (self, "You stop building.\n");

			if (self.weaponentity.pos1 != '0 0 0')
			{
				self.reload_time = time;
				self.weaponentity.pos1 = '0 0 0';
				self.weaponentity.lip = PLAYER_WEAPONSELECTION_SPEED;
			}

			self.pausetime = 0;
			self.tfstate = (self.tfstate - (self.tfstate & 65536));
			TeamFortress_SetSpeed (self);
			te = find (world, netname, "build_timer");
			while (te)
			{
				if ((te.owner == self))
				{
					dremove (te);
					te = world;
				}
				else
				{
					te = find (te, netname, "build_timer");
				}
			}
			self.is_building = 0;
//			self.current_weapon = self.weapon;		// add function to make weapon disappear?
			W_SetCurrentAmmo ();
		}
	}
};

float(entity obj, entity builder) CheckArea = 
{
	local vector src;
	local vector end;
	local float pos;
	pos = pointcontents(obj.origin);
	if (pos == -2 || pos == -6)
	{
		return 0;
	}
	src_x = obj.origin_x + obj.maxs_x + 16;
	src_y = obj.origin_y + obj.maxs_y + 16;
	src_z = obj.origin_z + obj.maxs_z + 16;
	pos = pointcontents(src);
	if (pos == -2 || pos == -6)
	{
		return 0;
	}
	end_x = obj.origin_x + obj.mins_x - 16;
	end_y = obj.origin_y + obj.mins_y - 16;
	end_z = obj.origin_z + obj.mins_z - 16;
	traceline(src, end, 1, obj);
	if (trace_fraction != 1)
	{
		return 0;
	}
	pos = pointcontents(end);
	if (pos == -2 || pos == -6)
	{
		return 0;
	}
	src_x = obj.origin_x + obj.mins_x - 16;
	src_y = obj.origin_y + obj.maxs_y + 16;
	src_z = obj.origin_z + obj.maxs_z + 16;
	pos = pointcontents(src);
	if (pos == -2 || pos == -6)
	{
		return 0;
	}
	end_x = obj.origin_x + obj.maxs_x + 16;
	end_y = obj.origin_y + obj.mins_y - 16;
	end_z = obj.origin_z + obj.mins_z - 16;
	traceline(src, end, 1, obj);
	if (trace_fraction != 1)
	{
		return 0;
	}
	pos = pointcontents(end);
	if (pos == -2 || pos == -6)
	{
		return 0;
	}
	traceline(builder.origin, obj.origin, 1, builder);
	if (trace_fraction != 1)
	{
		return 0;
	}
	return 1;
};

void(float objtobuild) TeamFortress_Build = 
{
	if (self.is_building == 1) {	// double-checks incase someone uses code with TeamFortress_EngineerBuild(number)
		TeamFortress_EngineerBuild();
		return;
	}
	if ((self.reload_time + .25) > time) { 
		sprint(self, "You cant build while reloading.\n");
		return; 
	}

	local float btime;
	local entity te;
	local vector tmp1;
	local vector tmp2;
	newmis = spawn();
	makevectors(self.v_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward) * 64;
	newmis.origin = self.origin + v_forward;
	if (objtobuild == 1)
	{
		if (self.has_dispenser)
		{
			sprint(self, "You can only have one dispenser.\nTry dismantling your old one.\n");
			return;
		}
		tmp1 = '-16 -16 0';
		tmp2 = '16 16 24';
		newmis.mdl = "progs/dispencr.mdl";
		newmis.netname = "dispenser";
		btime = time + 2;
	}
	else
	{
		if (objtobuild == 2)
		{
			if (self.has_sentry)
			{
				sprint(self, "You can only have one sentry gun.\nTry dismantling your old one.\n");
				return;
			}
			tmp1 = '-16 -16 0';
			tmp2 = '16 16 48';
//			newmis.mdl = "progs/turrbase.mdl";
			newmis.mdl = "models/sentry/turr1_base.md3";
//			newmis.scale = .75;
			newmis.netname = "sentrygun";
//			btime = time + 5;
			btime = .1;
		}
		if ((objtobuild == 3))
		{
			if (self.has_tesla)
			{
				sprint (self, "You can only have one tesla gun\n");
				return;
			}
			tmp1 = '-16 -16 0';
			tmp2 = '16 16 48';
			newmis.mdl = "models/engineer/tesla/tesla.md3";
			newmis.scale = .70;			//temp -- morphed's models too freaking huge :x

			newmis.netname = "tesla";
			btime = (time + 6);
		}
// Begin telepad 1
		if (objtobuild == 5)
		{
			if (self.has_teleporter >= 2)
			{
				sprint(self, "You can only have 2 teleporters.\nTry dismantling an old one.\n");
	         dremove(newmis);
				return;
			}
			tmp1 = '-16 -16 0';
			tmp2 = '16 16 4';
			newmis.mdl = "progs/telepad.mdl";
			newmis.netname = "teleporter";
	
			btime = time + 3;
		}
// End telepad 1
	}
	if (CheckArea(newmis, self) == 0)
	{
		sprint(self, "Not enough room to build here\n");
		dremove(newmis);
		return;
	}
	self.is_building = 1;
	self.immune_to_check = time + 10;
//	self.maxspeed = 0;			// make sure player cant move
	self.tfstate = self.tfstate | 65536;
/*	self.weapon = self.current_weapon;		// get rid of player's weapon model
	self.current_weapon = 0;
	self.weaponmodel = "";
	self.weaponframe = 0;*/
//	TeamFortress_SetSpeed(self);			// hmm? player cant move?
	newmis.owner = self;
	newmis.classname = "timer";
	newmis.netname = "build_timer";
	newmis.nextthink = btime;
	newmis.think = TeamFortress_FinishedBuilding;
	newmis.colormap = self.colormap;
	newmis.weapon = objtobuild;
	newmis.angles_y = anglemod(self.angles_y + 180);
	newmis.velocity = '0 0 8';
	newmis.movetype = 6;
	newmis.solid = 2;
	setmodel(newmis, newmis.mdl);
	setsize(newmis, tmp1, tmp2);
	setorigin(newmis, newmis.origin);
	newmis.flags = newmis.flags - (newmis.flags & 512);

	self.velocity = '0 0 0';		// stop player movement
	DoReload (5, (btime - time));		// Engineer build function shared with reload one
										// 5 is for building, btime minus time is for build time
};

void(entity bld) CheckBelowBuilding = 
{
	local vector below;
	below = bld.origin;
	if (bld.classname == "detpack")
	{
		below_z = below_z - 8;
	}
	else
	{
		below_z = below_z - 24;
	}
	traceline(bld.origin, below, 1, bld);
	if (trace_fraction == 1)
	{
		bld.movetype = 6;
		bld.flags = bld.flags - (bld.flags & 512);
	}
};

void () Tesla_Animate;
void() TeamFortress_FinishedBuilding = 
{
	local entity oldself;
	local vector source;

	if (self.owner.is_building != 1)
	{
		return;
	}
	oldself = self;
	self = self.owner;
	oldself.owner = world;
	oldself.real_owner = self;
	self.is_building = 0;
	self.tfstate = self.tfstate - (self.tfstate & 65536);
	self.current_weapon = self.weapon;
	self.StatusRefreshTime = time + 0.1;
	TeamFortress_SetSpeed(self);
/*	if (oldself.weapon == 1)
	{
		self.has_dispenser = 1;
		sprint(self, "You finish building the dispenser.\n");
		teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Dispenser.\n");
		self.ammo_cells = self.ammo_cells - 100;
		oldself.classname = "building_dispenser";
		oldself.netname = "dispenser";
		oldself.blocked = T_Dispenser;
		oldself.touch = T_Dispenser;
		oldself.max_health = 150;
		oldself.health = 150;
		oldself.think = DispenserThink;
		oldself.nextthink = time + 5;
		oldself.th_die = Dispenser_Die;
		oldself.mdl = "progs/dispencr.mdl";
		oldself.team_no = self.team_no;
		oldself.real_owner = self;
		oldself.colormap = self.colormap;
		oldself.takedamage = 2;
		oldself.owner = world;
		oldself.movetype = 6;
		oldself.velocity = '0 0 8';
		oldself.flags = oldself.flags - (oldself.flags & 512);
		oldself.ammo_shells = ceil(self.ammo_shells * 0.25);
		oldself.ammo_nails = ceil(self.ammo_nails * 0.25);
		oldself.ammo_rockets = ceil(self.ammo_rockets * 0.25);
		oldself.ammo_cells = ceil(self.ammo_cells * 0.25);
		oldself.armorvalue = ceil(self.armorvalue * 0.25);
		self.ammo_shells = ceil(self.ammo_shells * 0.75);
		self.ammo_nails = ceil(self.ammo_nails * 0.75);
		self.ammo_rockets = ceil(self.ammo_rockets * 0.75);
		self.ammo_cells = ceil(self.ammo_cells * 0.75);
		self.armorvalue = ceil(self.armorvalue * 0.75);
		oldself.solid = 2;
		setmodel(oldself, oldself.mdl);
		//setsize(oldself, '-8 -8 0', '8 8 24');gold. commented out.. plexi's idea :j
		setorigin(oldself, oldself.origin);
	}
	else
	{*/
		if (oldself.weapon == 2)
		{
			local entity barrel;
			barrel = spawn();
//			barrel.mdl = "models/sentry/turr1_base.md3";
//			barrel.mdl = "models/sentry/turr1_barrel.md3";
//			barrel.scale = .75;
			//barrel.solid = 2;

//			barrel.angles_x = barrel.angles_x - 70;

//			barrel.angles_z = barrel.angles_z - 90;
/*			barrel.angles_x = 0;
			barrel.angles_y = oldself.angles_y;
			barrel.angles_z = 0;*/
//			barrel.movetype = 4;
//			barrel.movetype = MOVETYPE_FOLL`OW;
			barrel.yaw_speed = 10;
//			barrel.angles_z = barrel.angles_z - 45;
			setmodel(barrel, "models/sentry/turr1_barrel.md3");
//			setsize(barrel, '-16 -16 0', '16 16 48');		// temp //'d
//			setorigin(barrel, oldself.origin + '0 0 8');
			setorigin(barrel, '0 0 0');
			

			self.has_sentry = 1;
			sprint(self, "You finish building the sentry gun.\n");
			teamsprint(self.team_no, self, self.netname);
			teamsprint(self.team_no, self, " has built a Sentry Gun.\n");
			oldself.classname = "building_sentrygun_base";
			oldself.netname = "sentry gun";
			oldself.takedamage = 0;
			oldself.th_die = Sentry_Die;
			self.ammo_cells = self.ammo_cells - 130;
			setsize(oldself, '-16 -16 0', '16 16 4');
			newmis = spawn();
			newmis.classname = "building_sentrygun";
			newmis.health = 150;
			newmis.max_health = newmis.health;
			newmis.weapon = 1;
			newmis.th_die = Sentry_Die;
			newmis.th_pain = Sentry_Pain;
//			newmis.mdl = "progs/turrgun.mdl";
			newmis.mdl = "models/sentry/turr1_body.md3";
//			newmis.scale = .75;
			sound(oldself, 3, "weapons/tnkatck4.wav", 1, 1);
			newmis.solid = 2;
			setmodel(newmis, newmis.mdl);
			setsize(newmis, '-16 -16 0', '16 16 48');
			setorigin(newmis, oldself.origin + '0 0 8');
			newmis.real_owner = oldself.real_owner;
			newmis.trigger_field = oldself;
			oldself.oldenemy = newmis;
			newmis.movetype = 4;
			oldself.colormap = self.colormap;
			newmis.colormap = self.colormap;
			newmis.takedamage = 2;
			newmis.velocity = '0 0 -8';
			newmis.flags = newmis.flags - (newmis.flags & 512);
			oldself.flags = oldself.flags - (oldself.flags & 512);
			newmis.team_no = self.team_no;
			newmis.think = lvl1_sentry_stand;
			newmis.nextthink = time + 0.5;
			newmis.yaw_speed = 10;
			newmis.heat = 0;
			newmis.angles_x = 0;
//			newmis.angles_y = oldself.angles_y;
			newmis.angles_y = oldself.angles_y;
			newmis.angles_z = 0;
			newmis.waitmin = anglemod(newmis.angles_y - 50);
			newmis.waitmax = anglemod(newmis.angles_y + 50);
			if (newmis.waitmin > newmis.waitmax)
			{
				newmis.waitmin = newmis.waitmax;
				newmis.waitmax = anglemod(newmis.angles_y - 50);
			}
			newmis.ammo_shells = 25;
			newmis.maxammo_shells = 100;
			newmis.maxammo_rockets = 20;

			newmis.barrel_ent = barrel;

//			setattachment(newmis, oldself, "tag_base_body");
			setattachment(barrel, newmis, "tag_body_barrel");


		}
		else
		{
//tesla
			if ((oldself.weapon == 3))
			{
				self.has_tesla = 1;
				sprint (self, "You finish building the tesla coil.\n");
				oldself.real_owner = self;
				teamsprint (self.team_no, self, self.netname);
				teamsprint (self.team_no, self, " has built a tesla.\n");
				sound (oldself, 3, "weapons/guerilla_set.wav", 1, 1);
				oldself.classname = "building_tesla";
				oldself.netname = "tesla";
				oldself.takedamage = 2;
				oldself.solid = 2;
				oldself.th_die = Tesla_Die;
				oldself.th_pain = Tesla_Pain;
				self.ammo_cells = (self.ammo_cells - 150);
				oldself.health = 200;
				oldself.movetype = 6;
				oldself.colormap = self.colormap;
				oldself.velocity = '0 0 -8';
				oldself.avelocity = '0 0 0';
				oldself.flags = (oldself.flags - (oldself.flags & 512));
				oldself.team_no = self.team_no;
				oldself.think = Tesla_Idle;
				oldself.nextthink = (time + 2);
				oldself.touch = Tesla_Touch;
				oldself.enemy = world;
				oldself.maxammo_shells = 0;
				oldself.maxammo_nails = 0;
				oldself.maxammo_rockets = 0;
				oldself.max_health = 100;
				oldself.ammo_cells = 50;
				oldself.tf_items = 0;
				/*if (!(self.weapons_carried & 8))
				{
					oldself.ammo_shells = 2;
					oldself.ammo_nails = 2;
					oldself.ammo_rockets = 1;
					oldself.currentammo = 5;
					oldself.max_health = 200;
					oldself.ammo_cells = 120;
				}*/
				oldself.currentammo = 0;		// 6 Upgrades. (6 minus this number is pgrade count)
				oldself.health = oldself.max_health;
				oldself.waitmin = ((oldself.ammo_shells + 2) * (oldself.ammo_nails + 2));
				oldself.waitmax = 0;

				// The tesla animater -- till I learn to be a better coder ;)
				local entity tesanim;
				tesanim = spawn();
				tesanim.owner = oldself;
				tesanim.think = Tesla_Animate;
				tesanim.nextthink = time;
			}
// TELEPAD 2 BEGIN*/ 
	/*if (oldself.weapon == 5)
	{
		self.has_teleporter = (self.has_teleporter + 1);
		sprint (self, "You finish building the Teleporter Pad.\n");

//        teamprefixsprint(self.team_no,self); //- OfN

        teamsprint(self.team_no, self, self.netname);
		teamsprint(self.team_no, self, " has built a Teleporter Pad.\n");
		sound (oldself, 3, "weapons/guerset.wav", 1, 1);

		self.ammo_cells = self.ammo_cells - 90;

		// Create the teleporter
		oldself.classname = "building_teleporter";
		oldself.netname = "teleporter";
//		oldself.blocked = Teleporter_touch;		// Actual touch function
		oldself.touch = Teleporter_touch;
		oldself.max_health = 300;
		oldself.health = 300;
		oldself.th_die = Teleporter_Die;		// Death function
		oldself.mdl = "progs/telepad.mdl";		// Actual mdl
		oldself.team_no = self.team_no;
		oldself.maxammo_cells = 200;	//CH Max of 20 teleports
		oldself.ammo_cells = 100;	//CH start not at full

		oldself.real_owner = self;			// The Engineer owns this item
		oldself.colormap = self.colormap;	// Set the Color
		oldself.takedamage = 2;
		oldself.owner = world;
		oldself.movetype = 6;
		oldself.velocity = '0 0 8';
		oldself.flags = oldself.flags - (oldself.flags & 512);

		oldself.solid = 2;
		setmodel(oldself, oldself.mdl);
		setsize (oldself, '-16 -16 0', '16 16 4');
		setorigin(oldself, oldself.origin + '0 0 8'); //CH does jump

		oldself.heat = 4; //dont come on for 4 seconds
		oldself.think = Teleporter_heat_think;
		oldself.nextthink = time + 1;
		oldself.spawnflags = 4; //CH cause extensive checks for height

		oldself.is_malfunctioning = 0;
	        oldself.all_active=0; // OfN - reset HACKER improvements
		}
// TELEPAD 2 END
		}*/
	}
	W_SetCurrentAmmo();
};





void () Drop_Magnetic_Mine =
{
	if (self.has_mine == 1)
	{
		sprint (self, "Hey, one mine at a time!\n");
		return;
	}

	local entity item;

	item = spawn ();
	item.team_no = self.team_no;
	item.owner = self;
	item.classname = "drop1";
	item.origin = (self.origin - '0 0 -10');

//	item.angles_x = 360;

	item.angles_y = 45;
	item.flags = 256;
//	item.solid = 2;
	item.solid = SOLID_TRIGGER;
	item.movetype = 6;

	item.velocity = '0 0 1';
	setsize (item, '-1 -1 0', '1 1 6');

	item.nextthink = (time + 180);

	item.touch = MagnetMineTouch;
	setmodel (item, "models/magmine/magnetmine.md3");
	item.scale = .35;

	item.think = RemoveMagnetMine;

	item.pausetime = time + 2;
	self.has_mine = 1;
	sprint(self, "You set a Mag Mine!\n");
}

void EngineerGrenade(float req)
{
	if(req == WR_GRENADE1)
	{
		if(W_ThrowGrenade(W_ArmorGrenade))
			self.grenade_time = time + cvar("g_balance_grenade_armor_refire");
	}
	else if(req == WR_GRENADE2)
	{
		Drop_Magnetic_Mine();
		self.grenade_time = time + 2;
	}
}

void EngineerPreThink()
{
}

void EngineerPostThink()
{
}

void BecomeEngineer(float portion)
{
	self.max_health = cvar("g_balance_class_engineer_health") * portion;

	self.max_armor = cvar("g_balance_class_engineer_armor") * portion;

	self.mass = cvar("g_balance_class_engineer_mass");

	SetPlayerSpeed(self);

	self.items = IT_WEP1 | IT_WEP2 | IT_WEP3 | IT_WEP4;
	self.switchweapon = WEP2;
	self.ammo_shells = floor(20 * portion);
	self.ammo_nails = floor(20 * portion);
	self.ammo_rockets = floor(1 * portion);
	self.ammo_cells = floor(0 * portion);
	self.playerclass = 9;		// TF P.C.
	SetMaxAmmoFor (32);
}

// Magnetic Mine
void () RemoveMagnetMine =
{
	sprint (self.owner, "Your Mag Mine is gone...\n");
	self.owner.has_mine = 0;
	dremove (self);
	return;
};

void () MagTimer =
{
	local entity theowner;
	local string st;

	theowner = self.owner;
	theowner.option5 = (theowner.option5 - .5);
	st = ftos (theowner.option5);
//	sound (theowner, 0, "ambient/100hzhum.wav", 1, 1);		// find new wav! :o
	theowner.origin = self.origin;
	CenterPrint2 (theowner, "You are stuck on a mag mine!\n", st);
	if ((theowner.option5 < 2))
	{
		theowner.option5 = 0;
		sprint (theowner.enemy, "Your Mag Mine died...\n");
		theowner.enemy.has_mine = 0;
		remove (self);
		return;
	}
	self.nextthink = (time + .5);
};

void () MagMineActivate =
{
	if ((other.option == 0))
	{
		self.owner.has_mine = 1;
		newmis = spawn ();
		newmis.classname = "timer";
		newmis.netname = " FlashTimer";
		newmis.team_no = self.owner.team_no;
		newmis.owner = other;
		other.enemy = self.owner;
		newmis.think = MagTimer;
		newmis.nextthink = (time + 1);
		newmis.origin = other.origin;
	}
	other.option5 = (floor ((other.armorvalue * .25)) + 3);
	if ((other.option5 > 15))
	{
		other.option5 = 15;
	}
};

void () RemoveDudMine =
{
	dremove(self);
}

void () MagnetMineTouch =
{
	local float isgood;
	local entity isnearplayer;
	
	isnearplayer = findradius (self.origin, 10);
	while (isnearplayer)
	{
		if ((isnearplayer.classname == "player"))
		{
			isgood = 1;
//			bprint (isnearplayer.classname);
//			bprint ("\n");
//			return;
		}
		isnearplayer = isnearplayer.chain;
	}
	if (isgood != 1)
		return;

	if ((self.pausetime > time))
	{
		return;
	}
	if ((other.classname != "player"))
	{
		return;
	}
	if ((other.health <= 0))
	{
		return;
	}
//	if ((other.is_undercover == 1))		//temp	- add function!!
//	{
//		return;
//	}
	if ((other.team_no == self.owner.team_no))
	{
		return;
	}
	if ((other.classname == "player"))
	{
		MagMineActivate ();
		sprint (other, "You stepped on a Magnetic Mine! :(\n");
		sprint (self.owner, "Your Magnet Mine worked!\n");
		self.pausetime = (time + 5);
	}
	self.touch = SUB_NULL;
	self.effects = EF_BRIGHTFIELD | EF_ADDITIVE;
	self.think = RemoveDudMine;
	self.nextthink = (time + 15);
//	dremove (self);
};

// Checks the distance between the player and the object
void () CheckDistance =
{
	local vector dist;

	if (!(self.owner.building.classname == "building_tesla" && self.enemy.classname == "building_dispenser")) {
	if (self.owner.building != self.enemy)
	{
		dremove (self);
		return;
	} }
	dist = self.enemy.origin - self.owner.origin;
//	if (vlen (dist) > 64)
	if (vlen (dist) > 84)
	{
		CenterPrint (self.owner, "\n");
		self.owner.menu_count = 25;
		self.owner.current_menu = 1;
		self.owner.building = world;
		dremove (self);
		return;
	}
	self.nextthink = (time + 0.3);
};


void (entity gun) Engineer_UseTesla =
{
	local entity dist_checker;
	local string st;

		if ((gun.ammo_rockets == TF_FLARE_LIT))
		{
			gun.maxammo_cells = 120;
		}
		else
		{
			if ((gun.ammo_rockets == TF_FLARE_OFF))
			{
				gun.maxammo_cells = 120;
			}
			else
			{
				if ((gun.ammo_rockets == 2))
				{
					gun.maxammo_cells = 200;
				}
				else
				{
					if ((gun.ammo_rockets == 3))
					{
						gun.maxammo_cells = 300;
					}
				}
			}
		}

	sprint(self, "Èåáìôè:");
	st = ftos(gun.health);
	sprint(self, st);
	sprint(self, "¯");
	st = ftos(gun.max_health);
	sprint(self, st);
	sprint(self, " Ãåììó:");
	st = ftos(gun.ammo_cells);
	sprint(self, st);
	sprint(self, "¯");
	st = ftos(gun.maxammo_cells);
	sprint(self, st);
	st = ftos ((6 - gun.currentammo));
	sprint(self, " Õðçòáäåó Ìåæô:");
	sprint (self, st);
	st = ftos ((6 - gun.currentammo));
	sprint (self, "\n");
	sprint(self, "Öïìôáçå:");
	st = ftos(gun.ammo_shells);
	sprint(self, st);
	sprint(self, " Áíðåòáçå:");
	st = ftos(gun.ammo_nails);
	sprint(self, st);
	sprint(self, " Ðï÷åò Óõððìù:");
	st = ftos(gun.ammo_rockets);
	sprint(self, st);
	sprint(self, "\n");
	if (gun.tf_items)
	{
		if ((gun.tf_items & 2))
		{
			sprint (self, "TeslaTurret(tm) ");
		}
		if ((gun.tf_items & TF_FLARE_OFF))
		{
			sprint (self, "Improved Targeter ");
		}
		if ((gun.tf_items & 1024))
		{
			sprint (self, "Spy Detector");
		}
		sprint (self, "\n");
	}
	self.current_menu = 18;
	self.menu_count = 25;
	self.building = gun;
	dist_checker = spawn ();
	dist_checker.classname = "timer";
	dist_checker.owner = self;
	dist_checker.enemy = gun;
	dist_checker.think = CheckDistance;
	dist_checker.nextthink = (time + 0.3);
};

void () button_fire;
// Engineer and Medic "USE" function -- called when user presses a key bound to +use
// replaces using wrench on sentry gun and buiaxe to heal.
void () Use_Function =
{
	if (self.impulse_wait > time)	// So when the player holds down the use button it doesnt spam sprints
		return;
	self.impulse_wait = time + .5;	// shared with gui menu .impulse_wait

	local vector source;
	local vector org;
	local vector def;
	local float healam;
	local entity te;

	makevectors (self.v_angle);
	source = (self.origin + '0 0 16');
	traceline (source, (source + (v_forward * 64)), 0, self);
	if ((trace_fraction == 1))
	{
		return;
	}
	org = (trace_endpos - (v_forward * 4));
	if ((trace_ent.goal_activation & 8))
	{
		if (Activated (trace_ent, self))
		{
			DoResults (trace_ent, self, 1);
			if ((trace_ent.classname == "func_button"))
			{
				trace_ent.enemy = self;
				other = self;
				self = trace_ent;
				self.dont_do_triggerwork = 1;
				button_fire ();
				self = other;
			}
		}
		else
		{
			if ((trace_ent.else_goal != 0))
			{
				te = Findgoal (trace_ent.else_goal);
				if (te)
				{
					DoResults (te, self, (trace_ent.goal_result & 2));
				}
			}
			else
			{
				sound (self, 1, "player/axhit2.wav", 1, 1);
				WriteByte (4, 23);
				WriteByte (4, 2);
				WriteByte (4, 3);
				WriteCoord (4, org_x);
				WriteCoord (4, org_y);
				WriteCoord (4, org_z);
			}
		}
		return;
	}
//	if (trace_ent.takedamage)
	if (trace_ent.classname != "player")
	{
		if ((trace_ent.classname == "building_dispenser"))
		{
			//Engineer_UseDispenser (trace_ent);
			return;
		}
		else
		{
			if ((trace_ent.classname == "building_sentrygun"))
			{
				//Engineer_UseSentryGun (trace_ent);
				return;
			}
			else
			{
				if ((trace_ent.classname == "building_sentrygun_base"))
				{
					if (trace_ent.oldenemy)
					{
						//Engineer_UseSentryGun (trace_ent.oldenemy);
					}
					return;
				}
				else
				{
					if ((trace_ent.classname == "building_tesla"))
					{
						Engineer_UseTesla (trace_ent);
						return;
					}
				}
			}
		}
	}
};