float DEG2RAD = 0.01745329251994329576;

float teamradar_angle; // player yaw angle
vector teamradar_origin3d_in_texcoord; // player origin
vector teamradar_origin2d; // 2D origin
vector teamradar_size2d; // 2D size
float teamradar_size; // 2D scale factor
float teamradar_scale; // window size = ...qu

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

	out_x = in_y * sin(teamradar_angle * DEG2RAD) + in_x * cos(teamradar_angle * DEG2RAD);
	out_y = in_y * cos(teamradar_angle * DEG2RAD) - in_x * sin(teamradar_angle * DEG2RAD);
	out_y = - out_y; // WHY?!? TODO find out whether the map images are mirrored too

	out = out * teamradar_size;
	out += teamradar_origin2d;
	return out;
}

vector yinvert(vector v)
{
	v_y = -v_y;
	return v;
}

void draw_teamradar_background()
{
	R_BeginPolygon(minimapname, 0);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', 1);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y - teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', 1);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x + teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', 1);
	R_PolygonVertex('1 0 0' * (teamradar_origin2d_x - teamradar_size2d_x * 0.5) + '0 1 0' * (teamradar_origin2d_y + teamradar_size2d_y * 0.5), '0 0 0', '0 0 0', 1);
	R_EndPolygon();
	R_BeginPolygon(minimapname, DRAWFLAG_ADDITIVE);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord0), yinvert(mi_pictexcoord0), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord1), yinvert(mi_pictexcoord1), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord2), yinvert(mi_pictexcoord2), '1 1 1', 1);
	R_PolygonVertex(teamradar_texcoord_to_2dcoord(mi_pictexcoord3), yinvert(mi_pictexcoord3), '1 1 1', 1);
	R_EndPolygon();
}

void(vector coord3d, vector pangles, vector rgb) draw_teamradar_player =
{
	vector coord;

	coord = teamradar_texcoord_to_2dcoord(teamradar_3dcoord_to_texcoord(coord3d));

	makevectors(pangles - '0 1 0' * teamradar_angle);
	v_forward_z = 0;
	v_forward = normalize(v_forward);
	v_forward_y *= -1.0;
	v_right_x = -v_forward_y;
	v_right_y = v_forward_x;

	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*2, '0 0 0', rgb, 1);
	R_PolygonVertex(coord+v_right*3-v_forward*2, '0 1 0', rgb, 1);
	R_PolygonVertex(coord-v_forward, '1 0 0', rgb, 1);
	R_PolygonVertex(coord-v_right*3-v_forward*2, '1 1 0', rgb, 1);
	R_EndPolygon();
};

void() teamradar_view =
{
	local float color;
	local vector coord, rgb;
	local entity tm;
	float scale2d, normalsize, bigsize;

	if(!cvar("cl_teamradar"))
		return;

	color = GetPlayerColor(player_localentnum-1);
	rgb = GetTeamRGB(color);

	scale2d = max(
		mi_picmax_x - mi_picmin_x,
		mi_picmax_y - mi_picmin_y
	);

	teamradar_angle = input_angles_y - 90;
	teamradar_origin2d = '64 64 0';
	teamradar_size2d = '128 128 0';
	teamradar_scale = 2048;

	normalsize = teamradar_size2d_x * scale2d / teamradar_scale;
	bigsize = teamradar_size2d_x * scale2d / max(teamradar_scale, vlen(mi_min - mi_max));
	teamradar_size =
		  current_zoomfraction * bigsize
		+ (1 - current_zoomfraction) * normalsize;
	teamradar_origin3d_in_texcoord = teamradar_3dcoord_to_texcoord(
		  current_zoomfraction * (mi_min + mi_max) * 0.5
		+ (1 - current_zoomfraction) * pmove_org);

	drawsetcliparea(
		teamradar_origin2d_x - teamradar_size2d_x * 0.5,
		teamradar_origin2d_y - teamradar_size2d_y * 0.5,
		teamradar_size2d_x,
		teamradar_size2d_y
	);

	draw_teamradar_background();
	draw_teamradar_player(pmove_org, input_angles, '1 1 1');
	for(tm = gps_start; tm != world; tm = tm.chain)
		draw_teamradar_player(tm.origin, tm.angles, rgb);

	drawresetcliparea();
};
