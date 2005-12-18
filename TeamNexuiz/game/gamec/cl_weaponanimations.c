$frame fire fire2 idle run

// VorteX: static frame globals
float WFRAME_FIRE1 = 0;
float WFRAME_FIRE2 = 1;
float WFRAME_IDLE = 2;
float WFRAME_RUN = 3;

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
void weapon_freeze ()
{
	if (self.weaponentity)
		self.weaponentity.frame = WFRAME_IDLE;
}