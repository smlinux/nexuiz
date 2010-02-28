void WarpZone_TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity, vector telefragmin, vector telefragmax, float tflags)
{
	vector from;

	makevectors (to_angles);

	from = player.origin;
	setorigin (player, to);
	player.oldorigin = to; // for DP's unsticking
	player.angles = to_angles;
	player.fixangle = TRUE;
	player.velocity = to_velocity;

	if(player.effects & EF_TELEPORT_BIT)
		player.effects &~= EF_TELEPORT_BIT;
	else
		player.effects |= EF_TELEPORT_BIT;

	if(player.classname == "player")
		player.flags &~= FL_ONGROUND;

	WarpZone_PostTeleportPlayer(player);
}

// the transform
.vector warpzone_origin, warpzone_angles;
.vector warpzone_forward;
.vector warpzone_transform;

float WarpZone_Teleport(entity player)
{
	vector o0, a0, v0, o1, a1, v1;

	o0 = player.origin + player.view_ofs;
	v0 = player.velocity;
	a0 = player.angles;

	if((o0 - self.warpzone_origin) * self.warpzone_forward >= 0) // wrong side of the portal
		return 2;
	// no failure, we simply don't want to teleport yet; TODO in
	// this situation we may want to create a temporary clone
	// entity of the player to fix graphics glitch

	o1 = AnglesTransform_Apply(self.warpzone_transform, o0 - self.warpzone_origin) + self.enemy.warpzone_origin;
	v1 = AnglesTransform_Apply(self.warpzone_transform, v0);
	if(player.classname == "player")
		a1 = WarpZone_TransformVAngles(self.warpzone_transform, player.v_angle);
	else
		a1 = AnglesTransform_ApplyToAngles(self.warpzone_transform, a0);

	// put him inside solid
	tracebox(o1 - player.view_ofs, player.mins, player.maxs, o1 - player.view_ofs, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		vector mi, ma;
		mi = player.mins;
		ma = player.maxs;
		setsize(player, mi - player.view_ofs, ma - player.view_ofs);
		setorigin(player, o1);
		if(WarpZoneLib_MoveOutOfSolid(player))
		{
			o1 = player.origin;
			setsize(player, mi, ma);
			setorigin(player, o0);
		}
		else
		{
			print("would have to put player in solid, won't do that\n");
			setsize(player, mi, ma);
			setorigin(player, o0 - player.view_ofs);
			return 0; // cannot fix
		}
	}

	if((o1 - self.enemy.warpzone_origin) * self.enemy.warpzone_forward <= 0) // wrong side of the portal post-teleport
	{
		print("inconsistent warp zones or evil roundoff error\n");
		return 0;
	}

	//print(sprintf("warpzone: %f %f %f -> %f %f %f\n", o0_x, o0_y, o0_z, o1_x, o1_y, o1_z));

	//o1 = trace_endpos;
	TeleportPlayer(self, other, o1 - player.view_ofs, a1, v1, '0 0 0', '0 0 0', TELEPORT_FLAGS_WARPZONE);

	return 1;
}

void WarpZone_Touch (void)
{
	entity oldself, e;

	// FIXME needs a better check to know what is safe to teleport and what not
	if(other.movetype == MOVETYPE_NONE)
		return;

	if(WarpZoneLib_ExactTrigger_Touch())
		return;

	e = self.enemy;
	if(WarpZone_Teleport(other))
	{
		if(self.aiment.target)
		{
			oldself = self;
			activator = other;
			self = self.aiment;
			SUB_UseTargets();
			self = oldself;
		}
	}
	else
	{
		dprint("WARPZONE FAIL AHAHAHAHAH))\n");
	}
}

float WarpZone_Send(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_WARPZONE);

	// we need THESE to render the warpzone (and cull properly)...
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);

	WriteShort(MSG_ENTITY, self.modelindex);
	WriteCoord(MSG_ENTITY, self.mins_x);
	WriteCoord(MSG_ENTITY, self.mins_y);
	WriteCoord(MSG_ENTITY, self.mins_z);
	WriteCoord(MSG_ENTITY, self.maxs_x);
	WriteCoord(MSG_ENTITY, self.maxs_y);
	WriteCoord(MSG_ENTITY, self.maxs_z);

	// we need THESE to calculate the proper transform
	WriteCoord(MSG_ENTITY, self.warpzone_origin_x);
	WriteCoord(MSG_ENTITY, self.warpzone_origin_y);
	WriteCoord(MSG_ENTITY, self.warpzone_origin_z);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_x);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_y);
	WriteCoord(MSG_ENTITY, self.warpzone_angles_z);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_origin_x);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_origin_y);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_origin_z);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_angles_x);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_angles_y);
	WriteCoord(MSG_ENTITY, self.enemy.warpzone_angles_z);

	return TRUE;
}

