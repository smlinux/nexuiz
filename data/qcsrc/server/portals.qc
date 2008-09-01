vector fixedvectoangles(vector v)
{
	vector a;
	a = vectoangles(v);
	a_x = -a_x;
	return a;
}

vector Portal_Transform_Apply(vector transform, vector v)
{
	makevectors(transform);
	return v_forward * v_x
	     + v_right   * v_y
		 + v_up      * v_z;
}

vector Portal_Transform_Invert(vector transform)
{
	makevectors(transform);
	// we want angles that turn v_forward into '1 0 0', v_right into '0 1 0' and v_up into '0 0 1'
	// but these are orthogonal unit vectors!
	// so to invert, we can simply vectoangles the TRANSPOSED matrix
	// TODO is this always -transform?
	return fixedvectoangles(
		'1 0 0' * v_forward_x + '0 1 0' * v_right_x + '0 0 1' * v_up_x,
		'1 0 0' * v_forward_y + '0 1 0' * v_right_y + '0 0 1' * v_up_y
	);
}

vector Portal_Transform_Multiply(vector t1, vector t2)
{
	vector vx, vy;
	makevectors(t2); vx = v_forward; vy = v_right;
	vx = Portal_Transform_Apply(t1, vx);
	vy = Portal_Transform_Apply(t1, vy);
	return fixedvectoangles(vx, vy);
}

vector Portal_Transform_Divide(vector to_transform, vector from_transform)
{
	return Portal_Transform_Multiply(to_transform, Portal_Transform_Invert(from_transform));
}

void Portal_TeleportPlayer(entity teleporter, entity player)
{
	vector to, transform;
	to = teleporter.velocity;
	transform = teleporter.mangle;
	TeleportPlayer(teleporter, player, to, Portal_Transform_Multiply(transform, player.angles), Portal_Transform_Apply(transform, player.velocity));
}

float Portal_Fix(entity teleporter)
{
	teleporter.mins = PL_MIN - '2 2 2';
	teleporter.maxs = PL_MAX + '2 2 2';
	return move_out_of_solid(teleporter);
}

void Portal_Connect(entity teleporter, entity destination)
{
	teleporter.mangle = Portal_Transform_Divide(-(destination.angles), teleporter.angles);
	teleporter.touch = Portal_Touch;
	teleporter.cnt = 0;
	destination.touch = SUB_Null;
	destination.cnt = 1;
}

entity Portal_Spawn(entity own, vector org, vector ang)
{
	entity portal;
	portal = spawn();
	portal.classname = "portal";
	portal.owner = own;
	portal.origin = org;
	portal.angles = ang;
	setmodel(portal, ...);
}
