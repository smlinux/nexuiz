string GotoMap(string m);

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
			print("Usage: sv_cmd radarmap [--force] [--loop] [--quit] [--block | --trace | --sample] [--sharpen N] [--res W H] [--qual Q]\n");
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
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0, (g_maplist_allow_hidden ? MAPINFO_FLAG_HIDDEN : 0) | MAPINFO_FLAG_FORBIDDEN, 0);
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
	float entno, i;
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

	if(argv(0) == "warp") if(argc == 2) if(cvar("g_campaign"))
	{
		CampaignLevelWarp(stof(argv(1)));
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
		string s;
		s = argv(1);
		t = MapInfo_Type_FromString(s);
		tsave = MapInfo_CurrentGametype();
		if(t)
		{
			MapInfo_SwitchGameType(t);
			MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0, MAPINFO_FLAG_HIDDEN | MAPINFO_FLAG_FORBIDDEN, 0);
			if(MapInfo_count > 0)
			{
				bprint("Game type successfully switched to ", s, "\n");
				MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0, (g_maplist_allow_hidden ? MAPINFO_FLAG_HIDDEN : 0) | MAPINFO_FLAG_FORBIDDEN, 0);
			}
			else
			{
				bprint("Cannot use this game type: no map for it found\n");
				MapInfo_SwitchGameType(tsave);
				MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), 0, (g_maplist_allow_hidden ? MAPINFO_FLAG_HIDDEN : 0) | MAPINFO_FLAG_FORBIDDEN, 0);
			}
		}
		else
			bprint("Game type switch to ", s, " failed: this type does not exist!\n");
		return;
	}

	if(argv(0) == "adminmsg") if(argc == 3)
	{
		entno = stof(argv(1));
		client = world;
		if(entno <= maxclients)
			client = edict_num(entno);
		if(client.flags & FL_CLIENT)
		{
			centerprint_atprio(client, CENTERPRIO_ADMIN, strcat("^3SERVER ADMIN:\n\n^7", argv(2)));
			sprint(client, strcat("\{1}\{13}^3SERVER ADMIN^7: ", argv(2), "\n"));
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
	if (argv(0) == "movetoteam") if(argc == 3)
	{
		entno = stof(argv(1));
		client = world;
		if(entno <= maxclients)
			client = edict_num(entno);
		if(client.flags & FL_CLIENT)
		{
			float lt;
			lt = lockteams;
			lockteams = 0;

			self = client;
			SV_ParseClientCommand(strcat("selectteam ", argv(2)));

			lockteams = lt;
		}
		else
			print("Client not found\n");
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
		strunzone(records_reply);
		records_reply = strzone(getrecords());
		print(records_reply);
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
			vector org, delta, start, end, p;

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
				if(trace_startsolid)
				{
					rint(42); // do an engine breakpoint on VM_rint so you can get the trace that errnoeously returns startsolid
					tracebox(start, PL_MIN, PL_MAX, end, MOVE_NOMONSTERS, world);
					tracebox(p, PL_MIN, PL_MAX, p, MOVE_NOMONSTERS, world);

					tracebox(p, PL_MIN + '0.1 0.1 0.1', PL_MAX - '0.1 0.1 0.1', p, MOVE_NOMONSTERS, world);
					if(trace_startsolid)
						error(strcat("trace_endpos much in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(trace_endpos), "\n"));
					else
						error(strcat("trace_endpos just in solid when tracing from ", vtos(start), " to ", vtos(end), " endpos ", vtos(trace_endpos), "\n"));
				}
			}
		}
	}

	if(argv(0) == "bot_cmd")
	{
		if(argv(1) == "help")
		{
			if(argc==2)
			{
				bot_list_commands();
				print("\nUse sv_cmd bot_cmd help <command> for more\n");
				return;
			}

			bot_cmdhelp(argv(2));
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

		local entity bot;
		bot = find_bot_by_name(argv(1));
		if(bot==world)
			bot = find_bot_by_number(stof(argv(1)));

		if(bot)
		{
			if(argc==4)
				bot_queuecommand(bot,argv(2),argv(3));
			else
				bot_queuecommand(bot,argv(2),"");
		}
		else
			print(strcat("Error: Unable to find a bot with the name or number '",argv(1),"'\n"));
        	return;
	}

	print("Invalid command. For a list of supported commands, try sv_cmd help.\n");
}

