
.entity flagcarried;

float FLAGSCORE_PICKUP        =  1;
float FLAGSCORE_RETURN        =  5; // returned by owner team
float FLAGSCORE_RETURNROGUE   = 10; // returned by rogue team
float FLAGSCORE_CAPTURE       =  5;
float FLAGSCORE_CAPTURE_TEAM  = 20;

float FLAG_BASE = 1;
float FLAG_CARRY = 2;
float FLAG_DROPPED = 3;

void() FlagThink;
void() FlagTouch;

void() place_flag =
{
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
	self.effects = self.effects | EF_DIMLIGHT;
	if (!droptofloor(0, 0))
	{
		dprint("Flag fell out of level at ", vtos(self.origin), "\n");
		remove(self);
		return;
	}
	self.oldorigin = self.origin;
};

void(entity e) RegenFlag =
{
	e.movetype = MOVETYPE_TOSS;
	e.solid = SOLID_TRIGGER;
	// TODO: play a sound here
	sound (e, CHAN_AUTO, "misc/flagrgen.wav", 1, ATTN_NONE);
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
		e.owner.flagcarried = world;
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
	bprint(p.netname);
	if (e.team == 5)
		bprint(" lost the RED flag\n");
	else
		bprint(" lost the BLUE flag\n");
	if (p.flagcarried == e)
		p.flagcarried = world;
	e.owner = world;

	e.flags = FL_ITEM; // clear FL_ONGROUND and any other junk
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_TOSS;
	// setsize(e, '-16 -16 0', '16 16 74');
	setorigin(e, p.origin - '0 0 24');
	e.cnt = FLAG_DROPPED;
	e.velocity = '0 0 300';
	e.pain_finished = time + 30;
};

void() FlagThink =
{
	local entity e;
	local vector v;
	local float f;

	self.nextthink = time + 0.1;

	if (self.cnt == FLAG_BASE)
		return;

	if (self.cnt == FLAG_DROPPED)
	{
		if (time > self.pain_finished)
		{
			if (self.team == 5)
				bprint("The RED flag has returned to base\n");
			else
				bprint("The BLUE flag has returned to base\n");
			ReturnFlag(self);
		}
		return;
	}

	e = self.owner;
	if (e.classname != "player" || (e.deadflag) || (e.flagcarried != self))
	{
		DropFlag(self);
		return;
	}

	// borrowed from threewave CTF, because it would be way too much work

	makevectors (e.angles);
	v = v_forward;
	v_z = 0 - v_z; // reverse z

	f = 14;
	/*
	if (e.frame >= 29 && e.frame <= 40)
	{
		if (e.frame >= 29 && e.frame <= 34)
		{
			//axpain
			if      (e.frame == 29) f = f + 2;
			else if (e.frame == 30) f = f + 8;
			else if (e.frame == 31) f = f + 12;
			else if (e.frame == 32) f = f + 11;
			else if (e.frame == 33) f = f + 10;
			else if (e.frame == 34) f = f + 4;
		}
		else if (e.frame >= 35 && e.frame <= 40)
		{
			// pain
			if      (e.frame == 35) f = f + 2;
			else if (e.frame == 36) f = f + 10;
			else if (e.frame == 37) f = f + 10;
			else if (e.frame == 38) f = f + 8;
			else if (e.frame == 39) f = f + 4;
			else if (e.frame == 40) f = f + 2;
		}
	}
	else if (e.frame >= 103 && e.frame <= 118)
	{
		if      (e.frame >= 103 && e.frame <= 104) f = f + 6;  //nailattack
		else if (e.frame >= 105 && e.frame <= 106) f = f + 6;  //light
		else if (e.frame >= 107 && e.frame <= 112) f = f + 7;  //rocketattack
		else if (e.frame >= 112 && e.frame <= 118) f = f + 7;  //shotattack
	}
	*/
	self.angles = e.angles + '0 0 -45';
	setorigin (self, e.origin + '0 0 -16' - f*v + v_right * 22);
	self.nextthink = time + 0.01;
};

float   flagcaptimerecord;
.float  flagpickuptime;

