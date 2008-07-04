void() Cmd_ons_map =
{
	ons_showmap = !ons_showmap;
};

vector(vector coord) mapcoords =
{
	local vector ret;
	ret = coord; // put that up to ret's definition and it's '0 0 0' ... stupid fteqcc
	ret -= mi_center;
	ret_x = ret_x * 256.0 / mi_scale_x;
	ret_y = -ret_y * 256.0 / mi_scale_y;
	ret_z = 0;
	ret = ret + '400 178';
	return ret;
};

void(vector coord, vector pangles, vector rgb) drawplayer =
{
	makevectors(pangles);
	v_forward_z = 0;
	v_forward = normalize(v_forward);
	v_forward_y *= -1.0;
	v_right_x = -v_forward_y;
	v_right_y = v_forward_x;
	// Ryling on !tex[0] => texture_white
	// beware of the order, it has to be clockwise!
	R_BeginPolygon("", 0);
	R_PolygonVertex(coord+v_forward*2, '0 0', rgb, 1);
	R_PolygonVertex(coord+v_right*3-v_forward*2, '0 1', rgb, 1);
	R_PolygonVertex(coord-v_forward, '1 0', rgb, 1);
	R_PolygonVertex(coord-v_right*3-v_forward*2, '1 1', rgb, 1);
	R_EndPolygon();
};

void() ons_view =
{
	if(ons_showmap) {
		local float color;
		local vector coord, rgb;

		color = stof(getplayerkey(player_localentnum-1, "colors")) & 15;

		coord = mapcoords(pmove_org);
			
		drawpic('272 50', minimapname, '256 256', '1 1 1', 1, 0);
		drawpic('257 35', "gfx/ons-frame.tga", '286 286', '1 1 1', 1, 0);
		if(color == COLOR_TEAM_RED)
		{
			rgb = '1 0 0';
		} else if(color == COLOR_TEAM_BLUE) {
			rgb = '0 0 1';
		} else {
			rgb = '1 1 1';
		}
		drawpic('257 35', "gfx/ons-frame-team.tga", '286 286', rgb, 1, 0);

		drawplayer(coord, input_angles, '1 1 1');

		local entity tm;
		for(tm = gps_start; tm != world; tm = tm.chain)
		{
			//print(strcat("GPS: ", ftos(tm.sv_entnum), " - ", vtos(tm.origin), "\n"));
			drawplayer(mapcoords(tm.origin), tm.angles, rgb);
		}
	}
};
