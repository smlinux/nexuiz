float(vector smins, vector smaxs, vector bmins, vector bmaxs) boxenclosed = {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;};

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

float(entity node) CheckNode =
{
	local float f, result;
	local vector tvec;
	local entity plane;

	if (boxenclosed(self.origin + self.mins, self.origin + self.maxs, node.origin + node.mins, node.origin + node.maxs))
	{
		result = TRUE;
		plane = node.plane_chain;
		while (plane)
		{
			tvec = self.maxs;
			if (plane.mangle_x < 0)
				tvec_x = self.mins_x;
			if (plane.mangle_y < 0)
				tvec_y = self.mins_y;
			if (plane.mangle_z < 0)
				tvec_z = self.mins_z;
			tvec += self.origin;
			f = tvec*plane.mangle - node.origin*plane.mangle-plane.delay;
			if (f > 0)
				result = FALSE;
			plane = plane.list;
		}
	}
	return result;
};

float(entity currentnode, entity goalnode, float flight) AdvancedTraceWalk =
{
	local float f, t, bump;
	local float result;
	local float stepdist, fulldist, totaldist;
	local vector goalpoint, oldorg, move;
	local entity oldself;

	oldself = self;
	stepdist = cvar("navnodeedit_tracewalk_stepdist");
	fulldist = cvar("navnodeedit_tracewalk_fulldist");
	result = FALSE;
	self = spawn();
	setsize(self, '-16 -16 -24', '16 16 45');
	tracebox(self.origin, self.mins, self.maxs, currentnode.origin + '0 0 -65536', TRUE, self);
	setorigin(self, trace_endpos);
	setsize(self, '-18 -18 -26', '18 18 47');
	goalpoint = ClampPointToSpace(self.origin, currentnode, goalnode);
	setsize(self, '-16 -16 -24', '16 16 45');
	while(vlen(self.origin - oldorg) > 2 && totaldist < fulldist)
	{
		oldorg = self.origin;
		if (!flight)
			tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 18', TRUE, self);
		setorigin(self, trace_endpos);
		move = self.origin - goalpoint;
		if (!flight)
			move_z = 0;
		f = vlen(self.origin - goalpoint);
		f = min(f, stepdist);
		self.velocity = normalize(move)*f;
		if (!flight)
			self.velocity_z = -800;
		t = 1;
		bump = 0;
		while (bump < 16)
		{
			bump = bump + 1;
			tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * t, TRUE, self);
			if (trace_fraction == 1)
			{
				setorigin(self, trace_endpos);
				break;
			}
			if (self.velocity * trace_plane_normal < 0)
				self.velocity = self.velocity - (trace_plane_normal * (trace_plane_normal * self.velocity));
			if (trace_fraction >= 0.0001)
			{
				t = t * (1 - trace_fraction);
				setorigin(self, trace_endpos);
			}
		}
		if (!flight)
		{
			tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 -65536', TRUE, self);
			setorigin(self, trace_endpos);
		}
		if (CheckNode(goalnode))
		{
			result = TRUE;
			break;
		}
		totaldist = totaldist + vlen(self.origin - oldorg);
	}
	self = oldself;
	return result;
};

