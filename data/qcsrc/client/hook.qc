.vector HookStart;
.vector HookEnd;
.float HookKillTime;

void Draw_CylindricLine(vector from, vector to, float thickness, string texture, float aspect, float shift, vector rgb, float alpha, float drawflag)
{
	// I want to draw a quad...
	// from and to are MIDPOINTS.
	
	vector axis, thickdir, A, B, C, D;
	float length_tex;

	axis = normalize(to - from);
	length_tex = aspect * vlen(to - from) / thickness;

	// direction is perpendicular to the view normal, and perpendicular to the axis
	thickdir = normalize(cross(axis, view_origin - from));

	A = from - thickdir * (thickness / 2);
	B = from + thickdir * (thickness / 2);
	C = to + thickdir * (thickness / 2);
	D = to - thickdir * (thickness / 2);

	R_BeginPolygon(texture, drawflag);
	R_PolygonVertex(A, '0 0 0' + shift * '1 0 0', rgb, alpha);
	R_PolygonVertex(B, '0 1 0' + shift * '1 0 0', rgb, alpha);
	R_PolygonVertex(C, '0 1 0' + (shift + length_tex) * '1 0 0', rgb, alpha);
	R_PolygonVertex(D, '0 0 0' + (shift + length_tex) * '1 0 0', rgb, alpha);
	R_EndPolygon();
}

string Draw_GrapplingHook_trace_callback_tex;
float Draw_GrapplingHook_trace_callback_rnd;
void Draw_GrapplingHook_trace_callback(vector start, vector hit, vector end)
{
	Draw_CylindricLine(hit, start, 8, Draw_GrapplingHook_trace_callback_tex, 0.25, Draw_GrapplingHook_trace_callback_rnd, '1 1 1', 1, DRAWFLAG_NORMAL);
	Draw_GrapplingHook_trace_callback_rnd += 0.25 * vlen(hit - start) / 8;
}

void Draw_GrapplingHook()
{
	vector a, b;
	string tex;
	vector rgb;
	float t;

	if(time >= self.HookKillTime)
		return;
	if(self.sv_entnum == player_localentnum - 1)
		a = view_origin + view_forward * hook_shotorigin_x + view_right * hook_shotorigin_y + view_up * hook_shotorigin_z;
	else
		a = self.HookStart;
	b = self.HookEnd;

	t = GetPlayerColorForce(self.sv_entnum);

	if(t == COLOR_TEAM1)
	{
		tex = "particles/hook_red";
		rgb = '1 .3 .3';
	}
	else if(t == COLOR_TEAM2)
	{
		tex = "particles/hook_blue";
		rgb = '.3 .3 1';
	}
	else if(t == COLOR_TEAM3)
	{
		tex = "particles/hook_yellow";
		rgb = '1 1 .3';
	}
	else if(t == COLOR_TEAM4)
	{
		tex = "particles/hook_pink";
		rgb = '1 .3 1';
	}
	else
	{
		tex = "particles/hook_green";
		rgb = '.3 1 .3';
	}

	Draw_GrapplingHook_trace_callback_tex = tex;
	Draw_GrapplingHook_trace_callback_rnd = random();
	WarpZone_TraceBox_ThroughZone(a, '0 0 0', '0 0 0', b, MOVE_NOMONSTERS, world, world, Draw_GrapplingHook_trace_callback);
	Draw_GrapplingHook_trace_callback_tex = string_null;
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
