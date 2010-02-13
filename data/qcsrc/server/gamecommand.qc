string GotoMap(string m);
void race_DeleteTime(float pos);

float FullTraceFraction(vector a, vector mi, vector ma, vector b)
{
	vector c;
	float white, black;

	white = 0.001;
	black = 0.001;

	c = a;

	float n, m;
	n = m = 0;

	while(vlen(c - b) > 1)
	{
		++m;

		tracebox(c, mi, ma, b, MOVE_WORLDONLY, world);
		++n;

		if(!trace_startsolid)
		{
			black += vlen(trace_endpos - c);
			c = trace_endpos;
		}

		n += tracebox_inverted(c, mi, ma, b, MOVE_WORLDONLY, world);

		white += vlen(trace_endpos - c);
		c = trace_endpos;
	}

	if(n > 200)
		dprint("HOLY SHIT! FullTraceFraction: ", ftos(n), " total traces, ", ftos(m), " iterations\n");

	return white / (black + white);
}

float RadarMapAtPoint_Trace(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector a, b, mi, ma;

	mi = '0 0 0';
	ma = '1 0 0' * w + '0 1 0' * h;
	a = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;
	b = '1 0 0' * x + '0 1 0' * y + '0 0 1' * (zsize + zmin);

	return FullTraceFraction(a, mi, ma, b);
}
float RadarMapAtPoint_LineBlock(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector o, mi, ma;
	float i, r;
	vector dz;

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	dz = (zsize / q) * '0 0 1';
	ma = '1 0 0' * w + '0 1 0' * h + dz;
	o = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;

	if(x < world.absmin_x - w)
		return 0;
	if(y < world.absmin_y - h)
		return 0;
	if(x > world.absmax_x)
		return 0;
	if(y > world.absmax_y)
		return 0;

	r = 0;
	for(i = 0; i < q; ++i)
	{
		vector v1, v2;
		v1 = v2 = o + dz * i + mi;
		v1_x += random() * (ma_x - mi_x);
		v1_y += random() * (ma_y - mi_y);
		v1_z += random() * (ma_z - mi_z);
		v2_x += random() * (ma_x - mi_x);
		v2_y += random() * (ma_y - mi_y);
		v2_z += random() * (ma_z - mi_z);
		traceline(v1, v2, MOVE_WORLDONLY, world);
		if(trace_startsolid || trace_fraction < 1)
			++r;
	}
	return r / q;
}
float RadarMapAtPoint_Block(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector o, mi, ma;
	float i, r;
	vector dz;

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	dz = (zsize / q) * '0 0 1';
	ma = '1 0 0' * w + '0 1 0' * h + dz;
	o = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;

	if(x < world.absmin_x - w)
		return 0;
	if(y < world.absmin_y - h)
		return 0;
	if(x > world.absmax_x)
		return 0;
	if(y > world.absmax_y)
		return 0;

	r = 0;
	for(i = 0; i < q; ++i)
	{
		tracebox(o + dz * i, mi, ma, o + dz * i, MOVE_WORLDONLY, world);
		if(trace_startsolid)
			++r;
	}
	return r / q;
}
float RadarMapAtPoint_Sample(float x, float y, float w, float h, float zmin, float zsize, float q)
{
	vector a, b, mi, ma;

	q *= 4; // choose q so it matches the regular algorithm in speed

	q = 256 * q - 1;
	// 256q-1 is the ideal sample count to map equal amount of sample values to one pixel value

	mi = '0 0 0';
	ma = '1 0 0' * w + '0 1 0' * h;
	a = '1 0 0' * x + '0 1 0' * y + '0 0 1' * zmin;
	b = '1 0 0' * w + '0 1 0' * h + '0 0 1' * zsize;

	float c, i;
	c = 0;

	for(i = 0; i < q; ++i)
	{
		vector v;
		v_x = a_x + random() * b_x;
		v_y = a_y + random() * b_y;
		v_z = a_z + random() * b_z;
		traceline(v, v, MOVE_WORLDONLY, world);
		if(trace_startsolid)
			++c;
	}

	return c / q;
}

// FF is contained twice, to map 256 to FF too
// removes the need to bound()
string doublehex = "000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFFFF";

float RADAR_WIDTH_MAX = 2048;
float RADAR_HEIGHT_MAX = 2048;
float sharpen_buffer[RADAR_WIDTH_MAX * 3];

void sharpen_set(float x, float v)
{
	sharpen_buffer[x + 2 * RADAR_WIDTH_MAX] = v;
}

float sharpen_getpixel(float x, float y)
{
	if(x < 0)
		return 0;
	if(x >= RADAR_WIDTH_MAX)
		return 0;
	if(y < 0)
		return 0;
	if(y > 2)
		return 0;
	return sharpen_buffer[x + y * RADAR_WIDTH_MAX];
}

float sharpen_get(float x, float a)
{
	float sum;
	sum = sharpen_getpixel(x, 1);
	if(a == 0)
		return sum;
	sum *= (8 + 1/a);
	sum -= sharpen_getpixel(x - 1, 0);
	sum -= sharpen_getpixel(x - 1, 1);
	sum -= sharpen_getpixel(x - 1, 2);
	sum -= sharpen_getpixel(x + 1, 0);
	sum -= sharpen_getpixel(x + 1, 1);
	sum -= sharpen_getpixel(x + 1, 2);
	sum -= sharpen_getpixel(x, 0);
	sum -= sharpen_getpixel(x, 2);
	return bound(0, sum * a, 1);
}

