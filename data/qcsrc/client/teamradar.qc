float teamradar_angle; // player yaw angle
vector teamradar_origin3d_in_texcoord; // player origin
vector teamradar_origin2d; // 2D origin
vector teamradar_size2d; // 2D size
vector teamradar_extraclip_mins, teamradar_extraclip_maxs; // don't even ask
float teamradar_size; // 2D scale factor
float cl_teamradar_scale; // window size = ...qu
float cl_teamradar_nohudhack;
float v_flipped;

float vlen2d(vector v)
{
	return sqrt(v_x * v_x + v_y * v_y);
}

float vlen_maxnorm2d(vector v)
{
	return max4(v_x, v_y, -v_x, -v_y);
}

float vlen_minnorm2d(vector v)
{
	return min(max(v_x, -v_x), max(v_y, -v_y));
}

vector teamradar_3dcoord_to_texcoord(vector in)
{
	vector out;
	out_x = (in_x - mi_picmin_x) / (mi_picmax_x - mi_picmin_x);
	out_y = (in_y - mi_picmin_y) / (mi_picmax_y - mi_picmin_y);
	out_z = 0;
	return out;
}

vector teamradar_texcoord_to_2dcoord(vector in)
{
	vector out;
	in -= teamradar_origin3d_in_texcoord;

	out = rotate(in, teamradar_angle * DEG2RAD);
	out_y = - out_y; // screen space is reversed

	out = out * teamradar_size;
	if(v_flipped)
		out_x = -out_x;
	out += teamradar_origin2d;
	return out;
}

vector yinvert(vector v)
{
	v_y = 1 - v_y;
	return v;
}

void draw_teamradar_background(float bg, float fg)
{
	float fga;
	vector fgc;
	if(bg > 0)
	{
		R_BeginPolygon("", 0);
		R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5 + teamradar_extraclip_mins_x) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5 + teamradar_extraclip_mins_y), '0 0 0', '0 0 0', bg);
		R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5 + teamradar_extraclip_maxs_x) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5 + teamradar_extraclip_mins_y), '0 0 0', '0 0 0', bg);
		R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5 + teamradar_extraclip_maxs_x) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5 + teamradar_extraclip_maxs_y), '0 0 0', '0 0 0', bg);
		R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5 + teamradar_extraclip_mins_x) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5 + teamradar_extraclip_maxs_y), '0 0 0', '0 0 0', bg);
		R_EndPolygon();
	}

	if(fg > 0 && minimapname != "")
	{
		fga = 1;
		fgc = '1 1 1' * fg;
		R_BeginPolygon(minimapname, DRAWFLAG_SCREEN | DRAWFLAG_MIPMAP);
		if(v_flipped)
		{
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), fgc, fga);
		}
		else
		{
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), fgc, fga);
			R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), fgc, fga);
		}
		R_EndPolygon();
	}
}

void(vector coord3d, vector pangles, vector rgb) draw_teamradar_player =
{
	vector coord, rgb2;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord3d));

	makevectors(pangles - '0 1 0' * teamradar_angle);
	if(v_flipped)
	{
		v_forward_x = -v_forward_x;
		v_right_x = -v_right_x;
		v_up_x = -v_up_x;
	}
	v_forward_z = 0;
	v_forward = normalize(v_forward);
	v_forward_y *= -1.0;
	v_right_x = -v_forward_y;
	v_right_y = v_forward_x;

	if(rgb == '1 1 1')
		rgb2 = '0 0 0';
	else
		rgb2 = '1 1 1';

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*3, '0 0 0', rgb2, sbar_alpha_fg);
	R_PolygonVertex(coord+v_right*4-v_forward*2.5, '0 1 0', rgb2, sbar_alpha_fg);
	R_PolygonVertex(coord-v_forward*2, '1 0 0', rgb2, sbar_alpha_fg);
	R_PolygonVertex(coord-v_right*4-v_forward*2.5, '1 1 0', rgb2, sbar_alpha_fg);
	R_EndPolygon();

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*2, '0 0 0', rgb, sbar_alpha_fg);
	R_PolygonVertex(coord+v_right*3-v_forward*2, '0 1 0', rgb, sbar_alpha_fg);
	R_PolygonVertex(coord-v_forward, '1 0 0', rgb, sbar_alpha_fg);
	R_PolygonVertex(coord-v_right*3-v_forward*2, '1 1 0', rgb, sbar_alpha_fg);
	R_EndPolygon();
};

