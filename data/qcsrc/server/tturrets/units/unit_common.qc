float turret_tag_setup(float linked)
{
    vector v;
    float f;

    // Laters dooz
    if (linked)
        return 0;

    f = gettagindex(self,"tag_head");
    v = gettaginfo_relative(self,f);
    v = v + self.origin;
    setorigin(self.tur_head,v);

    f = gettagindex(self.tur_head,"tag_fire");
    v = gettaginfo_relative(self.tur_head,f) + (self.tur_head.origin - self.origin);
    v_y *= -1;
    self.tur_shotorg = v;

    f = gettagindex(self.tur_head,"tag_aim");
    v = gettaginfo_relative(self.tur_head,f) + (self.tur_head.origin - self.origin);
    self.tur_aimorg  = v;

    return 1;
}

float turret_tag_fire_update()
{
    vector v;
    float f;

    f = gettagindex(self.tur_head,"tag_fire");
    v = gettaginfo_relative(self.tur_head,f) + (self.tur_head.origin - self.origin);
    v_y *= -1;
    self.tur_shotorg = v;

    f = gettagindex(self.tur_head,"tag_aim");
    v = gettaginfo_relative(self.tur_head,f) + (self.tur_head.origin - self.origin);
    self.tur_aimorg  = v;

    return 1;
}

void FireImoBeam (vector start,vector end,vector smin,vector smax,
                  float bforce,float f_dmg,float f_velfactor, float deathtype)

{
    local vector hitloc, force, endpoint, dir;
    local entity ent;

    dir = normalize(end - start);
    force = dir * bforce;

    // go a little bit into the wall because we need to hit this wall later
    end = end + dir;

    // trace multiple times until we hit a wall, each obstacle will be made unsolid.
    // note down which entities were hit so we can damage them later
    while (1)
    {
        tracebox(start, smin, smax, end, FALSE, self);

        // if it is world we can't hurt it so stop now
        if (trace_ent == world || trace_fraction == 1)
            break;

        if (trace_ent.solid == SOLID_BSP)
            break;

        // make the entity non-solid so we can hit the next one
        trace_ent.railgunhit = TRUE;
        trace_ent.railgunhitloc = end;
        trace_ent.railgunhitsolidbackup = trace_ent.solid;

        // stop if this is a wall


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
        if (ent.takedamage)
        {
            Damage (ent, self, self, f_dmg, deathtype, hitloc, force);
            ent.velocity = ent.velocity * f_velfactor;
            //ent.alpha = 0.25 + random() * 0.75;
        }

        // advance to the next entity
        ent = findfloat(ent, railgunhit, TRUE);
    }
    trace_endpos = endpoint;
}

void turrets_precash()
{
    precache_model ("models/turrets/c512.md3");

    precache_sound ("turrets/phaser.ogg");

    precache_model ("models/turrets/base-gib1.md3");
    precache_model ("models/turrets/base-gib2.md3");
    precache_model ("models/turrets/base-gib3.md3");
    precache_model ("models/turrets/base-gib4.md3");

    precache_model ("models/turrets/head-gib1.md3");
    precache_model ("models/turrets/head-gib2.md3");
    precache_model ("models/turrets/head-gib3.md3");
    precache_model ("models/turrets/head-gib4.md3");

    precache_model ("models/turrets/base.md3");
    precache_model ("models/turrets/flac.md3");
    precache_model ("models/turrets/pd_proj.md3");
    precache_model ("models/turrets/reactor.md3");
    precache_model ("models/turrets/mlrs_rocket.md3");
    precache_model ("models/turrets/hellion.md3");
    precache_model ("models/turrets/hunter2.md3");
    precache_model ("models/turrets/hk.md3");
    precache_model ("models/turrets/machinegun.md3");
    precache_model ("models/turrets/rocket.md3");
    precache_model ("models/turrets/mlrs.md3");
    precache_model ("models/turrets/phaser.md3");
    precache_model ("models/turrets/phaser_beam.md3");
    precache_model ("models/turrets/plasmad.md3");
    precache_model ("models/turrets/plasma.md3");
    precache_model ("models/turrets/tesla_head.md3");
    precache_model ("models/turrets/tesla_base.md3");
}
