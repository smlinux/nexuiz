
void Obituary (entity attacker, entity targ, float deathtype)
{
	local string s;
	if (targ.classname == "player" || targ.classname == "corpse")
	{
		s = targ.netname; 
		if (targ.classname == "corpse")
			s = "A corpse";
		if (targ == attacker)
		{
			if (deathtype == IT_LASER) {bprint(s);bprint(" was unable to resist the urge to self-immolate\n");}
			else if (deathtype == IT_GRENADE_LAUNCHER) {bprint(s);bprint(" detonated\n");}
			else if (deathtype == IT_ELECTRO) {bprint(s);bprint(" played with plasma\n");}
			else if (deathtype == IT_HAGAR) {bprint(s);bprint(" should have used a different weapon\n");}
			else if (deathtype == IT_ROCKET_LAUNCHER) {bprint(s);bprint(" exploded\n");}
			else {bprint(s);bprint(" competes for the darwin awards\n");}
			self.frags = self.frags - 1;
		}
		else if (attacker.classname == "player")
		{
			if (deathtype == IT_LASER) {bprint(s);bprint(" was a victim of laser surgeon ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_UZI) {bprint(s);bprint(" was gunned down by ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_SHOTGUN) {bprint(s);bprint(" was gunned down by ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_GRENADE_LAUNCHER) {bprint(s);bprint(" was blasted by ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_ELECTRO) {bprint(s);bprint(" bathed in plasma from ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_CRYLINK) {bprint(s);bprint(" was zapped by ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_NEX) {bprint(s);bprint(" sports a new hole from ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_HAGAR) {bprint(s);bprint(" was pummeled by ");bprint(attacker.netname);bprint("\n");}
			else if (deathtype == IT_ROCKET_LAUNCHER) {bprint(s);bprint(" was given a lesson in rocketry by ");bprint(attacker.netname);bprint("\n");}
			else {bprint(s);bprint(" was killed by ");bprint(attacker.netname);bprint("\n");}
			attacker.frags = attacker.frags + 1;
		}
		else
		{
			{bprint(s);bprint(" died\n");}
		}
	}
}

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local entity oldself;
	oldself = self;
	self = targ;
	if (attacker.items & IT_STRENGTH)
	{
		damage = damage * POWERUP_STRENGTH_DAMAGE;
		force = force * POWERUP_STRENGTH_FORCE;
	}
	if (targ.items & IT_INVINCIBLE)
		damage = damage * POWERUP_INVINCIBLE_TAKEDAMAGE;
	// apply push
	if (self.damageforcescale)
	{
		self.velocity = self.velocity + self.damageforcescale * force;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	// apply damage
	if (self.event_damage)
		self.event_damage (hitloc, damage, inflictor, attacker, deathtype);
	self = oldself;
}

void RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype)
{
	entity	targ;
	float	finaldmg;
	float	power;
	vector	blastorigin;
	vector	force;
	vector	m1;
	vector	m2;
	vector	nearest;
	vector	diff;

	blastorigin = (inflictor.origin + (inflictor.mins + inflictor.maxs) * 0.5);

	targ = findradius (blastorigin, rad);
	while (targ)
	{
		if (targ != inflictor)
			if (ignore != targ)
			{
				// LordHavoc: measure distance to nearest point on target (not origin)
				// (this guarentees 100% damage on a touch impact)
				nearest = blastorigin;
				m1 = targ.origin + targ.mins;
				m2 = targ.origin + targ.maxs;
				if (nearest_x < m1_x) nearest_x = m1_x;
				if (nearest_y < m1_y) nearest_y = m1_y;
				if (nearest_z < m1_z) nearest_z = m1_z;
				if (nearest_x > m2_x) nearest_x = m2_x;
				if (nearest_y > m2_y) nearest_y = m2_y;
				if (nearest_z > m2_z) nearest_z = m2_z;
				diff = nearest - blastorigin;
				// round up a little on the damage to ensure full damage on impacts
				// and turn the distance into a fraction of the radius
				power = 1 - ((vlen (diff) - 2) / rad);
				//bprint(" ");
				//bprint(ftos(power));
				if (power > 0)
				{
					if (power > 1)
						power = 1;
					finaldmg = coredamage * power + edgedamage * (1 - power);
					force = normalize(diff) * (finaldmg / coredamage) * forceintensity;
					if (targ == attacker)
						finaldmg = finaldmg * 0.6;	// Partial damage if the attacker hits himself
					if (finaldmg > 0)
						Damage (targ, inflictor, attacker, finaldmg, deathtype, inflictor.origin, force);
				}
			}
		targ = targ.chain;
	}
}

/*
entity	multi_ent;
float	multi_damage;
vector	multi_force;

void ClearMultiDamage (void)
{
	multi_ent = world;
	multi_damage = 0;
	multi_force = '0 0 0';
}

void ApplyMultiDamage (void)
{
	if (!multi_ent)
		return;

	Damage (self, multi_ent.origin, multi_ent, 0, multi_damage, multi_force);
}

void AddMultiDamage (entity hit, float damage, vector force)
{
	if (!hit)
		return;

	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		ClearMultiDamage ();
		multi_ent = hit;
	}
	multi_damage = multi_damage + damage;
	multi_force = multi_force + force;
}

void FireBullets (float shotcount, vector dir, vector spread, float deathtype)
{
	vector	direction;
	vector	source;
	vector	vel;
	vector	org;

	makevectors (self.v_angle);

	source = self.origin + v_forward * 10;	// FIXME
	source_x = self.absmin_z + self.size_z * 0.7;	// ??? whaddabout view_ofs

	// LordHavoc: better to use normal damage
	//ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom () * spread_x * v_right + crandom () * spread_y * v_up;

		traceline (source, source + direction * 2048, FALSE, self);
		if (trace_fraction != 1.0)
		{
			vel = normalize (direction + v_up * crandom () + v_right * crandom ());
			vel = vel + 2 * trace_plane_normal;
			vel = vel * 200;

			org = trace_endpos - direction * 4;

			if (!trace_ent.takedamage)
				te_gunshot (org);
			// LordHavoc: better to use normal damage
			//AddMultiDamage (trace_ent, 4, direction * 4);
			Damage (trace_ent, self, self, 4, deathtype, trace_endpos, direction * 4);
		}

		shotcount = shotcount + 1;
	}

	// LordHavoc: better to use normal damage
	//ApplyMultiDamage ();
}
*/
