void() LinkNavNodes;

float(vector m1, vector m2, vector m3, vector m4) boxesoverlap =
{
	return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;
};

float(entity e, vector start, vector m1, vector m2, vector end) tracewalk =
{
	local vector move;
	local vector dir;
	local vector nostependpos;
	local float dist;
	local float totaldist;
	local float stepdist;
	local float yaw;
	local float ignorehazards;
	local float p;
	local float nostepfrac;
	local entity saveself;
	move = end - start;
	move_z = 0;
	dist = totaldist = vlen(move);
	dir = normalize(move);
	stepdist = 32;
	saveself = self;
	if (!tracewalkent)
		tracewalkent = spawn();
	setsize(tracewalkent, m1, m2);
	tracewalkent.owner = self; // avoid collisions
	self = tracewalkent;
	setorigin(self, start);
	p = pointcontents(self.origin);
	if (p == CONTENT_EMPTY)
	{
		tracebox(start + '0 0 18', self.mins, self.maxs, start + '0 0 -18', FALSE, e);
		if (trace_fraction >= 1) // start isn't even on the floor
		{
			self = saveself;
			return 0;
		}
	}
	ignorehazards = FALSE;
	p = pointcontents(start);
	if (p == CONTENT_LAVA || p == CONTENT_SLIME)
		ignorehazards = TRUE;
	yaw = vectoyaw(move);
	move = end - self.origin;
	while (1)
	{
		if (boxesoverlap(end, end, self.absmin, self.absmax))
		{
			self = saveself;
			// succeeded
			return 1;
		}
		if (dist <= 0)
			break;
		if (stepdist > dist)
			stepdist = dist;
		dist = dist - stepdist;
		p = 0;
		if (!ignorehazards)
		{
			p = pointcontents(self.origin);
			if (p == CONTENT_LAVA || p == CONTENT_SLIME)
			{
				self = saveself;
				// hazards blocking path
				return 0;
			}
		}
		if (p == 0)
			p = pointcontents(self.origin);
		if (p != CONTENT_EMPTY)
		{
			move = normalize(end - self.origin);
			tracebox(self.origin, self.mins, self.maxs, self.origin + move * stepdist, FALSE, e);
			if (trace_startsolid || trace_fraction < 1)
			{
				self = saveself;
				// failed
				return 0;
			}
			setorigin(self, trace_endpos);
		}
		else
		{
			// walkmove failed, fall back to our own methods
			move = dir * stepdist + self.origin;
			// trace twice, first at ground level, then at
			// stepheight, stepheight trace will be used instead
			// of ground trace if it went further, if ground
			// level was chosen check if we made any progress,
			// if we did, fall to floor, if we did not, fail
			tracebox(self.origin, self.mins, self.maxs, move, FALSE, e);
			if (trace_startsolid)
			{
				self = saveself;
				// failed
				return 0;
			}
			nostepfrac = trace_fraction;
			nostependpos = trace_endpos;
			tracebox(self.origin + '0 0 18', self.mins, self.maxs, move + '0 0 18', FALSE, e);
			if (trace_fraction > nostepfrac + 0.001)
			{
				// stepped, fall to floor
				tracebox(trace_endpos, self.mins, self.maxs, trace_endpos + '0 0 -65536', FALSE, e);
				setorigin(self, trace_endpos);
			}
			else
			{
				if (nostepfrac >= 0.001)
				{
					// moved, fall to floor
					tracebox(nostependpos, self.mins, self.maxs, nostependpos + '0 0 -65536', FALSE, e);
					setorigin(self, trace_endpos);
				}
				else
				{
					// didn't move
					self = saveself;
					// failed
					return 0;
				}
			}
		}
	}
	self = saveself;
	// moved but didn't arrive at the intended destination
	return 0;
};

entity(entity start, vector org, float mode) FindCurrentNavNode =
{
	local float f, best_f;
	local entity e, best_e;

	best_f = 10000000;

	if (mode == M_OVERLAP)
	{
		if (start.classname == "navnode")
			e = start.list;
		else
			e = navnode_chain;
		while (e)
		{
			if (boxesoverlap(org, org, e.origin + e.mins, e.origin + e.maxs))
				return e;
			e = e.list;
		}
	}
	else if (mode == M_CLOSEST)
	{
		if (start.classname == "navnode")
			e = start.list;
		else
			e = navnode_chain;
		while (e)
		{
			f = vlen(org - e.origin);
			if (f < best_f)
			{
				best_e = e;
				best_f = f;
			}
			e = e.list;
		}
		return best_e;
	}
	return world;
};

