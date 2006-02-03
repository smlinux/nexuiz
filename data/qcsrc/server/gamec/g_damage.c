
float checkrules_firstblood;

void GiveFrags (entity attacker, entity targ, float f)
{
	
	if(gameover) return;
	
	if(f > 0 && cvar("g_domination") && cvar("g_domination_disable_frags"))
		return;
	else if(f > 0 && cvar("g_runematch"))
		f = RunematchHandleFrags(attacker, targ, f);
	else if(cvar("g_lms"))
	{
		// count remaining lives, not frags in lms
		targ.frags -= 1;
		// keep track of the worst players lives
		if(targ.frags < lms_lowest_lives)
			lms_lowest_lives = targ.frags;	
		// player has no more lives left
		if (!targ.frags)
			lms_dead_count += 1;
		return;
	}

	if(f)
		attacker.frags = attacker.frags + f;
}

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
			if (deathtype == DEATH_NOAMMO)
				centerprint(targ, strcat("^1You were killed for running out of ammo...\n\n\n"));
			else
				centerprint(targ, strcat("^1You killed your own dumb self!\n\n\n"));
			
			if (deathtype == IT_GRENADE_LAUNCHER)
				bprint ("^1",s, "^1 detonated\n");
			else if (deathtype == IT_ELECTRO)
				bprint ("^1",s, "^1 played with plasma\n");
			else if (deathtype == IT_ROCKET_LAUNCHER)
				bprint ("^1",s, "^1 exploded\n");
			else if (deathtype == DEATH_KILL)
				bprint ("^1",s, "^1 couldn't take it anymore\n");
			else if (deathtype == DEATH_NOAMMO)
			{
				bprint ("^7",s, " ^7committed suicide. What's the point of living without ammo?\n");
				//sound (self, CHAN_BODY, "minstagib/mockery.ogg", 1, ATTN_NONE);
			}
			else
				bprint ("^1",s, "^1 couldn't resist the urge to self-destruct\n");
			GiveFrags(attacker, targ, -1);
			//targ.frags = targ.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"^1 ended it all with a ",ftos(targ.killcount)," kill spree\n");
		}
		else if (teamplay && attacker.team == targ.team)
		{
			centerprint(attacker, strcat("^1Moron! You fragged a teammate!\n\n\n"));
			bprint ("^1", attacker.netname, "^1 mows down a teammate\n");
			GiveFrags(attacker, targ, -1);
			//attacker.frags = attacker.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"'s ^1",ftos(targ.killcount)," kill spree was endeded by a teammate!\n");
			if (attacker.killcount > 2)
				bprint ("^1",attacker.netname,"^1 ended a ",ftos(attacker.killcount)," kill spree by killing a teammate\n");
			attacker.killcount = 0;
		}
		else if (attacker.classname == "player" || attacker.classname == "gib")
		{
			if (!checkrules_firstblood)
			{
				checkrules_firstblood = TRUE;
				//sound(world, CHAN_AUTO, "announcer/firstblood.wav", 1, ATTN_NONE);
				if (cvar("g_minstagib"))
					//sound(world, CHAN_AUTO, "announce/male/mapkill1.ogg", 1, ATTN_NONE);
				bprint("^1",attacker.netname, "^1 drew first blood", "\n");
			}

			centerprint(attacker, strcat("^4You fragged ^7", s, "\n\n\n"));
			centerprint(targ, strcat("^1You were fragged by ^7", attacker.netname, "\n\n\n"));
			
			if (deathtype == IT_LASER)
				bprint ("^1",s, "^1 was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_UZI)
				bprint ("^1",s, "^1 was riddled full of holes by ", attacker.netname, "\n");
			else if (deathtype == IT_SHOTGUN)
				bprint ("^1",s, "^1 was gunned by ", attacker.netname, "\n");
			else if (deathtype == IT_GRENADE_LAUNCHER)
				bprint ("^1", s, "^1 was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_ELECTRO)
				bprint ("^1",s, "^1 was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_CRYLINK)
				bprint ("^1",s, "^1 was blasted by ", attacker.netname, "\n");
			else if (deathtype == IT_NEX)
				bprint ("^1",s, "^1 has been vaporized by ", attacker.netname, "\n");
			else if (deathtype == IT_HAGAR)
				bprint ("^1",s, "^1 was pummeled by ", attacker.netname, "\n");
			else if (deathtype == IT_ROCKET_LAUNCHER)
				bprint ("^1",s, "^1 was blasted by ", attacker.netname, "\n");
			else if (deathtype == DEATH_TELEFRAG)
				bprint ("^1",s, "^1 was telefragged by ", attacker.netname, "\n");
			else if (deathtype == DEATH_DROWN)
				bprint ("^1",s, "^1 was drowned by ", attacker.netname, "\n");
			else if (deathtype == DEATH_SLIME)
				bprint ("^1",s, "^1 was slimed by ", attacker.netname, "\n");
			else if (deathtype == DEATH_LAVA)
				bprint ("^1",s, "^1 was cooked by ", attacker.netname, "\n");
			else if (deathtype == DEATH_FALL)
				bprint ("^1",s, "^1 was grounded by ", attacker.netname, "\n");
			else if (deathtype == DEATH_SWAMP)
				bprint ("^1",s, "^1 was conserved by ", attacker.netname, "\n");
			else if (deathtype == DEATH_HURTTRIGGER)
				bprint ("^1",s, "^1 was thrown into a world of hurt by ", attacker.netname, "\n");
			else
				bprint ("^1",s, "^1 was fragged by ", attacker.netname, "\n");

			GiveFrags(attacker, targ, 1);
			//attacker.frags = attacker.frags + 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"'s ^1", ftos(targ.killcount), " kill spree was ended by ", attacker.netname, "\n");
			attacker.killcount = attacker.killcount + 1;
			if (attacker.killcount > 2)
				bprint ("^1",attacker.netname,"^1 has ",ftos(attacker.killcount)," frags in a row\n");

			if (attacker.killcount == 3)
			{
				bprint (attacker.netname,"^7 made a ^1TRIPLE FRAG\n");
				stuffcmd(attacker, "play2 announcer/male/03kills.ogg\n");
			}
			else if (attacker.killcount == 5)
			{
				bprint (attacker.netname,"^7 made a ^1FIVE FRAG COMBO\n");
				stuffcmd(attacker, "play2 announcer/male/05kills.ogg\n");
			}
			else if (attacker.killcount == 10)
			{
				bprint (attacker.netname,"^7 is on a ^1RAGE\n");
				stuffcmd(attacker, "play2 announcer/male/10kills.ogg\n");
			}
			else if (attacker.killcount == 15)
			{
				bprint (attacker.netname,"^7 has done a ^1MASSACRE!\n");
				stuffcmd(attacker, "play2 announcer/male/15kills.ogg\n");
			}
			else if (attacker.killcount == 20)
			{
				bprint (attacker.netname,"^7 is ^1UNHUMAN!\n");
				stuffcmd(attacker, "play2 announcer/male/20kills.ogg\n");
			}
			else if (attacker.killcount == 25)
			{
				bprint (attacker.netname,"^7 is a ^1DEATH INCARNATION!\n");
				stuffcmd(attacker, "play2 announcer/male/25kills.ogg\n");
			}
			else if (attacker.killcount == 30)
			{
				bprint (attacker.netname,"^7 is maybe a ^1AIMBOTTER?!\n");
				stuffcmd(attacker, "play2 announcer/male/30kills.ogg\n");
			}
		}
		else
		{
			centerprint(targ, strcat("^1Watch your step!\n\n\n"));
			if (deathtype == DEATH_HURTTRIGGER && attacker.message != "")
				bprint ("^1",s, "^1 ", attacker.message, "\n");
			else if (deathtype == DEATH_DROWN)
				bprint ("^1",s, "^1 drowned\n");
			else if (deathtype == DEATH_SLIME)
				bprint ("^1",s, "^1 was slimed\n");
			else if (deathtype == DEATH_LAVA)
				bprint ("^1",s, "^1 turned into hot slag\n");
			else if (deathtype == DEATH_FALL)
				bprint ("^1",s, "^1 hit the ground with a crunch\n");
			else if (deathtype == DEATH_SWAMP)
				bprint ("^1",s, "^1 is now conserved for centuries to come\n");
			else
				bprint ("^1",s, "^1 died\n");
			GiveFrags(targ, targ, -1);
			if(targ.frags == -5) {
				stuffcmd(targ, "play2 announcer/male/botlike.ogg\n");
			} 
			
			//targ.frags = targ.frags - 1;
			if (targ.killcount > 2)
				bprint ("^1",s,"^1 died with a ",ftos(targ.killcount)," kill spree\n");
		}
		// FIXME: this should go in PutClientInServer
		if (targ.killcount)
			targ.killcount = 0;
	}
}

// these are updated by each Damage call for use in button triggering and such
entity damage_targ;
entity damage_inflictor;
entity damage_attacker;

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (gameover || targ.killcount == -666)
		return;
	
	local entity oldself;
	oldself = self;
	self = targ;
        damage_targ = targ;
        damage_inflictor = inflictor;
        damage_attacker = attacker;	
	// nullify damage if teamplay is on
	if (teamplay)
	if (attacker.team)
	if (attacker.team == targ.team)
	if ((teamplay == 1 || teamplay == 3) && attacker != targ)
		damage = 0;
	
	if(damage > 0 && targ != attacker && clienttype(attacker) == CLIENTTYPE_REAL && targ.classname == "player")
		stuffcmd(attacker, "play2 misc/hit.wav\n");
	
	if (cvar("g_minstagib"))
	{
		if ((deathtype == DEATH_FALL)  || 
		    (deathtype == DEATH_DROWN) || 
		    (deathtype == DEATH_SLIME) || 
		    (deathtype == DEATH_LAVA))
			return;
		if (targ.extralives && (deathtype == IT_NEX) && damage)
		{
			targ.extralives -= 1;
			centerprint(targ, strcat("^3Remaining extra lives: ",ftos(targ.extralives),"\n"));
			damage = 0;
			targ.armorvalue = targ.extralives;
			if(clienttype(targ) == CLIENTTYPE_REAL) stuffcmd(targ, "play2 misc/hit.wav\n");
			//stuffcmd(attacker, "play2 misc/hit.wav\n");
		}
		else if (deathtype == IT_NEX && targ.items & IT_STRENGTH)
		{
			if(clienttype(attacker) == CLIENTTYPE_REAL) stuffcmd(attacker, "play2 announcer/male/yoda.ogg\n");
		}
		if (deathtype == IT_LASER)
		{
			damage = 0;
			if (targ != attacker)
			{
				if (targ.classname == "player")
					centerprint(attacker, "Secondary fire inflicts no damage!\n");
				damage = 0;
				force = '0 0 0';
				attacker = targ;
			}
		}
	} else {
		if (deathtype == IT_NEX && !(attacker.flags & FL_ONGROUND) && !(targ.flags & FL_ONGROUND) && attacker.killcount != 3 && attacker.killcount != 5 && attacker.killcount != 10 && attacker.killcount != 15 && attacker.killcount != 20 && attacker.killcount != 25 && attacker.killcount != 30)
		{
			if(clienttype(attacker) == CLIENTTYPE_REAL)  stuffcmd(attacker, "play2 announcer/male/yoda.ogg\n");
		}
	}
	
	// midair gamemode: damage only while in the air
	if (cvar("g_midair")
	    && self.classname == "player" // e.g. grenades take damage
	    && self.flags & FL_ONGROUND) {
		damage = 0;
	}

	// apply strength multiplier
	if (attacker.items & IT_STRENGTH && !cvar("g_minstagib"))
	{
		damage = damage * cvar("g_balance_powerup_strength_damage");
		force = force * cvar("g_balance_powerup_strength_force");
	}
	// apply invincibility multiplier
	if (targ.items & IT_INVINCIBLE && !cvar("g_minstagib"))
		damage = damage * cvar("g_balance_powerup_invincible_takedamage");


	if(cvar("g_runematch"))
	{
		// apply strength rune
		if (attacker.runes & RUNE_STRENGTH)
		{
			if(attacker.runes & CURSE_WEAK) // have both curse & rune
			{
				damage = damage * cvar("g_balance_rune_strength_combo_damage");
				force = force * cvar("g_balance_rune_strength_combo_force");
			}
			else
			{
				damage = damage * cvar("g_balance_rune_strength_damage");
				force = force * cvar("g_balance_rune_strength_force");
			}
		}
		else if (attacker.runes & CURSE_WEAK)
		{
			damage = damage * cvar("g_balance_curse_weak_damage");
			force = force * cvar("g_balance_curse_weak_force");
		}

		// apply defense rune
		if (targ.runes & RUNE_DEFENSE)
		{
			if (targ.runes & CURSE_VULNER) // have both curse & rune
				damage = damage * cvar("g_balance_rune_defense_combo_takedamage");
			else
				damage = damage * cvar("g_balance_rune_defense_takedamage");
		}
		else if (targ.runes & CURSE_VULNER)
			damage = damage * cvar("g_balance_curse_vulner_takedamage");
	}

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

	if(targ.classname == "player" && attacker.classname == "player" && attacker != targ && attacker.health > 2)
	{
		// Savage: vampire mode
		if(cvar("g_vampire") && !cvar("g_minstagib"))
		{
			attacker.health += damage;
		}
		if(cvar("g_runematch"))
		{
			if (attacker.runes & RUNE_VAMPIRE)
			{
			// apply vampire rune
				if (attacker.runes & CURSE_EMPATHY) // have the curse too
				{
					//attacker.health = attacker.health + damage * cvar("g_balance_rune_vampire_combo_absorb");
					attacker.health = bound(
						cvar("g_balance_curse_empathy_minhealth"), // LA: was 3, now 40
						attacker.health + damage * cvar("g_balance_rune_vampire_combo_absorb"), 
						cvar("g_balance_rune_vampire_maxhealth"));	// LA: was 1000, now 500
				}
				else
				{
					//attacker.health = attacker.health + damage * cvar("g_balance_rune_vampire_absorb");
					attacker.health = bound(
						attacker.health,	// LA: was 3, but changed so that you can't lose health
											// empathy won't let you gain health in the same way...
						attacker.health + damage * cvar("g_balance_rune_vampire_absorb"), 
						cvar("g_balance_rune_vampire_maxhealth"));	// LA: was 1000, now 500
					}
			}
			// apply empathy curse
			else if (attacker.runes & CURSE_EMPATHY)
			{
				attacker.health = bound(
					cvar("g_balance_curse_empathy_minhealth"), // LA: was 3, now 20
					attacker.health + damage * cvar("g_balance_curse_empathy_takedamage"), 
					attacker.health);
			}
		}
	}
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



