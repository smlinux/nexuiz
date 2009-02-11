#define cvar_base "g_turrets_unit_"

//.float tur_lastscore;
.string cvar_basename;

string cvar_gets(string s_base,string s_add)
{
    return strcat(s_base,s_add);
}

.float turret_scale_damage;
.float turret_scale_range;
.float turret_scale_refire;
.float turret_scale_ammo;
.float turret_scale_aim;
.float turret_scale_health;
.float turret_scale_respawn;

void load_unit_settings(entity ent,string unitname,float is_reload)
{

    string sbase;

    if (ent == world)
        return;

    if (!ent.turret_scale_damage)    ent.turret_scale_damage  = 1;
    if (!ent.turret_scale_range)     ent.turret_scale_range   = 1;
    if (!ent.turret_scale_refire)    ent.turret_scale_refire  = 1;
    if (!ent.turret_scale_ammo)      ent.turret_scale_ammo    = 1;
    if (!ent.turret_scale_aim)       ent.turret_scale_aim     = 1;
    if (!ent.turret_scale_health)    ent.turret_scale_health  = 1;
    if (!ent.turret_scale_respawn)   ent.turret_scale_respawn = 1;

    sbase = strcat(cvar_base,unitname);
    if (is_reload)
    {
        ent.enemy = world;
        ent.tur_head.avelocity = '0 0 0';
        ent.tur_head.angles = ent.angles;
    }
    ent.health = cvar(cvar_gets(sbase,"_health")) * ent.turret_scale_health;
    ent.respawntime = cvar(cvar_gets(sbase,"_respawntime")) * ent.turret_scale_respawn;

    ent.shot_dmg = cvar(cvar_gets(sbase,"_shot_dmg")) * ent.turret_scale_damage;
    ent.shot_refire = cvar(cvar_gets(sbase,"_shot_refire")) * ent.turret_scale_refire;
    ent.shot_radius = cvar(cvar_gets(sbase,"_shot_radius")) * ent.turret_scale_damage;
    ent.shot_speed = cvar(cvar_gets(sbase,"_shot_speed"));
    ent.shot_spread = cvar(cvar_gets(sbase,"_shot_spread"));
    ent.shot_force = cvar(cvar_gets(sbase,"_shot_force")) * ent.turret_scale_damage;
    ent.shot_volly = cvar(cvar_gets(sbase,"_shot_volly"));
    ent.shot_volly_refire = cvar(cvar_gets(sbase,"_shot_volly_refire")) * ent.turret_scale_refire;

    ent.target_range = cvar(cvar_gets(sbase,"_target_range")) * ent.turret_scale_range;
    ent.target_range_min = cvar(cvar_gets(sbase,"_target_range_min")) * ent.turret_scale_range;
    ent.target_range_fire = cvar(cvar_gets(sbase,"_target_range_fire")) * ent.turret_scale_range;
    ent.target_range_optimal = cvar(cvar_gets(sbase,"_target_range_optimal")) * ent.turret_scale_range;

    ent.target_select_rangebias = cvar(cvar_gets(sbase,"_target_select_rangebias"));
    ent.target_select_samebias = cvar(cvar_gets(sbase,"_target_select_samebias"));
    ent.target_select_anglebias = cvar(cvar_gets(sbase,"_target_select_anglebias"));
    ent.target_select_playerbias = cvar(cvar_gets(sbase,"_target_select_playerbias"));

    ent.ammo_max = cvar(cvar_gets(sbase,"_ammo_max")) * ent.turret_scale_ammo;
    //ent.ammo = cvar(cvar_gets(sbase,"_ammo"));
    ent.ammo_recharge = cvar(cvar_gets(sbase,"_ammo_recharge")) * ent.turret_scale_ammo;

    ent.aim_firetolerance_dist = cvar(cvar_gets(sbase,"_aim_firetolerance_dist"));
//    ent.aim_firetolerance_angle = cvar(cvar_gets(sbase,"_aim_firetolerance_angle"));
    ent.aim_speed = cvar(cvar_gets(sbase,"_aim_speed")) * ent.turret_scale_aim;
    ent.aim_maxrot = cvar(cvar_gets(sbase,"_aim_maxrot"));
    ent.aim_maxpitch = cvar(cvar_gets(sbase,"_aim_maxpitch"));

    ent.track_type = cvar(cvar_gets(sbase,"_track_type"));
    ent.track_accel_pitch = cvar(cvar_gets(sbase,"_track_accel_pitch"));
    ent.track_accel_rot = cvar(cvar_gets(sbase,"_track_accel_rot"));
    ent.track_blendrate = cvar(cvar_gets(sbase,"_track_blendrate"));
}

float turret_stdproc_true()
{
    return 1;
}

float turret_stdproc_false()
{
    return 0;
}

void turret_stdproc_nothing()
{
    return;
}

