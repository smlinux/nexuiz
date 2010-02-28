void WarpZone_SetUp(entity e, vector my_org, vector my_ang, vector other_org, vector other_ang)
{
	e.warpzone_transform = AnglesTransform_Divide(other_ang, AnglesTransform_TurnDirectionFR(my_ang));
	e.warpzone_shift = AnglesTransform_PrePostShift_GetPostShift(my_org, e.warpzone_transform, other_org);
	e.warpzone_origin = my_org;
	e.warpzone_targetorigin = other_org;
	e.warpzone_angles = my_ang;
	e.warpzone_targetangles = other_ang;
	fixedmakevectors(my_ang); e.warpzone_forward = v_forward;
	fixedmakevectors(other_ang); e.warpzone_targetforward = v_forward;
}

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
	entity wz;
	vector vf, vr, vu;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	o0 = org;
	e0 = end;
	// if starting in warpzone, first transform
	wz = WarpZone_Find(org + mi, org + ma);
	if(wz)
	{
		org = WarpZone_TransformOrigin(wz, trace_endpos);
		end = WarpZone_TransformOrigin(wz, end);
		WarpZone_trace_velocity = WarpZone_TransformVelocity(wz, WarpZone_trace_velocity);
		WarpZone_trace_angles = WarpZone_TransformAngles(wz, WarpZone_trace_angles);
		WarpZone_trace_v_angle = WarpZone_TransformVAngles(wz, WarpZone_trace_v_angle);
	}
	WarpZone_MakeAllSolid();
	sol = -1;
	frac = 0;
	for(;;)
	{
		tracebox(org, mi, ma, end, nomonsters, forent);
		if(WarpZone_trace_callback)
			WarpZone_trace_callback(org, trace_endpos, end);
		if(sol < 0)
			sol = trace_startsolid;
		if(trace_fraction >= 1)
			break;
		frac = trace_fraction = frac + (1 - frac) * trace_fraction;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		if(trace_ent == wz)
		{
			dprint("I transformed into the same zone again, wtf, aborting the trace\n");
			break;
		}
		wz = trace_ent;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = WarpZone_TransformOrigin(wz, trace_endpos);
		end = WarpZone_TransformOrigin(wz, end);
		WarpZone_trace_velocity = WarpZone_TransformVelocity(wz, WarpZone_trace_velocity);
		WarpZone_trace_angles = WarpZone_TransformAngles(wz, WarpZone_trace_angles);
		WarpZone_trace_v_angle = WarpZone_TransformVAngles(wz, WarpZone_trace_v_angle);
	}
	WarpZone_MakeAllOther();
	trace_startsolid = sol;
	WarpZone_trace_endpos = o0 + (e0 - o0) * trace_fraction;
	v_forward = vf;
	v_right = vr;
	v_up = vu;
}

