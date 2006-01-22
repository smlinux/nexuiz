float intermission_running;				// This was moved here from mauvebot.c
float intermission_exittime;			// This was moved here from g_world.c
void (entity AD) ParseTFDetect;

entity () FindIntermission =
{
	local entity spot;
	local float cyc;

	spot = find (world, classname, "info_intermission");
	if (spot)
	{
		cyc = (random () * 1);
		return (spot);
	}
	spot = find (world, classname, "info_player_start");
	if (spot)
	{
		return (spot);
	}
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
	{
		cyc = (random () * 6);
		while ((cyc > 1))
		{
			spot = find (spot, classname, "info_player_deathmatch");
			if (!spot)
			{
				spot = find (spot, classname, "info_player_deathmatch");
			}
			cyc = (cyc - 1);
		}
		return (spot);
	}
	objerror ("FindIntermission: no spot");
};

// This sets all the settings for the level including teams allowed, and lives and legal classes etc.
// it is called only once, for the first player who joins
void () DecodeLevelParms =
{
		if (parems_decoded == 1)
			return;
		else {
			// The following allows play on Nexuiz/NexCTF maps if there is no info_tfdetect on a map
			if (team1maxplayers == 0)
				team1maxplayers = 4;
			if (team2maxplayers == 0)
				team2maxplayers = 4;
			if (team1lives == 0)
				team1lives = -1;
			if (team2lives == 0)
				team2lives = -1;

			local entity decent;
			decent = find (world, classname, "info_tfdetect");
			if ((decent != world))
			{
//				teamplay = cvar ("teamplay");
//				if ((teamplay == 0))
//				{
					cvar_set ("teamplay", "21?TeamFortress");
//				}
				ParseTFDetect (decent);		// This returns the map's team/class allowances
				if (((number_of_teams <= 0.000000) || (number_of_teams >= 5.000000)))
				{
					number_of_teams = 4.000000;
				}
			}
		}
		parems_decoded = 1;
};

// Execute Change Level
void () execute_changelevel =
{
	local entity pos;

	intermission_running = 1;
	if (deathmatch)
	{
		intermission_exittime = (time + 5);
	}
	else
	{
		intermission_exittime = (time + 2);
	}
	WriteByte (2, 32);
	WriteByte (2, 3);
	WriteByte (2, 3);
	pos = FindIntermission ();
	other = find (world, classname, "player");
	while ((other != world))
	{
		other.view_ofs = '0 0 0';
		other.v_angle = pos.mangle;
		other.angles = pos.mangle;
		other.fixangle = 1;
		other.nextthink = (time + 0.5);
		other.takedamage = 0;
		other.solid = 0;
		other.movetype = 0;
		other.modelindex = 0;
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}
	WriteByte (2, 30);
};

.entity teambubble_needhealth;		// displays when player's health is below 30%
.entity teambubble_friendly;		// displays that player is friendly teammate
//repeated defs:
.float buttonchat;
.entity exteriormodeltoclient;

void() TeamBubbleThink =
{
	self.nextthink = time;
	if (!self.owner.modelindex || self.owner.teambubble_friendly != self)
	{
		remove(self);
		return;
	}
	//setorigin(self, self.owner.origin + '0 0 15' + self.owner.maxs_z * '0 0 1'); //bandwidth hax
	if (self.owner.buttonchat || self.owner.deadflag)
		self.model = "";
	else
		self.model = self.mdl;
	
};

.float() customizeentityforclient;		// new DP extension used for the team bubble
float() ChatBubble_customizeentityforclient = {return (self.owner.team_no == other.team_no && other.killcount > -666);};


void() UpdateTeamBubble =
{
	if (!self.modelindex || !cvar("teamplay"))
		return;
	// spawn a teambubble entity if needed
	if (!self.teambubble_friendly && cvar("teamplay"))
	{
		self.teambubble_friendly = spawn();
		self.teambubble_friendly.owner = self;
		self.teambubble_friendly.exteriormodeltoclient = self;
		self.teambubble_friendly.think = TeamBubbleThink;
		self.teambubble_friendly.nextthink = time;
		setmodel(self.teambubble_friendly, "models/team/team.sp2");
//		setorigin(self.teambubble_friendly, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.teambubble_friendly, self.teambubble_friendly.origin + '0 0 10' + self.maxs_z * '0 0 1');
		setattachment(self.teambubble_friendly, self, "");
		self.teambubble_friendly.scale = .07;
		self.teambubble_friendly.mdl = self.teambubble_friendly.model;
		self.teambubble_friendly.model = self.teambubble_friendly.mdl;
		self.teambubble_friendly.customizeentityforclient = ChatBubble_customizeentityforclient;
	}
}
