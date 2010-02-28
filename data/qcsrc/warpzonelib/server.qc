.vector warpzone_oldorigin, warpzone_oldvelocity, warpzone_oldangles;
.float warpzone_teleport_time;

void WarpZone_StoreProjectileData(entity e)
{
	e.warpzone_oldorigin = e.origin;
	e.warpzone_oldvelocity = e.velocity;
	e.warpzone_oldangles = e.angles;
}

void WarpZone_TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity)
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

	WarpZone_PostTeleportPlayer_Callback(player);
}

float WarpZone_Teleport(entity player)
{
	vector o0, a0, v0, o1, a1, v1;

	o0 = player.origin + player.view_ofs;
	v0 = player.velocity;
	a0 = player.angles;

	if(WarpZone_PlaneDist(self, o0) >= 0) // wrong side of the portal
		return 2;
	// no failure, we simply don't want to teleport yet; TODO in
	// this situation we may want to create a temporary clone
	// entity of the player to fix graphics glitch

	o1 = WarpZone_TransformOrigin(self, o0);
	v1 = WarpZone_TransformVelocity(self, v0);
	if(player.classname == "player")
		a1 = WarpZone_TransformVAngles(self, player.v_angle);
	else
		a1 = WarpZone_TransformAngles(self, a0);

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

	if(WarpZone_TargetPlaneDist(self, o1) <= 0)
	{
		print("inconsistent warp zones or evil roundoff error\n");
		return 0;
	}

	//print(sprintf("warpzone: %f %f %f -> %f %f %f\n", o0_x, o0_y, o0_z, o1_x, o1_y, o1_z));

	//o1 = trace_endpos;
	WarpZone_RefSys_Add(player, self);
	WarpZone_TeleportPlayer(self, player, o1 - player.view_ofs, a1, v1);
	WarpZone_StoreProjectileData(player);
	player.warpzone_teleport_time = time;

	return 1;
}

void WarpZone_Touch (void)
{
	entity oldself, e;

	if(other.classname == "trigger_warpzone")
		return;

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
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_x);
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_y);
	WriteCoord(MSG_ENTITY, self.warpzone_targetorigin_z);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_x);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_y);
	WriteCoord(MSG_ENTITY, self.warpzone_targetangles_z);

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

	WarpZone_SetUp(self, self.aiment.origin, self.aiment.angles, self.enemy.aiment.origin, self.enemy.aiment.angles);

	// now enable touch
	self.touch = WarpZone_Touch;

	// our mins/maxs are set to the warpzone... so all we need:
	self.flags |= FL_CAMERA;
	self.view_ofs = self.warpzone_targetorigin;
}

float WarpZone_CheckProjectileImpact()
{
	// if self hit a warpzone, abort
	vector o0, v0, a0;
	float mpd, pd, dpd;
	entity wz;
	wz = WarpZone_Find(self.origin + self.mins, self.origin + self.maxs);
	if(!wz)
		return FALSE;
	o0 = self.origin;
	v0 = self.velocity;
	a0 = self.angles;

	// FIXME this code assumes the trace goes through just one warpzone.
	// this approach transports the projectile at its full speed, but does
	// not properly retain the projectile trail (but we can't retain it
	// easily anyway without delaying the projectile by two frames, so who
	// cares)
	WarpZone_trace_angles = self.angles;
	WarpZone_trace_velocity = self.velocity;
	WarpZone_TraceBox(self.warpzone_oldorigin, self.mins, self.maxs, self.warpzone_oldorigin + self.warpzone_oldvelocity * frametime, MOVE_NORMAL, self); // this will get us through the warpzone
	setorigin(self, trace_endpos);
	self.angles = WarpZone_trace_angles;
	self.velocity = WarpZone_trace_velocity;
	
	// in case we are in our warp zone post-teleport, shift the projectile forward a bit
	mpd = max(vlen(self.mins), vlen(self.maxs));
	pd = WarpZone_TargetPlaneDist(wz, self.origin);
	if(pd < mpd)
	{
		dpd = normalize(self.velocity) * self.warpzone_targetforward;
		setorigin(self, self.origin + normalize(self.velocity) * ((mpd - pd) / dpd));
		if(!WarpZoneLib_MoveOutOfSolid(self))
		{
			setorigin(self, o0);
			self.angles = a0;
			self.velocity = v0;
			return FALSE;
		}
	}
	WarpZone_RefSys_Add(self, wz);
	WarpZone_StoreProjectileData(self);
	self.warpzone_teleport_time = time;

	return TRUE;
}
void WarpZone_StartFrame()
{
	entity e;
	for(e = world; (e = nextent(e)); )
		WarpZone_StoreProjectileData(e);
}
float WarpZone_Projectile_Touch()
{
	if(other.classname == "trigger_warpzone")
		return TRUE;
	if(WarpZone_Projectile_Touch_ImpactFilter_Callback())
		return TRUE;
	if(WarpZone_CheckProjectileImpact())
		return TRUE;
	if(self.warpzone_teleport_time == time) // already got teleported this frame? no collision then please
	{
		setorigin(self, self.warpzone_oldorigin);
		self.velocity = self.warpzone_oldvelocity;
		self.angles = self.warpzone_oldangles;
		return TRUE;
	}

	return FALSE;
}