vector(vector org) SnapToGrid =
{
	local float grid;
	local vector rl, rh, t1, t2, ret;

	grid = self.gridsize;

	if (org_x < 0)
	{
		while (rh_x > org_x)
			rh_x = rh_x - grid;
	}
	else
	{
		while (rh_x < org_x)
			rh_x = rh_x + grid;
	}
	if (org_y < 0)
	{
		while (rh_y > org_y)
			rh_y = rh_y - grid;
	}
	else
	{
		while (rh_y < org_y)
			rh_y = rh_y + grid;
	}
	if (org_z < 0)
	{
		while (rh_z > org_z)
			rh_z = rh_z - grid;
	}
	else
	{
		while (rh_z < org_z)
			rh_z = rh_z + grid;
	}

	if (rh_x < 0)
		rl_x = rh_x + grid;
	else
		rl_x = rh_x - grid;
	if (rh_y < 0)
		rl_y = rh_y + grid;
	else
		rl_y = rh_y - grid;
	if (rh_z < 0)
		rl_z = rh_z + grid;
	else
		rl_z = rh_z - grid;

	t1_x = rl_x;
	t1_y = rl_y;
	t1_z = rl_z;

	t2_x = rh_x;
	t2_y = rh_y;
	t2_z = rh_z;

	if (org_x < 0)
		org_x = org_x * -1;
	if (org_y < 0)
		org_y = org_y * -1;
	if (org_z < 0)
		org_z = org_z * -1;

	if (t1_x < 0)
		t1_x = t1_x * -1;
	if (t1_y < 0)
		t1_y = t1_y * -1;
	if (t1_z < 0)
		t1_z = t1_z * -1;

	if (t2_x < 0)
		t2_x = t2_x * -1;
	if (t2_y < 0)
		t2_y = t2_y * -1;
	if (t2_z < 0)
		t2_z = t2_z * -1;

	t1_x = org_x - t1_x;
	t1_y = org_y - t1_y;
	t1_z = org_z - t1_z;

	t2_x = org_x - t2_x;
	t2_y = org_y - t2_y;
	t2_z = org_z - t2_z;

	if (t1_x < 0)
		t1_x = t1_x * -1;
	if (t1_y < 0)
		t1_y = t1_y * -1;
	if (t1_z < 0)
		t1_z = t1_z * -1;

	if (t2_x < 0)
		t2_x = t2_x * -1;
	if (t2_y < 0)
		t2_y = t2_y * -1;
	if (t2_z < 0)
		t2_z = t2_z * -1;

	if (t1_x < t2_x)
		ret_x = rl_x;
	else
		ret_x = rh_x;
	if (t1_y < t2_y)
		ret_y = rl_y;
	else
		ret_y = rh_y;
	if (t1_z < t2_z)
		ret_z = rl_z;
	else
		ret_z = rh_z;

	return ret;
};

void(entity navn) FixPlanes =
{
	local entity e;

	if (!navn)
		return;
	e = navn.plane_chain;
	if (e)
	{
		setorigin(e, navn.origin + e.mangle*e.delay);
		e = e.plane_next;
		while (e != navn.plane_chain)
		{
			setorigin(e, navn.origin + e.mangle*e.delay);
			e = e.plane_next;
		}
	}
};

void(entity navn, vector org) MoveNavNode =
{
	if (!navn)
		return;
	setorigin(navn, org);
	FixPlanes(navn);
	LinkNavNodes();
};

float(entity navn, float ax, float amount) ResizeNavNode =
{
	local vector v;

	if (!navn)
		return FALSE;

	if (ax == 0)
	{
		amount = amount - navn.origin_x;
		if (amount < 0)
			amount = amount*-1;
		amount = amount - navn.maxs_x;
		v = navn.maxs;
		v_x = v_x + (amount*0.5);
		setsize(navn, v*-1, v);
		v = navn.origin;
		if (self.origin_x < navn.origin_x)
			v_x = navn.origin_x - (amount*0.5);
		else
			v_x = navn.origin_x + (amount*0.5);
		MoveNavNode(navn, v);
	}
	else if (ax == 1)
	{
		amount = amount - navn.origin_y;
		if (amount < 0)
			amount = amount*-1;
		amount = amount - navn.maxs_y;
		v = navn.maxs;
		v_y = v_y + (amount*0.5);
		setsize(navn, v*-1, v);
		v = navn.origin;
		if (self.origin_y < navn.origin_y)
			v_y = navn.origin_y - (amount*0.5);
		else
			v_y = navn.origin_y + (amount*0.5);
		MoveNavNode(navn, v);
	}
	else if (ax == 2)
	{
		amount = amount - navn.origin_z;
		if (amount < 0)
			amount = amount*-1;
		amount = amount - navn.maxs_z;
		v = navn.maxs;
		v_z = v_z + (amount*0.5);
		setsize(navn, v*-1, v);
		v = navn.origin;
		if (self.origin_z < navn.origin_z)
			v_z = navn.origin_z - (amount*0.5);
		else
			v_z = navn.origin_z + (amount*0.5);
		MoveNavNode(navn, v);
	}
	LinkNavNodes();
	return TRUE;
};

void(entity navn, vector normal, float dist) AddPlane =
{
	local float f;

	if (!navn)
		return;

	newmis = spawn();
	newmis.classname = "plane";
	if (!navn.plane_chain)
	{
		navn.plane_chain = newmis;
		newmis.plane_next = newmis;
		newmis.plane_prev = newmis;
	}
	else
	{
		newmis.plane_next = navn.plane_chain;
		newmis.plane_prev = newmis.plane_next.plane_prev;
		newmis.plane_prev.plane_next = newmis;
		newmis.plane_next.plane_prev = newmis;
	}
	newmis.mangle = normal*-1;
	newmis.delay = dist;
	f = (navn.origin * newmis.mangle) - ((navn.origin + (newmis.delay * newmis.mangle)) * newmis.mangle);
	if (f > 0)
	{
		newmis.mangle = newmis.mangle*-1;
		newmis.delay = newmis.delay*-1;
	}
	setorigin (newmis, navn.origin + newmis.mangle*newmis.delay);
	setmodel (newmis, "progs/plane.mdl");
	newmis.angles = vectoangles(newmis.mangle);
	newmis.effects = EF_NODRAW;
};

