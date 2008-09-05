.vector portal_transform;
.vector portal_safe_origin;
.float portal_wants_to_vanish;
.float portal_activatetime;
.float portal_id;

.entity portal_in, portal_out;

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
	return vectoangles2(m_forward, m_up);
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
	v = vectoangles2(i_forward, i_up);
	print("Transform: ", vtos(transform), "\n");
	print("Inverted: ", vtos(v), "\n");
	print("Verify: ", vtos(Portal_Transform_Multiply(v, transform)), "\n");
	fixedmakevectors(Portal_Transform_Multiply(v, transform));
	print("Verify: ", vtos(v_forward), "\n");
	print("Verify: ", vtos(v_right), "\n");
	print("Verify: ", vtos(v_up), "\n");
#endif
	return vectoangles2(i_forward, i_up);
}

vector Portal_Transform_TurnDirection(vector transform)
{
	// turn 180 degrees around v_up
	// changes in-direction to out-direction
	fixedmakevectors(transform);
	return vectoangles2(-1 * v_forward, 1 * v_up);
}

vector Portal_Transform_Divide(vector to_transform, vector from_transform)
{
	return Portal_Transform_Multiply(to_transform, Portal_Transform_Invert(from_transform));
}

float PlayerEdgeDistance(entity p, vector v)
{
	vector vbest;

	if(v_x < 0) vbest_x = p.mins_x; else vbest_x = p.maxs_x;
	if(v_y < 0) vbest_y = p.mins_y; else vbest_y = p.maxs_y;
	if(v_z < 0) vbest_z = p.mins_z; else vbest_z = p.maxs_z;

	return vbest * v;
}

