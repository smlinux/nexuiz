// FIXME make this generic code, to be used for other entities too?
.vector iorigin1, iorigin2;
.vector ivelocity1, ivelocity2;
.vector iforward1, iforward2;
.vector iright1, iright2;
.float itime1, itime2;
void InterpolateOrigin_Note()
{
	float dt;

	makevectors(self.angles);

	self.iorigin1 = self.iorigin2;
	self.iforward1 = self.iforward2;
	self.iright1 = self.iright2;
	self.ivelocity1 = self.ivelocity2;

	self.iorigin2 = self.origin;
	self.iforward2 = v_forward;
	self.iright2 = v_right;
	self.ivelocity2 = self.velocity;

	dt = time - self.itime1;

	if(vlen(self.iorigin2 - self.iorigin1) > 1000)
	{
		self.iorigin1 = self.iorigin2;
		self.iforward1 = self.iforward2;
		self.iright1 = self.iright2;
		self.ivelocity1 = self.ivelocity2;
	}
	else if(vlen(self.ivelocity2 - self.ivelocity1) > 1000)
	{
		self.iforward1 = self.iforward2;
		self.iright1 = self.iright2;
		self.ivelocity1 = self.ivelocity2;
	}

	if(dt < 0.2)
	{
		self.itime1 = time;
		self.itime2 = time + getstatf(STAT_SYS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);
	}
	else
	{
		// don't lerp
		self.itime1 = self.itime2 = time;
	}
}
void InterpolateOrigin_Do()
{
	vector forward, right;
	if(self.itime1 && self.itime2 && self.itime1 != self.itime2)
	{
		float f;
		f = bound(0, (time - self.itime1) / (self.itime2 - self.itime1), 1);
		self.origin = (1 - f) * self.iorigin1 + f * self.iorigin2;
		forward = (1 - f) * self.iforward1 + f * self.iforward2;
		right = (1 - f) * self.iright1 + f * self.iright2;
		self.angles = vectoangles(forward, right);
		self.angles_x = -self.angles_x;
		self.velocity = (1 - f) * self.ivelocity1 + f * self.ivelocity2;
	}
}
void InterpolateOrigin_Undo()
{
	self.origin = self.iorigin2;
	self.angles = vectoangles(self.iforward2, self.iright2);
	self.angles_x = -self.angles_x;
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
		Draw_CylindricLine(self.origin, trace_endpos, 2, "particles/laserbeam", 0, time * 3, self.colormod, 0.5, DRAWFLAG_ADDITIVE); // TODO make a texture to make the laser look smoother
	}
	if(self.cnt >= 0)
		pointparticles(self.cnt, trace_endpos, trace_plane_normal, drawframetime * 1000);
	if(self.colormod != '0 0 0')
		R_AddDynamicLight(trace_endpos + trace_plane_normal * 1, 50, self.colormod * 5);
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
		self.cnt = ReadShort() - 1; // effect number
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
