..entity owned_by_field;
.float rule;
.string model1;
.string model2;
.string model3;

.float(entity) waypointsprite_visible_for_player;

void WaypointSprite_UpdateSprites(entity e, string m1, string m2, string m3)
{
	if(m1 != e.model1)
	{
		e.model1 = m1;
		e.SendFlags |= 2;
	}
	if(m2 != e.model2)
	{
		e.model2 = m2;
		e.SendFlags |= 4;
	}
	if(m3 != e.model3)
	{
		e.model3 = m3;
		e.SendFlags |= 8;
	}
}

void WaypointSprite_UpdateOrigin(entity e, vector o)
{
	if(o != e.origin)
	{
		setorigin(e, o);
		e.SendFlags |= 64;
	}
}

void WaypointSprite_UpdateRule(entity e, float t, float r)
{
	// no check, as this is never called without doing an actual change (usually only once)
	e.rule = r;
	e.team = t;
	e.SendFlags |= 1;
}

void WaypointSprite_UpdateTeamRadar(entity e, float icon, vector col)
{
	// no check, as this is never called without doing an actual change (usually only once)
	e.cnt = (icon & 0x7F) | (e.cnt & 0x80);
	e.colormod = col;
	e.SendFlags |= 32;
}

void WaypointSprite_Ping(entity e)
{
	// ALWAYS sends (this causes a radar circle), thus no check
	e.cnt |= 0x80;
	e.SendFlags |= 32;
}

void WaypointSprite_FadeOutIn(entity e, float t)
{
	if(!e.health)
	{
		e.health = t;
		e.teleport_time = time + t;
	}
	else if(t < (e.teleport_time - time))
	{
		// accelerate the waypoint's dying
		// ensure:
		//   (e.teleport_time - time) / wp.health stays
		//   e.teleport_time = time + fadetime
		float current_fadetime;
		current_fadetime = e.teleport_time - time;
		e.teleport_time = time + t;
		e.health = e.health * t / current_fadetime;
	}

	e.SendFlags |= 16;
}

float waypointsprite_limitedrange, waypointsprite_deployed_lifetime, waypointsprite_deadlifetime;
void WaypointSprite_Init()
{
	waypointsprite_limitedrange = cvar("g_waypointsprite_limitedrange");
	waypointsprite_deployed_lifetime = cvar("g_waypointsprite_deployed_lifetime");
	waypointsprite_deadlifetime = cvar("g_waypointsprite_deadlifetime");
}
void WaypointSprite_InitClient(entity e)
{
}

void WaypointSprite_Kill(entity wp)
{
	if(!wp)
		return;
	if(wp.owner)
		wp.owner.(wp.owned_by_field) = world;
	remove(wp);
}

void WaypointSprite_Disown(entity wp, float fadetime)
{
	if(!wp)
		return;
	if(wp.classname != "sprite_waypoint")
	{
		backtrace("Trying to disown a non-waypointsprite");
		return;
	}
	if(wp.owner)
	{
		if(wp.exteriormodeltoclient == wp.owner)
			wp.exteriormodeltoclient = world;
		wp.owner.(wp.owned_by_field) = world;
		wp.owner = world;

		WaypointSprite_FadeOutIn(wp, fadetime);
	}
}

void WaypointSprite_Think()
{
	float doremove;

	doremove = FALSE;

	if(self.health)
	{
		if(time >= self.teleport_time)
			doremove = TRUE;
	}

	if(self.exteriormodeltoclient)
		WaypointSprite_UpdateOrigin(self, self.exteriormodeltoclient.origin + self.view_ofs);

	if(doremove)
		WaypointSprite_Kill(self);
	else
		self.nextthink = time; // WHY?!?
}

float WaypointSprite_visible_for_player(entity e)
{
	// personal waypoints
	if(self.enemy)
		if(self.enemy != other)
			return FALSE;

	// team waypoints
	if(self.team && self.rule == SPRITERULE_DEFAULT)
	{
		if(self.team != other.team)
			return FALSE;
		if(other.classname != "player")
			return FALSE;
	}

	return TRUE;
}

float WaypointSprite_Customize()
{
	// this is not in SendEntity because it shall run every frame, not just every update

	return self.waypointsprite_visible_for_player(other);
}

float WaypointSprite_SendEntity(entity to, float sendflags)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_WAYPOINT);
	WriteByte(MSG_ENTITY, sendflags);

	if(sendflags & 64)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
	}

	if(sendflags & 1)
	{
		WriteByte(MSG_ENTITY, self.team);
		WriteByte(MSG_ENTITY, self.rule);
	}

	if(sendflags & 2)
		WriteString(MSG_ENTITY, self.model1);

	if(sendflags & 4)
		WriteString(MSG_ENTITY, self.model2);

	if(sendflags & 8)
		WriteString(MSG_ENTITY, self.model3);

	if(sendflags & 16)
	{
		WriteCoord(MSG_ENTITY, self.health);
		WriteCoord(MSG_ENTITY, self.teleport_time);
		WriteShort(MSG_ENTITY, self.max_health); // maxdist
		float f;
		f = 0;
		if(self.currentammo)
			f |= 1; // hideable
		if(self.exteriormodeltoclient == to)
			f |= 2; // my own
		WriteByte(MSG_ENTITY, f);
	}

	if(sendflags & 32)
	{
		WriteByte(MSG_ENTITY, self.cnt); // icon on radar
		WriteByte(MSG_ENTITY, self.colormod_x * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_y * 255.0);
		WriteByte(MSG_ENTITY, self.colormod_z * 255.0);
	}

	return TRUE;
}

