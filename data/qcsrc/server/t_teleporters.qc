void trigger_teleport_use()
{
	if(teams_matter)
		self.team = activator.team;
}

#define TDEATHLOOP(o) \
	entity head; \
	vector deathmin; \
	vector deathmax; \
	float deathradius; \
	deathmin = (o) + player.mins; \
	deathmax = (o) + player.maxs; \
	if(telefragmin != telefragmax) \
	{ \
		if(deathmin_x > telefragmin_x) deathmin_x = telefragmin_x; \
		if(deathmin_y > telefragmin_y) deathmin_y = telefragmin_y; \
		if(deathmin_z > telefragmin_z) deathmin_z = telefragmin_z; \
		if(deathmax_x < telefragmax_x) deathmax_x = telefragmax_x; \
		if(deathmax_y < telefragmax_y) deathmax_y = telefragmax_y; \
		if(deathmax_z < telefragmax_z) deathmax_z = telefragmax_z; \
	} \
	deathradius = max(vlen(deathmin), vlen(deathmax)); \
	for(head = findradius(o, deathradius); head; head = head.chain) \
		if(head != player) \
			if(head.takedamage) \
				if(boxesoverlap(deathmin, deathmax, head.absmin, head.absmax))
	

float check_tdeath(entity player, vector org, vector telefragmin, vector telefragmax)
{
	TDEATHLOOP(org)
	{
		if ((player.classname == "player") && (player.health >= 1))
		{
			if(head.classname == "player")
				if(head.health >= 1)
					return 1;
		}
	}
	return 0;
}
float tdeath_hit;
void tdeath(entity player, entity teleporter, entity telefragger, vector telefragmin, vector telefragmax)
{
	TDEATHLOOP(player.origin)
	{
		if ((player.classname == "player") && (player.health >= 1))
		{
			if(head.classname == "player")
				if(head.health >= 1)
					++tdeath_hit;
			Damage (head, teleporter, telefragger, 10000, DEATH_TELEFRAG, head.origin, '0 0 0');
		}
		else if (telefragger.health < 1) // corpses gib
			Damage (head, teleporter, telefragger, 10000, DEATH_TELEFRAG, head.origin, '0 0 0');
		else // dead bodies and monsters gib themselves instead of telefragging
			Damage (telefragger, teleporter, telefragger, 10000, DEATH_TELEFRAG, telefragger.origin, '0 0 0');
	}
}

void spawn_tdeath(vector v0, entity e, vector v)
{
	tdeath(e, e, e, '0 0 0', '0 0 0');
}

.entity pusher;
#define TELEPORT_FLAG_SOUND 1
#define TELEPORT_FLAG_PARTICLES 2
#define TELEPORT_FLAG_TDEATH 4

