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
		//self.angles = -1 * (vectoangles (self.velocity));
		v_forward_y = 0;
		v_forward_z = 0;
		self.avelocity = -1 * ((v_forward * 250) + crandom() * v_right);
		self.lastplayer = other;
	}
};

void() BallCheck = 
{
	self.movetype = 10;
	self.nextthink = time + 15;
	self.effects = FALSE;
//	self.angles = vectoangles (self.velocity);
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
	precache_model("models/ball/ball.md3");
	setmodel(self, "models/ball/ball.md3");
	self.movetype = FALSE;
	setsize(self, '-16 -16 -14', '16 16 10');
	self.solid = TRUE;
	self.touch = BallTouch;
	self.classname = "ball";
	self.think = BallCheck;
	self.nextthink = time + 15;
	self.oldorigin = self.origin;
//	self.angles = vectoangles (self.velocity);
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
			CenterPrint2(te, "        ^3Score^7 for ^1Reds^7 by ", other.lastplayer.netname);
		}
		else
		{
			CenterPrint2(te, "        ^3Score^7 for ^4Blues^7 by ", other.lastplayer.netname);
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

void() PuckTouch = 
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
		self.velocity = other.velocity + v_forward * 100/* + v_up * 200*/;
		//self.angles = -1 * (vectoangles (self.velocity));
		v_forward_y = 0;
		v_forward_z = 0;
		self.avelocity = -1 * ((v_forward * 250) + crandom() * v_right);
		self.lastplayer = other;
	}
};

void() PuckCheck = 
{
	self.movetype = 10;
	self.nextthink = time + 15;
	self.effects = FALSE;
};

void() puck = 
{
	if (CheckExistence() == FALSE)
	{
		dremove(self);
		return;
	}
	precache_model("models/puck/puck.md3");
	setmodel(self, "models/puck/puck.md3");
	self.movetype = MOVETYPE_WALK;
	setsize(self, '-16 -16 -14', '16 16 10');
	self.solid = TRUE;
	self.touch = PuckTouch;
	self.classname = "ball";
	self.think = PuckCheck;
	self.nextthink = time + 15;
	self.oldorigin = self.origin;
};


vector(vector ang) SUB_NormalizeAngles = 
{
	while (ang_x > 360)
	{
		ang_x = ang_x - 360;
	}
	while (ang_x < FALSE)
	{
		ang_x = ang_x + 360;
	}
	while (ang_y > 360)
	{
		ang_y = ang_y - 360;
	}
	while (ang_y < FALSE)
	{
		ang_y = ang_y + 360;
	}
	while (ang_z > 360)
	{
		ang_z = ang_z - 360;
	}
	while (ang_z < FALSE)
	{
		ang_z = ang_z + 360;
	}
	return ang;
};

/*=======================================
			Rotate function for QuakeC
			by Hipnotic Interactive
				===================================*/

.float rotate_type;
.float endtime;
.float duration;
.vector neworigin;
.vector rotate;
.string path;
.string event;
.string group;

float START_ON = 1;  // flag. abe thinks right.
float TOGGLE = 1;    // flag. abe thinks right.

float ROTATION = 1;
float ANGLES = 2;    // flag. from abe.
float STOP = 4;
float NO_ROTATE = 8;

float VISIBLE = 1;
float DAMAGE = 2;
float TOUCH = 2;		// this one too.
float SET_DAMAGE = 4;	// i made this one up.

float NONBLOCKING = 4;

float STAYOPEN = 4;

float OBJECT_MOVEWALL = 2;
float OBJECT_ROTATE = 3;
float STATE_SPEEDINGUP = 4;
float STATE_ACTIVE = 5;
float OBJECT_SETORIGIN = 6;
float STATE_WAIT = 7;
float STATE_SLOWINGDOWN = 8;
float STATE_INACTIVE = 9;
float STATE_OPENING = 10;
float STATE_CLOSING = 11;
float STATE_MOVE = 12;
float STATE_STOP = 13;
float STATE_NEXT = 14;
float STATE_FIND = 15;
float STATE_OPEN = 16;
float STATE_CLOSED = 17;

.vector dest;

void() rotate_train_find;
void() rotate_door_group_reversedirection;
void() rotate_train_next;

void() info_rotate = 
{
	self.nextthink = time + 2;
	self.think = SUB_Remove;
};

