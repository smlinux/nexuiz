// a laser goes from origin in direction angles
// it has color 'colormod'
// and stops when something is in the way
.float cnt; // end effect
.vector colormod;
.float state; // on-off
.float count; // flags for the laser
.vector velocity;
.float alpha;
.float scale; // scaling factor of the thickness
.float modelscale; // scaling factor of the dlight

// TODO move these into a heade file
float trace_dphitq3surfaceflags;
float Q3SURFACEFLAG_SKY = 4; // sky surface (also has NOIMPACT and NOMARKS set)
float Q3SURFACEFLAG_NOIMPACT = 16; // projectiles should remove themselves on impact (this is set on sky)

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
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
			trace_endpos = self.origin + v_forward * 1048576;
	}
	if(self.scale != 0)
	{
		if(self.alpha)
		{
			Draw_CylindricLine(self.origin, trace_endpos, self.scale, "particles/laserbeam", 0, time * 3, self.colormod, self.alpha, DRAWFLAG_NORMAL); // TODO make a texture to make the laser look smoother
		}
		else
		{
			Draw_CylindricLine(self.origin, trace_endpos, self.scale, "particles/laserbeam", 0, time * 3, self.colormod, 0.5, DRAWFLAG_ADDITIVE); // TODO make a texture to make the laser look smoother
		}
	}
	if not(trace_dphitq3surfaceflags & (Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NOIMPACT))
	{
		if(self.cnt >= 0)
			pointparticles(self.cnt, trace_endpos, trace_plane_normal, drawframetime * 1000);
		if(self.colormod != '0 0 0' && self.modelscale != 0)
			R_AddDynamicLight(trace_endpos + trace_plane_normal * 1, self.modelscale, self.colormod * 5);
	}
}

void Ent_Laser()
{
	float f;
	InterpolateOrigin_Undo();

	// 30 bytes, or 13 bytes for just moving
	f = ReadByte();
	self.count = (f & 0xE0);

	if(self.count & 0x80)
		self.iflags = IFLAG_VELOCITY;
	else
		self.iflags = IFLAG_ANGLES;

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
		self.scale = 2;
		self.modelscale = 50;
		if(f & 0x20)
		{
			self.scale *= ReadByte() / 16.0; // beam radius
			self.modelscale *= ReadByte() / 16.0; // dlight radius
		}
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
			self.angles_x = ReadAngle();
			self.angles_y = ReadAngle();
		}
	}
	if(f & 4)
		self.state = ReadByte();
	InterpolateOrigin_Note();
	self.draw = Draw_Laser;
}
