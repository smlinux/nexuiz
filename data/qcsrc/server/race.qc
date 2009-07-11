#define MAX_CHECKPOINTS 255

.float race_penalty;
.float race_penalty_accumulator;
.string race_penalty_reason;
.float race_checkpoint; // player: next checkpoint that has to be reached
.float race_laptime;
.entity race_lastpenalty;

.entity sprite;

float race_checkpoint_records[MAX_CHECKPOINTS];
string race_checkpoint_recordholders[MAX_CHECKPOINTS];
float race_checkpoint_lasttimes[MAX_CHECKPOINTS];
float race_checkpoint_lastlaps[MAX_CHECKPOINTS];
entity race_checkpoint_lastplayers[MAX_CHECKPOINTS];

float race_highest_checkpoint;
float race_timed_checkpoint;

float race_NextCheckpoint(float f)
{
	if(f >= race_highest_checkpoint)
		return 0;
	else
		return f + 1;
}

float race_PreviousCheckpoint(float f)
{
	if(f == -1)
		return 0;
	else if(f == 0)
		return race_highest_checkpoint;
	else
		return f - 1;
}

// encode as:
//   0 = common start/finish
// 254 = start
// 255 = finish
float race_CheckpointNetworkID(float f)
{
	if(race_timed_checkpoint)
	{
		if(f == 0)
			return 254; // start
		else if(f == race_timed_checkpoint)
			return 255; // finish
	}
	return f;
}

void race_SendNextCheckpoint(entity e, float spec)
{
	float recordtime;
	string recordholder;
	float cp;

	if(!e.race_laptime)
		return;

	cp = e.race_checkpoint;
	recordtime = race_checkpoint_records[cp];
	recordholder = race_checkpoint_recordholders[cp];
	/*
	recordtime = stof(db_get(ServerProgsDB, strcat(GetMapname(), "/racerecord/", ftos(cp), "/time")));
	recordholder = db_get(ServerProgsDB, strcat(GetMapname(), "/racerecord/", ftos(cp), "/netname"));
	*/
	if(recordholder == e.netname)
		recordholder = "";

	if(!spec)
		msg_entity = e;
	WRITESPECTATABLE_MSG_ONE({
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_RACE);
		if(spec)
		{
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_NEXT_SPEC_QUALIFYING);
			WriteCoord(MSG_ONE, e.race_laptime - e.race_penalty_accumulator);
		}
		else
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_NEXT_QUALIFYING);
		WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player will be at next
		WriteShort(MSG_ONE, recordtime);
		WriteString(MSG_ONE, recordholder);
	});
}

void race_InitSpectator()
{
	if(g_race_qualifying)
		if(msg_entity.enemy.race_laptime)
			race_SendNextCheckpoint(msg_entity.enemy, 1);
}

