
void GibSplat (void)
{
	te_blood (self.origin + '0 0 1', '0 0 30', 8);
	
	remove (self);
}

void TossGib (string mdlname, vector org, vector v)
{
	entity		gib;
	vector		vel;
	
	// There has got to be a better way to do this...
	vel_x = v_x + (random () * 300 - 150);
	vel_y = v_y + (random () * 300 - 150);
	vel_z = v_z + (random () * 300 - 150);
	
	gib = spawn ();
	gib.classname = "gib";
	gib.movetype = MOVETYPE_BOUNCE;
	gib.solid = SOLID_CORPSE;
	
	setmodel (gib, mdlname);
	setsize (gib, '-8 -8 -8', '8 8 8');
	setorigin (gib, org);
	
	gib.health = 1;
	gib.takedamage = DAMAGE_YES;
	gib.event_die = GibSplat;
	gib.event_hurt = GibSplat;
	
	gib.velocity = vel;
	gib.avelocity = '300 300 300';
	gib.alpha = 1;

	SUB_SetFade (gib, time + 12 + random () * 4);
}

void Gib (vector vel)
{
	TossGib ("models/gibs/gib1.mdl", self.origin, vel);
	TossGib ("models/gibs/gib2.mdl", self.origin, vel);
	TossGib ("models/gibs/gib3.mdl", self.origin, vel);
	TossGib ("models/gibs/gib4.mdl", self.origin, vel);
	TossGib ("models/gibs/bloodyskull.md3", self.origin, vel);
	TossGib ("models/gibs/eye.md3", self.origin, vel);
}