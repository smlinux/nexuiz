.float pathgroup;

.entity path_next;
.entity path_prev;
// .entity path_start;

.float(vector start,vector end) path_validate;

float pathlib_stdproc_path_validate(vector start,vector end)
{
    tracebox(start, self.mins, self.maxs, end, MOVE_NOMONSTERS, self);

    if(vlen(trace_endpos - end) < 32)
        return 1;

    return 0;
}

void pathlib_point_use()
{
    remove(self);
}

entity pathlib_createpoint(entity parent,entity next,entity first,vector where)
{
    entity point;
    point = spawn();
    point.classname = "path_node";

    //bprint("Create point\n");

    traceline(where + '0 0 32' ,where - '0 0 10000',MOVE_NOMONSTERS,self);
    where = trace_endpos + '0 0 32';

    setorigin(point,where);

    if(first)
        point.owner = parent;
    else
    {
        point.classname = "path_master";
        point.owner = point;
    }

    if(parent)
        point.path_prev = parent;

    if(next)
        point.path_next = next;
    else
        point.classname = "path_end";

    return point;
}

#define pathib_maxdivide 128

vector pathlib_findsubpath(vector start,vector vcrash,vector end,float maxsize)
{
    float x,y;//,z;
    float step;
    float clear;
    float dist;
    float pathlength;
    float pathlength_best;
    vector bestpoint;
    vector point;
    //string s;

    pathlength_best = 1000000;

    step = vlen(self.maxs - self.mins) * 1.5;
    //s = ftos(step);

    //bprint("pathlib_findsubpath: step=",s);
    //s = ftos(maxsize);
    //bprint(" size=",s,"\n");

    //for(z = -maxsize; z < maxsize; z += step)
    for(y = -maxsize; y < maxsize; y += step)
    for(x = -maxsize; x < maxsize; x += step)
    {

        point = vcrash;
        point_x = point_x + x;
        point_y = point_y + y;

        traceline(point + '0 0 32' ,point - '0 0 10000',MOVE_NOMONSTERS,self);
        point = trace_endpos + '0 0 32';

        clear = self.path_validate(start,point);

        if(clear)
        {
            //bprint("Good point\n");

            dist = vlen(start - point);
            if(dist > step)
            {
                pathlength = dist + vlen(point - end);
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
    //bprint("pathlib_path...\n");

    // Fail.
    if(start.cnt > pathib_maxdivide)
        return 0;

    if(self.path_validate(start.origin,end.origin))
        return 1;

    vcrash = trace_endpos;

    subpath_point = pathlib_findsubpath(start.origin,vcrash,end.origin,500);

    if(subpath_point == vcrash)
        return 0; // Fail.

    subpoint = pathlib_createpoint(start,end,start.owner,subpath_point);
    subpoint.cnt = start.cnt +1;
    start.path_next = subpoint;
    end.path_prev = subpoint;
    if(self.path_validate(start.origin,end.origin))
        return 1;

    return pathlib_path(subpoint,end);

    /*
    while(!clear)
    {
        ++c;

        if(c > pathib_maxdivide)
            return 0;

        subpath_point = pathlib_findsubpath(subpoint2.origin,vcrash,end.origin,2000);
        if(subpath_point == vcrash)
            return 0; // Fail.

        subpoint = pathlib_createpoint(subpoint2,end,start.owner,subpath_point);
        subpoint.cnt = subpoint2.cnt +1;
        subpoint2.path_next = subpoint;

        clear = self.path_validate(subpoint2.origin,end.origin);
        vcrash = trace_endpos;
        if(clear)
            return 1;
        subpoint2 = subpoint;

        // Fail.

    }*

    */


    return 1;
}

void pathlib_path_optimize(entity start,entity end)
{
    entity point,point_tmp;
    point = start.path_next;
    float c;

    while(point != end)
    {
        c++;
        if(c > 200)
        {
            //bprint("pathlib_path_optimize runaway!\n");
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

entity dynpath_make(vector from, vector to)
{
    entity e_start,e_end;

    //float t;
    //t = time;

    if(!self.path_validate)
        self.path_validate = pathlib_stdproc_path_validate;

    e_start = pathlib_createpoint(world,world,world,from);
    e_start.owner = e_start;
    e_end = pathlib_createpoint(e_start,world,e_start,to);
    e_start.path_next = e_end;
    e_start.cnt = 0;

    if(!pathlib_path(e_start,e_end))
    {
        //bprint("Crap.\n");
        pathlib_deletepath(e_start);
        remove(e_start);
        return world;
    }

    pathlib_path_optimize(e_start,e_end);

    //string s;
    //t = time - t;
    //s = ftos(t);
    //bprint("^2Path created in ", s, " seconds\n");

    return e_start;

}

void pathlib_test_think()
{
    //bprint("pathlib_test tink...\n");
    pathlib_showpath(self.enemy);
    self.nextthink = time + 0.5;
}
void pathlib_test_dinit()
{
    entity path;
    entity end;
    // bprint("pathlib_test spawning...\n");

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

    setsize(self,'-70 -70 0','70 70 70');
    path = dynpath_make(self.origin,end.origin);
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