/**
** updates enemy distances, preicted impact point/time
** & aim<->predict impact distance.
** Also translates shoot & aimorgs by current rotation.
**/
void turret_do_updates(entity e_turret)
{
    vector enemy_pos;

    if (self.turrcaps_flags & TFL_TURRCAPS_LINKED)
    {
        e_turret.tur_head.angles_x = e_turret.tur_head.angles_x * -1;
        e_turret.angles_x = e_turret.angles_x * -1;
        makevectors(e_turret.tur_head.angles + e_turret.angles);
        e_turret.tur_head.angles_x = e_turret.tur_head.angles_x * -1;
        e_turret.angles_x = e_turret.angles_x * -1;
    }
    else
    {
        e_turret.tur_head.angles_x = e_turret.tur_head.angles_x * -1;
        makevectors(e_turret.tur_head.angles);
        e_turret.tur_head.angles_x = e_turret.tur_head.angles_x * -1;
    }
    enemy_pos = real_origin(e_turret.enemy);

    e_turret.tur_shotorg_updated = e_turret.origin + v_forward * e_turret.tur_shotorg_x + v_right * e_turret.tur_shotorg_y + v_up * e_turret.tur_shotorg_z;
    e_turret.tur_aimorg_updated = e_turret.origin + v_forward * e_turret.tur_aimorg_x + v_right * e_turret.tur_aimorg_y + v_up * e_turret.tur_aimorg_z;
    e_turret.tur_shotdir_updated = v_forward; // normalize((e_turret.tur_shotorg_updated + v_forward) - e_turret.tur_shotorg_updated);

    e_turret.tur_dist_enemy = vlen(e_turret.tur_aimorg_updated - enemy_pos);
    e_turret.tur_dist_aimpos = vlen(e_turret.tur_aimorg_updated - e_turret.tur_aimpos);

    //traceline(e_turret.tur_aimorg_updated,e_turret.tur_aimorg_updated + (e_turret.tur_shotdir_updated * e_turret.tur_dist_aimpos),MOVE_NORMAL,e_turret);
    tracebox(e_turret.tur_aimorg_updated, '-1 -1 -1','1 1 1',e_turret.tur_aimorg_updated + (e_turret.tur_shotdir_updated * e_turret.tur_dist_aimpos),MOVE_NORMAL,e_turret);

    //traceline(e_turret.tur_aimorg_updated,e_turret.tur_aimpos,MOVE_NORMAL,e_turret);

    e_turret.tur_impactpoint = trace_endpos;
    e_turret.tur_impactent = trace_ent;
    e_turret.tur_dist_impact_to_aimpos = vlen(trace_endpos - e_turret.tur_aimpos);
    e_turret.tur_impacttime = vlen(e_turret.tur_aimorg_updated - trace_endpos) / e_turret.shot_speed;


/*
.float      tur_dist_enemy;
.float      tur_dist_aimpos;
.float      tur_dist_impact_to_aimpos;
*/

}

