
float checkrules_firstblood;
void Obituary (entity attacker, entity targ, float deathtype)
{
	string	s;

	if (targ.classname == "player" || targ.classname == "corpse")
	{
		if (targ.classname == "corpse")
			s = "A corpse";
		else
			s = targ.netname;

		if (targ == attacker)
		{
			if (deathtype == IT_GRENADE_LAUNCHER)
				bprint ("^1",s, " detonated\n");
			else if (deathtype == IT_ELECTRO)
				bprint ("^1",s, " played with plasma\n");
			else if (deathtype == IT_ROCKET_LAUNCHER)
				bprint ("^1",s, " exploded\n");
			else if (deathtype == DEATH_KILL)
				bprint ("^1",s, " couldn't take it anymore\n");
			else
				bprint ("^1",s, " couldn't resist the urge to self immolate\n");
			targ.frags = targ.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s," ended it all with a ",ftos(targ.killcount)," kill spree\n");
		}
		else if (teamplay && attacker.team == targ.team)
		{
			bprint ("^1", attacker.netname, " mows down a teammate\n");
			attacker.frags = attacker.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"'s ",ftos(targ.killcount)," kill spree was endeded by a teammate!\n");
			if (attacker.killcount > 2)
				bprint ("^1",attacker.netname," ended a ",ftos(attacker.killcount)," kill spree by killing a teammate\n");
			attacker.killcount = 0;
		}
		else if (attacker.classname == "player")
		{
			if (!checkrules_firstblood)
			{
				checkrules_firstblood = TRUE;
				sound(world, CHAN_AUTO, "announcer/firstblood.wav", 1, ATTN_NONE);
				bprint("^1",attacker.netname, " drew first blood", "\n");
			}

			if (deathtype == IT_LASER)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_UZI)
				bprint ("^1",s, " was riddled full of holes by ", attacker.netname, "\n");
			else if (deathtype == IT_SHOTGUN)
				bprint ("^1",s, " was gunned by ", attacker.netname, "\n");
			else if (deathtype == IT_GRENADE_LAUNCHER)
				bprint ("^1", s, " was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_ELECTRO)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_CRYLINK)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_NEX)
				bprint ("^1",s, " has been vaporized by ", attacker.netname, "\n");
			else if (deathtype == IT_HAGAR)
				bprint ("^1",s, " was pummeled by ", attacker.netname, "\n");
			else if (deathtype == IT_ROCKET_LAUNCHER)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtype == DEATH_TELEFRAG)
				bprint ("^1",s, " was telefragged by ", attacker.netname, "\n");
			else
				bprint ("^1",s, " was killed by ", attacker.netname, "\n");

			attacker.frags = attacker.frags + 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"'s ", ftos(targ.killcount), " kill spree was ended by ", attacker.netname, "\n");
			attacker.killcount = attacker.killcount + 1;
			if (attacker.killcount > 2)
				bprint ("^1",attacker.netname," has ",ftos(attacker.killcount)," kills in a row\n");
		}
		else
		{
			if (deathtype == DEATH_HURTTRIGGER)
				bprint ("^1",s, " ", attacker.message, "\n");
			else if (deathtype == DEATH_DROWN)
				bprint ("^1",s, " drowned\n");
			else if (deathtype == DEATH_SLIME)
				bprint ("^1",s, " was slimed\n");
			else if (deathtype == DEATH_LAVA)
				bprint ("^1",s, " turned into hot slag\n");
			else if (deathtype == DEATH_FALL)
				bprint ("^1",s, " hit the ground with a crunch\n");
			targ.frags = targ.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s," died with a ",ftos(targ.killcount)," kill spree\n");
		}
		// FIXME: this should go in PutClientInServer
		if (targ.killcount)
			targ.killcount = 0;
	}
}

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	local entity oldself;
	oldself = self;
	self = targ;
	// nullify damage if teamplay is on
	if (teamplay)
	if (attacker.team)
	if (attacker.team == targ.team)
	if (teamplay == 1 || (teamplay == 3 && attacker != targ))
		damage = 0;
	// apply strength multiplier
	if (attacker.items & IT_STRENGTH)
	{
		damage = damage * cvar("g_balance_powerup_strength_damage");
		force = force * cvar("g_balance_powerup_strength_force");
	}
	// apply invincibility multiplier
	if (targ.items & IT_INVINCIBLE)
		damage = damage * cvar("g_balance_powerup_invincible_takedamage");
	// apply push
	if (self.damageforcescale)
	{
		self.velocity = self.velocity + self.damageforcescale * force;
		self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	// apply damage
	if (self.event_damage)
		self.event_damage (inflictor, attacker, damage, deathtype, hitloc, force);
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
					force = normalize((m1 + m2) * 0.5 - blastorigin) * (finaldmg / coredamage) * forceintensity;
					if (targ == attacker)
						finaldmg = finaldmg * cvar("g_balance_selfdamagepercent");	// Partial damage if the attacker hits himself
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