void WarpZone_InitStep_SpawnFunc()
{
	// warp zone entities must have:
	// "killtarget" pointing to a target_position with a direction arrow
	//              that points AWAY from the warp zone, and that is inside
	//              the warp zone trigger
	// "target"     pointing to an identical warp zone at another place in
	//              the map, with another killtarget to designate its
	//              orientation

	string m;
	m = self.model;
	WarpZoneLib_ExactTrigger_Init();
	setmodel(self, m);
	self.SendEntity = WarpZone_Send;
	self.SendFlags = 0xFFFFFF;
	self.effects |= EF_NODEPTHTEST;
}

void WarpZone_InitStep_FindTarget()
{
	entity e;

	if(self.killtarget == "")
	{
		objerror("Warp zone with no killtarget");
		return;
	}
	self.aiment = find(world, targetname, self.killtarget);
	if(self.aiment == world)
	{
		objerror("Warp zone with nonexisting killtarget");
		return;
	}

	// this way only one of the two ents needs to target
	if(self.target != "")
	{
		e = find(world, targetname, self.target);
		if(e)
		{
			self.enemy = e;
			self.enemy.enemy = self;
		}
	}
}

void WarpZone_InitStep_UpdateTransform()
{
	if(!self.enemy || self.enemy.enemy != self)
	{
		objerror("Invalid warp zone detected. Killed.");
		return;
	}

	// 1. update this, and the enemy, warp zone
	self.warpzone_origin = self.aiment.origin;
	self.warpzone_angles = self.aiment.angles;
	self.enemy.warpzone_origin = self.enemy.aiment.origin;
	self.enemy.warpzone_angles = self.enemy.aiment.angles;

	// 2. combine the angle transforms
	//    current forward must be turned into previous backward
	self.warpzone_transform = AnglesTransform_Divide(AnglesTransform_TurnDirectionFR(self.enemy.warpzone_angles), self.warpzone_angles);

	// 3. store off a saved forward vector for plane hit decisions
	fixedmakevectors(self.warpzone_angles);
	self.warpzone_forward = v_forward;

	// now enable touch
	self.touch = WarpZone_Touch;

	// our mins/maxs are set to the warpzone... so all we need:
	self.flags |= FL_CAMERA;
	self.view_ofs = self.enemy.warpzone_origin;
}

void WarpZone_TraceBox(vector org, vector mi, vector ma, vector end, float nomonsters, entity forent)
{
	float frac, sol;
	vector o0, e0;
	o0 = org;
	e0 = end;
	WarpZone_MakeAllSolid();
	sol = -1;
	frac = 0;
	for(;;)
	{
		tracebox(org, mi, ma, end, nomonsters, forent);
		if(sol < 0)
			sol = trace_startsolid;
		if(trace_fraction >= 1)
			break;
		frac = trace_fraction = frac + (1 - frac) * trace_fraction;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = AnglesTransform_Apply(trace_ent.warpzone_transform, trace_endpos - trace_ent.warpzone_origin) + trace_ent.enemy.warpzone_origin;
		end = AnglesTransform_Apply(trace_ent.warpzone_transform, end - trace_ent.warpzone_origin) + trace_ent.enemy.warpzone_origin;
	}
	WarpZone_MakeAllOther();
	WarpZone_trace_endpos = o0 + (e0 - o0) * trace_fraction;
}

void WarpZone_TraceLine(vector org, vector end, float nomonsters, entity forent)
{
	WarpZone_TraceBox(org, '0 0 0', '0 0 0', end, nomonsters, forent);
}

void WarpZone_TrailParticles(entity own, float eff, vector org, vector end)
{
	float frac, sol;
	WarpZone_MakeAllSolid();
	sol = -1;
	frac = 0;
	for(;;)
	{
		traceline(org, end, MOVE_NOMONSTERS, world);
		if(sol < 0)
			sol = trace_startsolid;
		//print(vtos(org), " to ", vtos(trace_endpos), "\n");
		trailparticles(own, eff, org, trace_endpos);
		if(trace_fraction >= 1)
			break;
		if(trace_ent.classname != "trigger_warpzone")
			break;
		// we hit a warpzone... so, let's perform the trace after the warp again
		org = AnglesTransform_Apply(trace_ent.warpzone_transform, trace_endpos - trace_ent.warpzone_origin) + trace_ent.enemy.warpzone_origin;
		end = AnglesTransform_Apply(trace_ent.warpzone_transform, end - trace_ent.warpzone_origin) + trace_ent.enemy.warpzone_origin;
	}
	WarpZone_MakeAllOther();
}
