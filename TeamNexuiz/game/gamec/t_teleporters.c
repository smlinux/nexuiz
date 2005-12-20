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

/*void Teleport_Touch (void)
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
}*/
/*
void misc_teleporter_dest (void)			// Moved down
{
	info_teleport_destination();
}
*/
/*
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
*/

// TF Teleporters
entity s;
void() SUB_UseTargets;

void () play_teleport =
{
	local float v;
	local string tmpstr;

	v = (random () * 5);
	if ((v < 1))
	{
		tmpstr = "misc/teleport.wav";
	}
	else
	{
		if ((v < 2))
		{
			tmpstr = "misc/teleport.wav";
		}
		else
		{
			if ((v < 3))
			{
				tmpstr = "misc/teleport.wav";
			}
			else
			{
				if ((v < 4))
				{
					tmpstr = "misc/teleport.wav";
				}
				else
				{
					tmpstr = "misc/teleport.wav";
				}
			}
		}
	}
	sound (self, 2, tmpstr, 1, 1);
	remove (self);
};

void (vector org) spawn_tfog =
{
	s = spawn ();
	s.origin = org;
	s.nextthink = (time + 0.2);
	s.think = play_teleport;
	WriteByte (0, 23);
	WriteByte (0, 11);
	WriteCoord (0, org_x);
	WriteCoord (0, org_y);
	WriteCoord (0, org_z);
};

void () teleport_touch =
{
	local entity t;
	local entity te;
	local vector org;

	if (self.targetname)
	{
		if ((self.nextthink < time))
		{
			return;
		}
	}
	if ((self.spawnflags & 1))
	{
		if ((other.classname != "player"))
		{
			return;
		}
	}
	if (!Activated (self, other))
	{
		if ((self.else_goal != 0))
		{
			te = Findgoal (self.else_goal);
			if (te)
			{
				AttemptToActivate (te, other, self);
			}
		}
		return;
	}
	if (((other.health <= 0) || (other.solid != 3)))
	{
		return;
	}
	SUB_UseTargets ();
	spawn_tfog (other.origin);
	t = find (world, targetname, self.target);
	if (!t)
	{
		objerror ("couldn't find target");
	}
	makevectors (t.mangle);
	org = (t.origin + (32 * v_forward));
	spawn_tfog (org);
	spawn_tdeath (t.origin, other);
	if (!other.health)
	{
		other.origin = t.origin;
		other.velocity = ((v_forward * other.velocity_x) + (v_forward * other.velocity_y));
		return;
	}
	setorigin (other, t.origin);
	other.angles = t.mangle;
	if ((other.classname == "player"))
	{
		if (((other.weapon == 1)/* && other.hook_out*/))		// Hook out code needs replacement
		{
			sound (other, 1, "weapons/bounce2.wav", 1, 1);
//			other.on_hook = 0;
//			other.hook_out = 0;
//			other.fire_held_down = 0;
			other.weaponframe = 0;
			other.attack_finished = (time + 0.75);
		}
		other.fixangle = 1;
		other.teleport_time = (time + 0.7);
		if ((other.flags & 512))
		{
			other.flags = (other.flags - 512);
		}
		other.velocity = (v_forward * 300);
	}
	other.flags = (other.flags - (other.flags & 512));
};

void () teleport_use =
{
	self.nextthink = (time + 0.2);
	force_retouch = 2;
	self.think = SUB_Null;
};

void () info_teleport_destination =
{
	if ((CheckExistence () == 0))
	{
		dremove (self);
		return;
	}
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = (self.origin + '0 0 27');
	if (!self.targetname)
	{
		objerror ("no targetname");
	}
};

void () trigger_teleport =
{
	if (self.allowteams == "red")
	{
		self.team_no = 2;
		self.owned_by = 2;
	}
	if (self.allowteams == "blue")
	{
		self.owned_by = 1;
		self.team_no = 1;
	}

	local vector o;

	if ((CheckExistence () == 0))
	{
		dremove (self);
		return;
	}
	InitTrigger ();
	self.touch = teleport_touch;
	if (!self.target)
	{
		objerror ("no target");
	}
	self.use = teleport_use;
	if (!(self.spawnflags & 2))
	{
		precache_sound ("ambience/hum1.wav");
		o = ((self.mins + self.maxs) * 0.5);
		ambientsound (o, "ambience/hum1.wav", 0.5, 3);
	}
};

void misc_teleporter_dest (void)			// Moved from above
{
	info_teleport_destination();
}