void() RotateTargets = 
{
	local entity ent;
	local vector vx;
	local vector vy;
	local vector vz;
	local vector org;
	makevectors(self.angles);
	ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.rotate_type == OBJECT_SETORIGIN)
		{
			org = ent.oldorigin;
			vx = v_forward * org_x;
			vy = v_right * org_y;
			vy = vy * -1;
			vz = v_up * org_z;
			ent.neworigin = vx + vy + vz;
			setorigin(ent, ent.neworigin + self.origin);
		}
		else
		{
			if (ent.rotate_type == OBJECT_ROTATE)
			{
				ent.angles = self.angles;
				org = ent.oldorigin;
				vx = v_forward * org_x;
				vy = v_right * org_y;
				vy = vy * -1;
				vz = v_up * org_z;
				ent.neworigin = vx + vy + vz;
				setorigin(ent, ent.neworigin + self.origin);
			}
			else
			{
				org = ent.oldorigin;
				vx = v_forward * org_x;
				vy = v_right * org_y;
				vy = vy * -1;
				vz = v_up * org_z;
				ent.neworigin = vx + vy + vz;
				ent.neworigin = self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin);
				ent.velocity = (ent.neworigin - ent.origin) * 25;
			}
		}
		ent = find(ent, targetname, self.target);
	}
};

void() RotateTargetsFinal = 
{
	local entity ent;
	ent = find(world, targetname, self.target);
	while (ent)
	{
		ent.velocity = '0 0 0';
		if (ent.rotate_type == OBJECT_ROTATE)
		{
			ent.angles = self.angles;
		}
		ent = find(ent, targetname, self.target);
	}
};

void() SetTargetOrigin = 
{
	local entity ent;
	ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.rotate_type == OBJECT_MOVEWALL)
		{
			setorigin(ent, self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin));
		}
		else
		{
			setorigin(ent, ent.neworigin + self.origin);
		}
		ent = find(ent, targetname, self.target);
	}
};

void() LinkRotateTargets = 
{
	local entity ent;
	local vector tempvec;
	self.oldorigin = self.origin;
	ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "rotate_object")
		{
			ent.rotate_type = OBJECT_ROTATE;
			ent.oldorigin = ent.origin - self.oldorigin;
			ent.neworigin = ent.origin - self.oldorigin;
			ent.owner = self;
		}
		else
		{
			if (ent.classname == "func_movewall")
			{
				ent.rotate_type = OBJECT_MOVEWALL;
				tempvec = (ent.absmin + ent.absmax) * 0.5;
				ent.oldorigin = tempvec - self.oldorigin;
				ent.neworigin = ent.oldorigin;
				ent.owner = self;
			}
			else
			{
				ent.rotate_type = OBJECT_SETORIGIN;
				ent.oldorigin = ent.origin - self.oldorigin;
				ent.neworigin = ent.origin - self.oldorigin;
			}
		}
		ent = find(ent, targetname, self.target);
	}
};

void(float amount) SetDamageOnTargets = 
{
	local entity ent;
	ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "func_movewall")
		{
			ent.dmg = amount;
		}
		ent = find(ent, targetname, self.target);
	}
};

void() rotate_entity_think = 
{
	local float t;
	t = time - self.ltime;
	self.ltime = time;
	if (self.state == STATE_SPEEDINGUP)
	{
		self.count = self.count + self.cnt * t;
		if (self.count > TRUE)
		{
			self.count = TRUE;
		}
		t = t * self.count;
	}
	else
	{
		if (self.state == STATE_SLOWINGDOWN)
		{
			self.count = self.count - self.cnt * t;
			if (self.count < FALSE)
			{
				RotateTargetsFinal();
				self.state = STATE_INACTIVE;
				self.think = SUB_Null;
				return;
			}
			t = t * self.count;
		}
	}
	self.angles = self.angles + self.rotate * t;
	self.angles = SUB_NormalizeAngles(self.angles);
	RotateTargets();
	self.nextthink = time + 0.020000;
};

void() rotate_entity_use = 
{
	self.frame = TRUE - self.frame;
	if (self.state == STATE_ACTIVE)
	{
		if (self.spawnflags & TOGGLE)
		{
			if (self.speed)
			{
				self.count = TRUE;
				self.state = STATE_SLOWINGDOWN;
			}
			else
			{
				self.state = STATE_INACTIVE;
				self.think = SUB_Null;
			}
		}
	}
	else
	{
		if (self.state == STATE_INACTIVE)
		{
			self.think = rotate_entity_think;
			self.nextthink = time + 0.020000;
			self.ltime = time;
			if (self.speed)
			{
				self.count = FALSE;
				self.state = STATE_SPEEDINGUP;
			}
			else
			{
				self.state = STATE_ACTIVE;
			}
		}
		else
		{
			if (self.state == STATE_SPEEDINGUP)
			{
				if (self.spawnflags & TOGGLE)
				{
					self.state = STATE_SLOWINGDOWN;
				}
			}
			else
			{
				self.state = STATE_SPEEDINGUP;
			}
		}
	}
};