void draw_teamradar_icon(vector coord, float icon, entity pingdata, vector rgb, float a)
{
	float dt;
	vector v;
	float i;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord));
	drawpic(coord - '4 4 0', strcat("gfx/teamradar_icon_", ftos(icon)), '8 8 0', rgb, a, 0);

	if(pingdata)
	{
		for(i = 0; i < MAX_TEAMRADAR_TIMES; ++i)
		{
			dt = pingdata.(teamradar_times[i]);
			if(dt == 0)
				continue;
			dt = time - dt;
			if(dt >= 1 || dt <= 0)
				continue;
			v = '2 2 0' * teamradar_size * dt;
			drawpic(coord - 0.5 * v, "gfx/teamradar_ping", v, '1 1 1', (1 - dt) * a, DRAWFLAG_ADDITIVE);
		}
	}
}

void draw_teamradar_link(vector start, vector end, float colors)
{
	vector c0, c1, norm;

	start = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(start));
	end = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(end));
	norm = normalize(start - end);
	norm_z = norm_x;
	norm_x = -norm_y;
	norm_y = norm_z;
	norm_z = 0;

	c0 = colormapPaletteColor(colors & 0x0F, FALSE);
	c1 = colormapPaletteColor((colors & 0xF0) / 0x10, FALSE);

	R_BeginPolygon("", 0);
	R_PolygonVertex(start - norm, '0 0 0', c0, sbar_alpha_fg);
	R_PolygonVertex(start + norm, '0 1 0', c0, sbar_alpha_fg);
	R_PolygonVertex(end + norm, '1 1 0', c1, sbar_alpha_fg);
	R_PolygonVertex(end - norm, '1 0 0', c1, sbar_alpha_fg);
	R_EndPolygon();
}

float cl_teamradar_scale;
float cl_teamradar_background_alpha;
float cl_teamradar_foreground_alpha;
float cl_teamradar_rotation;
vector cl_teamradar_size;
vector cl_teamradar_position;
float cl_teamradar_zoommode;

void teamradar_loadcvars()
{
	v_flipped = cvar("v_flipped");
	if(ons_showmap)
	{
		cl_teamradar_scale = 42; // dummy, not used (see zoommode)
		cl_teamradar_background_alpha = 1 * (1 - cvar("_menu_alpha"));
		cl_teamradar_foreground_alpha = 1 * (1 - cvar("_menu_alpha"));
		cl_teamradar_rotation = cvar("cl_teamradar_rotation");
		if(!cl_teamradar_rotation)
			cl_teamradar_rotation = 4;
		cl_teamradar_size = '256 256 0'; // TODO make somewhat variable?
		cl_teamradar_position = '0.5 0.5 0';
		cl_teamradar_zoommode = 3;
		cl_teamradar_nohudhack = 0;
	}
	else
	{
		cl_teamradar_scale = cvar("cl_teamradar_scale");
		cl_teamradar_background_alpha = cvar("cl_teamradar_background_alpha") * sbar_alpha_fg;
		cl_teamradar_foreground_alpha = cvar("cl_teamradar_foreground_alpha") * sbar_alpha_fg;
		cl_teamradar_rotation = cvar("cl_teamradar_rotation");
		cl_teamradar_size = stov(cvar_string("cl_teamradar_size"));
		cl_teamradar_position = stov(cvar_string("cl_teamradar_position"));
		cl_teamradar_zoommode = cvar("cl_teamradar_zoommode");

		// others default to 0
		// match this to defaultNexuiz.cfg!
		if(!cl_teamradar_scale) cl_teamradar_scale = 4096;
		if(!cl_teamradar_background_alpha) cl_teamradar_background_alpha = 0.4 * sbar_alpha_fg;
		if(!cl_teamradar_foreground_alpha) cl_teamradar_foreground_alpha = 0.8 * sbar_alpha_fg;
		if(!cl_teamradar_size_x) cl_teamradar_size_x = 128;
		if(!cl_teamradar_size_y) cl_teamradar_size_y = cl_teamradar_size_x;

		cl_teamradar_size_z = 0;
		cl_teamradar_nohudhack = cl_teamradar_position_z;
		cl_teamradar_position_z = 0;
	}
}

