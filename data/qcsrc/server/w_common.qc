
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
	float f;

	f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier

	Damage_DamageInfo(self.origin, self.dmg * f, 0, 0, self.dmg_force * normalize(self.velocity) * f, self.projectiledeathtype);

	if(other && other != self.enemy)
	{
		self.enemy = other; // don't hit the same player twice with the same bullet

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
	setorigin(self, self.W_BallisticBullet_LeaveSolid_origin);
	self.velocity = self.W_BallisticBullet_LeaveSolid_velocity;

	self.think = self.W_BallisticBullet_LeaveSolid_think_save;
	self.nextthink = max(time, self.W_BallisticBullet_LeaveSolid_nextthink_save) + 1;
	self.W_BallisticBullet_LeaveSolid_think_save = SUB_Null;

	self.flags &~= FL_ONGROUND;
	self.effects &~= EF_NODRAW;

	float f;
	f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
	Damage_DamageInfo(self.origin, 0, 0, 0, self.dmg_force * normalize(self.velocity) * f, self.projectiledeathtype);
	
	UpdateCSQCProjectile(self);
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

float W_BallisticBullet_LeaveSolid(entity e, vector vel, float constant)
{
	// move the entity along its velocity until it's out of solid, then let it resume
	
	float dt, dst, velfactor, v0, vs;
	float maxdist;
	float E0_m, Es_m;

	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	v0 = vlen(vel);

	E0_m = 0.5 * v0 * v0;
	maxdist = E0_m / constant;
	// maxdist = 0.5 * v0 * v0 / constant
	// dprint("max dist = ", ftos(maxdist), "\n");

	if(maxdist <= 0.5)
		return 0;

	traceline_inverted (self.origin, self.origin + normalize(vel) * maxdist, MOVE_NORMAL, self);

	if(trace_fraction == 1) // 1: we never got out of solid
		return 0;

	self.W_BallisticBullet_LeaveSolid_origin = trace_endpos;

	dst = vlen(trace_endpos - self.origin);
	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	Es_m = E0_m - constant * dst;
	if(Es_m <= 0)
	{
		// roundoff errors got us
		return 0;
	}
	vs = sqrt(2 * Es_m);
	velfactor = vs / v0;

	dt = dst / (0.5 * (v0 + vs));
	// this is not correct, but the differential equations have no analytic
	// solution - and these times are very small anyway
	//print("dt = ", ftos(dt), "\n");

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

void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float headshotbonus, float force, float dtype, float tracereffects, float gravityfactor, float bulletconstant)
{
	entity proj;
	proj = spawn();
	proj.classname = "bullet";
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
	proj.dmg_radius = cvar("g_ballistics_materialconstant") / bulletconstant;
	// so: bulletconstant = bullet mass / area of bullet circle
	setmodel(proj, "models/tracer.mdl");
	setsize(proj, '0 0 0', '0 0 0');
	setorigin(proj, start);
	proj.effects = EF_LOWPRECISION | tracereffects;
	proj.flags = FL_PROJECTILE;

	proj.touch = W_BallisticBullet_Touch;
	proj.dmg = damage;
	proj.dmg_edge = headshotbonus;
	proj.dmg_force = force;
	proj.projectiledeathtype = dtype;

	proj.oldvelocity = proj.velocity;

	if(DEATH_WEAPONOF(dtype) == WEP_CAMPINGRIFLE)
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING);
	else
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET);
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;
	local entity e;

	if(cvar("g_ballistics_force"))
	{
		if (DEATH_ISWEAPON(dtype, WEP_SHOTGUN))
			fireBallisticBullet(start, dir, spread, cvar("g_ballistics_force_shotgun_speed"), 5, damage, 0, force, dtype, 0, 1, cvar("g_ballistics_force_shotgun_bulletconstant"));
		else
			fireBallisticBullet(start, dir, spread, cvar("g_ballistics_force_uzi_speed"), 5, damage, 0, force, dtype, 0, 1, cvar("g_ballistics_force_shotgun_bulletconstant"));
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

		CSQCProjectile(e, TRUE, PROJECTILE_BULLET);
	}

	if ((trace_fraction != 1.0) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
			Damage_DamageInfo(trace_endpos, damage, 0, 0, dir * force, dtype);
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
