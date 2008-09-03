.vector portal_transform;
.vector portal_safe_origin;
.float portal_wants_to_vanish;
.float portal_id;
.float portal_activatetime;

.entity portal_in, portal_out;

vector fixedvectoangles(vector v)
{
	vector a;
	a = vectoangles(v);
	a_x = -a_x;
	return a;
}

vector fixedvectoangles2(vector v, vector w)
{
	vector a;
	a = vectoangles2(v, w);
	a_x = -a_x;
	return a;
}

void fixedmakevectors(vector a)
{
	//a_x = -a_x;
	makevectors(a);
}

vector Portal_Transform_Apply(vector transform, vector v)
{
	fixedmakevectors(transform);
	return v_forward * v_x
	     + v_right   * (-v_y)
		 + v_up      * v_z;
}

vector Portal_Transform_Multiply(vector t1, vector t2)
{
	vector m_forward, m_up;
	fixedmakevectors(t2); m_forward = v_forward; m_up = v_up;
	m_forward = Portal_Transform_Apply(t1, m_forward);
	m_up = Portal_Transform_Apply(t1, m_up);
	return fixedvectoangles2(m_forward, m_up);
}

vector Portal_Transform_Invert(vector transform)
{
	vector i_forward, i_up;
	fixedmakevectors(transform);
	// we want angles that turn v_forward into '1 0 0', v_right into '0 1 0' and v_up into '0 0 1'
	// but these are orthogonal unit vectors!
	// so to invert, we can simply vectoangles the TRANSPOSED matrix
	// TODO is this always -transform?
	i_forward_x = v_forward_x;
	i_forward_y = -v_right_x;
	i_forward_z = v_up_x;
	i_up_x = v_forward_z;
	i_up_y = -v_right_z;
	i_up_z = v_up_z;
#ifdef DEBUG
	vector v;
	v = fixedvectoangles2(i_forward, i_up);
	print("Transform: ", vtos(transform), "\n");
	print("Inverted: ", vtos(v), "\n");
	print("Verify: ", vtos(Portal_Transform_Multiply(v, transform)), "\n");
	fixedmakevectors(Portal_Transform_Multiply(v, transform));
	print("Verify: ", vtos(v_forward), "\n");
	print("Verify: ", vtos(v_right), "\n");
	print("Verify: ", vtos(v_up), "\n");
#endif
	return fixedvectoangles2(i_forward, i_up);
}

vector Portal_Transform_TurnDirection(vector transform)
{
	vector t_angles;
	t_angles_x = -transform_x;
	t_angles_y = mod(transform_y + 180, 360);
	t_angles_z = -transform_z;
	return t_angles;
}

vector Portal_Transform_Divide(vector to_transform, vector from_transform)
{
	return Portal_Transform_Multiply(to_transform, Portal_Transform_Invert(from_transform));
}

