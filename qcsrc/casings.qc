void CasingTouch (void)
{
	self.angles_x = 0;
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
}

void HitCasing (vector hitloc, float damage)
{
	self.flags = self.flags - (self.flags & FL_ONGROUND);

	self.velocity = normalize (self.origin - hitloc) * damage * 3 + '0 0 100';
	self.avelocity_x = random () * 500;
	self.avelocity_y = random () * 500;
}

void SpawnCasing (vector org, vector ang, vector vel, float ctype)
{
	casing = spawn ();
	casing.classname = "case";
	casing.movetype = MOVETYPE_BOUNCE;
	casing.solid = SOLID_CORPSE;
	casing.touch = CasingTouch;

	casing.effects = EF_LOWPRECISION;

	setmodel (casing, "models/casing.mdl");
	setorigin (casing, org);
	setsize (casing, '-3 -3 -1', '3 3 1');

	casing.health = 120;
	casing.takedamage = DAMAGE_YES;
	casing.damageforcescale = 5;
	casing.velocity = vel;
	casing.owner = self;
	casing.angles = vectoangles (ang);
	casing.avelocity_x = random () * 500;
	casing.avelocity_y = random () * 500;

	casing.event_hurt = HitCasing;
	casing.event_die = SUB_Remove;

	casing.skin = ctype;

	SUB_SetFade (casing, time + 16 + random () * 4);
}