void() rotate_entity_firstthink = 
{
	LinkRotateTargets();
	if (self.spawnflags & START_ON)
	{
		self.state = STATE_ACTIVE;
		self.think = rotate_entity_think;
		self.nextthink = time + 0.020000;
		self.ltime = time;
	}
	else
	{
		self.state = STATE_INACTIVE;
		self.think = SUB_Null;
	}
	self.use = rotate_entity_use;
};

/*QUAKED func_rotate_entity (0 .5 .8) (-8 -8 -8) (8 8 8) TOGGLE START_ON
Creates an entity that continually rotates.  Can be toggled on and
off if targeted.

TOGGLE = allows the rotation to be toggled on/off

START_ON = wether the entity is spinning when spawned.  If TOGGLE is 0, entity can be turned on, but not off.

If "deathtype" is set with a string, this is the message that will appear when a player is killed by the train.

"rotate" is the rate to rotate.
"target" is the center of rotation.
"speed"  is how long the entity takes to go from standing still to full speed and vice-versa.
*/

void() func_rotate_entity = 
{
	self.solid = FALSE;
	self.movetype = FALSE;
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	if (self.speed != FALSE)
	{
		self.cnt = TRUE / self.speed;
	}
	self.think = rotate_entity_firstthink;
	self.nextthink = time + 0.1;
	self.ltime = time;
};

/*QUAKED path_rotate (0.5 0.3 0) (-8 -8 -8) (8 8 8) ROTATION ANGLES STOP NO_ROTATE DAMAGE MOVETIME SET_DAMAGE
 Path for rotate_train.

 ROTATION tells train to rotate at rate specified by "rotate".  Use '0 0 0' to stop rotation.

 ANGLES tells train to rotate to the angles specified by "angles" while traveling to this path_rotate.  Use values < 0 or > 360 to guarantee that it turns in a certain direction.  Having this flag set automatically clears any rotation.

 STOP tells the train to stop and wait to be retriggered.

 NO_ROTATE tells the train to stop rotating when waiting to be triggered.

 DAMAGE tells the train to cause damage based on "dmg".

 MOVETIME tells the train to interpret "speed" as the length of time to take moving from one corner to another.

 SET_DAMAGE tells the train to set all targets damage to "dmg"

 "noise" contains the name of the sound to play when train stops.
 "noise1" contains the name of the sound to play when train moves.
 "event" is a target to trigger when train arrives at path_rotate.
*/

void() path_rotate = 
{
	if (self.noise)
	{
		precache_sound(self.noise);
	}
	if (self.noise1)
	{
		precache_sound(self.noise1);
	}
};

void() rotate_train_think = 
{
	local float t;
	local float timeelapsed;
	t = time - self.ltime;
	self.ltime = time;
	if (self.endtime && time >= self.endtime)
	{
		self.endtime = FALSE;
		if (self.state == STATE_MOVE)
		{
			setorigin(self, self.finaldest);
			self.velocity = '0 0 0';
		}
		if (self.think1)
		{
			self.think1();
		}
	}
	else
	{
		timeelapsed = (time - self.cnt) * self.duration;
		if (timeelapsed > TRUE)
		{
			timeelapsed = TRUE;
		}
		setorigin(self, self.dest1 + self.dest2 * timeelapsed);
	}
	self.angles = self.angles + self.rotate * t;
	self.angles = SUB_NormalizeAngles(self.angles);
	RotateTargets();
	self.nextthink = time + 0.020000;
};

void() rotate_train_use = 
{
	if (self.think1 != rotate_train_find)
	{
		if (self.velocity != '0 0 0')
		{
			return;
		}
		if (self.think1)
		{
			self.think1();
		}
	}
};

