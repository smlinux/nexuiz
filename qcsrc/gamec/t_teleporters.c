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
	{
		Damage (other, self, self.owner, 10000, WEP_TELEPORTER, other.origin,
'0 0 0');
	}
	else if (other.health < 1) // corpses gib
		Damage (other, self, self.owner, 10000, 0, other.origin, '0 0 0');
	else // dead bodies and monsters gib themselves instead of telefragging
		Damage (self.owner, self, other, 10000, 0, self.owner.origin, '0 0 0');
};

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
	death.think = SUB_Remove;
	death.owner = death_owner;

	force_retouch = 2;		// make sure even still objects get hit
};

void Teleport_Touch (void)
{
	if (other.health < 1)
		return;
	if (other.classname != "player")	// FIXME: Make missiles firable through the teleport too
		return;

	// Make teleport effect where the player left
	sound (other, CHAN_ITEM, "misc/teleport.wav", 1, ATTN_NORM);
	te_teleport (other.origin);
	
	dest = find (world, targetname, self.target);
	if (!dest)
		objerror ("Teleporter with nonexistant target");

	// Make teleport effect where the player arrived
	sound (other, CHAN_ITEM, "misc/teleport.wav", 1, ATTN_NORM);
	makevectors (dest.mangle);
	te_teleport (dest.origin + v_forward * 32);

	spawn_tdeath(dest.origin, other, other.origin);

	// Relocate the player
	//setorigin (other, dest.origin);
	setorigin (other, dest.origin + '0 0 1' * (1 - other.mins_z - 24));
	other.angles = dest.mangle;
	other.fixangle = TRUE;
	
	other.velocity = '0 0 0';
	
	other.flags = other.flags - (other.flags & FL_ONGROUND);
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

void trigger_teleport (void)
{
	self.angles = '0 0 0';

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	
	setmodel (self, self.model);
	
	self.model = "";
	self.modelindex = 0;
	
	self.touch = Teleport_Touch;
	
	if (!self.target)
		objerror ("Teleporter with no target");
}