
float checkrules_firstblood;

void Obituary (entity attacker, entity targ, float deathtypeN)	// Renamed "deathtype" to "deathtypeN"
{																// b/c of conflict with item_tfgoal
	string	s;

	if (targ.classname == "player" || targ.classname == "corpse")
	{
		if (targ.classname == "corpse")
			s = "A corpse";
		else
			s = targ.netname;

		if (((attacker.classname == "info_tfgoal") || (attacker.classname == "item_tfgoal")))
		{
			if ((attacker.deathtype != ""))
			{
				bprint (targ.netname);
				bprint (attacker.deathtype);
			}
			return;
		}

		if (targ == attacker)
		{
			if (deathtypeN == IT_GRENADE_LAUNCHER)
				bprint ("^1",s, " detonated\n");
			else if (deathtypeN == IT_ELECTRO)
				bprint ("^1",s, " played with plasma\n");
			else if (deathtypeN == IT_ROCKET_LAUNCHER)
				bprint ("^1",s, " exploded\n");
			else if (deathtypeN == DEATH_KILL)
				bprint ("^1",s, " couldn't take it anymore\n");
			else if (deathtypeN == 88)
				bprint ("^1",s, " blew his own sorry ass up\n");
			else if (deathtypeN == 35)
				bprint ("^1",s, " is still seeing stars from his flash grenade.\n");
			else if (deathtypeN == 99)
				bprint ("^1",s, " nails himself to death.\n");
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
				//sound(world, CHAN_AUTO, "announcer/firstblood.wav", 1, ATTN_NONE);
				bprint("^1",attacker.netname, " drew first blood", "\n");
			}

			if (deathtypeN == WEP_LASER)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_UZI)
				bprint ("^1",s, " was riddled full of holes by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_SHOTGUN)
				bprint ("^1",s, " was gunned by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_GRENADE_LAUNCHER)
				bprint ("^1", s, " was blasted by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_ELECTRO)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_CRYLINK)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_NEX)
				bprint ("^1",s, " has been vaporized by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_HAGAR)
				bprint ("^1",s, " was pummeled by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_ROCKET_LAUNCHER)
				bprint ("^1",s, " was blasted by ", attacker.netname, "\n");
			else if (deathtypeN == WEP_GRENADE_MIRV)
				bprint ("^1",s, " was blasted by ", attacker.netname, "'s mirv\n");
			else if (deathtypeN == WEP_GRENADE_FRAG)
				bprint ("^1",s, " was fragged by ", attacker.netname, "'s grenade\n");
			else if (deathtypeN == DEATH_BURNING)
				bprint ("^1",s, " was fried toasty by ", attacker.netname, "\n");
			else if (deathtypeN == DEATH_TELEFRAG)
				bprint ("^1",s, " was telefragged by ", attacker.netname, "\n");
			else if (deathtypeN == 88)
				bprint ("^1",s, " exploded from ", attacker.netname, "'s grenade\n");
			else if (deathtypeN == 35)
				bprint ("^1",s, " sees the light of ", attacker.netname, "'s flash grenade\n");
			else if (deathtypeN == 9)
				bprint ("^1",s, " gets nailed to the wall from ", attacker.netname, "'s nail grenade\n");
			else if (deathtypeN == 51)	//tesla
				bprint ("^1",s, " gets fried by ", attacker.netname, "'s tesla coil :D\n");
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
			if (deathtypeN == DEATH_CLASSCHANGE)
			{
				if (targ.killcount > 2)
					bprint ("^1",s," changed with a ",ftos(targ.killcount)," kill spree\n");
				if (targ.killcount)
					targ.killcount = 0;
				return; // don't print anything more or lose frags
			}
			else if (deathtypeN == DEATH_HURTTRIGGER)
				bprint ("^1",s, " ", attacker.message, "\n");
			else if (deathtypeN == DEATH_DROWN)
				bprint ("^1",s, " drowned\n");
			else if (deathtypeN == DEATH_SLIME)
				bprint ("^1",s, " was slimed\n");
			else if (deathtypeN == DEATH_LAVA)
				bprint ("^1",s, " turned into hot slag\n");
			else if (deathtypeN == DEATH_FALL)
				bprint ("^1",s, " hit the ground with a crunch\n");
			else if (deathtypeN == DEATH_LASERGATE)
				bprint ("^1",s, " ", attacker.message, "\n");
			targ.frags = targ.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s," died with a ",ftos(targ.killcount)," kill spree\n");
		}
		// FIXME: this should go in PutClientInServer
		if (targ.killcount)
			targ.killcount = 0;
	}
}

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	deathmsg = deathtype;
	T_Damage (targ, inflictor, attacker, damage);
	return;

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
/*
	// apply damage
	if (self.event_damage)
		self.event_damage (inflictor, attacker, damage, deathtype, hitloc, force);
	self = oldself;	*/
}

void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void (entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage;

void RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype)
{
//	deathmsg = deathtype;
//	T_RadiusDamage (inflictor, attacker, coredamage, ignore);
//	return;

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
					if (finaldmg > 0)
					{
						force = normalize((m1 + m2) * 0.5 - blastorigin) * (finaldmg / coredamage) * forceintensity;
						if (targ == attacker)
							finaldmg = finaldmg * cvar("g_balance_selfdamagepercent");	// Partial damage if the attacker hits himself
						Damage (targ, inflictor, attacker, finaldmg, deathtype, inflictor.origin, force);
					}
				}
			}
		targ = targ.chain;
	}
}


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

//	Damage (self, multi_ent.origin, multi_ent, 0, multi_damage, multi_force);
	TF_T_Damage (multi_ent, self, self, multi_damage, 2, 1);
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

/*void FireBullets (float shotcount, vector dir, vector spread, float deathtype)
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
}*/

float puff_count;
vector puff_org;
float blood_count;
vector blood_org;
float (entity ent) tfvisible;

void (float damage,vector dir) TraceAttack =
{
	local vector vel;
	local vector org;

	vel = normalize (((dir + (v_up * crandom ())) + (v_right * crandom ())));
	vel = (vel + (2 * trace_plane_normal));
	vel = (vel * 200);
	org = (trace_endpos - (dir * 4));

	if (tfvisible(trace_ent))
		trace_ent.takedamage = 1;

	if (trace_ent.takedamage)
	{
		blood_count = (blood_count + 1);
		blood_org = org;
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		puff_count = (puff_count + 1);
	}
};

void (float shotcount,vector dir,vector spread) FireBullets =
{
	local vector direction;
	local vector src;

	makevectors (self.v_angle);
	src = (self.origin + (v_forward * 10));
	src_z = (self.absmin_z + (self.size_z * 0.7));
	ClearMultiDamage ();
	traceline (src, (src + (dir * 2048)), 0.000000, self);
	puff_org = (trace_endpos - (dir * 4));
	while ((shotcount > 0.000000))
	{
		direction = ((dir + ((crandom () * spread_x) * v_right)) + ((crandom () * spread_y) * v_up));
		traceline (src, (src + (direction * 2048)), 0.000000, self);
		if ((trace_fraction != 1))
		{
			if ((self.weapon != 32768))
			{
				TraceAttack (4, direction);
			}
			else
			{
				TraceAttack (9, direction);
			}
		}
		shotcount = (shotcount - 1);
	}
	ApplyMultiDamage ();
};