void race_SendTime(entity e, float cp, float t, float tvalid)
{
	float snew, l;
	entity p;

	if(g_race_qualifying)
		t += e.race_penalty_accumulator;

	t = floor(0.4 + 10 * t); // make integer
	// adding just 0.4 so it rounds down in the .5 case (matching the timer display)

	if(tvalid)
	if(cp == race_timed_checkpoint) // finish line
	if not(e.race_completed)
	{
		float s;
		if(g_race_qualifying)
		{
			s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
			if(!s || t < s)
				PlayerScore_Add(e, SP_RACE_FASTEST, t - s);
		}
		else
		{
			s = PlayerScore_Add(e, SP_RACE_TIME, 0);
			snew = floor(0.4 + 10 * (time - game_starttime));
			PlayerScore_Add(e, SP_RACE_TIME, snew - s);
			l = PlayerTeamScore_Add(e, SP_RACE_LAPS, ST_RACE_LAPS, 1);

			if(cvar("fraglimit"))
				if(l >= cvar("fraglimit"))
				{
					race_completing = 1;
					FOR_EACH_PLAYER(p)
						if(p.deadflag != DEAD_NO)
							race_AbandonRaceCheck(p);
				}

			if(race_completing)
			{
				e.race_completed = 1;
				MAKE_INDEPENDENT_PLAYER(e);
				bprint(e.netname, "^7 has finished the race.\n");
				ClientData_Touch(e);
			}
		}
	}

	float recordtime;
	string recordholder;

	if(g_race_qualifying)
	{
		if(tvalid)
		{
			recordtime = race_checkpoint_records[cp];
			recordholder = strcat1(race_checkpoint_recordholders[cp]); // make a tempstring copy, as we'll possibly strunzone it!
			if(recordholder == e.netname)
				recordholder = "";

			if(t != 0)
			if(t < recordtime || recordtime == 0)
			{
				race_checkpoint_records[cp] = t;
				if(race_checkpoint_recordholders[cp])
					strunzone(race_checkpoint_recordholders[cp]);
				race_checkpoint_recordholders[cp] = strzone(e.netname);
				if(cp == race_timed_checkpoint)
				{
					float grecordtime;
					string grecordholder;
					grecordtime = stof(db_get(ServerProgsDB, strcat(GetMapname(), "/racerecord/time")));
					grecordholder = db_get(ServerProgsDB, strcat(GetMapname(), "/racerecord/netname"));
					if(grecordholder == e.netname)
						grecordholder = "";
					if(grecordtime == 0)
					{
						bprint(e.netname, "^7 set the all-time fastest lap record with ", mmsss(t), "\n");
						db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/time"), ftos(t));
						db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/netname"), e.netname);
						write_recordmarker(e, time - t/10, t/10);
					}
					else if(t < grecordtime)
					{
						if(grecordholder == "")
							bprint(e.netname, "^7 broke his all-time fastest lap record with ", mmsss(t), "\n");
						else
							bprint(e.netname, "^7 broke ", grecordholder, "^7's all-time fastest lap record with ", mmsss(t), "\n");
						db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/time"), ftos(t));
						db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/netname"), e.netname);
						write_recordmarker(e, time - t/10, t/10);
					}
					else
					{
						if(grecordholder == "")
							bprint(e.netname, "^7's new fastest lap could not break his all-time fastest lap record of ", mmsss(grecordtime), "\n");
						else
							bprint(e.netname, "^7's new fastest lap could not break ", grecordholder, "^7's all-time fastest lap record of ", mmsss(grecordtime), "\n");
					}
				}

				if(g_race_qualifying)
				{
					FOR_EACH_REALPLAYER(p)
						if(p.race_checkpoint == cp)
							race_SendNextCheckpoint(p, 0);
				}
			}
		}
		else
		{
			// dummies
			t = 0;
			recordtime = 0;
			recordholder = "";
		}

		msg_entity = e;
		if(g_race_qualifying)
		{
			WRITESPECTATABLE_MSG_ONE_VARNAME(dummy1, {
				WriteByte(MSG_ONE, SVC_TEMPENTITY);
				WriteByte(MSG_ONE, TE_CSQC_RACE);
				WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_QUALIFYING);
				WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
				WriteShort(MSG_ONE, t); // time to that intermediate
				WriteShort(MSG_ONE, recordtime); // previously best time
				WriteString(MSG_ONE, recordholder); // record holder
			});
		}
	}
	else // RACE! Not Qualifying
	{
		float lself, lother, othtime;
		entity oth;
		oth = race_checkpoint_lastplayers[cp];
		if(oth)
		{
			lself = PlayerScore_Add(e, SP_RACE_LAPS, 0);
			lother = race_checkpoint_lastlaps[cp];
			othtime = race_checkpoint_lasttimes[cp];
		}
		else
			lself = lother = othtime = 0;

		msg_entity = e;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy2, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_RACE);
			WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
			if(e == oth)
			{
				WriteShort(MSG_ONE, 0);
				WriteByte(MSG_ONE, 0);
				WriteString(MSG_ONE, "");
			}
			else
			{
				WriteShort(MSG_ONE, floor(10 * (time - race_checkpoint_lasttimes[cp]) + 0.5));
				WriteByte(MSG_ONE, lself - lother);
				WriteString(MSG_ONE, oth.netname); // record holder
			}
		});

		race_checkpoint_lastplayers[cp] = e;
		race_checkpoint_lasttimes[cp] = time;
		race_checkpoint_lastlaps[cp] = lself;

		msg_entity = oth;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy3, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT_RACE_BY_OPPONENT);
			WriteByte(MSG_ONE, race_CheckpointNetworkID(cp)); // checkpoint the player now is at
			if(e == oth)
			{
				WriteShort(MSG_ONE, 0);
				WriteByte(MSG_ONE, 0);
				WriteString(MSG_ONE, "");
			}
			else
			{
				WriteShort(MSG_ONE, floor(10 * (time - othtime) + 0.5));
				WriteByte(MSG_ONE, lother - lself);
				WriteString(MSG_ONE, e.netname); // record holder
			}
		});
	}
}

