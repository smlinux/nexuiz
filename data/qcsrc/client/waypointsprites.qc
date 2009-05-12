float waypointsprite_initialized;
float waypointsprite_fadedistance;
float waypointsprite_normdistance;
float waypointsprite_minscale;
float waypointsprite_minalpha;
float waypointsprite_distancealphaexponent;
float waypointsprite_timealphaexponent;
float waypointsprite_scale;

.float rule;
.string netname; // primary picture
.string netname2; // secondary picture
.string netname3; // tertiary picture
.float team; // team that gets netname2
.float lifetime;
.float fadetime;
.float maxdistance;
.float hideflags;
.float spawntime;

vector SPRITE_SIZE = '128 32 0';
vector SPRITE_HOTSPOT = '64 32 0';

void drawrotpic(vector org, float rot, string pic, vector sz, vector hotspot, vector rgb, float a, float f)
{
	vector v1, v2, v3, v4;

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the corners
	v1 = hotspot;
	v2 = hotspot + '1 0 0' * sz_x;
	v3 = hotspot + '1 0 0' * sz_x + '0 1 0' * sz_y;
	v4 = hotspot                  + '0 1 0' * sz_y;

	// rotate them, and make them absolute
	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	v1 = rotate(v1, rot) + org;
	v2 = rotate(v2, rot) + org;
	v3 = rotate(v3, rot) + org;
	v4 = rotate(v4, rot) + org;

	// draw them
	R_BeginPolygon(pic, f);
	R_PolygonVertex(v1, '0 0 0', rgb, a);
	R_PolygonVertex(v2, '1 0 0', rgb, a);
	R_PolygonVertex(v3, '1 1 0', rgb, a);
	R_PolygonVertex(v4, '0 1 0', rgb, a);
	R_EndPolygon();
}

