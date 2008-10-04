float teamradar_angle; // player yaw angle
vector teamradar_origin3d_in_texcoord; // player origin
vector teamradar_origin2d; // 2D origin
vector teamradar_size2d; // 2D size
float teamradar_size; // 2D scale factor
float teamradar_scale; // window size = ...qu

float vlen_maxnorm(vector v)
{
	return max6(v_x, v_y, v_z, -v_x, -v_y, -v_z);
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

void() teamradar_view =
{
	local float color;
	local vector rgb;
	local entity tm;
	float scale2d, normalsize, bigsize;
	float a, f, sz;

	color = GetPlayerColor(player_localentnum-1);
	rgb = GetTeamRGB(color);

	scale2d = max(
		mi_picmax_x - mi_picmin_x,
		mi_picmax_y - mi_picmin_y
	);

	f = current_zoomfraction;
	teamradar_scale = cvar("cl_teamradar_scale");
	a = cvar("cl_teamradar_background_alpha");
	teamradar_angle = cvar("cl_teamradar_rotation") * 90;
	sz = cvar("cl_teamradar_background_size");

	// fix undefined cvars first
	if(!teamradar_scale)
		teamradar_scale = 4096;
	if(!a)
		a = 0.75;
	if(!sz)
		sz = 128;

	if(teamradar_scale < 0)
	{
		f = 1 - f;
		teamradar_scale = -teamradar_scale;
	}

	if(!teamradar_angle)
		teamradar_angle = input_angles_y - 90;
	teamradar_size2d = '1 1 0' * sz;
	teamradar_origin2d = 0.5 * teamradar_size2d;

	normalsize = teamradar_size2d_x * scale2d / teamradar_scale;

	if(cvar("cl_teamradar_rotation"))
		bigsize = teamradar_size2d_x * scale2d / (1.05 * vlen_maxnorm(mi_min - mi_max));
	else
		bigsize = teamradar_size2d_x * scale2d / (1.05 * vlen(mi_min - mi_max));
	if(bigsize > normalsize)
		normalsize = bigsize;
	teamradar_size =
		  f * bigsize
		+ (1 - f) * normalsize;
	teamradar_origin3d_in_texcoord = teamradar_3dcoord_to_texcoord(
		  f * (mi_min + mi_max) * 0.5
		+ (1 - f) * pmove_org);

	drawsetcliparea(
		teamradar_origin2d_x - teamradar_size2d_x * 0.5,
		teamradar_origin2d_y - teamradar_size2d_y * 0.5,
		teamradar_size2d_x,
		teamradar_size2d_y
	);

	draw_teamradar_background(a);
	for(tm = world; (tm = findflags(tm, teamradar_icon, 0xFFFFFF)); )
		draw_teamradar_icon(tm.origin, tm.teamradar_icon, tm.teamradar_time, tm.teamradar_color, tm.alpha);
	for(tm = gps_start; tm != world; tm = tm.chain)
		draw_teamradar_player(tm.origin, tm.angles, rgb);
	draw_teamradar_player(pmove_org, input_angles, '1 1 1');

	drawresetcliparea();
};
