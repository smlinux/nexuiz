void(string s) SV_ParseClientCommand =
{
	local float f, f2, args;
	local string c, s1;
	local vector v;
	local entity navcurrent, navother;

	f = -1;

	args = tokenize(s);
	c = argv(0);
	if (c == "say")
	{
		c = argv(1);
		navcurrent = self.current_navnode;
		navother = self.other_navnode;
		if (c == "origin")
		{
			if (navcurrent)
			{
				s1 = argv(2);
				s1 = strcat(s1, " ");
				s1 = strcat(s1, argv(3));
				s1 = strcat(s1, " ");
				s1 = strcat(s1, argv(4));
				v = stov(s1);
				setorigin(navcurrent, v);
			}
			else
				sprint(self, "No selection\n");
		}
		else if (c == "resize")
		{
			if (!ResizeNavNode(navcurrent, self.axis, stof(argv(2))))
				sprint(self, "No selection\n");
		}
		else if (c == "save")
		{
			LinkNavNodes();
			SaveNavNodes();
		}
		else if (c == "load")
			LoadNavNodes();
		else if (c == "teleport")
		{
			if (navcurrent)
			{
				if (navcurrent.sflags & S_TELEPORT)
					navcurrent.sflags = navcurrent.sflags - (navcurrent.sflags & S_TELEPORT);
				else
					navcurrent.sflags = navcurrent.sflags | S_TELEPORT;
			}
			else
				sprint(self, "No selection\n");
		}
		else if (c == "door")
		{
			if (navcurrent)
			{
				if (navcurrent.sflags & S_DOOR)
					navcurrent.sflags = navcurrent.sflags - (navcurrent.sflags & S_DOOR);
				else
					navcurrent.sflags = navcurrent.sflags | S_DOOR;
			}
			else
				sprint(self, "No selection\n");
		}
		else if (c == "touch")
		{
			if (navcurrent)
			{
				if (navcurrent.sflags & S_TOUCH)
					navcurrent.sflags = navcurrent.sflags - (navcurrent.sflags & S_TOUCH);
				else
					navcurrent.sflags = navcurrent.sflags | S_TOUCH;
			}
			else
				sprint(self, "No selection\n");
		}
		else if (c == "nolink")
		{
			if (argv(2))
				f = stof(argv(2));
			LFlagChange(navcurrent, f, LF_NOLINK);
		}
		else if (c == "nowalk")
		{
			if (argv(2))
				f = stof(argv(2));
			LFlagChange(navcurrent, f, LF_NOWALK);
		}
		else if (c == "bad")
		{
			if (argv(2))
				f = stof(argv(2));
			LFlagChange(navcurrent, f, LF_BAD);
		}
		else if (c == "bigdrop")
		{
			if (argv(2))
				f = stof(argv(2));
			LFlagChange(navcurrent, f, LF_BIGDROP);
		}
		else if (c == "remote")
			RemoteLinkHandling(navcurrent, navother);
		else
			clientcommand(self, s);		
	}
	else
		clientcommand(self, s);
};

