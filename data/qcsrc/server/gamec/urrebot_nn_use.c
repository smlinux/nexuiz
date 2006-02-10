/* --- ClampPointToSpace ---
This function lets the bot know where to go to reach the next navnode.

This is a highly optimized version, it used to also be direction based, so it
was far more accurate. However, this accuracy was so slow, that it was a
show-stopper. Now it merely takes the shortest path to the navnode. Due to this,
navigation gets more and more inaccurate as the navnodes get larger.
A regular indoor map doesn't require navnodes of the kind of size that would
suffer from this. I hope to reinstate direction based some time in the future,
if I get it fast enough.*/

vector(vector point, entity current_space, entity goal_space) ClampPointToSpace =
{
	local float North, South, West, East, Up, Down;
	local float f, f2;
	local vector ret_point, tvec;
	local entity e;

	if (!goal_space)
		goal_space = current_space;

	North = min(current_space.origin_y + current_space.maxs_y, goal_space.origin_y + goal_space.maxs_y);
	South = max(current_space.origin_y + current_space.mins_y, goal_space.origin_y + goal_space.mins_y);
	East = min(current_space.origin_x + current_space.maxs_x, goal_space.origin_x + goal_space.maxs_x);
	West = max(current_space.origin_x + current_space.mins_x, goal_space.origin_x + goal_space.mins_x);
	Up = min(current_space.origin_z + current_space.maxs_z, goal_space.origin_z + goal_space.maxs_z);
	Down = max(current_space.origin_z + current_space.mins_z, goal_space.origin_z + goal_space.mins_z);

	f = (East + West) * 0.5;
	f2 = East - self.maxs_x;
	East = max(f, f2);
	f2 = West - self.mins_x;
	West = min(f, f2);
	f = (North + South) * 0.5;
	f2 = North - self.maxs_y;
	North = max(f, f2);
	f2 = South - self.mins_y;
	South = min(f, f2);
	f = (Up + Down) * 0.5;
	f2 = Up - self.maxs_z;
	Up = max(f, f2);
	f2 = Down - self.mins_z;
	Down = min(f, f2);

	ret_point_x = bound(West, point_x, East);
	ret_point_y = bound(South, point_y, North);
	ret_point_z = bound(Down, point_z, Up);

	e = goal_space.plane_chain;
	while (e)
	{
		tvec = self.maxs;
		if (e.mangle_x < 0)
			tvec_x = self.mins_x;
		if (e.mangle_y < 0)
			tvec_y = self.mins_y;
		if (e.mangle_z < 0)
			tvec_z = self.mins_z;
		tvec += ret_point;
		f = tvec*e.mangle - goal_space.origin*e.mangle-e.delay;
		if (f > 0)
			ret_point = ret_point - f*e.mangle;
		e = e.list;
	}

	return ret_point;
};

