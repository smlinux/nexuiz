void SpawnCasing (vector org, vector ang, vector vel, float ctype)
{
	casing = spawn ();
	casing.classname = "casing";
	casing.movetype = MOVETYPE_BOUNCE;
	casing.solid = SOLID_CORPSE;

	casing.effects = EF_LOWPRECISION;

	setmodel (casing, "models/casing.mdl");
	setorigin (casing, org);
	setsize (casing, '-1 -2 -1', '2 2 1');

	casing.velocity = vel;
	casing.owner = self;
	casing.angles = vectoangles (ang);
	casing.avelocity_x = random () * 500;
	casing.avelocity_y = random () * 500;

	casing.alpha = 1;
	
	if (ctype == 1)
		casing.skin = 2;
	else if (ctype == 2)
		casing.skin = 1;
	else
		casing.skin = 0;

	SUB_SetFade (casing, time + 16 + random () * 4);
}