void sharpen_shift(float w)
{
	float i;
	for(i = 0; i < w; ++i)
	{
		sharpen_buffer[i] = sharpen_buffer[i + RADAR_WIDTH_MAX];
		sharpen_buffer[i + RADAR_WIDTH_MAX] = sharpen_buffer[i + 2 * RADAR_WIDTH_MAX];
		sharpen_buffer[i + 2 * RADAR_WIDTH_MAX] = 0;
	}
}

void sharpen_init(float w)
{
	float i;
	for(i = 0; i < w; ++i)
	{
		sharpen_buffer[i] = 0;
		sharpen_buffer[i + RADAR_WIDTH_MAX] = 0;
		sharpen_buffer[i + 2 * RADAR_WIDTH_MAX] = 0;
	}
}

entity radarmapper;
void RadarMap_Next()
{
	if(radarmapper.count & 4)
	{
		localcmd("quit\n");
	}
	else if(radarmapper.count & 2)
	{
		localcmd(strcat("defer 1 \"sv_cmd radarmap --flags ", ftos(radarmapper.count), strcat(" --res ", ftos(radarmapper.size_x), " ", ftos(radarmapper.size_y), " --sharpen ", ftos(radarmapper.ltime), " --qual ", ftos(radarmapper.size_z)), "\"\n"));
		GotoNextMap();
	}
	remove(radarmapper);
	radarmapper = world;
}

