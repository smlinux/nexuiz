vector HookStart[255];
vector HookEnd[255];
float HookKillTime[255];
void Net_GrapplingHook()
{
	float i;
	vector start, end;

	i = ReadShort();
	end_x = ReadCoord();
	end_y = ReadCoord();
	end_z = ReadCoord();
	start_x = ReadCoord();
	start_y = ReadCoord();
	start_z = ReadCoord();

	if(i <= 0 || i >= 256) // not owned by a client
		return;
	--i;

	HookKillTime[i] = time + 0.1;
	HookStart[i] = start;
	HookEnd[i] = end;
}

void Draw_GrapplingHookLine(vector from, vector to, float thickness, vector org, vector view_forward)
{
	// I want to draw a quad...
	// from and to are MIDPOINTS.
	
	vector axis, thickdir, A, B, C, D;
	float length_tex;

	axis = normalize(to - from);
	length_tex = vlen(to - from) / thickness;

	// direction is perpendicular to the view normal, and perpendicular to the axis
	thickdir = normalize(cross(axis, org - from));

	A = from - thickdir * (thickness / 2);
	B = from + thickdir * (thickness / 2);
	C = to + thickdir * (thickness / 2);
	D = to - thickdir * (thickness / 2);

	R_BeginPolygon("particles/nexbeam", DRAWFLAG_ADDITIVE);
		R_PolygonVertex(A, '0 0 0', '.5 1 0', 1);
		R_PolygonVertex(B, '1 0 0', '.5 1 0', 1);
		R_PolygonVertex(C, '1 0 0' + length_tex * '0 1 0', '.5 1 0', 1);
		R_PolygonVertex(D, '0 0 0' + length_tex * '0 1 0', '.5 1 0', 1);
	R_EndPolygon();
}

void Draw_GrapplingHook()
{
	float i;
	vector a, b, o;

	o = pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT);
	makevectors(input_angles);

	for(i = 0; i < 255; ++i)
	{
		if(time >= HookKillTime[i])
			continue;
		if(i == player_localentnum - 1)
			a = o + v_forward * 8 - v_right * 8 + v_up * -12;
		else
			a = HookStart[i];
		b = HookEnd[i];
		Draw_GrapplingHookLine(a, b, 8, o, v_forward);
	}
}
