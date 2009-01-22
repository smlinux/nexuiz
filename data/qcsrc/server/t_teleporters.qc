void tdeath(entity player, entity teleporter, entity telefragger, vector telefragmin, vector telefragmax)
{
	entity head;
	vector deathmin;
	vector deathmax;
	float deathradius;
	deathmin = player.absmin;
	deathmax = player.absmax;
	if(telefragmin != telefragmax)
	{
		if(deathmin_x > telefragmin_x) deathmin_x = telefragmin_x;
		if(deathmin_y > telefragmin_y) deathmin_y = telefragmin_y;
		if(deathmin_z > telefragmin_z) deathmin_z = telefragmin_z;
		if(deathmax_x < telefragmax_x) deathmax_x = telefragmax_x;
		if(deathmax_y < telefragmax_y) deathmax_y = telefragmax_y;
		if(deathmax_z < telefragmax_z) deathmax_z = telefragmax_z;
	}
	deathradius = max(vlen(deathmin), vlen(deathmax));
	for(head = findradius(player.origin, deathradius); head; head = head.chain)
		if(head != player)
			if(head.takedamage)
				if(boxesoverlap(deathmin, deathmax, head.absmin, head.absmax))
				{
					if ((player.classname == "player") && (player.health >= 1))
						Damage (head, teleporter, telefragger, 10000, DEATH_TELEFRAG, head.origin, '0 0 0');
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
void TeleportPlayer(entity teleporter, entity player, vector to, vector to_angles, vector to_velocity, vector telefragmin, vector telefragmax)
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
		sound (player, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("teleport"), player.origin, '0 0 0', 1);
		pointparticles(particleeffectnum("teleport"), to + v_forward * 32, '0 0 0', 1);
		self.pushltime = time + 0.2;
	}

	// Relocate the player
	// assuming to allows PL_MIN to PL_MAX box and some more
	from = player.origin;
	setorigin (player, to);
	player.angles = to_angles;
	player.fixangle = TRUE;
	player.velocity = to_velocity;

	if(player.classname == "player")
	{
		if(player.takedamage && player.deadflag == DEAD_NO && !g_race)
			tdeath(player, teleporter, telefragger, telefragmin, telefragmax);

		// hide myself a tic
		player.effects = player.effects | EF_NODRAW;
		if (player.weaponentity) // misuse FL_FLY to avoid EF_NODRAW on viewmodel
			player.weaponentity.flags = player.weaponentity.flags | FL_FLY;
		player.teleport_time = time + cvar("sys_ticrate");

		// player no longer is on ground
		player.flags = player.flags - (player.flags & FL_ONGROUND);

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
	entity oldself;

	if (other.health < 1)
		return;
	if (!other.flags & FL_CLIENT)	// FIXME: Make missiles firable through the teleport too
		return;

	EXACTTRIGGER_TOUCH;

	makevectors(self.enemy.mangle);

	if(other.classname == "player")
		RemoveGrapplingHook(other);

	TeleportPlayer(self, other, self.enemy.origin + '0 0 1' * (1 - other.mins_z - 24), self.enemy.mangle, v_forward * vlen(other.velocity), '0 0 0', '0 0 0');

	if(self.enemy.target)
	{
		oldself = self;
		activator = other;
		self = self.enemy;
		SUB_UseTargets();
		self = oldself;
	}
}

void spawnfunc_info_teleport_destination (void)
{
	self.mangle = self.angles;
	self.angles = '0 0 0';

	//setorigin (self, self.origin + '0 0 27');	// To fix a mappers' habit as old as Quake
	setorigin (self, self.origin);

	IFTARGETED
	{
	}
	else
		objerror ("Teleport destination without a targetname");
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
	// now enable touch
	self.touch = Teleport_Touch;

	self.enemy = find (world, targetname, self.target);
	if (!self.enemy)
	{
		objerror ("Teleporter with nonexistant target");
		return;
	}

	self.dest = self.enemy.origin;
	waypoint_spawnforteleporter(self, self.dest, 0);
}

void spawnfunc_trigger_teleport (void)
{
	self.angles = '0 0 0';

	EXACTTRIGGER_INIT;

	// this must be called to spawn the teleport waypoints for bots
	InitializeEntity(self, teleport_findtarget, INITPRIO_FINDTARGET);

	if (!self.target)
	{
		objerror ("Teleporter with no target");
		return;
	}
}
