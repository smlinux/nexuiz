float waypointsprite_initialized;
float waypointsprite_fadedistance;
float waypointsprite_normdistance;
float waypointsprite_minscale;
float waypointsprite_minalpha;
float waypointsprite_distancealphaexponent;
float waypointsprite_timealphaexponent;
float waypointsprite_scale;
float waypointsprite_edgefadealpha;
float waypointsprite_edgefadescale;
float waypointsprite_edgefadedistance;
float waypointsprite_crosshairfadealpha;
float waypointsprite_crosshairfadescale;
float waypointsprite_crosshairfadedistance;
float waypointsprite_distancefadealpha;
float waypointsprite_distancefadescale;
float waypointsprite_distancefadedistance;
float waypointsprite_alpha;

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
.float health;
.float build_started;
.float build_starthealth;
.float build_finished;

vector SPRITE_SIZE = '288 36 0';
vector SPRITE_HOTSPOT = '144 36 0';
float SPRITE_HEALTHBAR_WIDTH = 144;
float SPRITE_HEALTHBAR_HEIGHT = 9;
float SPRITE_HEALTHBAR_MARGIN = 6;
float SPRITE_HEALTHBAR_BORDER = 2;
float SPRITE_HEALTHBAR_BORDERALPHA = 1;
float SPRITE_HEALTHBAR_HEALTHALPHA = 0.5;

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

void drawquad(vector o, vector ri, vector up, string pic, vector rgb, float a, float f)
{
	R_BeginPolygon(pic, f);
	R_PolygonVertex(o, '0 0 0', rgb, a);
	R_PolygonVertex(o + ri, '1 0 0', rgb, a);
	R_PolygonVertex(o + up + ri, '1 1 0', rgb, a);
	R_PolygonVertex(o + up, '0 1 0', rgb, a);
	R_EndPolygon();
}