void WarpZone_TraceBox_ThroughZone(vector org, vector mi, vector ma, vector end, float nomonsters, entity forent, entity zone)
{
	float frac, sol;
	vector o0, e0;
	entity wz;
	vector vf, vr, vu;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	o0 = org;
	e0 = end;
	// if starting in warpzone, first transform
	wz = WarpZone_Find(org + mi, org + ma);
	if(wz)
	{
		if(wz != zone)
		{
			// we are in ANOTHER warpzone. This is bad. Make a zero length trace and return.
			sol = 1;
			trace_fraction = 0;
			trace_endpos = org;
			goto fail;
		}
		org = WarpZone_TransformOrigin(wz, trace_endpos);
		end = WarpZone_TransformOrigin(wz, end);
		WarpZone_trace_velocity = WarpZone_TransformVelocity(wz, WarpZone_trace_velocity);
		WarpZone_trace_angles = WarpZone_TransformAngles(wz, WarpZone_trace_angles);
		WarpZone_trace_v_angle = WarpZone_TransformVAngles(wz, WarpZone_trace_v_angle);
	}
	WarpZone_MakeAllSolid();
	sol = -1;
	frac = 0;
	for(;;)
	{
		tracebox(org, mi, ma, end, nomonsters, forent);
		if(WarpZone_trace_callback)
			WarpZone_trace_callback(org, trace_endpos, end);
		if(sol < 0)
			sol = trace_startsolid;
		if(trace_fraction >= 1)
			break;
		frac = trace_fraction = frac + (1 - frac) * trace_fraction;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		if(trace_ent != zone)
			break;
		if(trace_ent == wz)
		{
			dprint("I transformed into the same zone again, wtf, aborting the trace\n");
			break;
		}
		wz = trace_ent;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = WarpZone_TransformOrigin(wz, trace_endpos);
		end = WarpZone_TransformOrigin(wz, end);
		WarpZone_trace_velocity = WarpZone_TransformVelocity(wz, WarpZone_trace_velocity);
		WarpZone_trace_angles = WarpZone_TransformAngles(wz, WarpZone_trace_angles);
		WarpZone_trace_v_angle = WarpZone_TransformVAngles(wz, WarpZone_trace_v_angle);
	}
	WarpZone_MakeAllOther();
:fail
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
	entity wz;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	v0 = e.velocity;
	o0 = e.origin;
	// if starting in warpzone, first transform
	wz = WarpZone_Find(e.origin + e.mins, e.origin + e.maxs);
	if(wz)
	{
		setorigin(e, WarpZone_TransformOrigin(wz, e.origin));
		e.velocity = WarpZone_TransformVelocity(wz, e.velocity);
	}
	WarpZone_MakeAllSolid();
	g = cvar("sv_gravity") * e.gravity;
	WarpZone_tracetoss_time = 0;
	for(;;)
	{
		tracetoss(e, forent);
		if(WarpZone_trace_callback)
			WarpZone_trace_callback(e.origin, trace_endpos, trace_endpos);
		e.origin = trace_endpos;
		dt = vlen(e.origin - o0) / vlen(e.velocity);
		WarpZone_tracetoss_time += dt;
		e.velocity_z -= WarpZone_tracetoss_time * g;
		if(trace_fraction >= 1)
			break;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		if(trace_ent == wz)
		{
			dprint("I transformed into the same zone again, wtf, aborting the trace\n");
			break;
		}
		wz = trace_ent;
		// we hit a warpzone... so, let's perform the trace after the warp again
		e.origin = WarpZone_TransformOrigin(wz, e.origin);
		e.velocity = WarpZone_TransformVelocity(wz, e.velocity);
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
	vector vf, vr, vu;
	entity e;
	vf = v_forward;
	vr = v_right;
	vu = v_up;
	WarpZone_MakeAllSolid();
	e = world;
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
		if(trace_ent == e)
		{
			dprint("I transformed into the same zone again, wtf, aborting the trace\n");
			break;
		}
		e = trace_ent;
	}
	WarpZone_MakeAllOther();
	v_forward = vf;
	v_right = vr;
	v_up = vu;
}

float WarpZone_PlaneDist(entity wz, vector v)
{
	return (v - wz.warpzone_origin) * wz.warpzone_forward;
}

float WarpZone_TargetPlaneDist(entity wz, vector v)
{
	return (v - wz.warpzone_targetorigin) * wz.warpzone_targetforward;
}

