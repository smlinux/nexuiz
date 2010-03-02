void W_GiveWeapon (entity e, float wep, string name)
{
	entity oldself;

	if (!wep)
		return;

	e.weapons = e.weapons | W_WeaponBit(wep);

	oldself = self;
	self = e;

	if not(g_minstagib)
	if (other.classname == "player")
	{
		sprint (other, "You got the ^2");
		sprint (other, name);
		sprint (other, "\n");
	}

	self = oldself;
}

.float railgundistance;
void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float mindist, float maxdist, float halflifedist, float forcehalflifedist, float deathtype)
{
	local vector hitloc, force, endpoint, dir;
	local entity ent, endent;
	local float endq3surfaceflags;

	float length;
	vector beampos;
	string snd;
	entity pseudoprojectile;
	float f, ffs;

	float hit;

	railgun_start = start;
	railgun_end = end;

	dir = normalize(end - start);
	length = vlen(end - start);
	force = dir * bforce;

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	while (1)
	{
		if(self.antilag_debug)
			WarpZone_traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
		else
			WarpZone_traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

		// if it is world we can't hurt it so stop now
		if (trace_ent == world || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		trace_ent.railgunhit = TRUE;
		trace_ent.railgunhitloc = end;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;
		trace_ent.railgundistance = vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos) - start);

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

	// Find all non-hit players the beam passed close by
	if(deathtype == WEP_MINSTANEX || deathtype == WEP_NEX)
	{
		FOR_EACH_REALCLIENT(msg_entity) if(msg_entity != self) if(!msg_entity.railgunhit) if not(msg_entity.classname == "spectator" && msg_entity.enemy == self) // we use realclient, so spectators can hear the whoosh too
		{
			// nearest point on the beam
			beampos = start + dir * bound(0, (msg_entity.origin - start) * dir, length);

			f = bound(0, 1 - vlen(beampos - msg_entity.origin) / 512, 1);
			if(f <= 0)
				continue;

			snd = strcat("weapons/nexwhoosh", ftos(floor(random() * 3) + 1), ".wav");

			if(!pseudoprojectile)
				pseudoprojectile = spawn(); // we need this so the sound uses the "entchannel4" volume
			soundtoat(MSG_ONE, pseudoprojectile, beampos, CHAN_PROJECTILE, snd, VOL_BASE * f, ATTN_NONE);
		}

		if(pseudoprojectile)
			remove(pseudoprojectile);
	}

	// find all the entities the railgun hit and hurt them
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// get the details we need to call the damage function
		hitloc = ent.railgunhitloc;

		//for stats so that team hit will count as a miss
		if(ent.flags & FL_CLIENT)
		if(ent.deadflag == DEAD_NO)
			hit = 1;

		if(teams_matter)
		if(ent.team == self.team)
			hit = 0;

		f = ExponentialFalloff(mindist, maxdist, halflifedist, ent.railgundistance);
		ffs = ExponentialFalloff(mindist, maxdist, forcehalflifedist, ent.railgundistance);

		// apply the damage
		if (ent.takedamage)
			Damage (ent, self, self, bdamage * f, deathtype, hitloc, force * ffs);

		// create a small explosion to throw gibs around (if applicable)
		//setorigin (explosion, hitloc);
		//RadiusDamage (explosion, self, 10, 0, 50, world, 300, deathtype);

		ent.railgunhitloc = '0 0 0';
		ent.railgunhitsolidbackup = SOLID_NOT;
		ent.railgunhit = FALSE;
		ent.railgundistance = 0;

		// advance to the next entity
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// calculate hits and fired shots for hitscan
	if not(inWarmupStage)
	{
		self.stats_fired[self.weapon - 1] += 1;
		self.stat_fired = self.weapon + 64 * floor(self.stats_fired[self.weapon - 1]);

		if(hit) {
			self.stats_hit[self.weapon - 1] += 1;
			self.stat_hit = self.weapon + 64 * floor(self.stats_hit[self.weapon - 1]);
		}
	}

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

	if(other.solid == SOLID_BSP)
		Damage_DamageInfo(self.origin, self.dmg * f, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * f, self.projectiledeathtype, self);

	if(other && other != self.enemy)
	{
		endzcurveparticles();

		headshot = 0;
		yoda = 0;
		damage_headshotbonus = self.dmg_edge;
		railgun_start = self.origin - 2 * frametime * self.velocity;
		railgun_end = self.origin + 2 * frametime * self.velocity;

		Damage(other, self, self.owner, self.dmg * f, self.projectiledeathtype, self.origin, self.dmg_force * normalize(self.velocity) * f);
		damage_headshotbonus = 0;

		if(self.dmg_edge != 0)
		{
			if(headshot)
				AnnounceTo(self.owner, "headshot");
			if(yoda)
				AnnounceTo(self.owner, "awesome");
		}

		// calculate hits for ballistic weapons
		if (other.flags & FL_CLIENT)  // is the player a client
		if (other.deadflag == DEAD_NO)  // is the victim a corpse
		if ((!(teamplay)) | (other.team != self.owner.team))  // not teamplay (ctf, kh, tdm etc) or the victim is in the same team
		if not(inWarmupStage)  // not in warm up stage
		{
			self.owner.stats_hit[self.owner.weapon - 1] += 1;
			self.owner.stat_hit = self.owner.weapon + 64 * floor(self.owner.stats_hit[self.owner.weapon - 1]);
		}
	}

	self.enemy = other; // don't hit the same player twice with the same bullet
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
	self.nextthink = max(time, self.W_BallisticBullet_LeaveSolid_nextthink_save);
	self.W_BallisticBullet_LeaveSolid_think_save = SUB_Null;

	self.flags &~= FL_ONGROUND;

	if(self.enemy.solid == SOLID_BSP)
	{
		float f;
		f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
		Damage_DamageInfo(self.origin, 0, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * -f, self.projectiledeathtype, self);
	}

	UpdateCSQCProjectile(self);
}