void Portal_TeleportPlayer(entity teleporter, entity player)
{
	vector from, to, safe, step, transform, ang;
	from = teleporter.origin;
	to = teleporter.enemy.origin;
	transform = teleporter.portal_transform;

	to = to + Portal_Transform_Apply(teleporter.portal_transform, player.origin - from);
	// this now is INSIDE the plane... can't use that

	// shift it out
	fixedmakevectors(teleporter.enemy.mangle);
	safe = teleporter.enemy.portal_safe_origin; // a valid player origin
	step = to + ((safe - to) * v_forward) * v_forward;
	tracebox(safe, PL_MIN, PL_MAX, step, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		bprint("'safe' teleport location is not safe!\n");
		// FAIL TODO why does this happen?
		return;
	}
	safe = trace_endpos;
	tracebox(safe, PL_MIN, PL_MAX, to, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
		error("trace_endpos in solid!");
	to = trace_endpos;

	if(player.classname == "player")
	{
		ang = Portal_Transform_Multiply(transform, player.v_angle);
		ang_z = player.angles_z;
	}
	else
	{
		ang = Portal_Transform_Multiply(transform, player.mangle);
	}

	TeleportPlayer(teleporter, player, to, ang, Portal_Transform_Apply(transform, player.velocity), teleporter.enemy.absmin, teleporter.enemy.absmax);

	// reset fade counter
	teleporter.portal_wants_to_vanish = 0;
	teleporter.fade_time = time + 10;
}

float Portal_FindSafeOrigin(entity portal)
{
	vector o;
	o = portal.origin;
	portal.mins = PL_MIN - '8 8 8';
	portal.maxs = PL_MAX + '8 8 8';
	if(!move_out_of_solid(portal))
	{
		print("NO SAFE ORIGIN\n");
		return 0;
	}
	portal.portal_safe_origin = portal.origin;
	setorigin(portal, o);
	return 1;
}

void Portal_Touch()
{
	if(other.classname == "porto")
		return;
	if(time < self.portal_activatetime)
		if(other == self.owner)
		{
			self.portal_activatetime = time + 0.1;
			return;
		}
	fixedmakevectors(self.mangle);
	if((other.origin - self.origin) * v_forward < 0)
		return;
	if(other.mins_x < PL_MIN_x || other.mins_y < PL_MIN_y || other.mins_z < PL_MIN_z
	|| other.maxs_x > PL_MAX_x || other.maxs_y > PL_MAX_y || other.maxs_z > PL_MAX_z)
	{
		// can't teleport this
		return;
	}
	Portal_TeleportPlayer(self, other);
}

void Portal_MakeBrokenPortal(entity portal)
{
	portal.solid = SOLID_NOT;
	portal.touch = SUB_Null;
	portal.effects = 0;
	portal.colormod = '1 1 1';
}

void Portal_MakeInPortal(entity portal)
{
	portal.solid = SOLID_TRIGGER;
	portal.touch = Portal_Touch;
	portal.effects = EF_RED;
	portal.colormod = '1 0 0';
}

void Portal_MakeOutPortal(entity portal)
{
	portal.solid = SOLID_NOT;
	portal.touch = SUB_Null;
	portal.effects = EF_STARDUST;
	portal.colormod = '0 0 1';
}

void Portal_Disconnect(entity teleporter, entity destination)
{
	teleporter.enemy = world;
	destination.enemy = world;
	Portal_MakeBrokenPortal(teleporter);
	Portal_MakeBrokenPortal(destination);
}

void Portal_Connect(entity teleporter, entity destination)
{
	teleporter.portal_transform = Portal_Transform_Divide(Portal_Transform_TurnDirection(destination.mangle), teleporter.mangle);
	teleporter.enemy = destination;
	destination.enemy = teleporter;
	Portal_MakeInPortal(teleporter);
	Portal_MakeOutPortal(destination);
	teleporter.fade_time = time + 10;
	destination.fade_time = time + 10;
	teleporter.portal_wants_to_vanish = 0;
	destination.portal_wants_to_vanish = 0;
}

void Portal_Think()
{
	entity e, o;
	float m;

	if(self.solid == SOLID_TRIGGER)
	{
		m = self.modelindex;
		o = self.owner;
		self.solid = SOLID_BBOX;
		self.owner = world;
		self.modelindex = 0;
		FOR_EACH_PLAYER(e)
		{
			if(time < self.portal_activatetime)
				if(e == o)
					continue;
			// if e would hit the portal in a frame...
			// already teleport him
			tracebox(e.origin, e.mins, e.maxs, e.origin + e.velocity * 3 * frametime, MOVE_NORMAL, e);
			if(trace_ent == self)
				Portal_TeleportPlayer(self, e);
		}
		self.solid = SOLID_TRIGGER;
		self.owner = o;
		self.modelindex = m;
	}

	self.nextthink = time;

	if(time < self.fade_time)
		return;

	self.portal_wants_to_vanish = 1;

	if(self.enemy)
		if(!self.enemy.portal_wants_to_vanish)
			return;

	SUB_SetFade(self, time + 1, 1);
	if(self.enemy)
	{
		SUB_SetFade(self.enemy, time + 1, 1);
		Portal_Disconnect(self, self.enemy);
	}
}

void Portal_RequestVanish(entity portal)
{
	entity oldself;
	oldself = self;
	self = portal;
	if(self.enemy)
		self.enemy.portal_wants_to_vanish = 1;
	Portal_Think();
	self = oldself;
}

entity Portal_Spawn(entity own, vector org, vector ang)
{
	fixedmakevectors(ang);
	if(!CheckWireframeBox(org - 48 * v_right - 48 * v_up + 16 * v_forward, 96 * v_right, 96 * v_up, 16 * v_forward))
		return world;

	entity portal;
	portal = spawn();
	portal.classname = "portal";
	portal.owner = own;
	portal.origin = org;
	portal.mangle = ang;
	ang_x = -ang_x;
	portal.angles = ang;
	portal.think = Portal_Think;
	portal.nextthink = time;
	portal.fade_time = time + 10;
	portal.portal_activatetime = time + 0.1;
	setmodel(portal, "models/portal.md3");

	if(!Portal_FindSafeOrigin(portal))
	{
		remove(portal);
		return world;
	}

	setsize(portal, '-48 -48 -48', '48 48 48');

	return portal;
}

float Portal_SpawnInPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
		return 0;

	if(trace_ent.classname == "player")
	{
		print("hit a player, adjusting...\n");
		trace_endpos = trace_ent.origin + '0 0 1' * PL_MIN_z;
		trace_plane_normal = '0 0 1';
	}

	if(own.portal_in)
	{
		if(own.portal_out)
		{
			Portal_Disconnect(own.portal_in, own.portal_out);
			Portal_RequestVanish(own.portal_out);
		}
		own.portal_out = own.portal_in;
		own.portal_in = world;
		own.portal_out.portal_id = portal_id_val;
	}
	else if(own.portal_out)
	{
		print("this DID happen, no idea why (1)\n");
		Portal_RequestVanish(own.portal_out);
		own.portal_out = world;
	}
		
	own.portal_in = Portal_Spawn(own, trace_endpos + trace_plane_normal, fixedvectoangles2(trace_plane_normal, dir));
	if(!own.portal_in)
		return 0;
	own.portal_in.portal_id = portal_id_val;

	if(own.portal_out)
		Portal_Connect(own.portal_in, own.portal_out);

	return 1;
}

float Portal_SpawnOutPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		if(own.portal_in.portal_id == portal_id_val)
			Portal_RequestVanish(own.portal_in);
		return 0;
	}

	if(trace_ent.classname == "player")
	{
		print("hit a player, adjusting...\n");
		trace_endpos = trace_ent.origin + '0 0 1' * PL_MIN_z;
		trace_plane_normal = '0 0 1';
		dir = -1 * dir; // fix orientation
	}

	if(!own.portal_in)
		return 0; // sorry

	if(own.portal_in.portal_id != portal_id_val)
		return 0; // we need MATCHING portals

	if(own.portal_out)
	{
		Portal_Disconnect(own.portal_in, own.portal_out);
		Portal_RequestVanish(own.portal_out);
		own.portal_out = world;
	}
		
	own.portal_out = Portal_Spawn(own, trace_endpos + trace_plane_normal, fixedvectoangles2(trace_plane_normal, -1 * dir));
	if(!own.portal_out)
	{
		Portal_RequestVanish(own.portal_in);
		return 0;
	}
	own.portal_out.portal_id = portal_id_val;

	Portal_Connect(own.portal_in, own.portal_out);

	return 1;
}
