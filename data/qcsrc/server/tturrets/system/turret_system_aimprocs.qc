/*
* Straight line, Dead-on (no prediction)
* Usefull for "stupid turrets" or ones
* that launch guided weapons and just need to apeer to
* somewhat face (and/or track) the target.

supports:
TFL_AIM_NO
*/
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

    if (self.aim_flags == TFL_AIM_NO)
        return self.idle_aim;

    // Baseline
    pre_pos = real_origin(self.enemy);

    // Lead?
    if (self.aim_flags & TFL_AIM_LEAD)
        if (self.aim_flags & TFL_AIM_SHOTTIMECOMPENSATE)       // Need to conpensate for shot traveltime
            pre_pos += self.enemy.velocity * (self.tur_dist_enemy / self.shot_speed);
        else if (self.turrcaps_flags & TFL_TURRCAPS_HITSCAN)   // Hitscan gun, conpensate for frametime and posibly refire offset.
            pre_pos += self.enemy.velocity * (frametime + min(max(self.attack_finished - time,0),self.ticrate*2));
        else                                                   // No lead
            pre_pos += self.enemy.velocity;

    // Smooth out predict-Z?
    if (self.aim_flags & TFL_AIM_ZEASE)
    {
        vector v;
        v = real_origin(self.enemy);
        //pre_pos_z = (pre_pos_z * 0.5) + (v_z * 0.5);
        pre_pos_z = (pre_pos_z  + v_z) * 0.5;
    }

    if (self.aim_flags & TFL_AIM_INFRONT)   // Aim a bit in front of the target
        pre_pos -= normalize(self.tur_aimorg_updated - pre_pos) * 32;

    if (self.aim_flags & TFL_AIM_BEHIND)    // Aim a bit behind the target
        pre_pos += normalize(self.tur_aimorg_updated - pre_pos) * 32;


    // This turret should hit the ground neer a target rather the do a direct hit
    if (self.aim_flags & TFL_AIM_GROUND)
    {
        traceline(pre_pos + '0 0 512',pre_pos - '0 0 2048',1,self.enemy);
        pre_pos = trace_endpos;
    }

    // self.tur_impacttime = vlen(pre_pos - self.origin) / self.shot_speed;

    return pre_pos;
}


/*
* Aim where it is
supports:
TFL_AIM_NO
*/
vector turret_stdproc_aim_rail()
{
    vector pre_pos;

    if (self.aim_flags & TFL_AIM_NO)
        return self.idle_aim;

    pre_pos = real_origin(self.enemy);

    self.tur_dist_toaimpos = vlen(self.enemy.origin - self.tur_aimorg_updated);

    self.tur_impacttime = time;

    return pre_pos;

}



