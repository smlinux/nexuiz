#define PFL_GROUNDSNAP 1
#define PFL_NOOPTIMIZE 2
#define PFL_SUBPATH3D  4

#define PT_QUICKSTAR 1
#define PT_QUICKBOX  2
#define PT_ASTAR     4  // FIXME NOT IMPLEMENTED

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
#define pathib_maxdivide 512

.float(vector start,vector end) path_validate;

float pathlib_stdproc_path_validate(vector start,vector end)
{
    tracebox(start, self.mins, self.maxs, end, MOVE_WORLDONLY, self);

    if(vlen(trace_endpos - end) < 32)
        return 1;

    return 0;
}

vector pathlib_groundsnap(vector where)
{
    float lsize;

    lsize = vlen(self.mins - self.maxs) * 0.25;

    traceline(where + ('0 0 1' * lsize) ,where - '0 0 10240',MOVE_WORLDONLY,self);

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
    }
    else
        point.classname = "path_end";

    if (point.owner.path_flags & PFL_GROUNDSNAP)
        where = pathlib_groundsnap(where);

    setorigin(point,where);


    return point;
}

/*
float pathlib_scoresubpath(vector start,vector point,vector end,float minstep)
{
    float dist_stp,dist_pte,dist_total;

    dist_stp = vlen(start - point);
    if(dist_stp < minstep)
        return 100000000;

    dist_pte = vlen(point - end);
    dist_total = dist_stp + dist_pte;
    return -1;
}
*/

vector pathlib_subpath_quickbox(entity start,vector vcrash,entity end,float maxsize)
{

    float step;
    float pathscore;
    float pathscore_best;
    float dist;
    vector bestpoint,point;
    float zmin,zmax;
    vector box;

    pathscore_best = 0;

    step = vlen(self.maxs - self.mins) * start.owner.path_subpathing_bboxexpand;

    if(start.owner.path_flags & PFL_SUBPATH3D)
    {
        zmin = maxsize * -1;
        zmax = maxsize;
    }
    else
    {
        zmin = 0;
        zmax = 1;
    }

    for(box_z = zmin; box_z < zmax; box_z += step)
    for(box_y = -maxsize; box_y < maxsize; box_y += step)
    for(box_x = -maxsize; box_x < maxsize; box_x += step)
    {

        point = vcrash + box;

        if(start.owner.path_flags & PFL_GROUNDSNAP)
            point = pathlib_groundsnap(point);

        if(self.path_validate(start.origin,point))
        {
            dist = vlen(start.origin - point);
            if(dist > step)
            {
                pathscore = 1 / (dist + vlen(point - end.origin));
                if(pathscore > pathscore_best)
                {
                    bestpoint = point;
                    pathscore_best = pathscore;
                }
            }
        }

    }

    if(pathscore_best != 0)
        return bestpoint;

    return start.origin;
}

vector pathlib_subpath_quickstar(entity start,entity end,float gridsize)
{
    vector point, best_point;
    float  score, best_score;
    vector dir_end;

    dir_end   = normalize(end.origin - start.origin);
    dir_end_x = dir_end_x * -1;

    makevectors(dir_end);

    best_score = 0;
    score      = 0;

    best_point = start.origin;

    // Forward
    point = start.origin + v_forward * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    // Forward-right
    point = start.origin + (v_forward + v_right * 0.5) * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);


    // Forward-left
    point = start.origin + (v_forward - v_right * 0.5) * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);


    // Right
    point = start.origin + v_right * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    // Left
    point = start.origin - v_right * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    // Back
    point = start.origin - v_forward * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    // Back-right

    point = start.origin - (v_forward + v_right * 0.5) * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    // Back-left
    point = start.origin - (v_forward - v_right * 0.5) * gridsize;
    point  = pathlib_groundsnap(point);
    if(self.path_validate(start.origin,point)) score = 1 / vlen(point - end.origin);
    if(score < best_score) { best_point = point; best_score = score; }
    //te_lightning1(world,start.origin,point);

    return(best_point);
}