/**
** Handles head rotation according to
** the units .track_type and .track_flags
**/
void turret_stdproc_track()
{
    vector wish_angle;  // This is where we want to aim

    vector real_angle;  // This is where we can aim
    float f_tmp;


    if (self.track_flags == TFL_TRACK_NO)
        return;

    if(!self.tur_active)
    {
        wish_angle = self.idle_aim - ('1 0 0' * self.aim_maxpitch);
    }
    else if (self.enemy == world)
    {
        if (self.turrcaps_flags & TFL_TURRCAPS_LINKED)
            wish_angle = self.idle_aim + self.angles;
        else
            if(time > self.lip)
                wish_angle = self.idle_aim;
            else
                wish_angle = self.tur_head.angles;

    }
    else
    {
        // Find the direction
        if (self.turrcaps_flags & TFL_TURRCAPS_LINKED)
            wish_angle = normalize(self.tur_aimpos - self.origin);
        else
            wish_angle = normalize(self.tur_aimpos - self.tur_head.origin);

        wish_angle = vectoangles(wish_angle); // And make a angle
    }

    // Find the diffrence between where we currently aim and where we want to aim
    if (self.turrcaps_flags & TFL_TURRCAPS_LINKED)
        real_angle = wish_angle - (self.angles + self.tur_head.angles);
    else
    {
        real_angle = wish_angle - self.tur_head.angles;

    }

    if(real_angle_x > self.tur_head.angles_x)
    {
        if(real_angle_x >= 180)
            real_angle_x -= 360;
    }
    else
    {
        if(real_angle_x <= -180)
            real_angle_x += 360;
    }
    if(real_angle_y > self.tur_head.angles_y)
    {
        if(real_angle_y >= 180)
            real_angle_y -= 360;
    }
    else
    {
        if(real_angle_y <= -180)
            real_angle_y += 360;
    }

    // Limit pitch

    if (self.track_flags & TFL_TRACK_PITCH)
        real_angle_x = bound(self.aim_maxpitch * -1,real_angle_x,self.aim_maxpitch);

    // Limit rot
    if (self.track_flags & TFL_TRACK_ROT)
        real_angle_y = bound(self.aim_maxrot * -1,real_angle_y,self.aim_maxrot);


    if (self.track_type == TFL_TRACKTYPE_STEPMOTOR)
    {
        f_tmp = self.aim_speed * self.ticrate; // dgr/sec -> dgr/tic

        // Limit turning speed
        real_angle_x = bound((-1 * f_tmp),real_angle_x, f_tmp);
        real_angle_y = bound((-1 * f_tmp),real_angle_y, f_tmp);

        // Limit pich and rot.
        if (self.track_flags & TFL_TRACK_PITCH)
            self.tur_head.angles_x = bound((-1 * self.aim_maxpitch),self.tur_head.angles_x + real_angle_x,self.aim_maxpitch);

        if (self.track_flags & TFL_TRACK_ROT)
            self.tur_head.angles_y = bound((-1 * self.aim_maxrot),self.tur_head.angles_y  + real_angle_y,self.aim_maxrot);

        return;
    }

    if (self.track_type == TFL_TRACKTYPE_FLUIDPRECISE)
    {
        if (self.track_flags & TFL_TRACK_PITCH)
            self.tur_head.avelocity_x = real_angle_x;

        if (self.track_flags & TFL_TRACK_ROT)
            self.tur_head.avelocity_y = real_angle_y;
    }
    else if (self.track_type == TFL_TRACKTYPE_FLUIDINERTIA)
    {
        f_tmp = self.aim_speed * self.ticrate;

        real_angle_y = bound(self.aim_speed * -1,real_angle_y * self.track_accel_rot * f_tmp,self.aim_speed);
        real_angle_x = bound(self.aim_speed * -1,real_angle_x * self.track_accel_pitch * f_tmp,self.aim_speed);
        real_angle = (self.tur_head.avelocity * self.track_blendrate) + (real_angle * (1 - self.track_blendrate));

        if (self.track_flags & TFL_TRACK_PITCH) self.tur_head.avelocity_x = real_angle_x;
        if (self.track_flags & TFL_TRACK_ROT)   self.tur_head.avelocity_y = real_angle_y;
        self.tur_head.avelocity_z = real_angle_z;
        setsize(self,self.mins,self.maxs);
    }

    // Limit pitch
    /*
    if (self.track_flags & TFL_TRACK_PITCH)
    {
        if (self.tur_head.angles_x > self.aim_maxpitch)
        {
            self.tur_head.angles_x = self.aim_maxpitch;
            self.tur_head.avelocity_x = 0;
        }
        else if (self.tur_head.angles_x < (self.aim_maxpitch * -1))
        {
            self.tur_head.angles_x = (self.aim_maxpitch * -1);
            self.tur_head.avelocity_x = 0;
        }
    }

    // Limit rot
    if (self.track_flags & TFL_TRACK_ROT)
    {
        if (self.tur_head.angles_y > self.aim_maxrot)
        {
            self.tur_head.angles_y = self.aim_maxrot;
            self.tur_head.avelocity_y = 0;
        }
        else if (self.tur_head.angles_y < (self.aim_maxrot * -1))
        {
            self.tur_head.angles_y = (self.aim_maxrot * -1);
            self.tur_head.avelocity_y = 0;
        }
    }
    */


}

/*
 + = implemented
 - = not implemented

 + TFL_FIRECHECK_NO
 + TFL_FIRECHECK_WORLD
 + TFL_FIRECHECK_DEAD
 + TFL_FIRECHECK_DISTANCES
 - TFL_FIRECHECK_LOS
 + TFL_FIRECHECK_AIMDIST
 + TFL_FIRECHECK_REALDIST
 - TFL_FIRECHECK_ANGLEDIST
 - TFL_FIRECHECK_TEAMCECK
 + TFL_FIRECHECK_AFF
 + TFL_FIRECHECK_OWM_AMMO
 + TFL_FIRECHECK_OTHER_AMMO
 + TFL_FIRECHECK_REFIRE
*/

/**
** Preforms pre-fire checks based on the uints firecheck_flags
**/
float turret_stdproc_firecheck()
{
    // This one just dont care =)
    if (self.firecheck_flags & TFL_FIRECHECK_NO) return 1;

    // Ready?
    if (self.firecheck_flags & TFL_FIRECHECK_REFIRE)
        if (self.attack_finished_single >= time) return 0;

    // Special case..
    if((self.shoot_flags & TFL_SHOOT_VOLLYALWAYS) && (self.volly_counter != self.shot_volly))
    {
        return 1;
    }


    //
    if (self.firecheck_flags & TFL_FIRECHECK_DEAD)
        if (self.enemy.deadflag != DEAD_NO) return 0;

    // Plz stop killing the world!
    if (self.firecheck_flags & TFL_FIRECHECK_WORLD)
        if (self.enemy == world) return 0;

    // Own ammo?
    if (self.firecheck_flags & TFL_FIRECHECK_OWM_AMMO)
        if (self.ammo < self.shot_dmg) return 0;

    // Other's ammo? (support-supply units)
    if (self.firecheck_flags & TFL_FIRECHECK_OTHER_AMMO)
        if (self.enemy.ammo >= self.enemy.ammo_max) return 0;

    if (self.firecheck_flags & TFL_FIRECHECK_DISTANCES)
    {
        // Not close enougth?
        if (self.tur_dist_aimpos > self.target_range_fire) return 0;

        // To close?
        if (self.tur_dist_aimpos < self.target_range_min) return 0;
    }

    // Try to avoid FF?
    if (self.firecheck_flags & TFL_FIRECHECK_AFF)
        if (self.tur_impactent.team == self.team) return 0;

    // aim<->predicted impact
    if (self.firecheck_flags & TFL_FIRECHECK_AIMDIST)
        if (self.tur_dist_impact_to_aimpos  > self.aim_firetolerance_dist) return 0;

    // Volly status
    if (self.shot_volly > 1)
    {
        if (self.volly_counter == self.shot_volly)
            if (self.ammo < (self.shot_dmg * self.shot_volly))
                return 0;
    }

    //if(self.tur_enemy_adist >= self.aim_firetolerance) return 0;


    return 1;
}

