void CopyBody(float keepvelocity);

.float maycheat;
float sv_cheats;
float autocvar_sv_cheats;

#define CHIMPULSE_SPEEDRUN_INIT 30
#define CHIMPULSE_GIVE_ALL 99
#define CHIMPULSE_CLONE_MOVING 140
#define CHIMPULSE_SPEEDRUN 141
#define CHIMPULSE_CLONE_STANDING 142
#define CHIMPULSE_TELEPORT 143
#define CHIMPULSE_R00T 148

float CheatsAllowed(float i, string cmd) // the cheat gets passed as argument for possible future ACL checking
{
	if(i == CHIMPULSE_CLONE_MOVING || i == CHIMPULSE_CLONE_STANDING)
		if(self.lip < sv_clones)
			return 1;
	if(self.maycheat)
		return 1;
	if(sv_cheats && autocvar_sv_cheats)
		return 1;
	if(autocvar_sv_cheats)
		sprint(self, "Cheats are not yet allowed, and will be activated at next map change.\n");
	return 0;
}

float CheatImpulse(float i)
{
	if not(CheatsAllowed(i, string_null))
		return 0;
	switch(i)
	{
		float wep;
		entity e, e2;
		vector org;

		case CHIMPULSE_SPEEDRUN_INIT: // deploy personal waypoint
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
			return 1;
		case CHIMPULSE_CLONE_MOVING:
			makevectors (self.v_angle);
			self.velocity = self.velocity + v_forward * 300;
			CopyBody(1);
			self.lip += 1;
			self.velocity = self.velocity - v_forward * 300;
			return 1;
		case CHIMPULSE_CLONE_STANDING:
			CopyBody(0);
			self.lip += 1;
			return 1;
		case CHIMPULSE_GIVE_ALL:
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
			return 1;
		case CHIMPULSE_SPEEDRUN:
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
				return 1;
			}
			else if(self.deadflag != DEAD_NO)
				sprint(self, "UR DEAD AHAHAH))\n");
			else
				sprint(self, "No waypoint set, cheater (use g_waypointsprite_personal to set one)\n");
			return 0;
		case CHIMPULSE_TELEPORT:
			if(MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, ((sv_cheats >= 2) ? 100000 : 100), 1024, 256))
			{
				self.angles_x = -self.angles_x;
				self.fixangle = TRUE;
				self.velocity = '0 0 0';
				return 1;
			}
			else
				sprint(self, "Emergency teleport could not find a good location, forget it!\n");
			return 0;
		case CHIMPULSE_R00T:
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
			return 1;
	}
	return 0;
}

float CheatCommand(string cmd)
{
	if not(CheatsAllowed(0, cmd))
		return 0;
	return 0;
}
