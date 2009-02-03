vector PointInBrush_vec;
entity PointInBrush_brush;
.float dphitcontentsmask;
float PointInBrush_Recurse()
{
	float s;
	entity se;
	float f;

	traceline(PointInBrush_vec, PointInBrush_vec, 0, world);
	if not(trace_ent)
		return 0;
	if(trace_ent == PointInBrush_brush)
		return 1;

	se = trace_ent;
	s = se.solid;
	se.solid = SOLID_NOT;
	f = PointInBrush_Recurse();
	se.solid = s;

	return f;
}
float PointInBrush(entity brush, vector point)
{
	float f, s;

	if not(brush.modelindex)
		return 1;

	s = brush.solid;
	brush.solid = SOLID_BSP;
	PointInBrush_vec = point;
	PointInBrush_brush = brush;
	f = PointInBrush_Recurse();
	brush.solid = s;

	return f;
}

.float cnt; // effect number
.vector velocity; // particle velocity
.float waterlevel; // direction jitter
.float count; // count multiplier
.float glow_color; // palette color
.float impulse; // density
.string noise; // sound
.float absolute;
.vector movedir; // trace direction

void Draw_PointParticles()
{
	float n, i, fail;
	vector p;
	vector sz;
	vector o;
	o = self.origin;
	sz = self.maxs - self.mins;
	n = self.impulse * drawframetime;
	if(n == 0)
		return;
	fail = 0;
	for(i = random(); i <= n && fail <= 64*n; ++i)
	{
		p = o + self.mins;
		p_x += random() * sz_x;
		p_y += random() * sz_y;
		p_z += random() * sz_z;
		if(PointInBrush(self, p))
		{
			if(self.movedir != '0 0 0')
			{
				traceline(p, p + normalize(self.movedir) * 4096, 0, world);
				p = trace_endpos;
				pointparticles(self.cnt, p, trace_plane_normal * vlen(self.movedir) + self.velocity + randomvec() * self.waterlevel, self.count, self.glow_color);
			}
			else
				pointparticles(self.cnt, p, self.velocity + randomvec() * self.waterlevel, self.count, self.glow_color);
			if(self.noise != "")
			{
				self.origin = p;
				sound(self, CHAN_AUTO, self.noise, 1, ATTN_NORM);
			}
		}
		else if(self.absolute)
		{
			++fail;
			--i;
		}
	}
	self.origin = o;
}

void Ent_PointParticles_Remove()
{
	if(self.noise)
		strunzone(self.noise);
	self.noise = string_null;
}

void Ent_PointParticles()
{
	float f;
	f = ReadByte();
	if(f & 2)
	{
		self.impulse = ReadCoord(); // density (<0: point, >0: volume)
		self.absolute = (self.impulse >= 0);
		if(!self.absolute)
			self.impulse *= -self.maxs_x * self.maxs_y * self.maxs_z / 262144; // relative: particles per 64^3 cube
	}
	if(f & 4)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}
	if(f & 1)
	{
		self.modelindex = ReadShort();
		if(self.modelindex)
		{
			self.mins_x = ReadCoord();
			self.mins_y = ReadCoord();
			self.mins_z = ReadCoord();
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}
		else
		{
			self.mins    = '0 0 0';
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}

		self.cnt = ReadShort(); // effect number

		self.velocity = decompressShortVector(ReadShort());
		self.movedir = decompressShortVector(ReadShort());
		self.waterlevel = ReadCoord();
		self.count = ReadCoord();
		self.glow_color = ReadByte();
		if(self.noise)
			strunzone(self.noise);
		self.noise = strzone(ReadString());
	}

	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.solid = SOLID_NOT;
	self.draw = Draw_PointParticles;
	self.entremove = Ent_PointParticles_Remove;
}

void Draw_Rain()
{
    te_particlerain(self.origin + self.mins, self.origin + self.maxs, self.velocity, self.count * drawframetime, self.glow_color);
}

void Draw_Snow()
{
    te_particlesnow(self.origin + self.mins, self.origin + self.maxs, self.velocity, self.count * drawframetime, self.glow_color);
}

void Ent_RainOrSnow()
{
	self.impulse = ReadByte(); // Rain, Snow, or Whatever
	self.origin_x = ReadCoord();
	self.origin_y = ReadCoord();
	self.origin_z = ReadCoord();
	self.maxs_x = ReadCoord();
	self.maxs_y = ReadCoord();
	self.maxs_z = ReadCoord();
	self.velocity = decompressShortVector(ReadShort());
	self.count = ReadShort() * 10;
	self.glow_color = ReadByte(); // color

	self.mins    = -0.5 * self.maxs;
	self.maxs    =  0.5 * self.maxs;
	self.origin  = self.origin - self.mins;

	setorigin(self, self.origin);
	setsize(self, self.mins, self.maxs);
	self.solid = SOLID_NOT;
	if(self.impulse)
		self.draw = Draw_Rain;
	else
		self.draw = Draw_Snow;
}