// rough map entity
//   cnt: current line
//   size: pixel width/height
//   maxs: cell width/height
//   frame: counter
void RadarMap_Think()
{
	float i, x, l;
	string si;

	if(self.frame == 0)
	{
		// initialize
		get_mi_min_max_texcoords(1);
		self.mins = mi_picmin;
		self.maxs_x = (mi_picmax_x - mi_picmin_x) / self.size_x;
		self.maxs_y = (mi_picmax_y - mi_picmin_y) / self.size_y;
		self.maxs_z = mi_max_z - mi_min_z;
		print("Picture mins/maxs: ", ftos(self.maxs_x), " and ", ftos(self.maxs_y), " should match\n");
		self.netname = strzone(strcat("gfx/", mi_shortname, "_radar.xpm"));
		if(!(self.count & 1))
		{
			self.cnt = fopen(self.netname, FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.tga"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.png"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_radar.jpg"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.tga"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.png"), FILE_READ);
			if(self.cnt < 0)
				self.cnt = fopen(strcat("gfx/", mi_shortname, "_mini.jpg"), FILE_READ);
			if(self.cnt >= 0)
			{
				fclose(self.cnt);

				print(self.netname, " already exists, aborting (you may want to specify --force)\n");
				RadarMap_Next();
				return;
			}
		}
		self.cnt = fopen(self.netname, FILE_WRITE);
		if(self.cnt < 0)
		{
			print("Error writing ", self.netname, "\n");
			remove(self);
			radarmapper = world;
			return;
		}
		print("Writing to ", self.netname, "...\n");
		fputs(self.cnt, "/* XPM */\n");
		fputs(self.cnt, "static char *RadarMap[] = {\n");
		fputs(self.cnt, "/* columns rows colors chars-per-pixel */\n");
		fputs(self.cnt, strcat("\"", ftos(self.size_x), " ", ftos(self.size_y), " 256 2\",\n"));
		for(i = 0; i < 256; ++i)
		{
			si = substring(doublehex, i*2, 2);
			fputs(self.cnt, strcat("\"", si, " c #", si, si, si, "\",\n"));
		}
		self.frame += 1;
		self.nextthink = time;
		sharpen_init(self.size_x);
	}
	else if(self.frame <= self.size_y)
	{
		// fill the sharpen buffer with this line
		sharpen_shift(self.size_x);
		i = self.count & 24;

		switch(i)
		{
			case 0:
			default:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Block(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 8:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Trace(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 16:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_Sample(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
			case 24:
				for(x = 0; x < self.size_x; ++x)
				{
					l = RadarMapAtPoint_LineBlock(self.mins_x + x * self.maxs_x, self.mins_y + (self.size_y - self.frame) * self.maxs_y, self.maxs_x, self.maxs_y, self.mins_z, self.maxs_z, self.size_z);
					sharpen_set(x, l);
				}
				break;
		}

		// do we have enough lines?
		if(self.frame >= 2)
		{
			// write a pixel line
			fputs(self.cnt, "\"");
			for(x = 0; x < self.size_x; ++x)
			{
				l = sharpen_get(x, self.ltime);
				fputs(self.cnt, substring(doublehex, 2 * floor(l * 256.0), 2));
			}
			if(self.frame == self.size_y)
				fputs(self.cnt, "\"\n");
			else
			{
				fputs(self.cnt, "\",\n");
				print(ftos(self.size_y - self.frame), " lines left\n");
			}
		}

		// is this the last line? then write back the missing line
		if(self.frame == self.size_y)
		{
			sharpen_shift(self.size_x);
			// write a pixel line
			fputs(self.cnt, "\"");
			for(x = 0; x < self.size_x; ++x)
			{
				l = sharpen_get(x, self.ltime);
				fputs(self.cnt, substring(doublehex, 2 * floor(l * 256.0), 2));
			}
			if(self.frame == self.size_y)
				fputs(self.cnt, "\"\n");
			else
			{
				fputs(self.cnt, "\",\n");
				print(ftos(self.size_y - self.frame), " lines left\n");
			}
		}

		self.frame += 1;
		self.nextthink = time;
	}
	else
	{
		// close the file
		fputs(self.cnt, "};\n");
		fclose(self.cnt);
		print("Finished. Please edit data/", self.netname, " with an image editing application and place it in the TGA format in the gfx folder.\n");
		RadarMap_Next();
	}
}

void RadarMap(float argc)
{
	if(radarmapper)
		return;
	float i;
	radarmapper = spawn();
	radarmapper.classname = "radarmapper";
	radarmapper.think = RadarMap_Think;
	radarmapper.nextthink = time;
	radarmapper.count = 8; // default to the --trace method, as it is faster now
	radarmapper.ltime = 1;
	radarmapper.size_x = 512;
	radarmapper.size_y = 512;
	radarmapper.size_z = 1;

	for(i = 1; i < argc; ++i)
	{
		if(argv(i) == "--force")
			radarmapper.count |= 1;
		else if(argv(i) == "--loop")
			radarmapper.count |= 2;
		else if(argv(i) == "--quit")
			radarmapper.count |= 4;
		else if(argv(i) == "--block")
		{
			radarmapper.count &~= 24;
		}
		else if(argv(i) == "--trace")
		{
			radarmapper.count &~= 24;
			radarmapper.count |= 8;
		}
		else if(argv(i) == "--sample")
		{
			radarmapper.count &~= 24;
			radarmapper.count |= 16;
		}
		else if(argv(i) == "--lineblock")
		{
			radarmapper.count |= 24;
		}
		else if(argv(i) == "--flags") // for the recursive call
		{
			++i;
			radarmapper.count = stof(argv(i));
		}
		else if(argv(i) == "--sharpen") // for the recursive call
		{
			++i;
			radarmapper.ltime = stof(argv(i));
		}
		else if(argv(i) == "--res") // resolution
		{
			++i;
			radarmapper.size_x = stof(argv(i));
			++i;
			radarmapper.size_y = stof(argv(i));
		}
		else if(argv(i) == "--qual") // quality multiplier
		{
			++i;
			radarmapper.size_z = stof(argv(i));
		}
		else
		{
			remove(radarmapper);
			radarmapper = world;
			print("Usage: sv_cmd radarmap [--force] [--loop] [--quit] [--block | --trace | --sample | --lineblock] [--sharpen N] [--res W H] [--qual Q]\n");
			print("The quality factor Q is roughly proportional to the time taken.\n");
			print("--trace supports no quality factor; its result should look like --block with infinite quality factor.\n");
			print("--block \n");
			return;
		}
	}

	print("Radarmap entity spawned.\n");
}

void BBox()
{
	print("Original size: ", ftos(world.absmin_x), " ", ftos(world.absmin_y), " ", ftos(world.absmin_z));
	print(" ", ftos(world.absmax_x), " ", ftos(world.absmax_y), " ", ftos(world.absmax_z), "\n");
	print("Currently set size: ", ftos(world.mins_x), " ", ftos(world.mins_y), " ", ftos(world.mins_z));
	print(" ", ftos(world.maxs_x), " ", ftos(world.maxs_y), " ", ftos(world.maxs_z), "\n");
	print("Solid bounding box size:");

	tracebox('1 0 0' * world.absmin_x,
	         '0 1 0' * world.absmin_y + '0 0 1' * world.absmin_z,
	         '0 1 0' * world.absmax_y + '0 0 1' * world.absmax_z,
	         '1 0 0' * world.absmax_x,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmin_x));
	else
		print(" ", ftos(trace_endpos_x));

	tracebox('0 1 0' * world.absmin_y,
	         '1 0 0' * world.absmin_x + '0 0 1' * world.absmin_z,
	         '1 0 0' * world.absmax_x + '0 0 1' * world.absmax_z,
	         '0 1 0' * world.absmax_y,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmin_y));
	else
		print(" ", ftos(trace_endpos_y));

	tracebox('0 0 1' * world.absmin_z,
	         '1 0 0' * world.absmin_x + '0 1 0' * world.absmin_y,
	         '1 0 0' * world.absmax_x + '0 1 0' * world.absmax_y,
	         '0 0 1' * world.absmax_z,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmin_z));
	else
		print(" ", ftos(trace_endpos_z));

	tracebox('1 0 0' * world.absmax_x,
	         '0 1 0' * world.absmin_y + '0 0 1' * world.absmin_z,
	         '0 1 0' * world.absmax_y + '0 0 1' * world.absmax_z,
	         '1 0 0' * world.absmin_x,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmax_x));
	else
		print(" ", ftos(trace_endpos_x));

	tracebox('0 1 0' * world.absmax_y,
	         '1 0 0' * world.absmin_x + '0 0 1' * world.absmin_z,
	         '1 0 0' * world.absmax_x + '0 0 1' * world.absmax_z,
	         '0 1 0' * world.absmin_y,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmax_y));
	else
		print(" ", ftos(trace_endpos_y));

	tracebox('0 0 1' * world.absmax_z,
	         '1 0 0' * world.absmin_x + '0 1 0' * world.absmin_y,
	         '1 0 0' * world.absmax_x + '0 1 0' * world.absmax_y,
	         '0 0 1' * world.absmin_z,
			 MOVE_WORLDONLY,
			 world);
	if(trace_startsolid)
		print(" ", ftos(world.absmax_z));
	else
		print(" ", ftos(trace_endpos_z));

	print("\n");
}

