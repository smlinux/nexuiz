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

#define CHRAME_DRAG 1

float CheatsAllowed(float i, float argc, float fr) // the cheat gets passed as argument for possible future ACL checking
{
	if(i == CHIMPULSE_CLONE_MOVING || i == CHIMPULSE_CLONE_STANDING)
		if(self.lip < sv_clones)
			goto allow;
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
	if not(CheatsAllowed(i, 0, 0))
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
			goto cheated;
		case CHIMPULSE_CLONE_MOVING:
			makevectors (self.v_angle);
			self.velocity = self.velocity + v_forward * 300;
			CopyBody(1);
			self.lip += 1;
			self.velocity = self.velocity - v_forward * 300;
			goto cheated;
		case CHIMPULSE_CLONE_STANDING:
			CopyBody(0);
			self.lip += 1;
			goto cheated;
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
			goto cheated;
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
				goto cheated;
			}
			else if(self.deadflag != DEAD_NO)
				sprint(self, "UR DEAD AHAHAH))\n");
			else
				sprint(self, "No waypoint set, cheater (use g_waypointsprite_personal to set one)\n");
			break;
		case CHIMPULSE_TELEPORT:
			if(MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, ((sv_cheats >= 2) ? 100000 : 100), 1024, 256))
			{
				self.angles_x = -self.angles_x;
				self.fixangle = TRUE;
				self.velocity = '0 0 0';
				goto cheated;
			}
			else
				sprint(self, "Emergency teleport could not find a good location, forget it!\n");
			break;
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
			goto cheated;
	}
	return 0;

:cheated
	cheatcount_total += 1;
	self.cheatcount += 1;
	return 1;
}

