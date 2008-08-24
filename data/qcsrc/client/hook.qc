.vector HookStart;
.vector HookEnd;
.float HookKillTime;
void Net_GrapplingHook()
{
	float i;
	vector start, end;
	entity p;

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

	p = playerslots[i];
	if(!p)
		return;

	p.HookKillTime = time + 0.1;
	p.HookStart = start;
	p.HookEnd = end;
}

void Draw_GrapplingHookLine(vector from, vector to, float thickness, vector org, vector view_forward, string texture, float aspect, vector rgb)
{
	// I want to draw a quad...
	// from and to are MIDPOINTS.
	
	float t;
	vector axis, thickdir, A, B, C, D;
	float length_tex;

	t = -2 * time;
	t = random();

	axis = normalize(to - from);
	length_tex = aspect * vlen(to - from) / thickness;

	// direction is perpendicular to the view normal, and perpendicular to the axis
	thickdir = normalize(cross(axis, org - from));

	A = from - thickdir * (thickness / 2);
	B = from + thickdir * (thickness / 2);
	C = to + thickdir * (thickness / 2);
	D = to - thickdir * (thickness / 2);

	if(checkextension("DP_SV_WRITEPICTURE"))
		R_BeginPolygon(texture, 0);
	else
		R_BeginPolygon("", 0);
	R_PolygonVertex(A, '0 0 0' + t * '1 0 0', rgb, 1);
	R_PolygonVertex(B, '0 1 0' + t * '1 0 0', rgb, 1);
	R_PolygonVertex(C, '0 1 0' + (t + length_tex) * '1 0 0', rgb, 1);
	R_PolygonVertex(D, '0 0 0' + (t + length_tex) * '1 0 0', rgb, 1);
	R_EndPolygon();
}

void Draw_GrapplingHook()
{
	float i;
	vector a, b, o;
	entity e;
	string tex;

	o = pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT);
	makevectors(input_angles);

	for(i = 0; i < 255; ++i)
	{
		e = playerslots[i];
		if(!e)
			continue;
		if(time >= e.HookKillTime)
			continue;
		if(i == player_localentnum - 1)
			a = o + v_forward * 8 - v_right * 8 + v_up * -12;
		else
			a = e.HookStart;
		b = e.HookEnd;
		if(e.team == COLOR_TEAM1)
			tex = "particles/hook_red";
		else if(e.team == COLOR_TEAM2)
			tex = "particles/hook_blue";
		else if(e.team == COLOR_TEAM3)
			tex = "particles/hook_yellow";
		else if(e.team == COLOR_TEAM4)
			tex = "particles/hook_pink";
		else
			tex = "particles/hook_green";
		Draw_GrapplingHookLine(b, a, 8, o, v_forward, tex, 0.25, '1 1 1');
	}
}