vector WarpZone_TransformOrigin(entity wz, vector v)
{
	return wz.warpzone_shift + AnglesTransform_Apply(wz.warpzone_transform, v);
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

vector WarpZone_UnTransformOrigin(entity wz, vector v)
{
	return AnglesTransform_Apply(AnglesTransform_Invert(wz.warpzone_transform), v - wz.warpzone_shift);
}

vector WarpZone_UnTransformVelocity(entity wz, vector v)
{
	return AnglesTransform_Apply(AnglesTransform_Invert(wz.warpzone_transform), v);
}

vector WarpZone_UnTransformAngles(entity wz, vector v)
{
	return AnglesTransform_ApplyToAngles(AnglesTransform_Invert(wz.warpzone_transform), v);
}

vector WarpZone_UnTransformVAngles(entity wz, vector ang)
{
	float roll;

	roll = ang_z;
	ang_z = 0;

	ang = AnglesTransform_ApplyToVAngles(AnglesTransform_Invert(wz.warpzone_transform), ang);
	ang = AnglesTransform_Normalize(ang, TRUE);
	ang = AnglesTransform_CancelRoll(ang);

	ang_z = roll;
	return ang;
}

vector WarpZoneLib_NearestPointOnBox(vector mi, vector ma, vector org)
{
	vector nearest;
	nearest_x = bound(mi_x, org_x, ma_x);
	nearest_y = bound(mi_y, org_y, ma_y);
	nearest_z = bound(mi_z, org_z, ma_z);
	return nearest;
}

.float WarpZone_findradius_hit;
.entity WarpZone_findradius_next;
void WarpZone_FindRadius_Recurse(vector org, float rad,        vector org0,               vector transform, vector shift, float needlineofsight)
//                               blast origin of current search   original blast origin   how to untransform (victim to blast system)
{
	vector org_new;
	vector org0_new;
	vector shift_new, transform_new;
	vector p;
	entity e, e0;
	entity wz;
	if(rad <= 0)
		return;
	e0 = findradius(org, rad);
	wz = world;

	for(e = e0; e; e = e.chain)
	{
		p = WarpZoneLib_NearestPointOnBox(e.origin + e.mins, e.origin + e.maxs, org0);
		if(needlineofsight)
		{
			traceline(org, p, MOVE_NOMONSTERS, e);
			if(trace_fraction < 1)
				continue;
		}
		if(!e.WarpZone_findradius_hit || vlen(e.WarpZone_findradius_dist) > vlen(org0 - p))
		{
			e.WarpZone_findradius_nearest = p;
			e.WarpZone_findradius_dist = org0 - p;
			e.WarpZone_findradius_findorigin = org;
			e.WarpZone_findradius_findradius = rad;
			if(e.classname == "warpzone_refsys")
			{
				// ignore, especially: do not overwrite the refsys parameters
			}
			else if(e.classname == "trigger_warpzone")
			{
				e.WarpZone_findradius_next = wz;
				wz = e;
				e.WarpZone_findradius_hit = 1;
				e.enemy.WarpZone_findradius_dist = '0 0 0'; // we don't want to go through this zone ever again
				e.enemy.WarpZone_findradius_hit = 1;
			}
			else
			{
				e.warpzone_transform = transform;
				e.warpzone_shift = shift;
				e.WarpZone_findradius_hit = 1;
			}
		}
	}
	for(e = wz; e; e = e.WarpZone_findradius_next)
	{
		org0_new = WarpZone_TransformOrigin(e, org);
		traceline(e.warpzone_targetorigin, org0_new, MOVE_NOMONSTERS, e);
		org_new = trace_endpos;

		transform_new = AnglesTransform_Multiply(e.warpzone_transform, transform);
		shift_new = AnglesTransform_Multiply_GetPostShift(e.warpzone_transform, e.warpzone_shift, transform, shift);
		WarpZone_FindRadius_Recurse(
			org_new,
			bound(0, rad - vlen(org_new - org0_new), rad - 8),
			org0_new,
			transform_new, shift_new,
			needlineofsight);
		e.WarpZone_findradius_hit = 0;
		e.enemy.WarpZone_findradius_hit = 0;
	}
}
entity WarpZone_FindRadius(vector org, float rad, float needlineofsight)
{
	entity e0, e;
	WarpZone_FindRadius_Recurse(org, rad, org, '0 0 0', '0 0 0', needlineofsight);
	e0 = findchainfloat(WarpZone_findradius_hit, 1);
	for(e = e0; e; e = e.chain)
		e.WarpZone_findradius_hit = 0;
	return e0;
}

void WarpZone_Accumulator_Clear(entity acc)
{
	acc.warpzone_transform = '0 0 0';
	acc.warpzone_shift = '0 0 0';
}
void WarpZone_Accumulator_AddTransform(entity acc, vector t, vector s)
{
	vector tr, st;
	tr = AnglesTransform_Multiply(t, acc.warpzone_transform);
	st = AnglesTransform_Multiply_GetPostShift(t, s, acc.warpzone_transform, acc.warpzone_shift);
	acc.warpzone_transform = tr;
	acc.warpzone_shift = st;
}
void WarpZone_Accumulator_Add(entity acc, entity wz)
{
	vector t, st;
	t = AnglesTransform_Multiply(wz.warpzone_transform, acc.warpzone_transform);
	st = AnglesTransform_Multiply_GetPostShift(wz.warpzone_transform, wz.warpzone_shift, acc.warpzone_transform, acc.warpzone_shift);
	acc.warpzone_transform = t;
	acc.warpzone_shift = st;
}

.entity WarpZone_refsys;
void WarpZone_RefSys_GC()
{
	// garbage collect unused reference systems
	self.nextthink = time + 1;
	if(self.owner.WarpZone_refsys != self)
		remove(self);
}
void WarpZone_RefSys_Add(entity me, entity wz)
{
	if(me.WarpZone_refsys.owner != me)
	{
		me.WarpZone_refsys = spawn();
		me.WarpZone_refsys.classname = "warpzone_refsys";
		me.WarpZone_refsys.owner = me;
		me.WarpZone_refsys.think = WarpZone_RefSys_GC;
		me.WarpZone_refsys.nextthink = time + 1;
		WarpZone_Accumulator_Clear(me.WarpZone_refsys);
	}
	if(wz)
		WarpZone_Accumulator_Add(me.WarpZone_refsys, wz);
}
.vector WarpZone_refsys_incremental_shift;
.vector WarpZone_refsys_incremental_transform;
void WarpZone_RefSys_AddIncrementally(entity me, entity ref)
{
	vector t, s;
	if(me.WarpZone_refsys_incremental_transform == ref.WarpZone_refsys.warpzone_transform)
	if(me.WarpZone_refsys_incremental_shift == ref.WarpZone_refsys.warpzone_shift)
		return;
	if(me.WarpZone_refsys.owner != me)
	{
		me.WarpZone_refsys = spawn();
		me.WarpZone_refsys.classname = "warpzone_refsys";
		me.WarpZone_refsys.owner = me;
		me.WarpZone_refsys.think = WarpZone_RefSys_GC;
		me.WarpZone_refsys.nextthink = time + 1;
		WarpZone_Accumulator_Clear(me.WarpZone_refsys);
	}
	t = AnglesTransform_Invert(me.WarpZone_refsys_incremental_transform);
	s = AnglesTransform_PrePostShift_GetPostShift(me.WarpZone_refsys_incremental_shift, t, '0 0 0');
	WarpZone_Accumulator_AddTransform(me.WarpZone_refsys, t, s);
	WarpZone_Accumulator_Add(me.WarpZone_refsys, ref);
	me.WarpZone_refsys_incremental_shift = ref.WarpZone_refsys.warpzone_shift;
	me.WarpZone_refsys_incremental_transform = ref.WarpZone_refsys.warpzone_transform;
}
void WarpZone_RefSys_BeginAddingIncrementally(entity me, entity ref)
{
	me.WarpZone_refsys_incremental_shift = ref.WarpZone_refsys.warpzone_shift;
	me.WarpZone_refsys_incremental_transform = ref.WarpZone_refsys.warpzone_transform;
}
vector WarpZone_RefSys_TransformOrigin(entity from, entity to, vector org)
{
	if(from.WarpZone_refsys)
		org = WarpZone_UnTransformOrigin(from.WarpZone_refsys, org);
	if(to.WarpZone_refsys)
		org = WarpZone_TransformOrigin(to.WarpZone_refsys, org);
	return org;
}
vector WarpZone_RefSys_TransformVelocity(entity from, entity to, vector vel)
{
	if(from.WarpZone_refsys)
		vel = WarpZone_UnTransformVelocity(from.WarpZone_refsys, vel);
	if(to.WarpZone_refsys)
		vel = WarpZone_TransformVelocity(to.WarpZone_refsys, vel);
	return vel;
}
vector WarpZone_RefSys_TransformAngles(entity from, entity to, vector ang)
{
	if(from.WarpZone_refsys)
		ang = WarpZone_UnTransformAngles(from.WarpZone_refsys, ang);
	if(to.WarpZone_refsys)
		ang = WarpZone_TransformAngles(to.WarpZone_refsys, ang);
	return ang;
}
vector WarpZone_RefSys_TransformVAngles(entity from, entity to, vector ang)
{
	if(from.WarpZone_refsys)
		ang = WarpZone_UnTransformVAngles(from.WarpZone_refsys, ang);
	if(to.WarpZone_refsys)
		ang = WarpZone_TransformVAngles(to.WarpZone_refsys, ang);
	return ang;
}
entity WarpZone_RefSys_SpawnSameRefSys(entity me)
{
	entity e;
	e = spawn();
	if(me.WarpZone_refsys)
	{
		e.WarpZone_refsys = spawn();
		e.WarpZone_refsys.classname = "warpzone_refsys";
		e.WarpZone_refsys.owner = e;
		e.WarpZone_refsys.think = WarpZone_RefSys_GC;
		e.WarpZone_refsys.nextthink = time + 1;
		e.WarpZone_refsys.warpzone_shift = me.WarpZone_refsys.warpzone_shift;
		e.WarpZone_refsys.warpzone_transform = me.WarpZone_refsys.warpzone_transform;
	}
	return e;
}