float CheatCommand(float argc)
{
	if not(CheatsAllowed(0, argc, 0))
		return 0;
	string cmd;
	cmd = argv(0);
	switch(cmd)
	{
		entity e;
		float effectnum, f;
		vector start, end;
		entity oldself;

		case "pointparticles":
			if(argc == 5)
			{
				// arguments:
				//   effectname
				//   origin (0..1, on crosshair line)
				//   velocity
				//   howmany
				effectnum = particleeffectnum(argv(1));
				f = stof(argv(2));
				start = (1-f) * self.origin + f * self.cursor_trace_endpos;
				end = stov(argv(3));
				f = stof(argv(4));
				pointparticles(effectnum, start, end, f);
				goto cheated;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd pointparticles effectname position(0..1) velocityvector multiplier\n");
			break;
		case "trailparticles":
			if(argc == 2)
			{
				// arguments:
				//   effectname
				effectnum = particleeffectnum(argv(1));
				W_SetupShot(self, FALSE, FALSE, "",0);
				traceline(w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, MOVE_NORMAL, self);
				trailparticles(self, effectnum, w_shotorg, trace_endpos);
				goto cheated;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd trailparticles effectname\n");
			break;
		case "make":
			if(argc == 3)
			{
				// arguments:
				//   modelname mode
				f = stof(argv(2));
				W_SetupShot(self, FALSE, FALSE, "", 0);
				traceline(w_shotorg, w_shotorg + w_shotdir * 2048, MOVE_NORMAL, self);
				if((trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT) || trace_fraction == 1)
				{
					sprint(self, "cannot make stuff there (bad surface)\n");
				}
				else
				{
					e = spawn();
					e.model = strzone(argv(1));
					e.mdl = "rocket_explode";
					e.health = 1000;
					setorigin(e, trace_endpos);
					e.effects = EF_NOMODELFLAGS;
					if(f == 1)
					{
						e.angles = fixedvectoangles2(trace_plane_normal, v_forward);
						e.angles = AnglesTransform_Multiply(e.angles, '-90 0 0'); // so unrotated models work
					}
					oldself = self;
					self = e;
					spawnfunc_func_breakable();
					self = oldself;
					// now, is it valid?
					if(f == 0)
					{
						tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_NORMAL, e);
						if(trace_startsolid)
						{
							remove(e);
							sprint(self, "cannot make stuff there (no space)\n");
						}
						else
							goto cheated;
					}
					else
						goto cheated;
				}
			}
			else
				sprint(self, "Usage: sv_cheats 1; restart; cmd make models/... 0/1/2\n");
			break;
		case "penalty":
			if(argc == 3)
			{
				race_ImposePenaltyTime(self, stof(argv(1)), argv(2));
				goto cheated;
			}
			sprint(self, "Usage: sv_cheats 1; restart; cmd penalty 5.0 AHAHAHAHAHAHAH))\n");
			break;
		case "dragbox_spawn":
			e = spawn();
			e.classname = "dragbox_box";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = -1; // black
			setmodel(e, "null"); // network it
			if(argc == 4)
				e.cnt = stof(argv(1));
			else
				e.cnt = max(0, drag_lastcnt);

			e.aiment = spawn();
			e.aiment.classname = "dragbox_corner_1";
			e.aiment.owner = e;
			setmodel(e.aiment, "models/marker.md3");
			e.aiment.skin = 0;
			setsize(e.aiment, '0 0 0', '0 0 0');
			if(argc == 4)
				setorigin(e.aiment, stov(argv(2)));
			else
				setorigin(e.aiment, self.cursor_trace_endpos);

			e.enemy = spawn();
			e.enemy.classname = "dragbox_corner_2";
			e.enemy.owner = e;
			setmodel(e.enemy, "models/marker.md3");
			e.enemy.skin = 1;
			setsize(e.enemy, '0 0 0', '0 0 0');
			end = normalize(self.cursor_trace_start - e.aiment.origin);
			end_x = (end_x > 0) * 2 - 1;
			end_y = (end_y > 0) * 2 - 1;
			end_z = (end_z > 0) * 2 - 1;
			if(argc == 4)
				setorigin(e.enemy, stov(argv(3)));
			else
				setorigin(e.enemy, e.aiment.origin + 32 * end);

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 -8');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 8');
			goto cheated;
		case "dragpoint_spawn":
			e = spawn();
			e.classname = "dragpoint";
			e.think = DragBox_Think;
			e.nextthink = time;
			e.solid = 0; // nothing special
			setmodel(e, "models/marker.md3");
			setsize(e, PL_MIN, PL_MAX);
			e.skin = 2;
			if(argc == 3)
				e.cnt = stof(argv(1));
			else
				e.cnt = drag_lastcnt;
			if(argc == 3)
				setorigin(e, stov(argv(2)));
			else
			{
				setorigin(e, self.cursor_trace_endpos + normalize(self.cursor_trace_start - self.cursor_trace_endpos));
				move_out_of_solid(e);
			}

			e.killindicator = spawn();
			e.killindicator.classname = "drag_digit";
			e.killindicator.owner = e;
			setattachment(e.killindicator, e, "");
			setorigin(e.killindicator, '0 0 40');
			e.killindicator.killindicator = spawn();
			e.killindicator.killindicator.classname = "drag_digit";
			e.killindicator.killindicator.owner = e;
			setattachment(e.killindicator.killindicator, e, "");
			setorigin(e.killindicator.killindicator, '0 0 56');
			goto cheated;
		case "drag_remove":
			RandomSelection_Init();
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			for(e = world; (e = find(e, classname, "dragpoint")); )
				RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
			if(RandomSelection_chosen_ent)
			{
				remove(RandomSelection_chosen_ent.killindicator.killindicator);
				remove(RandomSelection_chosen_ent.killindicator);
				if(RandomSelection_chosen_ent.aiment)
					remove(RandomSelection_chosen_ent.aiment);
				if(RandomSelection_chosen_ent.enemy)
					remove(RandomSelection_chosen_ent.enemy);
				remove(RandomSelection_chosen_ent);
			}
			goto cheated;
		case "drag_setcnt":
			if(argc == 2)
			{
				RandomSelection_Init();
				for(e = world; (e = find(e, classname, "dragbox_box")); )
					RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
				for(e = world; (e = find(e, classname, "dragpoint")); )
					RandomSelection_Add(e, 0, string_null, 1, 1 / vlen(e.origin + (e.mins + e.maxs) * 0.5 - self.cursor_trace_endpos));
				if(RandomSelection_chosen_ent)
				{
					if(substring(argv(1), 0, 1) == "*")
						RandomSelection_chosen_ent.cnt = drag_lastcnt = RandomSelection_chosen_ent.cnt + stof(substring(argv(1), 1, -1));
					else
						RandomSelection_chosen_ent.cnt = drag_lastcnt = stof(argv(1));
				}
				goto cheated;
			}
			else
				sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_setcnt cnt\n");
			break;
		case "drag_save":
			if(argc == 2)
			{
				f = fopen(argv(1), FILE_WRITE);
				fputs(f, "cmd drag_clear\n");
				for(e = world; (e = find(e, classname, "dragbox_box")); )
				{
					fputs(f, strcat("cmd dragbox_spawn ", ftos(e.cnt), " \"", vtos(e.aiment.origin), "\" \"", vtos(e.enemy.origin), "\"\n"));
				}
				for(e = world; (e = find(e, classname, "dragpoint")); )
				{
					fputs(f, strcat("cmd dragpoint_spawn ", ftos(e.cnt), " \"", vtos(e.origin), "\"\n"));
				}
				fclose(f);
				goto cheated;
			}
			else
				sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
			break;
		case "drag_saveraceent":
			if(argc == 2)
			{
				f = fopen(argv(1), FILE_WRITE);
				for(e = world; (e = find(e, classname, "dragbox_box")); )
				{
					fputs(f, "{\n");
					fputs(f, "\"classname\" \"trigger_race_checkpoint\"\n");
					fputs(f, strcat("\"origin\" \"", ftos(e.absmin_x), " ", ftos(e.absmin_y), " ", ftos(e.absmin_z), "\"\n"));
					fputs(f, strcat("\"maxs\" \"", ftos(e.absmax_x - e.absmin_x), " ", ftos(e.absmax_y - e.absmin_y), " ", ftos(e.absmax_z - e.absmin_z), "\"\n"));
					fputs(f, strcat("\"cnt\" \"", ftos(e.cnt), "\"\n"));
					fputs(f, strcat("\"targetname\" \"checkpoint", ftos(e.cnt), "\"\n"));
					fputs(f, "}\n");
				}
				for(e = world; (e = find(e, classname, "dragpoint")); )
				{
					start = '0 0 0';
					effectnum = 0;
					for(oldself = world; (oldself = find(oldself, classname, "dragbox_box")); )
					{
						if(e.cnt <= 0 && oldself.cnt == 0 || e.cnt == oldself.cnt)
						{
							start = start + oldself.origin;
							++effectnum;
						}
					}
					start *= 1 / effectnum;
					fputs(f, "{\n");
					fputs(f, "\"classname\" \"info_player_race\"\n");
					fputs(f, strcat("\"angle\" \"", ftos(vectoyaw(start - e.origin)), "\"\n"));
					fputs(f, strcat("\"origin\" \"", ftos(e.origin_x), " ", ftos(e.origin_y), " ", ftos(e.origin_z), "\"\n"));
					if(e.cnt == -2)
					{
						fputs(f, "\"target\" \"checkpoint0\"\n");
						fputs(f, "\"race_place\" \"0\"\n");
					}
					else if(e.cnt == -1)
					{
						fputs(f, "\"target\" \"checkpoint0\"\n");
						fputs(f, "\"race_place\" \"-1\"\n");
					}
					else
					{
						fputs(f, strcat("\"target\" \"checkpoint", ftos(e.cnt), "\"\n"));
						if(e.cnt == 0)
						{
							// these need race_place
							// counting...
							effectnum = 1;
							for(oldself = world; (oldself = find(oldself, classname, "dragpoint")); )
							if(oldself.cnt == 0)
							{
								if(vlen(oldself.origin - start) < vlen(e.origin - start))
									++effectnum;
								else if(vlen(oldself.origin - start) == vlen(e.origin - start) && num_for_edict(oldself) < num_for_edict(e))
									++effectnum;
							}
							fputs(f, strcat("\"race_place\" \"", ftos(effectnum), "\"\n"));
						}
					}
					fputs(f, "}\n");
				}
				fclose(f);
				goto cheated;
			}
			else
				sprint(self, "Usage: sv_cheats 1; restart; cmd dragbox_save filename\n");
			break;
		case "drag_clear":
			for(e = world; (e = find(e, classname, "dragbox_box")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_1")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragbox_corner_2")); )
				remove(e);
			for(e = world; (e = find(e, classname, "dragpoint")); )
				remove(e);
			for(e = world; (e = find(e, classname, "drag_digit")); )
				remove(e);
			goto cheated;
	}
	return 0;

