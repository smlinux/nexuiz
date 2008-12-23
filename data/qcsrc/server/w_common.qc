
void W_GiveWeapon (entity e, float wep, string name)
{
	entity oldself;

	if (!wep)
		return;

	e.weapons = e.weapons | W_WeaponBit(wep);

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
	local entity ent, endent;
	local float endq3surfaceflags;
	//local entity explosion;
	
	railgun_start = start;
	railgun_end = end;

	dir = normalize(end - start);
	force = dir * bforce;

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	while (1)
	{
		if(self.antilag_debug)
			traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
		else
			traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

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
	endent = trace_ent;
	endq3surfaceflags = trace_dphitq3surfaceflags;

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
	trace_ent = endent;
	trace_dphitq3surfaceflags = endq3surfaceflags;
}

.float dmg_edge;
.float dmg_force;
.float dmg_radius;
void W_BallisticBullet_Hit (void)
{
	vector org2;
	float f;

	org2 = self.origin - 6 * normalize(self.oldvelocity);
	if (DEATH_ISWEAPON(self.projectiledeathtype, WEP_SHOTGUN))
		pointparticles(particleeffectnum("shotgun_impact"), org2, normalize(self.velocity) * 1000, 1);
	else
		pointparticles(particleeffectnum("machinegun_impact"), org2, normalize(self.velocity) * 1000, 1);

	if(other && other != self.enemy)
	{
		self.enemy = other; // don't hit the same player twice with the same bullet

		f = vlen(self.velocity) / vlen(self.oldvelocity);

		headshot = 0;
		yoda = 0;
		damage_headshotbonus = self.dmg_edge;
		railgun_start = self.origin - 2 * frametime * self.oldvelocity;
		railgun_end = self.origin + 2 * frametime * self.oldvelocity;
		Damage(other, self, self.owner, self.dmg * f, self.projectiledeathtype, self.origin, self.dmg_force * normalize(self.velocity) * f);
		damage_headshotbonus = 0;

		if(self.dmg_edge != 0)
		{
			if(headshot)
				announce(self.owner, "announcer/male/headshot.wav");
			if(yoda)
				announce(self.owner, "announcer/male/yoda.wav");
		}

		//sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
	}
}

.void(void) W_BallisticBullet_LeaveSolid_think_save;
.float W_BallisticBullet_LeaveSolid_nextthink_save;
.vector W_BallisticBullet_LeaveSolid_origin;
.vector W_BallisticBullet_LeaveSolid_velocity;

void W_BallisticBullet_LeaveSolid_think()
{
	vector org2;

	setorigin(self, self.W_BallisticBullet_LeaveSolid_origin);
	self.velocity = self.W_BallisticBullet_LeaveSolid_velocity;

	self.think = self.W_BallisticBullet_LeaveSolid_think_save;
	self.nextthink = max(time, self.W_BallisticBullet_LeaveSolid_nextthink_save) + 1;
	self.W_BallisticBullet_LeaveSolid_think_save = SUB_Null;

	self.flags &~= FL_ONGROUND;
	self.effects &~= EF_NODRAW;

	org2 = self.origin - 6 * normalize(self.oldvelocity);
	if (DEATH_ISWEAPON(self.projectiledeathtype, WEP_SHOTGUN))
		pointparticles(particleeffectnum("shotgun_impact"), org2, normalize(self.velocity) * 1000, 1);
	else
		pointparticles(particleeffectnum("machinegun_impact"), org2, normalize(self.velocity) * 1000, 1);
}

// a fake logarithm function
float log(float x)
{
	if(x < 0.0001)
		return 0;
	if(x > 0.9 && x < 1.1)
		return x - 1;
	return 2 * log(sqrt(x));
}

float W_BallisticBullet_LeaveSolid(entity e, vector vel, float speedhalflife)
{
	// move the entity along its velocity until it's out of solid, then let it resume
	
	vector tracevel, org, skiporg, endorg, t;
	float dt, dst, velfactor, v0;
	float maxdist;

	speedhalflife *= 1.442695040888963; // distance for 1/eth of the speed
	v0 = vlen(vel);

	// maxdist: max distance that CAN be travelled using current velocity and speed halflife
	//
	// v(t) = v(0) * e^(-t / speedhalflife)
	// integrate
	// V(t) = - v(0) * e^(-t / speedhalflife) * speedhalflife
	// s(t) = V(t) - V(0)
	// s(t) = (speedhalflife * v(0)) * (1 - e^(-t / speedhalflife))
	// lim s = speedhalflife * v(0)
	// t(s) = speedhalflife * log((speedhalflife * v(0)) / (speedhalflife * v(0) - s))
	// v(s) = (speedhalflife * v(0) - s) / speedhalflife

	maxdist = speedhalflife * v0;
	//print("max dist = ", ftos(maxdist), "\n");

	if(maxdist <= 0)
		return 0;

	tracevel = normalize(vel);

	org = self.origin;
	skiporg = org + tracevel;
	endorg = org + tracevel * maxdist;

	for(;;)
	{
		traceline(skiporg, endorg, MOVE_NORMAL, self);
		t = trace_endpos;

		if(trace_startsolid)
		{
			// good: skiporg is actually in solid
			traceline(t, skiporg, MOVE_NORMAL, self);
			t = trace_endpos;

			if(trace_startsolid)
			{
				// we're stuck inside solid :(
				// force advance by 1 unit, and retry
				// CAN we go by 1 unit?
				if(vlen(skiporg + tracevel - org) < maxdist)
					skiporg = skiporg + tracevel;
				else
					return 0;
			}
			else
			{
				// we managed to leave solid
				// so trace_endpos is good
				self.W_BallisticBullet_LeaveSolid_origin = t;
				break;
			}
		}
		else
		{
			// bad: skiporg is outside solid. Then imagine it's alright.
			self.W_BallisticBullet_LeaveSolid_origin = skiporg;
			break;
		}
	}

	dst = vlen(self.W_BallisticBullet_LeaveSolid_origin - org);
	velfactor = (speedhalflife * v0 - dst) / (speedhalflife * v0);

	// t(s) = speedhalflife * log((speedhalflife * v(0)) / (speedhalflife * v(0) - s))
	dt = speedhalflife * log((speedhalflife * v0) / (speedhalflife * v0 - dst));

	//print("slowdown by ", ftos(dst), " units = ", ftos(velfactor), "\n");
	//print("takes time ", ftos(dt), "\n");

	self.W_BallisticBullet_LeaveSolid_think_save = self.think;
	self.W_BallisticBullet_LeaveSolid_nextthink_save = self.nextthink;
	self.think = W_BallisticBullet_LeaveSolid_think;
	self.nextthink = time + dt;

	vel = vel * velfactor;

	self.velocity = '0 0 0';
	self.flags |= FL_ONGROUND; // prevent moving
	self.effects |= EF_NODRAW;
	self.W_BallisticBullet_LeaveSolid_velocity = vel;

	return 1;
}

void W_BallisticBullet_Touch (void)
{
	if(self.think == W_BallisticBullet_LeaveSolid_think) // skip this!
		return;

	PROJECTILE_TOUCH;
	W_BallisticBullet_Hit ();

	// go through solid!
	if(!W_BallisticBullet_LeaveSolid(self, self.velocity, self.dmg_radius))
	{
		remove(self);
		return;
	}

	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float headshotbonus, float force, float dtype, float tracereffects, float gravityfactor)
{
	entity proj;
	proj = spawn();
	proj.owner = self;
	proj.solid = SOLID_BBOX;
	if(gravityfactor > 0)
	{
		proj.movetype = MOVETYPE_TOSS;
		proj.gravity = gravityfactor;
	}
	else
		proj.movetype = MOVETYPE_FLY;
	proj.think = SUB_Remove;
	proj.nextthink = time + lifetime; // min(pLifetime, vlen(world.maxs - world.mins) / pSpeed);
	proj.velocity = (dir + randomvec() * spread) * pSpeed;
	W_SetupProjectileVelocity(proj);
	proj.angles = vectoangles(proj.velocity);
	proj.dmg_radius = cvar("g_ballistics_solidspeedhalflife");
	setmodel(proj, "models/tracer.mdl");
	setsize(proj, '0 0 0', '0 0 0');
	setorigin(proj, w_shotorg);
	proj.effects = EF_LOWPRECISION | tracereffects;
	proj.flags = FL_PROJECTILE;

	proj.touch = W_BallisticBullet_Touch;
	proj.dmg = damage;
	proj.dmg_edge = headshotbonus;
	proj.dmg_force = force;
	proj.projectiledeathtype = dtype;

	proj.oldvelocity = proj.velocity;

	if (cvar("g_casings") >= 2)
		SpawnCasing (w_shotorg + v_forward * 10, ((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3);
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;
	local entity e;

	if(cvar("g_ballistics_force"))
	{
		if (DEATH_ISWEAPON(dtype, WEP_SHOTGUN))
			fireBallisticBullet(start, dir, spread, cvar("g_ballistics_force_shotgun_speed"), 5, damage, 0, force, dtype, 0, 1);
		else
			fireBallisticBullet(start, dir, spread, cvar("g_ballistics_force_uzi_speed"), 5, damage, 0, force, dtype, 0, 1);
		return;
	}

	dir = dir + randomvec() * spread;
	end = start + dir * MAX_SHOT_DISTANCE;
	if(self.antilag_debug)
		traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
	else
		traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

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
			if (DEATH_ISWEAPON(dtype, WEP_SHOTGUN))
				pointparticles(particleeffectnum("shotgun_impact"), trace_endpos, trace_plane_normal * 1000, 1);
			else
				pointparticles(particleeffectnum("machinegun_impact"), trace_endpos, trace_plane_normal * 1000, 1);
		}
		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
	}
}

void W_PrepareExplosionByDamage(entity attacker, void() explode)
{
	self.takedamage = DAMAGE_NO;
	self.event_damage = SUB_Null;
	self.owner = attacker;

	// do not explode NOW but in the NEXT FRAME!
	// because recursive calls to RadiusDamage are not allowed
	self.nextthink = time;
	self.think = explode;
}
