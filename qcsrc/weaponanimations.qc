$frame fire fire2 idle run

// changes by LordHavoc on 03/30/04
// cleaned up code formatting a bit
// renamed to weapon_anim
void weapon_anim ()
{
	if (self.attack_finished > time)
		self.weaponframe = $fire;
	else if (self.movement_x || self.movement_y)
		self.weaponframe = $run;
	else
		self.weaponframe = $idle;
}