void race_ClearTime(entity e)
{
	e.race_checkpoint = -1;
	e.race_laptime = 0;
	e.race_penalty_accumulator = 0;
	e.race_lastpenalty = world;

	msg_entity = e;
	WRITESPECTATABLE_MSG_ONE({
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_RACE);
		WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_CLEAR); // next
	});
}

void dumpsurface(entity e)
{
	float n, si, ni;
	vector norm, vec;
	print("Surfaces of ", etos(e), ":\n");

	print("TEST = ", ftos(getsurfacenearpoint(e, '0 0 0')), "\n");

	for(si = 0; ; ++si)
	{
		n = getsurfacenumpoints(e, si);
		if(n <= 0)
			break;
		print("  Surface ", ftos(si), ":\n");
		norm = getsurfacenormal(e, si);
		print("    Normal = ", vtos(norm), "\n");
		for(ni = 0; ni < n; ++ni)
		{
			vec = getsurfacepoint(e, si, ni);
			print("    Point ", ftos(ni), " = ", vtos(vec), " (", ftos(norm * vec), ")\n");
		}
	}
}

void checkpoint_passed()
{
	string oldmsg;

	if(other.classname == "porto")
	{
		// do not allow portalling through checkpoints
		trace_plane_normal = normalize(-1 * other.velocity);
		self = other;
		W_Porto_Fail(0);
		return;
	}

	/*
	 * Trigger targets
	 */
	if not(self.spawnflags & 2)
	{
		activator = other;
		oldmsg = self.message;
		self.message = "";
		SUB_UseTargets();
		self.message = oldmsg;
	}

	if(other.classname != "player")
		return;

	/*
	 * Remove unauthorized equipment
	 */
	Portal_ClearAll(other);

	other.porto_forbidden = 2; // decreased by 1 each StartFrame

	if(other.race_checkpoint == -1 || other.race_checkpoint == self.race_checkpoint)
	{
		if(self.race_penalty)
		{
			if(other.race_lastpenalty != self)
			{
				other.race_lastpenalty = self;
				race_ImposePenaltyTime(other, self.race_penalty, self.race_penalty_reason);
			}
		}

		if(other.race_penalty)
			return;

		/*
		 * Trigger targets
		 */
		if(self.spawnflags & 2)
		{
			activator = other;
			oldmsg = self.message;
			self.message = "";
			SUB_UseTargets();
			self.message = oldmsg;
		}

		other.race_checkpoint = race_NextCheckpoint(self.race_checkpoint);

		race_SendTime(other, self.race_checkpoint, time - other.race_laptime, !!other.race_laptime);

		if(!self.race_checkpoint) // start line
		{
			other.race_laptime = time;
			other.race_penalty_accumulator = 0;
			other.race_lastpenalty = world;
		}

		if(g_race_qualifying)
			race_SendNextCheckpoint(other, 0);
	}
	else if(other.race_checkpoint == race_NextCheckpoint(self.race_checkpoint))
	{
		// ignored
	}
	else
	{
		if(self.spawnflags & 4)
			Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
	}
}

void checkpoint_touch()
{
	EXACTTRIGGER_TOUCH;
	checkpoint_passed();
}

void checkpoint_use()
{
	if(other.classname == "info_player_deathmatch") // a spawn, a spawn
		return;

	other = activator;
	checkpoint_passed();
}