void Draw_WaypointSprite()
{
	string spriteimage;
	float t;

	if(self.lifetime)
		self.alpha = pow(bound(0, (self.fadetime - time) / self.lifetime, 1), waypointsprite_timealphaexponent);
	else
		self.alpha = 1;

	if(self.hideflags & 2)
		return; // radar only

	if(cvar("cl_hidewaypoints") >= 2)
		return;

	if(self.hideflags & 1)
		if(cvar("cl_hidewaypoints"))
			return; // fixed waypoint

	InterpolateOrigin_Do();

	t = GetPlayerColor(player_localentnum - 1) + 1;

	spriteimage = "";

	// choose the sprite
	switch(self.rule)
	{
		case SPRITERULE_DEFAULT:
			if(self.team)
			{
				if(self.team == t)
					spriteimage = self.netname;
				else
					spriteimage = "";
			}
			else
				spriteimage = self.netname;
			break;
		case SPRITERULE_TEAMPLAY:
			if(t == COLOR_SPECTATOR + 1)
				spriteimage = self.netname3;
			else if(self.team == t)
				spriteimage = self.netname2;
			else
				spriteimage = self.netname;
			break;
		default:
			error("Invalid waypointsprite rule!");
			break;
	}

	if(spriteimage == "")
		return;
	
	float dist;
	dist = vlen(self.origin - view_origin);
	
	float a;
	a = self.alpha;

	if(self.maxdistance > waypointsprite_normdistance)
		a *= pow(bound(0, (self.maxdistance - dist) / (self.maxdistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent);
	else if(self.maxdistance > 0)
		a *= pow(bound(0, (waypointsprite_fadedistance - dist) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1), waypointsprite_distancealphaexponent) * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;

	if(a <= 0)
		return;
	
	// draw the sprite image
	vector o;
	float rot;
	o = project_3d_to_2d(self.origin);
	rot = 0;

	if(o_z < 0 || o_x < 0 || o_y < 0 || o_x > vid_conwidth || o_y > vid_conheight)
	{
		// scale it to be just in view
		vector d;
		float f1, f2;

		// get the waypoint angle vector
		d_x = view_right * (self.origin - view_origin) * vid_conwidth / vid_width;
		d_y = -view_up * (self.origin - view_origin) * vid_conheight / (vid_height * vid_pixelheight);
		d_z = 0;
		
		//d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;

		if(cvar("v_flipped"))
			d_x = -d_x;

		f1 = d_x / vid_conwidth;
		f2 = d_y / vid_conheight;

		if(max(f1, -f1) > max(f2, -f2))
		{
			if(f1 > 0)
			{
				// RIGHT edge
				d = d * (0.5 / f1);
				rot = 3;
			}
			else
			{
				// LEFT edge
				d = d * (-0.5 / f1);
				rot = 1;
			}
		}
		else
		{
			if(f2 > 0)
			{
				// BOTTOM edge
				d = d * (0.5 / f2);
				rot = 0;
			}
			else
			{
				// TOP edge
				d = d * (-0.5 / f2);
				rot = 2;
			}
		}

		o = d + '0.5 0 0' * vid_conwidth + '0 0.5 0' * vid_conheight;
	}
	o_z = 0;

	float vidscale;
	vidscale = max(vid_conwidth / vid_width, vid_conheight / vid_height);

	t = stof(db_get(tempdb, strcat("/spriteframes/", spriteimage)));
	if(t == 0)
		spriteimage = strcat("models/sprites/", spriteimage);
	else
		spriteimage = strcat("models/sprites/", spriteimage, "_frame", ftos(mod(floor((max(0, time - self.spawntime)) * 2), t)));

	drawrotpic(o, rot * 90 * DEG2RAD, spriteimage, SPRITE_SIZE * waypointsprite_scale * vidscale, SPRITE_HOTSPOT * waypointsprite_scale * vidscale, '1 1 1', a, DRAWFLAG_MIPMAP);
}

void Ent_RemoveWaypointSprite()
{
	if(self.netname)
		strunzone(self.netname);
	if(self.netname2)
		strunzone(self.netname2);
	if(self.netname3)
		strunzone(self.netname3);
}

void Ent_WaypointSprite()
{
	float sendflags, f;
	sendflags = ReadByte();

	if(!self.spawntime)
		self.spawntime = time;

	self.draw2d = Draw_WaypointSprite;

	InterpolateOrigin_Undo();

	if(sendflags & 64)
	{
		// unfortunately, this needs to be exact (for the 3D display)
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}

	if(sendflags & 1)
	{
		self.team = ReadByte();
		self.rule = ReadByte();
	}

	if(sendflags & 2)
	{
		if(self.netname)
			strunzone(self.netname);
		self.netname = strzone(ReadString());
	}

	if(sendflags & 4)
	{
		if(self.netname2)
			strunzone(self.netname2);
		self.netname2 = strzone(ReadString());
	}

	if(sendflags & 8)
	{
		if(self.netname3)
			strunzone(self.netname3);
		self.netname3 = strzone(ReadString());
	}

	if(sendflags & 16)
	{
		self.lifetime = ReadCoord();
		self.fadetime = ReadCoord();
		self.maxdistance = ReadShort();
		self.hideflags = ReadByte();
	}

	if(sendflags & 32)
	{
		f = ReadByte();
		self.teamradar_icon = (f & 0x7F);
		if(f & 0x80)
		{
			self.(teamradar_times[self.teamradar_time_index]) = time;
			self.teamradar_time_index = mod(self.teamradar_time_index + 1, MAX_TEAMRADAR_TIMES);
		}
		self.teamradar_color_x = ReadByte() / 255.0;
		self.teamradar_color_y = ReadByte() / 255.0;
		self.teamradar_color_z = ReadByte() / 255.0;
	}

	InterpolateOrigin_Note();

	self.entremove = Ent_RemoveWaypointSprite;
}

void WaypointSprite_Load()
{
	waypointsprite_fadedistance = vlen(world.maxs - world.mins);
	waypointsprite_normdistance = cvar("g_waypointsprite_normdistance");
	waypointsprite_minscale = cvar("g_waypointsprite_minscale");
	waypointsprite_minalpha = cvar("g_waypointsprite_minalpha");
	waypointsprite_distancealphaexponent = cvar("g_waypointsprite_distancealphaexponent");
	waypointsprite_timealphaexponent = cvar("g_waypointsprite_timealphaexponent");
	waypointsprite_scale = cvar("g_waypointsprite_scale");
	if(!waypointsprite_scale)
		waypointsprite_scale = 1.0;

	if(!waypointsprite_initialized)
	{
		float dh, n, i, o, f;
		string s, sname, sframes;
		dh = search_begin("models/sprites/*_frame*.tga", FALSE, FALSE);
		n = search_getsize(dh);
		for(i = 0; i < n; ++i)
		{
			s = search_getfilename(dh, i);
			if(substring(s, 0, 15) != "models/sprites/")
				continue;
			if(substring(s, strlen(s) - 4, 4) != ".tga")
				continue;
			s = substring(s, 15, strlen(s) - 19);

			o = strstrofs(s, "_frame", 0);
			sname = strcat("/spriteframes/", substring(s, 0, o));
			sframes = substring(s, o + 6, strlen(s) - o - 6);
			f = stof(sframes) + 1;
			db_put(tempdb, sname, ftos(max(f, stof(db_get(tempdb, sname)))));
		}
		search_end(dh);
	}
	waypointsprite_initialized = 1;
}
