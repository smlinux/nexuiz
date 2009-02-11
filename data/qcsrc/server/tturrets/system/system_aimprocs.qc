/*
* Straight line, Dead-on (no prediction)
* Usefull for "stupid turrets" or ones
* that launch guided weapons and just need to apeer to
* somewhat face (and/or track) the target.

supports:
TFL_AIM_NO
*/
/*
vector turret_stdproc_aim_simple()
{
    float s_bu;     // Solidity backup (for ground shooters)
    vector aim_pos;

    if (self.aim_flags & TFL_AIM_NO) return self.idle_aim;

    aim_pos = self.enemy.origin;

    // Target ground?
    if (self.aim_flags & TFL_AIM_GROUND)
    {
        s_bu = self.enemy.solid;
        self.enemy.solid = SOLID_NOT;
        traceline(self.enemy.origin + '0 0 128',self.enemy.origin + '0 0 -99999',1,self.enemy);
        self.enemy.solid = s_bu;
        aim_pos = trace_endpos;
    }

    // This is where its at.
    return aim_pos;
}
*/

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
    vector pre_pos;
    float distance,impact_time,i,mintime;
    vector prep;

    //if (self.aim_flags == TFL_AIM_NO)
    //  return self.idle_aim;

    // Baseline
    pre_pos = real_origin(self.enemy);

    if(self.aim_flags & TFL_AIM_SIMPLE)
        return pre_pos;

    // This is not accurate enougth
    //pre_pos = bot_shotlead(pre_pos, self.enemy.velocity, self.shot_speed, 0.01); //self.enemy.velocity;  * (self.tur_dist_aimpos / self.shot_speed);

    // Keep track of when we can shoot the next tim and
    // try to predict where the target will be then, so we can put our aimpoint there.
    // + sys_ticrate becouse projectiles dont move during the first tic of their life.
    mintime = max(self.attack_finished_single - time,0) + (sys_ticrate * 2);

    if (self.aim_flags & TFL_AIM_INFRONT)   // Aim a bit in front of the target
        pre_pos += normalize(normalize(self.enemy.velocity) * 16);

    if (self.aim_flags & TFL_AIM_BEHIND)    // Aim a bit behind the target
        pre_pos -= normalize(normalize(self.enemy.velocity) * 16);

    // Lead?
    if (self.aim_flags & TFL_AIM_LEAD)
    if (self.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE)       // Need to conpensate for shot traveltime
    {
        // FIXME: this cant be the best way to do this..
        prep = pre_pos;
        for(i = 0; i < 3; ++i)
        {
            distance = vlen(prep - self.tur_shotorg_updated);
            impact_time = distance / self.shot_speed;
            prep = pre_pos + self.enemy.velocity * (impact_time + mintime);


        }

        /* no worky well :/
        if not(self.enemy.flags & FL_ONGROUND)
        {
            float z;
            z = self.enemy.velocity_z;
            z = z - (sv_gravity * impact_time);
            prep_z += z;
        }
        */


        pre_pos = prep;
    }
    else
    {
        pre_pos = pre_pos + self.enemy.velocity * mintime;
    }


    // Smooth out predict-Z?
    if (self.aim_flags & TFL_AIM_ZEASE)
    {
        vector v;
        v = real_origin(self.enemy);
        pre_pos_z = (pre_pos_z + v_z) * 0.5;
    }

    // This turret should hit the ground neer a target rather the do a direct hit
    if ( (self.aim_flags & TFL_AIM_GROUND) ||
         ((self.aim_flags & TFL_AIM_GROUND2) && (self.enemy.flags & FL_ONGROUND)) )
    {
        traceline(pre_pos + '0 0 8',pre_pos - '0 0 10000',1,self.enemy);
        pre_pos = trace_endpos;
    }

    return pre_pos;
}


/*
* Aim where it is
supports:
TFL_AIM_NO
*/
/*
vector turret_stdproc_aim_rail()
{
    vector pre_pos;

    if (self.aim_flags & TFL_AIM_NO)
        return self.idle_aim;

    pre_pos = real_origin(self.enemy);

    self.tur_dist_impact_to_aimpos = vlen(self.enemy.origin - self.tur_aimorg_updated);

    self.tur_impacttime = time;

    return pre_pos;

}
*/