void(entity navn, entity delplane) RemovePlane =
{
	local entity e;

	e = navn.plane_chain;
	if (e)
	{
		if (e == delplane)
		{
			if (navn.plane_chain == e)
				navn.plane_chain = e.plane_next;
			e.plane_prev.plane_next = e.plane_next;
			e.plane_next.plane_prev = e.plane_prev;
			remove (e);
			e = navn.plane_chain;
		}
		e = e.plane_next;
		while (e != navn.plane_chain)
		{
			if (e == delplane)
			{
				if (navn.plane_chain == e)
					navn.plane_chain = e.plane_next;
				e.plane_prev.plane_next = e.plane_next;
				e.plane_next.plane_prev = e.plane_prev;
				remove (e);
				e = navn.plane_chain;
			}
			e = e.plane_next;
		}
		if (navn.plane_chain.origin == nullvector)
			navn.plane_chain = world;
	}
};

void() RemoveClippoints =
{
	if (self.clippoint1)
	{
		if (self.clippoint2)
		{
			if (self.clippoint3)
				remove (self.clippoint3);
			remove (self.clippoint2);
		}
		remove (self.clippoint1);
	}
	self.current_clippoint = world;
	self.clippoint1 = self.clippoint2 = self.clippoint3 = world;
};

void() ClippointThink =
{
	local float p;

	self.nextthink = time + 0.1;

	p = pointcontents(self.origin);
	if (p == CONTENT_SOLID)
		self.effects = EF_NODEPTHTEST | EF_ADDITIVE;
	else
		self.effects = 0;
};

void(vector org) SpawnClipPoint =
{
	if (self.clippoint1)
	{
		if (self.clippoint2)
		{
			if (self.clippoint3)
				return;
			else
			{
				self.clippoint3 = spawn();
				setmodel(self.clippoint3, "progs/point.spr");
				setsize(self.clippoint3, '0 0 0', '0 0 0');
				self.clippoint3.classname = "clippoint";
				self.clippoint3.scale = 0.5;
				setorigin(self.clippoint3, org);
				self.clippoint3.think = ClippointThink;
				self.clippoint3.nextthink = time;
			}
		}
		else
		{
			self.clippoint2 = spawn();
			setmodel(self.clippoint2, "progs/point.spr");
			setsize(self.clippoint2, '0 0 0', '0 0 0');
			self.clippoint2.classname = "clippoint";
			self.clippoint2.scale = 0.5;
			setorigin(self.clippoint2, org);
			self.clippoint2.think = ClippointThink;
			self.clippoint2.nextthink = time;
		}
	}
	else
	{
		self.clippoint1 = spawn();
		setmodel(self.clippoint1, "progs/point.spr");
		setsize(self.clippoint1, '0 0 0', '0 0 0');
		self.clippoint1.classname = "clippoint";
		self.clippoint1.scale = 0.5;
		setorigin(self.clippoint1, org);
		self.clippoint1.think = ClippointThink;
		self.clippoint1.nextthink = time;
	}
};

entity(vector org, vector nnmins, vector nnmaxs) SpawnNavNode =
{
	newmis = spawn();
	setmodel(newmis, "progs/navnode.spr");
	setsize(newmis, nnmins, nnmaxs);
	newmis.classname = "navnode";
	newmis.frame = 20;
	setorigin(newmis, org);
	return newmis;
};

