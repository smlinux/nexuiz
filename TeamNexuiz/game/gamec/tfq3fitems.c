/*
=============
	XavioR's Q3F/ETF Entity recognition
							==============
*/
// q3f_forts seems to work almost perfectly --
//any other map will probably need a small to large amount of entity editing;
//still, this code does do a lot of work for you so give it a look :)
.string groupname;
//.string allowteams;
.string give;
.string active_all_sound;
.string carried_message;
.string active_all_message;
.string carried_sound;
.string holding;
.float gameindex;
.float teamscore;
.float floating;
//.vector orig_origin;

// Q3F/ETF Maps dont have info_tfdetects, so this calls it.
void () DoTFDetect =
{
	if (q3fdetect == 1)
		return;
self.display_item_status1 = 1;
self.n_s_c = "����� flag: carried by";
self.display_item_status2 = 2;
self.impulse = 64;
//self.classname = "info_tfdetect";
self.b_n = "\n";
self.t_s_h = "���� flag: base.";
//self.origin = '-80 -60 108';
self.t_s_c = "���� flag: carried by";
self.n_s_h = "����� flag: base.";
self.b_t = "Amnesia\n��� CHOOSE YOUR TEAM ���\n\n�..� BLUE TEAM\n�..� ��� TEAM \n\n��.� AUTO TEAM\n";
self.b_b = "TeamFortress";
self.n_s_m = "����� flag: down.";
self.t_s_m = "���� flag: down.";
q3fdetect = 1;
info_tfdetect();
};

void () PossiblyDoTFDetect =
{
	if (q3fdetect != 1)
	{
		newmis = spawn();
		newmis.classname = "info_tfdetect";
		newmis.nextthink = time;
		newmis.think = DoTFDetect;
	}
}

//	Converts item to FLAG
void (float tno) ConvertToFlag =
{
	PossiblyDoTFDetect();
	local string droppedmsg;

	if (self.allowteams == "red")
	{
//		if (redflagexists == 1)
//			return;
		self.team_no = 2;
		self.owned_by = 1;
		self.n_b = " took the Blue ����!\n";
		droppedmsg = " Dropped the Blue flag\n";
		self.netname = "Red Flag";
		redflagexists = 1;

			if (!self.goal_no)
		self.goal_no = 200;		// Temp Goal Number, can be overridden by a "goal" def in the entity
	}
	if (self.allowteams == "blue")
	{
//		if (blueflagexists == 1)
//			return;
		self.team_no = 1;
		self.owned_by = 2;
		self.n_b = " took the Red ����!\n";
		droppedmsg = " Dropped the Red flag\n";
		self.netname = "Blue Flag";
		blueflagexists = 1;

			if (!self.goal_no)
		self.goal_no = 100;		// Temp Goal Number, can be overridden by a "goal" def in the entity
	}
	self.classname = "item_tfgoal";
	if (self.carried_message)
		self.message = self.carried_message;

	self.d_t = "the ����� ���� your flag!\n";		// The enemy stole your flag msg
	self.b_o = "Your flag has been stolen!\n";

	self.noise = self.carried_sound;
//	self.noise3 = self.inactive_all_message;
	self.noise3 = "Your flag has returned to base!\n";
//	self.noise4 = self.inactive_all_message;
	self.noise4 = "The enemy flag has returned to base!\n";

//	self.impulse = 9;
	self.items = 133701;

	self.mdl = self.model;

//	self.mdl = "models/flag.md3";

	if (!self.delay)
		self.delay = self.wait;

	self.d_n_n = droppedmsg;
	self.d_n_t = droppedmsg;

	self.g_a = 2741;
	self.g_e = 17;


	item_tfgoal();
};

// Simulate animation for converted tfgoal backpack
// Very unorthodox -- i cant find out why self.owner.velocity has no effect
void () PackFloat =
{
	self.owner.angles_y = self.owner.angles_y + 10;

	if (self.floating == -17)
	{
		self.floating = 9;
	}
	if (self.floating == 0)
	{
		self.floating = 9;
	}
	if (self.floating > 0)
	{
		self.owner.origin_z = self.owner.origin_z + 3;
		self.floating = self.floating - 1;
	}
	if (self.floating == 0)
	{
		self.floating = -9;
	}
	if (self.floating < 0)
	{
		self.owner.origin_z = self.owner.origin_z - 3;
		self.floating = self.floating + 1;
	}
	self.owner.movetype = 9;

//	self.nextthink = (time + 0.500000);
	self.nextthink = time + 0.01;
	self.think = PackFloat;
};

