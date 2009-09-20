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

/*
 * Impulse map:
 *
 * 0 reserved (no input)
 * 1 to 9, 14: weapon shortcuts
 * 10: next weapon according to linear list
 * 11: most recently used weapon
 * 12: previous weapon according to linear list
 * 13: best weapon according to priority list
 * 15: next weapon according to priority list
 * 16: previous weapon according to priority list
 * 17: throw weapon
 * 18: next weapon according to sbar_hudselector 1 list
 * 19: previous weapon according to sbar_hudselector 1 list
 * 20: reload if needed
 *
 * 30 to 39: create waypoints
 * 47: clear personal waypoints
 * 48: clear team waypoints
 *
 * 99: loaded
 *
 * 140: moving clone
 * 141: ctf speedrun
 * 142: fixed clone
 * 143: emergency teleport
 * 144: printsurfaceinfo
 * 145: distance
 * 148: unfairly eliminate
 *
 * TODO:
 * 200 to 209: prev weapon shortcuts
 * 210 to 219: best weapon shortcuts
 * 220 to 229: next weapon shortcuts
 * 230 to 253: individual weapons (up to 24)
 */

void ImpulseCommands (void)
{
	local float imp;
	vector org;
	float i;
	float m;
	float wep;
	entity e, e2;

	imp = self.impulse;
	if (!imp || gameover)
		return;
	self.impulse = 0;

	if (timeoutStatus == 2) //don't allow any impulses while the game is paused
		return;

	if (imp >= 1 && imp <= 9)
	{
		// weapon switching impulses
		if(self.deadflag == DEAD_NO)
			W_NextWeaponOnImpulse(imp);
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp >= 10 && imp <= 20)
	{
		if(self.deadflag == DEAD_NO)
		{
			switch(imp)
			{
				case 10:
					W_NextWeapon (0);
					break;
				case 11:
					W_SwitchWeapon (self.cnt); // previously used
					break;
				case 12:
					W_PreviousWeapon (0);
					break;
				case 13:
					W_SwitchWeapon (w_getbestweapon(self));
					break;
				case 14:
					W_NextWeaponOnImpulse(0);
					break;
				case 15:
					W_NextWeapon (2);
					break;
				case 16:
					W_PreviousWeapon (2);
					break;
				case 17:
					if (!g_minstagib)
						W_ThrowWeapon(W_CalculateProjectileVelocity(self.velocity, v_forward * 750), '0 0 0', TRUE);
					break;
				case 18:
					W_NextWeapon (1);
					break;
				case 19:
					W_PreviousWeapon (1);
					break;
				case 20:
					W_Reload ();
					break;
			}
		}
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp >= 200 && imp <= 229)
	{
		if(self.deadflag == DEAD_NO)
		{
			// custom order weapon cycling
			i = mod(imp, 10);
			m = (imp - (210 + i)); // <0 for prev, =0 for best, >0 for next
			W_CycleWeapon(self.(cvar_cl_weaponpriorities[i]), m);
		}
		else
			self.impulse = imp; // retry in next frame
	}
	else if(imp >= 230 && imp <= 253)
	{
		if(self.deadflag == DEAD_NO)
			W_SwitchWeapon (imp - 230 + WEP_FIRST);
		else
			self.impulse = imp; // retry in next frame
	}
	// deploy waypoints
	else if (imp >= 30 && imp <= 49)
	{
		entity wp;
		switch(imp)
		{
			case 30:
				wp = WaypointSprite_DeployPersonal("waypoint", self.origin);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_WAYPOINT, '0 1 1');
					WaypointSprite_Ping(wp);
				}
				if(sv_cheats)
				{
					if(!self.personal)
					{
						self.personal = spawn();
						self.personal.classname = "personal_wp";
					}
					self.personal.origin = self.origin;
					self.personal.v_angle = self.v_angle;
					self.personal.velocity = self.velocity;
					self.personal.ammo_rockets = self.ammo_rockets;
					self.personal.ammo_nails = self.ammo_nails;
					self.personal.ammo_cells = self.ammo_cells;
					self.personal.ammo_shells = self.ammo_shells;
					self.personal.ammo_fuel = self.ammo_fuel;
					self.personal.health = self.health;
					self.personal.armorvalue = self.armorvalue;
					self.personal.weapons = self.weapons;
					self.personal.items = self.items;
					self.personal.pauserotarmor_finished = self.pauserotarmor_finished;
					self.personal.pauserothealth_finished = self.pauserothealth_finished;
					self.personal.pauserotfuel_finished = self.pauserotfuel_finished;
					self.personal.pauseregen_finished = self.pauseregen_finished;
					self.personal.strength_finished = self.strength_finished;
					self.personal.invincible_finished = self.invincible_finished;
					self.personal.teleport_time = time;
				}
				sprint(self, "personal waypoint spawned at location\n");
				break;
			case 31:
				wp = WaypointSprite_DeployPersonal("waypoint", self.cursor_trace_endpos);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_WAYPOINT, '0 1 1');
					WaypointSprite_Ping(wp);
				}
				sprint(self, "personal waypoint spawned at crosshair\n");
				break;
			case 32:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployPersonal("waypoint", self.death_origin);
					if(wp)
					{
						WaypointSprite_UpdateTeamRadar(wp, RADARICON_WAYPOINT, '0 1 1');
						WaypointSprite_Ping(wp);
					}
					sprint(self, "personal waypoint spawned at death location\n");
				}
				break;
			case 33:
				if(self.deadflag == DEAD_NO && teams_matter)
				{
					wp = WaypointSprite_Attach("helpme", TRUE);
					if(wp)
						WaypointSprite_UpdateTeamRadar(wp, RADARICON_HELPME, '1 0.5 0'); // TODO choose better color
					if(!wp)
						wp = self.waypointsprite_attachedforcarrier; // flag sprite?
					if(wp)
						WaypointSprite_Ping(wp);
					sprint(self, "HELP ME attached\n");
				}
				break;
			case 34:
				wp = WaypointSprite_DeployFixed("here", FALSE, self.origin);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_HERE, '0 1 0');
					WaypointSprite_Ping(wp);
				}
				sprint(self, "HERE spawned at location\n");
				break;
			case 35:
				wp = WaypointSprite_DeployFixed("here", FALSE, self.cursor_trace_endpos);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_HERE, '0 1 0');
					WaypointSprite_Ping(wp);
				}
				sprint(self, "HERE spawned at crosshair\n");
				break;
			case 36:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployFixed("here", FALSE, self.death_origin);
					if(wp)
					{
						WaypointSprite_UpdateTeamRadar(wp, RADARICON_HERE, '0 1 0');
						WaypointSprite_Ping(wp);
					}
					sprint(self, "HERE spawned at death location\n");
				}
				break;
			case 37:
				wp = WaypointSprite_DeployFixed("danger", FALSE, self.origin);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_DANGER, '1 0.5 0');
					WaypointSprite_Ping(wp);
				}
				sprint(self, "DANGER spawned at location\n");
				break;
			case 38:
				wp = WaypointSprite_DeployFixed("danger", FALSE, self.cursor_trace_endpos);
				if(wp)
				{
					WaypointSprite_UpdateTeamRadar(wp, RADARICON_DANGER, '1 0.5 0');
					WaypointSprite_Ping(wp);
				}
				sprint(self, "DANGER spawned at crosshair\n");
				break;
			case 39:
				if(vlen(self.death_origin))
				{
					wp = WaypointSprite_DeployFixed("danger", FALSE, self.death_origin);
					if(wp)
					{
						WaypointSprite_UpdateTeamRadar(wp, RADARICON_DANGER, '1 0.5 0');
						WaypointSprite_Ping(wp);
					}
					sprint(self, "DANGER spawned at death location\n");
				}
				break;
			case 47:
				WaypointSprite_ClearPersonal();
				sprint(self, "personal waypoint cleared\n");
				break;
			case 48:
				WaypointSprite_ClearOwned();
				sprint(self, "all waypoints cleared\n");
				break;
		}
	}
	else if(imp >= 140 && imp <= 149 || imp == 99) // 10 cheats ought to be enough for anyone
	{
		if(self.deadflag == DEAD_NO)
		{
			if(sv_cheats || self.maycheat || (self.lip < sv_clones))
			{
				switch(imp)
				{
					 case 140:
						makevectors (self.v_angle);
						self.velocity = self.velocity + v_forward * 300;
						CopyBody(1);
						self.lip += 1;
						self.velocity = self.velocity - v_forward * 300;
						break;
					case 142:
						CopyBody(0);
						self.lip += 1;
						break;
				 }
			}

			if(sv_cheats || self.maycheat)
			{
				switch(imp)
				{
					case 99:
						self.weapons |= WEPBIT_ALL;
						self.items |= IT_UNLIMITED_AMMO;
						self.ammo_shells = g_pickup_shells_max;
						self.ammo_nails = g_pickup_nails_max;
						self.ammo_rockets = g_pickup_rockets_max;
						self.ammo_cells = g_pickup_cells_max;
						self.ammo_fuel = g_pickup_fuel_max;
						self.health = g_pickup_healthsmall_max;
						self.armorvalue = g_pickup_armorsmall_max;
						self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
						self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
						self.pauserotfuel_finished = time + cvar("g_balance_pause_fuel_rot_spawn");
						self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
						// precache weapon models/sounds
						wep = WEP_FIRST;
						while (wep <= WEP_LAST)
						{
							weapon_action(wep, WR_PRECACHE);
							wep = wep + 1;
						}
						break;
					case 141:
						if(self.personal)
						{
							self.speedrunning = TRUE;
							tracebox(self.personal.origin, self.mins, self.maxs, self.personal.origin, MOVE_WORLDONLY, self);
							if(trace_startsolid)
							{
								sprint(self, "Cannot move there, cheater - only waypoints set using g_waypointsprite_personal work\n");
							}
							else
							{
								// Abort speedrun, teleport back
								setorigin(self, self.personal.origin);
								self.oldvelocity = self.velocity = self.personal.velocity;
								self.angles = self.personal.v_angle;
								self.fixangle = TRUE;
								if(self.flagcarried)
								{
									bprint("The ", self.flagcarried.netname, " was returned to base by its carrier\n");
									ReturnFlag(self.flagcarried);
								}
							}
							if(g_ctf)
							{
								self.ammo_rockets = 999;
								self.ammo_nails = 999;
								self.ammo_cells = 999;
								self.ammo_shells = 999;
								self.ammo_fuel = 999;
								self.health = start_health;
								self.armorvalue = start_armorvalue;
								self.weapons |= weaponsInMap;
								self.pauserotarmor_finished = time + cvar("g_balance_pause_armor_rot_spawn");
								self.pauserothealth_finished = time + cvar("g_balance_pause_health_rot_spawn");
								self.pauserotfuel_finished = time + cvar("g_balance_pause_fuel_rot_spawn");
								self.pauseregen_finished = time + cvar("g_balance_pause_health_regen_spawn");
								self.strength_finished = 0;
								self.invincible_finished = 0;
							}
							else
							{
								self.ammo_rockets = self.personal.ammo_rockets;
								self.ammo_nails = self.personal.ammo_nails;
								self.ammo_cells = self.personal.ammo_cells;
								self.ammo_shells = self.personal.ammo_shells;
								self.ammo_fuel = self.personal.ammo_fuel;
								self.health = self.personal.health;
								self.armorvalue = self.personal.armorvalue;
								self.weapons = self.personal.weapons;
								self.items = self.personal.items;
								self.pauserotarmor_finished = time + self.personal.pauserotarmor_finished - self.personal.teleport_time;
								self.pauserothealth_finished = time + self.personal.pauserothealth_finished - self.personal.teleport_time;
								self.pauserotfuel_finished = time + self.personal.pauserotfuel_finished - self.personal.teleport_time;
								self.pauseregen_finished = time + self.personal.pauseregen_finished - self.personal.teleport_time;
								self.strength_finished = time + self.personal.strength_finished - self.personal.teleport_time;
								self.invincible_finished = time + self.personal.invincible_finished - self.personal.teleport_time;
							}
						}
						else if(self.deadflag != DEAD_NO)
							sprint(self, "UR DEAD AHAHAH))\n");
						else
							sprint(self, "No waypoint set, cheater (use g_waypointsprite_personal to set one)\n");
						break;
					case 143:
						if(MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, ((sv_cheats >= 2) ? 100000 : 100), 1024, 256))
						{
							self.angles_x = -self.angles_x;
							self.fixangle = TRUE;
							self.velocity = '0 0 0';
						}
						else
							sprint(self, "Emergency teleport could not find a good location, forget it!\n");
						break;
					case 144:
						makevectors(self.v_angle);
						traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * MAX_SHOT_DISTANCE, FALSE, self);
						if (trace_fraction < 1)
							printsurfaceinfo(trace_ent, trace_endpos);
						break;
					case 145:
						makevectors(self.v_angle);
						traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 65536, FALSE, self);
						sprint(self, strcat("distance: ", ftos(fabs(vlen(trace_endpos - (self.origin + self.view_ofs)))), "\n"));
						break;
					case 146:
						makevectors(self.v_angle);
						i = self.dphitcontentsmask;
						self.dphitcontentsmask = DPCONTENTS_OPAQUE;
						traceline(self.origin + self.view_ofs, self.origin + self.view_ofs + v_forward * 65536, FALSE, self);
						self.dphitcontentsmask = i;
						sprint(self, strcat("distance: ", ftos(fabs(vlen(trace_endpos - (self.origin + self.view_ofs)))), "\n"));
						pointparticles(particleeffectnum("fire_big"), trace_endpos, '0 0 0', 10);
						break;
					case 148:
						FOR_EACH_PLAYER(e)
						{
							if( e.playermodel == "models/player/jeandarc.zym"
							||  e.playermodel == "models/player/pyria.zym"
							||  e.playermodel == "models/player/skadi.zym"
							|| (e.playermodel == "models/player/specop.zym" && random() < 0.5) // you never know
							||  e.playermodel == "models/player/visitant.zym")
							{
								makevectors(e.angles);
								traceline(e.origin, e.origin + v_right * 256, MOVE_NORMAL, e);
							}
							else
							{
								org_x = random();
								org_y = random();
								org_z = 0;
								org = normalize(org);
								traceline(e.origin, e.origin + org * 256, MOVE_NORMAL, e); // random direction
							}

							org = findbetterlocation(trace_endpos, 12);

							e2 = spawn();
							setorigin(e2, org);
							pointparticles(particleeffectnum("rocket_explode"), org, '0 0 0', 1);
							sound(e2, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
							RadiusDamage(e2, e, 1000, 0, 128, e, 500, DEATH_CHEAT, world);
							remove(e2);
						}
						print("404 Sportsmanship not found.\n");
						break;
				}
			}
		}
	}
	else if(imp >= 103 && imp <= 107)
	{
		if(cvar("g_waypointeditor"))
		{
			switch(imp)
			{
				case 103:
					waypoint_schedulerelink(waypoint_spawn(self.origin, self.origin, 0));
					bprint(strcat("Waypoint spawned at ",vtos(self.origin),"\n"));
					break;
				case 104:
					e = navigation_findnearestwaypoint(self, FALSE);
					if (e)
					if not(e.wpflags & WAYPOINTFLAG_GENERATED)
					{
						bprint(strcat("Waypoint removed at ",vtos(e.origin),"\n"));
						waypoint_remove(e);
					}
					break;
				case 105:
					waypoint_schedulerelinkall();
					break;
				case 106:
					waypoint_saveall();
					break;
				case 107:
					navigation_markroutes();
					for(e = findchain(classname, "waypoint"); e; e = e.chain)
					{
						if(e.wpcost < 10000000)
						{
							e.colormod_x = 1;
							e.effects &~= EF_NODEPTHTEST;
						}
						else
						{
							e.colormod_x = 0.1;
							e.effects |= EF_NODEPTHTEST;
						}
					}
					break;
			}
		}
	}
#ifdef TETRIS
	else if(imp == 100)
		TetrisImpulse();
#endif
}