void drawhealthbar(vector org, float rot, float h, vector sz, vector hotspot, float width, float height, float margin, float border, float align, vector rgb, float a, vector hrgb, float ha, float f)
{
	vector o, ri, up;
	float owidth; // outer width

	hotspot = -1 * hotspot;

	// hotspot-relative coordinates of the healthbar corners
	o = hotspot;
	ri = '1 0 0';
	up = '0 1 0';
	
	rot = -rot; // rotate by the opposite angle, as our coordinate system is reversed
	o = rotate(o, rot) + org;
	ri = rotate(ri, rot);
	up = rotate(up, rot);

	owidth = width + 2 * border;
	o = o - up * (margin + border + height) + ri * (sz_x - owidth) * 0.5;

	drawquad(o - up * border,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o + up * height,                               ri * owidth,    up * border, "", rgb,  a,  f);
	drawquad(o,                                             ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (owidth - border),                    ri * border,    up * height, "", rgb,  a,  f);
	drawquad(o + ri * (border + align * ((1 - h) * width)), ri * width * h, up * height, "", hrgb, ha, f);
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
	a = self.alpha * sbar_alpha_fg;

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
		/*
		d_x = view_right * (self.origin - view_origin) * vid_conwidth / vid_width;
		d_y = -view_up * (self.origin - view_origin) * vid_conheight / (vid_height * vid_pixelheight);
		d_z = 0;
		*/
		
		d = o - '0.5 0 0' * vid_conwidth - '0 0.5 0' * vid_conheight;

		/*
		if(cvar("v_flipped"))
			d_x = -d_x;
		*/

		f1 = d_x / vid_conwidth;
		f2 = d_y / vid_conheight;

		if(max(f1, -f1) > max(f2, -f2))
		{
			if(d_z * f1 > 0)
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
			if(d_z * f2 > 0)
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

	float edgedistance_min, crosshairdistance;
	edgedistance_min = min4(o_y, o_x,vid_conwidth - o_x, vid_conheight - o_y);

	crosshairdistance = sqrt( pow(o_x - vid_conwidth/2, 2) + pow(o_y - vid_conheight/2, 2) );

	t = waypointsprite_scale * vidscale;
	a *= waypointsprite_alpha;

	{
		a = a * (1 - (1 - waypointsprite_distancefadealpha) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_distancefadescale) * (bound(0, dist/waypointsprite_distancefadedistance, 1)));
	}
	if (edgedistance_min < waypointsprite_edgefadedistance) {
		a = a * (1 - (1 - waypointsprite_edgefadealpha) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_edgefadescale) * (1 - bound(0, edgedistance_min/waypointsprite_edgefadedistance, 1)));
	}
	if(crosshairdistance < waypointsprite_crosshairfadedistance) {
		a = a * (1 - (1 - waypointsprite_crosshairfadealpha) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
		t = t * (1 - (1 - waypointsprite_crosshairfadescale) * (1 - bound(0, crosshairdistance/waypointsprite_crosshairfadedistance, 1)));
	}
	drawrotpic(o, rot * 90 * DEG2RAD, spriteimage, SPRITE_SIZE * t, SPRITE_HOTSPOT * t, '1 1 1', a, DRAWFLAG_MIPMAP);

	if(self.build_finished)
	{
		if(time < self.build_finished + 0.25)
		{
			if(time < self.build_started)
				self.health = self.build_starthealth;
			else if(time < self.build_finished)
				self.health = (time - self.build_started) / (self.build_finished - self.build_started) * (1 - self.build_starthealth) + self.build_starthealth;
			else
				self.health = 1;
		}
		else
			self.health = -1;
	}

	if(self.health >= 0)
	{
		float align;
		if(self.build_finished)
			align = 0.5;
		else
			align = 0;
		drawhealthbar(o, rot * 90 * DEG2RAD, self.health, SPRITE_SIZE * t, SPRITE_HOTSPOT * t, SPRITE_HEALTHBAR_WIDTH * t, SPRITE_HEALTHBAR_HEIGHT * t, SPRITE_HEALTHBAR_MARGIN * t, SPRITE_HEALTHBAR_BORDER * t, align, self.teamradar_color, a * SPRITE_HEALTHBAR_BORDERALPHA, self.teamradar_color, a * SPRITE_HEALTHBAR_HEALTHALPHA, DRAWFLAG_NORMAL);
	}
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
	float sendflags, f, t;
	sendflags = ReadByte();

	if(!self.spawntime)
		self.spawntime = time;

	self.draw2d = Draw_WaypointSprite;

	InterpolateOrigin_Undo();

	if(sendflags & 0x80)
	{
		t = ReadByte();
		if(t < 192)
		{
			self.health = t / 191.0;
			self.build_finished = 0;
		}
		else
		{
			t = (t - 192) * 256 + ReadByte();
			self.build_started = servertime;
			if(self.build_finished)
				self.build_starthealth = bound(0, self.health, 1);
			else
				self.build_starthealth = 0;
			self.build_finished = servertime + t / 32;
			//print("build: ", ftos(self.build_finished - self.build_started), "\n");
		}
	}
	else
	{
		self.health = -1;
		self.build_finished = 0;
	}

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
	waypointsprite_fadedistance = vlen(mi_max - mi_min);
	waypointsprite_normdistance = cvar("g_waypointsprite_normdistance");
	waypointsprite_minscale = cvar("g_waypointsprite_minscale");
	waypointsprite_minalpha = cvar("g_waypointsprite_minalpha");
	waypointsprite_distancealphaexponent = cvar("g_waypointsprite_distancealphaexponent");
	waypointsprite_timealphaexponent = cvar("g_waypointsprite_timealphaexponent");
	waypointsprite_scale = cvar_or("g_waypointsprite_scale", 1);
	waypointsprite_edgefadealpha = cvar_or("g_waypointsprite_edgefadealpha", 1);
	waypointsprite_edgefadescale = cvar_or("g_waypointsprite_edgefadescale", 1);
	waypointsprite_edgefadedistance = cvar("g_waypointsprite_edgefadedistance");
	waypointsprite_crosshairfadealpha = cvar_or("g_waypointsprite_crosshairfadealpha", 1);
	waypointsprite_crosshairfadescale = cvar_or("g_waypointsprite_crosshairfadescale", 1);
	waypointsprite_crosshairfadedistance = cvar("g_waypointsprite_crosshairfadedistance");
	waypointsprite_distancefadealpha = cvar_or("g_waypointsprite_distancefadealpha", 1);
	waypointsprite_distancefadescale = cvar_or("g_waypointsprite_distancefadescale", 1);
	waypointsprite_distancefadedistance = vlen(mi_max - mi_min) * cvar_or("g_waypointsprite_distancefadedistancemultiplier", 1);
	waypointsprite_alpha = cvar_or("g_waypointsprite_alpha", 1) * (1 - cvar("_menu_alpha"));

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
