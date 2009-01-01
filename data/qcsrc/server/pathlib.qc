#define PLF_GROUNDSNAP 1
#define PLF_NOOPTIMIZE 2
#define PLF_SUBPATH3D  4

//#define PATHLIB_RDFIELDS
#ifdef PATHLIB_RDFIELDS
    #define path_flags lip

    #define path_subpathing_size autoswitch
    #define path_subpathing_bboxexpand welcomemessage_time

    #define path_next swampslug
    #define path_prev lasertarget
#else
    .entity path_next;
    .entity path_prev;

    .float path_subpathing_size;
    .float path_subpathing_bboxexpand;
    .float path_flags;
#endif

#define pathlib_garbagetime 120
#define pathib_maxdivide 256

.float(vector start,vector end) path_validate;

float pathlib_stdproc_path_validate(vector start,vector end)
{
    tracebox(start, self.mins, self.maxs, end, MOVE_NORMAL, self);

    if(vlen(trace_endpos - end) < 32)
        return 1;

    return 0;
}

vector pathlib_groundsnap(vector where,entity path)
{
    float lsize;

    lsize = vlen(self.mins - self.maxs) * 0.25;

    traceline(where + ('0 0 1' * lsize) ,where - '0 0 10000',MOVE_NORMAL,self);

    return trace_endpos + ('0 0 1' * lsize);

}

entity pathlib_createpoint(entity parent,entity next,entity first,vector where)
{
    entity point;

    point = spawn();
    point.classname = "path_node";

    if(first)
        point.owner = first;
    else
    {
        point.classname = "path_master";
        point.owner = point;
    }

    if(parent)
        point.path_prev = parent;

    if(next)
    {
        point.path_next = next;
        //point.path_nodelength = vlen(point.origin - next.origin)
    }
    else
        point.classname = "path_end";

    if(point.owner.path_flags & PLF_GROUNDSNAP)
        where = pathlib_groundsnap(where,parent);


    setorigin(point,where);


    return point;
}

vector pathlib_findsubpath(entity start,vector vcrash,entity end,float maxsize)
{
    float x,y,z;
    float step;
    float dist;
    float pathlength;
    float pathlength_best;
    vector bestpoint;
    vector point;
    float zmin,zmax;

    pathlength_best = 1000000;

    step = vlen(self.maxs - self.mins) * start.owner.path_subpathing_bboxexpand;

    if(start.owner.path_flags & PLF_SUBPATH3D)
    {
        zmin = maxsize * -1;
        zmax = maxsize;
    }
    else
    {
        zmin = 0;
        zmax = 1;
    }

    for(z = zmin; z < zmax; z += step)
    for(y = -maxsize; y < maxsize; y += step)
    for(x = -maxsize; x < maxsize; x += step)
    {

        point_z = vcrash_z + z;
        point_x = vcrash_x + x;
        point_y = vcrash_y + y;


        if(start.owner.path_flags & PLF_GROUNDSNAP)
            point = pathlib_groundsnap(point,start);

        if(self.path_validate(start.origin,point))
        {
            dist = vlen(start.origin - point);
            if(dist > step)
            {
                pathlength = dist + vlen(point - end.origin);
                if(pathlength < pathlength_best)
                {
                    bestpoint = point;
                    pathlength_best = pathlength;
                }
            }
        }

    }

    if(pathlength_best != 1000000)
        return bestpoint;

    return vcrash;
}

float pathlib_path(entity start,entity end)
{
    vector vcrash;
    vector subpath_point;
    entity subpoint;

    // Fail.
    if(start.cnt > pathib_maxdivide)
        return 0;

    if(self.path_validate(start.origin,end.origin))
        return 1;

    vcrash = trace_endpos;

    subpath_point = pathlib_findsubpath(start,vcrash,end,start.owner.path_subpathing_size);

    if(subpath_point == vcrash)
        return 0; // Fail.

    subpoint = pathlib_createpoint(start,end,start.owner,subpath_point);

    subpoint.cnt = start.cnt +1;
    start.path_next = subpoint;
    end.path_prev = subpoint;

    if(self.path_validate(start.origin,end.origin))
        return 1;

    return pathlib_path(subpoint,end);
}

void pathlib_path_optimize(entity start,entity end)
{
    entity point,point_tmp;
    float c;

    point = start.path_next;

    while(point != end)
    {
        ++c;
        if(c > 5000)
        {
            dprint("pathlib_path_optimize runaway!\n");
            return;
        }

        point_tmp = point;
        point = point.path_next;
        if(self.path_validate(point_tmp.path_prev.origin,point_tmp.path_next.origin))
        {

            point_tmp.path_next.path_prev = point_tmp.path_prev;
            point_tmp.path_prev.path_next = point_tmp.path_next;
            remove(point_tmp);
        }
    }
}

void pathlib_deletepath(entity start)
{
    entity e;

    e = findentity(start, owner, start);
    while(e)
    {
        remove(e);
        e = findentity(start, owner, start);
    }
}

void pathlib_showpath(entity start)
{
    entity e;
    e = start;
    while(e.path_next)
    {
        te_lightning1(e,e.origin,e.path_next.origin);
        e = e.path_next;
    }
}

/**
    Run a A*-like pathing from 'from' to 'to'
**/
entity pathlib_makepath(vector from, vector to,float pathflags,float subpathing_size, float subpathing_bboxexpand)
{
    entity e_start,e_end;

    if(!self.path_validate)
        self.path_validate = pathlib_stdproc_path_validate;


    if(subpathing_size < 10)
        subpathing_size = 500;

    if(subpathing_bboxexpand < 1)
        subpathing_bboxexpand = 1;

    e_start = pathlib_createpoint(world,world,world,from);
    e_start.path_flags = pathflags;

    e_start.path_subpathing_size = subpathing_size;
    e_start.path_subpathing_bboxexpand = subpathing_bboxexpand;

    e_start.owner = e_start;

    e_end = pathlib_createpoint(e_start,world,e_start,to);
    e_start.path_next = e_end;
    e_start.cnt = 0;

    if(!pathlib_path(e_start,e_end))
    {
        pathlib_deletepath(e_start);
        remove(e_start);
        return world;
    }

    pathlib_path_optimize(e_start,e_end);

    return e_start;

}


/* TESTING */
void pathlib_test_think()
{
    pathlib_showpath(self.enemy);

    self.nextthink = time + 0.5;
}
void pathlib_test_dinit()
{
    entity path;
    entity end;

    if(self.target == "")
    {
        bprint("^1 ==== ERROR: pathlib_test with no target. ====\n");
        remove(self);
        return;
    }

    end = find(world,targetname,self.target);
    if(!end)
    {
        bprint("^1 ==== ERROR: pathlib_test with no valid target. ====\n");
        remove(self);
        return;
    }

    setsize(self,'-50 -50 0','50 50 50');
    path = pathlib_makepath(self.origin,end.origin, PLF_GROUNDSNAP,500,1.25);

    if(!path)
    {
        bprint("^1 ==== ERROR: pathlib_test pathing fail ====\n");
        remove(self);
        return;
    }

    self.enemy = path;
    self.think = pathlib_test_think;
    self.nextthink = time + 0.5;

}
void spawnfunc_pathlib_test()
{
    self.think = pathlib_test_dinit;
    self.nextthink = time + 2;
}
