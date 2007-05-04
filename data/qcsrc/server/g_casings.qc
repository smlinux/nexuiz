void() casingtouch =
{
	if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		remove(self);
		return;
	}
	if (other.solid == SOLID_BSP)
	if (vlen(self.velocity) >= 50)
	if (time >= self.attack_finished)
	sound (self, CHAN_IMPACT, "weapons/tink1.wav", 0.5, ATTN_NORM);
	self.attack_finished = time + 0.2;
	//self.touch = SUB_Null; // one tink is enough
	//self.dest = self.origin - self.groundentity.origin;
};

void() casingthink =
{
	local   float   p;
	self.nextthink = time + 0.1;
	if (self.flags & FL_ONGROUND)
	{
	// just keep the yaw angle
		self.angles_x = 0;
		self.angles_z = 0;
		self.flags = self.flags - FL_ONGROUND;
		self.nextthink = time + 0.5;
	}
	p = pointcontents(self.origin);
	if (p == CONTENT_SOLID || p == CONTENT_LAVA || p == CONTENT_SKY)
	{
		removedecor(self);
		return;
	}
	if (time > self.cnt)
	{
		self.nextthink = time;
		self.alpha = self.alpha - frametime;
		if (self.alpha < 0.0625)
			removedecor(self);
	}
};

// knock loose the casing when disturbed
void() casingknockedloosefunc =
{
	self.movetype = MOVETYPE_BOUNCE;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = randomvec() * 300;
	self.nextthink = time + 0.1;
	self.touch = casingtouch;
};

void(vector org, vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype) SpawnCasing =
{
	local entity e;
	if (cvar("temp1") & 2048)
		return;

	e = newdecor();
	e.isdecor = TRUE;
	e.alpha = 1;
	//e.forcescale = 15;
	e.movetype = MOVETYPE_BOUNCE;
	e.solid = SOLID_TRIGGER;
	e.velocity = vel + randomvec() * randomvel;
	e.angles = ang;
	e.avelocity = avel + randomvec() * randomavel;
	e.nextthink = time;
	e.think = casingthink;
	e.touch = casingtouch;
	//e.knockedloosefunc = casingknockedloosefunc;
	e.effects = EF_LOWPRECISION;
	e.createdtime = time;
	if (casingtype == 1)
	{
		setmodel (e, "models/casing_shell.mdl"); // precision set above
		e.cnt = time + 30;
		// bias to make these be considered more important than other things
		e.createdtime = time + 1;
	}
	else if (casingtype == 2)
	{
		// FIXME: this is not used and not precached, uncomment if you need it
		//setmodel (e, "models/casing_steel.mdl"); // precision set above
		e.cnt = time + 10;
	}
	else
	{
		setmodel (e, "models/casing_bronze.mdl"); // precision set above
		e.cnt = time + 10;
	}
	if (maxclients == 1)
		e.cnt = time + 3000;
	setsize (e, '0 0 -1', '0 0 -1');
	setorigin (e, org);
};