void WaypointSprite_Reset()
{
	// if a WP wants to time out, let it time out immediately; other WPs ought to be reset/killed by their owners

	if(self.health) // there was there before: || g_keyhunt, do we really need this?
		WaypointSprite_Kill(self);
}

entity WaypointSprite_Spawn(
	string spr, // sprite
	float lifetime, float maxdistance, // lifetime, max distance
	entity ref, vector ofs, // position
	entity showto, float t, // show to whom? Use a flag to indicate a team
	entity own, .entity ownfield, // remove when own gets killed
	float hideable // true when it should be controlled by cl_hidewaypoints
)
{
	entity wp;
	wp = spawn();
	wp.classname = "sprite_waypoint";
	wp.teleport_time = time + lifetime;
	wp.health = lifetime;
	wp.exteriormodeltoclient = ref;
	if(ref)
	{
		wp.view_ofs = ofs;
		setorigin(wp, ref.origin + ofs);
	}
	else
		setorigin(wp, ofs);
	wp.enemy = showto;
	wp.team = t;
	wp.owner = own;
	wp.currentammo = hideable;
	if(own)
	{
		if(own.ownfield)
			remove(own.ownfield);
		own.ownfield = wp;
		wp.owned_by_field = ownfield;
	}
	wp.max_health = maxdistance;
	wp.think = WaypointSprite_Think;
	wp.nextthink = time;
	wp.model1 = spr;
	wp.customizeentityforclient = WaypointSprite_Customize;
	wp.waypointsprite_visible_for_player = WaypointSprite_visible_for_player;
	wp.reset2 = WaypointSprite_Reset;
	Net_LinkEntity(wp, FALSE, 0, WaypointSprite_SendEntity);
	return wp;
}

entity WaypointSprite_SpawnFixed(
	string spr,
	vector ofs,
	entity own,
	.entity ownfield
)
{
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, world, 0, own, ownfield, TRUE);
}

.entity waypointsprite_deployed_fixed;
entity WaypointSprite_DeployFixed(
	string spr,
	float limited_range,
	vector ofs
)
{
	float t, maxdistance;
	if(teams_matter)
		t = self.team;
	else
		t = 0;
	if(limited_range)
		maxdistance = waypointsprite_limitedrange;
	else
		maxdistance = 0;
	return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, world, ofs, world, t, self, waypointsprite_deployed_fixed, FALSE);
}

.entity waypointsprite_deployed_personal;
entity WaypointSprite_DeployPersonal(
	string spr,
	vector ofs
)
{
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, world, 0, self, waypointsprite_deployed_personal, FALSE);
}

.entity waypointsprite_attached;
.entity waypointsprite_attachedforcarrier;
entity WaypointSprite_Attach(
	string spr,
	float limited_range
)
{
	float t, maxdistance;
	if(self.waypointsprite_attachedforcarrier)
		return world; // can't attach to FC
	if(teams_matter)
		t = self.team;
	else
		t = 0;
	if(limited_range)
		maxdistance = waypointsprite_limitedrange;
	else
		maxdistance = 0;
	return WaypointSprite_Spawn(spr, waypointsprite_deployed_lifetime, maxdistance, self, '0 0 64', world, t, self, waypointsprite_attached, FALSE);
}

entity WaypointSprite_AttachCarrier(
	string spr,
	entity carrier
)
{
	WaypointSprite_Kill(carrier.waypointsprite_attached); // FC overrides attached
	return WaypointSprite_Spawn(spr, 0, 0, carrier, '0 0 64', world, carrier.team, carrier, waypointsprite_attachedforcarrier, FALSE);
}

void WaypointSprite_DetachCarrier(entity carrier)
{
	WaypointSprite_Disown(carrier.waypointsprite_attachedforcarrier, waypointsprite_deadlifetime);
}

void WaypointSprite_ClearPersonal()
{
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
}

void WaypointSprite_ClearOwned()
{
	WaypointSprite_Kill(self.waypointsprite_deployed_fixed);
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
	WaypointSprite_Kill(self.waypointsprite_attached);
}

void WaypointSprite_PlayerDead()
{
	WaypointSprite_Disown(self.waypointsprite_attached, waypointsprite_deadlifetime);
	WaypointSprite_DetachCarrier(self);
}

void WaypointSprite_PlayerGone()
{
	WaypointSprite_Disown(self.waypointsprite_deployed_fixed, waypointsprite_deadlifetime);
	WaypointSprite_Kill(self.waypointsprite_deployed_personal);
	WaypointSprite_Disown(self.waypointsprite_attached, waypointsprite_deadlifetime);
	WaypointSprite_DetachCarrier(self);
}
