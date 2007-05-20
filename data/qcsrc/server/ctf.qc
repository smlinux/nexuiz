
.float next_take_time;			// the next time a player can pick up a flag (time + blah)
								/// I used this, in part, to fix the looping score bug. - avirox

//float FLAGSCORE_PICKUP        =  1;
//float FLAGSCORE_RETURN        =  5; // returned by owner team
//float FLAGSCORE_RETURNROGUE   = 10; // returned by rogue team
//float FLAGSCORE_CAPTURE       =  5;
//float FLAGSCORE_CAPTURE_TEAM  = 20;

#define FLAG_CARRY_POS '-15 0 7'

void() FlagThink;
void() FlagTouch;

void() place_flag =
{
	if(!self.t_width)
		self.t_width = 0.1; // frame animation rate
	if(!self.t_length)
		self.t_length = 119; // maximum frame

	setattachment(self, world, "");
	self.mdl = self.model;
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	self.think = FlagThink;
	self.touch = FlagTouch;
	self.nextthink = time + 0.1;
	self.cnt = FLAG_BASE;
	self.mangle = self.angles;
	self.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
	//self.effects = self.effects | EF_DIMLIGHT;
	if (!droptofloor())
	{
		dprint("Flag fell out of level at ", vtos(self.origin), "\n");
		remove(self);
		return;
	}
	self.oldorigin = self.origin;
};

void LogCTF(string mode, float flagteam, entity actor)
{
	string s;
	if(!cvar("sv_eventlog"))
		return;
	s = strcat(":ctf:", mode);
	s = strcat(s, ":", ftos(flagteam));
	if(actor != world)
		s = strcat(s, ":", ftos(actor.playerid));
	GameLogEcho(s, FALSE);
}

void(entity e) RegenFlag =
{
	setattachment(e, world, "");
	e.movetype = MOVETYPE_TOSS;
	e.solid = SOLID_TRIGGER;
	// TODO: play a sound here
	setorigin(e, e.oldorigin);
	e.angles = e.mangle;
	e.cnt = FLAG_BASE;
	e.owner = world;
	e.flags = FL_ITEM; // clear FL_ONGROUND and any other junk
};

void(entity e) ReturnFlag =
{
	if (e.owner)
	if (e.owner.flagcarried == e)
	{
		WaypointSprite_DetachCarrier(e.owner);
		e.owner.flagcarried = world;
	}
	e.owner = world;
	RegenFlag(e);
};

void(entity e) DropFlag =
{
	local entity p;

	if (!e.owner)
	{
		dprint("FLAG: drop - no owner?!?!\n");
		return;
	}
	p = e.owner;
	if (p.flagcarried != e)
	{
		dprint("FLAG: drop - owner is not carrying this flag??\n");
		return;
	}
	bprint(p.netname, "^7 lost the ", e.netname, "\n");
	WaypointSprite_DetachCarrier(p);
	LogCTF("dropped", p.team, p.flagcarried);

	setattachment(e, world, "");

	if (p.flagcarried == e)
		p.flagcarried = world;
	e.owner = world;

	e.flags = FL_ITEM; // clear FL_ONGROUND and any other junk
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_TOSS;
	// setsize(e, '-16 -16 0', '16 16 74');
	setorigin(e, p.origin - '0 0 24' + '0 0 37');
	e.cnt = FLAG_DROPPED;
	e.velocity = '0 0 300';
	e.pain_finished = time + cvar("g_ctf_flag_returntime");//30;

	trace_startsolid = FALSE;
	tracebox(e.origin, e.mins, e.maxs, e.origin, TRUE, e);
	if(trace_startsolid)
		dprint("FLAG FALLTHROUGH will happen SOON\n");
};

void AnimateFlag()
{
	if(self.delay > time)
		return;
	self.delay = time + self.t_width;
	if(self.nextthink > self.delay)
		self.nextthink = self.delay;

	self.frame = self.frame + 1;
	if(self.frame > self.t_length)
		self.frame = 0;
}

