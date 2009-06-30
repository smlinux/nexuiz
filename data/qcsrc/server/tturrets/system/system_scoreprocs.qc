/*
.float target_select_flags; /// target selection flags
float TFL_TARGETSELECT_NO            = 1;   /// Dont select a target on its own.
float TFL_TARGETSELECT_LOS           = 2;   /// Need line of sight
float TFL_TARGETSELECT_PLAYERS       = 4;   /// Players are valid targets
float TFL_TARGETSELECT_MISSILES      = 8;   /// Missiles are valid targets
float TFL_TARGETSELECT_TRIGGERTARGET = 16;  /// Responds to turret_trigger_target events
float TFL_TARGETSELECT_ANGLELIMITS   = 32;  /// Angular limitations of turret head limits target selection
float TFL_TARGETSELECT_RANGELIMTS    = 64;  /// Range limits apply in targetselection
float TFL_TARGETSELECT_TEAMCHECK     = 128; /// Consider team own <-> targets team
float TFL_TARGETSELECT_NOBUILTIN     = 256; /// Cant select targets on its own. needs to be triggerd or slaved.
float TFL_TARGETSELECT_OWNTEAM       = 512;
*/

float turret_stdproc_targetscore_support(entity e_turret,entity e_target)
{
    float score;        // Total score
    float s_score,d_score;

    if (e_turret.enemy == e_target) s_score = 1;

    d_score = min(e_turret.target_range_optimal,tvt_dist) / max(e_turret.target_range_optimal,tvt_dist);

    score = (d_score * e_turret.target_select_rangebias) +
            (s_score * e_turret.target_select_samebias);

    return score;
}

/*
* Generic bias aware score system.
*/
float turret_stdproc_targetscore_generic(entity e_turret,entity e_target)
{
    //vector v_tmp;
    float d_dist;       // Defendmode Distance

    float score;        // Total score

    float d_score;      // Distance score
    float a_score;      // Angular score
    float m_score;      // missile score
    float p_score;      // player score
    //float da_score;   // Distance from aimpoint score

    float ikr;          // ideal kill range

    if(!e_target) return 0;

    //if (e_target == e_turret.enemy) s_score = 1;

    if (e_turret.tur_defend)
    {
        d_dist = vlen(real_origin(e_target) - e_turret.tur_defend.origin);
        ikr = vlen(e_turret.origin - e_turret.tur_defend.origin);
        d_score = 1 - d_dist / e_turret.target_range;
    }
    else
    {
        // Make a normlized value base on the targets distance from our optimal killzone
        ikr = e_turret.target_range_optimal;
        d_score = min(ikr,tvt_dist) / max(ikr,tvt_dist);
    }

    /*
    // Determine the maximum time it could take this turrent to aim at someting.
    max_aim_delay = (max(e_turret.aim_maxrot,e_turret.aim_maxpitch) / e_turret.aim_speed * 2);

    // Find out how long it would take to aim at this taget.
    aim_delay = (thadf+0.01) / e_turret.aim_speed;

    // Turn this info into a normalized value.
    aim_delay = (min(max_aim_delay,aim_delay) / max_aim_delay);
    a_score = 1 - aim_delay;
    */

    //a_score = 1 - (tvt_thadf / max(e_turret.aim_maxrot,e_turret.aim_maxpitch));
    a_score = 1 - tvt_thadf / e_turret.aim_maxrot;

    if ((e_turret.target_select_missilebias > 0) && (e_target.flags & FL_PROJECTILE))
        m_score = 1;

    if ((e_turret.target_select_playerbias > 0) && (e_target.flags & FL_CLIENT))
        p_score = 1;

    d_score = max(d_score,0);
    a_score = max(a_score,0);
    m_score = max(m_score,0);
    p_score = max(p_score,0);

    score = (d_score * e_turret.target_select_rangebias) +
            (a_score * e_turret.target_select_anglebias) +
            (m_score * e_turret.target_select_missilebias) +
            (p_score * e_turret.target_select_playerbias);

    if(e_turret.target_range < vlen(e_turret.tur_shotorg - real_origin(e_target)))
    {
        dprint("Wtf?\n");
        score *= 0.001;
    }

#ifdef TURRET_DEBUG
    string sd,sa,sm,sp,ss;
    string sdt,sat,smt,spt;

    sd = ftos(d_score);
    d_score *= e_turret.target_select_rangebias;
    sdt = ftos(d_score);

    //sv = ftos(v_score);
    //v_score *= e_turret.target_select_samebias;
    //svt = ftos(v_score);

    sa = ftos(a_score);
    a_score *= e_turret.target_select_anglebias;
    sat = ftos(a_score);

    sm = ftos(m_score);
    m_score *= e_turret.target_select_missilebias;
    smt = ftos(m_score);

    sp = ftos(p_score);
    p_score *= e_turret.target_select_playerbias;
    spt = ftos(p_score);


    ss = ftos(score);
    bprint("^3Target scores^7 \[  ",e_turret.netname, "  \] ^3for^7 \[  ", e_target.netname,"  \]\n");
    bprint("^5Range:\[  ",sd,  "  \]^2+bias:\[  ",sdt,"  \]\n");
    bprint("^5Angle:\[  ",sa,  "  \]^2+bias:\[  ",sat,"  \]\n");
    bprint("^5Missile:\[  ",sm,"  \]^2+bias:\[  ",smt,"  \]\n");
    bprint("^5Player:\[  ",sp, "  \]^2+bias:\[  ",spt,"  \]\n");
    bprint("^3Total (w/bias):\[^1",ss,"\]\n");

#endif

    return score;
}

/*
float turret_stdproc_targetscore_close(entity e_turret,entity e_target)
{
    return 1 - (tvt_dist / e_turret.target_range);
}

float turret_stdproc_targetscore_far (entity e_turret,entity e_target)
{
    return  tvt_dist / e_turret.target_range;
}

float turret_stdproc_targetscore_optimal(entity e_turret,entity e_target)
{
    return  min(e_turret.target_range_optimal,tvt_dist) / max(e_turret.target_range_optimal,tvt_dist);
}

float turret_stdproc_score_angular(entity e_turret,entity e_target)
{
    return 1 - (tvt_thadf / e_turret.aim_maxrot);
}

float turret_stdproc_targetscore_defend(entity e_turret,entity e_target)
{
    return 0;
    //min(e_target.origin,e_turret.tur_defend.origin) / max(e_target.origin,e_turret.tur_defend.origin);
}
*/
