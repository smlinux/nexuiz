//--// Some support routines //--//

float shortangle_f(float ang1,float ang2)
{
    if(ang1 > ang2)
    {
        if(ang1 >= 180)
            return ang1 - 360;
    }
    else
    {
        if(ang1 <= -180)
            return ang1 + 360;
    }

    return ang1;
}
vector shortangle_v(vector ang1,vector ang2)
{
    vector vtmp;
    vtmp_x = shortangle_f(ang1_x,ang2_x);
    vtmp_y = shortangle_f(ang1_y,ang2_y);
    vtmp_z = shortangle_f(ang1_z,ang2_z);

    return vtmp;
}


// Get real origin
vector real_origin(entity ent)
{
    entity e;
    vector v;

    e = ent.tag_entity;
    while(e)
    {
        // v = v + e.origin;
        v = v + ((e.absmin + e.absmax) * 0.5);
        e = e.tag_entity;
    }
    //v = v + ent.origin;
    v = v + ((ent.absmin + ent.absmax) * 0.5);
    return v;

}

// Plug this into wherever precashing is done.
void g_turrets_common_precash()
{
    precache_model ("models/turrets/c512.md3");
}

/*
* Paint a v_color colord circle on target onwho
* that fades away over f_time
*/
void paint_target(entity onwho, float f_size, vector v_color, float f_time)
{
    entity e;

    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    //setsize(e, '0 0 0', '0 0 0');
    //setattachment(e,onwho,"");
    setorigin(e,onwho.origin + '0 0 1');
    e.alpha = 0.15;
    e.movetype = MOVETYPE_FLY;

    e.velocity = (v_color * 32); // + '0 0 1' * 64;

    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}

void paint_target2(entity onwho, float f_size, vector v_color, float f_time)
{
    entity e;

    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    setsize(e, '0 0 0', '0 0 0');

    setorigin(e,onwho.origin + '0 0 1');
    e.alpha = 0.15;
    e.movetype = MOVETYPE_FLY;

    e.velocity = (v_color * 32); // + '0 0 1' * 64;
    e.avelocity_x = -128;

    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}

void paint_target3(vector where, float f_size, vector v_color, float f_time)
{
    entity e;
    e = spawn();
    setmodel(e, "models/turrets/c512.md3"); // precision set above
    e.scale = (f_size/512);
    setsize(e, '0 0 0', '0 0 0');
    setorigin(e,where+ '0 0 1');
    e.movetype = MOVETYPE_NONE;
    e.velocity = '0 0 0';
    e.colormod = v_color;
    SUB_SetFade(e,time,f_time);
}

/*
* Return the angle between two enteties
*/
vector angleofs(entity from, entity to)
{
    vector v_res;

    // makevectors(from.angles);
    v_res = normalize(to.origin - from.origin);
    v_res = vectoangles(v_res);
    v_res = v_res - from.angles;

    if (v_res_x < 0) v_res_x += 360;
    if (v_res_x > 180) v_res_x -= 360;

    if (v_res_y < 0) v_res_y += 360;
    if (v_res_y > 180) v_res_y -= 360;

    return v_res;
}

vector angleofs2(entity from, vector to)
{
    vector v_res;

    // makevectors(from.angles);
    v_res = normalize(to - from.origin);
    v_res = vectoangles(v_res);
    v_res = v_res - from.angles;

    if (v_res_x < 0) v_res_x += 360;
    if (v_res_x > 180) v_res_x -= 360;

    if (v_res_y < 0) v_res_y += 360;
    if (v_res_y > 180) v_res_y -= 360;

    return v_res;
}

