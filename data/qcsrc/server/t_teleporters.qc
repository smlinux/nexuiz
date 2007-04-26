void Damage (entity targ, entity inflictor, entity attacker, float
damage, float deathtype, vector hitloc, vector force);

void() tdeath_touch =
{
	if (other == self.owner)
		return;
	// so teleporting shots etc can't telefrag
	if (!self.owner.takedamage)
		return;
	if (!other.takedamage)
		return;

	if ((self.owner.classname == "player") && (self.owner.health >= 1))
		Damage (other, self, self.owner, 10000, DEATH_TELEFRAG, other.origin, '0 0 0');
	else if (other.health < 1) // corpses gib
		Damage (other, self, self.owner, 10000, DEATH_TELEFRAG, other.origin, '0 0 0');
	else // dead bodies and monsters gib themselves instead of telefragging
		Damage (self.owner, self, self.owner, 10000, DEATH_TELEFRAG, self.owner.origin, '0 0 0');
};

void tdeath_remove()
{
	if (self.owner)
	{
		self.owner.effects = self.owner.effects - (self.owner.effects & EF_NODRAW);
		if (self.owner.weaponentity)
			self.owner.weaponentity.flags = self.owner.weaponentity.flags - (self.owner.weaponentity.flags & FL_FLY);
	}
	remove(self);
}

// org2 is where they will return to if the teleport fails
void(vector org, entity death_owner, vector org2) spawn_tdeath =
{
	local entity death;

	death = spawn();
//	death.classname = "teledeath";
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	death.dest2 = org2;
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.nextthink = time + 0.2;
	death.think = tdeath_remove;
	death.owner = death_owner;

	// hide entity to avoid "ghosts" between teleporter and destination caused by clientside interpolation
	death.owner.effects = death.owner.effects | EF_NODRAW;
	if (death.owner.weaponentity) // misuse FL_FLY to avoid EF_NODRAW on viewmodel
		death.owner.weaponentity.flags = death.owner.weaponentity.flags | FL_FLY;

	force_retouch = 2;		// make sure even still objects get hit
};

void Teleport_Touch (void)
{
	entity head;

	if (other.health < 1)
		return;
	if (!other.flags & FL_CLIENT)	// FIXME: Make missiles firable through the teleport too
		return;

	// Make teleport effect where the player left
	sound (other, CHAN_ITEM, "misc/teleport.wav", 1, ATTN_NORM);
	te_teleport (other.origin);

	// Make teleport effect where the player arrived
	sound (other, CHAN_ITEM, "misc/teleport.wav", 1, ATTN_NORM);
	makevectors (self.enemy.mangle);
	te_teleport (self.enemy.origin + v_forward * 32);

	// Relocate the player
	setorigin (other, self.enemy.origin + '0 0 1' * (1 - other.mins_z - 24));
	other.angles = self.enemy.mangle;
	other.fixangle = TRUE;
	other.velocity = v_forward * vlen(other.velocity);

	// Kill anyone else in the teleporter box (NO MORE TDEATH)
	if(other.takedamage)
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

	// hide myself for 0.2 seconds
	other.effects = other.effects | EF_NODRAW;
	if (other.weaponentity) // misuse FL_FLY to avoid EF_NODRAW on viewmodel
		other.weaponentity.flags = other.weaponentity.flags | FL_FLY;
	other.teleport_time = time + 0.2;

	other.flags = other.flags - (other.flags & FL_ONGROUND);
	// reset tracking of oldvelocity for impact damage (sudden velocity changes)
	other.oldvelocity = other.velocity;
	// reset tracking of who pushed you into a hazard (for kill credit)
	other.pushltime = 0;

	// stop player name display
	{
		entity oldself;
		oldself = self;
		self = other;
		ClearSelectedPlayer();
		self = oldself;
	}
}

void info_teleport_destination (void)
{
	self.mangle = self.angles;
	self.angles = '0 0 0';

	//setorigin (self, self.origin + '0 0 27');	// To fix a mappers' habit as old as Quake
	setorigin (self, self.origin);

	if (!self.targetname)
		objerror ("Teleport destination without a targetname");
}

void misc_teleporter_dest (void)
{
	info_teleport_destination();
}

void target_teleporter (void)
{
	info_teleport_destination();
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

void trigger_teleport (void)
{
	self.angles = '0 0 0';

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;

	setmodel (self, self.model); // no precision needed

	self.model = "";
	self.modelindex = 0;

	self.think = teleport_findtarget;
	self.nextthink = time + 0.2;

	if (!self.target)
		objerror ("Teleporter with no target");
}