#define TELEPORT_FLAGS_WARPZONE   0
#define TELEPORT_FLAGS_PORTAL     (TELEPORT_FLAG_SOUND | TELEPORT_FLAG_PARTICLES)
#define TELEPORT_FLAGS_TELEPORTER (TELEPORT_FLAG_SOUND | TELEPORT_FLAG_PARTICLES | TELEPORT_FLAG_TDEATH)
void TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity, vector telefragmin, vector telefragmax, float tflags)
{
	entity oldself;
	entity telefragger;
	vector from;

	if(teleporter.owner)
		telefragger = teleporter.owner;
	else
		telefragger = player;

	makevectors (to_angles);

	if(self.pushltime < time) // only show one teleport effect per teleporter per 0.2 seconds, for better fps
	{
		if(tflags & TELEPORT_FLAG_SOUND)
			sound (player, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
		if(tflags & TELEPORT_FLAG_PARTICLES)
		{
			pointparticles(particleeffectnum("teleport"), player.origin, '0 0 0', 1);
			pointparticles(particleeffectnum("teleport"), to + v_forward * 32, '0 0 0', 1);
		}
		self.pushltime = time + 0.2;
	}

	// Relocate the player
	// assuming to allows PL_MIN to PL_MAX box and some more
	from = player.origin;
	setorigin (player, to);
	player.oldorigin = to; // don't undo the teleport by unsticking
	player.angles = to_angles;
	player.fixangle = TRUE;
	player.velocity = to_velocity;
	BITXOR_ASSIGN(player.effects, EF_TELEPORT_BIT);

	UpdateCSQCProjectileAfterTeleport(player);

	if(player.classname == "player")
	{
		if(tflags & TELEPORT_FLAG_TDEATH)
			if(player.takedamage && player.deadflag == DEAD_NO && !g_race && !g_cts && cvar("g_telefrags"))
				tdeath(player, teleporter, telefragger, telefragmin, telefragmax);

		// player no longer is on ground
		player.flags &~= FL_ONGROUND;

		// reset tracking of oldvelocity for impact damage (sudden velocity changes)
		player.oldvelocity = player.velocity;

		// reset tracking of who pushed you into a hazard (for kill credit)
		if(teleporter.owner)
		{
			player.pusher = teleporter.owner;
			player.pushltime = time + cvar("g_maxpushtime");
		}
		else
		{
			player.pushltime = 0;
		}

		if(player.isbot)
			player.lastteleporttime = time;

		// stop player name display
		{
			oldself = self;
			self = player;
			ClearSelectedPlayer();
			self = oldself;
		}
	}
}

void Teleport_Touch (void)
{
	entity oldself, e;
	vector o;
	float p;

	if (other.health < 1)
		return;
	if not(other.flags & FL_CLIENT)	// FIXME: Make missiles firable through the teleport too
		return;

	if(self.team)
		if((self.spawnflags & 4 == 0) == (self.team != other.team))
			return;

	EXACTTRIGGER_TOUCH;

	makevectors(self.enemy.mangle);

	if(other.classname == "player")
		RemoveGrapplingHook(other);
	
	if(self.enemy)
	{
		e = self.enemy;
	}
	else
	{
		RandomSelection_Init();
		for(e = world; (e = find(e, targetname, self.target)); )
		{
			p = 1;
			if(cvar("g_telefrags_avoid"))
			{
				o = e.origin + '0 0 1' * (1 - other.mins_z - 24);
				if(check_tdeath(other, o, '0 0 0', '0 0 0'))
					p = 0;
			}
			if(e.cnt)
				RandomSelection_Add(e, 0, string_null, e.cnt, p);
			else
				RandomSelection_Add(e, 0, string_null, 1, p);
		}
		e = RandomSelection_chosen_ent;
	}

	if(!e)
	{
		sprint(other, "Teleport destination vanished. Sorry... please complain to the mapper.\n");
	}

	if(e.speed)
		if(vlen(other.velocity) > e.speed)
			other.velocity = normalize(other.velocity) * max(0, e.speed);
	if(cvar("g_teleport_maxspeed"))
		if(vlen(other.velocity) > cvar("g_teleport_maxspeed"))
			other.velocity = normalize(other.velocity) * max(0, cvar("g_teleport_maxspeed"));

	o = e.origin + '0 0 1' * (1 - other.mins_z - 24);
	TeleportPlayer(self, other, o, e.mangle, v_forward * vlen(other.velocity), '0 0 0', '0 0 0', TELEPORT_FLAGS_TELEPORTER);

	if(e.target)
	{
		oldself = self;
		activator = other;
		self = e;
		SUB_UseTargets();
		self = oldself;
	}
}

void spawnfunc_info_teleport_destination (void)
{
	self.classname = "info_teleport_destination";

	self.mangle = self.angles;
	self.angles = '0 0 0';

	//setorigin (self, self.origin + '0 0 27');	// To fix a mappers' habit as old as Quake
	setorigin (self, self.origin);

	IFTARGETED
	{
	}
	else
		objerror ("^3Teleport destination without a targetname");
}

void spawnfunc_misc_teleporter_dest (void)
{
	spawnfunc_info_teleport_destination();
}

void spawnfunc_target_teleporter (void)
{
	spawnfunc_info_teleport_destination();
}

void teleport_findtarget (void)
{
	entity e;
	float n;

	RandomSelection_Init();
	n = 0;
	for(e = world; (e = find(e, targetname, self.target)); )
	{
		++n;
		if(e.movetype == MOVETYPE_NONE)
			RandomSelection_Add(e, 0, string_null, 1, 1);
		if(e.classname != "info_teleport_destination")
			print("^3MAPPER ERROR: teleporter does target an invalid teleport destination entity. Angles will not work.\n");
	}
	if(RandomSelection_chosen_ent)
		waypoint_spawnforteleporter(self, RandomSelection_chosen_ent.origin, 0);

	if(n == 0)
	{
		// no dest!
		objerror ("Teleporter with nonexistant target");
		return;
	}
	else if(n == 1)
	{
		// exactly one dest - bots love that
		self.enemy = find(e, targetname, self.target);
		self.dest = self.enemy.origin;
	}
	else
	{
		// have to use random selection every single time
		self.enemy = world;
	}

	// now enable touch
	self.touch = Teleport_Touch;
}

void spawnfunc_trigger_teleport (void)
{
	self.angles = '0 0 0';

	EXACTTRIGGER_INIT;

	self.use = trigger_teleport_use;

	// this must be called to spawn the teleport waypoints for bots
	InitializeEntity(self, teleport_findtarget, INITPRIO_FINDTARGET);

	if (!self.target)
	{
		objerror ("Teleporter with no target");
		return;
	}
}

void WarpZone_PostTeleportPlayer_Callback(entity pl)
{
	UpdateCSQCProjectileAfterTeleport(pl);
	if(pl.classname == "player")
	{
		// reset tracking of oldvelocity for impact damage (sudden velocity changes)
		pl.oldvelocity = pl.velocity;
	}
}