:cheated
	cheatcount_total += 1;
	self.cheatcount += 1;
	return 1;
}

void Drag_Begin(entity dragger, entity draggee, vector touchpoint);
void Drag_Finish(entity dragger);
float Drag_IsDraggable(entity draggee);
float Drag_MayChangeAngles(entity draggee);
void Drag_MoveForward(entity dragger);
void Drag_SetSpeed(entity dragger, float s);
void Drag_MoveBackward(entity dragger);
void Drag_Update(entity dragger);
float Drag_CanDrag(entity dragger);
float Drag_IsDragging(entity dragger);
void Drag_MoveDrag(entity from, entity to);
.entity dragentity;

float CheatFrame()
{
	float cheating;
	cheating = 0;

	if(CheatsAllowed(0, 0, CHRAME_DRAG))
		if(Drag_CanDrag(self))
			if(self.BUTTON_DRAG)
				if(!self.dragentity)
					if(self.cursor_trace_ent)
						if(Drag_IsDraggable(self.cursor_trace_ent))
						{
							if(self.cursor_trace_ent.draggedby)
								Drag_Finish(self.cursor_trace_ent.draggedby);
							if(self.cursor_trace_ent.tag_entity)
								detach_sameorigin(self.cursor_trace_ent);
							Drag_Begin(self, self.cursor_trace_ent, self.cursor_trace_endpos);
							++cheating;
						}
	if(Drag_IsDragging(self))
	{
		if(self.BUTTON_DRAG)
		{
			if(self.impulse == 10 || self.impulse == 15 || self.impulse == 18)
			{
				Drag_MoveForward(self);
				self.impulse = 0;
			}
			else if(self.impulse == 12 || self.impulse == 16 || self.impulse == 19)
			{
				Drag_MoveBackward(self);
				self.impulse = 0;
			}
			else if(self.impulse >= 1 && self.impulse <= 9)
			{
				Drag_SetSpeed(self, self.impulse - 1);
			}
			else if(self.impulse == 14)
			{
				Drag_SetSpeed(self, 9);
			}

			if(frametime)
				Drag_Update(self);
		}
		else
		{
			Drag_Finish(self);
		}
	}

	if(cheating)
	{
		cheatcount_total += 1;
		self.cheatcount += 1;
		return 1;
	}

	return cheating;
}





