void() UrreBotAdd =
{
	local entity ent;

	ent = self;
	self = spawnclient();
	if (!self)
	{
		bprint("Can not add UrreBot, server full\n");
		cvar_set("bots", ftos(actualurrebots));
		self = ent;
		return;
	}
	UrreBotSetup();
	self.list = bot_chain;
	bot_chain = self;
	self.bottype = BOTTYPE_URREBOT;
	ClientConnect();
	PutClientInServer();
	self = ent;

	strategytoken = bot_chain;
	actualurrebots = actualurrebots + 1;
};

void() UrreBotRemove =
{
	local entity ent, t;

	ent = findchain(classname, "player");
	while (ent)
	{
		if (clienttype(ent) == CLIENTTYPE_BOT)
		{
			if (ent.bottype == BOTTYPE_URREBOT)
			{
				if (bot_chain == self)
					bot_chain = self.list;
				else
				{
					t = find(world, classname, "player");
					while(t)
					{
						if (t.list == ent)
							t.list = ent.list;
						t = find(t, classname, "player");
					}
				}
				if (actualurrebots > 0)
					actualurrebots -= 1;
				if(cvar("g_lms") && self.frags < 1)
					lms_dead_count -= 1;
				dropclient(ent);
			}
		}
		ent = ent.chain;
	}
};

/* --- SpawnNavNode ---
The one to guess what this does gets bacon from FrikaC*/

entity(vector org, vector nnmins, vector nnmaxs) SpawnNavNode =
{
	newmis = spawn();
	setsize(newmis, nnmins, nnmaxs);
	newmis.classname = "navnode";
	setorigin(newmis, org);
	return newmis;
};

void(entity navn, vector normal, float dist) AddPlane =
{
	local float f;

	newmis = spawn();
	newmis.classname = "plane";
	newmis.list = navn.plane_chain;
	navn.plane_chain = newmis;
	newmis.mangle = normal*-1;
	newmis.delay = dist;
	f = (navn.origin * newmis.mangle) - ((navn.origin + (newmis.delay * newmis.mangle)) * newmis.mangle);
	if (f > 0)
	{
		newmis.mangle = newmis.mangle*-1;
		newmis.delay = newmis.delay*-1;
	}
};

/* --- LinkNavNodes ---
Links the navnodes and gives some special attributes (like doors, teleporters)*/

void() LinkNavNodes =
{
	local entity e, t, tdest;

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
		if (e.link1)
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
		if (e.link2)
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
		if (e.link3)
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
		if (e.link4)
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
		if (e.link5)
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
		if (e.link6)
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
		if (e.link7)
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
		if (e.link8)
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
		if (e.link9)
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
		if (e.link10)
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
		if (e.link11)
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
		if (e.link12)
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
		if (e.link13)
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
		if (e.link14)
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
		if (e.link15)
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
		if (e.link16)
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
		if (e.link17)
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
		if (e.link18)
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
		if (e.link19)
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
		e = e.list;
	}
	e = navnode_chain;
	while (e)
	{
		if (!(e.sflags & S_TELEPORT))
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
		}
		e = e.list;
	}
	e = navnode_chain;
	while (e)
	{
		if (e.sflags & S_TELEPORT)
		{
			t = findchain(classname, "trigger_teleport");
			while (t)
			{
				if (boxesoverlap(t.absmin, t.absmax, e.absmin, e.absmax))
				{
					tdest = find(world, targetname, t.target);
					tdest = FindCurrentNavNode(tdest.origin, '0 0 0', '0 0 0');
					e.link0 = tdest;
				}
				t = t.chain;
			}
			if (!e.link0)
				error("Expected navnode\n");
		}
		else if (e.sflags & S_DOOR)
		{
			t = findchain(classname, "door");
			while (t)
			{
				if (boxesoverlap(t.absmin, t.absmax, e.absmin, e.absmax))
					e.goalentity = t;
				t = t.chain;
			}
			if (!e.goalentity)
				error("Expected door\n");
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
		dprint("Found navnode file\n");
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
		}
		fclose(file);
	}
	else
		dprint("No navnode file found\n");
	remove(plane_storage);
	plane_storage = world;
};

/* --- SpawnWayBox ---
The one to guess what this does gets a cookie from Quest*/
/*
entity(vector org, vector wsize) SpawnWayBox =
{
	newmis = spawn();
	setsize(newmis, wsize*-1, wsize);
	newmis.classname = "waybox";
	setorigin(newmis, org);
	return (newmis);
};
*/
/* --- LinkWayBoxes ---
Links wayboxes and gives some special attributes (like doors, teleporters)*/

/*
void() LinkWayBoxes =
{
	local entity e, t, tdest;

	box_chain = world;
	wayboxes = 0;

	e = findchain(classname, "waybox");
	while (e)
	{
		e.list = box_chain;
		box_chain = e;
		e.link0 = e.link1 = e.link2 = e.link3 = e.link4 = e.link5 = e.link6 = e.link7 = e.link8 = e.link9 = world;
		e.link10 = e.link11 = e.link12 = e.link13 = e.link14 = e.link15 = e.link16 = e.link17 = e.link18 = e.link19 = world;
		wayboxes = wayboxes + 1;
		e = e.chain;
	}

	e = box_chain;
	while (e)
	{
		if (!(e.sflags & S_TELEPORT))
		{
			t = box_chain;
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
						objerror("Too many touching wayboxes!\n");
				}
				t = t.list;
			}
		}
		e = e.list;
	}
	e = box_chain;
	while (e)
	{
		if (e.sflags & S_TELEPORT)
		{
			t = findchain(classname, "trigger_teleport");
			while (t)
			{
				if (boxesoverlap(t.absmin, t.absmax, e.absmin, e.absmax))
				{
					tdest = find(world, targetname, t.target);
					tdest = FindCurrentWayBox(tdest.origin, '0 0 0', '0 0 0');
					e.link0 = tdest;
				}
				t = t.chain;
			}
		}
		else if (e.sflags & S_DOOR)
		{
			t = findchain(classname, "door");
			while (t)
			{
				if (boxesoverlap(t.absmin, t.absmax, e.absmin, e.absmax))
					e.goalentity = t;
				t = t.chain;
			}
			if (!e.goalentity)
				error("Expected door\n");
		}
		e = e.list;
	}
};
*/