void() FlaggerThink =
{
	local entity e;

	self.nextthink = time;
	if (dasnode)
	{
		if (!AdvancedTraceWalk(dasnode, dasnode.link0, FALSE))
		{
			dasnode.lflags0 = LF_NOWALK;
			if (!AdvancedTraceWalk(dasnode, dasnode.link0, TRUE))
				dasnode.lflags0 = LF_NOLINK;
		}
		if (dasnode.link1)
		{
			if (!AdvancedTraceWalk(dasnode, dasnode.link1, FALSE))
			{
				dasnode.lflags1 = LF_NOWALK;
				if (!AdvancedTraceWalk(dasnode, dasnode.link1, TRUE))
					dasnode.lflags1 = LF_NOLINK;
			}
			if (dasnode.link2)
			{
				if (!AdvancedTraceWalk(dasnode, dasnode.link2, FALSE))
				{
					dasnode.lflags2 = LF_NOWALK;
					if (!AdvancedTraceWalk(dasnode, dasnode.link2, TRUE))
						dasnode.lflags2 = LF_NOLINK;
				}
				if (dasnode.link3)
				{
					if (!AdvancedTraceWalk(dasnode, dasnode.link3, FALSE))
					{
						dasnode.lflags3 = LF_NOWALK;
						if (!AdvancedTraceWalk(dasnode, dasnode.link3, TRUE))
							dasnode.lflags3 = LF_NOLINK;
					}
					if (dasnode.link4)
					{
						if (!AdvancedTraceWalk(dasnode, dasnode.link4, FALSE))
						{
							dasnode.lflags4 = LF_NOWALK;
							if (!AdvancedTraceWalk(dasnode, dasnode.link4, TRUE))
								dasnode.lflags4 = LF_NOLINK;
						}
						if (dasnode.link5)
						{
							if (!AdvancedTraceWalk(dasnode, dasnode.link5, FALSE))
							{
								dasnode.lflags5 = LF_NOWALK;
								if (!AdvancedTraceWalk(dasnode, dasnode.link5, TRUE))
									dasnode.lflags5 = LF_NOLINK;
							}
							if (dasnode.link6)
							{
								if (!AdvancedTraceWalk(dasnode, dasnode.link6, FALSE))
								{
									dasnode.lflags6 = LF_NOWALK;
									if (!AdvancedTraceWalk(dasnode, dasnode.link6, TRUE))
										dasnode.lflags6 = LF_NOLINK;
								}
								if (dasnode.link7)
								{
									if (!AdvancedTraceWalk(dasnode, dasnode.link7, FALSE))
									{
										dasnode.lflags7 = LF_NOWALK;
										if (!AdvancedTraceWalk(dasnode, dasnode.link7, TRUE))
											dasnode.lflags7 = LF_NOLINK;
									}
									if (dasnode.link8)
									{
										if (!AdvancedTraceWalk(dasnode, dasnode.link8, FALSE))
										{
											dasnode.lflags8 = LF_NOWALK;
											if (!AdvancedTraceWalk(dasnode, dasnode.link8, TRUE))
												dasnode.lflags8 = LF_NOLINK;
										}
										if (dasnode.link9)
										{
											if (!AdvancedTraceWalk(dasnode, dasnode.link9, FALSE))
											{
												dasnode.lflags9 = LF_NOWALK;
												if (!AdvancedTraceWalk(dasnode, dasnode.link9, TRUE))
													dasnode.lflags9 = LF_NOLINK;
											}
											if (dasnode.link10)
											{
												if (!AdvancedTraceWalk(dasnode, dasnode.link10, FALSE))
												{
													dasnode.lflags10 = LF_NOWALK;
													if (!AdvancedTraceWalk(dasnode, dasnode.link10, TRUE))
														dasnode.lflags10 = LF_NOLINK;
												}
												if (dasnode.link11)
												{
													if (!AdvancedTraceWalk(dasnode, dasnode.link11, FALSE))
													{
														dasnode.lflags11 = LF_NOWALK;
														if (!AdvancedTraceWalk(dasnode, dasnode.link11, TRUE))
															dasnode.lflags11 = LF_NOLINK;
													}
													if (dasnode.link12)
													{
														if (!AdvancedTraceWalk(dasnode, dasnode.link12, FALSE))
														{
															dasnode.lflags12 = LF_NOWALK;
															if (!AdvancedTraceWalk(dasnode, dasnode.link12, TRUE))
																dasnode.lflags12 = LF_NOLINK;
														}
														if (dasnode.link13)
														{
															if (!AdvancedTraceWalk(dasnode, dasnode.link13, FALSE))
															{
																dasnode.lflags13 = LF_NOWALK;
																if (!AdvancedTraceWalk(dasnode, dasnode.link13, TRUE))
																	dasnode.lflags13 = LF_NOLINK;
															}
															if (dasnode.link14)
															{
																if (!AdvancedTraceWalk(dasnode, dasnode.link14, FALSE))
																{
																	dasnode.lflags14 = LF_NOWALK;
																	if (!AdvancedTraceWalk(dasnode, dasnode.link14, TRUE))
																		dasnode.lflags14 = LF_NOLINK;
																}
																if (dasnode.link15)
																{
																	if (!AdvancedTraceWalk(dasnode, dasnode.link15, FALSE))
																	{
																		dasnode.lflags15 = LF_NOWALK;
																		if (!AdvancedTraceWalk(dasnode, dasnode.link15, TRUE))
																			dasnode.lflags15 = LF_NOLINK;
																	}
																	if (dasnode.link16)
																	{
																		if (!AdvancedTraceWalk(dasnode, dasnode.link16, FALSE))
																		{
																			dasnode.lflags16 = LF_NOWALK;
																			if (!AdvancedTraceWalk(dasnode, dasnode.link16, TRUE))
																				dasnode.lflags16 = LF_NOLINK;
																		}
																		if (dasnode.link17)
																		{
																			if (!AdvancedTraceWalk(dasnode, dasnode.link17, FALSE))
																			{
																				dasnode.lflags17 = LF_NOWALK;
																				if (!AdvancedTraceWalk(dasnode, dasnode.link17, TRUE))
																					dasnode.lflags17 = LF_NOLINK;
																			}
																			if (dasnode.link18)
																			{
																				if (!AdvancedTraceWalk(dasnode, dasnode.link18, FALSE))
																				{
																					dasnode.lflags18 = LF_NOWALK;
																					if (!AdvancedTraceWalk(dasnode, dasnode.link18, TRUE))
																						dasnode.lflags18 = LF_NOLINK;
																				}
																				if (dasnode.link19)
																				{
																					if (!AdvancedTraceWalk(dasnode, dasnode.link19, FALSE))
																					{
																						dasnode.lflags19 = LF_NOWALK;
																						if (!AdvancedTraceWalk(dasnode, dasnode.link19, TRUE))
																							dasnode.lflags19 = LF_NOLINK;
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
		dasnode = dasnode.list;
	}
	else
	{
		self.think = SUB_Remove;
		e = findchainflags(flags, FL_CLIENT);
		while (e)
		{
			e.confirm = 0;
			e = e.chain;		
		}
	}
};

void() AutoFlagger =
{
	local entity e;

	dasnode = navnode_chain;
	e = spawn();
	e.think = FlaggerThink;
	e.nextthink = time;
};