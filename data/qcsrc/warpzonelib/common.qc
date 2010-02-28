.vector warpzone_origin;
.vector warpzone_transform;
.entity enemy;

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

entity WarpZone_Find(vector mi, vector ma)
{
	// if we are near any warpzone planes - MOVE AWAY (work around nearclip)
	entity e;
	for(e = world; (e = find(e, classname, "trigger_warpzone")); )
		if(WarpZoneLib_BoxTouchesBrush(mi, ma, e, world))
			return e;
	return world;
}

void WarpZone_MakeAllSolid()
{
	entity e;
	for(e = world; (e = find(e, classname, "trigger_warpzone")); )
		e.solid = SOLID_BSP;
}

void WarpZone_MakeAllOther()
{
	entity e;
	for(e = world; (e = find(e, classname, "trigger_warpzone")); )
		e.solid = SOLID_TRIGGER;
}

void WarpZone_TraceBox(vector org, vector mi, vector ma, vector end, float nomonsters, entity forent)
{
	float frac, sol;
	vector o0, e0;
	vector vf, vr, vu;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	WarpZone_MakeAllSolid();
	o0 = org;
	e0 = end;
	sol = -1;
	frac = 0;
	for(;;)
	{
		tracebox(org, mi, ma, end, nomonsters, forent);
		if(WarpZone_trace_callback)
			WarpZone_trace_callback();
		if(sol < 0)
			sol = trace_startsolid;
		if(trace_fraction >= 1)
			break;
		frac = trace_fraction = frac + (1 - frac) * trace_fraction;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = WarpZone_TransformOrigin(trace_ent, trace_endpos);
		end = WarpZone_TransformOrigin(trace_ent, end);
	}
	WarpZone_MakeAllOther();
	trace_startsolid = sol;
	WarpZone_trace_endpos = o0 + (e0 - o0) * trace_fraction;
	v_forward = vf;
	v_right = vr;
	v_up = vu;
}

void WarpZone_TraceLine(vector org, vector end, float nomonsters, entity forent)
{
	WarpZone_TraceBox(org, '0 0 0', '0 0 0', end, nomonsters, forent);
}

void WarpZone_TraceToss(entity e, entity forent)
{
	float g, dt;
	vector vf, vr, vu, v0, o0;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	WarpZone_MakeAllSolid();
	g = cvar("sv_gravity") * e.gravity;
	WarpZone_tracetoss_time = 0;
	v0 = e.velocity;
	o0 = e.origin;
	for(;;)
	{
		tracetoss(e, forent);
		if(WarpZone_trace_callback)
			WarpZone_trace_callback();
		e.origin = trace_endpos;
		dt = vlen(e.origin - o0) / vlen(e.velocity);
		WarpZone_tracetoss_time += dt;
		e.velocity_z -= WarpZone_tracetoss_time * g;
		if(trace_fraction >= 1)
			break;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		// we hit a warpzone... so, let's perform the trace after the warp again
		e.origin = WarpZone_TransformOrigin(trace_ent, e.origin);
		e.velocity = WarpZone_TransformVelocity(trace_ent, e.velocity);
	}
	WarpZone_MakeAllOther();
	v_forward = vf;
	v_right = vr;
	v_up = vu;
	WarpZone_tracetoss_velocity = e.velocity;
	e.velocity = v0;
	e.origin = o0;
	WarpZone_trace_endpos = e.origin + e.velocity * WarpZone_tracetoss_time;
	WarpZone_trace_endpos_z -= 0.5 * g * WarpZone_tracetoss_time * WarpZone_tracetoss_time;
}

void WarpZone_TrailParticles(entity own, float eff, vector org, vector end)
{
	float frac;
	vector vf, vr, vu;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	WarpZone_MakeAllSolid();
	frac = 0;
	for(;;)
	{
		traceline(org, end, MOVE_NOMONSTERS, world);
		//print(vtos(org), " to ", vtos(trace_endpos), "\n");
		trailparticles(own, eff, org, trace_endpos);
		if(trace_fraction >= 1)
			break;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = WarpZone_TransformOrigin(trace_ent, trace_endpos);
		end = WarpZone_TransformOrigin(trace_ent, end);
	}
	WarpZone_MakeAllOther();
	v_forward = vf;
	v_right = vr;
	v_up = vu;
}

vector WarpZone_TransformOrigin(entity wz, vector v)
{
	return wz.enemy.warpzone_origin + AnglesTransform_Apply(wz.warpzone_transform, v - wz.warpzone_origin);
}

vector WarpZone_TransformVelocity(entity wz, vector v)
{
	return AnglesTransform_Apply(wz.warpzone_transform, v);
}

vector WarpZone_TransformAngles(entity wz, vector v)
{
	return AnglesTransform_ApplyToAngles(wz.warpzone_transform, v);
}

vector WarpZone_TransformVAngles(entity wz, vector ang)
{
	float roll;

	roll = ang_z;
	ang_z = 0;

	ang = AnglesTransform_ApplyToVAngles(wz.warpzone_transform, ang);
	ang = AnglesTransform_Normalize(ang, TRUE);
	ang = AnglesTransform_CancelRoll(ang);

	ang_z = roll;
	return ang;
}