void() LinkNavNodes =
{
	local entity e, t;

	navnode_chain = world;
	navnodes = 0;

	e = findchain(classname, "navnode");
	while (e)
	{
		e.list = navnode_chain;
		navnode_chain = e;
		e.delay = navnodes;
		navnodes = navnodes + 1;
		e = e.chain;
	}

	e = navnode_chain;
	while (e)
	{
		if (e.link0)
		{
			e.link0.effects = 0;
			e.link0.frame = 20;
			if (e.link0.classname == "remotelinker")
			{
				e.link0.think = SUB_Remove;
				e.link0.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link0.delay)
						e.link0 = t;
					t = t.list;
				}
				e.lflags0 = e.lflags0 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags0 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link0.origin + e.link0.mins, e.link0.origin + e.link0.maxs))
					PushLinks(e, 0);
			}
		}
		if (e.link1)
		{
			e.link1.effects = 0;
			e.link1.frame = 20;
			if (e.link1.classname == "remotelinker")
			{
				e.link1.think = SUB_Remove;
				e.link1.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link1.delay)
						e.link1 = t;
					t = t.list;
				}
				e.lflags1 = e.lflags1 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags1 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link1.origin + e.link1.mins, e.link1.origin + e.link1.maxs))
					PushLinks(e, 1);
			}
		}
		if (e.link2)
		{
			e.link2.effects = 0;
			e.link2.frame = 20;
			if (e.link2.classname == "remotelinker")
			{
				e.link2.think = SUB_Remove;
				e.link2.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link2.delay)
						e.link2 = t;
					t = t.list;
				}
				e.lflags2 = e.lflags2 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags2 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link2.origin + e.link2.mins, e.link2.origin + e.link2.maxs))
					PushLinks(e, 2);
			}
		}
		if (e.link3)
		{
			e.link3.effects = 0;
			e.link3.frame = 20;
			if (e.link3.classname == "remotelinker")
			{
				e.link3.think = SUB_Remove;
				e.link3.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link3.delay)
						e.link3 = t;
					t = t.list;
				}
				e.lflags3 = e.lflags3 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags3 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link3.origin + e.link3.mins, e.link3.origin + e.link3.maxs))
					PushLinks(e, 3);
			}
		}
		if (e.link4)
		{
			e.link4.effects = 0;
			e.link4.frame = 20;
			if (e.link4.classname == "remotelinker")
			{
				e.link4.think = SUB_Remove;
				e.link4.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link4.delay)
						e.link4 = t;
					t = t.list;
				}
				e.lflags4 = e.lflags4 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags4 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link4.origin + e.link4.mins, e.link4.origin + e.link4.maxs))
					PushLinks(e, 4);
			}
		}
		if (e.link5)
		{
			e.link5.effects = 0;
			e.link5.frame = 20;
			if (e.link5.classname == "remotelinker")
			{
				e.link5.think = SUB_Remove;
				e.link5.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link5.delay)
						e.link5 = t;
					t = t.list;
				}
				e.lflags5 = e.lflags5 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags5 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link5.origin + e.link5.mins, e.link5.origin + e.link5.maxs))
					PushLinks(e, 5);
			}
		}
		if (e.link6)
		{
			e.link6.effects = 0;
			e.link6.frame = 20;
			if (e.link6.classname == "remotelinker")
			{
				e.link6.think = SUB_Remove;
				e.link6.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link6.delay)
						e.link6 = t;
					t = t.list;
				}
				e.lflags6 = e.lflags6 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags6 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link6.origin + e.link6.mins, e.link6.origin + e.link6.maxs))
					PushLinks(e, 6);
			}
		}
		if (e.link7)
		{
			e.link7.effects = 0;
			e.link7.frame = 20;
			if (e.link7.classname == "remotelinker")
			{
				e.link7.think = SUB_Remove;
				e.link7.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link7.delay)
						e.link7 = t;
					t = t.list;
				}
				e.lflags7 = e.lflags7 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags7 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link7.origin + e.link7.mins, e.link7.origin + e.link7.maxs))
					PushLinks(e, 7);
			}
		}
		if (e.link8)
		{
			e.link8.effects = 0;
			e.link8.frame = 20;
			if (e.link8.classname == "remotelinker")
			{
				e.link8.think = SUB_Remove;
				e.link8.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link8.delay)
						e.link8 = t;
					t = t.list;
				}
				e.lflags8 = e.lflags8 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags8 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link8.origin + e.link8.mins, e.link8.origin + e.link8.maxs))
					PushLinks(e, 8);
			}
		}
		if (e.link9)
		{
			e.link9.effects = 0;
			e.link9.frame = 20;
			if (e.link9.classname == "remotelinker")
			{
				e.link9.think = SUB_Remove;
				e.link9.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link9.delay)
						e.link9 = t;
					t = t.list;
				}
				e.lflags9 = e.lflags9 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags9 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link9.origin + e.link9.mins, e.link9.origin + e.link9.maxs))
					PushLinks(e, 9);
			}
		}
		if (e.link10)
		{
			e.link10.effects = 0;
			e.link10.frame = 20;
			if (e.link10.classname == "remotelinker")
			{
				e.link10.think = SUB_Remove;
				e.link10.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link10.delay)
						e.link10 = t;
					t = t.list;
				}
				e.lflags10 = e.lflags10 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags10 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link10.origin + e.link10.mins, e.link10.origin + e.link10.maxs))
					PushLinks(e, 10);
			}
		}
		if (e.link11)
		{
			e.link11.effects = 0;
			e.link11.frame = 20;
			if (e.link11.classname == "remotelinker")
			{
				e.link11.think = SUB_Remove;
				e.link11.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link11.delay)
						e.link11 = t;
					t = t.list;
				}
				e.lflags11 = e.lflags11 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags11 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link11.origin + e.link11.mins, e.link11.origin + e.link11.maxs))
					PushLinks(e, 11);
			}
		}
		if (e.link12)
		{
			e.link12.effects = 0;
			e.link12.frame = 20;
			if (e.link12.classname == "remotelinker")
			{
				e.link12.think = SUB_Remove;
				e.link12.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link12.delay)
						e.link12 = t;
					t = t.list;
				}
				e.lflags12 = e.lflags12 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags12 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link12.origin + e.link12.mins, e.link12.origin + e.link12.maxs))
					PushLinks(e, 12);
			}
		}
		if (e.link13)
		{
			e.link13.effects = 0;
			e.link13.frame = 20;
			if (e.link13.classname == "remotelinker")
			{
				e.link13.think = SUB_Remove;
				e.link13.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link13.delay)
						e.link13 = t;
					t = t.list;
				}
				e.lflags13 = e.lflags13 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags13 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link13.origin + e.link13.mins, e.link13.origin + e.link13.maxs))
					PushLinks(e, 13);
			}
		}
		if (e.link14)
		{
			e.link14.effects = 0;
			e.link14.frame = 20;
			if (e.link14.classname == "remotelinker")
			{
				e.link14.think = SUB_Remove;
				e.link14.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link14.delay)
						e.link14 = t;
					t = t.list;
				}
				e.lflags14 = e.lflags14 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags14 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link14.origin + e.link14.mins, e.link14.origin + e.link14.maxs))
					PushLinks(e, 14);
			}
		}
		if (e.link15)
		{
			e.link15.effects = 0;
			e.link15.frame = 20;
			if (e.link15.classname == "remotelinker")
			{
				e.link15.think = SUB_Remove;
				e.link15.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link15.delay)
						e.link15 = t;
					t = t.list;
				}
				e.lflags15 = e.lflags15 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags15 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link15.origin + e.link15.mins, e.link15.origin + e.link15.maxs))
					PushLinks(e, 15);
			}
		}
		if (e.link16)
		{
			e.link16.effects = 0;
			e.link16.frame = 20;
			if (e.link16.classname == "remotelinker")
			{
				e.link16.think = SUB_Remove;
				e.link16.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link16.delay)
						e.link16 = t;
					t = t.list;
				}
				e.lflags16 = e.lflags16 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags16 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link16.origin + e.link16.mins, e.link16.origin + e.link16.maxs))
					PushLinks(e, 16);
			}
		}
		if (e.link17)
		{
			e.link17.effects = 0;
			e.link17.frame = 20;
			if (e.link17.classname == "remotelinker")
			{
				e.link17.think = SUB_Remove;
				e.link17.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link17.delay)
						e.link17 = t;
					t = t.list;
				}
				e.lflags17 = e.lflags17 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags17 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link17.origin + e.link17.mins, e.link17.origin + e.link17.maxs))
					PushLinks(e, 17);
			}
		}
		if (e.link18)
		{
			e.link18.effects = 0;
			e.link18.frame = 20;
			if (e.link18.classname == "remotelinker")
			{
				e.link18.think = SUB_Remove;
				e.link18.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link18.delay)
						e.link18 = t;
					t = t.list;
				}
				e.lflags18 = e.lflags18 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags18 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link18.origin + e.link18.mins, e.link18.origin + e.link18.maxs))
					PushLinks(e, 18);
			}
		}
		if (e.link19)
		{
			e.link19.effects = 0;
			e.link19.frame = 20;
			if (e.link19.classname == "remotelinker")
			{
				e.link19.think = SUB_Remove;
				e.link19.nextthink = time;
				t = navnode_chain;
				while (t)
				{
					if (t.delay == e.link19.delay)
						e.link19 = t;
					t = t.list;
				}
				e.lflags19 = e.lflags19 | LF_REMOTE;
			}
			else
			{
				if (!(e.lflags19 & LF_REMOTE))
				if (!boxesoverlap(e.origin + e.mins, e.origin + e.maxs, e.link19.origin + e.link19.mins, e.link19.origin + e.link19.maxs))
					PushLinks(e, 19);
			}
		}
		e = e.list;
	}
	e = navnode_chain;
	while (e)
	{
		t = navnode_chain;
		while (t)
		{
			if (boxesoverlap(e.origin + e.mins, e.origin + e.maxs, t.origin + t.mins, t.origin + t.maxs))
			if (t != e)
			if (t != e.link0)
			if (t != e.link1)
			if (t != e.link2)
			if (t != e.link3)
			if (t != e.link4)
			if (t != e.link5)
			if (t != e.link6)
			if (t != e.link7)
			if (t != e.link8)
			if (t != e.link9)
			if (t != e.link10)
			if (t != e.link11)
			if (t != e.link12)
			if (t != e.link13)
			if (t != e.link14)
			if (t != e.link15)
			if (t != e.link16)
			if (t != e.link17)
			if (t != e.link18)
			if (t != e.link19)
			{
				if (!e.link0)
					e.link0 = t;
				else if (!e.link1)
					e.link1 = t;
				else if (!e.link2)
					e.link2 = t;
				else if (!e.link3)
					e.link3 = t;
				else if (!e.link4)
					e.link4 = t;
				else if (!e.link5)
					e.link5 = t;
				else if (!e.link6)
					e.link6 = t;
				else if (!e.link7)
					e.link7 = t;
				else if (!e.link8)
					e.link8 = t;
				else if (!e.link9)
					e.link9 = t;
				else if (!e.link10)
					e.link10 = t;
				else if (!e.link11)
					e.link11 = t;
				else if (!e.link12)
					e.link12 = t;
				else if (!e.link13)
					e.link13 = t;
				else if (!e.link14)
					e.link14 = t;
				else if (!e.link15)
					e.link15 = t;
				else if (!e.link16)
					e.link16 = t;
				else if (!e.link17)
					e.link17 = t;
				else if (!e.link18)
					e.link18 = t;
				else if (!e.link19)
					e.link19 = t;
				else
					dprint("WARNING: Too many linking NavNodes!\n");
			}
			t = t.list;
		}
		e = e.list;
	}
};

