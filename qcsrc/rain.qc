void() rain_think =

{

	self.nextthink = time + 0.1;

	te_particlerain(self.absmin, self.absmax, self.destvec, self.count, self.cnt);

//	te_particlesnow(self.absmin, self.absmax, self.destvec * 0.25, self.count, self.cnt);

//	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);

//	WriteByte (MSG_BROADCAST, TE_PARTICLERAIN);

//	WriteVec (MSG_BROADCAST, self.absmin);

//	WriteVec (MSG_BROADCAST, self.absmax);

//	WriteVec (MSG_BROADCAST, self.destvec);

//	WriteShort (MSG_BROADCAST, self.count);

//	WriteByte (MSG_BROADCAST, self.cnt);

};



/*QUAKED func_rain (0 .5 .8) ?

This is an invisible area like a trigger, which rain falls inside of.



Keys:

"velocity"

 falling direction (should be something like '0 0 -700', use the X and Y velocity for wind)

"cnt"

 sets color of rain (default 12 - white)

"count"

 adjusts rain density, this many particles fall every second, experiment to see the effects (default is based on area size)

*/

void() func_rain =

{

	self.destvec = self.velocity;

	self.velocity = '0 0 0';

	if (!self.destvec)

		self.destvec = '0 0 -700';

	self.angles = '0 0 0';

	self.movetype = MOVETYPE_NONE;

	self.solid = SOLID_NOT;

	setmodel(self, self.model);

	setorigin(self, self.origin);

	setsize(self, self.mins, self.maxs);

	self.model = "";

	if (!self.cnt)

		self.cnt = 12;

	if (!self.count)

		self.count = (self.absmax_x - self.absmin_x)*(self.absmax_y - self.absmin_y)/8192;

	if (self.count < 1)

	{

		remove(self);

		return;

	}

	// convert from per second to per 0.1 sec,

	self.count = ceil(self.count * 0.1);

	self.think = rain_think;

	self.nextthink = time + 0.5;

};



void() snow_think =

{

	self.nextthink = time + 0.1;

	te_particlesnow(self.absmin, self.absmax, self.destvec, self.count, self.cnt);

//	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);

//	WriteByte (MSG_BROADCAST, TE_PARTICLESNOW);

//	WriteVec (MSG_BROADCAST, self.absmin);

//	WriteVec (MSG_BROADCAST, self.absmax);

//	WriteVec (MSG_BROADCAST, self.destvec);

//	WriteShort (MSG_BROADCAST, self.count);

//	WriteByte (MSG_BROADCAST, self.cnt);

};



/*QUAKED func_snow (0 .5 .8) ?

This is an invisible area like a trigger, which snow falls inside of.



Keys:

"velocity"

 falling direction (should be something like '0 0 -300', use the X and Y velocity for wind)

"cnt"

 sets color of rain (default 12 - white)

"count"

 adjusts snow density, this many particles fall every second, experiment to see the effects (default is based on area size)

*/

void() func_snow =

{

	self.destvec = self.velocity;

	self.velocity = '0 0 0';

	if (!self.destvec)

		self.destvec = '0 0 -300';

	self.angles = '0 0 0';

	self.movetype = MOVETYPE_NONE;

	self.solid = SOLID_NOT;

	setmodel(self, self.model);

	setorigin(self, self.origin);

	setsize(self, self.mins, self.maxs);

	self.model = "";

	if (!self.cnt)

		self.cnt = 12;

	if (!self.count)

		self.count = (self.absmax_x - self.absmin_x)*(self.absmax_y - self.absmin_y)/8192;

	if (self.count < 1)

	{

		remove(self);

		return;

	}

	// convert from per second to per 0.1 sec,

	self.count = ceil(self.count * 0.1);

	self.think = snow_think;

	self.nextthink = time + 0.5;

};



void() particlecube_think =

{

	self.nextthink = time + 0.1;

	te_particlecube(self.absmin, self.absmax, self.destvec, self.count, self.cnt, (self.spawnflags & 1) != 0, self.cnt2);

//	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);

//	WriteByte (MSG_BROADCAST, TE_PARTICLECUBE);

//	WriteVec (MSG_BROADCAST, self.absmin);

//	WriteVec (MSG_BROADCAST, self.absmax);

//	WriteVec (MSG_BROADCAST, self.destvec);

//	WriteShort (MSG_BROADCAST, self.count);

//	WriteByte (MSG_BROADCAST, self.cnt);

//	if (self.spawnflags & 1)

//		WriteByte (MSG_BROADCAST, 1);

//	else

//		WriteByte (MSG_BROADCAST, 0);

//	WriteCoord (MSG_BROADCAST, self.cnt2);

};



/*QUAKED func_particlecube (0 .5 .8) ? GRAVITY

This is an invisible area like a trigger, which particles spawn in.



Flags:

gravity

 if set the particles will fall.



Keys:

"velocity"

 particle velocity. (default is '0 0 0)

"cnt"

 sets color of particles (default 12 - white), the colors are actually a range of 4 colors, starting with this color.

"count"

 adjusts particle density, this many particles appear every second, experiment to see the effects (default is based on area size).

"cnt2"

 random velocity adjustment, default is 0, higher makes the particles more random, 0 makes them follow velocity exactly.

*/

void() func_particlecube =

{

	self.destvec = self.velocity;

	self.velocity = '0 0 0';

	self.angles = '0 0 0';

	self.movetype = MOVETYPE_NONE;

	self.solid = SOLID_NOT;

	setmodel(self, self.model);

	setorigin(self, self.origin);

	setsize(self, self.mins, self.maxs);

	self.model = "";

	if (!self.cnt)

		self.cnt = 12;

	if (!self.count)

		self.count = (self.absmax_x - self.absmin_x)*(self.absmax_y - self.absmin_y)*(self.absmax_z - self.absmin_z)/65536;

	if (self.count < 1)

	{

		remove(self);

		return;

	}

//	if (self.spawnflags & 1)

//		self.lefty = 1;

	// convert from per second to per 0.1 sec,

	// and round up to nearest multiple of 4

	self.count = ((self.count * 0.1) + 3) & 65532;

	self.think = particlecube_think;

	self.nextthink = time + 0.5;

};