void() FlagThink =
{
	local entity e;

	self.nextthink = time + 0.1;

	AnimateFlag();

	if (self.cnt == FLAG_BASE)
		return;

	if (self.cnt == FLAG_DROPPED)
	{
		// flag fallthrough? FIXME remove this if bug is really fixed now
		if(self.origin_z < -131072)
		{
			dprint("FLAG FALLTHROUGH just happened\n");
			self.pain_finished = 0;
		}
		setattachment(self, world, "");
		if (time > self.pain_finished)
		{
			bprint("The ", self.netname, " has returned to base\n");
			sound (e, CHAN_AUTO, self.noise3, 1, ATTN_NONE);
			LogCTF("returned", self.team, world);
			ReturnFlag(self);
		}
		return;
	}

	e = self.owner;
	if (e.classname != "player" || (e.deadflag) || (e.flagcarried != self))
	{
		dprint("CANNOT HAPPEN - player dead and STILL had a flag!\n");
		DropFlag(self);
		return;
	}
};

float   flagcaptimerecord;
.float  flagpickuptime;

void() FlagTouch =
{
	if(gameover) return;

	local float t;
	local entity head;
	local entity player;
	local string s, s0;
	if (other.classname != "player")
		return;
	if (other.health < 1) // ignore dead players
		return;

	if (self.cnt == FLAG_CARRY)
		return;

	if (self.cnt == FLAG_BASE)
	if (other.team == self.team)
	if (other.flagcarried) // he's got a flag
	if (other.flagcarried.team != self.team) // capture
	{
		if (other.flagcarried == world)
		{
			return;
		}
		t = time - other.flagcarried.flagpickuptime;
		s = ftos_decimals(t, 2);
		s0 = ftos_decimals(flagcaptimerecord, 2);
		if (flagcaptimerecord == 0)
		{
			bprint(other.netname, "^7 captured the ", other.flagcarried.netname, " in ", s, " seconds\n");
			flagcaptimerecord = t;
		}
		else if (t < flagcaptimerecord)
		{
			bprint(other.netname, "^7 captured the ", other.flagcarried.netname, " in ", s, ", breaking the previous record of ", s0, " seconds\n");
			flagcaptimerecord = t;
		}
		else
		{
			bprint(other.netname, "^7 captured the ", other.flagcarried.netname, " in ", s, ", failing to break the previous record of ", s0, " seconds\n");
		}

		LogCTF("capture", other.flagcarried.team, other);
		// give credit to the individual player
		UpdateFrags(other, cvar("g_ctf_flagscore_capture"));

		// give credit to all players of the team (rewards large teams)
		// NOTE: this defaults to 0
		FOR_EACH_PLAYER(head)
			if (head.team == self.team)
				UpdateFrags(head, cvar("g_ctf_flagscore_capture_team"));

		sound (self, CHAN_AUTO, self.noise2, 1, ATTN_NONE);
		WaypointSprite_DetachCarrier(other);
		RegenFlag (other.flagcarried);
		other.flagcarried = world;
		other.next_take_time = time + 1;
	}
	if (self.cnt == FLAG_BASE)
	if (other.team == COLOR_TEAM1 || other.team == COLOR_TEAM2) // only red and blue team can steal flags
	if (other.team != self.team)
	if (!other.flagcarried)
	{
		if (other.next_take_time > time)
			return;
		// pick up
		self.flagpickuptime = time; // used for timing runs
		self.solid = SOLID_NOT;
		setorigin(self, self.origin); // relink
		self.owner = other;
		other.flagcarried = self;
		self.cnt = FLAG_CARRY;
		self.angles = '0 0 0';
		bprint(other.netname, "^7 got the ", self.netname, "\n");
		UpdateFrags(other, cvar("g_ctf_flagscore_pickup"));
		LogCTF("steal", self.team, other);
		sound (self, CHAN_AUTO, self.noise, 1, ATTN_NONE);

		FOR_EACH_PLAYER(player)
			if(player.team == self.team)
				centerprint(player, "The enemy got your flag! Retrieve it!");

		self.movetype = MOVETYPE_NONE;
		setorigin(self, FLAG_CARRY_POS);
		setattachment(self, other, "");
		WaypointSprite_AttachCarrier("flagcarrier", other);

		return;
	}

	if (self.cnt == FLAG_DROPPED)
	{
		self.flags = FL_ITEM; // clear FL_ONGROUND and any other junk
		if (other.team == self.team || (other.team != COLOR_TEAM1 && other.team != COLOR_TEAM2))
		{
			// return flag
			bprint(other.netname, "^7 returned the ", self.netname, "\n");
			if (other.team == COLOR_TEAM1 || other.team == COLOR_TEAM2)
				UpdateFrags(other, cvar("g_ctf_flagscore_return"));
			else
				UpdateFrags(other, cvar("g_ctf_flagscore_return_rogue"));
			LogCTF("return", self.team, other);
			sound (self, CHAN_AUTO, self.noise1, 1, ATTN_NONE);
			ReturnFlag(self);
		}
		else if (!other.flagcarried)
		{
			// pick up
			self.solid = SOLID_NOT;
			setorigin(self, self.origin); // relink
			self.owner = other;
			other.flagcarried = self;
			self.cnt = FLAG_CARRY;
			bprint(other.netname, "^7 picked up the ", self.netname, "\n");
			UpdateFrags(other, cvar("g_ctf_flagscore_pickup"));
			LogCTF("pickup", self.team, other);
			sound (self, CHAN_AUTO, self.noise, 1, ATTN_NONE);

			FOR_EACH_PLAYER(player)
				if(player.team == self.team)
					centerprint(player, "The enemy got your flag! Retrieve it!");

			self.movetype = MOVETYPE_NONE;	// flag must have MOVETYPE_NONE here, otherwise it will drop through the floor...
			setorigin(self, FLAG_CARRY_POS);
			setattachment(self, other, "");
			WaypointSprite_AttachCarrier("flagcarrier", other);
		}
	}
};

