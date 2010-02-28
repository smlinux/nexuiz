vector WarpZone_TransformVAngles(vector t, vector ang)
{
	float roll;

	roll = ang_z;
	ang_z = 0;

	/*
	vector vf, vr, vu;
	print(vtos(ang), " input\n");
	makevectors(ang);
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	print(vtos(vf), " -> ", vtos(AnglesTransform_Apply(t, vf)), "\n");
	print(vtos(vr), " -> ", vtos(AnglesTransform_Apply(t, vr)), "\n");
	print(vtos(vu), " -> ", vtos(AnglesTransform_Apply(t, vu)), "\n");
	*/

	ang = AnglesTransform_ApplyToVAngles(t, ang);
	// FIXME when a roll comes out and angle is near +/-90 degrees
	// then roll can be incorporated into yaw and cancelled out

	/*
	print(vtos(ang), " output\n");
	makevectors(ang);
	print(vtos(vf), " -> ", vtos(v_forward), "\n");
	print(vtos(vr), " -> ", vtos(v_right), "\n");
	print(vtos(vu), " -> ", vtos(v_up), "\n");
	*/

	ang = AnglesTransform_Normalize(ang, TRUE);

	/*
	print(vtos(ang), " output\n");
	*/

	ang_z = roll;
	return ang;
}

vector WarpZoneLib_BoxTouchesBrush_mins;
vector WarpZoneLib_BoxTouchesBrush_maxs;
entity WarpZoneLib_BoxTouchesBrush_ent;
entity WarpZoneLib_BoxTouchesBrush_ignore;
float WarpZoneLib_BoxTouchesBrush_Recurse()
{
	float s;
	entity se;
	float f;

	tracebox('0 0 0', WarpZoneLib_BoxTouchesBrush_mins, WarpZoneLib_BoxTouchesBrush_maxs, '0 0 0', MOVE_NOMONSTERS, WarpZoneLib_BoxTouchesBrush_ignore);
#ifdef CSQC
	if (trace_networkentity)
	{
		dprint("hit a network ent, cannot continue WarpZoneLib_BoxTouchesBrush\n");
		// we cannot continue, as a player blocks us...
		// so, abort
		return 0;
	}
#endif
	if not(trace_ent)
		return 0;
	if (trace_ent == WarpZoneLib_BoxTouchesBrush_ent)
		return 1;

	

	se = trace_ent;
	s = se.solid;
	se.solid = SOLID_NOT;
	f = WarpZoneLib_BoxTouchesBrush_Recurse();
	se.solid = s;

	return f;
}

float WarpZoneLib_BoxTouchesBrush(vector mi, vector ma, entity e, entity ig)
{
    float f, s;

    if not(e.modelindex)
        return 1;

    s = e.solid;
    e.solid = SOLID_BSP;
    WarpZoneLib_BoxTouchesBrush_mins = mi;
    WarpZoneLib_BoxTouchesBrush_maxs = ma;
    WarpZoneLib_BoxTouchesBrush_ent = e;
    WarpZoneLib_BoxTouchesBrush_ignore = ig;
    f = WarpZoneLib_BoxTouchesBrush_Recurse();
    e.solid = s;

    return f;
}