entity (entity navn, entity from, entity to) MatchOptPoint =
{
	local float fr, go;
	local entity t;

	if (!from)
		from = navn;
	if (!to)
		to = navn;
	t = navn.optp_chain;
	while (t)
	{
		fr = go = FALSE;
		if (t.link0 == from)
			fr = TRUE;
		if (t.link1)
		{
			if (t.link1 == from)
				fr = TRUE;
			if (t.link2)
			{
				if (t.link2 == from)
					fr = TRUE;
				if (t.link3)
				{
					if (t.link3 == from)
						fr = TRUE;
					if (t.link4)
					{
						if (t.link4 == from)
							fr = TRUE;
						if (t.link5)
						{
							if (t.link5 == from)
								fr = TRUE;
							if (t.link6)
							{
								if (t.link6 == from)
									fr = TRUE;
								if (t.link7)
								{
									if (t.link7 == from)
										fr = TRUE;
									if (t.link8)
									{
										if (t.link8 == from)
											fr = TRUE;
										if (t.link9)
										{
											if (t.link9 == from)
												fr = TRUE;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (t.link10 == from)
			fr = TRUE;
		if (t.link11)
		{
			if (t.link11 == from)
				fr = TRUE;
			if (t.link12)
			{
				if (t.link12 == from)
					fr = TRUE;
				if (t.link13)
				{
					if (t.link13 == from)
						fr = TRUE;
					if (t.link14)
					{
						if (t.link14 == from)
							fr = TRUE;
						if (t.link15)
						{
							if (t.link15 == from)
								fr = TRUE;
							if (t.link16)
							{
								if (t.link16 == from)
									fr = TRUE;
								if (t.link17)
								{
									if (t.link17 == from)
										fr = TRUE;
									if (t.link18)
									{
										if (t.link18 == from)
											fr = TRUE;
										if (t.link19)
										{
											if (t.link19 == from)
												fr = TRUE;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if (fr && go)
			return t;
		t = t.list;
	}
	return world;
};

/* --- PopRoute ---
Traverses the bots goal-list to get a new goal to travel towards*/

void() PopRoute =
{
	self.goallist = self.goalcurrent;
	self.goalcurrent = self.link0;
	self.link0 = self.link1;
	self.link1 = self.link2;
	self.link2 = self.link3;
	self.link3 = self.link4;
	self.link4 = self.link5;
	self.link5 = self.link6;
	self.link6 = self.link7;
	self.link7 = self.link8;
	self.link8 = self.link9;
	self.link9 = self.link10;
	self.link10 = self.link11;
	self.link11 = self.link12;
	self.link12 = self.link13;
	self.link13 = self.link14;
	self.link14 = self.link15;
	self.link15 = self.link16;
	self.link16 = self.link17;
	self.link17 = self.link18;
	self.link18 = self.link19;
	self.link19 = world;
	if (cvar("urrebots_debug"))
	{
		bprint(self.goalcurrent.classname);
		bprint("\n");
	}
};

/* --- PushRoute ---
Adds navnodes to the bots goal-list*/

void(entity e) PushRoute =
{
	self.link19 = self.link18;
	self.link18 = self.link17;
	self.link17 = self.link16;
	self.link16 = self.link15;
	self.link15 = self.link14;
	self.link14 = self.link13;
	self.link13 = self.link12;
	self.link12 = self.link11;
	self.link11 = self.link10;
	self.link10 = self.link9;
	self.link9 = self.link8;
	self.link8 = self.link7;
	self.link7 = self.link6;
	self.link6 = self.link5;
	self.link5 = self.link4;
	self.link4 = self.link3;
	self.link3 = self.link2;
	self.link2 = self.link1;
	self.link1 = self.link0;
	self.link0 = self.goalcurrent;
	self.goalcurrent = e;
};

/* --- ClearRoute ---
Removes all goals from the bots goal-list*/

void() ClearRoute =
{
	self.movepoint = nullvector;
	self.goalcurrent = world;
	self.link0 = world;
	self.link1 = world;
	self.link2 = world;
	self.link3 = world;
	self.link4 = world;
	self.link5 = world;
	self.link6 = world;
	self.link7 = world;
	self.link8 = world;
	self.link9 = world;
	self.link10 = world;
	self.link11 = world;
	self.link12 = world;
	self.link13 = world;
	self.link14 = world;
	self.link15 = world;
	self.link16 = world;
	self.link17 = world;
	self.link18 = world;
	self.link19 = world;
};

/* --- FindCurrentNavNode ---
Returns the current navnode at an origin with a size*/
// FIXME: you can do better
entity(vector org, vector minss, vector maxss) FindCurrentNavNode =
{
	local float f, f2, bad;
	local vector tvec;
	local entity e, plane, best;

	e = navnode_chain;
	while (e)
	{
		bad = FALSE;
		if (boxesoverlap(org, org, e.origin + e.mins, e.origin + e.maxs))
		{
			plane = e.plane_chain;
			while (plane)
			{
				f = org*plane.mangle - e.origin*plane.mangle-plane.delay;
				if (f > 0)
					bad = TRUE;
				plane = plane.list;
			}
			if (!bad)
				return e;
		}
		e = e.list;
	}
	e = navnode_chain;
	while (e)
	{
		bad = FALSE;
		if (boxesoverlap(org + minss, org + maxss, e.origin + e.mins, e.origin + e.maxs))
		{
			plane = e.plane_chain;
			while (plane)
			{
				tvec = maxss;
				if (plane.mangle_x < 0)
					tvec_x = minss_x;
				if (plane.mangle_y < 0)
					tvec_y = minss_y;
				if (plane.mangle_z < 0)
					tvec_z = minss_z;
				tvec += org;
				f = tvec*plane.mangle - e.origin*plane.mangle-plane.delay;
				if (f > 0)
					bad = TRUE;
				plane = plane.list;
			}
			if (!bad)
				return e;
		}
		e = e.list;
	}
	f2 = 10000000;
	e = navnode_chain;
	while (e)
	{
		traceline(org, e.origin, TRUE, world);
		if (trace_fraction == 1)
		{
			f = vlen(org - e.origin);
			if (f < f2)
			{
				best = e;
				f2 = f;
			}
		}
		e = e.list;
	}
	return best;
};

/* --- ToPointInSpace ---
Returns a direction towards a point, inside a navnode
It prefers staying inside a navnode over going towards the point
This function exists to allow the bot to drop off a platform and run
under it, and to avoid getting stuck in corners*/

vector(entity space, vector point) ToPointInSpace =
{
	local float f;
	vector tvec, ret_dir, intonavn, towardspoint;
	local entity e;

	if (self.origin_x + self.mins_x <= space.origin_x + space.mins_x)
		intonavn = '1 0 0';
	else if (self.origin_x + self.maxs_x >= space.origin_x + space.maxs_x)
		intonavn = '-1 0 0';
	if (self.origin_y + self.mins_y <= space.origin_y + space.mins_y)
		intonavn += '0 1 0';
	else if (self.origin_y + self.maxs_y >= space.origin_y + space.maxs_y)
		intonavn += '0 -1 0';
	if (self.origin_z + self.mins_z <= space.origin_z + space.mins_z)
		intonavn += '0 0 1';
	else if (self.origin_z + self.maxs_z >= space.origin_z + space.maxs_z)
		intonavn += '0 0 -1';

	e = space.plane_chain;
	while (e)
	{
		tvec = self.maxs;
		if (e.mangle_x < 0)
			tvec_x = self.mins_x;
		if (e.mangle_y < 0)
			tvec_y = self.mins_y;
		if (e.mangle_z < 0)
			tvec_z = self.mins_z;
		tvec += self.origin;
		f = tvec*e.mangle - space.origin*e.mangle-e.delay;
		if (f > 0)
			intonavn = intonavn - e.mangle;
		e = e.list;
	}
	intonavn = normalize(intonavn);

	towardspoint = normalize(point - self.origin);
	if (!intonavn)
		ret_dir = towardspoint;
	else
	{
		if ((intonavn_x < 0 && towardspoint_x < 0) || (intonavn_x > 0 && towardspoint_x > 0))
			ret_dir_x = towardspoint_x;
		else
			ret_dir_x = intonavn_x;
		if ((intonavn_y < 0 && towardspoint_y < 0) || (intonavn_y > 0 && towardspoint_y > 0))
			ret_dir_y = towardspoint_y;
		else
			ret_dir_y = intonavn_y;
		if ((intonavn_z < 0 && towardspoint_z < 0) || (intonavn_z > 0 && towardspoint_z > 0))
			ret_dir_z = towardspoint_z;
		else
			ret_dir_z = intonavn_z;
	}
	return ret_dir;
};