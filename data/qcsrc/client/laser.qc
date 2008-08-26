// a laser goes from origin in direction angles
// it has color 'colormod'
// and stops when something is in the way
.float cnt; // end effect
.vector colormod;
.float state; // on-off

void Draw_Laser()
{
	if(!self.state)
		return;
	makevectors(self.angles);
	traceline(self.origin, self.origin + v_forward * 32768, 0, self);
	Draw_CylindricLine(self.origin, trace_endpos, 2, "particles/laserbeam", 1, self.colormod, DRAWFLAG_ADDITIVE); // TODO make a texture to make the laser look smoother
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
	}
	if(f & 8)
	{
		self.colormod_x = ReadByte() / 255.0;
		self.colormod_y = ReadByte() / 255.0;
		self.colormod_z = ReadByte() / 255.0;
		self.cnt = ReadShort(); // effect number
	}
	if(f & 2)
	{
		self.angles_x = ReadCoord();
		self.angles_y = ReadCoord();
	}
	if(f & 4)
		self.state = ReadByte();
	self.draw = Draw_Laser;
}