void() LoadNavNodes =
{
	local float f, file, length;
	local float pdst;
	local float sfl;
	local float tfl0, tfl1, tfl2, tfl3, tfl4, tfl5, tfl6, tfl7, tfl8, tfl9;
	local float tfl10, tfl11, tfl12, tfl13, tfl14, tfl15, tfl16, tfl17, tfl18, tfl19;
	local string s;
	local float rl0, rl1, rl2, rl3, rl4, rl5, rl6, rl7, rl8, rl9;
	local float rl10, rl11, rl12, rl13, rl14, rl15, rl16, rl17, rl18, rl19;
	local vector pln;
	local vector wborg, wbmaxs, wbmins;
	local entity e, plane_storage;

	if (navnodes)
	{
		dprint("NavNodes present, map needs to be reloaded to load navnode-file\n");
		return;
	}

	plane_storage = spawn();

	length = strlen(world.model);
	length = length - 5;
	s = substring(world.model, 5, length);
	s = strcat(s, ".nnl");

	file = fopen(s, FILE_READ);

	if (file >= 0)
	{
		s = fgets(file);
		while (s == "navnode")
		{
			f = 0;
			pdst = -1;
			pln = nullvector;
			wborg = wbmaxs = wbmins = nullvector;
			plane_storage.plane_chain = world;
			sfl = 0;
			tfl0 = tfl1 = tfl2 = tfl3 = tfl4 = tfl5 = tfl6 = tfl7 = tfl8 = tfl9 = 0;
			tfl10 = tfl11 = tfl12 = tfl13 = tfl14 = tfl15 = tfl16 = tfl17 = tfl18 = tfl19 = 0;
			rl0 = rl1 = rl2 = rl3 = rl4 = rl5 = rl6 = rl7 = rl8 = rl9 = -1;
			rl10 = rl11 = rl12 = rl13 = rl14 = rl15 = rl16 = rl17 = rl18 = rl19 = -1;
			s = fgets(file);
			wborg = stov(s);
			s = fgets(file);
			wbmins = stov(s);
			s = fgets(file);
			wbmaxs = stov(s);
			s = fgets(file);
			while (s == "plane")
			{
				s = fgets(file);
				pln = stov(s);
				s = fgets(file);
				pdst = stof(s);
				AddPlane(plane_storage, pln*-1, pdst);
				s = fgets(file);
			}
			while (substring(s, 0, 6) == "remote")
			{
				length = strlen(s);
				f = stof(substring(s, 6, length));
				s = fgets(file);
				if (!f)
					rl0 = stof(s);
				else if (f == 1)
					rl1 = stof(s);
				else if (f == 2)
					rl2 = stof(s);
				else if (f == 3)
					rl3 = stof(s);
				else if (f == 4)
					rl4 = stof(s);
				else if (f == 5)
					rl5 = stof(s);
				else if (f == 6)
					rl6 = stof(s);
				else if (f == 7)
					rl7 = stof(s);
				else if (f == 8)
					rl8 = stof(s);
				else if (f == 9)
					rl9 = stof(s);
				else if (f == 10)
					rl10 = stof(s);
				else if (f == 11)
					rl11 = stof(s);
				else if (f == 12)
					rl12 = stof(s);
				else if (f == 13)
					rl13 = stof(s);
				else if (f == 14)
					rl14 = stof(s);
				else if (f == 15)
					rl15 = stof(s);
				else if (f == 16)
					rl16 = stof(s);
				else if (f == 17)
					rl17 = stof(s);
				else if (f == 18)
					rl18 = stof(s);
				else if (f == 19)
					rl19 = stof(s);
				s = fgets(file);
			}
			if (s == "sflags")
			{
				s = fgets(file);
				sfl = stof(s);
				s = fgets(file);
			}
			while (substring(s, 0, 6) == "lflags")
			{
				length = strlen(s);
				f = stof(substring(s, 6, length));
				s = fgets(file);
				if (!f)
					tfl0 = stof(s);
				else if (f == 1)
					tfl1 = stof(s);
				else if (f == 2)
					tfl2 = stof(s);
				else if (f == 3)
					tfl3 = stof(s);
				else if (f == 4)
					tfl4 = stof(s);
				else if (f == 5)
					tfl5 = stof(s);
				else if (f == 6)
					tfl6 = stof(s);
				else if (f == 7)
					tfl7 = stof(s);
				else if (f == 8)
					tfl8 = stof(s);
				else if (f == 9)
					tfl9 = stof(s);
				else if (f == 10)
					tfl10 = stof(s);
				else if (f == 11)
					tfl11 = stof(s);
				else if (f == 12)
					tfl12 = stof(s);
				else if (f == 13)
					tfl13 = stof(s);
				else if (f == 14)
					tfl14 = stof(s);
				else if (f == 15)
					tfl15 = stof(s);
				else if (f == 16)
					tfl16 = stof(s);
				else if (f == 17)
					tfl17 = stof(s);
				else if (f == 18)
					tfl18 = stof(s);
				else if (f == 19)
					tfl19 = stof(s);
				s = fgets(file);
			}
			e = SpawnNavNode(wborg, wbmins, wbmaxs);
			if (plane_storage.plane_chain)
				e.plane_chain = plane_storage.plane_chain;
			e.sflags = sfl;
			e.lflags0 = tfl0;
			e.lflags1 = tfl1;
			e.lflags2 = tfl2;
			e.lflags3 = tfl3;
			e.lflags4 = tfl4;
			e.lflags5 = tfl5;
			e.lflags6 = tfl6;
			e.lflags7 = tfl7;
			e.lflags8 = tfl8;
			e.lflags9 = tfl9;
			e.lflags10 = tfl10;
			e.lflags11 = tfl11;
			e.lflags12 = tfl12;
			e.lflags13 = tfl13;
			e.lflags14 = tfl14;
			e.lflags15 = tfl15;
			e.lflags16 = tfl16;
			e.lflags17 = tfl17;
			e.lflags18 = tfl18;
			e.lflags19 = tfl19;
			if (rl0 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl0;
				e.link0 = newmis;
			}
			if (rl1 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl1;
				e.link1 = newmis;
			}
			if (rl2 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl2;
				e.link2 = newmis;
			}
			if (rl3 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl3;
				e.link3 = newmis;
			}
			if (rl4 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl4;
				e.link4 = newmis;
			}
			if (rl5 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl5;
				e.link5 = newmis;
			}
			if (rl6 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl6;
				e.link6 = newmis;
			}
			if (rl7 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl7;
				e.link7 = newmis;
			}
			if (rl8 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl8;
				e.link8 = newmis;
			}
			if (rl9 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl9;
				e.link9 = newmis;
			}
			if (rl10 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl10;
				e.link10 = newmis;
			}
			if (rl11 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl11;
				e.link11 = newmis;
			}
			if (rl12 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl12;
				e.link12 = newmis;
			}
			if (rl13 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl13;
				e.link13 = newmis;
			}
			if (rl14 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl14;
				e.link14 = newmis;
			}
			if (rl15 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl15;
				e.link15 = newmis;
			}
			if (rl16 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl16;
				e.link16 = newmis;
			}
			if (rl17 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl17;
				e.link17 = newmis;
			}
			if (rl18 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl18;
				e.link18 = newmis;
			}
			if (rl19 > -1)
			{
				newmis = spawn();
				newmis.classname = "remotelinker";
				newmis.delay = rl19;
				e.link19 = newmis;
			}
			FixPlanes(e);
		}
		fclose(file);
	}
	remove(plane_storage);
	plane_storage = world;
	LinkNavNodes();
};

