.float race_checkpoint; // player: next checkpoint that has to be reached
.float race_laptime;

.entity sprite;

float race_checkpoint_records[256];
string race_checkpoint_recordholders[256];

float race_highest_checkpoint;

void race_SendNextCheckpoint(entity e)
{
	float recordtime;
	string recordholder;
	float cp;

	if(clienttype(e) != CLIENTTYPE_REAL)
		return;

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

	msg_entity = e;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_RACE);
	WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_NEXT);
	WriteByte(MSG_ONE, cp); // checkpoint the player will be at next
	WriteShort(MSG_ONE, recordtime);
	WriteString(MSG_ONE, recordholder);
}

void race_SendTime(entity e, float cp, float t, float tvalid)
{
	t = floor(0.5 + 10 * t); // make integer

	if(tvalid)
	if(cp == 0) // finish line
	{
		float s;
		s = PlayerScore_Add(e, SP_RACE_FASTEST, 0);
		if(!s || t < s)
			PlayerScore_Add(e, SP_RACE_FASTEST, t - s);
		PlayerTeamScore_Add(e, SP_RACE_LAPS, ST_RACE_LAPS, 1);
	}

	float recordtime;
	string recordholder;

	if(tvalid)
	{
		recordtime = race_checkpoint_records[cp];
		recordholder = strcat1(race_checkpoint_recordholders[cp]); // make a tempstring copy, as we'll possibly strunzone it!
		if(recordholder == e.netname)
			recordholder = "";

		if(t < recordtime || recordtime == 0)
		{
			race_checkpoint_records[cp] = t;
			if(race_checkpoint_recordholders[cp])
				strunzone(race_checkpoint_recordholders[cp]);
			race_checkpoint_recordholders[cp] = strzone(e.netname);
			if(cp == 0)
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
				}
				else if(t < grecordtime)
				{
					if(grecordholder == "")
						bprint(e.netname, "^7 broke his all-time fastest lap record with ", mmsss(t), "\n");
					else
						bprint(e.netname, "^7 broke ", grecordholder, "^7's all-time fastest lap record with ", mmsss(t), "\n");
					db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/time"), ftos(t));
					db_put(ServerProgsDB, strcat(GetMapname(), "/racerecord/netname"), e.netname);
				}
				else
				{
					if(grecordholder == "")
						bprint(e.netname, "^7's new fastest lap could not break his all-time fastest lap record of ", mmsss(grecordtime), "\n");
					else
						bprint(e.netname, "^7's new fastest lap could not break ", grecordholder, "^7's all-time fastest lap record of ", mmsss(grecordtime), "\n");
				}
			}

			entity p;
			FOR_EACH_REALPLAYER(p)
				if(p.race_checkpoint == cp)
					race_SendNextCheckpoint(p);
		}
	}
	else
	{
		// dummies
		t = 0;
		recordtime = 0;
		recordholder = "";
	}

	if(clienttype(e) != CLIENTTYPE_REAL)
		return;

	msg_entity = e;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_RACE);
	WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_HIT);
	WriteByte(MSG_ONE, cp); // checkpoint the player now is at
	WriteShort(MSG_ONE, t); // time to that intermediate
	WriteShort(MSG_ONE, recordtime); // previously best time
	WriteString(MSG_ONE, recordholder); // record holder
}

void race_ClearTime(entity e)
{
	e.race_checkpoint = -1;
	e.race_laptime = 0;

	if(clienttype(e) != CLIENTTYPE_REAL)
		return;

	msg_entity = e;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_RACE);
	WriteByte(MSG_ONE, RACE_NET_CHECKPOINT_CLEAR); // next
}

void checkpoint_touch()
{
	if(other.classname != "player")
		return;

	if(other.race_checkpoint == -1 || other.race_checkpoint == self.cnt)
	{
		if(self.cnt == race_highest_checkpoint)
			other.race_checkpoint = 0;
		else
			other.race_checkpoint = self.cnt + 1;

		race_SendTime(other, self.cnt, time - other.race_laptime, !!other.race_laptime);

		if(!self.cnt) // finish line
			other.race_laptime = time;

		race_SendNextCheckpoint(other);
	}
	else if(other.race_checkpoint == self.cnt + 1)
	{
		// ignored
	}
	else if(other.race_checkpoint == 0 && self.cnt == race_highest_checkpoint)
	{
		// ignored
	}
	else
	{
		if(self.spawnflags & 4)
			Damage (other, self, self, 10000, DEATH_HURTTRIGGER, other.origin, '0 0 0');
	}
}

void checkpoint_use()
{
	other = activator;
	checkpoint_touch();
}

float race_waypointsprite_for_player(entity e)
{
	if(e.race_checkpoint == -1)
		return self.modelindex;
	else if(e.race_checkpoint == self.owner.cnt)
		return self.modelindex;
	else
		return FALSE;
}

void spawnfunc_trigger_race_checkpoint()
{
	vector o;
	if(!g_race)
	{
		remove(self);
		return;
	}
	InitTrigger();
	self.use = checkpoint_use;
	if not(self.spawnflags & 1)
		self.touch = checkpoint_touch;

	o = (self.absmin + self.absmax) * 0.5;
	tracebox(o, PL_MIN, PL_MAX, o - '0 0 1' * (o_z - self.absmin_z), MOVE_NORMAL, self);
	self.nearestwaypoint = waypoint_spawn(trace_endpos, trace_endpos, WAYPOINTFLAG_GENERATED);
	self.nearestwaypointtimeout = time + 1000000000;

	if(!self.message)
		self.message = "went backwards";

	if(self.cnt > race_highest_checkpoint)
		race_highest_checkpoint = self.cnt;

	if(self.cnt)
	{
		precache_model("models/sprites/race-checkpoint.sp2");
		WaypointSprite_SpawnFixed("race-checkpoint", o, self, sprite);
	}
	else
	{
		precache_model("models/sprites/race-finish.sp2");
		WaypointSprite_SpawnFixed("race-finish", o, self, sprite);
	}
	self.sprite.waypointsprite_for_player = race_waypointsprite_for_player;
}

void race_PreparePlayer()
{
	if(!g_race)
		return;
	race_ClearTime(self);
}

void spawnfunc_info_player_race (void)
{
	if(!g_race)
	{
		remove(self);
		return;
	}
	spawnfunc_info_player_deathmatch();
}