// ENTITY DRAGGING

// on dragger:
.float draggravity;
.float dragspeed; // speed of mouse wheel action
.float dragdistance; // distance of dragentity's draglocalvector from view_ofs
.vector draglocalvector; // local attachment vector of the dragentity
.float draglocalangle;
// on draggee:
.entity draggedby;
.float dragmovetype;
void Drag_Begin(entity dragger, entity draggee, vector touchpoint)
{
	float tagscale;

	draggee.dragmovetype = draggee.movetype;
	draggee.draggravity = draggee.gravity;
	draggee.movetype = MOVETYPE_WALK;
	draggee.gravity = 0.00001;
	draggee.flags &~= FL_ONGROUND;
	draggee.draggedby = dragger;

	dragger.dragentity = draggee;

	dragger.dragdistance = vlen(touchpoint - dragger.origin - dragger.view_ofs);
	dragger.draglocalangle = draggee.angles_y - dragger.v_angle_y;
	touchpoint = touchpoint - gettaginfo(draggee, 0);
	tagscale = pow(vlen(v_forward), -2);
	dragger.draglocalvector_x = touchpoint * v_forward * tagscale;
	dragger.draglocalvector_y = touchpoint * v_right * tagscale;
	dragger.draglocalvector_z = touchpoint * v_up * tagscale;

	dragger.dragspeed = 64;
}

