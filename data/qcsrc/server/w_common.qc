
// increments sprite frame, loops when end is hit.. simple

float TE_SMOKE =77;
void (vector vec) WriteVec =
{
		WriteCoord (MSG_BROADCAST, vec_x);
		WriteCoord (MSG_BROADCAST, vec_y);
		WriteCoord (MSG_BROADCAST, vec_z);
}
void (vector org, vector dir, float counts) W_Smoke =
{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SMOKE);
		WriteVec (org);
		WriteVec (dir);
		WriteByte (MSG_BROADCAST, counts);
}

// increments sprite frame, loops when end is hit.. simple
void animate_sprite (float startframe, float frame_count)
{
	if ((self.frame - startframe) >= (frame_count - 1 ))
		self.frame = startframe;
	else
		self.frame = self.frame + 1;
}

void W_GiveWeapon (entity e, float wep, string name)
{
	entity oldself;

	if (!wep)
		return;

	e.items = e.items | wep;

	oldself = self;
	self = e;

	if (other.classname == "player")
	{
		sprint (other, "You got the ^2");
		sprint (other, name);
		sprint (other, "\n");
	}


	self = oldself;
}

void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float deathtype)
{
	local vector hitloc, force, endpoint, dir;
	local entity ent;
	//local entity explosion;

	dir = normalize(end - start);
	force = dir * bforce;

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	while (1)
	{
		traceline_hitcorpse (self, start, end, FALSE, self);

		//if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		//if (!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		//	te_plasmaburn (trace_endpos - dir * 6);

		// if it is world we can't hurt it so stop now
		if (trace_ent == world || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		trace_ent.railgunhit = TRUE;
		trace_ent.railgunhitloc = end;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;

		// stop if this is a wall
		if (trace_ent.solid == SOLID_BSP)
			break;

		// make the entity non-solid
		trace_ent.solid = SOLID_NOT;
	}

	endpoint = trace_endpos;

	// find all the entities the railgun hit and restore their solid state
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// restore their solid type
		ent.solid = ent.railgunhitsolidbackup;
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// spawn a temporary explosion entity for RadiusDamage calls
	//explosion = spawn();

	// find all the entities the railgun hit and hurt them
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// get the details we need to call the damage function
		hitloc = ent.railgunhitloc;
		ent.railgunhitloc = '0 0 0';
		ent.railgunhitsolidbackup = SOLID_NOT;
		ent.railgunhit = FALSE;

		// apply the damage
		if (ent.takedamage || ent.classname == "case")
			Damage (ent, self, self, bdamage, deathtype, hitloc, force);

		// create a small explosion to throw gibs around (if applicable)
		//setorigin (explosion, hitloc);
		//RadiusDamage (explosion, self, 10, 0, 50, world, 300, deathtype);

		// advance to the next entity
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// we're done with the explosion entity, remove it
	//remove(explosion);

	trace_endpos = endpoint;
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;
	local entity e;

	// use traceline_hitcorpse to make sure it can hit gibs and corpses too
	dir = dir + randomvec() * spread;
	end = start + dir * MAX_SHOT_DISTANCE;
	traceline_hitcorpse (self, start, end, FALSE, self);

	if (tracer)
	{
		e = spawn();
		e.owner = self;
		e.movetype = MOVETYPE_FLY;
		e.solid = SOLID_NOT;
		e.think = SUB_Remove;
		e.nextthink = time + vlen(trace_endpos - start) / 6000;
		e.velocity = dir * 6000;
		e.angles = vectoangles(e.velocity);
		setmodel (e, "models/tracer.mdl"); // precision set below
		setsize (e, '0 0 0', '0 0 0');
		setorigin (e, start);
		e.effects = EF_LOWPRECISION;
		e.flags = FL_PROJECTILE;
	}

	if ((trace_fraction != 1.0) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		{
			if (dtype == IT_SHOTGUN)
				te_gunshot (trace_endpos);
			else
				te_spike (trace_endpos);
		}
		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
	}
}
