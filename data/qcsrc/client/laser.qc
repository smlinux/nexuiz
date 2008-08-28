// FIXME make this generic code, to be used for other entities too?
.vector iorigin1, iorigin2;
.vector ivelocity1, ivelocity2;
.vector iangles1, iangles2;
.float itime1, itime2;
void InterpolateOrigin_Note()
{
	float dt;

	self.iorigin1 = self.iorigin2;
	self.iangles1 = self.iangles2;
	self.ivelocity1 = self.ivelocity2;

	self.iorigin2 = self.origin;
	self.iangles2 = self.angles;
	self.ivelocity2 = self.velocity;

	dt = time - self.itime1;

	if(vlen(self.iorigin2 - self.iorigin1) > 1000)
	{
		self.iorigin1 = self.iorigin2;
		self.iangles1 = self.iangles2;
		self.ivelocity1 = self.ivelocity2;
	}
	else if(vlen(self.ivelocity2 - self.ivelocity1) > 1000)
	{
		self.iangles1 = self.iangles2;
		self.ivelocity1 = self.ivelocity2;
	}

	if(dt < 0.2)
	{
		self.itime1 = time;
		self.itime2 = time + getstatf(STAT_SYS_TICRATE);
	}
	else
	{
		// don't lerp
		self.itime1 = self.itime2 = time;
	}
}
void InterpolateOrigin_Do()
{
	if(self.itime1 && self.itime2 && self.itime1 != self.itime2)
	{
		float f;
		f = bound(0, (time - self.itime1) / (self.itime2 - self.itime1), 1);
		self.origin = (1 - f) * self.iorigin1 + f * self.iorigin2;
		self.angles = (1 - f) * self.iangles1 + f * self.iangles2;
		self.velocity = (1 - f) * self.ivelocity1 + f * self.ivelocity2;
	}
}
void InterpolateOrigin_Undo()
{
	self.origin = self.iorigin2;
	self.angles = self.iangles2;
	self.velocity = self.ivelocity2;
}

// a laser goes from origin in direction angles
// it has color 'colormod'
// and stops when something is in the way
.float cnt; // end effect
.vector colormod;
.float state; // on-off
.float count; // flags for the laser
.vector velocity;
.float alpha;

void Draw_Laser()
{
	if(!self.state)
		return;
	InterpolateOrigin_Do();
	if(self.count & 0x80)
	{
		traceline(self.origin, self.velocity, 0, self);
	}
	else
	{
		makevectors(self.angles);
		traceline(self.origin, self.origin + v_forward * 32768, 0, self);
	}
	if(self.alpha)
	{
		Draw_CylindricLine(self.origin, trace_endpos, 2, "particles/laserbeam", 0, time * 3, self.colormod, self.alpha, DRAWFLAG_NORMAL); // TODO make a texture to make the laser look smoother
	}
	else
	{
		Draw_CylindricLine(self.origin, trace_endpos, 2, "particles/laserbeam", 0, time * 3, self.colormod, 1, DRAWFLAG_ADDITIVE); // TODO make a texture to make the laser look smoother
	}
	pointparticles(self.cnt, trace_endpos, trace_plane_normal, 256 * drawframetime);
}

void Ent_Laser()
{
	float f;
	// 30 bytes, or 13 bytes for just moving
	f = ReadByte();
	self.count = (f & 0xC0);
	InterpolateOrigin_Undo();
	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}
	if(f & 8)
	{
		self.colormod_x = ReadByte() / 255.0;
		self.colormod_y = ReadByte() / 255.0;
		self.colormod_z = ReadByte() / 255.0;
		if(f & 0x40)
			self.alpha = ReadByte() / 255.0;
		else
			self.alpha = 0;
		self.cnt = ReadShort(); // effect number
	}
	if(f & 2)
	{
		if(f & 0x80)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
		}
		else
		{
			self.angles_x = ReadCoord();
			self.angles_y = ReadCoord();
		}
	}
	if(f & 4)
		self.state = ReadByte();
	InterpolateOrigin_Note();
	self.draw = Draw_Laser;
}