void() teamradar_view =
{
	local float color1, color2; // color already declared as a global in sbar.qc
	local vector rgb;
	local entity tm;
	float scale2d, normalsize, bigsize;
	float f;

	if(minimapname == "" && !ons_showmap)
		return;

	teamradar_loadcvars();

	switch(cl_teamradar_zoommode)
	{
		default:
		case 0:
			f = current_zoomfraction;
			break;
		case 1:
			f = 1 - current_zoomfraction;
			break;
		case 2:
			f = 0;
			break;
		case 3:
			f = 1;
			break;
	}

	switch(cl_teamradar_rotation)
	{
		case 0:
			teamradar_angle = view_angles_y - 90;
			break;
		default:
			teamradar_angle = 90 * cl_teamradar_rotation;
			break;
	}

	scale2d = vlen_maxnorm2d(mi_picmax - mi_picmin);
	teamradar_size2d = cl_teamradar_size;

	teamradar_origin2d =
		  '1 0 0' * (0.5 * teamradar_size2d_x + cl_teamradar_position_x * (vid_conwidth - teamradar_size2d_x))
		+ '0 1 0' * (0.5 * teamradar_size2d_y + cl_teamradar_position_y * (vid_conheight - teamradar_size2d_y));
	
	teamradar_extraclip_mins = teamradar_extraclip_maxs = '0 0 0';
	if(cl_teamradar_position == '1 0 0')
	{
		if(cl_teamradar_nohudhack < 2)
			teamradar_origin2d_y += 25;
		if(cl_teamradar_nohudhack < 1)
			teamradar_extraclip_mins_y -= 25;
	}
	else if(cl_teamradar_position == '0 1 0' || cl_teamradar_position == '1 1 0')
	{
		if(cl_teamradar_nohudhack < 2)
			teamradar_origin2d_y -= 50;
		//if(cl_teamradar_nohudhack < 1)
			//teamradar_extraclip_size_y += 50; // don't, the HUD looks nice
	}

	// pixels per world qu to match the teamradar_size2d_x range in the longest dimension
	if(cl_teamradar_rotation == 0)
	{
		// max-min distance must fit the radar in any rotation
		bigsize = vlen_minnorm2d(teamradar_size2d) * scale2d / (1.05 * vlen2d(mi_max - mi_min));
	}
	else
	{
		vector c0, c1, c2, c3, span;
		c0 = rotate(mi_min, teamradar_angle * DEG2RAD);
		c1 = rotate(mi_max, teamradar_angle * DEG2RAD);
		c2 = rotate('1 0 0' * mi_min_x + '0 1 0' * mi_max_y, teamradar_angle * DEG2RAD);
		c3 = rotate('1 0 0' * mi_max_x + '0 1 0' * mi_min_y, teamradar_angle * DEG2RAD);
		span = '0 0 0';
		span_x = max4(c0_x, c1_x, c2_x, c3_x) - min4(c0_x, c1_x, c2_x, c3_x);
		span_y = max4(c0_y, c1_y, c2_y, c3_y) - min4(c0_y, c1_y, c2_y, c3_y);

		// max-min distance must fit the radar in x=x, y=y
		bigsize = min(
			teamradar_size2d_x * scale2d / (1.05 * span_x),
			teamradar_size2d_y * scale2d / (1.05 * span_y)
		);
	}

	normalsize = vlen_maxnorm2d(teamradar_size2d) * scale2d / cl_teamradar_scale;
	if(bigsize > normalsize)
		normalsize = bigsize;

	teamradar_size =
		  f * bigsize
		+ (1 - f) * normalsize;
	teamradar_origin3d_in_texcoord = teamradar_3dcoord_to_texcoord(
		  f * (mi_min + mi_max) * 0.5
		+ (1 - f) * view_origin);

	color1 = GetPlayerColor(player_localentnum-1);
	rgb = GetTeamRGB(color1);

	drawsetcliparea(
		teamradar_origin2d_x - teamradar_size2d_x * 0.5 + teamradar_extraclip_mins_x,
		teamradar_origin2d_y - teamradar_size2d_y * 0.5 + teamradar_extraclip_mins_y,
		teamradar_size2d_x + teamradar_extraclip_maxs_x - teamradar_extraclip_mins_x,
		teamradar_size2d_y + teamradar_extraclip_maxs_y - teamradar_extraclip_mins_y
	);

	draw_teamradar_background(cl_teamradar_background_alpha, cl_teamradar_foreground_alpha);

	if(ons_showmap)
	{
		drawresetcliparea();

		vector frame_origin, frame_size;
		frame_origin = frame_size = '0 0 0';

		frame_origin_x = teamradar_origin2d_x - teamradar_size2d_x * 0.55859375; // matches the picture
		frame_origin_y = teamradar_origin2d_y - teamradar_size2d_y * 0.55859375; // matches the picture
		frame_size_x = teamradar_size2d_x * 1.1171875; // matches the picture
		frame_size_y = teamradar_size2d_y * 1.1171875; // matches the picture
		drawpic(frame_origin, "gfx/ons-frame.tga", frame_size, '1 1 1', sbar_alpha_fg, 0);
		drawpic(frame_origin, "gfx/ons-frame-team.tga", frame_size, rgb, sbar_alpha_fg, 0);

		drawsetcliparea(
			teamradar_origin2d_x - teamradar_size2d_x * 0.5,
			teamradar_origin2d_y - teamradar_size2d_y * 0.5,
			teamradar_size2d_x,
			teamradar_size2d_y
		);
	}

	for(tm = world; (tm = find(tm, classname, "radarlink")); )
		draw_teamradar_link(tm.origin, tm.velocity, tm.team);
	for(tm = world; (tm = findflags(tm, teamradar_icon, 0xFFFFFF)); )
		draw_teamradar_icon(tm.origin, tm.teamradar_icon, tm, tm.teamradar_color, tm.alpha * sbar_alpha_fg);
	for(tm = world; (tm = find(tm, classname, "entcs_receiver")); )
	{
		color2 = GetPlayerColor(tm.sv_entnum);
		//if(color == COLOR_SPECTATOR || color == color2)
			draw_teamradar_player(tm.origin, tm.angles, GetTeamRGB(color2));
	}
	draw_teamradar_player(view_origin, view_angles, '1 1 1');

	drawresetcliparea();
};



// radar links

void Ent_RadarLink()
{
	float sendflags;
	sendflags = ReadByte();

	InterpolateOrigin_Undo();

	self.iflags = IFLAG_VELOCITY;
	self.classname = "radarlink";

	if(sendflags & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
	}

	if(sendflags & 2)
	{
		self.velocity_x = ReadCoord();
		self.velocity_y = ReadCoord();
		self.velocity_z = ReadCoord();
	}

	if(sendflags & 4)
	{
		self.team = ReadByte();
	}

	InterpolateOrigin_Note();
}