/*
 + TFL_TARGETSELECT_NO
 + TFL_TARGETSELECT_LOS
 + TFL_TARGETSELECT_PLAYERS
 + TFL_TARGETSELECT_MISSILES
 - TFL_TARGETSELECT_TRIGGERTARGET
 + TFL_TARGETSELECT_ANGLELIMITS
 + TFL_TARGETSELECT_RANGELIMTS
 + TFL_TARGETSELECT_TEAMCHECK
 - TFL_TARGETSELECT_NOBUILTIN
 + TFL_TARGETSELECT_OWNTEAM
*/

/**
** Evaluate a entity for target valitity based on validate_flags
**/
float turret_validate_target(entity e_turret,entity e_target,float validate_flags)
{
    vector v_tmp;

    //if(!validate_flags & TFL_TARGETSELECT_NOBUILTIN)
    //    return -0.5;

    if (!e_target)// == world)
        return -1;

    if (e_target.classname == "grapplinghook")
        return - 1.5;

	if(g_onslaught)
		if (substring(e_target.classname, 0, 10) == "onslaught_") // don't attack onslaught targets, that's the player's job!
			return - 1.75;

    if (validate_flags & TFL_TARGETSELECT_NO)
        return -2;

    // If only this was used more..
    if (e_target.flags & FL_NOTARGET)
        return -3;

    // Cant touch this
    if ((e_target.takedamage == DAMAGE_NO) || (e_target.health < 0))
        return -4;

    // player
    if (e_target.flags & FL_CLIENT)
    {
        if (!(validate_flags & TFL_TARGETSELECT_PLAYERS))
            return -5;

        if (e_target.deadflag != DEAD_NO)
            return -6;
    }

	// enemy turrets
	if (e_target.turret_firefunc || e_target.owner.tur_head == e_target)
	{
		if (validate_flags & TFL_TARGETSELECT_NOTURRETS)
			return -5.5;
	}


    // Missile
    if (e_target.flags & FL_PROJECTILE)
    {
        if (!(validate_flags & TFL_TARGETSELECT_MISSILES))
            return -7;
    }

    // Team check
    if (validate_flags & TFL_TARGETSELECT_TEAMCHECK)
    {
        if (validate_flags & TFL_TARGETSELECT_OWNTEAM)
        {
            if (e_target.team != e_turret.team)
                return -8;

            if (e_turret.team != e_target.owner.team)
                return -8.5;
        }
        else
        {
            if (e_target.team == e_turret.team)
                return -9;

            if (e_turret.team == e_target.owner.team)
                return -9.5;
        }
    }

    // Range limits?
    tvt_dist = vlen(e_turret.origin - real_origin(e_target));
    if (validate_flags & TFL_TARGETSELECT_RANGELIMTS)
    {
        if (tvt_dist < e_turret.target_range_min)
            return -13;

        if (tvt_dist > e_turret.target_range)
            return -14;
    }

    // Can we even aim this thing?
    tvt_thadv = angleofs(e_turret.tur_head,e_target);
    tvt_tadv  = angleofs(e_turret,e_target);
    tvt_thadf = vlen(tvt_thadv);
    tvt_tadf  = vlen(tvt_tadv);

    if (validate_flags & TFL_TARGETSELECT_ANGLELIMITS)
    {
        if (fabs(tvt_tadv_x) > e_turret.aim_maxpitch)
            return -11;

        if (fabs(tvt_tadv_y) > e_turret.aim_maxrot)
            return -12;
    }

    // Line of sight?
    if (validate_flags & TFL_TARGETSELECT_LOS)
    {
        v_tmp = real_origin(e_target) + ((e_target.mins + e_target.maxs) * 0.5);
        //v_tmp = e_target.origin;
        traceline(e_turret.origin + e_turret.tur_aimorg,v_tmp,0,e_turret);

        if (e_turret.aim_firetolerance_dist < vlen(v_tmp - trace_endpos))
            return -10;
    }

#ifdef TURRET_DEBUG_TARGETSELECT
    bprint("Target:",e_target.netname," is a valid target for ",e_turret.netname,"\n");
#endif

    return 1;
}

