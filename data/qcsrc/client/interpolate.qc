// FIXME make this generic code, to be used for other entities too?
.vector iorigin1, iorigin2;
.vector ivelocity1, ivelocity2;
.vector iforward1, iforward2;
.vector iup1, iup2;
.float itime1, itime2;
void InterpolateOrigin_Reset()
{
	self.iflags &~= (IFLAG_PREVALID | IFLAG_VALID);
	self.itime1 = self.itime2 = 0;
}
void InterpolateOrigin_Note()
{
	float dt;

	dt = time - self.itime2;

	if(self.iflags & IFLAG_PREVALID)
		self.iflags |= IFLAG_VALID;
	else
		self.iflags |= IFLAG_PREVALID;

	self.iorigin1 = self.iorigin2;
	self.iorigin2 = self.origin;

	if(self.iflags & IFLAG_AUTOANGLES)
		self.angles = vectoangles(self.iorigin2 - self.iorigin1);

	if(self.iflags & IFLAG_ANGLES)
	{
		fixedmakevectors(self.angles);
		self.iforward1 = self.iforward2;
		self.iup1 = self.iup2;
		self.iforward2 = v_forward;
		self.iup2 = v_up;
	}

	if(self.iflags & IFLAG_VELOCITY)
	{
		self.ivelocity1 = self.ivelocity2;
		self.ivelocity2 = self.velocity;
	}

	if(vlen(self.iorigin2 - self.iorigin1) > 1000)
	{
		self.itime1 = self.itime2 = time; // don't lerp
	}

	if((self.iflags & IFLAG_VELOCITY) && (vlen(self.ivelocity2 - self.ivelocity1) > 1000))
	{
		self.itime1 = self.itime2 = time; // don't lerp
	}

	if(dt < 0.2)
	{
		self.itime1 = serverprevtime;
		self.itime2 = time;
	}
	else
	{
		// don't lerp
		self.itime1 = self.itime2 = time;
	}
}
void InterpolateOrigin_Do()
{
	vector forward, up;
	if(self.itime1 && self.itime2 && self.itime1 != self.itime2)
	{
		float f;
		f = bound(0, (time - self.itime1) / (self.itime2 - self.itime1), 1);
		self.origin = (1 - f) * self.iorigin1 + f * self.iorigin2;
		if(self.iflags & IFLAG_ANGLES)
		{
			forward = (1 - f) * self.iforward1 + f * self.iforward2;
			up = (1 - f) * self.iup1 + f * self.iup2;
			self.angles = fixedvectoangles2(forward, up);
		}
		if(self.iflags & IFLAG_VELOCITY)
			self.velocity = (1 - f) * self.ivelocity1 + f * self.ivelocity2;
	}
}
void InterpolateOrigin_Undo()
{
	self.origin = self.iorigin2;
	if(self.iflags & IFLAG_ANGLES)
		self.angles = fixedvectoangles2(self.iforward2, self.iup2);
	if(self.iflags & IFLAG_VELOCITY)
		self.velocity = self.ivelocity2;
}

