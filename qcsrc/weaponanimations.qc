$frame fire fire2 idle run

void weapon_stand (void)
{
	if (self.attack_finished > time)
			self.weaponframe = $fire;
	else
	{
	if (self.movement_x || self.movement_y)
		self.weaponframe = $run;
		else	self.weaponframe = $idle;

		self.think = weapon_stand;
		self.nextthink = time + 0.02;
	}
}