void() SaveNavNodes =
{
	local float file, length;
	local float tfl0, tfl1, tfl2, tfl3, tfl4, tfl5, tfl6, tfl7, tfl8, tfl9;
	local float tfl10, tfl11, tfl12, tfl13, tfl14, tfl15, tfl16, tfl17, tfl18, tfl19;
	local string s;
	local entity e, e2;

	length = strlen(world.model);
	length = length - 5;
	s = substring(world.model, 5, length);
	s = strcat(s, ".nnl");

	file = fopen(s, FILE_WRITE);

	if (file >= 0)
	{
		e = navnode_chain;
		while (e)
		{
			fputs(file, "navnode\n");
			fputs(file, ftos(e.origin_x));
			fputs(file, " ");
			fputs(file, ftos(e.origin_y));
			fputs(file, " ");
			fputs(file, ftos(e.origin_z));
			fputs(file, "\n");
			fputs(file, ftos(e.mins_x));
			fputs(file, " ");
			fputs(file, ftos(e.mins_y));
			fputs(file, " ");
			fputs(file, ftos(e.mins_z));
			fputs(file, "\n");
			fputs(file, ftos(e.maxs_x));
			fputs(file, " ");
			fputs(file, ftos(e.maxs_y));
			fputs(file, " ");
			fputs(file, ftos(e.maxs_z));
			fputs(file, "\n");
			if (e.plane_chain)
			{
				e2 = e.plane_chain;
				fputs(file, "plane\n");
				fputs(file, ftos(e2.mangle_x));
				fputs(file, " ");
				fputs(file, ftos(e2.mangle_y));
				fputs(file, " ");
				fputs(file, ftos(e2.mangle_z));
				fputs(file, "\n");
				fputs(file, ftos(e2.delay));
				fputs(file, "\n");
				e2 = e2.plane_next;
				while (e2 != e.plane_chain)
				{
					fputs(file, "plane\n");
					fputs(file, ftos(e2.mangle_x));
					fputs(file, " ");
					fputs(file, ftos(e2.mangle_y));
					fputs(file, " ");
					fputs(file, ftos(e2.mangle_z));
					fputs(file, "\n");
					fputs(file, ftos(e2.delay));
					fputs(file, "\n");
					e2 = e2.plane_next;
				}
			}
			if (e.lflags0 & LF_REMOTE)
			{
				fputs(file, "remote0\n");
				fputs(file, ftos(e.link0.delay));
				fputs(file, "\n");
			}
			if (e.lflags1 & LF_REMOTE)
			{
				fputs(file, "remote1\n");
				fputs(file, ftos(e.link1.delay));
				fputs(file, "\n");
			}
			if (e.lflags2 & LF_REMOTE)
			{
				fputs(file, "remote2\n");
				fputs(file, ftos(e.link2.delay));
				fputs(file, "\n");
			}
			if (e.lflags3 & LF_REMOTE)
			{
				fputs(file, "remote3\n");
				fputs(file, ftos(e.link3.delay));
				fputs(file, "\n");
			}
			if (e.lflags4 & LF_REMOTE)
			{
				fputs(file, "remote4\n");
				fputs(file, ftos(e.link4.delay));
				fputs(file, "\n");
			}
			if (e.lflags5 & LF_REMOTE)
			{
				fputs(file, "remote5\n");
				fputs(file, ftos(e.link5.delay));
				fputs(file, "\n");
			}
			if (e.lflags6 & LF_REMOTE)
			{
				fputs(file, "remote6\n");
				fputs(file, ftos(e.link6.delay));
				fputs(file, "\n");
			}
			if (e.lflags7 & LF_REMOTE)
			{
				fputs(file, "remote7\n");
				fputs(file, ftos(e.link7.delay));
				fputs(file, "\n");
			}
			if (e.lflags8 & LF_REMOTE)
			{
				fputs(file, "remote8\n");
				fputs(file, ftos(e.link8.delay));
				fputs(file, "\n");
			}
			if (e.lflags9 & LF_REMOTE)
			{
				fputs(file, "remote9\n");
				fputs(file, ftos(e.link9.delay));
				fputs(file, "\n");
			}
			if (e.lflags10 & LF_REMOTE)
			{
				fputs(file, "remote10\n");
				fputs(file, ftos(e.link10.delay));
				fputs(file, "\n");
			}
			if (e.lflags11 & LF_REMOTE)
			{
				fputs(file, "remote11\n");
				fputs(file, ftos(e.link11.delay));
				fputs(file, "\n");
			}
			if (e.lflags12 & LF_REMOTE)
			{
				fputs(file, "remote12\n");
				fputs(file, ftos(e.link12.delay));
				fputs(file, "\n");
			}
			if (e.lflags13 & LF_REMOTE)
			{
				fputs(file, "remote13\n");
				fputs(file, ftos(e.link13.delay));
				fputs(file, "\n");
			}
			if (e.lflags14 & LF_REMOTE)
			{
				fputs(file, "remote14\n");
				fputs(file, ftos(e.link14.delay));
				fputs(file, "\n");
			}
			if (e.lflags15 & LF_REMOTE)
			{
				fputs(file, "remote15\n");
				fputs(file, ftos(e.link15.delay));
				fputs(file, "\n");
			}
			if (e.lflags16 & LF_REMOTE)
			{
				fputs(file, "remote16\n");
				fputs(file, ftos(e.link16.delay));
				fputs(file, "\n");
			}
			if (e.lflags17 & LF_REMOTE)
			{
				fputs(file, "remote17\n");
				fputs(file, ftos(e.link17.delay));
				fputs(file, "\n");
			}
			if (e.lflags18 & LF_REMOTE)
			{
				fputs(file, "remote18\n");
				fputs(file, ftos(e.link18.delay));
				fputs(file, "\n");
			}
			if (e.lflags19 & LF_REMOTE)
			{
				fputs(file, "remote19\n");
				fputs(file, ftos(e.link19.delay));
				fputs(file, "\n");
			}
			tfl0 = e.lflags0 - (e.lflags0 & LF_REMOTE);
			tfl1 = e.lflags1 - (e.lflags1 & LF_REMOTE);
			tfl2 = e.lflags2 - (e.lflags2 & LF_REMOTE);
			tfl3 = e.lflags3 - (e.lflags3 & LF_REMOTE);
			tfl4 = e.lflags4 - (e.lflags4 & LF_REMOTE);
			tfl5 = e.lflags5 - (e.lflags5 & LF_REMOTE);
			tfl6 = e.lflags6 - (e.lflags6 & LF_REMOTE);
			tfl7 = e.lflags7 - (e.lflags7 & LF_REMOTE);
			tfl8 = e.lflags8 - (e.lflags8 & LF_REMOTE);
			tfl9 = e.lflags9 - (e.lflags9 & LF_REMOTE);
			tfl10 = e.lflags10 - (e.lflags10 & LF_REMOTE);
			tfl11 = e.lflags11 - (e.lflags11 & LF_REMOTE);
			tfl12 = e.lflags12 - (e.lflags12 & LF_REMOTE);
			tfl13 = e.lflags13 - (e.lflags13 & LF_REMOTE);
			tfl14 = e.lflags14 - (e.lflags14 & LF_REMOTE);
			tfl15 = e.lflags15 - (e.lflags15 & LF_REMOTE);
			tfl16 = e.lflags16 - (e.lflags16 & LF_REMOTE);
			tfl17 = e.lflags17 - (e.lflags17 & LF_REMOTE);
			tfl18 = e.lflags18 - (e.lflags18 & LF_REMOTE);
			tfl19 = e.lflags19 - (e.lflags19 & LF_REMOTE);
			if (e.sflags)
			{
				fputs(file, "sflags\n");
				fputs(file, ftos(e.sflags));
				fputs(file, "\n");
			}
			if (tfl0)
			{
				fputs(file, "lflags0\n");
				fputs(file, ftos(tfl0));
				fputs(file, "\n");
			}
			if (tfl1)
			{
				fputs(file, "lflags1\n");
				fputs(file, ftos(tfl1));
				fputs(file, "\n");
			}
			if (tfl2)
			{
				fputs(file, "lflags2\n");
				fputs(file, ftos(tfl2));
				fputs(file, "\n");
			}
			if (tfl3)
			{
				fputs(file, "lflags3\n");
				fputs(file, ftos(tfl3));
				fputs(file, "\n");
			}
			if (tfl4)
			{
				fputs(file, "lflags4\n");
				fputs(file, ftos(tfl4));
				fputs(file, "\n");
			}
			if (tfl5)
			{
				fputs(file, "lflags5\n");
				fputs(file, ftos(tfl5));
				fputs(file, "\n");
			}
			if (tfl6)
			{
				fputs(file, "lflags6\n");
				fputs(file, ftos(tfl6));
				fputs(file, "\n");
			}
			if (tfl7)
			{
				fputs(file, "lflags7\n");
				fputs(file, ftos(tfl7));
				fputs(file, "\n");
			}
			if (tfl8)
			{
				fputs(file, "lflags8\n");
				fputs(file, ftos(tfl8));
				fputs(file, "\n");
			}
			if (tfl9)
			{
				fputs(file, "lflags9\n");
				fputs(file, ftos(tfl9));
				fputs(file, "\n");
			}
			if (tfl10)
			{
				fputs(file, "lflags10\n");
				fputs(file, ftos(tfl10));
				fputs(file, "\n");
			}
			if (tfl11)
			{
				fputs(file, "lflags11\n");
				fputs(file, ftos(tfl11));
				fputs(file, "\n");
			}
			if (tfl12)
			{
				fputs(file, "lflags12\n");
				fputs(file, ftos(tfl12));
				fputs(file, "\n");
			}
			if (tfl13)
			{
				fputs(file, "lflags13\n");
				fputs(file, ftos(tfl13));
				fputs(file, "\n");
			}
			if (tfl14)
			{
				fputs(file, "lflags14\n");
				fputs(file, ftos(tfl14));
				fputs(file, "\n");
			}
			if (tfl15)
			{
				fputs(file, "lflags15\n");
				fputs(file, ftos(tfl15));
				fputs(file, "\n");
			}
			if (tfl16)
			{
				fputs(file, "lflags16\n");
				fputs(file, ftos(tfl16));
				fputs(file, "\n");
			}
			if (tfl17)
			{
				fputs(file, "lflags17\n");
				fputs(file, ftos(tfl17));
				fputs(file, "\n");
			}
			if (tfl18)
			{
				fputs(file, "lflags18\n");
				fputs(file, ftos(tfl18));
				fputs(file, "\n");
			}
			if (tfl19)
			{
				fputs(file, "lflags19\n");
				fputs(file, ftos(tfl19));
				fputs(file, "\n");
			}
			e = e.list;
		}
	}
	fclose(file);
};