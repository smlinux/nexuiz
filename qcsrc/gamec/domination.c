
/*
Domination as a plugin for netquake mods
by LordHavoc (lordhavoc@ghdigital.com)

How to add domination points to a mod:
1. Add this line to progs.src above world.qc:
domination.qc
2. Comment out all lines in ClientObituary in client.qc that begin with targ.frags  or attacker.frags.
3. Add this above worldspawn in world.qc:
void() dom_init;
4. Add this line to the end of worldspawn in world.qc:
dom_init();

Note: The only teams who can use dom control points are identified by dom_team entities (if none exist these default to red and blue and use only quake models/sounds).
*/

void() dom_spawnteams;

void() dompointthink =
{
	local entity head;
	self.nextthink = time + 3;
	if (!self.goalentity.netname)
		return;
	head = find(head, classname, "player");
	while (head)
	{
		if (head.team == self.goalentity.team)
			head.frags = head.frags + 1;
		head = find(head, classname, "player");
	}
};

void() dompointtouch =
{
	local entity head;
	if (other.classname != "player")
		return;
	if (other.health < 1)
		return;
	// only valid teams can claim it
	head = find(world, classname, "dom_team");
	while (head && head.team != other.team)
		head = find(head, classname, "dom_team");
	if (!head || head.netname == "" || head == self.goalentity)
		return;

	self.goalentity = head;
	self.model = head.mdl;
	self.modelindex = head.dmg;
	self.skin = head.skin;

	bprint(head.message);
	bprint("\n");

	if (head.noise != "")
		sound(self, CHAN_BODY, head.noise, 1, ATTN_NORM);
	if (head.noise1 != "")
		sound(self, CHAN_VOICE, head.noise1, 1, ATTN_NONE);
};

/*QUAKED dom_team (0 .5 .8) (-16 -16 -24) (16 16 32)
Team declaration for Domination gameplay, this allows you to decide what team
names and control point models are used in your map.

Note: If you use dom_team entities you must define at least 3 and only two
can have netname set!  The nameless team owns all control points at start.

Keys:
"netname"
 Name of the team (for example Red, Blue, Green, Yellow, Life, Death, etc)
"cnt"
 Scoreboard color of the team (for example 4 is red and 13 is blue)
"model"
 Model to use for control points owned by this team (for example
 "progs/b_g_key.mdl" is a gold keycard, and "progs/b_s_key.mdl" is a silver
 keycard)
"skin"
 Skin of the model to use (for team skins on a single model)
"noise"
 Sound to play when this team captures a point.
 (this is a localized sound, like a small alarm or other effect)
"noise1"
 Narrator speech to play when this team captures a point.
 (this is a global sound, like "Red team has captured a control point")
"message"
 Message to show when a team captures a point
 (for example "Red team has captured a control point", or
  "The forces of light have captured a mana well")
*/

void() dom_team =
{
	precache_model(self.model);
	if (self.noise != "")
		precache_sound(self.noise);
	if (self.noise1 != "")
		precache_sound(self.noise1);
	self.classname = "dom_team";
	setmodel(self, self.model);
	self.mdl = self.model;
	self.dmg = self.modelindex;
	self.model = "";
	self.modelindex = 0;
	// this would have to be changed if used in quakeworld
	self.team = self.cnt + 1;
};

void() dom_controlpoint_setup =
{
	local entity head;
	// find the dom_team representing unclaimed points
	head = find(world, classname, "dom_team");
	while(head && head.netname != "")
		head = find(head, classname, "dom_team");
	if (!head)
		objerror("no dom_team with netname \"\" found\n");

	// copy important properties from dom_team entity
	self.goalentity = head;
	setmodel(self, head.mdl);
	self.skin = head.skin;

	self.think = dompointthink;
	self.nextthink = time;
	self.touch = dompointtouch;
	self.solid = SOLID_TRIGGER;
	setsize(self, '-16 -16 -24', '16 16 32');
	setorigin(self, self.origin);
	droptofloor(0, 0);
};

/*QUAKED dom_controlpoint (0 .5 .8) (-16 -16 -24) (16 16 32)
Control point for Domination gameplay.
*/
void() dom_controlpoint =
{
	self.think = dom_controlpoint_setup;
	self.nextthink = time + 0.1;
};

// code from here on is just to support maps that don't have control point and team entities
void(string teamname, float teamcolor, string pointmodel, float pointskin, string capsound, string capnarration, string capmessage) dom_spawnteam =
{
	local entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "dom_team";
	self.netname = teamname;
	self.cnt = teamcolor;
	self.model = pointmodel;
	self.skin = pointskin;
	self.noise = capsound;
	self.noise1 = capnarration;
	self.message = capmessage;

	// this code is identical to dom_team
	setmodel(self, self.model);
	self.mdl = self.model;
	self.dmg = self.modelindex;
	self.model = "";
	self.modelindex = 0;
	// this would have to be changed if used in quakeworld
	self.team = self.cnt + 1;

	//eprint(self);
	self = oldself;
};

void(vector org) dom_spawnpoint =
{
	local entity oldself;
	oldself = self;
	self = spawn();
	self.classname = "dom_controlpoint";
	self.think = dom_controlpoint;
	self.nextthink = time;
	self.origin = org;
	dom_controlpoint();
	self = oldself;
};

void() dom_spawnteams =
{
	// LordHavoc: edit this if you want to change defaults
	dom_spawnteam("Red", 4, "progs/dom_red.md3", 0, "misc/domclaim.wav", "", "Red team has captured a control point");
	dom_spawnteam("Blue", 13, "progs/dom_blue.md3", 0, "misc/domclaim.wav", "", "Blue team has captured a control point");
	dom_spawnteam("Green", 3, "progs/dom_green.md3", 0, "misc/domclaim.wav", "", "Green team has captured a control point");
	dom_spawnteam("Yellow", 12, "progs/dom_yellow.md3", 0, "misc/domclaim.wav", "", "Yellow team has captured a control point");
	dom_spawnteam("", 0, "progs/dom_unclaimed.md3", 0, "", "", "");
};

void() dom_delayedinit =
{
	local entity head;
	// if no teams are found, spawn defaults
	if (find(world, classname, "dom_team") == world)
		dom_spawnteams();
	// if no control points are found, spawn defaults
	if (find(world, classname, "dom_controlpoint") == world)
	{
		// here follow default domination points for each map
		/*
		if (world.model == "maps/e1m1.bsp")
		{
			dom_spawnpoint('0 0 0');
		}
		else
		*/
		{
			// if no supported map was found, make every deathmatch spawn a point
			head = find(world, classname, "info_player_deathmatch");
			while (head)
			{
				dom_spawnpoint(head.origin);
				head = find(head, classname, "info_player_deathmatch");
			}
		}
	}
};

void() dom_init =
{
	local entity e;
	// we have to precache default models/sounds even if they might not be
	// used because worldspawn is executed before any other entities are read,
	// so we don't even know yet if this map is set up for domination...
	precache_model("progs/b_g_key.mdl");
	precache_model("progs/b_s_key.mdl");
	precache_model("progs/end1.mdl");
	precache_sound("doors/runetry.wav");
	e = spawn();
	e.think = dom_delayedinit;
	e.nextthink = time + 0.1;
};