void() FlagTouch =
{
	local float t;
	local entity head;
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
		t = time - other.flagpickuptime;
		if (flagcaptimerecord == 0)
		{
			if (other.flagcarried.team == 5)
				bprint(other.netname, " captured the RED flag in ", ftos(t), " seconds\n");
			else
				bprint(other.netname, " captured the BLUE flag in ", ftos(t), " seconds\n");
			flagcaptimerecord = t;
		}
		else if (t < flagcaptimerecord)
		{
			if (other.flagcarried.team == 5)
				bprint(other.netname, " captured the RED flag in ", ftos(t), ", breaking the previous record of", ftos(flagcaptimerecord), " seconds\n");
			else
				bprint(other.netname, " captured the BLUE flag in ", ftos(t), ", breaking the previous record of", ftos(flagcaptimerecord), " seconds\n");
			flagcaptimerecord = t;
		}
		else
		{
			if (other.flagcarried.team == 5)
				bprint(other.netname, " captured the RED flag in ", ftos(t), ", failing to break the previous record of", ftos(flagcaptimerecord), " seconds\n");
			else
				bprint(other.netname, " captured the BLUE flag in ", ftos(t), ", failing to break the previous record of", ftos(flagcaptimerecord), " seconds\n");
		}
		other.frags = other.frags + FLAGSCORE_CAPTURE;
		head = find(head, classname, "player");
		while (head)
		{
			if (head.team == self.goalentity.team)
				head.frags = head.frags + FLAGSCORE_CAPTURE_TEAM;
			head = find(head, classname, "player");
		}
		sound (self, CHAN_AUTO, "misc/flagcap.wav", 1, ATTN_NONE);
		ReturnFlag(other.flagcarried);
	}
	if (self.cnt == FLAG_BASE)
	if (other.team == 5 || other.team == 14) // only red and blue team can steal flags
	if (other.team != self.team)
	if (!other.flagcarried)
	{
		// pick up
		other.flagpickuptime = time; // used for timing runs
		self.solid = SOLID_NOT;
		setorigin(self, self.origin); // relink
		self.owner = other;
		other.flagcarried = self;
		self.cnt = FLAG_CARRY;
		if (other.flagcarried.team == 5)
			bprint(other.netname, " got the RED flag\n");
		else
			bprint(other.netname, " got the BLUE flag\n");
		other.frags = other.frags + FLAGSCORE_PICKUP;
		sound (self, CHAN_AUTO, "misc/flagtk.wav", 1, ATTN_NONE);
		return;
	}

	if (self.cnt == FLAG_DROPPED)
	{
		self.flags = FL_ITEM; // clear FL_ONGROUND and any other junk
		if (other.team == self.team || (other.team != 5 && other.team != 14))
		{
			// return flag
			if (self.team == 5)
				bprint(other.netname, " returned the RED flag\n");
			else
				bprint(other.netname, " returned the BLUE flag\n");
			if (other.team == 5 || other.team == 14)
				other.frags = other.frags + FLAGSCORE_RETURN;
			else
				other.frags = other.frags + FLAGSCORE_RETURNROGUE;
			sound (self, CHAN_AUTO, "misc/flagret.wav", 1, ATTN_NONE);
			ReturnFlag(self);
		}
		else if (!other.flagcarried)
		{
			// pick up
			other.flagpickuptime = time; // used for timing runs
			self.solid = SOLID_NOT;
			setorigin(self, self.origin); // relink
			self.owner = other;
			other.flagcarried = self;
			self.cnt = FLAG_CARRY;
			if (self.team == 5)
				bprint(other.netname, " picked up the RED flag\n");
			else
				bprint(other.netname, " picked up the BLUE flag\n");
			other.frags = other.frags + FLAGSCORE_PICKUP;
			sound (self, CHAN_AUTO, "misc/flagtk.wav", 1, ATTN_NONE);
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
void() info_player_team1 = {};

/*QUAKED info_player_team2 (1 0 0) (-16 -16 -24) (16 16 24)
CTF Starting point for a player in
team two (Blue).

Keys:
"angle"
 viewing angle when spawning
*/
void() info_player_team2 = {};

/*QUAKED item_flag_team1 (0 0.5 0.8) (-48 -48 -24) (48 48 64)
CTF flag for team one (Red).
Multiple are allowed.

Keys:
"angle"
 Angle the flag will point
(minus 90 degrees)

*/

void() item_flag_team1 =
{
	if (!cvar("g_ctf"))
		return;
	self.team = 5; // color 4 team (red)
	self.items = IT_KEY2; // gold key (redish enough)
	precache_model ("progs/flag.mdl");
	setmodel (self, "progs/flag.mdl");
	self.skin = 0;
	precache_sound ("misc/flagcap.wav");
	precache_sound ("misc/flagtk.wav");
	precache_sound ("doors/runetry.wav");
	self.noise = "misc/flagtk.wav";
	self.noise1 = "doors/runetry.wav";
	setsize(self, '-16 -16 0', '16 16 74');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;
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
	self.team = 14; // color 13 team (blue)
	self.items = IT_KEY1; // silver key (bluish enough)
	precache_model ("progs/flag.mdl");
	setmodel (self, "progs/flag.mdl");
	self.skin = 1;
	precache_sound ("misc/flagcap.wav");
	precache_sound ("misc/flagtk.wav");
	precache_sound ("doors/runetry.wav");
	self.noise = "misc/flagtk.wav";
	self.noise1 = "doors/runetry.wav";
	setsize(self, '-16 -16 0', '16 16 74');
	self.nextthink = time + 0.2; // start after doors etc
	self.think = place_flag;
};

