float waypointsprite_normdistance;
float waypointsprite_minscale;
float waypointsprite_fadedistance;
float waypointsprite_minalpha;
float waypointsprite_distancealphaexponent;
float waypointsprite_timealphaexponent;
float waypointsprite_deployed_lifetime;
float waypointsprite_deadlifetime;
float waypointsprite_limitedrange;

..entity owned_by_field;
.float(entity) waypointsprite_for_player; // returns a model index or 0 for hide
float waypointsprite_for_player_default(entity e)
{
	// personal waypoints
	if(self.enemy)
		if(self.enemy != other)
			return FALSE;

	// team waypoints
	if(self.team)
	{
		if(self.team != other.team)
			return FALSE;
		if(other.classname != "player")
			return FALSE;
	}

	// fixed waypoints
	if(self.currentammo) // hidable?
		if(other.cvar_cl_hidewaypoints) // wants to hide;
			return FALSE;

	// otherwise, accept the model
	return self.modelindex;
}

void WaypointSprite_Init()
{
	waypointsprite_fadedistance = vlen(world.maxs - world.mins);
	waypointsprite_normdistance = cvar("g_waypointsprite_normdistance");
	waypointsprite_minscale = cvar("g_waypointsprite_minscale");
	waypointsprite_minalpha = cvar("g_waypointsprite_minalpha");
	waypointsprite_distancealphaexponent = cvar("g_waypointsprite_distancealphaexponent");
	waypointsprite_timealphaexponent = cvar("g_waypointsprite_timealphaexponent");
	waypointsprite_deployed_lifetime = cvar("g_waypointsprite_deployed_lifetime");
	waypointsprite_deadlifetime = cvar("g_waypointsprite_deadlifetime");
	waypointsprite_limitedrange = cvar("g_waypointsprite_limitedrange");

	precache_model("models/sprites/bluebase.sp2");
	precache_model("models/sprites/flagcarrier.sp2");
	precache_model("models/sprites/here.sp2");
	precache_model("models/sprites/helpme.sp2");
	precache_model("models/sprites/redbase.sp2");
	precache_model("models/sprites/waypoint.sp2");
	precache_model("models/sprites/danger.sp2");
}

void WaypointSprite_InitClient(entity e)
{
	stuffcmd(e, "\nalias \"g_waypointsprite_personal\" \"impulse 30\"\n alias \"g_waypointsprite_personal_p\" \"impulse 31\"\n alias \"g_waypointsprite_personal_d\" \"impulse 32\"\n alias \"g_waypointsprite_team_helpme\" \"impulse 33\"\n alias \"g_waypointsprite_team_here\" \"impulse 34\"\n alias \"g_waypointsprite_team_here_p\" \"impulse 35\"\n alias \"g_waypointsprite_team_here_d\" \"impulse 36\"\n alias \"g_waypointsprite_team_danger\" \"impulse 37\"\n alias \"g_waypointsprite_team_danger_p\" \"impulse 38\"\n alias \"g_waypointsprite_team_danger_d\" \"impulse 39\"\n alias \"g_waypointsprite_clear_personal\" \"impulse 47\"\n alias \"g_waypointsprite_clear\" \"impulse 48\"\n alias \"g_waypointsprite_toggle\" \"impulse 49\"\n");
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
	if(wp.owner)
	{
		if(wp.exteriormodeltoclient == wp.owner)
		{
			setattachment(wp, world, "");
#ifdef ATTACHMENT_WORKS_WITH_EF_NODEPTHTEST
			setorigin(wp, wp.origin + wp.exteriormodeltoclient.origin);
#else
			setorigin(wp, wp.view_ofs + wp.exteriormodeltoclient.origin);
#endif
			wp.exteriormodeltoclient = world;
		}
		wp.owner.(wp.owned_by_field) = world;
		wp.owner = world;

		if(!wp.health)
		{
			wp.health = fadetime;
			wp.teleport_time = time + fadetime;
		}
		else if(fadetime < (wp.teleport_time - time))
		{
			// accelerate the waypoint's dying
			// ensure:
			//   (wp.teleport_time - time) / wp.health stays
			//   wp.teleport_time = time + fadetime
			float current_fadetime;
			current_fadetime = wp.teleport_time - time;
			wp.teleport_time = time + fadetime;
			wp.health = wp.health * fadetime / current_fadetime;
		}
	}
}

