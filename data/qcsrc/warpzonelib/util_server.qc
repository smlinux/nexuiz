void WarpZoneLib_MoveOutOfSolid_Expand(entity e, vector by)
{
	float eps = 0.0625;
	tracebox(e.origin, e.mins - '1 1 1' * eps, e.maxs + '1 1 1' * eps, e.origin + by, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return;
	if (trace_fraction < 1)
	{
		// hit something
		// adjust origin in the other direction...
		setorigin(e,e.origin - by * (1 - trace_fraction));
	}
}

float WarpZoneLib_MoveOutOfSolid(entity e)
{
	vector o, m0, m1;

	o = e.origin;
	traceline(o, o, MOVE_WORLDONLY, e);
	if (trace_startsolid)
		return FALSE;

	tracebox(o, e.mins, e.maxs, o, MOVE_WORLDONLY, e);
	if (!trace_startsolid)
		return TRUE;

	m0 = e.mins;
	m1 = e.maxs;
	e.mins = '0 0 0';
	e.maxs = '0 0 0';
	WarpZoneLib_MoveOutOfSolid_Expand(e, '1 0 0' * m0_x);
	e.mins_x = m0_x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '1 0 0' * m1_x);
	e.maxs_x = m1_x;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 1 0' * m0_y);
	e.mins_y = m0_y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 1 0' * m1_y);
	e.maxs_y = m1_y;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 0 1' * m0_z);
	e.mins_z = m0_z;
	WarpZoneLib_MoveOutOfSolid_Expand(e, '0 0 1' * m1_z);
	e.maxs_z = m1_z;
	setorigin(e, e.origin);

	tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_WORLDONLY, e);
	if (trace_startsolid)
	{
		setorigin(e, o);
		return FALSE;
	}

	return TRUE;
}

