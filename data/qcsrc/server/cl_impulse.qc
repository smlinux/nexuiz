.vector personal_v_angle; // view angles to restore on impulse 77
.vector personal_velocity; // velocity to restore on impulse 77

void CopyBody(float keepvelocity);

// changes by LordHavoc on 03/30/04
// cleaned up dummy code
// dummies are now removed eventually after being gibbed (norespawn = TRUE)
// dummy impulse now checks sv_cheats to prevent players from overwhelming server with dummies
// dummies now use player code where possible

void player_anim (void);
void DummyThink(void)
{
	self.think = DummyThink;
	self.nextthink = time;
	SV_PlayerPhysics();
	PlayerPreThink();
	//player_anim();
	PlayerPostThink();
}

// from dpmod
void printsurfaceinfo(entity e, vector v)
{
	local float surfnum, numpoints, vnum;
	local string s;
	local vector n;
	surfnum = getsurfacenearpoint(e, v);
	if (surfnum >= 0)
	{
		sprint(self, "texture: ");
		s = getsurfacetexture(e, surfnum);
		sprint(self, s);
		sprint(self, " normal: ");
		n = getsurfacenormal(e, surfnum);
		sprint(self, vtos(n));
		sprint(self, " ");
		numpoints = getsurfacenumpoints(e, surfnum);
		sprint(self, ftos(numpoints));
		sprint(self, " verts:");
		vnum = 0;
		while (vnum < numpoints)
		{
			sprint(self, " ");
			n = getsurfacepoint(e, surfnum, vnum);
			sprint(self, vtos(n));
			vnum = vnum + 1;
		}
		sprint(self, " point tested: ");
		sprint(self, vtos(v));
		sprint(self, " nearest point on surface: ");
		n = getsurfaceclippedpoint(e, surfnum, v);
		sprint(self, vtos(n));
		sprint(self, "\n");
	}
};

