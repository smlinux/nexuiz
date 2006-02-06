/* --- CheckNavNode ---
Evaluates travel cost and wether to continue search or not in this direction*/

float(entity from, entity to, float lflag) CheckNavNode =
{
	local float addcost;
	local vector foundpoint;
	local entity optpoint;

	if (!to)
		return FALSE;

	if (!(lflag & LF_NOWALK))
	if (!(lflag & LF_NOLINK))
	{
		if (from.sflags & S_TELEPORT) // teleporter exception
			foundpoint = from.origin;
		else
		{
			optpoint = MatchOptPoint(from, from.goallist, to);
			if (optpoint)
			{
				// bprint("^1SEARCH^7 succeeded!!!\n");
				foundpoint = optpoint.origin;
			}
			else
			{
				// bprint("No ^1SEARCH^7 success\n");
				foundpoint = ClampPointToSpace(from.pointl, from, to);
			}
		}
		addcost = vlen(from.pointl - foundpoint);
		addcost = addcost + from.costl;
		if (addcost <= search_distance)
		if (to.costl > addcost)
		{
			to.lmark = TRUE;
			to.goallist = from;
			to.costl = addcost;
			to.pointl = foundpoint;
		}
	}
	return TRUE;
};

/* --- MarkRoute ---
Searches as far as possible, and gives all navnodes a travel cost and shortest
travel point, which is then used for goal evaluation

Starts by clearing all navnodes, and searches breadth first from the starting navnode*/

void(float sdist) MarkRoute =
{
	local entity t, start;
	local float searching;

	start = FindCurrentNavNode(self.origin, self.mins, self.maxs);

	if(!start)
		return;

	search_distance = sdist;

	t = navnode_chain;
	while (t)
	{
		t.goallist = world;
		t.lmark = FALSE;
		t.costl = 10000000;
		t.pointl = '0 0 0';
		t = t.list;
	}

	start.lmark = TRUE;
	start.costl = 0;
	start.pointl = self.origin;

	searching = TRUE;
	while(searching)
	{
		searching = FALSE;
		t = navnode_chain;
		while(t)
		{
			if(t.lmark)
			{
				searching = TRUE;
				t.lmark = FALSE;
				if (CheckNavNode(t, t.link0, t.lflags0))
				if (CheckNavNode(t, t.link1, t.lflags1))
				if (CheckNavNode(t, t.link2, t.lflags2))
				if (CheckNavNode(t, t.link3, t.lflags3))
				if (CheckNavNode(t, t.link4, t.lflags4))
				if (CheckNavNode(t, t.link5, t.lflags5))
				if (CheckNavNode(t, t.link6, t.lflags6))
				if (CheckNavNode(t, t.link7, t.lflags7))
				if (CheckNavNode(t, t.link8, t.lflags8))
				if (CheckNavNode(t, t.link9, t.lflags9))
				if (CheckNavNode(t, t.link10, t.lflags10))
				if (CheckNavNode(t, t.link11, t.lflags11))
				if (CheckNavNode(t, t.link12, t.lflags12))
				if (CheckNavNode(t, t.link13, t.lflags13))
				if (CheckNavNode(t, t.link14, t.lflags14))
				if (CheckNavNode(t, t.link15, t.lflags15))
				if (CheckNavNode(t, t.link16, t.lflags16))
				if (CheckNavNode(t, t.link17, t.lflags17))
				if (CheckNavNode(t, t.link18, t.lflags18))
				CheckNavNode(t, t.link19, t.lflags19);
			}
			t = t.list;
		}
	}
};