.vector right_vector;
float Portal_TeleportPlayer(entity teleporter, entity player)
{
	vector from, to, safe, step, transform, ang, newvel;
	float planeshift, s, t;
	from = teleporter.origin;
	transform = teleporter.portal_transform;

	to = teleporter.enemy.origin;
	to = to + Portal_Transform_Apply(teleporter.portal_transform, player.origin - from);
	newvel = Portal_Transform_Apply(transform, player.velocity);
	// this now is INSIDE the plane... can't use that
	
	// shift it out
	fixedmakevectors(teleporter.enemy.angles);

	// first shift it ON the plane if needed
	planeshift = ((teleporter.enemy.origin - to) * v_forward) + PlayerEdgeDistance(player, v_forward);
	if(planeshift > 0)
		to += newvel * (planeshift / (newvel * v_forward));
	
	s = bound(-48, (to - teleporter.enemy.origin) * v_right, 48);
	t = bound(-48, (to - teleporter.enemy.origin) * v_up, 48);
	to = teleporter.enemy.origin
	   + (to * v_forward) * v_forward
	   +     s            * v_right
	   +     t            * v_up;

	safe = teleporter.enemy.portal_safe_origin; // a valid player origin
	step = to + ((safe - to) * v_forward) * v_forward;
	tracebox(safe, PL_MIN, PL_MAX, step, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		bprint("'safe' teleport location is not safe!\n");
		// FAIL TODO why does this happen?
		return 0;
	}
	safe = trace_endpos;
	tracebox(safe, PL_MIN, PL_MAX, to, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
		error("trace_endpos in solid!");
	to = trace_endpos;

	// ang_x stuff works around weird quake angles
	if(player.classname == "player")
	{
		ang = player.v_angle;
		ang_x = -ang_x;
		ang = Portal_Transform_Multiply(transform, ang);
		ang_z = player.angles_z;
	}
	else
	{
		ang = player.angles;
		ang_x = -ang_x;
		ang = Portal_Transform_Multiply(transform, player.angles);
	}
	ang_x = -ang_x;

	// factor -1 allows chaining portals, but may be weird
	player.right_vector = -1 * Portal_Transform_Apply(transform, player.right_vector);

	if(player.flagcarried)
		DropFlag(player.flagcarried);
	TeleportPlayer(teleporter, player, to, ang, newvel, teleporter.enemy.absmin, teleporter.enemy.absmax);

	// reset fade counter
	teleporter.portal_wants_to_vanish = 0;
	teleporter.fade_time = time + 15;
	teleporter.enemy.health = 300;

	return 1;
}

float Portal_FindSafeOrigin(entity portal)
{
	vector o;
	o = portal.origin;
	portal.mins = PL_MIN - '8 8 8';
	portal.maxs = PL_MAX + '8 8 8';
	fixedmakevectors(portal.angles);
	portal.origin += 16 * v_forward;
	if(!move_out_of_solid(portal))
	{
#ifdef DEBUG
		print("NO SAFE ORIGIN\n");
#endif
		return 0;
	}
	portal.portal_safe_origin = portal.origin;
	setorigin(portal, o);
	return 1;
}

void Portal_Touch()
{
	if(other.classname == "porto")
	{
		if(other.portal_id == self.portal_id)
			return;
	}
	if(time < self.portal_activatetime)
		if(other == self.owner)
		{
			self.portal_activatetime = time + 0.1;
			return;
		}
	fixedmakevectors(self.angles);
	if((other.origin - self.origin) * v_forward < 0)
		return;
	if(other.mins_x < PL_MIN_x || other.mins_y < PL_MIN_y || other.mins_z < PL_MIN_z
	|| other.maxs_x > PL_MAX_x || other.maxs_y > PL_MAX_y || other.maxs_z > PL_MAX_z)
	{
		// can't teleport this
		return;
	}
	if(Portal_TeleportPlayer(self, other))
		if(other.classname == "porto")
			if(other.cnt == 0)
				other.cnt = 1;
}

void Portal_MakeBrokenPortal(entity portal)
{
	portal.solid = SOLID_NOT;
	portal.touch = SUB_Null;
	portal.effects = 0;
	//portal.colormod = '1 1 1';
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_NO;
}

void Portal_MakeWaitingPortal(entity portal)
{
	portal.solid = SOLID_NOT;
	portal.touch = SUB_Null;
	portal.effects = EF_ADDITIVE;
	portal.colormod = '1 1 1';
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_YES;
}

void Portal_MakeInPortal(entity portal)
{
	portal.solid = SOLID_TRIGGER;
	portal.touch = Portal_Touch;
	portal.effects = EF_RED;
	portal.colormod = '1 0 0';
	portal.nextthink = time;
	portal.takedamage = DAMAGE_NO;
}

void Portal_MakeOutPortal(entity portal)
{
	portal.solid = SOLID_NOT;
	portal.touch = SUB_Null;
	portal.effects = EF_STARDUST | EF_BLUE;
	portal.colormod = '0 0 1';
	portal.nextthink = 0;
	portal.takedamage = DAMAGE_YES;
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
	teleporter.portal_transform = Portal_Transform_Divide(Portal_Transform_TurnDirection(destination.angles), teleporter.angles);

#ifdef DEBUG
	{
		// let's verify the transform
		vector in_f, in_r, in_u;
		vector out_f, out_r, out_u;
		fixedmakevectors(teleporter.angles);
		in_f = v_forward;
		in_r = v_right;
		in_u = v_up;
		print("teleporter: ", vtos(in_f), " ", vtos(in_r), " ", vtos(in_u), "\n");
		fixedmakevectors(destination.angles);
		out_f = v_forward;
		out_r = v_right;
		out_u = v_up;
		print("dest: ", vtos(out_f), " ", vtos(out_r), " ", vtos(out_u), "\n");
		// INTENDED TRANSFORM:
		//   in_f -> -out_f
		//   in_r -> -out_r
		//   in_u -> +out_u
		print("FORWARD: ", vtos(in_f), " -> ", vtos(Portal_Transform_Apply(teleporter.portal_transform, in_f)), ", should be", vtos(-1 * out_f), "\n");
		print("RIGHT: ", vtos(in_r), " -> ", vtos(Portal_Transform_Apply(teleporter.portal_transform, in_r)), ", should be", vtos(-1 * out_r), "\n");
		print("UP: ", vtos(in_u), " -> ", vtos(Portal_Transform_Apply(teleporter.portal_transform, in_u)), ", should be", vtos(out_u), "\n");

		te_lightning3(world, teleporter.origin, teleporter.origin + in_r * 1000);
		te_lightning3(world, destination.origin, destination.origin + out_r * 1000);
	}
#endif

	teleporter.enemy = destination;
	destination.enemy = teleporter;
	Portal_MakeInPortal(teleporter);
	Portal_MakeOutPortal(destination);
	teleporter.fade_time = time + 15;
	destination.fade_time = time + 15;
	teleporter.portal_wants_to_vanish = 0;
	destination.portal_wants_to_vanish = 0;
}

void Portal_Remove(entity portal, float killed)
{
	entity e;
	e = portal.enemy;

	if(e)
	{
		Portal_Disconnect(portal, e);
		Portal_Remove(e, killed);
	}

	if(portal == portal.owner.portal_in)
		portal.owner.portal_in = world;
	if(portal == portal.owner.portal_out)
		portal.owner.portal_out = world;
	portal.owner = world;

	// makes the portal vanish
	if(killed)
	{
		fixedmakevectors(portal.angles);
		pointparticles(particleeffectnum("rocket_explode"), portal.origin + v_forward * 16, v_forward * 1024, 4);
		remove(portal);
	}
	else
	{
		Portal_MakeBrokenPortal(portal);
		SUB_SetFade(portal, time, 0.5);
	}
}

void Portal_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(deathtype == DEATH_TELEFRAG)
		return;
	self.health -= damage;
	if(self.health < 0)
	{
		Portal_Remove(self, 1);
	}
}

