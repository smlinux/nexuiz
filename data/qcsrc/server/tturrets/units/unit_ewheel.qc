void turret_ewheel_projectile_explode()
{
    vector org2;

    org2 = findbetterlocation (self.origin, 8);
    pointparticles(particleeffectnum("laser_impact"), org2, trace_plane_normal * 1000, 1);
    //w_deathtypestring = "saw the eweel. to late.";
#ifdef TURRET_DEBUG
    float d;

    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif
    sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);

    remove (self);
}


void ewheel_attack()
{
    entity proj;
    float i;

    for (i=0;i<1;++i)
    {
        turret_do_updates(self);

        sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg, self.tur_shotdir_updated * 1000, 1);

        proj                    = spawn ();
        setorigin(proj, self.tur_shotorg);
        //setsize(proj, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');
        //setmodel(proj, "models/laser.mdl"); // precision set above
        proj.classname       = "ewheel bolt";
        proj.owner           = self;
        proj.bot_dodge       = FALSE;
        proj.bot_dodgerating = self.shot_dmg;
        proj.think           = turret_ewheel_projectile_explode;
        proj.nextthink       = time + 9;
        proj.solid           = SOLID_BBOX;
        proj.movetype        = MOVETYPE_FLYMISSILE;
        proj.velocity        = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
        proj.angles          = vectoangles(proj.velocity);
        proj.touch           = turret_ewheel_projectile_explode;
        //proj.effects         = EF_LOWPRECISION |  EF_BRIGHTFIELD;
        proj.enemy           = self.enemy;
        proj.flags           = FL_PROJECTILE | FL_NOTARGET;

        CSQCProjectile(proj, TRUE, PROJECTILE_LASER, TRUE);

        self.tur_head.frame += 2;

        if (self.tur_head.frame > 3)
            self.tur_head.frame = 0;
    }

}

float ewheel_moveverb_path(float eval)
{
    switch (eval)
    {
    case VCM_EVAL:

        if (self.pathcurrent)
            return verb.verb_static_value;

        return VS_CALL_NO;

    case VCM_DO:
        // Do we have a path?
        if not(self.pathcurrent)
            return VS_CALL_NO;
        else
        {
            // Are we close enougth to a path node to switch to the next?
            if (vlen(self.origin  - self.pathcurrent.origin) < 32)
                if (self.pathcurrent.path_next == world)
                {
                    // Path endpoint reached
                    pathlib_deletepath(self.pathcurrent.owner);
                    self.pathcurrent = world;

                    if (self.pathgoal)
                    {
                        if (self.pathgoal.use)
                            self.pathgoal.use();

                        if (self.pathgoal.enemy)
                        {
                            self.pathcurrent = pathlib_astar(self.pathgoal.origin,self.pathgoal.enemy.origin);
                            self.pathgoal = self.pathgoal.enemy;
                        }
                    }
                    else
                        self.pathgoal = world;
                }
                else
                    self.pathcurrent = self.pathcurrent.path_next;
        }


        if (self.pathcurrent)
        {
            switch (self.waterlevel)
            {
            case 0:
            case 1:
            case 2:
            case 3:
            }

            self.moveto = self.pathcurrent.origin;
            self.steerto = steerlib_attract2(self.moveto,0.5,500,0.95);

            self.frame += 1;
            movelib_move_simple(v_forward,cvar("g_turrets_unit_ewheel_speed_slow"),0.4);

            return VS_CALL_YES_DOING;
        }
        else
            return VS_CALL_YES_DONE;

    case VCM_REMOVE:

        if (self.pathcurrent)
            pathlib_deletepath(self.pathcurrent.owner);

        self.pathcurrent = world;

        return VS_CALL_YES_DONE;
    }

    return VS_CALL_YES_DONE;
}

float ewheel_moveverb_enemy(float eval)
{
    switch (eval)
    {
    case VCM_EVAL:
        if (self.enemy)
        {
            if (self.spawnflags & TSF_NO_PATHBREAK)
                if (self.pathcurrent)
                    return VS_CALL_NO;

            return verb.verb_static_value;
        }

        return VS_CALL_NO;

    case VCM_DO:

        self.moveto  = self.enemy.origin;
        self.steerto = steerlib_arrive(self.enemy.origin,self.target_range_optimal);

        if (self.tur_dist_enemy > self.target_range_optimal)
        {
            if ( self.tur_head.spawnshieldtime < 1 )
            {
                self.frame += 2;
                movelib_move_simple(v_forward ,cvar("g_turrets_unit_ewheel_speed_fast"),0.4);
            }
            else if (self.tur_head.spawnshieldtime < 2)
            {
                self.frame += 1;
                movelib_move_simple(v_forward,cvar("g_turrets_unit_ewheel_speed_slow"),0.4);
            }
            else
            {
                self.frame += 1;
                movelib_move_simple(v_forward,cvar("g_turrets_unit_ewheel_speed_slower"),0.4);
            }
        }
        else if (self.tur_dist_enemy < self.target_range_min)
        {
            self.frame -= 1;
            movelib_move_simple(v_forward * -1,cvar("g_turrets_unit_ewheel_speed_slow"),0.4);
        }
        else
        {
            movelib_beak_simple(cvar("g_turrets_unit_ewheel_speed_stop"));
        }

        return VS_CALL_YES_DOING;
    }


    return VS_CALL_YES_DONE;
}