void() rotate_train_wait = 
{
	self.state = STATE_WAIT;
	if (self.goalentity.noise)
	{
		if (self.goalentity.noise == "ambience/chopper.wav")
		{
			sound(self, 2, self.goalentity.noise, TRUE, FALSE);
		}
		else
		{
			sound(self, 2, self.goalentity.noise, TRUE, TRUE);
		}
	}
	else
	{
		sound(self, 2, self.noise, TRUE, TRUE);
	}
	if (self.goalentity.spawnflags & ANGLES)
	{
		self.rotate = '0 0 0';
		self.angles = self.finalangle;
	}
	if (self.goalentity.spawnflags & NO_ROTATE)
	{
		self.rotate = '0 0 0';
	}
	self.endtime = self.ltime + self.goalentity.wait;
	self.think1 = rotate_train_next;
};

void() rotate_train_stop = 
{
	self.state = STATE_STOP;
	if (self.goalentity.noise)
	{
		if (self.goalentity.noise == "ambience/chopper.wav")
		{
			sound(self, 2, self.goalentity.noise, TRUE, FALSE);
		}
		else
		{
			sound(self, 2, self.goalentity.noise, TRUE, TRUE);
		}
	}
	else
	{
		sound(self, 2, self.noise, TRUE, TRUE);
	}
	if (self.goalentity.spawnflags & ANGLES)
	{
		self.rotate = '0 0 0';
		self.angles = self.finalangle;
	}
	if (self.goalentity.spawnflags & NO_ROTATE)
	{
		self.rotate = '0 0 0';
	}
	self.dmg = FALSE;
	self.think1 = rotate_train_next;
};

void() rotate_train_next = 
{
	local entity targ;
	local entity current;
	local vector vdestdelta;
	local float len;
	local float traveltime;
	local float div;
	local string temp;
	self.state = STATE_NEXT;
	current = self.goalentity;
	targ = find(world, targetname, self.path);
	if (targ.classname != "path_rotate")
	{
		objerror("Next target is not path_rotate");
	}
	if (self.goalentity.noise1)
	{
		self.noise1 = self.goalentity.noise1;
	}
	if (self.noise1 == "ambience/chopper.wav")
	{
		sound(self, 2, self.noise1, TRUE, FALSE);
	}
	else
	{
		sound(self, 2, self.noise1, TRUE, TRUE);
	}
	self.goalentity = targ;
	self.path = targ.target;
	if (!(self.path))
	{
		objerror("rotate_train_next: no next target");
	}
	if (targ.spawnflags & STOP)
	{
		self.think1 = rotate_train_stop;
	}
	else
	{
		if (targ.wait)
		{
			self.think1 = rotate_train_wait;
		}
		else
		{
			self.think1 = rotate_train_next;
		}
	}
	if (current.event)
	{
		temp = self.target;
		self.target = current.event;
		self.message = current.message;
		SUB_UseTargets();
		self.target = temp;
		self.message = string_null;
	}
	if (current.spawnflags & ANGLES)
	{
		self.rotate = '0 0 0';
		self.angles = self.finalangle;
	}
	if (current.spawnflags & ROTATION)
	{
		self.rotate = current.rotate;
	}
	if (current.spawnflags & DAMAGE)
	{
		self.dmg = current.dmg;
	}
	if (current.spawnflags & SET_DAMAGE)
	{
		SetDamageOnTargets(current.dmg);
	}
	if (current.speed == -1)
	{
		setorigin(self, targ.origin);
		self.endtime = self.ltime + 0.010000;
		SetTargetOrigin();
		if (targ.spawnflags & ANGLES)
		{
			self.angles = targ.angles;
		}
		self.duration = TRUE;
		self.cnt = time;
		self.dest2 = '0 0 0';
		self.dest1 = self.origin;
		self.finaldest = self.origin;
	}
	else
	{
		self.state = STATE_MOVE;
		self.finaldest = targ.origin;
		if (self.finaldest == self.origin)
		{
			self.velocity = '0 0 0';
			self.endtime = self.ltime + 0.1;
			self.duration = TRUE;
			self.cnt = time;
			self.dest2 = '0 0 0';
			self.dest1 = self.origin;
			self.finaldest = self.origin;
			return;
		}
		vdestdelta = self.finaldest - self.origin;
		len = vlen(vdestdelta);
//		if (current.spawnflags & MOVETIME)
//		{
//			traveltime = current.speed;
//		}
//		else
//		{
			if (current.speed > FALSE)
			{
				self.speed = current.speed;
			}
			if (!(self.speed))
			{
				objerror("No speed is defined!");
			}
			traveltime = len / self.speed;
//		}
		if (traveltime < 0.1)
		{
			self.velocity = '0 0 0';
			self.endtime = self.ltime + 0.1;
			if (targ.spawnflags & ANGLES)
			{
				self.angles = targ.angles;
			}
			return;
		}
		div = TRUE / traveltime;
		if (targ.spawnflags & ANGLES)
		{
			self.finalangle = SUB_NormalizeAngles(targ.angles);
			self.rotate = (targ.angles - self.angles) * div;
		}
		self.endtime = self.ltime + traveltime;
		self.velocity = vdestdelta * div;
		self.duration = div;
		self.cnt = time;
		self.dest2 = vdestdelta;
		self.dest1 = self.origin;
	}
};

