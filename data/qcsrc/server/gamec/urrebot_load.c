/* --- UrreBotSetup ---
Issues a random funky name, random colors, playermodel and team to the bot*/

void() UrreBotSetup =
{
	local float r, shirt, pants;
	local string s;

	r = random()*18;
	if (r <= 1)
		s = "GrooveMachine";
	else if (r <= 2)
		s = "Worm";
	else if (r <= 3)
		s = "ClownLock";
	else if (r <= 4)
		s = "DiscO";
	else if (r <= 5)
		s = "FunkyFresh";
	else if (r <= 6)
		s = "DanceWithMe";
	else if (r <= 7)
		s = "BodyJiggle";
	else if (r <= 8)
		s = "CantSwim";
	else if (r <= 9)
		s = "AtomicDog";
	else if (r <= 10)
		s = "Follower";
	else if (r <= 11)
		s = "BrassMonkey";
	else if (r <= 12)
		s = "SirNose";
	else if (r <= 13)
		s = "StarChild";
	else if (r <= 14)
		s = "GeorgeC";
	else if (r <= 15)
		s = "Bootsy";
	else if (r <= 16)
		s = "Flashlight";
	else if (r <= 17)
		s = "Bodysnatcher";
	else
		s = "Boogieboy";

	self.netname = s;

	r = random()*15;
	if (r <= 1)
	{
		self.playermodel = "models/player/carni.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 2)
	{
		self.playermodel = "models/player/crash.zym";
		self.playerskin = "0";
	}
	else if (r <= 3)
	{
		self.playermodel = "models/player/grunt.zym";
		self.playerskin = "0";
	}
	else if (r <= 4)
	{
		self.playermodel = "models/player/headhunter.zym";
		self.playerskin = "0";
	}
	else if (r <= 5)
	{
		self.playermodel = "models/player/insurrectionist.zym";
		self.playerskin = "0";
	}
	else if (r <= 6)
	{
		self.playermodel = "models/player/jeandarc.zym";
		self.playerskin = "0";
	}
	else if (r <= 7)
	{
		self.playermodel = "models/player/lurk.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 8)
	{
		self.playermodel = "models/player/lycanthrope.zym";
		self.playerskin = "0";
	}
	else if (r <= 9)
	{
		self.playermodel = "models/player/marine.zym";
		self.playerskin = "0";
	}
	else if (r <= 10)
	{
		self.playermodel = "models/player/nexus.zym";
		if (random() < 0.5)
			self.playerskin = "0";
		else
			self.playerskin = "1";
	}
	else if (r <= 11)
	{
		self.playermodel = "models/player/pyria.zym";
		self.playerskin = "0";
	}
	else if (r <= 12)
	{
		self.playermodel = "models/player/shock.zym";
		self.playerskin = "0";
	}
	else if (r <= 13)
	{
		self.playermodel = "models/player/skadi.zym";
		self.playerskin = "0";
	}
	else if (r <= 14)
	{
		self.playermodel = "models/player/specop.zym";
		self.playerskin = "0";
	}
	else
	{
		self.playermodel = "models/player/visitant.zym";
		self.playerskin = "0";
	}

	if (teamplay)
		JoinBestTeam(self, 0);
	else
	{
		shirt = floor(random()*15);
		pants = floor(random()*15);
		self.clientcolors = pants + shirt * 16;
	}
};

/* --- UrreBotAdd ---
Adds an UrreBot to the server*/

entity(float bottype) UrreBotAdd =
{
	local entity ent, ret;

	ent = self;
	self = spawnclient();
	if (!self)
	{
		bprint("Can not add UrreBot, server full\n");
		if (bottype == BOT_TYPE_URREBOT)
			cvar_set("urrebots", ftos(urrebots));
		else
			cvar_set("bot_number", ftos(bot_number));
		self = ent;
		return world;
	}
	UrreBotSetup();
	self.list = urrebot_chain;
	urrebot_chain = self;
	ClientConnect();
	PutClientInServer();
	ret = self;
	self = ent;

	strategytoken = urrebot_chain;

	return ret;
};

/* --- UrreBotRemove ---
removes an UrreBot from the server*/

void() UrreBotRemove =
{
	local entity ent, t;

	ent = findchainflags(flags, FL_CLIENT);
	while (ent)
	{
		if (clienttype(ent) == CLIENTTYPE_BOT)
		{
			if (ent.bot_type == BOT_TYPE_URREBOT)
			{
				if (urrebot_chain == self)
					urrebot_chain = self.list;
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
				if (urrebots > 0)
					urrebots -= 1;
				self = ent;
				ClientDisconnect();
				dropclient(ent);
			}
		}
		ent = ent.chain;
	}
};

/* --- SpawnNavNode ---
The one to guess what this does gets free bacon from FrikaC*/

entity(vector org, vector nnmins, vector nnmaxs) SpawnNavNode =
{
	newmis = spawn();
	setsize(newmis, nnmins, nnmaxs);
	newmis.classname = "navnode";
	setorigin(newmis, org);
	return newmis;
};

/* --- AddPlane ---
Adds a plane to the plane list of a navnode*/

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

/* --- SpawnOptPoint ---
This function spawns waypoints for the most used paths between navnodes as an
optimisation*/

void(entity navn, entity l1, entity l2) SpawnOptPoint =
{
	local float upd;
	local vector point;
	local entity oldself;
	local entity l, upd_pt;

	upd = FALSE;
	point = ClampPointToSpace(ClampPointToSpace(l2.origin, l2, navn), l1, navn);
	l = navn.optp_chain;
	while (l)
	{
		if (point == l.origin)
		{
			upd = TRUE;
			upd_pt = l;
		}
		l = l.list;
	}

	if (upd)
	{
		if (upd_pt.link0 != l1)
		if (upd_pt.link1 != l1)
		if (upd_pt.link2 != l1)
		if (upd_pt.link3 != l1)
		if (upd_pt.link4 != l1)
		if (upd_pt.link5 != l1)
		if (upd_pt.link6 != l1)
		if (upd_pt.link7 != l1)
		if (upd_pt.link8 != l1)
		if (upd_pt.link9 != l1)
		{
			if (!upd_pt.link0)
				upd_pt.link0 = l1;
			else if (!upd_pt.link1)
				upd_pt.link1 = l1;
			else if (!upd_pt.link2)
				upd_pt.link2 = l1;
			else if (!upd_pt.link3)
				upd_pt.link3 = l1;
			else if (!upd_pt.link4)
				upd_pt.link4 = l1;
			else if (!upd_pt.link5)
				upd_pt.link5 = l1;
			else if (!upd_pt.link6)
				upd_pt.link6 = l1;
			else if (!upd_pt.link7)
				upd_pt.link7 = l1;
			else if (!upd_pt.link8)
				upd_pt.link8 = l1;
			else if (!upd_pt.link9)
				upd_pt.link9 = l1;
		}
		upd = FALSE;
		if (upd_pt.link10 != l2)
		if (upd_pt.link11 != l2)
		if (upd_pt.link12 != l2)
		if (upd_pt.link13 != l2)
		if (upd_pt.link14 != l2)
		if (upd_pt.link15 != l2)
		if (upd_pt.link16 != l2)
		if (upd_pt.link17 != l2)
		if (upd_pt.link18 != l2)
		if (upd_pt.link19 != l2)
		{
			if (!upd_pt.link10)
			{
				upd_pt.link10 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link11)
			{
				upd_pt.link11 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link12)
			{
				upd_pt.link12 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link13)
			{
				upd_pt.link13 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link14)
			{
				upd_pt.link14 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link15)
			{
				upd_pt.link15 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link16)
			{
				upd_pt.link16 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link17)
			{
				upd_pt.link17 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link18)
			{
				upd_pt.link18 = l2;
				upd = TRUE;
			}
			else if (!upd_pt.link19)
			{
				upd_pt.link19 = l2;
				upd = TRUE;
			}
		}
	}

	if (!upd)
	{
		newmis = spawn();
		newmis.classname = "optpoint";
		newmis.list = navn.optp_chain;
		navn.optp_chain = newmis;
		setmodel(newmis, "models/misc/chatbubble.spr");
		setsize (newmis, PL_MIN, PL_MAX);
		oldself = self;
		self = newmis;
		point = ClampPointToSpace(ClampPointToSpace(l2.origin, l2, navn), l1, navn);
		self = oldself;
		setorigin(newmis, point);
		newmis.link0 = l1;
		newmis.link10 = l2;
	}
};

void() OptimiseNavigation =
{
	local entity navn, l;

	navn = navnode_chain;
	while (navn)
	{
		l = navn.optp_chain;
		while (l)
		{
			l.think = SUB_Remove;
			l.nextthink = time;
			SpawnOptPoint(navn, l.enemy, navn);
			if (navn.link0 != l.enemy)
				SpawnOptPoint(navn, l.enemy, navn.link0);
			if (navn.link1)
			{
				if (navn.link1 != l.enemy)
					SpawnOptPoint(navn, l.enemy, navn.link1);
				if (navn.link2)
				{
					if (navn.link2 != l.enemy)
						SpawnOptPoint(navn, l.enemy, navn.link2);
					if (navn.link3)
					{
						if (navn.link3 != l.enemy)
							SpawnOptPoint(navn, l.enemy, navn.link3);
						if (navn.link4)
						{
							if (navn.link4 != l.enemy)
								SpawnOptPoint(navn, l.enemy, navn.link4);
							if (navn.link5)
							{
								if (navn.link5 != l.enemy)
									SpawnOptPoint(navn, l.enemy, navn.link5);
								if (navn.link6)
								{
									if (navn.link6 != l.enemy)
										SpawnOptPoint(navn, l.enemy, navn.link6);
									if (navn.link7)
									{
										if (navn.link7 != l.enemy)
											SpawnOptPoint(navn, l.enemy, navn.link7);
										if (navn.link8)
										{
											if (navn.link8 != l.enemy)
												SpawnOptPoint(navn, l.enemy, navn.link8);
											if (navn.link9)
											{
												if (navn.link9 != l.enemy)
													SpawnOptPoint(navn, l.enemy, navn.link9);
												if (navn.link10)
												{
													if (navn.link10 != l.enemy)
														SpawnOptPoint(navn, l.enemy, navn.link10);
													if (navn.link11)
													{
														if (navn.link11 != l.enemy)
															SpawnOptPoint(navn, l.enemy, navn.link11);
														if (navn.link12)
														{
															if (navn.link12 != l.enemy)
																SpawnOptPoint(navn, l.enemy, navn.link12);
															if (navn.link13)
															{
																if (navn.link13 != l.enemy)
																	SpawnOptPoint(navn, l.enemy, navn.link13);
																if (navn.link14)
																{
																	if (navn.link14 != l.enemy)
																		SpawnOptPoint(navn, l.enemy, navn.link14);
																	if (navn.link15)
																	{
																		if (navn.link15 != l.enemy)
																			SpawnOptPoint(navn, l.enemy, navn.link15);
																		if (navn.link16)
																		{
																			if (navn.link16 != l.enemy)
																				SpawnOptPoint(navn, l.enemy, navn.link16);
																			if (navn.link17)
																			{
																				if (navn.link17 != l.enemy)
																					SpawnOptPoint(navn, l.enemy, navn.link17);
																				if (navn.link18)
																				{
																					if (navn.link18 != l.enemy)
																						SpawnOptPoint(navn, l.enemy, navn.link18);
																					if (navn.link19)
																					if (navn.link19 != l.enemy)
																						SpawnOptPoint(navn, l.enemy, navn.link19);
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			l = l.list;
		}
		navn = navn.list;
	}
};

void(entity navn, entity linked) SpawnOptController =
{
	newmis = spawn();
	newmis.classname = "optcontroller";
	newmis.list = navn.optp_chain;
	navn.optp_chain = newmis;
	newmis.enemy = linked;
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
					SpawnOptController(e, t);
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

/* --- LoadNavNodes ---
Loads the navnodes from an .nnl file (NavNodeList) for the map*/

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
	s = strcat("maps/", s, ".nnl");

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