void() FixFrames =
{
	local entity e;

	if (self.other_navnode)
		self.other_navnode.colormod = '0 0 0';

	if (self.current_navnode)
	{
		self.current_navnode.colormod = '0 0 0';
		self.current_navnode.scale = 1;
		e = self.current_navnode.plane_chain;
		if (e)
		{
			e.effects = EF_NODRAW;
			e = e.plane_next;
			while (e != self.current_navnode.plane_chain)
			{
				e.effects = EF_NODRAW;
				e = e.plane_next;
			}
		}
		if (self.current_navnode.link0)
		{
			self.current_navnode.link0.effects = 0;
			self.current_navnode.link0.frame = 20;
			if (self.current_navnode.link1)
			{
				self.current_navnode.link1.effects = 0;
				self.current_navnode.link1.frame = 20;
				if (self.current_navnode.link2)
				{
					self.current_navnode.link2.effects = 0;
					self.current_navnode.link2.frame = 20;
					if (self.current_navnode.link3)
					{
						self.current_navnode.link3.effects = 0;
						self.current_navnode.link3.frame = 20;
						if (self.current_navnode.link4)
						{
							self.current_navnode.link4.effects = 0;
							self.current_navnode.link4.frame = 20;
							if (self.current_navnode.link5)
							{
								self.current_navnode.link5.effects = 0;
								self.current_navnode.link5.frame = 20;
								if (self.current_navnode.link6)
								{
									self.current_navnode.link6.effects = 0;
									self.current_navnode.link6.frame = 20;
									if (self.current_navnode.link7)
									{
										self.current_navnode.link7.effects = 0;
										self.current_navnode.link7.frame = 20;
										if (self.current_navnode.link8)
										{
											self.current_navnode.link8.effects = 0;
											self.current_navnode.link8.frame = 20;
											if (self.current_navnode.link9)
											{
												self.current_navnode.link9.effects = 0;
												self.current_navnode.link9.frame = 20;
												if (self.current_navnode.link10)
												{
													self.current_navnode.link10.effects = 0;
													self.current_navnode.link10.frame = 20;
													if (self.current_navnode.link11)
													{
														self.current_navnode.link11.effects = 0;
														self.current_navnode.link11.frame = 20;
														if (self.current_navnode.link12)
														{
															self.current_navnode.link12.effects = 0;
															self.current_navnode.link12.frame = 20;
															if (self.current_navnode.link13)
															{
																self.current_navnode.link13.effects = 0;
																self.current_navnode.link13.frame = 20;
																if (self.current_navnode.link14)
																{
																	self.current_navnode.link14.effects = 0;
																	self.current_navnode.link14.frame = 20;
																	if (self.current_navnode.link15)
																	{
																		self.current_navnode.link15.effects = 0;
																		self.current_navnode.link15.frame = 20;
																		if (self.current_navnode.link16)
																		{
																			self.current_navnode.link16.effects = 0;
																			self.current_navnode.link16.frame = 20;
																			if (self.current_navnode.link17)
																			{
																				self.current_navnode.link17.effects = 0;
																				self.current_navnode.link17.frame = 20;
																				if (self.current_navnode.link18)
																				{
																					self.current_navnode.link18.effects = 0;
																					self.current_navnode.link18.frame = 20;
																					if (self.current_navnode.link19)
																					{
																						self.current_navnode.link19.effects = 0;
																						self.current_navnode.link19.frame = 20;
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
			}
		}
	}
};

void() SwitchNavNode =
{
	FixFrames();
	self.current_navnode = FindCurrentNavNode(self.current_navnode, self.origin, self.selmode);
	if (!self.current_navnode)
		self.current_navnode = FindCurrentNavNode(world, self.origin, self.selmode);
};

void(float match) SwitchAxis =
{
	if (match == -1)
	{
		self.axis = self.axis + 1;
		if (self.axis > 2)
			self.axis = 0;
	}
	else if (match == 0)
		self.axis = 0;
	else if (match == 1)
		self.axis = 1;
	else if (match == 2)
		self.axis = 2;
};

void(float i) ImpulseCommands =
{
	local float f;
	local vector v;
	local entity e;

	if (self.confirm && i >= 1 && i <= 9)
	{
		Select(i);
		return;
	}
	else if (i == 101)
	{
		if (self.button3 & !self.button4)
		{
			if (self.axis == 0)
				f = self.current_navnode.origin_x + self.current_navnode.maxs_x;
			else if (self.axis == 1)
				f = self.current_navnode.origin_y + self.current_navnode.maxs_y;
			else if (self.axis == 2)
				f = self.current_navnode.origin_z + self.current_navnode.maxs_z;
			f = f + self.gridsize;
			ResizeNavNode(self.current_navnode, self.axis, f);
		}
		else if (self.button4 & !self.button3)
		{
			if (self.current_clippoint)
			{
				e = self.current_clippoint;
				v = self.current_clippoint.origin;
			}
			else
			{
				e = self.current_navnode;
				v = self.current_navnode.origin;
			}
			if (self.axis == 0)
				v_x = v_x + self.gridsize;
			else if (self.axis == 1)
				v_y = v_y + self.gridsize;
			else if (self.axis == 2)
				v_z = v_z + self.gridsize;
			MoveNavNode(e, v);
		}
		else if (self.button3 & self.button4)
		{
			if (self.current_clippoint)
			{
				if (self.current_clippoint == self.clippoint1)
				{
					if (self.clippoint2)
						self.current_clippoint = self.clippoint2;
					else
						self.current_clippoint = self.clippoint1;
				}
				else if (self.current_clippoint == self.clippoint2)
				{
					if (self.clippoint3)
						self.current_clippoint = self.clippoint3;
					else
						self.current_clippoint = self.clippoint1;
				}
				else if (self.current_clippoint == self.clippoint3)
					self.current_clippoint = self.clippoint1;
			}
			else
				self.current_plane = self.current_plane.plane_next;
		}
		else
			self.gridsize = self.gridsize * 2;
	}
	else if (i == 102)
	{
		if (self.button3 & !self.button4)
		{
			if (self.axis == 0)
				f = self.current_navnode.origin_x + self.current_navnode.maxs_x;
			else if (self.axis == 1)
				f = self.current_navnode.origin_y + self.current_navnode.maxs_y;
			else if (self.axis == 2)
				f = self.current_navnode.origin_z + self.current_navnode.maxs_z;
			f = f - self.gridsize;
			ResizeNavNode(self.current_navnode, self.axis, f);
		}
		else if (self.button4 & !self.button3)
		{
			if (self.current_clippoint)
			{
				e = self.current_clippoint;
				v = self.current_clippoint.origin;
			}
			else
			{
				e = self.current_navnode;
				v = self.current_navnode.origin;
			}
			if (self.axis == 0)
				v_x = v_x - self.gridsize;
			else if (self.axis == 1)
				v_y = v_y - self.gridsize;
			else if (self.axis == 2)
				v_z = v_z - self.gridsize;
			MoveNavNode(e, v);
		}
		else if (self.button3 & self.button4)
		{
			if (self.current_clippoint)
			{
				if (self.current_clippoint == self.clippoint1)
				{
					if (self.clippoint3)
						self.current_clippoint = self.clippoint3;
					else if (self.clippoint2)
						self.current_clippoint = self.clippoint2;
					else
						self.current_clippoint = self.clippoint1;
				}
				else if (self.current_clippoint == self.clippoint2)
					self.current_clippoint = self.clippoint1;
				else if (self.current_clippoint == self.clippoint3)
					self.current_clippoint = self.clippoint2;
			}
			else
				self.current_plane = self.current_plane.plane_prev;
		}
		else
		{
			self.gridsize = self.gridsize * 0.5;
			if (self.gridsize < 1)
				self.gridsize = 1;
		}
	}
	else if (i == 110)	// Spawns new navnode
	{
		if (!self.lockselection)
		{
			v = SnapToGrid(self.origin);
			e = SpawnNavNode(v, '-32 -32 -32', '32 32 32');
			LinkNavNodes();
			if (e)
			{
				FixFrames();
				self.current_navnode = e;
				self.other_navnode = e;
				self.lockselection = TRUE;
				self.confirm = 0;
			}
		}
	}
	else if (i == 111)	// Deletes current navnode (FIXME: better solution? most think remote functions checking for variables in cases such as this is ugly)
	{
		if (self.current_navnode)
		{
			self.confirm = C_DELETE_NAVNODE;
			self.lockselection = TRUE;
		}
	}
	else if (i == 112)	// Deletes current plane (FIXME: better solution? most think remote functions checking for variables in cases such as this is ugly)
	{
		if (self.current_plane)
		{
			self.confirm = C_DELETE_PLANE;
			self.lockselection = TRUE;
		}
	}
	else if (i == 120)	// Switches navnode in case of overlap
	{
		if (!self.lockselection)
		if (self.selmode == M_OVERLAP)
			SwitchNavNode();
	}
	else if (i == 121)	// Switches selection mode
	{
		if (self.selmode == M_OVERLAP)
			self.selmode = M_CLOSEST;
		else if (self.selmode == M_CLOSEST)
			self.selmode = M_OVERLAP;
	}
	else if (i == 122)	// Cycles through axis
		SwitchAxis(-1);
	else if (i == 123)	// Switches to X axis
		SwitchAxis(0);
	else if (i == 124)	// Switches to Y axis
		SwitchAxis(1);
	else if (i == 125)	// Switches to Z axis
		SwitchAxis(2);
};

void() ClientKill = {};

void() ClientConnect =
{
	bprint (self.netname);
	bprint (" has connected\n");
};

void() ClientDisconnect =
{
	bprint (self.netname);
	bprint (" has disconnected\n");
};

float BT_LIGHTNING = 0;
float BT_BEAM = 1;

void(float beamtype, vector bmins, vector bmaxs) BeamBox =
{
	local vector v1, v2;

	v1 = bmaxs;
	v2 = bmaxs;
	v2_x = bmins_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v2 = bmaxs;
	v2_y = bmins_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v2 = bmaxs;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_x = bmaxs_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_y = bmaxs_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v2 = bmins;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_z = bmaxs_z;
	v2 = bmins;
	v2_x = bmaxs_x;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_z = bmaxs_z;
	v2 = bmins;
	v2_y = bmaxs_y;
	v2_z = bmaxs_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v1_z = bmins_z;
	v2 = bmaxs;
	v2_x = bmins_x;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmaxs;
	v1_z = bmins_z;
	v2 = bmaxs;
	v2_y = bmins_y;
	v2_z = bmins_z;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_x = bmaxs_x;
	v2 = bmaxs;
	v2_y = bmins_y;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
	v1 = bmins;
	v1_y = bmaxs_y;
	v2 = bmaxs;
	v2_x = bmins_x;
	if (beamtype == BT_LIGHTNING)
		te_lightning1(world, v1, v2);
	else
		te_beam(world, v1, v2);
};

void() PlayerPreThink =
{
	local float f;
	local vector v, edge1, edge2, org, tvec, intonav; // FIXME
	local string s;
	local entity e, navcurrent, navother, delplane;

	if (self.selmode == M_OVERLAP)
	{
		if (self.current_navnode)
		if (!self.lockselection)
		if (!boxesoverlap(self.origin, self.origin, self.current_navnode.origin + self.current_navnode.mins, self.current_navnode.origin + self.current_navnode.maxs))
		{
			FixFrames();
			self.other_navnode = world;
			self.current_navnode = world;
		}
	}
	else if (self.selmode == M_CLOSEST)
	{
		if (self.current_navnode)
		if (!self.lockselection)
		{
			e = FindCurrentNavNode(world, self.origin, self.selmode);
			if (e != self.current_navnode)
			{
				FixFrames();
				self.other_navnode = world;
				self.current_navnode = world;
			}
		}
	}

	if (self.current_navnode)
		navcurrent = self.current_navnode;
	else
	{
		self.current_plane = world;
		navcurrent = self.current_navnode = FindCurrentNavNode(world, self.origin, self.selmode);
	}

	navother = FindCurrentNavNode(world, self.origin, self.selmode);
	if (self.other_navnode)
	if (navother != self.other_navnode)
	{
		if (self.other_navnode != self.current_navnode)
			self.other_navnode.colormod = '0 0 0';
	}
	self.other_navnode = navother;

	if (self.button0)
	{
		if (!(self.buttonflag & B_FLAG0))
		{
			if (!self.button2)
			{
				if (self.button3 & !self.button4)
				{
					makevectors(self.v_angle);
					traceline(self.origin, self.origin + v_forward*8192, TRUE, world);
					v = SnapToGrid(trace_endpos);
					if (self.axis == 0)
						ResizeNavNode(navcurrent, self.axis, v_x);
					else if (self.axis == 1)
						ResizeNavNode(navcurrent, self.axis, v_y);
					else if (self.axis == 2)
						ResizeNavNode(navcurrent, self.axis, v_z);
				}
				else if (self.button4 & !self.button3)
				{
					makevectors(self.v_angle);
					traceline(self.origin, self.origin + v_forward*8192, TRUE, world);
					if (self.current_clippoint)
						e = self.current_clippoint;
					else
						e = navcurrent;
					v = SnapToGrid(trace_endpos);
					MoveNavNode(e, v);
				}
				else if (self.button3 & self.button4)
				{
					if (self.clippoint3)
					{
						edge1=self.clippoint1.origin-self.clippoint2.origin;
						edge2=self.clippoint3.origin-self.clippoint2.origin;
						v_x=edge1_y*edge2_z-edge1_z*edge2_y;
						v_y=edge1_z*edge2_x-edge1_x*edge2_z;
						v_z=edge1_x*edge2_y-edge1_y*edge2_x;
						v = normalize(v);
						org = (((self.clippoint1.origin + self.clippoint2.origin)*0.5) + self.clippoint3.origin)*0.5;
						RemoveClippoints();
					}
					else
					{
						makevectors(self.v_angle);
						traceline(self.origin, self.origin + v_forward*8192, TRUE, world);
						v = trace_plane_normal;
						org = trace_endpos;
					}
					f = rint(v * (navcurrent.origin - org));
					delplane = world;
					e = navcurrent.plane_chain;
					if (e)
					{
						if (e.mangle == v*-1)
						if (e.delay == f)
							delplane = e;
						e = e.plane_next;
						while (e != navcurrent.plane_chain)
						{
							if (e.mangle == v*-1)
							if (e.delay == f)
								delplane = e;
							e = e.plane_next;
						}
					}
					if (delplane)
					{
						RemovePlane(navcurrent, delplane);
						self.current_plane = world;
					}
					else
						AddPlane(navcurrent, v, f);
				}
				else
				{
					makevectors (self.v_angle);
					v = v_forward*-1;
					traceline(self.origin, self.origin + v_forward*8192, TRUE, self);
					f = pointcontents(trace_endpos);
					if (f != CONTENT_SOLID || f != CONTENT_SKY)
						setorigin(self, trace_endpos + v*8);
				}
			}
		}
		self.buttonflag = self.buttonflag | B_FLAG0;
	}
	else
		self.buttonflag = self.buttonflag - (self.buttonflag & B_FLAG0);

	if (self.button2)
	{
		if (!(self.buttonflag & B_FLAG2))
		{
			if (!self.button0)
			{
				if (self.button3 & !self.button4)
				{
					v = SnapToGrid(self.origin);
					ResizeNavNode(navcurrent, 0, v_x);
					ResizeNavNode(navcurrent, 1, v_y);
					ResizeNavNode(navcurrent, 2, v_z);
				}
				else if (self.button4 & !self.button3)
				{
					if (self.current_clippoint)
						e = self.current_clippoint;
					else
						e = navcurrent;
					v = SnapToGrid(self.origin);
					MoveNavNode(e, v);
				}
				else if (self.button3 & self.button4)
				{
					if (navcurrent)
					if (self.lockselection)
					{
						v = SnapToGrid(self.origin);
						SpawnClipPoint(v);
					}
				}
				else if (!self.confirm)
				{
					if (self.lockselection)
					{
						RemoveClippoints();
						self.lockselection = FALSE;
					}
					else
						self.lockselection = TRUE;
				}
			}
		}
		self.buttonflag = self.buttonflag | B_FLAG2;
	}
	else
		self.buttonflag = self.buttonflag - (self.buttonflag & B_FLAG2);

	if (time >= self.ltntime + 0.15)
	{
		self.ltntime = time;
		if (navcurrent)
		{
			navcurrent.scale = 0.2;
			if (!self.current_plane)
				self.current_plane = navcurrent.plane_chain;
			if (self.lockselection)
			{
				if (self.clippoint1)
				{
					if (!self.current_clippoint)
						self.current_clippoint = self.clippoint1;
					if (self.current_clippoint == self.clippoint1)
					{
						self.clippoint1.colormod = '1 0 0';
						if (self.clippoint2)
						{
							self.clippoint2.colormod = '0 0 0';
							if (self.clippoint3)
								self.clippoint3.colormod = '0 0 0';
						}
					}
					else if (self.current_clippoint == self.clippoint2)
					{
						self.clippoint2.colormod = '1 0 0';
						if (self.clippoint1)
						{
							self.clippoint1.colormod = '0 0 0';
							if (self.clippoint3)
								self.clippoint3.colormod = '0 0 0';
						}
					}
					else if (self.current_clippoint == self.clippoint3)
					{
						self.clippoint3.colormod = '1 0 0';
						if (self.clippoint1)
						{
							self.clippoint1.colormod = '0 0 0';
							if (self.clippoint2)
								self.clippoint2.colormod = '0 0 0';
						}
					}
				}
				navcurrent.colormod = '0.25 0.25 1';
				BeamBox(BT_LIGHTNING, navcurrent.origin + navcurrent.mins, navcurrent.origin + navcurrent.maxs);
				e = navcurrent.plane_chain;
				if (e)
				{
					if (self.current_plane == e)
						e.skin = 3;
					else
						e.skin = 1;
					e.effects = EF_NODEPTHTEST | EF_ADDITIVE | EF_FULLBRIGHT;
					e = e.plane_next;
					while (e != navcurrent.plane_chain)
					{
						if (self.current_plane == e)
							e.skin = 3;
						else
							e.skin = 1;
						e.effects = EF_NODEPTHTEST | EF_ADDITIVE | EF_FULLBRIGHT;
						e = e.plane_next;
					}
				}
				if (navother != navcurrent)
				{
					navother.colormod = '1 0 0';
					BeamBox(BT_BEAM, navother.origin + navother.mins, navother.origin + navother.maxs);
				}
			}
			else
			{
				navcurrent.colormod = '1 0 0';
				BeamBox(BT_BEAM, navcurrent.origin + navcurrent.mins, navcurrent.origin + navcurrent.maxs);
				e = navcurrent.plane_chain;
				if (e)
				{
					if (self.current_plane == e)
						e.skin = 2;
					else
						e.skin = 0;
					e.effects = EF_NODEPTHTEST | EF_ADDITIVE | EF_FULLBRIGHT;
					e = e.plane_next;
					while (e != navcurrent.plane_chain)
					{
						if (self.current_plane == e)
							e.skin = 2;
						else
							e.skin = 0;
						e.effects = EF_NODEPTHTEST | EF_ADDITIVE | EF_FULLBRIGHT;
						e = e.plane_next;
					}
				}
			}
			e = navcurrent.plane_chain;
			if (e)
			{
				if (e.mangle_x < 0)
					tvec_x = self.origin_x + self.mins_x;
				else
					tvec_x = self.origin_x + self.maxs_x;
				if (e.mangle_y < 0)
					tvec_y = self.origin_y + self.mins_y;
				else
					tvec_y = self.origin_y + self.maxs_y;
				if (e.mangle_z < 0)
					tvec_z = self.origin_z + self.mins_z;
				else
					tvec_z = self.origin_z + self.maxs_z;
				f = (tvec * e.mangle) - ((navcurrent.origin + (e.delay * e.mangle)) * e.mangle);
				if (f > 0)
					intonav = intonav + e.mangle*-1;
				e = e.plane_next;
				while (e != navcurrent.plane_chain)
				{
					if (e.mangle_x < 0)
						tvec_x = self.origin_x + self.mins_x;
					else
						tvec_x = self.origin_x + self.maxs_x;
					if (e.mangle_y < 0)
						tvec_y = self.origin_y + self.mins_y;
					else
						tvec_y = self.origin_y + self.maxs_y;
					if (e.mangle_z < 0)
						tvec_z = self.origin_z + self.mins_z;
					else
						tvec_z = self.origin_z + self.maxs_z;
					f = (tvec * e.mangle) - ((navcurrent.origin + (e.delay * e.mangle)) * e.mangle);
					if (f > 0)
						intonav = intonav + e.mangle*-1;
					e = e.plane_next;
				}
			}
			intonav = normalize(intonav);
			// te_lightning1(self, self.origin, self.origin + intonav*200);
			if (navcurrent.link0)
			{
				navcurrent.link0.effects = EF_NODEPTHTEST;
				navcurrent.link0.frame = 0;
				if (navcurrent.lflags0 & LF_REMOTE)
					navcurrent.link0.frame = navcurrent.link0.frame + 21;
				if (navcurrent.link1)
				{
					navcurrent.link1.effects = EF_NODEPTHTEST;
					navcurrent.link1.frame = 1;
					if (navcurrent.lflags1 & LF_REMOTE)
						navcurrent.link1.frame = navcurrent.link1.frame + 21;
					if (navcurrent.link2)
					{
						navcurrent.link2.effects = EF_NODEPTHTEST;
						navcurrent.link2.frame = 2;
						if (navcurrent.lflags2 & LF_REMOTE)
							navcurrent.link2.frame = navcurrent.link2.frame + 21;
						if (navcurrent.link3)
						{
							navcurrent.link3.effects = EF_NODEPTHTEST;
							navcurrent.link3.frame = 3;
							if (navcurrent.lflags3 & LF_REMOTE)
								navcurrent.link3.frame = navcurrent.link3.frame + 21;
							if (navcurrent.link4)
							{
								navcurrent.link4.effects = EF_NODEPTHTEST;
								navcurrent.link4.frame = 4;
								if (navcurrent.lflags4 & LF_REMOTE)
									navcurrent.link4.frame = navcurrent.link4.frame + 21;
								if (navcurrent.link5)
								{
									navcurrent.link5.effects = EF_NODEPTHTEST;
									navcurrent.link5.frame = 5;
									if (navcurrent.lflags5 & LF_REMOTE)
										navcurrent.link5.frame = navcurrent.link5.frame + 21;
									if (navcurrent.link6)
									{
										navcurrent.link6.effects = EF_NODEPTHTEST;
										navcurrent.link6.frame = 6;
										if (navcurrent.lflags6 & LF_REMOTE)
											navcurrent.link6.frame = navcurrent.link6.frame + 21;
										if (navcurrent.link7)
										{
											navcurrent.link7.effects = EF_NODEPTHTEST;
											navcurrent.link7.frame = 7;
											if (navcurrent.lflags7 & LF_REMOTE)
												navcurrent.link7.frame = navcurrent.link7.frame + 21;
											if (navcurrent.link8)
											{
												navcurrent.link8.effects = EF_NODEPTHTEST;
												navcurrent.link8.frame = 8;
												if (navcurrent.lflags8 & LF_REMOTE)
													navcurrent.link8.frame = navcurrent.link8.frame + 21;
												if (navcurrent.link9)
												{
													navcurrent.link9.effects = EF_NODEPTHTEST;
													navcurrent.link9.frame = 9;
													if (navcurrent.lflags9 & LF_REMOTE)
														navcurrent.link9.frame = navcurrent.link9.frame + 21;
													if (navcurrent.link10)
													{
														navcurrent.link10.effects = EF_NODEPTHTEST;
														navcurrent.link10.frame = 10;
														if (navcurrent.lflags10 & LF_REMOTE)
															navcurrent.link10.frame = navcurrent.link10.frame + 21;
														if (navcurrent.link11)
														{
															navcurrent.link11.effects = EF_NODEPTHTEST;
															navcurrent.link11.frame = 11;
															if (navcurrent.lflags11 & LF_REMOTE)
																navcurrent.link11.frame = navcurrent.link11.frame + 21;
															if (navcurrent.link12)
															{
																navcurrent.link12.effects = EF_NODEPTHTEST;
																navcurrent.link12.frame = 12;
																if (navcurrent.lflags12 & LF_REMOTE)
																	navcurrent.link12.frame = navcurrent.link12.frame + 21;
																if (navcurrent.link13)
																{
																	navcurrent.link13.effects = EF_NODEPTHTEST;
																	navcurrent.link13.frame = 13;
																	if (navcurrent.lflags13 & LF_REMOTE)
																		navcurrent.link13.frame = navcurrent.link13.frame + 21;
																	if (navcurrent.link14)
																	{
																		navcurrent.link14.effects = EF_NODEPTHTEST;
																		navcurrent.link14.frame = 14;
																		if (navcurrent.lflags14 & LF_REMOTE)
																			navcurrent.link14.frame = navcurrent.link14.frame + 21;
																		if (navcurrent.link15)
																		{
																			navcurrent.link15.effects = EF_NODEPTHTEST;
																			navcurrent.link15.frame = 15;
																			if (navcurrent.lflags15 & LF_REMOTE)
																				navcurrent.link15.frame = navcurrent.link15.frame + 21;
																			if (navcurrent.link16)
																			{
																				navcurrent.link16.effects = EF_NODEPTHTEST;
																				navcurrent.link16.frame = 16;
																				if (navcurrent.lflags16 & LF_REMOTE)
																					navcurrent.link16.frame = navcurrent.link16.frame + 21;
																				if (navcurrent.link17)
																				{
																					navcurrent.link17.effects = EF_NODEPTHTEST;
																					navcurrent.link17.frame = 17;
																					if (navcurrent.lflags17 & LF_REMOTE)
																						navcurrent.link17.frame = navcurrent.link17.frame + 21;
																					if (navcurrent.link18)
																					{
																						navcurrent.link18.effects = EF_NODEPTHTEST;
																						navcurrent.link18.frame = 18;
																						if (navcurrent.lflags18 & LF_REMOTE)
																							navcurrent.link18.frame = navcurrent.link18.frame + 21;
																						if (navcurrent.link19)
																						{
																							navcurrent.link19.effects = EF_NODEPTHTEST;
																							navcurrent.link19.frame = 19;
																							if (navcurrent.lflags19 & LF_REMOTE)
																								navcurrent.link19.frame = navcurrent.link19.frame + 21;
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
				}
			}
		}
	}	
};

void() PlayerPostThink =
{
	MainMenu();

	if (self.impulse)
		ImpulseCommands(self.impulse);
	self.impulse = 0;
};

void() NavOrgThink =
{
	self.nextthink = time + 0.1;

	setorigin(self, self.owner.current_navnode.origin);
};

void() PutClientInServer =
{
	local entity spawn_spot;

	spawn_spot = find (world, classname, "info_player_start");
	if (!spawn_spot)
		spawn_spot = find (world, classname, "info_player_deathmatch");

	self.classname = "player";
	self.health = 100;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_FLY;
	self.flags = FL_CLIENT;
	self.nextthink = time;
	self.think = SUB_Null;

	setorigin(self, spawn_spot.origin);
	self.angles = spawn_spot.angles;
	self.fixangle = TRUE;

	// setmodel (self, "progs/bbox.mdl");
	setmodel (self, "progs/null.spr");
	// setsize (self, '-16 -16 -28', '16 16 28');
	setsize (self, '0 0 0', '0 0 0');
	self.gridsize = 8;

	self.navorg1 = spawn();
	setmodel(self.navorg1, "progs/org.mdl");
	setsize(self.navorg1, '0 0 0', '0 0 0');
	self.navorg1.effects = EF_FULLBRIGHT;
	self.navorg1.owner = self;
	self.navorg1.think = NavOrgThink;
	self.navorg1.nextthink = time;
	self.navorg2 = spawn();
	setmodel(self.navorg2, "progs/org2.mdl");
	setsize(self.navorg2, '0 0 0', '0 0 0');
	self.navorg2.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	self.navorg2.owner = self;
	self.navorg2.think = NavOrgThink;
	self.navorg2.nextthink = time;
};

void() SV_PlayerPhysics =
{
	local   vector  wishvel, wishdir;
	local   float   wishspeed, f;

	if (self.movetype == MOVETYPE_NONE)
		return;

	if (self.punchangle != '0 0 0')
		self.punchangle = self.punchangle * (1 - frametime * 3);

	if (self.punchvector != '0 0 0')
		self.punchvector = self.punchvector * (1 - frametime * 3);

	if (vlen(self.movement))
	{
		makevectors(self.v_angle);
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
	}
	else
		self.velocity = '0 0 0';
};