float pathlib_path(entity start,entity end,float pathing_method)
{
    vector vcrash;
    vector subpath_point;
    entity subpoint;

    // Fail.
    if(start.cnt > pathib_maxdivide)
    {
        bprint("To many segments!\n");
        return 0;
    }

    if(self.path_validate(start.origin,end.origin))
        return 1;

    vcrash = trace_endpos;

    switch(pathing_method)
    {
        case PT_QUICKSTAR:
            subpath_point = pathlib_subpath_quickstar(start,end,start.owner.path_subpathing_size);
            break;
        case PT_QUICKBOX:
            subpath_point = pathlib_subpath_quickbox(start,vcrash,end,start.owner.path_subpathing_size);
            break;
        case PT_ASTAR:
            dprint("Pathlib error: A* pathing not implemented!\n");
            return 0;
        default:
            subpath_point = pathlib_subpath_quickstar(start,end,start.owner.path_subpathing_size);
            dprint("Pathlib warning: unknown pathing method, using quickstar!\n");
            break;
    }

    if(subpath_point == start.origin)
        return 0; // Fail.

    subpoint = pathlib_createpoint(start,end,start.owner,subpath_point);

    subpoint.cnt = start.cnt +1;
    start.path_next = subpoint;
    end.path_prev = subpoint;

    if(self.path_validate(start.origin,end.origin))
        return 1;

    return pathlib_path(subpoint,end,pathing_method);
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

    e = findchainentity(owner, start);
    while(e)
    {
        e.think = SUB_Remove;
        e.nextthink = time;
        e = e.chain;
    }
}

//#define DEBUGPATHING
#ifdef DEBUGPATHING
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

void path_dbg_think()
{
    pathlib_showpath(self);
    self.nextthink = time + 1;
}
#endif
/**
    Pathing from 'from' to 'to'
**/
entity pathlib_makepath(vector from, vector to,float pathflags,float subpathing_size, float subpathing_bboxexpand,float pathing_method)
{
    entity e_start,e_end;

    if(!self.path_validate)
        self.path_validate = pathlib_stdproc_path_validate;


    if(subpathing_size < 10)
        subpathing_size = 500;

    if(subpathing_bboxexpand < 1)
        subpathing_bboxexpand = 1;

    if(pathflags & PFL_GROUNDSNAP)
    {
        from = pathlib_groundsnap(from);
        to = pathlib_groundsnap(to);
    }

    e_start = pathlib_createpoint(world,world,world,from);
    e_start.path_flags = pathflags;

    e_start.path_subpathing_size = subpathing_size;
    e_start.path_subpathing_bboxexpand = subpathing_bboxexpand;

    e_start.owner = e_start;

    e_end = pathlib_createpoint(e_start,world,e_start,to);
    e_start.path_next = e_end;
    e_start.cnt = 0;

    if(!pathlib_path(e_start,e_end,pathing_method))
    {
        bprint("Fail, Fail, Fail!\n");
        pathlib_deletepath(e_start);
        remove(e_start);

        return world;
    }

    pathlib_path_optimize(e_start,e_end);

#ifdef DEBUGPATHING
    e_start.think = path_dbg_think;
    e_start.nextthink = time + 1;
#endif

    return e_start;

}

/*
.entity goalcurrent, goalstack01, goalstack02, goalstack03;
.entity goalstack04, goalstack05, goalstack06, goalstack07;
.entity goalstack08, goalstack09, goalstack10, goalstack11;
.entity goalstack12, goalstack13, goalstack14, goalstack15;
.entity goalstack16, goalstack17, goalstack18, goalstack19;
.entity goalstack20, goalstack21, goalstack22, goalstack23;
.entity goalstack24, goalstack25, goalstack26, goalstack27;
.entity goalstack28, goalstack29, goalstack30, goalstack31;
*/

#define node_left  goalstack01
#define node_right goalstack02
#define node_front goalstack03
#define node_back  goalstack04

#define node_open    goalstack05
#define node_closed  goalstack06
#define node_blocked goalstack07



float pointinbox(vector point,vector box,float ssize)
{
    return 0;
}
#ifdef DEBUGPATHING

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
    path = pathlib_makepath(self.origin,end.origin, PFL_GROUNDSNAP,500,1.25,PT_QUICKSTAR);

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

#endif
