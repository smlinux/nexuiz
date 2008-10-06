float teamradar_angle; // player yaw angle
vector teamradar_origin3d_in_texcoord; // player origin
vector teamradar_origin2d; // 2D origin
vector teamradar_size2d; // 2D size
float teamradar_size; // 2D scale factor
float cl_teamradar_scale; // window size = ...qu

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
	out += teamradar_origin2d;
	return out;
}

vector yinvert(vector v)
{
	v_y = 1 - v_y;
	return v;
}

void draw_teamradar_background(float a)
{
	if(a <= 0)
		return;

	R_BeginPolygon("", 0);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', a);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', a);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', a);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', a);
	R_EndPolygon();

	R_BeginPolygon(minimapname, DRAWFLAG_ADDITIVE | DRAWFLAG_MIPMAP);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), '1 1 1', 1);
	R_EndPolygon();
}

void(vector coord3d, vector pangles, vector rgb) draw_teamradar_player =
{
	vector coord, rgb2;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord3d));

	makevectors(pangles - '0 1 0' * teamradar_angle);
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
	R_PolygonVertex(coord+v_forward*3, '0 0 0', rgb2, 1);
	R_PolygonVertex(coord+v_right*4-v_forward*2.5, '0 1 0', rgb2, 1);
	R_PolygonVertex(coord-v_forward*2, '1 0 0', rgb2, 1);
	R_PolygonVertex(coord-v_right*4-v_forward*2.5, '1 1 0', rgb2, 1);
	R_EndPolygon();

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*2, '0 0 0', rgb, 1);
	R_PolygonVertex(coord+v_right*3-v_forward*2, '0 1 0', rgb, 1);
	R_PolygonVertex(coord-v_forward, '1 0 0', rgb, 1);
	R_PolygonVertex(coord-v_right*3-v_forward*2, '1 1 0', rgb, 1);
	R_EndPolygon();
};

void draw_teamradar_icon(vector coord, float icon, float pingtime, vector rgb, float a)
{
	float dt;
	vector v;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord));
	drawpic(coord - '4 4 0', strcat("gfx/teamradar_icon_", ftos(icon)), '8 8 0', rgb, a, 0);
	if(pingtime != 0)
	{
		dt = time - pingtime;
		if(dt > 1)
			return;
		v = '2 2 0' * teamradar_size * dt;
		drawpic(coord - 0.5 * v, "gfx/teamradar_ping", v, '1 1 1', 1 - dt, DRAWFLAG_ADDITIVE);
	}
}

float cl_teamradar_scale;
float cl_teamradar_background_alpha;
float cl_teamradar_rotation;
vector cl_teamradar_size;
vector cl_teamradar_position;
float cl_teamradar_zoommode;

void teamradar_loadcvars()
{
	cl_teamradar_scale = cvar("cl_teamradar_scale");
	cl_teamradar_background_alpha = cvar("cl_teamradar_background_alpha");
	cl_teamradar_rotation = cvar("cl_teamradar_rotation");
	cl_teamradar_size = stov(cvar_string("cl_teamradar_size"));
	cl_teamradar_position = stov(cvar_string("cl_teamradar_position"));
	cl_teamradar_zoommode = cvar("cl_teamradar_zoommode");

	// others default to 0
	if(!cl_teamradar_scale) cl_teamradar_scale = 4096;
	if(!cl_teamradar_background_alpha) cl_teamradar_background_alpha = 0.75;
	if(!cl_teamradar_size_x) cl_teamradar_size_x = 128;
	if(!cl_teamradar_size_y) cl_teamradar_size_y = cl_teamradar_size_x;

	cl_teamradar_size_z = 0;
	cl_teamradar_position_z = 0;
}

void() teamradar_view =
{
	local float color, color2;
	local vector rgb;
	local entity tm;
	float scale2d, normalsize, bigsize;
	float f;

	if(minimapname == "")
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
			teamradar_angle = input_angles_y - 90;
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

	// pixels per world qu to match the teamradar_size2d_x range in the longest dimension
	if(cl_teamradar_rotation == 0)
	{
		// max-min distance must fit the radar in any rotation
		bigsize = vlen_minnorm2d(teamradar_size2d) * scale2d / (1.05 * vlen(mi_max - mi_min));
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
		+ (1 - f) * pmove_org);

	color = GetPlayerColor(player_localentnum-1);
	rgb = GetTeamRGB(color);

	drawsetcliparea(
		teamradar_origin2d_x - teamradar_size2d_x * 0.5,
		teamradar_origin2d_y - teamradar_size2d_y * 0.5,
		teamradar_size2d_x,
		teamradar_size2d_y
	);

	draw_teamradar_background(cl_teamradar_background_alpha);
	for(tm = world; (tm = findflags(tm, teamradar_icon, 0xFFFFFF)); )
		draw_teamradar_icon(tm.origin, tm.teamradar_icon, tm.teamradar_time, tm.teamradar_color, tm.alpha);
	for(tm = world; (tm = find(tm, classname, "entcs_receiver")); )
	{
		color2 = GetPlayerColor(tm.sv_entnum);
		//if(color == COLOR_SPECTATOR || color == color2)
			draw_teamradar_player(tm.origin, tm.angles, GetTeamRGB(color2));
	}
	draw_teamradar_player(pmove_org, input_angles, '1 1 1');

	drawresetcliparea();
};