/*QUAKED info_player_team1 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player
in team one (Red).

Keys:
"angle"
 viewing angle when spawning
*/
void() info_player_team1 =
{
	self.team = COLOR_TEAM1; // red
	info_player_deathmatch();
};
//self.team = 4;self.classname = "info_player_start";info_player_start();};

/*QUAKED info_player_team2 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team two (Blue).

Keys:
"angle"
 viewing angle when spawning
*/
void() info_player_team2 =
{
	self.team = COLOR_TEAM2; // blue
	info_player_deathmatch();
};
//self.team = 13;self.classname = "info_player_start";info_player_start();};

/*QUAKED info_player_team3 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team three (Magenta).

Keys:
"angle"
 viewing angle when spawning
*/
void() info_player_team3 =
{
	self.team = COLOR_TEAM3; // purple
	info_player_deathmatch();
};


/*QUAKED info_player_team4 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team four (Yellow).

Keys:
"angle"
 viewing angle when spawning
*/
void() info_player_team4 =
{
	self.team = COLOR_TEAM4; // yellow
	info_player_deathmatch();
};




/*QUAKED item_flag_team1 (0 0.5 0.8) (-48 -48 -37) (48 48 37)
CTF flag for team one (Red).
Multiple are allowed.

Keys:
"angle"
 Angle the flag will point
(minus 90 degrees)
"model"
 model to use, note this needs red and blue as skins 0 and 1
 (default models/ctf/flag.md3)
"noise"
 sound played when flag is picked up
 (default ctf/take.wav)
"noise1"
 sound played when flag is returned by a teammate
 (default ctf/return.wav)
"noise2"
 sound played when flag is captured
 (default ctf/capture.wav)
"noise3"
 sound played when flag is lost in the field and respawns itself
 (default ctf/respawn.wav)
*/

void() item_flag_team1 =
{
	if (!cvar("g_ctf"))
		return;
	//if(!cvar("teamplay"))
	//	cvar_set("teamplay", "3");

	self.classname = "item_flag_team1";
	self.team = COLOR_TEAM1; // color 4 team (red)
	self.items = IT_KEY2; // gold key (redish enough)
	self.netname = "^1RED^7 flag";
	self.target = "###item###";
	self.skin = 0;
	if (!self.model)
		self.model = "models/ctf/flag_red.md3";
	if (!self.noise)
		self.noise = "ctf/take.wav";
	if (!self.noise1)
		self.noise1 = "ctf/return.wav";
	if (!self.noise2)
		self.noise2 = "ctf/capture.wav";
	if (!self.noise3)
		self.noise3 = "ctf/respawn.wav";
	precache_model (self.model);
	setmodel (self, self.model); // precision set below
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	precache_sound (self.noise3);
	setsize(self, '-16 -16 -37', '16 16 37');
	setorigin(self, self.origin + '0 0 37');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;

	if(!self.scale)
		self.scale = 0.6;
	//if(!self.glow_size)
	//	self.glow_size = 50;

	self.effects = self.effects | EF_FULLBRIGHT | EF_LOWPRECISION;
	droptofloor();

	WaypointSprite_SpawnFixed("redbase", self.origin + '0 0 37');
};

/*QUAKED item_flag_team2 (0 0.5 0.8) (-48 -48 -24) (48 48 64)
CTF flag for team two (Blue).
Multiple are allowed.

Keys:
"angle"
 Angle the flag will point
(minus 90 degrees)

*/

