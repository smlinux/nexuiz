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
void(entity e, vector v) printsurfaceinfo =
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
		{
			if (self.weapon != WEP_LASER
				&& !cvar("g_minstagib") && !cvar("g_instagib")
				&& !cvar("g_rocketarena") && !cvar("g_lms") && cvar("g_pickup_items") && !cvar("g_nixnex"))
				W_ThrowWeapon(W_CalculateProjectileVelocity(self.velocity, v_forward * 750), '0 0 0', TRUE);
		}
	}
	// deploy waypoints
	else if (imp >= 30 && imp <= 49)
	{
		if(imp == 30)
		{
			WaypointSprite_DeployPersonal("waypoint", self.origin);
			sprint(self, "personal waypoint spawned at location\n");
		}
		else if(imp == 31)
		{
			WaypointSprite_DeployPersonal("waypoint", self.cursor_trace_endpos);
			sprint(self, "personal waypoint spawned at crosshair\n");
		}
		else if(imp == 32 && vlen(self.death_origin))
		{
			WaypointSprite_DeployPersonal("waypoint", self.death_origin);
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
				if(imp == 99)
				{
					self.items |= (IT_LASER | IT_UZI | IT_SHOTGUN | IT_GRENADE_LAUNCHER | IT_ELECTRO | IT_CRYLINK | IT_NEX | IT_HAGAR | IT_ROCKET_LAUNCHER);
					self.ammo_shells = cvar("g_pickup_shells_max");
					self.ammo_nails = cvar("g_pickup_nails_max");
					self.ammo_rockets = cvar("g_pickup_rockets_max");
					self.ammo_cells = cvar("g_pickup_cells_max");
					self.health = cvar("g_pickup_healthshard_max");
					self.armorvalue = cvar("g_pickup_armorshard_max");
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
					self.velocity = self.velocity - v_forward * 300;
				}
				else if (imp == 14)
					CopyBody(0);
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

	//TetrisImpulses();
}