entity turret_select_target()
{
    entity e;        // target looper entity
    float  score;    // target looper entity score
    entity e_enemy;  // currently best scoreing target
    float  m_score;  // currently best scoreing target's score
    float f;

    m_score = 0;
    if(self.enemy)
    if(turret_validate_target(self,self.enemy,self.target_select_flags) > 0)
    {
        e_enemy = self.enemy;
        m_score = self.turret_score_target(self,e_enemy) * self.target_select_samebias;
    }

    e = findradius(self.origin,self.target_range);

    // Nothing to aim at?
    if (!e) return world;

    while (e)
    {
        f = turret_validate_target(self,e,self.target_select_flags);
        if (f > 0)
        {
            score = self.turret_score_target(self,e);
            if ((score > m_score) && (score > 0))
            {
                e_enemy = e;
                m_score = score;
            }
        }
        e = e.chain;
    }

    return e_enemy;
}

void turret_think()
{
    entity e;

    self.nextthink = (time + self.ticrate);

    // ONS uses somewhat backwards linking.
    if (teamplay)
    {
        if (g_onslaught)
        {

        }
        else
        {
            if (self.target)
            {
                e = find(world,targetname,self.target);
                if (e != world)
                    self.team = e.team;
            }
        }

        if (self.team != self.tur_head.team)
            turret_stdproc_respawn();
    }


    if (cvar("g_turrets_reloadcvars") == 1)
    {
        e = nextent(world);
        while (e)
        {
            if (e.tur_head != world)
            {

                load_unit_settings(e,e.cvar_basename,1);
                e.turret_postthink();
            }

            e = nextent(e);
        }

        cvar_set("g_turrets_reloadcvars","0");
    }

#ifdef TURRET_DEBUG
    if (self.tur_dbg_tmr1 < time)
    {
        if (self.enemy) paint_target (self.enemy,128,self.tur_dbg_rvec,0.9);
        paint_target(self,256,self.tur_dbg_rvec,0.9);
        self.tur_dbg_tmr1 = time + 1;
    }
#endif

    //Do custom prethink, and bail if it fails.
    //if (!self.turret_prethink()) return;

    // Handle ammo
    if (self.ammo < self.ammo_max)
        self.ammo = min(self.ammo + self.ammo_recharge,self.ammo_max);


    // Inactive turrets needs to run the think loop too
    // So they can handle animation and wake up if need be.
    if(!self.tur_active)
    {
        turret_stdproc_track();
        return;
    }

    //This is just wrong :|
    if(self.deadflag != DEAD_NO)
    {
        dprint("Warning:dead turret running the think function!\n");
        //self.enemy = world;
        //turret_stdproc_track();
        return;
    }

    // This is typicaly used for zaping every target in range
    // turret_fusionreactor uses this to recharge friendlys.
    if (self.shoot_flags & TFL_SHOOT_HITALLVALID)
    {

        // Do a self.turret_fire for every valid target.
        e = findradius(self.origin,self.target_range);

        while (e)
        {
            if (turret_validate_target(self,e,self.target_validate_flags))
            {
                self.enemy = e;

                turret_do_updates(self);

                if ( self.turret_firecheckfunc() ) turret_fire();
            }

            e = e.chain;
        }
        self.enemy = world;

    }
    else
    {
        // Special case for volly always. if it fired once it must compleate the volly.
        if((self.shoot_flags & TFL_SHOOT_VOLLYALWAYS) && (self.volly_counter != self.shot_volly))
        {
            // Predict or whatnot
            if not((self.aim_flags & TFL_AIM_NO))
                self.tur_aimpos = turret_stdproc_aim_generic();


            // Turn & pitch
            if (!self.track_flags & TFL_TRACK_NO)
                turret_stdproc_track();

            turret_do_updates(self);

            // Fire!
            if (self.turret_firecheckfunc() != 0)
                turret_fire();

            self.turret_postthink();

            return;
        }

        // Check if we have a vailid enemy, and try to find one if we dont.
        if ((turret_validate_target(self,self.enemy,self.target_validate_flags) <= 0) && (self.cnt < time))
        {
            self.enemy = turret_select_target();
            self.cnt = time + cvar("g_turrets_targetscan_mindelay");
        }


        // No target, just go to idle, do any custom stuff and bail.
        if (self.enemy == world)
        {
            // Turn & pitch
            if (!self.track_flags & TFL_TRACK_NO)
                turret_stdproc_track();

            // do any per-turret stuff
            self.turret_postthink();

            // And bail.
            return;
        }
        else
            self.lip = time + cvar("g_turrets_aimidle_delay"); // Keep track of the last time we had a target.

        //turret_do_updates(self);

        // Predict or whatnot
        if not((self.aim_flags & TFL_AIM_NO))
            self.tur_aimpos = turret_stdproc_aim_generic();

        // Fire?
        //if (self.turret_firecheckfunc() != 0)
        //    turret_fire();

        //turret_do_updates(self);

        // Turn & pitch
        if (!self.track_flags & TFL_TRACK_NO)
            turret_stdproc_track();

        turret_do_updates(self);

        // Fire?
        if (self.turret_firecheckfunc() != 0)
            turret_fire();
    }

    // do any per-turret stuff
    self.turret_postthink();
}

