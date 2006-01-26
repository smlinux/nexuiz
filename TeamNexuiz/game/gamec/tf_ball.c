// MegaTF Ball and Goal
// By: Ambush (and DyerMaker?)
// Implemented into Team:Nexuiz by avirox

float () CheckExistence;
.float last_used;
.entity lastplayer;

void() BallTouch = 
{
	if (other.classname == "player" && self.last_used <= time)
	{
		sound(self, 3, "zombie/z_fall.wav", 0.8, TRUE);
		self.last_used = time + 0.3;
	}
	if (other.classname != "player")
	{
		sound(self, TRUE, "zombie/z_hit.wav", TRUE, TRUE);
	}
	if (other.classname == "player")
	{
		makevectors(other.v_angle);
		self.velocity = other.velocity + v_forward * 100 + v_up * 200;
		self.lastplayer = other;
	}
};

void() BallCheck = 
{
	self.movetype = 10;
	self.nextthink = time + 15;
	self.effects = FALSE;
};

void() ballstart = 
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}
};

void() BallStart = 
{
	local entity te;
	sound(self, 3, "sandball/whistle.wav", TRUE, FALSE);
	te = find(world, classname, "ballstart");
	while (te)
	{
		setorigin(self, te.origin);
		te = find(te, classname, "ballstart");
	}
	self.nextthink = time + 5;
	self.think = BallCheck;
	self.movetype = 10;
	self.velocity_z = 40;
};

void() ball = 
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	self.movetype = FALSE;
	setsize(self, '-16 -16 -14', '16 16 10');
	self.solid = TRUE;
	self.touch = BallTouch;
	self.classname = "ball";
	self.think = BallCheck;
	self.nextthink = time + 15;
	self.oldorigin = self.origin;
};

void() GoalTouch = 
{
	local entity te;
	if (other.classname != "ball")
	{
		return;
	}
	if (self.last_used > time)
	{
		return;
	}
	sound(self, 3, "sandball/goal.wav", TRUE, FALSE);
	self.last_used = time + 10;
	te = find(world, classname, "player");
	while (te)
	{
		if (self.team_no == 2)
		{
			CenterPrint2(te, "Score for Reds by\n", other.lastplayer.netname);
		}
		else
		{
			CenterPrint2(te, "Score for Blues by\n", other.lastplayer.netname);
		}
		if (te.team_no == self.team_no && self.team_no != FALSE)
		{
			te.real_frags = te.real_frags + self.frags;
			te.frags = te.frags + self.frags;
			te.health = te.max_health;
		}
		te = find(te, classname, "player");
	}
	other.nextthink = time + 10;
	other.think = BallStart;
	other.movetype = 9;
	other.velocity_z = 40;
	other.effects = self.team_no * 64;
};

void() sandball_goal = 
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}
	precache_model("progs/null.mdl");
	precache_sound("sandball/goal.wav");
	precache_sound("sandball/whistle.wav");
	precache_sound("zombie/z_fall.wav");
	setmodel(self, "progs/null.mdl");
	self.movetype = FALSE;
	self.skin = self.team_no;
	self.solid = TRUE;
	setsize(self, '-35 -35 -14', '35 35 50');
	self.effects = FALSE;
	self.touch = GoalTouch;
};