void EffectIndexDump()
{
	float d;
	float fh;
	string s;

	d = db_create();

	print("begin of effects list\n");
	db_put(d, "TE_GUNSHOT", "1"); print("effect TE_GUNSHOT is ", ftos(particleeffectnum("TE_GUNSHOT")), "\n");
	db_put(d, "TE_GUNSHOTQUAD", "1"); print("effect TE_GUNSHOTQUAD is ", ftos(particleeffectnum("TE_GUNSHOTQUAD")), "\n");
	db_put(d, "TE_SPIKE", "1"); print("effect TE_SPIKE is ", ftos(particleeffectnum("TE_SPIKE")), "\n");
	db_put(d, "TE_SPIKEQUAD", "1"); print("effect TE_SPIKEQUAD is ", ftos(particleeffectnum("TE_SPIKEQUAD")), "\n");
	db_put(d, "TE_SUPERSPIKE", "1"); print("effect TE_SUPERSPIKE is ", ftos(particleeffectnum("TE_SUPERSPIKE")), "\n");
	db_put(d, "TE_SUPERSPIKEQUAD", "1"); print("effect TE_SUPERSPIKEQUAD is ", ftos(particleeffectnum("TE_SUPERSPIKEQUAD")), "\n");
	db_put(d, "TE_WIZSPIKE", "1"); print("effect TE_WIZSPIKE is ", ftos(particleeffectnum("TE_WIZSPIKE")), "\n");
	db_put(d, "TE_KNIGHTSPIKE", "1"); print("effect TE_KNIGHTSPIKE is ", ftos(particleeffectnum("TE_KNIGHTSPIKE")), "\n");
	db_put(d, "TE_EXPLOSION", "1"); print("effect TE_EXPLOSION is ", ftos(particleeffectnum("TE_EXPLOSION")), "\n");
	db_put(d, "TE_EXPLOSIONQUAD", "1"); print("effect TE_EXPLOSIONQUAD is ", ftos(particleeffectnum("TE_EXPLOSIONQUAD")), "\n");
	db_put(d, "TE_TAREXPLOSION", "1"); print("effect TE_TAREXPLOSION is ", ftos(particleeffectnum("TE_TAREXPLOSION")), "\n");
	db_put(d, "TE_TELEPORT", "1"); print("effect TE_TELEPORT is ", ftos(particleeffectnum("TE_TELEPORT")), "\n");
	db_put(d, "TE_LAVASPLASH", "1"); print("effect TE_LAVASPLASH is ", ftos(particleeffectnum("TE_LAVASPLASH")), "\n");
	db_put(d, "TE_SMALLFLASH", "1"); print("effect TE_SMALLFLASH is ", ftos(particleeffectnum("TE_SMALLFLASH")), "\n");
	db_put(d, "TE_FLAMEJET", "1"); print("effect TE_FLAMEJET is ", ftos(particleeffectnum("TE_FLAMEJET")), "\n");
	db_put(d, "EF_FLAME", "1"); print("effect EF_FLAME is ", ftos(particleeffectnum("EF_FLAME")), "\n");
	db_put(d, "TE_BLOOD", "1"); print("effect TE_BLOOD is ", ftos(particleeffectnum("TE_BLOOD")), "\n");
	db_put(d, "TE_SPARK", "1"); print("effect TE_SPARK is ", ftos(particleeffectnum("TE_SPARK")), "\n");
	db_put(d, "TE_PLASMABURN", "1"); print("effect TE_PLASMABURN is ", ftos(particleeffectnum("TE_PLASMABURN")), "\n");
	db_put(d, "TE_TEI_G3", "1"); print("effect TE_TEI_G3 is ", ftos(particleeffectnum("TE_TEI_G3")), "\n");
	db_put(d, "TE_TEI_SMOKE", "1"); print("effect TE_TEI_SMOKE is ", ftos(particleeffectnum("TE_TEI_SMOKE")), "\n");
	db_put(d, "TE_TEI_BIGEXPLOSION", "1"); print("effect TE_TEI_BIGEXPLOSION is ", ftos(particleeffectnum("TE_TEI_BIGEXPLOSION")), "\n");
	db_put(d, "TE_TEI_PLASMAHIT", "1"); print("effect TE_TEI_PLASMAHIT is ", ftos(particleeffectnum("TE_TEI_PLASMAHIT")), "\n");
	db_put(d, "EF_STARDUST", "1"); print("effect EF_STARDUST is ", ftos(particleeffectnum("EF_STARDUST")), "\n");
	db_put(d, "TR_ROCKET", "1"); print("effect TR_ROCKET is ", ftos(particleeffectnum("TR_ROCKET")), "\n");
	db_put(d, "TR_GRENADE", "1"); print("effect TR_GRENADE is ", ftos(particleeffectnum("TR_GRENADE")), "\n");
	db_put(d, "TR_BLOOD", "1"); print("effect TR_BLOOD is ", ftos(particleeffectnum("TR_BLOOD")), "\n");
	db_put(d, "TR_WIZSPIKE", "1"); print("effect TR_WIZSPIKE is ", ftos(particleeffectnum("TR_WIZSPIKE")), "\n");
	db_put(d, "TR_SLIGHTBLOOD", "1"); print("effect TR_SLIGHTBLOOD is ", ftos(particleeffectnum("TR_SLIGHTBLOOD")), "\n");
	db_put(d, "TR_KNIGHTSPIKE", "1"); print("effect TR_KNIGHTSPIKE is ", ftos(particleeffectnum("TR_KNIGHTSPIKE")), "\n");
	db_put(d, "TR_VORESPIKE", "1"); print("effect TR_VORESPIKE is ", ftos(particleeffectnum("TR_VORESPIKE")), "\n");
	db_put(d, "TR_NEHAHRASMOKE", "1"); print("effect TR_NEHAHRASMOKE is ", ftos(particleeffectnum("TR_NEHAHRASMOKE")), "\n");
	db_put(d, "TR_NEXUIZPLASMA", "1"); print("effect TR_NEXUIZPLASMA is ", ftos(particleeffectnum("TR_NEXUIZPLASMA")), "\n");
	db_put(d, "TR_GLOWTRAIL", "1"); print("effect TR_GLOWTRAIL is ", ftos(particleeffectnum("TR_GLOWTRAIL")), "\n");
	db_put(d, "SVC_PARTICLE", "1"); print("effect SVC_PARTICLE is ", ftos(particleeffectnum("SVC_PARTICLE")), "\n");

	fh = fopen("effectinfo.txt", FILE_READ);
	while((s = fgets(fh)))
	{
		tokenize(s); // tokenize_console would hit the loop counter :(
		if(argv(0) == "effect")
		{
			if(db_get(d, argv(1)) != "1")
			{
				if(particleeffectnum(argv(1)) >= 0)
					print("effect ", argv(1), " is ", ftos(particleeffectnum(argv(1))), "\n");
				db_put(d, argv(1), "1");
			}
		}
	}
	print("end of effects list\n");

	db_close(d);
}

