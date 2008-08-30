void Teleport_Touch (void)
{
	entity head;
	entity oldself;

	if (other.health < 1)
		return;
	if (!other.flags & FL_CLIENT)	// FIXME: Make missiles firable through the teleport too
		return;

	EXACTTRIGGER_TOUCH;

	sound (other, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("teleport"), other.origin, '0 0 0', 1);

	/*
	// Make teleport effect where the player left
	sound (self, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("teleport"), other.origin, '0 0 0', 1);

	// Make teleport effect where the player arrived
	sound (self.enemy, CHAN_TRIGGER, "misc/teleport.wav", VOL_BASE, ATTN_NORM);
	*/

	makevectors (self.enemy.mangle);
	pointparticles(particleeffectnum("teleport"), self.enemy.origin + v_forward * 32, '0 0 0', 1);

	// Relocate the player
	setorigin (other, self.enemy.origin + '0 0 1' * (1 - other.mins_z - 24));
	other.angles = self.enemy.mangle;
	other.fixangle = TRUE;
	other.velocity = v_forward * vlen(other.velocity);
	RemoveGrapplingHook(other);

	// Kill anyone else in the teleporter box (NO MORE TDEATH)
	if(other.takedamage && !g_race)
	{
		vector deathmin;
		vector deathmax;
		float deathradius;
		deathmin = other.absmin;
		deathmax = other.absmax;
		deathradius = max(vlen(deathmin), vlen(deathmax));
		for(head = findradius(other.origin, deathradius); head; head = head.chain)
			if(head != other)
				if(head.takedamage)
					if(boxesoverlap(deathmin, deathmax, head.absmin, head.absmax))
					{
						if ((other.classname == "player") && (other.health >= 1))
							Damage (head, self, other, 10000, DEATH_TELEFRAG, head.origin, '0 0 0');
						else if (other.health < 1) // corpses gib
							Damage (head, self, other, 10000, DEATH_TELEFRAG, head.origin, '0 0 0');
						else // dead bodies and monsters gib themselves instead of telefragging
							Damage (other, self, other, 10000, DEATH_TELEFRAG, other.origin, '0 0 0');
					}
	}

	// hide myself a tic
	other.effects = other.effects | EF_NODRAW;
	if (other.weaponentity) // misuse FL_FLY to avoid EF_NODRAW on viewmodel
		other.weaponentity.flags = other.weaponentity.flags | FL_FLY;
	other.teleport_time = time + cvar("sys_ticrate");

	other.flags = other.flags - (other.flags & FL_ONGROUND);
	// reset tracking of oldvelocity for impact damage (sudden velocity changes)
	other.oldvelocity = other.velocity;
	// reset tracking of who pushed you into a hazard (for kill credit)
	other.pushltime = 0;

	// stop player name display
	{
		oldself = self;
		self = other;
		ClearSelectedPlayer();
		self = oldself;
	}

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
		remove(self);
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
		objerror ("Teleporter with no target");
}