void() rotate_train_find = 
{
	local entity targ;
	self.state = STATE_FIND;
	LinkRotateTargets();
	targ = find(world, targetname, self.path);
	if (targ.classname != "path_rotate")
	{
		objerror("Next target is not path_rotate");
	}
	self.goalentity = targ;
	if (targ.spawnflags & ANGLES)
	{
		self.angles = targ.angles;
		self.finalangle = SUB_NormalizeAngles(targ.angles);
	}
	self.path = targ.target;
	setorigin(self, targ.origin);
	SetTargetOrigin();
	RotateTargetsFinal();
	self.think1 = rotate_train_next;
	if (!(self.targetname))
	{
		self.endtime = self.ltime + 0.1;
	}
	else
	{
		self.endtime = FALSE;
	}
	self.duration = TRUE;
	self.cnt = time;
	self.dest2 = '0 0 0';
	self.dest1 = self.origin;
};

void() func_rotate_train = 
{
	if (!(self.speed))
	{
		self.speed = 100;
	}
	if (!(self.target))
	{
		objerror("rotate_train without a target");
	}
	if (!(self.noise))
	{
		if (self.sounds == FALSE)
		{
			self.noise = "misc/null.wav";
		}
		if (self.sounds == TRUE)
		{
			self.noise = "plats/train2.wav";
		}
	}
	if (!(self.noise1))
	{
		if (self.sounds == FALSE)
		{
			self.noise1 = "misc/null.wav";
		}
		if (self.sounds == TRUE)
		{
			self.noise1 = "plats/train1.wav";
		}
	}
	precache_sound(self.noise);
	precache_sound(self.noise1);
	self.cnt = TRUE;
	self.solid = FALSE;
	self.movetype = 4;
	self.use = rotate_train_use;
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	setorigin(self, self.origin);
	self.ltime = time;
	self.nextthink = self.ltime + 0.1;
	self.endtime = self.ltime + 0.1;
	self.think = rotate_train_think;
	self.think1 = rotate_train_find;
	self.state = STATE_FIND;
	self.duration = TRUE;
	self.cnt = 0.1;
	self.dest2 = '0 0 0';
	self.dest1 = self.origin;
	self.flags = self.flags | 512;
};

void() movewall_touch = 
{
	if (time < self.owner.attack_finished)
	{
		return;
	}
	if (self.dmg)
	{
		T_Damage(other, self, self.owner, self.dmg);
		self.owner.attack_finished = time + 0.5;
	}
	else
	{
		if (self.owner.dmg)
		{
			T_Damage(other, self, self.owner, self.owner.dmg);
			self.owner.attack_finished = time + 0.5;
		}
	}
};

void() movewall_blocked = 
{
	local entity temp;
	if (time < self.owner.attack_finished)
	{
		return;
	}
	self.owner.attack_finished = time + 0.5;
	if (self.owner.classname == "func_rotate_door")
	{
		temp = self;
		self = self.owner;
		rotate_door_group_reversedirection();
		self = temp;
	}
	if (self.dmg)
	{
		T_Damage(other, self, self.owner, self.dmg);
		self.owner.attack_finished = time + 0.5;
	}
	else
	{
		if (self.owner.dmg)
		{
			T_Damage(other, self, self.owner, self.owner.dmg);
			self.owner.attack_finished = time + 0.5;
		}
	}
};

void() movewall_think = 
{
	self.ltime = time;
	self.nextthink = time + 0.020000;
};

void() func_movewall = 
{
	self.angles = '0 0 0';
	self.movetype = 7;
	if (self.spawnflags & NONBLOCKING)
	{
		self.solid = FALSE;
	}
	else
	{
		self.solid = 4;
		self.blocked = movewall_blocked;
	}
	if (self.spawnflags & TOUCH)
	{
		self.touch = movewall_touch;
	}
	setmodel(self, self.model);
	if (!(self.spawnflags & VISIBLE))
	{
		self.model = string_null;
	}
	self.think = movewall_think;
	self.nextthink = time + 0.020000;
	self.ltime = time;
};

