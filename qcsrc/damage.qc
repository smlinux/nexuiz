
void Obituary (entity attacker, entity targ, float deathtype)
{
	if (targ.classname == "player" || targ.classname == "corpse")
	{
		if (targ.classname == "corpse")
			bprint ("A corpse");
		else
			bprint (targ.netname);
		bprint (" was killed by ");
		bprint (attacker.netname);
		bprint ("\n");
	}
}

void Damage (entity attacker, vector hitloc, entity targ, float deathtype, float damage)
{
	entity	oldself;
	
	if (!targ.takedamage)
		return;
		
	targ.health = targ.health - damage;
	
	oldself = self;
	self = targ;
	
	if (targ.health <= 0)
	{
		Obituary (attacker, targ, deathtype);
		if (targ.event_die)
			targ.event_die (hitloc, damage);
		//return;	// self = oldself;return;
	}
	else if (targ.event_hurt)
		targ.event_hurt (hitloc, damage);
	
	self = oldself;
}

void RadiusDamage (entity attacker, entity inflictor, float deathtype, float damage)
{
	entity	targ;
	
	targ = findradius (inflictor.origin, damage);
	while (targ)
	{
		Damage (attacker, inflictor.origin, targ, deathtype, damage);
		targ = targ.chain;
	}
}

entity	multi_ent;
float	multi_damage;

void ClearMultiDamage (void)
{
	multi_ent = world;
	multi_damage = 0;
}

void ApplyMultiDamage (void)
{
	if (!multi_ent)
		return;

	Damage (self, multi_ent.origin, multi_ent, 0, multi_damage);
}

void AddMultiDamage (entity hit, float damage)
{
	if (!hit)
		return;
		
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
}

float crandom (void)	// -1.0 to 1.0
{
	return 2 * (random () - 0.5);
}

void FireBullets (float shotcount, vector dir, vector spread)
{
	vector	direction;
	vector	source;
	vector	vel;
	vector	org;
	
	makevectors (self.v_angle);
	
	source = self.origin + v_forward * 10;	// FIXME
	source_x = self.absmin_z + self.size_z * 0.7;	// ??? whaddabout view_ofs
	
	ClearMultiDamage ();
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
			
			if (trace_ent.takedamage)
			{
				//te_blood (
				AddMultiDamage (trace_ent, 4);
			}
			else
				te_gunshot (org);
		}
		
		shotcount = shotcount + 1;
	}
	
	ApplyMultiDamage ();
}