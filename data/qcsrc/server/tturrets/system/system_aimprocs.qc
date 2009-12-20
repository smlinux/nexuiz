/*
* Generic aim

supports:
TFL_AIM_NO
TFL_AIM_GROUND
TFL_AIM_LEAD
TFL_AIM_SHOTTIMECOMPENSATE
TFL_AIM_INFRONT
TFL_AIM_BEHIND
TFL_AIM_ZEASE

not supported:
TFL_AIM_BALISTIC
*/
vector turret_stdproc_aim_generic()
{

    vector pre_pos,prep;
    float distance,impact_time,i,mintime;

    turret_tag_fire_update();

    if(self.aim_flags & TFL_AIM_SIMPLE)
        return real_origin(self.enemy);

    // Keep track of when we can shoot the next time and
    // try to predict where the target will be then, so we can put our aimpoint there.
    // + sys_frametime, becouse spawned REMOVE THIS IF sv_gameplayfix_delayprojectiles are 0!
    // projectiles dont move during the first tic of their life.
    //if (self.turrcaps_flags & TFL_TURRCAPS_HITSCAN)
    //    mintime = max(self.attack_finished_single - time,0) + sys_frametime;
    //else

    mintime = max(self.attack_finished_single - time,0) + sys_frametime;

    // Baseline
    pre_pos = real_origin(self.enemy);

    if (self.aim_flags & TFL_AIM_INFRONT)   // Aim a bit in front of the target
        pre_pos = pre_pos + (normalize(self.enemy.velocity) * 64);

    if (self.aim_flags & TFL_AIM_BEHIND)    // Aim a bit behind the target
        pre_pos = pre_pos - (normalize(self.enemy.velocity) * 32);

    // Lead?
    if (self.aim_flags & TFL_AIM_LEAD)
    if (self.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE)       // Need to conpensate for shot traveltime
    {
        // FIXME: this cant be the best way to do this..
        prep = pre_pos;
        for(i = 0; i < 4; ++i)
        {
            distance = vlen(prep - self.tur_shotorg);
            impact_time = distance / self.shot_speed;
            prep = pre_pos + self.enemy.velocity * impact_time;
        }


        // tnx to Rudolf "div0" Polzer for this solution.
        // hmm tobad it dont work.
        /*
        vector q;
        q = solve_quadratic(self.enemy.velocity*self.enemy.velocity - self.shot_speed*self.shot_speed, 2*(pre_pos*self.enemy.velocity), pre_pos * pre_pos);
        if(q_x > 0)
            impact_time = q_x;
        else
            impact_time = q_y;
        */

        prep = pre_pos + (self.enemy.velocity * (impact_time + mintime));

        if(self.aim_flags & TFL_AIM_ZPREDICT)
        if not(self.enemy.flags & FL_ONGROUND)
        if(self.enemy.movetype == MOVETYPE_WALK || self.enemy.movetype == MOVETYPE_TOSS || self.enemy.movetype == MOVETYPE_BOUNCE)
        {
            float vz;
            prep_z = pre_pos_z;
            vz = self.enemy.velocity_z;
            for(i = 0; i < impact_time; i += sys_frametime)
            {
                vz = vz - (sv_gravity * sys_frametime);
                prep_z = prep_z + vz * sys_frametime;
            }
        }
        pre_pos = prep;
    }
    else
        pre_pos = pre_pos + self.enemy.velocity * mintime;

    // Smooth out predict-Z?
    /*
    if (self.aim_flags & TFL_AIM_ZEASE)
    if (self.enemy.flags & FL_CLIENT)
    {
        vector v;
        v = real_origin(self.enemy);
        pre_pos_z = (pre_pos_z + v_z) * 0.5;
    }
    */

    if(self.aim_flags & TFL_AIM_GROUND2)
    {
        //tracebox(pre_pos + '0 0 32',self.enemy.mins,self.enemy.maxs,pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
        traceline(pre_pos + '0 0 32',pre_pos -'0 0 64',MOVE_WORLDONLY,self.enemy);
        if(trace_fraction != 1.0)
            pre_pos = trace_endpos;
    }

    /*
    // This turret should hit the ground neer a target rather the do a direct hit
    if (self.aim_flags & TFL_AIM_GROUND)
    {
        traceline(pre_pos + '0 0 8',pre_pos - '0 0 10000',MOVE_WORLDONLY,self.enemy);
        pre_pos = trace_endpos;
    }
    */

    return pre_pos;
}