void() rotate_object = 
{
	self.classname = "rotate_object";
	self.solid = FALSE;
	self.movetype = FALSE;
	setmodel(self, self.model);
	setsize(self, self.mins, self.maxs);
	self.think = SUB_Null;
};

void() rotate_door_think2 = 
{
	local float t;
	t = time - self.ltime;
	self.ltime = time;
	self.frame = TRUE - self.frame;
	self.angles = self.dest;
	if (self.state == STATE_OPENING)
	{
		self.state = STATE_OPEN;
	}
	else
	{
		if (self.spawnflags & STAYOPEN)
		{
			rotate_door_group_reversedirection();
			return;
		}
		self.state = STATE_CLOSED;
	}
	sound(self, 2, self.noise3, TRUE, TRUE);
	self.think = SUB_Null;
	RotateTargetsFinal();
};

void() rotate_door_think = 
{
	local float t;
	t = time - self.ltime;
	self.ltime = time;
	if (time < self.endtime)
	{
		self.angles = self.angles + self.rotate * t;//self.angles = self.angles + self.rotate * t;
		RotateTargets();
	}
	else
	{
		self.angles = self.dest;
		RotateTargets();
		self.think = rotate_door_think2;
	}
	self.nextthink = time + 0.010000;
};

void() rotate_door_reversedirection = 
{
	local vector start;
	self.frame = TRUE - self.frame;
	if (self.state == STATE_CLOSING)
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}
	sound(self, 2, self.noise2, TRUE, TRUE);
	self.rotate = (self.dest - start) * (TRUE / self.speed);
	self.think = rotate_door_think;
	self.nextthink = time + 0.020000;
	self.endtime = time + self.speed - (self.endtime - time);
	self.ltime = time;
};

void() rotate_door_group_reversedirection = 
{
	local string name;
	if (self.group)
	{
		name = self.group;
		self = find(world, group, name);
		while (self)
		{
			rotate_door_reversedirection();
			self = find(self, group, name);
		}
	}
	else
	{
		rotate_door_reversedirection();
	}
};

void() rotate_door_use = 
{
	local vector start;
	if (self.state != STATE_OPEN && self.state != STATE_CLOSED)
	{
		return;
	}
	if (!(self.cnt))
	{
		self.cnt = TRUE;
		LinkRotateTargets();
	}
	self.frame = TRUE - self.frame;
	if (self.state == STATE_CLOSED)
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}
	sound(self, 2, self.noise2, TRUE, TRUE);
	self.rotate = (self.dest - start) * (TRUE / self.speed);
	self.think = rotate_door_think;
	self.nextthink = time + 0.010000;
	self.endtime = time + self.speed;
	self.ltime = time;
};

void() func_rotate_door = 
{
	if (!(self.target))
	{
		objerror("rotate_door without target.");
	}
	self.dest1 = '0 0 0';
	self.dest2 = self.angles;
	self.angles = self.dest1;
	if (!(self.speed))
	{
		self.speed = 2;
	}
	self.cnt = FALSE;
	if (!(self.dmg))
	{
		self.dmg = 2;
	}
	else
	{
		if (self.dmg < FALSE)
		{
			self.dmg = FALSE;
		}
	}
	if (self.sounds == FALSE)
	{
		precache_sound("misc/null.wav");
		if (self.noise1)
		{
			precache_sound(self.noise1);
		}
		else
		{
			self.noise1 = "misc/null.wav";
		}
		if (self.noise2)
		{
			precache_sound(self.noise2);
		}
		else
		{
			self.noise2 = "misc/null.wav";
		}
		if (self.noise3)
		{
			precache_sound(self.noise3);
		}
		else
		{
			self.noise3 = "misc/null.wav";
		}
	}
	if (self.sounds == TRUE)
	{
		precache_sound("doors/latch2.wav");
		precache_sound("doors/winch2.wav");
		precache_sound("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound("doors/airdoor1.wav");
		precache_sound("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound("doors/basesec1.wav");
		precache_sound("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}
	self.solid = FALSE;
	self.movetype = FALSE;
	setmodel(self, self.model);
	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.state = STATE_CLOSED;
	self.use = rotate_door_use;
	self.think = SUB_Null;
};

