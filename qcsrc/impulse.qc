
void dummyhurt (vector hitloc, float damage)
{
	te_blood (hitloc, '0 0 20', floor (damage * 0.5));
}

void dummydie (vector hitloc, float damage)
{
	vector	vel;
	
	te_bloodshower (self.origin + self.mins, self.origin + self.maxs, 600, 500);
	
	vel = normalize (self.origin - hitloc) * damage * 4;	// blow gibs away from impact point
	if (vel_z > 0)
		vel_z = vel_z * 2;	// more vertical
	Gib (vel);
	
	remove (self);
}

void CreateDummy (vector org)
{
	entity	dummy;
	
	dummy = spawn ();
	dummy.solid = SOLID_SLIDEBOX;
	dummy.movetype = MOVETYPE_FLY;
	dummy.classname = "corpse";
	dummy.takedamage = DAMAGE_YES;
	dummy.health = 100;
	setsize (dummy, PL_MIN, PL_MAX);
	setorigin (dummy, org);
	setmodel (dummy, "models/player/player.zym");
	
	dummy.event_hurt = dummyhurt;
	dummy.event_die = dummydie;
}

void ImpulseCommands (void)
{
	if (self.impulse >= 1 && self.impulse <= 9)
		W_SwitchWeapon (self.impulse);
		
	else if (self.impulse == 10)
		W_NextWeapon ();
	else if (self.impulse == 12)
		W_PreviousWeapon ();
	else if (self.impulse == 13)
	{
		makevectors (self.v_angle);
		CreateDummy (self.origin + self.view_ofs + v_forward * 64);
	}
		
	self.impulse = 0;
}