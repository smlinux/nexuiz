
void PlayerHurt (vector hitloc, float damage)
{
	te_blood (hitloc, '0 0 20', floor (damage / 2));
}

void PlayerDie (void)
{
	self.avelocity = '0 0 0';
	self.movetype = MOVETYPE_TOSS;
	self.weaponmodel = "";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.death_time = time + 1;
	self.dead_angles = self.angles;
	self.dead_angles_x = 0;
	self.deadflag = DEAD_DEAD;
}