void turret_fire()
{
    if (cvar("g_turrets_nofire") != 0)
        return;

    if ((!self.tur_active) || (self.deadflag != DEAD_NO))
        return;

    self.turret_firefunc();

    self.attack_finished_single = time + self.shot_refire;
    self.ammo                   = self.ammo - self.shot_dmg;
    self.volly_counter          = self.volly_counter - 1;
    if (self.volly_counter <= 0)
    {
        self.volly_counter = self.shot_volly;

        if (self.shoot_flags & TFL_SHOOT_CLEARTARGET)
            self.enemy = world;

        if (self.shot_volly > 1)
            self.attack_finished_single = time + self.shot_volly_refire;
    }


#ifdef TURRET_DEBUG
    if (self.enemy) paint_target3(self.tur_aimpos, 64, self.tur_dbg_rvec, self.tur_impacttime + 0.25);
#endif
}

void turret_stdproc_fire()
{
    dprint("^1Bang, ^3your dead^7 ",self.enemy.netname,"! ^1(turret with no real firefunc)\n");
}

/*
    When .used a turret switched team to activator.team.
    If activator is world, the turrets goes inactive.
*/
void turret_stdproc_use()
{
     //bprint("Used:",self.netname, " By ",other.classname,"\n");

    self.team = activator.team;

    if(self.team == 0)
        self.tur_active = 0;
    else
        self.tur_active = 1;

}

