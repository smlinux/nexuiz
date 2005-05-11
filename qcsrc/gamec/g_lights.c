float LOOP = 1;

float DNOSHADOW = 2;
float DFOLLOW = 4;
.float light_lev;
.float lefty;
.vector color;
.string dtagname;

/*QUAKED dynlight (0 1 0) (-8 -8 -8) (8 8 8) START_OFF NOSHADOW FOLLOW
Dynamic light.
Can do one of these things: sit still and be just a silly light, travel along a path, follow an entity around, attach to a tag on an entity.
It can spin around it's own axis in all the above cases.
If targeted, it will toggle between on or off.
keys:
"light_lev" light radius, default 200
"color" light color in rgb and brightness, 1 1 1 produces bright white, up to 255 255 255 (nuclear blast), recommended values up to 1 1 1, default 1 1 1
"style" lightstyle, same as for static lights
"angles" initial orientation
"avelocity" a vector value, the direction and speed it rotates in
"skin" cubemap number, must be 16 or above
"dtagname" will attach to this tag on the entity which "targetname" matches "target". If the "target" is either not an md3 model or is missing tags, it will attach to the targets origin. Note that the "target" must be visible to the light
"targetname" will toggle on and off when triggered
"target" if issued with a target, preferrably path_corner, it will move along the path. If also issued with the FOLLOW spawnflag, then this is the entity it will follow. If issued with the "tagname" key it will attach it to this targets tag called "tagname", does not work together with FOLLOW or path movement
"speed" the speed it will travel along the path, default 100
flags:
"START_OFF" light will be in off state until targeted
"NOSHADOW" will not cast shadows in realtime lighting mode
"FOLLOW" will follow the entity which "targetname" matches "target"
*/
void() dynlight_think =
{
	if(!self.owner)
		remove(self);

	self.nextthink = 0.1;
};
void() dynlight_find_aiment =
{
	local entity targ;

	targ = find(world, targetname, self.target);
	self.movetype = MOVETYPE_FOLLOW;
	self.aiment = targ;
	self.owner = targ;
	self.punchangle = targ.angles;
	self.view_ofs = self.origin - targ.origin;
	self.v_angle = self.angles - targ.angles;
	self.nextthink = 0.1;
	self.think = dynlight_think;
};
void() dynlight_find_path =
{
	local entity targ;

	targ = find(world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin);
	self.nextthink = self.ltime + 0.1;
	self.think = train_next;
};
void() dynlight_use =
{
	if (self.light_lev == 0)
		self.light_lev = self.lefty;
	else
		self.light_lev = 0;
};
void() dynlight =
{
	local	entity	targ;

	if (!self.light_lev)
		self.light_lev = 200;
	if (!self.color)
		self.color = '1 1 1';
	self.lefty = self.light_lev;
	self.use = dynlight_use;
	setsize (self, '0 0 0', '0 0 0');
	setorigin (self, self.origin);
	//self.pflags = PFLAGS_FULLDYNAMIC;
	self.solid = SOLID_NOT;
	//self.blocked = SUB_Null;
	//if (self.spawnflags & DNOSHADOW)
	//	self.pflags = self.pflags + PFLAGS_NOSHADOW;
	//if (self.spawnflags & START_OFF)
	//	self.light_lev = 0;

//tag attaching
	if (self.dtagname)
	{
		if (!self.target)
			objerror ("dynlight: no target to follow");
		targ = find(world, targetname, self.target);
		setattachment(self, targ, self.dtagname);
		self.owner = targ;
		self.think = dynlight_think;
		return;
	}

// entity following
	if (self.spawnflags & DFOLLOW)
	{
		if (!self.target)
			objerror ("dynlight: no target to follow");
		self.nextthink = time + 0.1;
		self.think = dynlight_find_aiment;
		return;
	}
// path following
	if (self.target)
//	if (!(self.spawnflags & DFOLLOW))
	{
		self.movetype = MOVETYPE_PUSH;
		if (!self.speed)
			self.speed = 100;
		self.nextthink = self.ltime + 0.1;
		self.think = dynlight_find_path;
	}
};