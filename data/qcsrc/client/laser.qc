// a laser goes from origin in direction velocity
// it has color 'colormod'
// and stops when something is in the way
.float cnt; // end effect
.vector colormod;

void Draw_Laser()
{
	traceline(self.origin, self.origin + self.velocity, 0, self);
	Draw_CylindricLine(self.origin, trace_endpos, 4, "particles/laserbeam", 1, self.colormod, DRAWFLAG_ADDITIVE); // TODO make a texture to make the laser look smoother
	pointparticles(self.cnt, trace_endpos, trace_plane_normal, 256 * drawframetime);
}

void Ent_Laser()
{
	float f;
	// 30 bytes, or 13 bytes for just moving
	f = ReadByte();
	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		self.colormod_x = ReadByte() / 255.0;
		self.colormod_y = ReadByte() / 255.0;
		self.colormod_z = ReadByte() / 255.0;
		self.cnt = ReadShort(); // effect number
	}
	if(f & 2)
	{
		self.velocity_x = ReadCoord();
		self.velocity_y = ReadCoord();
		self.velocity_z = ReadCoord();
	}
	self.draw = Draw_Laser;
}