void make_mapinfo_Think()
{
	if(MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 0, 0, 1))
	{
		print("Done rebuiling mapinfos.\n");
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
		remove(self);
	}
	else
	{
		self.think = make_mapinfo_Think;
		self.nextthink = time;
	}
}

void GameCommand(string command)
{
	float argc;
	entity client, e;
	vector v;
	float entno, i, n;
	string s;
	argc = tokenize_console(command);

	if(argv(0) == "help" || argc == 0)
	{
		print("Usage: sv_cmd COMMAND..., where possible commands are:\n");
		print("  adminmsg clientnumber \"message\"\n");
		print("  teamstatus\n");
		print("  printstats\n");
		print("  make_mapinfo\n");
		print("  gametype dm|ctf|...\n");
		print("  savedb filename\n");
		print("  dumpdb filename\n");
		print("  loaddb filename\n");
		print("  allready\n");
		print("  effectindexdump\n");
		print("  radarmap [--force] [--quit | --loop] [sharpness]\n");
		print("  bbox\n");
		print("  cvar_changes\n");
		print("  find classname\n");
		GameCommand_Vote("help", world);
		GameCommand_Ban("help");
		GameCommand_Generic("help");
		return;
	}

	if(GameCommand_Vote(command, world))
		return;

	if(GameCommand_Ban(command))
		return;

	if(GameCommand_Generic(command))
		return;

	if(argv(0) == "printstats")
	{
		DumpStats(FALSE);
		return;
	}

	if(argv(0) == "make_mapinfo")
	{
		e = spawn();
		e.classname = "make_mapinfo";
		e.think = make_mapinfo_Think;
		e.nextthink = time;
		MapInfo_Enumerate();
		return;
	}

	if(argv(0) == "gotomap") if(argc == 2)
	{
		print(GotoMap(argv(1)), "\n");
		return;
	}

	if(argv(0) == "gametype") if(argc == 2)
	{
		float t, tsave;
		s = argv(1);
		t = MapInfo_Type_FromString(s);
		tsave = MapInfo_CurrentGametype();
		if(t)
		{
			MapInfo_SwitchGameType(t);
			MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
			if(MapInfo_count > 0)
			{
				bprint("Game type successfully switched to ", s, "\n");
			}
			else
			{
				bprint("Cannot use this game type: no map for it found\n");
				MapInfo_SwitchGameType(tsave);
				MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
			}
		}
		else
			bprint("Game type switch to ", s, " failed: this type does not exist!\n");
		return;
	}

	if(argv(0) == "adminmsg")
	if(argc == 3)
	{
		entno = stof(argv(1));

		if((entno < 1) | (entno > maxclients)) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}

		client = edict_num(entno);

		if(client.flags & FL_CLIENT)
		{
			centerprint_atprio(client, CENTERPRIO_ADMIN, strcat("^3", admin_name(), ":\n\n^7", argv(2)));
			sprint(client, strcat("\{1}\{13}^3", admin_name(), "^7: ", argv(2), "\n"));
			print("Message sent to ", client.netname, "\n");
		}
		else
			print("Client not found\n");

		return;
	}

	if(argv(0) == "savedb") if(argc == 2)
	{
		db_save(ServerProgsDB, argv(1));
		print("DB saved.\n");
		return;
	}

	if(argv(0) == "dumpdb") if(argc == 2)
	{
		db_dump(ServerProgsDB, argv(1));
		print("DB dumped.\n");
		return;
	}

	if(argv(0) == "loaddb") if(argc == 2)
	{
		db_close(ServerProgsDB);
		ServerProgsDB = db_load(argv(1));
		print("DB loaded.\n");
		return;
	}

	if (argv(0) == "nospectators")
	{
		blockSpectators = 1;
		local entity plr;
		FOR_EACH_CLIENT(plr) //give every spectator <g_maxplayers_spectator_blocktime> seconds time to become a player
		{
			if(plr.classname == "spectator" || plr.classname == "observer")
			{
				plr.spectatortime = time;
				sprint(plr, strcat("^7You have to become a player within the next ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
			}
		}
		bprint(strcat("^7All spectators will be automatically kicked when not joining the game after ", ftos(cvar("g_maxplayers_spectator_blocktime")), " seconds!\n"));
		return;
	}

	if (argv(0) == "lockteams")
	{
		if(teams_matter)
		{
			lockteams = 1;
			bprint("^1The teams are now locked.\n");
		}
		else
			bprint("That command can only be used in a team-based gamemode.\n");
		return;
	}

	if (argv(0) == "unlockteams")
	{
		if(teams_matter)
		{
			lockteams = 0;
			bprint("^1The teams are now unlocked.\n");
		}
		else
			bprint("That command can only be used in a team-based gamemode.\n");
		return;
	}
	if(argv(0) == "movetoteam")
	if(argc == 3 || argc == 4) {
// 	sv_cmd movetoteam  player_id  team_colour
// 	sv_cmd movetoteam  player_id  team_colour  type_of_move

// 	type of move
// 	0 (00) automove centerprint, admin message
// 	1 (01) automove centerprint, no admin message
// 	2 (10) no centerprint, admin message
// 	3 (11) no centerprint, no admin message

		if(!teams_matter) {  // death match
			print("Currently not playing a team game\n");
			return;
		}

		entno = stof(argv(1));

		// player_id is out of range
		if((entno < 1) | (entno > maxclients)) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}

			client = edict_num(entno);

		// player entity is not a client
		if not(client.flags & FL_CLIENT) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}

		// find the team to move the player to
		float team_colour;

		team_colour = ColourToNumber(argv(2));

		if(team_colour == client.team) {  // player already on the team
			print("Player ", argv(1), " (", client.netname, ") is already on the ", ColoredTeamName(client.team), "\n");
			return;
		} else if(team_colour == 0)  // auto team
			team_colour = NumberToTeamNumber(FindSmallestTeam(client, FALSE));

		switch(team_colour) {
			case COLOR_TEAM1:
				if(c1 == -1) {
					print("Sorry, there isn't a red team\n");
					return;
		}
			break;

			case COLOR_TEAM2:
				if(c2 == -1) {
					print("Sorry, there isn't a blue team\n");
		return;
	}
			break;

			case COLOR_TEAM3:
				if(c3 == -1) {
					print("Sorry, there isn't a yellow team\n");
					return;
				}
			break;

			case COLOR_TEAM4:
				if(c4 == -1) {
					print("Sorry, there isn't a pink team\n");
					return;
				}
			break;

			default:
				print("Sorry, team ", argv(2), " doesn't exist\n");
				return;
		}
		print("Player ", argv(1), " (", client.netname, ") has been moved to the ", ColoredTeamName(team_colour), "\n");

		MoveToTeam(client, team_colour, 6, stof(argv(3)));

		return;
	}
	if (argv(0) == "teamstatus")
	{
		Score_NicePrint(world);
		return;
	}
	if (argv(0) == "allready")
	{
		ReadyRestart();
		return;
	}
	if (argv(0) == "effectindexdump")
	{
		EffectIndexDump();
		return;
	}
	if (argv(0) == "radarmap")
	{
		RadarMap(argc);
		return;
	}
	if (argv(0) == "bbox")
	{
		BBox();
		return;
	}
	if (argv(0) == "cvar_changes")
	{
		print(cvar_changes);
		return;
	}
	if (argv(0) == "find") if(argc == 2)
	{
		for(client = world; (client = find(client, classname, argv(1))); )
			print(etos(client), "\n");
		return;
	}
	if (argv(0) == "records")
	{
		for (i = 0; i < 10; ++i)
			print(records_reply[i]);
		return;
	}
	if (argv(0) == "rankings")
	{
		strunzone(rankings_reply);
		rankings_reply = strzone(getrankings());
		print(rankings_reply);
		return;
	}

	if(argv(0) == "cointoss")
	{
		bprint("^3Throwing coin... Result: ");
		if (random() > 0.5)
			bprint("^1heads ^3!\n");
		else
			bprint("^1tails ^3!\n");
		return;
	}

	if(argv(0) == "__FORCE_READY_RESTART")
	{
		reset_map(FALSE);
		return;
	}

	if(argv(0) == "debug_shotorg")
	{
		debug_shotorg = stov(argv(1));
		return;
	}

	if(argv(0) == "gettaginfo") if(argc >= 4)
	{
		e = spawn();
		if(argv(1) == "w")
			setmodel(e, (nextent(world)).weaponentity.model);
		else
			setmodel(e, argv(1));
		e.frame = stof(argv(2));
		i = gettagindex(e, argv(3));
		if(i)
		{
			v = gettaginfo(e, i);
			print("model ", e.model, " frame ", ftos(e.frame), " tag ", argv(3));
			print(" index = ", ftos(i));
			print(" vector = ", ftos(v_x), " ", ftos(v_y), " ", ftos(v_z), "\n");
			if(argc >= 6)
			{
				v_y = -v_y;
				localcmd(strcat(argv(4), vtos(v), argv(5), "\n"));
			}
		}
		else
			print("bone not found\n");
		remove(e);
		return;
	}

	if(argv(0) == "time")
	{
		print("time = ", ftos(time), "\n");
		print("frame start = ", ftos(gettime(GETTIME_FRAMESTART)), "\n");
		print("realtime = ", ftos(gettime(GETTIME_REALTIME)), "\n");
		print("hires = ", ftos(gettime(GETTIME_HIRES)), "\n");
		print("uptime = ", ftos(gettime(GETTIME_UPTIME)), "\n");
		print("localtime = ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n");
		print("gmtime = ", strftime(FALSE, "%a %b %e %H:%M:%S %Z %Y"), "\n");
		return;
	}

	if(argv(0) == "tracebug")
	{
		print("TEST CASE. If this returns the runaway loop counter error, possibly everything is oaky.\n");
		for(;;)
		{
			vector org, delta, start, end, p, q, q0, pos;
			float safe, unsafe, dq, dqf;

			org = world.mins;
			delta = world.maxs - world.mins;

			start_x = org_x + random() * delta_x;
			start_y = org_y + random() * delta_y;
			start_z = org_z + random() * delta_z;

			end_x = org_x + random() * delta_x;
			end_y = org_y + random() * delta_y;
			end_z = org_z + random() * delta_z;

			start = stov(vtos(start));
			end = stov(vtos(end));

			tracebox(start, PL_MIN, PL_MAX, end, MOVE_NOMONSTERS, world);
			if(!trace_startsolid)
			{
				p = trace_endpos;
				tracebox(p, PL_MIN, PL_MAX, p, MOVE_NOMONSTERS, world);
				if(trace_startsolid || trace_fraction == 1)
				{
					rint(42); // do an engine breakpoint on VM_rint so you can get the trace that errnoeously returns startsolid
					tracebox(start, PL_MIN, PL_MAX, end, MOVE_NOMONSTERS, world);
					tracebox(p, PL_MIN, PL_MAX, q, MOVE_NOMONSTERS, world);

					if(trace_startsolid)
					{
						// how much do we need to back off?
						safe = 1;
						unsafe = 0;
						for(;;)
						{
							pos = p * (1 - (safe + unsafe) * 0.5) + start * ((safe + unsafe) * 0.5);
							tracebox(pos, PL_MIN, PL_MAX, pos, MOVE_NOMONSTERS, world);
							if(trace_startsolid)
							{
								if((safe + unsafe) * 0.5 == unsafe)
									break;
								unsafe = (safe + unsafe) * 0.5;
							}
							else
							{
								if((safe + unsafe) * 0.5 == safe)
									break;
								safe = (safe + unsafe) * 0.5;
							}
						}

						print("safe distance to back off: ", ftos(safe * vlen(p - start)), "qu\n");
						print("unsafe distance to back off: ", ftos(unsafe * vlen(p - start)), "qu\n");

						tracebox(p, PL_MIN + '0.1 0.1 0.1', PL_MAX - '0.1 0.1 0.1', p, MOVE_NOMONSTERS, world);
						if(trace_startsolid)
							print("trace_endpos much in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
						else
							print("trace_endpos just in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
						break;
					}

					q0 = p;
					dq = 0;
					dqf = 1;
					for(;;)
					{
						q = p + normalize(end - p) * (dq + dqf);
						if(q == q0)
							break;
						tracebox(p, PL_MIN, PL_MAX, q, MOVE_NOMONSTERS, world);
						if(trace_startsolid)
							error("THIS ONE cannot happen");
						if(trace_fraction > 0)
							dq += dqf * trace_fraction;
						dqf *= 0.5;
						q0 = q;
					}
					if(dq > 0)
					{
						print("trace_endpos still before solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(p), "\n");
						print("could go ", ftos(dq), " units further to ", vtos(q), "\n");
						break;
					}
				}
			}
		}
	}

	if(argv(0) == "tracebug2")
	{
		e = nextent(world);
		float f;
		vector vv, dv;
		tracebox(e.origin + '0 0 32', e.mins, e.maxs, e.origin + '0 0 -1024', MOVE_NORMAL, e);
		vv = trace_endpos;
		if(trace_fraction == 1)
		{
			print("not above ground, aborting\n");
			return;
		}
		f = 0;
		for(i = 0; i < 100000; ++i)
		{
			dv = randomvec();
			if(dv_z > 0)
				dv = -1 * dv;
			tracebox(vv, e.mins, e.maxs, vv + dv, MOVE_NORMAL, e);
			if(trace_startsolid)
				print("bug 1\n");
			if(trace_fraction == 1)
			if(dv_z < f)
			{
				print("bug 2: ", ftos(dv_x), " ", ftos(dv_y), " ", ftos(dv_z));
				print(" (", ftos(asin(dv_z / vlen(dv)) * 180 / M_PI), " degrees)\n");
				f = dv_z;
			}
		}
		print("highest possible dist: ", ftos(f), "\n");
		return;
	}

	if(argv(0) == "tracewalk")
	{
		e = nextent(world);
		if(tracewalk(e, stov(argv(1)), e.mins, e.maxs, stov(argv(2)), MOVE_NORMAL))
			print("can walk\n");
		else
			print("cannot walk\n");
		return;
	}

	if(argv(0) == "onslaught_updatelinks")
	{
		onslaught_updatelinks();
		print("ONS links updated\n");
		return;
	}

	if(argv(0) == "bot_cmd")
	{
		local entity bot;

		if(argv(1) == "help")
		{
			if(argc==2)
			{
				bot_list_commands();
				print("\nsv_cmd bot_cmd reset          #Clear the cmd queues of all bots\n");
				print("sv_cmd bot_cmd load <file>    #Load script file\n");
				print("\nUse sv_cmd bot_cmd help <command> for more\n\n");
				return;
			}

			bot_cmdhelp(argv(2));
			return;
		}

		// Clear all bot queues
		if(argv(1) == "reset")
		{
			bot_resetqueues();
			return;
		}

		// Load cmds from file
		if(argv(1) == "load" && argc == 3)
		{
			float fh;
			fh = fopen(argv(2), FILE_READ);
			if(fh < 0)
			{
				print("cannot open the file\n");
				return;
			}

			i = 0;
			while((s = fgets(fh)))
			{
				argc = tokenize_console(s);

				if(argc >= 3 && argv(0) == "sv_cmd" && argv(1) == "bot_cmd")
				{
					// let's start at token 2 so we can skip sv_cmd bot_cmd
					bot = find_bot_by_number(stof(argv(2)));
					if(bot == world)
						bot = find_bot_by_name(argv(2));
					if(bot)
						bot_queuecommand(bot, strcat(argv(3), " ", argv(4)));
				}
				else
					localcmd(strcat(s, "\n"));

				++i;
			}

			print(ftos(i), " commands read\n");

			fclose(fh);

			return;
		}

		if(argc < 3)
		{
			print("Usage: sv_cmd bot_cmd <bot name or number> <command> [argument]\n");
			print("Examples: bot_cmd <id> cc \"say something\"\n");
			print("          bot_cmd <id> presskey jump\n");
			print("          .. or sv_cmd bot_cmd help <command> for more\n");
			return;
		}

		bot = find_bot_by_number(stof(argv(1)));
		if(bot == world)
			bot = find_bot_by_name(argv(1));

		if(bot)
			bot_queuecommand(bot, strcat(argv(2), " ", argv(3)));
		else
			print(strcat("Error: Unable to find a bot with the name or number '",argv(1),"'\n"));

		return;
	}

	if(argv(0) == "playerdemo")
	{
		if(argv(1) == "read")
		{
			entno = stof(argv(2));
			if((entno < 1) | (entno > maxclients)) {
				print("Player ", argv(2), " doesn't exist\n");
				return;
			}
			client = edict_num(entno);
			if(clienttype(client) != CLIENTTYPE_BOT) {
				print("Player ", client.netname, " is not a bot\n");
				return;
			}
			self = client;
			playerdemo_open_read(argv(3));
			return;
		}
		else if(argv(1) == "write")
		{
			entno = stof(argv(2));
			if((entno < 1) | (entno > maxclients)) {
				print("Player ", argv(2), " doesn't exist\n");
				return;
			}
			client = edict_num(entno);
			self = client;
			playerdemo_open_write(argv(3));
			return;
		}
		else if(argv(1) == "auto_read_and_write")
		{
			s = argv(2);
			n = stof(argv(3));
			cvar_set("bot_number", ftos(n));
			localcmd("wait; wait; wait\n");
			for(i = 0; i < n; ++i)
				localcmd("sv_cmd playerdemo read ", ftos(i+2), " ", s, ftos(i+1), "\n");
			localcmd("sv_cmd playerdemo write 1 ", ftos(n+1), "\n");
			return;
		}
		else if(argv(1) == "auto_read")
		{
			s = argv(2);
			n = stof(argv(3));
			cvar_set("bot_number", ftos(n));
			localcmd("wait; wait; wait\n");
			for(i = 0; i < n; ++i)
				localcmd("sv_cmd playerdemo read ", ftos(i+2), " ", s, ftos(i+1), "\n");
			return;
		}
	}

	if(argv(0) == "anticheat")
	{
		entno = stof(argv(1));
		if((entno < 1) | (entno > maxclients)) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}
		client = edict_num(entno);
		if(clienttype(client) != CLIENTTYPE_REAL && clienttype(client) != CLIENTTYPE_BOT) {
			print("Player ", client.netname, " is not active\n");
			return;
		}
		self = client;
		anticheat_report();
		return;
	}

	if(argv(0) == "defer_clear")
	if(argc == 2)
	{
		entno = stof(argv(1));

		// player_id is out of range
		if((entno < 1) | (entno > maxclients)) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}

		client = edict_num(entno);

		if not(client.flags & FL_CLIENT) {
			print("Player ", argv(1), " doesn't exist\n");
			return;
		}

		if(clienttype(client) == CLIENTTYPE_BOT) {
			print("Player ", argv(1), " (", client.netname, ") is a bot\n");
			return;
		}

		stuffcmd(client, "defer clear\n");
		print("defer clear stuffed to ", argv(1), " (", client.netname, ")\n");
		return;
	}

	if(argv(0) == "defer_clear_all")
	{
		FOR_EACH_CLIENTSLOT(client)
			GameCommand(strcat("defer_clear ", ftos(num_for_edict(client))));	

		return;
	}
	if(argv(0) == "delrec")
	{
		race_DeleteTime(stof(argv(1)));
		return;
	}

	print("Invalid command. For a list of supported commands, try sv_cmd help.\n");
}