float ewheel_moveverb_runaway(float eval)
{
    switch (eval)
    {
    case VCM_EVAL:
        if (self.spawnflags & TSF_NO_PATHBREAK)
            if (self.pathcurrent)
                return VS_CALL_NO;

        if (self.enemy)
            if (self.health < 50)
                return verb.verb_static_value;

        return VS_CALL_NO;

    case VCM_DO:
        self.steerto = (steerlib_push(self.enemy.origin) * 0.7) + (steerlib_traceavoid_flat(0.3, 500, '0 0 128') * 0.3);
        self.moveto  = self.origin + self.steerto * 1000;

        self.frame += 2;
        movelib_move_simple(v_forward ,cvar("g_turrets_unit_ewheel_speed_fast"),0.4);

        return VS_CALL_YES_DOING;

    }

    return VS_CALL_YES_DONE;
}

float ewheel_moveverb_idle(float eval)
{
    switch (eval)
    {
    case VCM_EVAL:
        if (self.enemy)
            return VS_CALL_NO;

        return verb.verb_static_value;

    case VCM_DO:
        self.moveto = self.origin;

        if (vlen(self.velocity))
            movelib_beak_simple(cvar("g_turrets_unit_ewheel_speed_stop"));

        return VS_CALL_YES_DOING;
    }

    return VS_CALL_YES_DONE;
}

void ewheel_postthink()
{
    float vz;
    vector wish_angle,real_angle;

    vz = self.velocity_z;

    self.angles_x = anglemods(self.angles_x);
    self.angles_y = anglemods(self.angles_y);

    self.angles_x *= -1;
    makevectors(self.angles);
    self.angles_x *= -1;

    wish_angle = normalize(self.steerto);
    wish_angle = vectoangles(wish_angle);
    real_angle = wish_angle - self.angles;
    real_angle = shortangle_vxy(real_angle,self.tur_head.angles);

    self.tur_head.spawnshieldtime = fabs(real_angle_y);
    real_angle_y  = bound(self.tur_head.aim_speed * -1,real_angle_y,self.tur_head.aim_speed);
    self.angles_y = (self.angles_y + real_angle_y);

    // Simulate banking
    self.angles_z = bound(-45,real_angle_y * -2.5,45);

    verbstack_pop(self.verbs_move);

    if (self.frame > 40)
        self.frame = 1;

    if (self.frame < 1)
        self.frame = 40;


    self.velocity_z = vz;
}

void ewheel_respawnhook()
{
    entity e;

    setorigin(self,self.pos1);

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            dprint("Initital waypoint for ewheel does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
            self.pathcurrent = WALKER_PATH(self.origin,e.origin);
            self.pathgoal = e;
        }
    }
}

void ewheel_diehook()
{
    turret_trowgib2(self.origin,self.velocity + v_up * 400,'-0.6 -0.2 -02',self,time + random() * 2 +3);

    if (self.pathcurrent)
        pathlib_deletepath(self.pathcurrent.owner);

    self.pathcurrent = world;

    if (self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
    {
        verbstack_flush(self.verbs_move);
        remove(self.verbs_move);
    }

}

void turret_ewheel_dinit()
{
    entity e;

    if (self.netname == "")      self.netname     = "eWheel Turret";

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            bprint("Warning! initital waypoint for ewheel does NOT exsist!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
            self.goalcurrent = e;
    }

    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE | TFL_TURRCAPS_ROAM | TFL_TURRCAPS_HEADATTACHED;
    //self.aim_flags = TFL_AIM_SIMPLE;// TFL_AIM_LEAD | TFL_AIM_ZEASE;

    self.turret_respawnhook = ewheel_respawnhook;
    self.turret_diehook = ewheel_diehook;

    if (turret_stdproc_init("ewheel_std") == 0)
    {
        remove(self);
        return;
    }

    self.target_select_flags   = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.damage_flags          |= TFL_DMG_DEATH_NOGIBS;

    self.iscreature = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;

    setmodel(self,"models/turrets/ewheel-base.md3");
    setmodel(self.tur_head,"models/turrets/ewheel-gun1.md3");
    setattachment(self.tur_head,self,"tag_head");

    self.pos1 = self.origin;

    self.idle_aim = '0 0 0';

    // Our fire routine
    self.turret_firefunc  = ewheel_attack;
    self.turret_postthink = ewheel_postthink;
    self.tur_head.frame = 1;

    self.verbs_move = spawn();
    verbstack_push(self.verbs_move, ewheel_moveverb_idle,   WVM_IDLE,  0);
    verbstack_push(self.verbs_move, ewheel_moveverb_enemy,  WVM_ENEMY, 0);
    verbstack_push(self.verbs_move, ewheel_moveverb_path,   WVM_PATH,  0);
    verbstack_push(self.verbs_move, ewheel_moveverb_runaway,WVM_PANIC,  0);

    // Convert from dgr / sec to dgr / tic
    self.tur_head.aim_speed = cvar("g_turrets_unit_ewheel_turnrate");
    self.tur_head.aim_speed = self.tur_head.aim_speed / (1 / self.ticrate);

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            dprint("Initital waypoint for ewheel does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
            self.pathcurrent = WALKER_PATH(self.origin,e.origin);
            self.pathgoal = e;
        }
    }
}

void spawnfunc_turret_ewheel()
{
    precache_model ("models/turrets/ewheel-base.md3");
    precache_model ("models/turrets/ewheel-gun1.md3");

    self.think = turret_ewheel_dinit;
    self.nextthink = time + 0.5;
}