// This is the function that will convert an item to a backpack
//(happens with any item that has a "give" value).
void () ConvertToBackPack =
{
	PossiblyDoTFDetect();
	if (self.give == "")
		return;

//	self.classname = "i_t_g";
	if (self.allowteams == "red")
	{
		self.team_no = 2;
		self.owned_by = 2;
	}
	if (self.allowteams == "blue")
	{
		self.team_no = 1;
		self.owned_by = 1;
	}

	self.message = "Resupplied!\n";
	if (self.carried_message != "")
		self.message = self.carried_message;
	if (self.active_all_message != "")
		self.message = self.active_all_message;

	self.mdl = self.model;
	self.noise = self.active_all_sound;
	self.g_e = 1;
	self.g_a = 1;

	self.flags = self.flags & FL_ITEM & FL_WEAPON; // makes it turn around -- much more bandwidth efficient

/*	self.orig_origin = self.origin;		// old pack float code
	newmis = spawn();					// thx savagex for making me aware of cl_itembobheight
	newmis.floating = -17;
	newmis.owner = self;
	newmis.think = PackFloat;
	newmis.nextthink = (time + 1.000000);*/

	// If no ammo amount is specified in the entity, it will default to these values.
	// The reason for this is because q3f/etf uses "give" commands to add ammo, and I can't
	//convert those easily :(
	if (!(self.ammo_nails || self.ammo_cells || self.ammo_rockets || self.health))
	{
		self.health = 50;
		self.ammo_shells = 20;
		self.ammo_nails = 100;
		self.ammo_rockets = 15;
		self.a_c = 25;
		self.armorvalue = 100;
		self.no_grenades_1 = 2;
		self.no_grenades_2 = 1;
	}
	i_t_g ();
};

// Converts Q3F/ETF Team Spawn points to tf-recognized ones.
/*void () info_player_start =
{
	if (self.allowteams == "blue")
		self.team_no = 1;
	if (self.allowteams == "red")
		self.team_no = 2;
	i_p_t();
};*/

void() info_notnull =
{
	if (self.give != "")
	{
		ConvertToBackPack ();
	}
	if (self.groupname == "blueflag")
		ConvertToFlag(1);
	if (self.groupname == "redflag")
		ConvertToFlag(2);
};

void() func_goalinfo =
{
	if (self.give != "")
	{
		ConvertToBackPack ();
	}
	if (self.groupname == "blueflag")
		ConvertToFlag(1);
	if (self.groupname == "redflag")
		ConvertToFlag(2);
};

void() func_goalitem =
{
	if (self.give != "")
	{
		ConvertToBackPack ();
	}
	if (self.groupname == "blueflag" && self.gameindex != 3) {
		ConvertToFlag(1);
	}
	if (self.groupname == "redflag" && self.gameindex != 3) {
		ConvertToFlag(2);
	}
};

// Converts trigger_multiples to Flag Goals (the point(s) where the flag is capped).
//This works for q3f_forts and machse and a couple other ones. 
void(float tno) ConvertToGoal =
{
	if (!self.teamscore)
		return;
	if (tno == 1)
	{
		self.team_no = 2;
		self.axhitme = 200;
		self.items_allowed = 200;
	}
	if (tno == 2)
	{
		self.team_no = 1;
		self.axhitme = 100;
		self.items_allowed = 100;
	}

	self.is_converted_goal = "yes"; // used with spawn point finder, no connnection with the actual conversion

	self.goal_result = 2;
	self.noise = self.active_all_sound;
	self.frags = self.teamscore;
	self.count = self.teamscore;
	self.classname = "i_t_g";

	self.g_a = 1;
	self.g_e = 3;

	i_t_g();
};

void() CheckIfQ3FTrigger =			// Handles trigger_multiples from Q3F/ETF -- called from trigger_multiple
{
	if (self.holding == "blueflag")
		ConvertToGoal (1);
	if (self.holding == "redflag")
		ConvertToGoal (2);
	if (self.holding == "oneflag" && self.allowteams == "blue")
		ConvertToGoal (1);
	if (self.holding == "oneflag" && self.allowteams == "red")
		ConvertToGoal (2);
};

// func_hud is not valid in Team:Nexuiz (dont know if it will ever be)
void () func_hud =
{
	dremove(self);
};
