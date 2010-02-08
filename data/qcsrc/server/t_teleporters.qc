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

	n = 0;
	for(e = world; (e = find(e, targetname, self.target)); )
	{
		++n;
		if(e.movetype == MOVETYPE_NONE)
			waypoint_spawnforteleporter(self, e.origin, 0);
		if(e.classname != "info_teleport_destination")
			print("^3MAPPER ERROR: teleporter does target an invalid teleport destination entity. Angles will not work.\n");
	}

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


// the transform
.vector warpzone_origin, warpzone_angles;
.vector warpzone_forward;
.vector warpzone_transform;

void warpzone_updatetransform()
{
	// 1. update this, and the enemy, warp zone
	self.warpzone_origin = self.aiment.origin;
	self.warpzone_angles = self.aiment.angles;
	self.enemy.warpzone_origin = self.enemy.aiment.origin;
	self.enemy.warpzone_angles = self.enemy.aiment.angles;

	// 2. combine the angle transforms
	//    current forward must be turned into previous backward
	self.warpzone_transform = AnglesTransform_Divide(AnglesTransform_TurnDirection(self.enemy.warpzone_angles), self.warpzone_angles);

	// 3. store off a saved forward vector for plane hit decisions
	fixedmakevectors(self.warpzone_angles);
	self.warpzone_forward = v_forward;
}

float warpzone_teleport(entity player)
{
	vector o0, a0, v0, o1, a1, v1;

	o0 = player.origin;
	v0 = player.velocity;
	a0 = player.angles;

	if((o0 - self.warpzone_origin) * self.warpzone_forward >= 0) // wrong side of the portal
		return 2;
		// no failure, we simply don't want to teleport yet; TODO in
		// this situation we may want to create a temporary clone
		// entity of the player to fix graphics glitch

	o1 = AnglesTransform_Apply(self.warpzone_transform, o0 - self.warpzone_origin) + self.enemy.warpzone_origin;
	v1 = AnglesTransform_Apply(self.warpzone_transform, v0);
	if(player.classname == "player")
		a1 = Portal_ApplyTransformToPlayerAngle(self.warpzone_transform, player.v_angle);
	else
		a1 = AnglesTransform_Multiply(self.warpzone_transform, a0);

	// put him inside solid
	tracebox(o1, player.mins, player.maxs, o1, MOVE_NOMONSTERS, player);
	if(trace_startsolid)
	{
		print("in solid\n");
		return 0; // TODO nudge out of solid here!
	}

	if((o1 - self.enemy.warpzone_origin) * self.enemy.warpzone_forward <= 0) // wrong side of the portal post-teleport
	{
		print("inconsistent warp zones or evil roundoff error\n");
		return 0;
	}

	//print(sprintf("warpzone: %f %f %f -> %f %f %f\n", o0_x, o0_y, o0_z, o1_x, o1_y, o1_z));

	//o1 = trace_endpos;
	TeleportPlayer(self, other, o1, a1, v1, '0 0 0', '0 0 0', TELEPORT_FLAGS_WARPZONE);

	return 1;
}

void warpzone_touch (void)
{
	entity oldself, e;

	if (other.health < 1)
		return;

	if(self.team)
		if((self.spawnflags & 4 == 0) == (self.team != other.team))
			return;

	EXACTTRIGGER_TOUCH;

	e = self.enemy;
	if(warpzone_teleport(other))
	{
	}
	else
	{
		dprint("WARPZONE FAIL AHAHAHAHAH))\n");
	}

	if(self.aiment.target)
	{
		oldself = self;
		activator = other;
		self = self.aiment;
		SUB_UseTargets();
		self = oldself;
	}
}
void warpzone_findtarget (void)
{
	if(self.target == "")
	{
		objerror("Warp zone with no target");
		return;
	}
	self.enemy = find(world, targetname, self.target);
	if(self.enemy == world)
	{
		objerror("Warp zone with nonexisting target");
		return;
	}

	if(self.killtarget == "")
	{
		objerror("Warp zone with no killtarget");
		return;
	}
	self.aiment = find(world, targetname, self.killtarget);
	if(self.aiment == world)
	{
		objerror("Warp zone with nonexisting killtarget");
		return;
	}

	// now enable touch
	self.touch = warpzone_touch;
}

void spawnfunc_trigger_warpzone(void)
{
	// warp zone entities must have:
	// "killtarget" pointing to a target_position with a direction arrow
	//              that points AWAY from the warp zone, and that is inside
	//              the warp zone trigger
	// "target"     pointing to an identical warp zone at another place in
	//              the map, with another killtarget to designate its
	//              orientation
	
	EXACTTRIGGER_INIT;

	self.use = trigger_teleport_use; // set team
	InitializeEntity(self, warpzone_findtarget, INITPRIO_FINDTARGET);
	InitializeEntity(self, warpzone_updatetransform, INITPRIO_LAST);
}