/* --- LoadWayBoxes ---
Loads wayboxes from a file generated by the waybox-editor mod*/

/*
void() LoadNavs =
{
	local float f, file, length;
	local float sfl;
	local float tfl0, tfl1, tfl2, tfl3, tfl4, tfl5, tfl6, tfl7, tfl8, tfl9;
	local float tfl10, tfl11, tfl12, tfl13, tfl14, tfl15, tfl16, tfl17, tfl18, tfl19;
	local string s, nname;
	local vector wborg, wbmaxs;
	local entity e;

	if (navents)
	{
		dprint("NavEntities present, map needs to be reloaded to load navent-file\n");
		return;
	}

	length = strlen(world.model);
	length = length - 5;
	s = substring(world.model, 5, length);
	s = strcat(s, ".nel");

	file = fopen(s, FILE_READ);

	if (file >= 0)
	{
		s = fgets(file);
		while (s == "navent")
		{
			f = 0;
			sfl = 0;
			tfl0 = tfl1 = tfl2 = tfl3 = tfl4 = tfl5 = tfl6 = tfl7 = tfl8 = tfl9 = 0;
			tfl10 = tfl11 = tfl12 = tfl13 = tfl14 = tfl15 = tfl16 = tfl17 = tfl18 = tfl19 = 0;
			s = fgets(file);
			if (s == "sflags")
			{
				s = fgets(file);
				sfl = stof(s);
				s = fgets(file);
			}
			while (substring(s, 0, 6) == "tflags")
			{
				f = stof(substring(s, 6, 7));
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
			wborg = stov(s);
			s = fgets(file);
			wbmaxs = stov(s);
			e = SpawnNavEnt(wborg, wbmaxs);
			e.sflags = sfl;
			e.tflags0 = tfl0;
			e.tflags1 = tfl1;
			e.tflags2 = tfl2;
			e.tflags3 = tfl3;
			e.tflags4 = tfl4;
			e.tflags5 = tfl5;
			e.tflags6 = tfl6;
			e.tflags7 = tfl7;
			e.tflags8 = tfl8;
			e.tflags9 = tfl9;
			e.tflags10 = tfl10;
			e.tflags11 = tfl11;
			e.tflags12 = tfl12;
			e.tflags13 = tfl13;
			e.tflags14 = tfl14;
			e.tflags15 = tfl15;
			e.tflags16 = tfl16;
			e.tflags17 = tfl17;
			e.tflags18 = tfl18;
			e.tflags19 = tfl19;
			s = fgets(file);
		}
		fclose(file);
	}
	LinkNavs();
};
*/
/*
void() LoadWayBoxes =
{
	local float f, file, length;
	local float sfl;
	local float tfl0, tfl1, tfl2, tfl3, tfl4, tfl5, tfl6, tfl7, tfl8, tfl9;
	local float tfl10, tfl11, tfl12, tfl13, tfl14, tfl15, tfl16, tfl17, tfl18, tfl19;
	local string s, nname;
	local vector wborg, wbmaxs;
	local entity e;

	if (wayboxes)
	{
		dprint("Wayboxes present, map needs to be reloaded to load waybox-file\n");
		return;
	}

	length = strlen(world.model);
	length = length - 5;
	s = substring(world.model, 5, length);
	s = strcat(s, ".wbl");

	file = fopen(s, FILE_READ);

	if (file >= 0)
	{
		s = fgets(file);
		while (s == "waybox")
		{
			f = 0;
			sfl = 0;
			tfl0 = tfl1 = tfl2 = tfl3 = tfl4 = tfl5 = tfl6 = tfl7 = tfl8 = tfl9 = 0;
			tfl10 = tfl11 = tfl12 = tfl13 = tfl14 = tfl15 = tfl16 = tfl17 = tfl18 = tfl19 = 0;
			s = fgets(file);
			if (s == "sflags")
			{
				s = fgets(file);
				sfl = stof(s);
				s = fgets(file);
			}
			while (substring(s, 0, 6) == "tflags")
			{
				f = stof(substring(s, 6, 7));
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
			wborg = stov(s);
			s = fgets(file);
			wbmaxs = stov(s);
			e = SpawnWayBox(wborg, wbmaxs);
			e.sflags = sfl;
			e.tflags0 = tfl0;
			e.tflags1 = tfl1;
			e.tflags2 = tfl2;
			e.tflags3 = tfl3;
			e.tflags4 = tfl4;
			e.tflags5 = tfl5;
			e.tflags6 = tfl6;
			e.tflags7 = tfl7;
			e.tflags8 = tfl8;
			e.tflags9 = tfl9;
			e.tflags10 = tfl10;
			e.tflags11 = tfl11;
			e.tflags12 = tfl12;
			e.tflags13 = tfl13;
			e.tflags14 = tfl14;
			e.tflags15 = tfl15;
			e.tflags16 = tfl16;
			e.tflags17 = tfl17;
			e.tflags18 = tfl18;
			e.tflags19 = tfl19;
			s = fgets(file);
		}
		fclose(file);
	}
};
*/