void Drag_Finish(entity dragger)
{
	entity draggee;
	draggee = dragger.dragentity;
	if(dragger)
		dragger.dragentity = world;
	draggee.draggedby = world;
	draggee.movetype = draggee.dragmovetype;
	draggee.gravity = draggee.draggravity;

	switch(draggee.movetype)
	{
		case MOVETYPE_TOSS:
		case MOVETYPE_WALK:
		case MOVETYPE_STEP:
		case MOVETYPE_FLYMISSILE:
		case MOVETYPE_BOUNCE:
		case MOVETYPE_BOUNCEMISSILE:
		case MOVETYPE_PHYSICS:
			break;
		default:
			draggee.velocity = '0 0 0';
			break;
	}

	if((draggee.flags & FL_ITEM) && (vlen(draggee.velocity) < 32))
	{
		draggee.velocity = '0 0 0';
		draggee.flags |= FL_ONGROUND; // floating items are FUN
	}
}

float Drag_IsDraggable(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(draggee.classname == "func_bobbing")
		return FALSE;
	if(draggee.classname == "door") // FIXME find out why these must be excluded, or work around the problem (trying to drag these causes like 4 fps)
		return FALSE;
	if(draggee.classname == "plat")
		return FALSE;
	if(draggee.classname == "func_button")
		return FALSE;
	if(draggee.model == "")
		return FALSE;
	if(draggee.classname == "spectator")
		return FALSE;
	if(draggee.classname == "observer")
		return FALSE;
	if(draggee.classname == "exteriorweaponentity")
		return FALSE;

	return TRUE;
}

float Drag_MayChangeAngles(entity draggee)
{
	// TODO add more checks for bad stuff here
	if(substring(draggee.model, 0, 1) == "*")
		return FALSE;
	return TRUE;
}

void Drag_MoveForward(entity dragger)
{
	dragger.dragdistance += dragger.dragspeed;
}

void Drag_SetSpeed(entity dragger, float s)
{
	dragger.dragspeed = pow(2, s);
}

void Drag_MoveBackward(entity dragger)
{
	dragger.dragdistance = max(0, dragger.dragdistance - dragger.dragspeed);
}

void Drag_Update(entity dragger)
{
	vector curorigin, neworigin, goodvelocity;
	float f;
	entity draggee;

	draggee = dragger.dragentity;
	draggee.flags &~= FL_ONGROUND;

	curorigin = gettaginfo(draggee, 0);
	curorigin = curorigin + v_forward * dragger.draglocalvector_x + v_right * dragger.draglocalvector_y + v_up * dragger.draglocalvector_z;
	makevectors(dragger.v_angle);
	neworigin = dragger.origin + dragger.view_ofs + v_forward * dragger.dragdistance;
	goodvelocity = (neworigin - curorigin) * (1 / frametime);

	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle > 180)
		dragger.draglocalangle += 360;
	while(draggee.angles_y - dragger.v_angle_y - dragger.draglocalangle <= -180)
		dragger.draglocalangle -= 360;

	f = min(frametime * 10, 1);
	draggee.velocity = draggee.velocity * (1 - f) + goodvelocity * f;

	if(Drag_MayChangeAngles(draggee))
		draggee.angles_y = draggee.angles_y * (1 - f) + (dragger.v_angle_y + dragger.draglocalangle) * f;

	draggee.ltime = max(servertime + serverframetime, draggee.ltime); // fixes func_train breakage

	te_lightning1(dragger, dragger.origin + dragger.view_ofs, curorigin);
}

float Drag_CanDrag(entity dragger)
{
	return (dragger.deadflag == DEAD_NO) || (dragger.classname == "player");
}

float Drag_IsDragging(entity dragger)
{
	if(!dragger.dragentity)
		return FALSE;
	if(wasfreed(dragger.dragentity) || dragger.dragentity.draggedby != dragger)
	{
		dragger.dragentity = world;
		return FALSE;
	}
	if(!Drag_CanDrag(dragger) || !Drag_IsDraggable(dragger.dragentity))
	{
		Drag_Finish(dragger);
		return FALSE;
	}
	return TRUE;
}

void Drag_MoveDrag(entity from, entity to)
{
	if(from.draggedby)
	{
		to.draggedby = from.draggedby;
		to.draggedby.dragentity = to;
		from.draggedby = world;
	}
}