void() item_flag_team2 =
{
	if (!cvar("g_ctf"))
		return;
	//if(!cvar("teamplay"))
	//	cvar_set("teamplay", "3");

	self.classname = "item_flag_team2";
	self.team = COLOR_TEAM2; // color 13 team (blue)
	self.items = IT_KEY1; // silver key (bluish enough)
	self.netname = "^4BLUE^7 flag";
	self.target = "###item###";
	self.skin = 0;
	if (!self.model)
		self.model = "models/ctf/flag_blue.md3";
	if (!self.noise)
		self.noise = "ctf/take.wav";
	if (!self.noise1)
		self.noise1 = "ctf/return.wav";
	if (!self.noise2)
		self.noise2 = "ctf/capture.wav";
	if (!self.noise3)
		self.noise3 = "ctf/respawn.wav";
	precache_model (self.model);
	setmodel (self, self.model); // precision set below
	precache_sound (self.noise);
	precache_sound (self.noise1);
	precache_sound (self.noise2);
	precache_sound (self.noise3);
	setsize(self, '-16 -16 -37', '16 16 37');
	setorigin(self, self.origin + '0 0 37');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;

	if(!self.scale)
		self.scale = 0.6;
	//if(!self.glow_size)
	//	self.glow_size = 50;

	self.effects = self.effects | EF_FULLBRIGHT | EF_LOWPRECISION;
	droptofloor();

	WaypointSprite_SpawnFixed("bluebase", self.origin + '0 0 37');
};


// spawnfunctions for q3 flags
void team_CTF_redflag()
{
	item_flag_team1();
}

void team_CTF_blueflag()
{
	item_flag_team2();
}


/*QUAKED ctf_team (0 .5 .8) (-16 -16 -24) (16 16 32)
Team declaration for CTF gameplay, this allows you to decide what team
names and control point models are used in your map.

Note: If you use ctf_team entities you must define at least 2!  However, unlike
domination, you don't need to make a blank one too.

Keys:
"netname"
 Name of the team (for example Red, Blue, Green, Yellow, Life, Death, Offense, Defense, etc)
"cnt"
 Scoreboard color of the team (for example 4 is red and 13 is blue)

*/

void() ctf_team =
{
	self.classname = "ctf_team";
	self.team = self.cnt + 1;
};

// code from here on is just to support maps that don't have control point and team entities
void ctf_spawnteam (string teamname, float teamcolor)
{
	local entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "ctf_team";
	self.netname = teamname;
	self.cnt = teamcolor;

	ctf_team();

	self = oldself;
};

// spawn some default teams if the map is not set up for ctf
void() ctf_spawnteams =
{
	float numteams;

	numteams = 2;//cvar("g_ctf_default_teams");

	ctf_spawnteam("Red", COLOR_TEAM1 - 1);
	ctf_spawnteam("Blue", COLOR_TEAM2 - 1);
};

void() ctf_delayedinit =
{
	self.think = SUB_Remove;
	self.nextthink = time;
	// if no teams are found, spawn defaults
	if (find(world, classname, "ctf_team") == world)
		ctf_spawnteams();
};

void() ctf_init =
{
	local entity e;
	e = spawn();
	e.think = ctf_delayedinit;
	e.nextthink = time + 0.1;
};

void(entity flag) ctf_setstatus2 =
{
	if (flag) {
		local float shift;
		if (flag.team == COLOR_TEAM1) shift = IT_RED_FLAG_TAKEN;
		else if (flag.team == COLOR_TEAM2) shift = IT_BLUE_FLAG_TAKEN;
		else shift = 0;

		local float status;
		if (flag.cnt ==	FLAG_CARRY)
			if (flag.owner == self) status = 3;
			else status = 1;
		else if (flag.cnt == FLAG_DROPPED) status = 2;
		else status = 0;

		self.items = self.items | (shift * status);
	}
};

void() ctf_setstatus =
{
	self.items = self.items - (self.items & IT_RED_FLAG_TAKEN);
	self.items = self.items - (self.items & IT_RED_FLAG_LOST);
	self.items = self.items - (self.items & IT_BLUE_FLAG_TAKEN);
	self.items = self.items - (self.items & IT_BLUE_FLAG_LOST);

	if (cvar("g_ctf")) {
		local entity flag;
		flag = find(world, classname, "item_flag_team1");
		ctf_setstatus2(flag);
		flag = find(world, classname, "item_flag_team2");
		ctf_setstatus2(flag);
	}
};
