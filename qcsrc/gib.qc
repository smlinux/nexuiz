
void GibDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	te_blood (hitloc, force, damage);
	self.health = self.health - damage;
	if (self.health <= -300)
	{
		self.event_damage = SUB_Null;
		SUB_VanishOrRemove (self);
	}
}

// changes by LordHavoc on 03/30/04
// TossGib now takes a gib entity so it can be used for tossing heads
// gib.velocity now uses randomvec() instead of a bunch of manual random calls
// merged Gib() into PlayerGib()
void TossGib (entity gib, string mdlname, vector org, vector v)
{
	if (gib == world)
	{
		gib = spawn ();
		gib.norespawn = TRUE;
	}
	gib.classname = "gib";
	gib.movetype = MOVETYPE_BOUNCE;
	gib.solid = SOLID_CORPSE;

	setmodel (gib, mdlname);
	setsize (gib, '-8 -8 -8', '8 8 8');
	setorigin (gib, org);

	gib.health = -1;
	gib.takedamage = DAMAGE_YES;
	gib.damageforcescale = 3.5;
	gib.event_damage = GibDamage;

	gib.velocity = v + randomvec() * 250;
	gib.avelocity = randomvec() * 300;

	SUB_SetFade (gib, time + 12 + random () * 4);
}
