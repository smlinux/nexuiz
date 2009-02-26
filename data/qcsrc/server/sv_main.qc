
void CreatureFrame (void)
{
	local entity oldself;
	local float dm;
	oldself = self;
	self = findfloat(world, iscreature, TRUE);
	while (self)
	{
		if (self.movetype != MOVETYPE_NOCLIP)
		{
			if (self.waterlevel)
			{
				if (!(self.flags & FL_INWATER))
				{
					self.flags |= FL_INWATER;
					self.dmgtime = 0;
				}
				if (self.waterlevel != 3)
				{
					if(self.air_finished < time + 9)
						PlayerSound(playersound_gasp, CHAN_PLAYER, VOICETYPE_PLAYERSOUND);
					self.air_finished = time + 12;
					self.dmg = 2;
				}
				else if (self.air_finished < time)
				{	// drown!
					if (!self.deadflag)
					if (self.pain_finished < time)
					{
						Damage (self, world, world, 5, DEATH_DROWN, self.origin, '0 0 0');
						self.pain_finished = time + 0.5;
					}
				}
				if (self.dmgtime < time)
				{
					self.dmgtime = time + 0.1;
					if (self.watertype == CONTENT_LAVA)
					{
						if (self.watersound_finished < time)
						{
							self.watersound_finished = time + 0.5;
							sound (self, CHAN_PLAYER, "player/lava.wav", VOL_BASE, ATTN_NORM);
						}
						Damage (self, world, world, 6 * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
					}
					else if (self.watertype == CONTENT_SLIME)
					{
						if (self.watersound_finished < time)
						{
							self.watersound_finished = time + 0.5;
							sound (self, CHAN_PLAYER, "player/slime.wav", VOL_BASE, ATTN_NORM);
						}
						Damage (self, world, world, 2 * self.waterlevel, DEATH_SLIME, self.origin, '0 0 0');
					}
				}
			}
			else
			{
				if (self.flags & FL_INWATER)
				{
					// play leave water sound
					self.flags &~= FL_INWATER;
					self.dmgtime = 0;
				}
				self.air_finished = time + 12;
				self.dmg = 2;
			}
			// check for falling damage
			if(!self.hook.state)
			{
				dm = vlen(self.oldvelocity) - vlen(self.velocity); // dm is now the velocity DECREASE. Velocity INCREASE should never cause a sound or any damage.
				if (self.deadflag)
					dm = (dm - cvar("g_balance_falldamage_deadminspeed")) * cvar("g_balance_falldamage_factor");
				else
					dm = min((dm - cvar("g_balance_falldamage_minspeed")) * cvar("g_balance_falldamage_factor"), cvar("g_balance_falldamage_maxdamage"));
				if (dm > 0)
				{
					Damage (self, world, world, dm, DEATH_FALL, self.origin, '0 0 0');
				}
				else if(vlen(self.velocity) > 100000 && cvar("developer"))
				{
					dprint(strcat(self.netname, " became too fast, please investigate: ", vtos(self.spawnorigin), "\n"));
					Damage (self, world, world, 50000, DEATH_SHOOTING_STAR, self.origin, '0 0 0');
				}
			}

			// play stupid sounds
			if (g_footsteps)
			if (!gameover)
			if (self.flags & FL_ONGROUND)
			if (vlen(self.velocity) > sv_maxspeed * 0.6)
			if (!self.deadflag)
			if (time < self.lastground + 0.2)
			{
				if((time > self.nextstep) || (time < (self.nextstep - 10.0)))
				{
					self.nextstep = time + 0.3 + random() * 0.1;
					trace_dphitq3surfaceflags = 0;
					tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
					/*
					if(trace_fraction == 1)
						dprint("nohit\n");
					else
						dprint(ftos(trace_dphitq3surfaceflags), "\n");
					*/
					if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
					{
						if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS)
							GlobalSound(globalsound_metalstep, CHAN_PLAYER, VOICETYPE_PLAYERSOUND);
						else
							GlobalSound(globalsound_step, CHAN_PLAYER, VOICETYPE_PLAYERSOUND);
					}
				}
			}
			self.oldvelocity = self.velocity;
		}
		self = findfloat(self, iscreature, TRUE);
	}
	self = oldself;
}


/*
=============
StartFrame

Called before each frame by the server
=============
*/
void RuneMatchGivePoints();
float RedirectionThink();
entity SelectSpawnPoint (float anypoint);
void StartFrame (void)
{
	remove = remove_unsafely; // not during spawning!

	dprint_load(); // load dprint status from cvar

	if(RedirectionThink())
		return;

	UncustomizeEntitiesRun();
	InitializeEntitiesRun();

	sv_gravity = cvar("sv_gravity");
	sv_maxairspeed = cvar("sv_maxairspeed");
	sv_maxspeed = cvar ("sv_maxspeed");
	sv_friction = cvar ("sv_friction");
	sv_accelerate = cvar ("sv_accelerate");
	sv_airaccelerate = cvar("sv_airaccelerate");
	sv_airaccel_sideways_friction = cvar("sv_airaccel_sideways_friction");
	sv_airaccel_qw = cvar("sv_airaccel_qw");

	sv_stopspeed = cvar ("sv_stopspeed");
	teamplay = cvar ("teamplay");
	skill = cvar("skill");

	Spawnqueue_Check();

	// if in warmup stage and limit for warmup is hit start match
	if (inWarmupStage
	    && 0 < g_warmup_limit
	    && time >= g_warmup_limit)
	{
		ReadyRestart();
		return;
	}

	CreatureFrame ();
	CheckRules_World ();

	AuditTeams();

	RuneMatchGivePoints();
	bot_serverframe();

	if(cvar("spawn_debugview"))
	{
		RandomSelection_Init();
		for(self = world; (self = find(self, classname, "player")); )
			RandomSelection_Add(self, 0, 1, 0);
		self = RandomSelection_chosen_ent;
		SelectSpawnPoint(0);
	}

	FOR_EACH_PLAYER(self)
		self.porto_forbidden = max(0, self.porto_forbidden - 1);
}

.vector originjitter;
.vector anglesjitter;
.string gametypefilter;
void SV_OnEntityPreSpawnFunction()
{
	if(self.gametypefilter != "")
	if not(isGametypeInFilter(game, teamplay, self.gametypefilter))
	{
		remove(self);
		return;
	}

	self.origin_x += (random() * 2 - 1) * self.originjitter_x;
	self.origin_y += (random() * 2 - 1) * self.originjitter_y;
	self.origin_z += (random() * 2 - 1) * self.originjitter_z;
	self.angles_x += (random() * 2 - 1) * self.anglesjitter_x;
	self.angles_y += (random() * 2 - 1) * self.anglesjitter_y;
	self.angles_z += (random() * 2 - 1) * self.anglesjitter_z;
}