float race_waypointsprite_visible_for_player(entity e)
{
	if(e.race_checkpoint == -1)
		return TRUE;
	else if(e.race_checkpoint == self.owner.race_checkpoint)
		return TRUE;
	else
		return FALSE;
}

float have_verified;
void trigger_race_checkpoint_verify()
{
	entity oldself, cp;
	float i, p;
	float qual;

	if(have_verified)
		return;
	have_verified = 1;
	
	qual = g_race_qualifying;

	oldself = self;
	self = spawn();
	self.classname = "player";

	for(i = 0; i <= race_highest_checkpoint; ++i)
	{
		self.race_checkpoint = race_NextCheckpoint(i);

		// race only (middle of the race)
		g_race_qualifying = 0;
		self.race_place = 0;
		if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), world, 0, FALSE))
			error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for respawning in race) - bailing out"));

		if(i == 0)
		{
			// qualifying only
			g_race_qualifying = 1;
			self.race_place = race_lowest_place_spawn;
			if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), world, 0, FALSE))
				error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for qualifying) - bailing out"));
			
			// race only (initial spawn)
			g_race_qualifying = 0;
			for(p = 1; p <= race_highest_place_spawn; ++p)
			{
				self.race_place = p;
				if(!Spawn_FilterOutBadSpots(findchain(classname, "info_player_deathmatch"), world, 0, FALSE))
					error(strcat("Checkpoint ", ftos(i), " misses a spawnpoint with race_place==", ftos(self.race_place), " (used for initially spawning in race) - bailing out"));
			}
		}
	}

	g_race_qualifying = qual;

	if(race_timed_checkpoint)
		for(cp = world; (cp = find(cp, classname, "trigger_race_checkpoint")); )
			if(cp.sprite)
			{
				if(cp.race_checkpoint == 0)
					WaypointSprite_UpdateSprites(cp.sprite, "race-start", "", "");
				else if(cp.race_checkpoint == race_timed_checkpoint)
					WaypointSprite_UpdateSprites(cp.sprite, "race-finish", "", "");
			}

	remove(self);
	self = oldself;
}

void spawnfunc_trigger_race_checkpoint()
{
	vector o;
	if(!g_race)
	{
		remove(self);
		return;
	}

	EXACTTRIGGER_INIT;

	self.use = checkpoint_use;
	if not(self.spawnflags & 1)
		self.touch = checkpoint_touch;

	o = (self.absmin + self.absmax) * 0.5;
	tracebox(o, PL_MIN, PL_MAX, o - '0 0 1' * (o_z - self.absmin_z), MOVE_NORMAL, self);
	self.nearestwaypoint = waypoint_spawn(trace_endpos, trace_endpos, WAYPOINTFLAG_GENERATED);
	self.nearestwaypointtimeout = time + 1000000000;

	if(!self.message)
		self.message = "went backwards";
	if (!self.message2)
		self.message2 = "was pushed backwards by";
	if (!self.race_penalty_reason)
		self.race_penalty_reason = "missing a checkpoint";
	
	self.race_checkpoint = self.cnt;

	if(self.race_checkpoint > race_highest_checkpoint)
	{
		race_highest_checkpoint = self.race_checkpoint;
		if(self.spawnflags & 8)
			race_timed_checkpoint = self.race_checkpoint;
		else
			race_timed_checkpoint = 0;
	}

	if(!self.race_penalty)
	{
		if(self.race_checkpoint)
			WaypointSprite_SpawnFixed("race-checkpoint", o, self, sprite);
		else
			WaypointSprite_SpawnFixed("race-finish", o, self, sprite);
	}

	self.sprite.waypointsprite_visible_for_player = race_waypointsprite_visible_for_player;

	InitializeEntity(self, trigger_race_checkpoint_verify, INITPRIO_FINDTARGET);
}

void race_AbandonRaceCheck(entity p)
{
	if(race_completing && !p.race_completed)
	{
		p.race_completed = 1;
		MAKE_INDEPENDENT_PLAYER(p);
		bprint(p.netname, "^7 has abandoned the race.\n");
		ClientData_Touch(p);
	}
}

void race_PreparePlayer()
{
	race_ClearTime(self);
	self.race_place = 0;
}