void ImpulseCommands (void)
{
	local float imp;
	imp = self.impulse;
	if (!imp || gameover)
		return;
	self.impulse = 0;

	if (timeoutStatus == 2) //don't allow any impulses while the game is paused
		return;

	if (imp >= 1 && imp <= 12)
	{
		// weapon switching impulses
		if(self.deadflag == DEAD_NO)
		{
			if (imp <= 9)
				W_SwitchWeapon (imp);
			else if (imp == 10)
				W_NextWeapon ();
			else if (imp == 12)
				W_PreviousWeapon ();
			else if (imp == 11) // last weapon
				W_SwitchWeapon (self.cnt);
		}
		else
			self.impulse = imp; // retry in next frame
	}
	// throw weapon
	else if (imp == 17)
	{
		if(self.deadflag == DEAD_NO)
		if (!g_minstagib)
			W_ThrowWeapon(W_CalculateProjectileVelocity(self.velocity, v_forward * 750), '0 0 0', TRUE);
	}
	// deploy waypoints
	else if (imp >= 30 && imp <= 49)
	{
		if(imp == 30)
		{
			WaypointSprite_DeployPersonal("waypoint", self.origin);
			self.personal_v_angle = self.v_angle;
			self.personal_velocity = self.velocity;
			sprint(self, "personal waypoint spawned at location\n");
		}
		else if(imp == 31)
		{
			WaypointSprite_DeployPersonal("waypoint", self.cursor_trace_endpos);
			self.personal_v_angle = self.v_angle;
			self.personal_velocity = '0 0 0';
			sprint(self, "personal waypoint spawned at crosshair\n");
		}
		else if(imp == 32 && vlen(self.death_origin))
		{
			WaypointSprite_DeployPersonal("waypoint", self.death_origin);
			self.personal_v_angle = self.v_angle;
			self.personal_velocity = '0 0 0';
			sprint(self, "personal waypoint spawned at death location\n");
		}
		else if(imp == 33 && self.deadflag == DEAD_NO && teams_matter)
		{
			WaypointSprite_Attach("helpme", TRUE);
			sprint(self, "HELP ME attached\n");
		}
		else if(imp == 34)
		{
			WaypointSprite_DeployFixed("here", FALSE, self.origin);
			sprint(self, "HERE spawned at location\n");
		}
		else if(imp == 35)
		{
			WaypointSprite_DeployFixed("here", FALSE, self.cursor_trace_endpos);
			sprint(self, "HERE spawned at crosshair\n");
		}
		else if(imp == 36 && vlen(self.death_origin))
		{
			WaypointSprite_DeployFixed("here", FALSE, self.death_origin);
			sprint(self, "HERE spawned at death location\n");
		}
		else if(imp == 37)
		{
			WaypointSprite_DeployFixed("danger", FALSE, self.origin);
			sprint(self, "DANGER spawned at location\n");
		}
		else if(imp == 38)
		{
			WaypointSprite_DeployFixed("danger", FALSE, self.cursor_trace_endpos);
			sprint(self, "DANGER spawned at crosshair\n");
		}
		else if(imp == 39 && vlen(self.death_origin))
		{
			WaypointSprite_DeployFixed("danger", FALSE, self.death_origin);
			sprint(self, "DANGER spawned at death location\n");
		}
		else if(imp == 47)
		{
			WaypointSprite_ClearPersonal();
			sprint(self, "personal waypoint cleared\n");
		}
		else if(imp == 48)
		{
			WaypointSprite_ClearOwned();
			sprint(self, "all waypoints cleared\n");
		}
		else if(imp == 49)
		{
			self.cvar_cl_hidewaypoints = !(self.cvar_cl_hidewaypoints);
			sprint(self, "fixed waypoints now ");
			if(self.cvar_cl_hidewaypoints)
				sprint(self, "OFF\n");
			else
				sprint(self, "ON\n");
		}
	}
	else
	{
		if (sv_cheats)
		{
			if(imp == 19)
			{
				makevectors(self.v_angle);
				traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * MAX_SHOT_DISTANCE, FALSE, self);
				if (trace_fraction < 1)
					printsurfaceinfo(trace_ent, trace_endpos);
			}
			else if(imp == 20)
			{
				makevectors(self.v_angle);
				traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 65536, FALSE, self);
				sprint(self, strcat("distance: ", ftos(fabs(vlen(trace_endpos - (self.origin + self.view_ofs)))), "\n"));
			}
			else if(self.deadflag == DEAD_NO)
			{
				if(imp == 77)
				{
					if(self.waypointsprite_deployed_personal)
					{
						self.speedrunning = TRUE;
						tracebox(self.waypointsprite_deployed_personal.origin, self.mins, self.maxs, self.waypointsprite_deployed_personal.origin, MOVE_WORLDONLY, self);
						if(trace_startsolid)
						{
							sprint(self, "Cannot move there, cheater - only waypoints set using g_waypointsprite_personal work\n");
						}
						else
						{
							// Abort speedrun, teleport back
							setorigin(self, self.waypointsprite_deployed_personal.origin);
							self.oldvelocity = self.velocity = self.personal_velocity;
							self.angles = self.personal_v_angle;
							self.fixangle = TRUE;
							if(self.flagcarried)
							{
								bprint("The ", self.flagcarried.netname, " was returned to base by its carrier\n");
								ReturnFlag(self.flagcarried);
							}
						}
						self.ammo_rockets = 999;
						self.ammo_nails = 999;
						self.ammo_cells = 999;
						self.ammo_shells = 999;
						self.health = start_health;
						self.armorvalue = start_armorvalue;
						self.items |= itemsInMap & (IT_LASER | IT_SHOTGUN | IT_UZI | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER);
						self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
						self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
						self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
					}
					else
						sprint(self, "No waypoint set, cheater (use g_waypointsprite_personal to set one)\n");
				}
				else if(imp == 99)
				{
					self.items |= (IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER);
					self.ammo_shells = g_pickup_shells_max;
					self.ammo_nails = g_pickup_nails_max;
					self.ammo_rockets = g_pickup_rockets_max;
					self.ammo_cells = g_pickup_cells_max;
					self.health = g_pickup_healthsmall_max;
					self.armorvalue = g_pickup_armorsmall_max;
					self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
					self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
					self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
					// precache weapon models/sounds
					local float wep;
					wep = WEP_FIRST;
					while (wep <= WEP_LAST)
					{
						weapon_action(wep, WR_PRECACHE);
						wep = wep + 1;
					}
				}
				else if (imp == 13)
				{
					makevectors (self.v_angle);
					self.velocity = self.velocity + v_forward * 300;
					CopyBody(1);
					self.lip += 1;
					self.velocity = self.velocity - v_forward * 300;
				}
				else if (imp == 14)
				{
					CopyBody(0);
					self.lip += 1;
				}
				else if (imp == 143) // actually: impulse 911
				{
					vector start, end;
					float i;
					float m;
					float good, evil;
					vector org, delta;

					good = DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP;
					evil = DPCONTENTS_NODROP | DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER;

					m = self.dphitcontentsmask;
					self.dphitcontentsmask = good | evil;

					org = world.mins;
					delta = world.maxs - world.mins;

					for(i = 100; i > 0; --i)
					{
						start_x = org_x + random() * delta_x;
						start_y = org_y + random() * delta_y;
						start_z = org_z + random() * delta_z;

						// rule 1: start inside world bounds, and outside
						// solid, and don't start from somewhere where you can
						// fall down to evil
						tracebox(start, self.mins, self.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;
						if(trace_startsolid)
							continue;
						dprint("hit contents ", ftos(trace_dphitcontents), "\n");
						if(trace_dphitcontents & evil)
							continue;

						// rule 2: if we are too high, lower the point
						if(trace_fraction * delta_z > 1024)
							start = trace_endpos + '0 0 1024';

						// these can be traceLINES as we already verified the starting box
						traceline(start, start + '1 0 0' * delta_x, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;
						traceline(start, start - '1 0 0' * delta_x, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;
						traceline(start, start + '0 1 0' * delta_y, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;
						traceline(start, start - '0 1 0' * delta_y, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;
						traceline(start, start + '0 0 1' * delta_z, MOVE_NORMAL, self);
						if(trace_fraction >= 1)
							continue;

						end_x = org_x + random() * delta_x;
						end_y = org_y + random() * delta_y;
						end_z = org_z + random() * delta_z;
						end = start + normalize(end - start) * 256;

						// rule 3: start TO end must not be too short
						tracebox(start, self.mins, self.maxs, end, MOVE_NORMAL, self);
						if(trace_startsolid)
							continue;
						if(trace_fraction < 1)
							continue;

						break;
					}

					if(i)
					{
						self.origin = start;
						self.angles = vectoangles(end - start);
						self.angles_x = -self.angles_x;
						self.fixangle = TRUE;
						self.velocity = '0 0 0';
						dprint("Needed ", ftos(101 - i), " attempts\n");
					}
					else
						sprint(self, "Emergency teleport could not find a good location, forget it!\n");

					self.dphitcontentsmask = m;
				}
			}
		}
	}

	if (cvar("g_waypointeditor"))
	{
		local entity e;
		if (imp == 103) waypoint_schedulerelink(waypoint_spawn(self.origin, self.origin, 0));
		else if (imp == 104) {e = navigation_findnearestwaypoint(self, FALSE);if (e) waypoint_remove(e);}
		else if (imp == 105) waypoint_schedulerelinkall();
		else if (imp == 106) waypoint_saveall();
	}

	//TetrisImpulses(imp);
}
