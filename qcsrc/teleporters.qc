
void Teleport_Touch (void)
{
	entity	dest;
	
	if (other.health < 1)
		return;
	if (other.classname != "player")	// FIXME: Make missiles firable through the teleport too
		return;

	// Make teleport effect where the player left
	sound (other, CHAN_ITEM, "misc/Teleport.wav", 1, ATTN_NORM);
	te_teleport (other.origin);
	
	dest = find (world, targetname, self.target);
	if (!dest)
		objerror ("Teleporter with nonexistant target");

	// Make teleport effect where the player arrived
	sound (other, CHAN_ITEM, "misc/Teleport.wav", 1, ATTN_NORM);
	makevectors (dest.mangle);
	te_teleport (dest.origin + v_forward * 32);

	// Relocate the player
	setorigin (other, dest.origin);
	other.angles = dest.mangle;
	other.fixangle = TRUE;
	
	other.velocity = '0 0 0';
	
	other.flags = other.flags - (other.flags & FL_ONGROUND);
}

void info_teleport_destination (void)
{
	self.mangle = self.angles;
	self.angles = '0 0 0';

	setorigin (self, self.origin + '0 0 27');	// To fix a mappers' habit as old as Quake

	if (!self.targetname)
		objerror ("Teleport destination without a targetname");
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