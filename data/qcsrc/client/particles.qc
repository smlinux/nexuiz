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
.float atten;
.float volume;
.float absolute;
.vector movedir; // trace direction
.string message; // script stuff

float pointparticles_scriptbuf;
float pointparticles_scriptbufsize;
float pointparticles_scriptbufloaded;
void PointparticlesScript_Init()
{
	string s;
	float fh, i;
	pointparticles_scriptbuf = pointparticles_scriptbufsize = 0;
	pointparticles_scriptbufloaded = 1;
	s = strcat("maps/", mi_shortname, ".pp");
	fh = fopen(s, FILE_READ);
	if(fh < 0)
		return;
	pointparticles_scriptbuf = buf_create();
	while((s = fgets(fh)))
	{
		bufstr_set(pointparticles_scriptbuf, pointparticles_scriptbufsize, s);
		++pointparticles_scriptbufsize;
	}
	fclose(fh);
}

.float scriptline;
.float scriptline0;
.float scriptstate;
.float scripttime;
void PointparticlesScript_InitEntity(entity e)
{
	if(e.message != "")
	{
		if(!pointparticles_scriptbufloaded)
			PointparticlesScript_Init();

		string mychar;
		float i;

		e.scriptline0 = -1;
		mychar = substring(e.message, 0, 1);
		for(i = 0; i < pointparticles_scriptbufsize; ++i)
		{
			tokenize_sane(bufstr_get(pointparticles_scriptbuf, i));
			if(argv(0) == mychar)
				break;
		}
		e.scriptline = e.scriptline0 = i;
		if(i >= pointparticles_scriptbufsize)
		{
			print("func_pointparticles: script does not define ", mychar, "\n");
			e.message = "";
		}
	}
}

float PointparticlesScript(entity e)
{
	string l;
	string mychar;
	float mymult;
	float t;

	if(e.message == "")
		return 1;

	e.scriptstate = !!e.scriptstate; // turns 0 to 0 and 2 to 1

	mychar = substring(e.message, 0, 1);
	mymult = stof(substring(e.message, 1, -1));
	t = gettime(GETTIME_CDTRACK);

	tokenize_sane(bufstr_get(pointparticles_scriptbuf, e.scriptline));
	if(t < e.scripttime)
	{
		e.scriptline = e.scriptline0;
		e.scriptstate = 0;
		tokenize_sane(bufstr_get(pointparticles_scriptbuf, e.scriptline));
	}

	if(argv(0) != mychar)
	{
		e.scriptstate = 0; // end of script, will revert to beginning later
	}
	else if(t >= stof(argv(1)))
	{
		// time code reached!
		e.scriptstate = stof(argv(2)) * 2; // 0 = off, 2 = on
		e.scripttime = stof(argv(1));
		e.scriptline += 1;
	}

	if(e.scriptstate)
	{
		if(mymult >= 1)
			return (e.scriptstate == 2);
		else
			return pow(0.5, (t - e.scripttime) * (mymult / (1 - mymult)));
	}
	else
		return 0;
}

void Draw_PointParticles()
{
	float n, i, fail, force;
	vector p;
	vector sz;
	vector o;
	o = self.origin;
	sz = self.maxs - self.mins;
	n = self.impulse * drawframetime;
	n *= PointparticlesScript(self);
	if(n == 0)
		return;
	fail = 0;
	force = (self.scriptstate == 2);
	for(i = random(); (force || i <= n) && fail <= 64*n; ++i)
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
				sound(self, CHAN_AUTO, self.noise, VOL_BASE * self.volume, self.atten);
			}
			force = 0;
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
	if(self.message)
		strunzone(self.message);
	self.message = string_null;
}

void Ent_PointParticles()
{
	float f;
	vector v;
	f = ReadByte();
	if(f & 2)
	{
		self.impulse = ReadCoord(); // density (<0: point, >0: volume)
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
		if(self.noise != "")
		{
			self.atten = ReadByte() / 64.0;
			self.volume = ReadByte() / 255.0;
		}
		if(self.message)
			strunzone(self.message);
		self.message = strzone(ReadString());
		PointparticlesScript_InitEntity(self);
	}

	if(f & 2)
	{
		self.absolute = (self.impulse >= 0);
		if(!self.absolute)
		{
			v = self.maxs - self.mins;
			self.impulse *= -v_x * v_y * v_z / 262144; // relative: particles per 64^3 cube
		}
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

entity zcurve;
void zcurveparticles(float effectnum, vector start, vector end, float end_dz, float speed, float depth)
{
	// end_dz:
	//   IF IT WERE A STRAIGHT LINE, it'd end end_dz above end

	vector mid;
	mid = (start + end) * 0.5;

	end_dz *= 0.25;
	mid_z += end_dz;

	--depth;
	if(depth < 0 || normalize(mid - start) * normalize(end - start) > 0.999999)
	// TODO make this a variable threshold
	// currently: 0.081 degrees
	// 0.99999 would be 0.256 degrees and is visible
	{
		zcurve.velocity = speed * normalize(end - start);
		trailparticles(zcurve, effectnum, start, end);
	}
	else
	{
		zcurveparticles(effectnum, start, mid, end_dz, speed, depth);
		zcurveparticles(effectnum, mid, end, end_dz, speed, depth);
	}
}

void Net_ReadZCurveParticles()
{
	vector start, end;
	float end_dz;
	float effectnum, speed;

	if(!zcurve)
	{
		zcurve = spawn();
		zcurve.classname = "zcurve";
	}

	effectnum = ReadShort();

	start_x = ReadCoord();
	start_y = ReadCoord();
	start_z = ReadCoord();
	end_x = ReadCoord();
	end_y = ReadCoord();
	end_z = ReadCoord();
	end_dz = ReadCoord();
	speed = ReadShort() * 16;

	zcurveparticles(effectnum, start, end, end_dz, speed, 5); // at most 32 segments
}

void Net_ReadNexgunBeamParticle()
{
	vector shotorg, endpos;
	shotorg_x = ReadCoord(); shotorg_y = ReadCoord(); shotorg_z = ReadCoord();
	endpos_x = ReadCoord(); endpos_y = ReadCoord(); endpos_z = ReadCoord();
	
	pointparticles(particleeffectnum("nex_muzzleflash"), shotorg, normalize(endpos - shotorg) * 1000, 1);
	
	//draw either the old v2.3 beam or the new beam
	if (cvar("cl_particles_oldnexbeam") && (getstati(STAT_ALLOW_OLDNEXBEAM) || isdemo()))
		trailparticles(world, particleeffectnum("TE_TEI_G3"), shotorg, endpos);
	else
		trailparticles(world, particleeffectnum("nex_beam"), shotorg, endpos);
}