/*
* Standard turret initialization. use this!
* (unless you have a very good reason not to.)
* Any special stuff like multiple cannon models should be done
* after this is proc called.
* if the return value is 0, the turret should be removed.
*/
float turret_stdproc_init (string cvar_base_name)
{
	entity e;

    // Are turrets allowed atm?
    if (cvar("g_turrets") == 0) return 0;

    // Better more then once then never.
    // turret_gibs_precash();

    if (self.spawnflags & 2)
    {
        entity tb;
        precache_model("models/turrets/terrainbase.md3");
        tb = spawn();
        setmodel(tb,"models/turrets/terrainbase.md3");
        setorigin(tb,self.origin);
        tb.solid = SOLID_BBOX;
        makestatic(tb);
    }

    self.cvar_basename = cvar_base_name;
    load_unit_settings(self,self.cvar_basename,0);

    // Group all turrets into the same team if in non teamplaymode, so they dont try to kill eachother.
    if (cvar("g_assult") != 0)
    {
        if (!self.team)
            self.team = 14; // Assume turrets are on the defending side if not explicitly set otehrwize
    }
    else if (!teamplay)
		self.team = MAX_SHOT_DISTANCE;
	else if(g_onslaught && self.targetname)
	{
		e = find(world,target,self.targetname);
		if(e != world)
			self.team = e.team;
	}
	else if(!self.team)
		self.team = MAX_SHOT_DISTANCE;


    /*
    * Try to guess some reasonaly defaults
    * for missing params and do sanety checks
    * thise checks could produce some "interesting" results
    * if it hits a glitch in my logic :P so try to set as mutch
    * as possible beforehand.
    */
    if (self.turrcaps_flags & TFL_TURRCAPS_SUPPORT)
    {
        // Support units generaly dont need to have a high speed ai-loop
        if (!self.ticrate) self.ticrate = 0.25;     // Speed of this turrets AI loop
    }
    else
    {
        if (!self.ticrate) self.ticrate = 0.1;     // Speed of this turrets AI loop
    }

    self.ticrate = bound(0.01,self.ticrate,60);  // keep it sane plz

// General stuff
    if (self.netname == "")  self.netname        = "turret";

    if (!self.respawntime) self.respawntime = 60;
    self.respawntime = max(-1,self.respawntime);

    if (!self.health)        self.health         = 1000;
    self.tur_health = max(1,self.health);

    if (!self.turrcaps_flags) self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;

    if (!self.damage_flags) self.damage_flags = TFL_DMG_YES | TFL_DMG_RETALIATE | TFL_DMG_AIMSHAKE;

// Shot stuff.
    if (!self.shot_refire) self.shot_refire     = 1;
    self.shot_refire = bound(0.01,self.shot_refire,9999);

    if (!self.shot_dmg) self.shot_dmg        = self.shot_refire * 50;
    self.shot_dmg = max(1,self.shot_dmg);

    if (!self.shot_radius) self.shot_radius     = self.shot_dmg * 0.5;
    self.shot_radius = max(1,self.shot_radius);

    if (!self.shot_speed) self.shot_speed      = 2500;
    self.shot_speed = max(1,self.shot_speed);

    if (!self.shot_spread) self.shot_spread     = 0.0125;
    self.shot_spread = bound(0.0001,self.shot_spread,500);

    if (!self.shot_force) self.shot_force      = self.shot_dmg * 0.5 + self.shot_radius * 0.5;
    self.shot_force = bound(0.001,self.shot_force,MAX_SHOT_DISTANCE * 0.5);

    if (!self.shot_volly) self.shot_volly = 1;
    self.shot_volly = bound(1,self.shot_volly,floor(self.ammo_max / self.shot_dmg));

    if (!self.shot_volly_refire) self.shot_volly_refire = self.shot_refire * self.shot_volly;
    self.shot_volly_refire = bound(self.shot_refire,self.shot_volly_refire,60);

    if (!self.firecheck_flags)
        self.firecheck_flags = TFL_FIRECHECK_WORLD | TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES |
                               TFL_FIRECHECK_LOS | TFL_FIRECHECK_AIMDIST | TFL_FIRECHECK_TEAMCECK |
                               TFL_FIRECHECK_OWM_AMMO | TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_WORLD;

// Range stuff.
    if (!self.target_range) self.target_range               = self.shot_speed * 0.5;
    self.target_range = bound(0,self.target_range,MAX_SHOT_DISTANCE);

    if (!self.target_range_min)          self.target_range_min           = self.shot_radius * 2;
    self.target_range_min = bound(0,self.target_range_min,MAX_SHOT_DISTANCE);

    if (!self.target_range_fire)         self.target_range_fire          = self.target_range * 0.8;
    self.target_range_fire = bound(0,self.target_range_fire,MAX_SHOT_DISTANCE);

    if (!self.target_range_optimal)      self.target_range_optimal       = self.target_range_fire * 0.5;
    self.target_range_optimal = bound(0,self.target_range_optimal,MAX_SHOT_DISTANCE);


// Aim stuff.
    if (!self.aim_maxrot)    self.aim_maxrot    = 45;
    self.aim_maxrot = bound(0,self.aim_maxrot,361);

    if (!self.aim_maxpitch)  self.aim_maxpitch  = 20;
    self.aim_maxpitch = bound(0,self.aim_maxpitch,90);

    if (!self.aim_speed)     self.aim_speed     = 36;
    self.aim_speed  = bound(0.1,self.aim_speed, 1000);

    if (!self.aim_firetolerance_dist)     self.aim_firetolerance_dist  = 5 + (self.shot_radius * 2);
    self.aim_firetolerance_dist = bound(0.1,self.aim_firetolerance_dist,MAX_SHOT_DISTANCE);

//    if (!self.aim_firetolerance_angle)     self.aim_firetolerance_angle  = 10;
//    self.aim_firetolerance_angle = bound(0.1,self.aim_firetolerance_angle,360);

    if (!self.aim_flags) self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE | TFL_AIM_ZEASE;

    // Sill the most tested (and aim-effective)
    if (!self.track_type) self.track_type = TFL_TRACKTYPE_STEPMOTOR;

    if (self.track_type != TFL_TRACKTYPE_STEPMOTOR)
    {
        // Fluid / Ineria mode. Looks mutch nicer, bit experimental &
        // Can inmapt aim preformance alot.
        // needs a bit diffrent aimspeed
        if (!self.aim_speed) self.aim_speed = 180;
        self.aim_speed  = bound(0.1,self.aim_speed, 1000);

        if (!self.track_accel_pitch) self.track_accel_pitch = 0.75;
        if (!self.track_accel_rot)   self.track_accel_rot   = 0.75;
        if (!self.track_blendrate)   self.track_blendrate   = 0.35;
    }

    if (!self.track_flags) self.track_flags = TFL_TRACK_PITCH | TFL_TRACK_ROT;


// Target selection stuff.
    if (!self.target_select_rangebias)   self.target_select_rangebias     = 1;
    self.target_select_rangebias = bound(-10,self.target_select_rangebias,10);

    if (!self.target_select_samebias)    self.target_select_samebias      = 1;
    self.target_select_samebias = bound(-10,self.target_select_samebias,10);

    if (!self.target_select_anglebias)   self.target_select_anglebias     = 1;
    self.target_select_anglebias = bound(-10,self.target_select_anglebias,10);

    if (!self.target_select_missilebias)   self.target_select_missilebias = -10;
    self.target_select_missilebias = bound(-10,self.target_select_missilebias,10);
    self.target_select_playerbias = bound(-10,self.target_select_playerbias,10);

    if (!self.target_select_flags)
        if (self.turrcaps_flags & TFL_TURRCAPS_MISSILEKILL)
            self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_MISSILES |
                                       TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_ANGLELIMITS;
        else
            self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_PLAYERS |
                                       TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_ANGLELIMITS;

    //if(!self.target_validate_flags)
    self.target_validate_flags = self.target_select_flags;


// Ammo stuff
    if (!self.ammo_max)          self.ammo_max       = self.shot_dmg * 10;
    self.ammo_max = max(self.shot_dmg,self.ammo_max);

    if (!self.ammo)              self.ammo           = self.shot_dmg * 5;
    self.ammo = bound(0,self.ammo,self.ammo_max);

    if (!self.ammo_recharge)     self.ammo_recharge = self.shot_dmg / 2;
    self.ammo_recharge = max(0,self.ammo_recharge);

    // Convert the recharge from X per sec to X per ticrate
    self.ammo_recharge = self.ammo_recharge * self.ticrate;

    if (!self.ammo_flags) self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;

// Offsets & origins
    if (!self.tur_aimorg)    self.tur_aimorg = '0 0 50';
    if (!self.tur_shotorg)   self.tur_shotorg = '50 0 50';

// End of default & sanety checks, start building the turret.

// Spawn extra bits
    self.tur_head   = spawn();

    self.tur_head.netname = self.tur_head.classname = "turret_head";
    self.tur_head.team = self.team;

    // Defend mode?
    if (self.target != "")
    {
        self.tur_defend = find(world, targetname, self.target);
        if (self.tur_defend == world)
        {
            self.target = "";
            dprint("Turret has invalid defendpoint!\n");
        }
    }

// Claim ownership
    self.tur_head.owner = self;

// Put pices in place

    if (!(self.turrcaps_flags & TFL_TURRCAPS_LINKED))
        setorigin(self.tur_head,self.origin);

    // In target defense mode, aim on the spot to defens when idle.
    if (self.tur_defend)
        self.idle_aim  = self.tur_head.angles + angleofs(self.tur_head,self.tur_defend);
    else
        self.idle_aim  = self.angles;

    if (!(self.turrcaps_flags & TFL_TURRCAPS_LINKED))
        self.tur_head.angles    = self.idle_aim;

    if (!self.health) self.health  = 150;
        self.tur_health = self.health;

    self.tur_head.health = self.health;

    //Solid bbox for preformance reasons
    self.solid              = SOLID_BBOX;
    self.tur_head.solid     = SOLID_BBOX;

    self.takedamage             = DAMAGE_AIM;
    self.tur_head.takedamage    = DAMAGE_AIM;

    self.movetype            = MOVETYPE_NOCLIP;
    self.tur_head.movetype   = MOVETYPE_NOCLIP;

    // Team colouring?track
    if (self.team == COLOR_TEAM1) self.colormod = '1.4 0.8 0.8';
    if (self.team == COLOR_TEAM2) self.colormod = '0.8 0.8 1.4';

    // Attach stdprocs. override when and what needed
    if (self.turrcaps_flags & TFL_TURRCAPS_SUPPORT)
    {
        //self.turret_prethink        = turret_stdproc_true;
        self.turret_score_target    = turret_stdproc_targetscore_support;
        //self.turret_aim             = turret_stdproc_aim_generic;
        //self.turret_track           = turret_stdproc_track;
        self.turret_firecheckfunc   = turret_stdproc_firecheck;
        self.turret_firefunc        = turret_stdproc_fire;
        self.turret_postthink       = turret_stdproc_nothing;

        //self.turret_damagefunc          = turret_stdproc_damage;
        //self.event_damage               = turret_stdproc_damage;
        self.tur_head.event_damage      = turret_stdproc_damage;

        //self.turret_diefunc             = turret_stdproc_die;
        //self.turret_spawnfunc           = turret_stdproc_respawn;

    }
    else
    {

        //self.turret_prethink        = turret_stdproc_true;
        self.turret_score_target    = turret_stdproc_targetscore_generic;

        //if (self.aim_flags & TFL_AIM_SIMPLE)
        //    self.turret_aim             = turret_stdproc_aim_simple;
        //else
        //    self.turret_aim             = turret_stdproc_aim_generic;

        //self.turret_track           = turret_stdproc_track;
        self.turret_firecheckfunc   = turret_stdproc_firecheck;
        self.turret_firefunc        = turret_stdproc_fire;
        self.turret_postthink       = turret_stdproc_nothing;

        //self.turret_damagefunc          = turret_stdproc_damage;
        self.event_damage               = turret_stdproc_damage;
        self.tur_head.event_damage      = turret_stdproc_damage;

        //self.turret_diefunc             = turret_stdproc_die;
        //self.turret_spawnfunc           = turret_stdproc_respawn;
        self.turret_addtarget           = turret_stdproc_false;
    }

    self.use = turret_stdproc_use;
    self.bot_attack = TRUE;

    // Initiate the main AI loop
    self.think     = turret_think;
    self.nextthink = time + self.ticrate;

    self.tur_head.team = self.team;
    self.view_ofs = '0 0 0';

#ifdef TURRET_DEBUG
    self.tur_dbg_start = self.nextthink;
    while (vlen(self.tur_dbg_rvec) < 2)
        self.tur_dbg_rvec  = randomvec() * 4;

    self.tur_dbg_rvec_x = fabs(self.tur_dbg_rvec_x);
    self.tur_dbg_rvec_y = fabs(self.tur_dbg_rvec_y);
    self.tur_dbg_rvec_z = fabs(self.tur_dbg_rvec_z);
#endif

    // Its all good.
    self.classname = "turret_main";

    self.tur_active = 1;

    //if (g_onslaught)
    //    self.use();

    //turret_stdproc_use();

    return 1;
}