void Portal_Think()
{
	entity e, o;

	if(self.solid != SOLID_TRIGGER)
		error("Portal_Think called for a portal that should not be thinking");

	o = self.owner;
	self.solid = SOLID_BBOX;
	self.owner = world;
	FOR_EACH_PLAYER(e)
	{
		if(time < self.portal_activatetime)
			if(e == o)
				continue;
		// if e would hit the portal in a frame...
		// already teleport him
		tracebox(e.origin, e.mins, e.maxs, e.origin + e.velocity * 2 * frametime, MOVE_NORMAL, e);
		if(trace_ent == self)
			Portal_TeleportPlayer(self, e);
	}
	self.solid = SOLID_TRIGGER;
	self.owner = o;

	self.nextthink = time;

	if(time > self.fade_time)
		Portal_Remove(self, 0);
}


// cleanup:
//   when creating in-portal:
//     disconnect
//     clear existing in-portal
//     set as in-portal
//     connect
//   when creating out-portal:
//     disconnect
//     clear existing out-portal
//     set as out-portal
//   when player dies:
//     disconnect portals
//     clear both portals
//   after timeout of in-portal:
//     disconnect portals
//     clear both portals
//   TODO: ensure only one portal shot at once
float Portal_SetInPortal(entity own, entity portal)
{
	if(own.portal_in)
	{
		if(own.portal_out)
			Portal_Disconnect(own.portal_in, own.portal_out);
		Portal_Remove(own.portal_in, 0);
	}
	own.portal_in = portal;
	if(own.portal_out)
		Portal_Connect(own.portal_in, own.portal_out);
	return 2;
}
float Portal_SetOutPortal(entity own, entity portal)
{
	if(own.portal_out)
	{
		if(own.portal_in)
			Portal_Disconnect(own.portal_in, own.portal_out);
		Portal_Remove(own.portal_out, 0);
	}
	own.portal_out = portal;
	if(own.portal_in)
		Portal_Connect(own.portal_in, own.portal_out);
	return 1;
}
void Portal_ClearAll(entity own)
{
	if(own.portal_in)
		Portal_Remove(own.portal_in, 0);
	if(own.portal_out)
		Portal_Remove(own.portal_out, 0);
}
void Portal_ClearWithID(entity own, float id)
{
	if(own.portal_in)
		if(own.portal_in.portal_id == id)
		{
			if(own.portal_out)
				Portal_Disconnect(own.portal_in, own.portal_out);
			Portal_Remove(own.portal_in, 0);
		}
	if(own.portal_out)
		if(own.portal_out.portal_id == id)
		{
			if(own.portal_in)
				Portal_Disconnect(own.portal_in, own.portal_out);
			Portal_Remove(own.portal_out, 0);
		}
}

entity Portal_Spawn(entity own, vector org, vector ang)
{
	entity portal;

	fixedmakevectors(ang);
	if(!CheckWireframeBox(own, org - 48 * v_right - 48 * v_up + 16 * v_forward, 96 * v_right, 96 * v_up, 96 * v_forward))
		return world;

	portal = spawn();
	portal.classname = "portal";
	portal.owner = own;
	portal.origin = org;
	portal.angles = ang;
	portal.think = Portal_Think;
	portal.nextthink = 0;
	portal.fade_time = time + 15;
	portal.portal_activatetime = time + 0.1;
	portal.event_damage = Portal_Damage;
	portal.health = 300;
	setmodel(portal, "models/portal.md3");

	if(!Portal_FindSafeOrigin(portal))
	{
		remove(portal);
		return world;
	}

	setsize(portal, '-48 -48 -48', '48 48 48');
	Portal_MakeWaitingPortal(portal);

	return portal;
}

float Portal_SpawnInPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	entity portal;
	vector ang;
	vector org;

	if(trace_ent.movetype == MOVETYPE_WALK)
	{
		trace_endpos = trace_ent.origin + '0 0 1' * PL_MIN_z;
		trace_plane_normal = '0 0 1';
		dir = -1 * dir; // create telefrag portals the other way round
	}

	org = trace_endpos;
	ang = vectoangles2(trace_plane_normal, dir);
	fixedmakevectors(ang);

	portal = Portal_Spawn(own, org, ang);
	if(!portal)
	{
		if(!self.portal_out || self.portal_out.portal_id == portal_id_val)
			Portal_ClearAll(own);
		return 0;
	}

	portal.portal_id = portal_id_val;
	Portal_SetInPortal(own, portal);

	return 1;
}

float Portal_SpawnOutPortalAtTrace(entity own, vector dir, float portal_id_val)
{
	entity portal;
	vector ang;
	vector org;

	if(trace_ent.movetype == MOVETYPE_WALK)
	{
		trace_endpos = trace_ent.origin + '0 0 1' * PL_MIN_z;
		trace_plane_normal = '0 0 1';
		dir = -1 * dir; // create telefrag portals the other way round
	}

	org = trace_endpos;
	ang = vectoangles2(trace_plane_normal, dir);
	fixedmakevectors(ang);

	portal = Portal_Spawn(own, org, ang);
	if(!portal)
	{
		if(!self.portal_in || self.portal_in.portal_id == portal_id_val)
			Portal_ClearAll(own);
		return 0;
	}

	portal.portal_id = portal_id_val;
	Portal_SetOutPortal(own, portal);

	return 1;
}