void WaypointSprite_Think()
{
	float doremove;

	doremove = FALSE;

	if(self.health)
		if(time >= self.teleport_time)
			doremove = TRUE;

	if(doremove)
		WaypointSprite_Kill(self);
	else
		self.nextthink = time;
}

float WaypointSprite_CustomizeEntityForClient()
{
	vector realorigin, porigin;
	float distancealpha, timealpha;
	float distance;
	float newmodel;

	if(self.health)
	{
		timealpha = bound(0, (self.teleport_time - time) / self.health, 1);
		if(timealpha == 0)
			return FALSE;
		timealpha = pow(timealpha, waypointsprite_timealphaexponent);
	}
	else
		timealpha = 1;

	// customize WP
	newmodel = self.waypointsprite_for_player(other);
	if(newmodel == 0)
		return FALSE;
	self.modelindex = newmodel;

	porigin = other.origin + other.view_ofs_z * '0 0 1';

#ifdef ATTACHMENT_WORKS_WITH_EF_NODEPTHTEST
	realorigin = self.exteriormodeltoclient.origin + self.origin;
#else
	if(self.exteriormodeltoclient)
	{
		if(self.exteriormodeltoclient == other)
		{
			setattachment(self, other, "");
			setorigin(self, self.view_ofs);
			realorigin = other.origin + self.origin;
		}
		else
		{
			setattachment(self, world, "");
			setorigin(self, self.exteriormodeltoclient.origin + self.view_ofs);
			realorigin = self.origin;
		}
	}
	else
		realorigin = self.origin;
#endif

	distance = vlen(realorigin - porigin);

	if(self.max_health)
		if(distance >= self.max_health)
			return FALSE;

	self.scale = max(1, distance / waypointsprite_normdistance) * waypointsprite_minscale;

	if(self.max_health > waypointsprite_normdistance)
	{
		// alpha 1 at normdistance, alpha 0 at maxdistance
		distancealpha = bound(0, (self.max_health - distance) / (self.max_health - waypointsprite_normdistance), 1);
		distancealpha = pow(distancealpha, waypointsprite_distancealphaexponent);
	}
	else if(self.max_health)
	{
		// alpha 1 if visible
		distancealpha = 1;
	}
	else
	{
		// alpha 1 at normdistance, alpha minalpha at fadedistance
		distancealpha = bound(0, (waypointsprite_fadedistance - distance) / (waypointsprite_fadedistance - waypointsprite_normdistance), 1);
		distancealpha = pow(distancealpha, waypointsprite_distancealphaexponent);
		distancealpha = distancealpha * (1 - waypointsprite_minalpha) + waypointsprite_minalpha;
	}

	self.alpha = timealpha * distancealpha;

	return TRUE;
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
#ifdef ATTACHMENT_WORKS_WITH_EF_NODEPTHTEST
		setattachment(wp, ref, "");
		setorigin(wp, ofs);
#else
		wp.view_ofs = ofs;
#endif
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
	wp.customizeentityforclient = WaypointSprite_CustomizeEntityForClient;
	wp.think = WaypointSprite_Think;
	wp.nextthink = time;
	wp.effects = EF_NODEPTHTEST | EF_LOWPRECISION;
	if(spr != "")
		setmodel(wp, strcat("models/sprites/", spr, ".sp2")); // precision set above
	else
		wp.model = "waypoint";
	setsize(wp, '0 0 0', '0 0 0');
	wp.waypointsprite_for_player = waypointsprite_for_player_default;
	return wp;
}

entity WaypointSprite_SpawnFixed(
	string spr,
	vector ofs
)
{
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, world, 0, world, enemy, TRUE);
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
	return WaypointSprite_Spawn(spr, 0, 0, world, ofs, self, 0, self, waypointsprite_deployed_personal, FALSE);
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