float W_BallisticBullet_LeaveSolid(entity e, vector vel, float constant)
{
	// move the entity along its velocity until it's out of solid, then let it resume

	float dt, dst, velfactor, v0, vs;
	float maxdist;
	float E0_m, Es_m;

	// outside the world? forget it
	if(self.origin_x > world.maxs_x || self.origin_y > world.maxs_y || self.origin_z > world.maxs_z || self.origin_x < world.mins_x || self.origin_y < world.mins_y || self.origin_z < world.mins_z)
		return 0;

	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	v0 = vlen(vel);

	E0_m = 0.5 * v0 * v0;
	maxdist = E0_m / constant;
	// maxdist = 0.5 * v0 * v0 / constant
	// dprint("max dist = ", ftos(maxdist), "\n");

	if(maxdist <= cvar("g_ballistics_mindistance"))
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

void endFireBallisticBullet()
{
	endzcurveparticles();
}

entity fireBallisticBullet_trace_callback_ent;
float fireBallisticBullet_trace_callback_eff;
void fireBallisticBullet_trace_callback(vector start, vector hit, vector end)
{
	if(vlen(trace_endpos - fireBallisticBullet_trace_callback_ent.origin) > 16)
		zcurveparticles_from_tracetoss(fireBallisticBullet_trace_callback_eff, fireBallisticBullet_trace_callback_ent.origin, trace_endpos, fireBallisticBullet_trace_callback_ent.velocity);
}

void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float headshotbonus, float force, float dtype, float tracereffects, float gravityfactor, float bulletconstant)
{
	float lag, dt, savetime;
	entity pl, oldself;

	entity proj;
	proj = spawn();
	proj.classname = "bullet";
	proj.owner = self;
	PROJECTILE_MAKETRIGGER(proj);
	if(gravityfactor > 0)
	{
		proj.movetype = MOVETYPE_TOSS;
		proj.gravity = gravityfactor;
	}
	else
		proj.movetype = MOVETYPE_FLY;
	proj.think = SUB_Remove;
	proj.nextthink = time + lifetime; // min(pLifetime, vlen(world.maxs - world.mins) / pSpeed);
	W_SetupProjectileVelocityEx(proj, dir, v_up, pSpeed, 0, 0, spread);
	proj.angles = vectoangles(proj.velocity);
	proj.dmg_radius = cvar("g_ballistics_materialconstant") / bulletconstant;
	// so: bulletconstant = bullet mass / area of bullet circle
	setorigin(proj, start);
	proj.flags = FL_PROJECTILE;

	proj.touch = W_BallisticBullet_Touch;
	proj.dmg = damage;
	proj.dmg_edge = headshotbonus;
	proj.dmg_force = force;
	proj.projectiledeathtype = dtype;

	proj.oldvelocity = proj.velocity;

	if(cvar("g_antilag_bullets"))
	if(pSpeed >= cvar("g_antilag_bullets"))
	{
		float eff;

		if(tracereffects & EF_RED)
			eff = particleeffectnum("tr_rifle");
		else
			eff = particleeffectnum("tr_bullet");

		// NOTE: this may severely throw off weapon balance
		lag = ANTILAG_LATENCY(self);
		if(lag < 0.001)
			lag = 0;
		if(clienttype(self) != CLIENTTYPE_REAL)
			lag = 0;
		if(cvar("g_antilag") == 0 || self.cvar_cl_noantilag)
			lag = 0; // only do hitscan, but no antilag

		if(lag)
			FOR_EACH_PLAYER(pl)
				antilag_takeback(pl, time - lag);

		oldself = self;
		self = proj;

		savetime = frametime;
		frametime = 0.05;

		// update the accuracy stats - increase shots fired by 1
		if not(inWarmupStage)
		{
			oldself.stats_fired[oldself.weapon - 1] += 1;
			oldself.stat_fired = oldself.weapon + 64 * floor(oldself.stats_fired[oldself.weapon - 1]);
		}

		for(;;)
		{
			// DP tracetoss is stupid and always traces in 0.05s
			// ticks. This makes it trace in 0.05*0.125s ticks
			// instead.
			vector v0;
			float g0;
			v0 = self.velocity;
			g0 = self.gravity;
			self.velocity = self.velocity * 0.125;
			self.gravity *= 0.125 * 0.125;
			trace_fraction = 0;
			fireBallisticBullet_trace_callback_ent = self;
			fireBallisticBullet_trace_callback_eff = eff;
			WarpZone_TraceToss_ThroughZone(self, oldself, world, fireBallisticBullet_trace_callback);
			self.velocity = v0;
			self.gravity = g0;

			if(trace_fraction == 1)
				break;
				// won't hit anything anytime soon (DP's
				// tracetoss does 200 tics of, here,
				// 0.05*0.125s, that is, 1.25 seconds

			other = trace_ent;
			dt = WarpZone_tracetoss_time * 0.125; // this is only approximate!
			setorigin(self, trace_endpos);
			self.velocity = WarpZone_tracetoss_velocity * (1 / 0.125);

			if(!SUB_OwnerCheck())
			{
				if(SUB_NoImpactCheck())
					break;

				// hit the player
				W_BallisticBullet_Hit();
			}

			// go through solid!
			if(!W_BallisticBullet_LeaveSolid(self, self.velocity, self.dmg_radius))
				break;

			W_BallisticBullet_LeaveSolid_think();
		}
		frametime = savetime;
		self = oldself;

		if(lag)
			FOR_EACH_PLAYER(pl)
				antilag_restore(pl);

		remove(proj);

		return;
	}

	// update the accuracy stats
	if not(inWarmupStage)
	{
		self.stats_fired[self.weapon - 1] += 1;
		self.stat_fired = self.weapon + 64 * floor(self.stats_fired[self.weapon - 1]);
	}

	if(tracereffects & EF_RED)
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING_TRACER, TRUE);
	else if(tracereffects & EF_BLUE)
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING, TRUE);
	else
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET, TRUE);
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;

	dir = normalize(dir + randomvec() * spread);
	end = start + dir * MAX_SHOT_DISTANCE;
	if(self.antilag_debug)
		traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
	else
		traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

	end = trace_endpos;

	if ((trace_fraction != 1.0) && (pointcontents (trace_endpos) != CONTENT_SKY))
	{
		pointparticles(particleeffectnum("TE_KNIGHTSPIKE"),end,trace_plane_normal * 2500,1);
		if (trace_ent.solid == SOLID_BSP && !(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
			Damage_DamageInfo(trace_endpos, damage, 0, 0, dir * max(1, force), dtype, self);
		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
		//void(float effectnum, vector org, vector vel, float howmany) pointparticles = #337; // same as in CSQC
	}
	trace_endpos = end;
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
