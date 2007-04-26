
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
					//if (self.watertype == CONTENT_LAVA)
					//	sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
					//if (self.watertype == CONTENT_WATER)
					//	sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
					//if (self.watertype == CONTENT_SLIME)
					//	sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
					self.flags = self.flags + FL_INWATER;
					self.dmgtime = 0;
				}
				if (self.waterlevel != 3)
				{
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
							sound (self, CHAN_BODY, "player/lava.wav", 1, ATTN_NORM);
						}
						Damage (self, world, world, 6 * self.waterlevel, DEATH_LAVA, self.origin, '0 0 0');
					}
					else if (self.watertype == CONTENT_SLIME)
					{
						if (self.watersound_finished < time)
						{
							self.watersound_finished = time + 0.5;
							sound (self, CHAN_BODY, "player/slime.wav", 1, ATTN_NORM);
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
					self.flags = self.flags - FL_INWATER;
					self.dmgtime = 0;
				}
				self.air_finished = time + 12;
				self.dmg = 2;
			}
			// check for falling damage
			if(!self.hook.state)
			{
				dm = vlen(self.oldvelocity) - vlen(self.velocity); // dm is now the velocity DECREASE. Velocity INCREASE should never cause a sound.
				if (self.deadflag)
					dm = (dm - cvar("g_balance_falldamage_deadminspeed")) * cvar("g_balance_falldamage_factor");
				else
				{
					if (self.oldvelocity_z < self.velocity_z - 160)
					{
						local float soundrandom;
						soundrandom = random() * 4;
						if (soundrandom < 1)
							sound (self, CHAN_BODY, "misc/hitground1.wav", 1, ATTN_NORM);
						else if (soundrandom < 2)
							sound (self, CHAN_BODY, "misc/hitground2.wav", 1, ATTN_NORM);
						else if (soundrandom < 3)
							sound (self, CHAN_BODY, "misc/hitground3.wav", 1, ATTN_NORM);
						else if (soundrandom < 4)
							sound (self, CHAN_BODY, "misc/hitground4.wav", 1, ATTN_NORM);
						self.nextstep = time + 0.3 + random() * 0.1;
					}
					dm = min((dm - cvar("g_balance_falldamage_minspeed")) * cvar("g_balance_falldamage_factor"), cvar("g_balance_falldamage_maxdamage"));
				}
				if (dm > 0)
					Damage (self, world, world, dm, DEATH_FALL, self.origin, '0 0 0');
				else if(vlen(self.velocity) > 100000 && cvar("developer"))
				{
					dprint(strcat(self.netname, " became too fast, please investigate: ", vtos(self.spawnorigin), "\n"));
					Damage (self, world, world, 50000, DEATH_SHOOTING_STAR, self.origin, '0 0 0');
				}
			}

			// play stupid sounds
			if (cvar("g_footsteps"))
			if (!gameover)
			if (self.flags & FL_ONGROUND)
			if (vlen(self.velocity) > sv_maxspeed * 0.6)
			if (!self.deadflag)
			{
				if((time > self.nextstep) || (time < (self.nextstep - 10.0)))
				{
					local float steprandom;
					self.nextstep = time + 0.3 + random() * 0.1;
					steprandom = random() * 6;
					if (steprandom < 1)
						sound (self, CHAN_BODY, "misc/footstep01.wav", 1, ATTN_NORM);
					else if (steprandom < 2)
						sound (self, CHAN_BODY, "misc/footstep02.wav", 1, ATTN_NORM);
					else if (steprandom < 3)
						sound (self, CHAN_BODY, "misc/footstep03.wav", 1, ATTN_NORM);
					else if (steprandom < 4)
						sound (self, CHAN_BODY, "misc/footstep04.wav", 1, ATTN_NORM);
					else if (steprandom < 5)
						sound (self, CHAN_BODY, "misc/footstep05.wav", 1, ATTN_NORM);
					else if (steprandom <= 6)
						sound (self, CHAN_BODY, "misc/footstep06.wav", 1, ATTN_NORM);
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
void StartFrame (void)
{
	if(RedirectionThink())
		return;

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

	CreatureFrame ();
	CheckRules_World ();

	AuditTeams();

	RuneMatchGivePoints();
	bot_serverframe();
}