void race_RetractPlayer()
{
	if(!g_race)
		return;
	self.race_checkpoint = race_PreviousCheckpoint(self.race_checkpoint);
	if(self.race_checkpoint == 0)
	{
		race_ClearTime(self);
		self.race_checkpoint = 0;
	}
}

void race_PreDie()
{
	if(!g_race)
		return;

	race_AbandonRaceCheck(self);
}

void race_PreSpawn()
{
	if(!g_race)
		return;
	if(self.killcount == -666 || g_race_qualifying)
		race_PreparePlayer();

	race_AbandonRaceCheck(self);
}

void race_PostSpawn(entity spot)
{
	if(!g_race)
		return;
	if(self.killcount != -666 && !g_race_qualifying)
	{
		if(spot.target == "")
			// let the player run without timing, if he did not spawn at a targetting spawnpoint
			race_PreparePlayer();
		else
			race_RetractPlayer();
	}

	if(spot.target != "" && self.race_checkpoint == -1)
		self.race_checkpoint = 0;

	self.race_place = 0;
}

void race_PreSpawnObserver()
{
	if(!g_race)
		return;
	race_PreparePlayer();
}

void spawnfunc_info_player_race (void)
{
	if(!g_race)
	{
		remove(self);
		return;
	}
	++race_spawns;
	spawnfunc_info_player_deathmatch();

	if(self.race_place > race_highest_place_spawn)
		race_highest_place_spawn = self.race_place;
	if(self.race_place < race_lowest_place_spawn)
		race_lowest_place_spawn = self.race_place;
}

void race_ClearRecords()
{
	float i;
	entity e;

	for(i = 0; i < MAX_CHECKPOINTS; ++i)
	{
		race_checkpoint_records[i] = 0;
		if(race_checkpoint_recordholders[i])
			strunzone(race_checkpoint_recordholders[i]);
		race_checkpoint_recordholders[i] = string_null;
	}

	FOR_EACH_CLIENT(e)
		race_ClearTime(e);
}

void race_ReadyRestart()
{
	Score_NicePrint(world);

	race_ClearRecords();
	PlayerScore_Sort(race_place);

	entity e;
	FOR_EACH_CLIENT(e)
		print(e.netname, " = ", ftos(e.race_place), "\n");

	if(g_race_qualifying == 2)
	{
		g_race_qualifying = 0;
		independent_players = 0;
		cvar_set("fraglimit", ftos(race_fraglimit));
		cvar_set("leadlimit", ftos(race_leadlimit));
		ScoreRules_race();
	}
}

void race_ImposePenaltyTime(entity pl, float penalty, string reason)
{
	if(g_race_qualifying)
	{
		pl.race_penalty_accumulator += penalty;
		msg_entity = pl;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_PENALTY_QUALIFYING);
			WriteByte(MSG_ONE, floor(0.4 + 10 * penalty));
			WriteString(MSG_ONE, reason);
		});
	}
	else
	{
		pl.race_penalty = time + penalty;
		msg_entity = pl;
		WRITESPECTATABLE_MSG_ONE_VARNAME(dummy, {
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_RACE);
			WriteByte(MSG_ONE, RACE_NET_PENALTY_RACE);
			WriteByte(MSG_ONE, floor(0.4 + 10 * penalty));
			WriteString(MSG_ONE, reason);
		});
	}
}

void penalty_touch()
{
	EXACTTRIGGER_TOUCH;
	race_ImposePenaltyTime(other, self.race_penalty, self.race_penalty_reason);
}

void penalty_use()
{
	other = activator;
	if(other.race_lastpenalty != self)
	{
		other.race_lastpenalty = self;
		race_ImposePenaltyTime(other, self.race_penalty, self.race_penalty_reason);
	}
}

void spawnfunc_trigger_race_penalty()
{
	EXACTTRIGGER_INIT;

	self.use = penalty_use;
	if not(self.spawnflags & 1)
		self.touch = penalty_touch;

	if (!self.race_penalty_reason)
		self.race_penalty_reason = "missing a checkpoint";
	if (!self.race_penalty)
		self.race_penalty = 5;
}
