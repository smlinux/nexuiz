.vector HookStart;
.vector HookEnd;
.float HookKillTime;

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

	R_BeginPolygon(texture, 0);
	R_PolygonVertex(A, '0 0 0' + t * '1 0 0', rgb, 1);
	R_PolygonVertex(B, '0 1 0' + t * '1 0 0', rgb, 1);
	R_PolygonVertex(C, '0 1 0' + (t + length_tex) * '1 0 0', rgb, 1);
	R_PolygonVertex(D, '0 0 0' + (t + length_tex) * '1 0 0', rgb, 1);
	R_EndPolygon();
}

void Draw_GrapplingHook()
{
	vector a, b, o;
	string tex;
	vector rgb;

	o = pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT);
	makevectors(input_angles);

	if(time >= self.HookKillTime)
		return;
	if(self.sv_entnum == player_localentnum - 1)
		a = o + v_forward * 8 - v_right * 8 + v_up * -12;
	else
		a = self.HookStart;
	b = self.HookEnd;
	if(self.team == COLOR_TEAM1)
	{
		tex = "particles/hook_red";
		rgb = '1 .3 .3';
	}
	else if(self.team == COLOR_TEAM2)
	{
		tex = "particles/hook_blue";
		rgb = '.3 .3 1';
	}
	else if(self.team == COLOR_TEAM3)
	{
		tex = "particles/hook_yellow";
		rgb = '1 1 .3';
	}
	else if(self.team == COLOR_TEAM4)
	{
		tex = "particles/hook_pink";
		rgb = '1 .3 1';
	}
	else
	{
		tex = "particles/hook_green";
		rgb = '.3 1 .3';
	}
	if(checkextension("DP_SV_WRITEPICTURE"))
		Draw_GrapplingHookLine(b, a, 8, o, v_forward, tex, 0.25, '1 1 1');
	else
		Draw_GrapplingHookLine(b, a, 1, o, v_forward, "", 0.25, rgb);
}

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
	p.draw = Draw_GrapplingHook;
}
