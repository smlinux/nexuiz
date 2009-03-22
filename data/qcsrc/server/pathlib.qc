//#define PATHLIB_RDFIELDS
#ifdef PATHLIB_RDFIELDS
    #define path_next swampslug
    #define path_prev lasertarget
#else
    .entity path_next;
    .entity path_prev;
#endif

entity openlist;
entity closedlist;
entity scraplist;

.float pathlib_node_g;
.float pathlib_node_h;
.float pathlib_node_f;

float pathlib_open_cnt;
float pathlib_closed_cnt;
float pathlib_made_cnt;
float pathlib_merge_cnt;
float pathlib_recycle_cnt;
float pathlib_searched_cnt;

float pathlib_bestopen_seached;
float pathlib_bestcash_hits;
float pathlib_bestcash_saved;

float pathlib_gridsize;

float pathlib_movecost;
float pathlib_movecost_diag;
float pathlib_movecost_waterfactor;

float pathlib_edge_check_size;

float pathlib_foundgoal;
entity goal_node;

entity best_open_node;
.float is_path_node;



#define DEBUGPATHING
#ifdef DEBUGPATHING
float edge_show(vector point,float fsize);
void mark_error(vector where,float lifetime);
void mark_info(vector where,float lifetime);
entity mark_misc(vector where,float lifetime);



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

void __showpath2_think()
{
    mark_info(self.origin,1);
    if(self.path_next)
    {
        self.path_next.think     = __showpath2_think;
        self.path_next.nextthink = time + 0.15;
    }
    else
    {
        self.owner.think     = __showpath2_think;
        self.owner.nextthink = time + 0.15;
    }
}

void pathlib_showpath2(entity path)
{
    path.think     = __showpath2_think;
    path.nextthink = time;
}

#endif

/*
float pathlib_stdproc_path_validate(vector start,vector end)
{
    tracebox(start, self.mins * 2, self.maxs * 2, end, MOVE_WORLDONLY, self);

    if(vlen(trace_endpos - end) < 5)
        return 1;

    return 0;
}
*/


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

float fsnap(float val,float fsize)
{
    return rint(val / fsize) * fsize;
}

vector vsnap(vector point,float fsize)
{
    vector vret;

    vret_x = rint(point_x / fsize) * fsize;
    vret_y = rint(point_y / fsize) * fsize;
    vret_z = ceil(point_z / fsize) * fsize;

    return vret;
}


#define floor_failmask (DPCONTENTS_SLIME | DPCONTENTS_LAVA)
// | DPCONTENTS_MONSTERCLIP | DPCONTENTS_DONOTENTER
float walknode_stepsize;
vector walknode_stepup;
vector walknode_maxdrop;
vector walknode_boxup;
vector walknode_boxmax;
vector walknode_boxmin;
float pathlib_movenode_goodnode;

float floor_ok(vector point)
{
    float pc;

    if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
        return 0;

    pc = pointcontents(point);

    switch(pc)
    {
        case CONTENT_SOLID:
        case CONTENT_SLIME:
        case CONTENT_LAVA:
        case CONTENT_SKY:
            return 0;
        case CONTENT_EMPTY:
            if not (pointcontents(point - '0 0 1') == CONTENT_SOLID)
                return 0;
            break;
        case CONTENT_WATER:
            return 1;
    }
    if(pointcontents(point - '0 0 1') == CONTENT_SOLID)
        return 1;

    return 0;
}

float inwater(vector point)
{
    if(pointcontents(point) == CONTENT_WATER)
        return 1;

    return 0;
}

//#define _pcheck(p) traceline(p+z_up,p-z_down,MOVE_WORLDONLY,self); if(trace_fraction == 1.0) return 1
#define _pcheck(p) traceline(p+z_up,p-z_down,MOVE_WORLDONLY,self); if not(floor_ok(trace_endpos)) return 1
float edge_check(vector point,float fsize)
{
    vector z_up,z_down;

    z_up   = '0 0 1' * fsize;
    z_down = '0 0 1' * fsize;

    _pcheck(point + ('1 1 0'  * fsize));
    _pcheck(point + ('1 -1 0'  * fsize));
    _pcheck(point + ('1 0 0' * fsize));

    _pcheck(point + ('0 1 0'  * fsize));
    _pcheck(point + ('0 -1 0' * fsize));

    _pcheck(point + ('-1 0 0'  * fsize));
    _pcheck(point + ('-1 1 0'  * fsize));
    _pcheck(point + ('-1 -1 0' * fsize));

    return 0;
}

#ifdef DEBUGPATHING
#define _pshow(p) mark_error(p,10)
float edge_show(vector point,float fsize)
{

    _pshow(point + ('1 1 0'  * fsize));
    _pshow(point + ('1 -1 0' * fsize));
    _pshow(point + ('1 0 0'  * fsize));

    _pshow(point + ('0 1 0'  * fsize));
    _pshow(point + ('0 -1 0' * fsize));

    _pshow(point + ('-1 0 0'  * fsize));
    _pshow(point + ('-1 1 0'  * fsize));
    _pshow(point + ('-1 -1 0' * fsize));

    return 0;
}
#endif

var vector pathlib_movenode(vector start,vector end,float doedge);
vector pathlib_wateroutnode(vector start,vector end)
{
    vector surface;

    pathlib_movenode_goodnode = 0;

    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    traceline(end + ('0 0 0.25' * pathlib_gridsize),end - ('0 0 1' * pathlib_gridsize),MOVE_WORLDONLY,self);
    end = trace_endpos;

    if not(pointcontents(end - '0 0 1') == CONTENT_SOLID)
        return end;

    for(surface = start ; surface_z < (end_z + 32); ++surface_z)
    {
        if(pointcontents(surface) == CONTENT_EMPTY)
            break;
    }
    //mark_error(surface,10);

    if(pointcontents(surface + '0 0 1') != CONTENT_EMPTY)
        return end;

    tracebox(start + '0 0 64', walknode_boxmin,walknode_boxmax, end + '0 0 64', MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
    {
        pathlib_movenode_goodnode = 1;
        //mark_error(end + '0 0 64',30);
    }

    if(fabs(surface_z - end_z) > 32)
        pathlib_movenode_goodnode = 0;

    return end;
}

vector pathlib_swimnode(vector start,vector end)
{
    pathlib_movenode_goodnode = 0;

    if(pointcontents(start) != CONTENT_WATER)
        return end;

    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    if(pointcontents(end) == CONTENT_EMPTY)
        return pathlib_wateroutnode( start, end);

    tracebox(start, walknode_boxmin,walknode_boxmax, end, MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
        pathlib_movenode_goodnode = 1;

    return end;
}

vector pathlib_flynode(vector start,vector end)
{
    pathlib_movenode_goodnode = 0;

    /*
    if(pointcontents(start) == CONTENT_EMPTY)
        return end;

    if(pointcontents(end) == CONTENT_EMPTY)
        return end;
    */
    end_x = fsnap(end_x, pathlib_gridsize);
    end_y = fsnap(end_y, pathlib_gridsize);

    tracebox(start, walknode_boxmin,walknode_boxmax, end, MOVE_WORLDONLY, self);
    if(trace_fraction == 1)
        pathlib_movenode_goodnode = 1;

    return end;
}

vector pathlib_walknode(vector start,vector end,float doedge)
{
    vector direction,point,last_point,s,e;
    float steps, distance, i,laststep;

    pathlib_movenode_goodnode = 0;

    s   = start;
    e   = end;
    e_z = 0;
    s_z = 0;
    direction  = normalize(s - e);

    distance    = vlen(start - end);
    laststep    = distance / walknode_stepsize;
    steps       = floor(laststep);
    laststep    = laststep - steps;

    point = start;
    s     = point + walknode_stepup;
    e     = point - walknode_maxdrop;

    traceline(s, e,MOVE_WORLDONLY,self);
    if(trace_fraction == 1.0)
        return trace_endpos;

    if (floor_ok(trace_endpos) == 0)
        return trace_endpos;

    last_point = trace_endpos;

    for(i = 0; i < steps; ++i)
    {
        point = last_point + direction * walknode_stepsize;

        s = point + walknode_stepup;
        e = point - walknode_maxdrop;
        traceline(s, e,MOVE_WORLDONLY,self);
        if(trace_fraction == 1.0)
            return trace_endpos;

        point = trace_endpos;
        if not(floor_ok(trace_endpos))
            return trace_endpos;

        tracebox(last_point + walknode_boxup, walknode_boxmin,walknode_boxmax, point + walknode_boxup, MOVE_WORLDONLY, self);
        if(trace_fraction != 1.0)
            return trace_endpos;

        if(doedge)
        if(edge_check(point,pathlib_edge_check_size))
            return trace_endpos;

        last_point = point;
    }

    point = last_point + direction * walknode_stepsize * laststep;

    point_x = fsnap(point_x, pathlib_gridsize);
    point_y = fsnap(point_y, pathlib_gridsize);

    s = point + walknode_stepup;
    e = point - walknode_maxdrop;
    traceline(s, e,MOVE_WORLDONLY,self);

    if(trace_fraction == 1.0)
        return trace_endpos;

    point = trace_endpos;

    if not(floor_ok(trace_endpos))
        return trace_endpos;

    tracebox(last_point + walknode_boxup, walknode_boxmin,walknode_boxmax, point + walknode_boxup, MOVE_WORLDONLY, self);
    if(trace_fraction != 1.0)
        return trace_endpos;

    pathlib_movenode_goodnode = 1;
    return point;
}

var float pathlib_cost(entity parent,vector to, float static_cost);
float pathlib_g_static(entity parent,vector to, float static_cost)
{
    if(inwater(to))
        return parent.pathlib_node_g + static_cost * pathlib_movecost_waterfactor;
    else
        return parent.pathlib_node_g + static_cost;
}

float pathlib_g_euclidean(entity parent,vector to, float static_cost)
{
    return vlen(parent.origin - to);
}

var float(vector from,vector to) pathlib_heuristic;
float pathlib_h_manhattan(vector a,vector b)
{
    //h(n) = D * (abs(n.x-goal.x) + abs(n.y-goal.y))

    float h;
    h = fabs(a_x - b_x);
    h = h + fabs(a_y - b_y);
    h = pathlib_gridsize * h;

    return h;
}

float pathlib_h_diagonal(vector a,vector b)
{
    //h(n) = D * max(abs(n.x-goal.x), abs(n.y-goal.y))
    float h,x,y;

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);
    h = pathlib_movecost * max(x,y);

    return h;
}

float pathlib_h_euclidean(vector a,vector b)
{
    return vlen(a - b);
}

float pathlib_h_diagonal2(vector a,vector b)
{
    float h_diag,h_str,h,x,y;

    /*
    h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))
    */

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);

    h_diag = min(x,y);
    h_str = x + y;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    return h;
}

float pathlib_h_diagonal2tbs(vector start,vector point,vector end)
{
    float h_diag,h_str,h,x,y;

    /*
    h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))
    */

    float dx1,dx2,dy1,dy2,fcross;
    dx1 = point_x - end_x;
    dy1 = point_y - end_y;
    dx2 = start_x - end_x;
    dy2 = start_y - end_y;
    fcross = fabs(dx1*dy2 - dx2*dy1);

    x = fabs(point_x - end_x);
    y = fabs(point_y - end_y);

    h_diag = min(x,y);
    h_str = x + y;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    return h + (fcross * 0.001);
}

float pathlib_h_diagonal2sdp(vector preprev,vector prev,vector point,vector end)
{
    float h_diag,h_str,h,x,y,z;

    //h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    //h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    //h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))

    x = fabs(point_x - end_x);
    y = fabs(point_y - end_y);
    z = fabs(point_z - end_z);

    h_diag = min3(x,y,z);
    h_str = x + y + z;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    float m;
    vector d1,d2;

    m = 0.999;
    d1 = normalize(preprev - prev);
    d2 = normalize(prev - point);
    if(vlen(d1-d2) > 0.6)
        m = 1;


    return h * m;
}


float pathlib_h_diagonal3(vector a,vector b)
{
    float h_diag,h_str,h,x,y,z;

    //h_diagonal(n) = min(abs(n.x-goal.x), abs(n.y-goal.y))
    //h_straight(n) = (abs(n.x-goal.x) + abs(n.y-goal.y))
    //h(n) = D2 * h_diagonal(n) + D * (h_straight(n) - 2*h_diagonal(n)))

    x = fabs(a_x - b_x);
    y = fabs(a_y - b_y);
    z = fabs(a_z - b_z);

    h_diag = min3(x,y,z);
    h_str = x + y + z;

    h =  pathlib_movecost_diag * h_diag;
    h += pathlib_movecost * (h_str - 2 * h_diag);

    //if(inwater(a))
    //h =

    return h;
}

//#define PATHLIB_USE_NODESCRAP
float pathlib_scraplist_cnt;
entity newnode()
{
    entity n;
#ifdef PATHLIB_USE_NODESCRAP
    if(pathlib_scraplist_cnt)
    {
        n = findentity(world,owner,scraplist);
        if(n)
        {
            --pathlib_scraplist_cnt;
            ++pathlib_recycle_cnt;
            return n;
        }
        else
            pathlib_scraplist_cnt = 0;
    }
#endif
    ++pathlib_made_cnt;
    n = spawn();
    return n;
}

void dumpnode(entity n)
{
#ifdef PATHLIB_USE_NODESCRAP
    ++pathlib_scraplist_cnt;
    n.owner = scraplist;
#else
    n.is_path_node = FALSE;
    n.think = SUB_Remove;
    n.nextthink= time;
#endif
}

entity pathlib_mknode(vector where,entity parent)
{
    entity node;

    node              = newnode();
    node.is_path_node = TRUE;
    node.owner        = openlist;
    node.path_prev    = parent;

    setorigin(node, where);

    ++pathlib_open_cnt;

    //if(inwater(where))
    //{
        //node.waterlevel = 1;
        //mark_info(where,5);
    //}
    //mark_info(where,30);
    return node;
}
var float pathlib_expandnode(entity node, vector start, vector goal);
float pathlib_expandnode_star(entity node, vector start, vector goal);
float pathlib_expandnode_box(entity node, vector start, vector goal);

float pathlib_makenode(entity parent,vector start, vector to, vector goal,float cost)
{
    entity node;
    float h,g,f,doedge;
    vector where;

    ++pathlib_searched_cnt;

    if(inwater(parent.origin))
    {
        if(inwater(to))
        {
            //bprint("Switch to water tracing\n");
            pathlib_expandnode = pathlib_expandnode_box;
            pathlib_movenode   = pathlib_swimnode;
        }
        else
        {

            //bprint("Switch to get out of water tracing\n");
            pathlib_expandnode = pathlib_expandnode_box;
            pathlib_movenode   = pathlib_swimnode;
        }
    }
    else
    {
        if(inwater(to))
        {
            //bprint("Switch to get into water tracing\n");
            pathlib_expandnode = pathlib_expandnode_box;
            pathlib_movenode   = pathlib_swimnode;
        }
        else
        {

            //bprint("Switch to land tracing\n");
            pathlib_expandnode = pathlib_expandnode_star;
            pathlib_movenode   = pathlib_walknode;
            doedge = 1;
        }
    }

    where = pathlib_movenode(parent.origin,to,0);
    if not(pathlib_movenode_goodnode)
    {
        //mark_error(where,15);
        return 0;
    }

    if(doedge)
    if(edge_check(where,pathlib_edge_check_size))
        return 0;

    h = pathlib_heuristic(where,goal);

    /*
    if(parent.path_prev)
        h = pathlib_h_diagonal2sdp(parent.path_prev.origin,parent.origin,where,goal);
    else
        h = pathlib_heuristic(where,goal);
    */


    //h = 0;
    g = pathlib_cost(parent,where,cost);
    f = g + h;

    node = findradius(where,pathlib_gridsize * 0.75);
    while(node)
    {
        if(node.is_path_node == TRUE)
        {
            ++pathlib_merge_cnt;
            if(node.owner == openlist)
            {
                if(node.pathlib_node_g > g)
                {
                    node.pathlib_node_h = h;
                    node.pathlib_node_g = g;
                    node.pathlib_node_f = f;
                    node.path_prev = parent;
                }

                if not (best_open_node)
                    best_open_node = node;
                else if(best_open_node.pathlib_node_f > node.pathlib_node_f)
                    best_open_node = node;
            }

            return 1;
        }
        node = node.chain;
    }

    node = pathlib_mknode(where,parent);

    node.pathlib_node_h = h;
    node.pathlib_node_g = g;
    node.pathlib_node_f = f;

    if not (best_open_node)
        best_open_node = node;
    else if(best_open_node.pathlib_node_f > node.pathlib_node_f)
        best_open_node = node;

    return 1;
}

entity pathlib_getbestopen()
{
    entity node;
    entity bestnode;

    if(best_open_node)
    {
        ++pathlib_bestcash_hits;
        pathlib_bestcash_saved += pathlib_open_cnt;

        return best_open_node;
    }

    node = findchainentity(owner,openlist);
    if(!node)
        return world;

    bestnode = node;
    while(node)
    {
        ++pathlib_bestopen_seached;
        if(node.pathlib_node_f < bestnode.pathlib_node_f)
            bestnode = node;

        node = node.chain;
    }

    return bestnode;
}

void pathlib_close_node(entity node,vector goal)
{

    if(node.owner == closedlist)
    {
        dprint("Pathlib: Tried to close a closed node!\n");
        return;
    }

    if(node == best_open_node)
        best_open_node = world;

    ++pathlib_closed_cnt;
    --pathlib_open_cnt;

    node.owner = closedlist;

    if(vlen(node.origin - goal) <= pathlib_gridsize)
    {
        //if(vlen(node.origin - goal) < 128)
        vector goalmove;
        goalmove = pathlib_walknode(node.origin,goal,1);
        if(pathlib_movenode_goodnode)
            {
                goal_node         = node;
                pathlib_foundgoal = TRUE;
            }
    }
}

float pathlib_expandnode_star(entity node, vector start, vector goal)
{
    vector point;
    vector where;
    float nodecnt;

    where = node.origin;

    v_forward = '1 0 0';
    v_right   = '0 1 0';

    // Forward
    point = where + v_forward * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost);

    // Back
    point = where - v_forward * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost);

    // Right
    point = where + v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost);

    // Left
    point = where - v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost);

    // Forward-right
    point = where + v_forward * pathlib_gridsize + v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost_diag);

    // Forward-left
    point = where + v_forward * pathlib_gridsize - v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost_diag);

    // Back-right
    point = where - v_forward * pathlib_gridsize + v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost_diag);

    // Back-left
    point = where - v_forward * pathlib_gridsize - v_right * pathlib_gridsize;
    nodecnt += pathlib_makenode(node,start,point,goal,pathlib_movecost_diag);

    return pathlib_open_cnt;
}

float pathlib_expandnode_box(entity node, vector start, vector goal)
{
    vector v;

    for(v_z = node.origin_z - pathlib_gridsize; v_z <= node.origin_z + pathlib_gridsize; v_z += pathlib_gridsize)
    for(v_y = node.origin_y - pathlib_gridsize; v_y <= node.origin_y + pathlib_gridsize; v_y += pathlib_gridsize)
    for(v_x = node.origin_x - pathlib_gridsize; v_x <= node.origin_x + pathlib_gridsize; v_x += pathlib_gridsize)
    {
        if(vlen(v - node.origin))
            pathlib_makenode(node,start,v,goal,pathlib_movecost);
    }

    return pathlib_open_cnt;
}

void pathlib_cleanup()
{
    entity node;

    best_open_node = world;

    node = findfloat(world,is_path_node, TRUE);
    while(node)
    {
        node.path_next = world;
        node.path_prev = world;
        node.is_path_node = FALSE;
        dumpnode(node);
        node = findfloat(node,is_path_node, TRUE);
    }

    if(openlist)
        remove(openlist);

    if(closedlist)
        remove(closedlist);
}

entity pathlib_astar(vector from,vector to)
{
    entity path;
    entity open,n;

    pathlib_cleanup();

    pathlib_heuristic  = pathlib_h_diagonal3;
    pathlib_cost       = pathlib_g_static;
    pathlib_expandnode = pathlib_expandnode_star;
    pathlib_movenode   = pathlib_walknode;

    if not(openlist)
        openlist       = spawn();

    if not(closedlist)
        closedlist     = spawn();

    if not(scraplist)
        scraplist      = spawn();

    pathlib_closed_cnt     = 0;
    pathlib_open_cnt       = 0;
    pathlib_made_cnt       = 0;
    pathlib_merge_cnt      = 0;
    pathlib_searched_cnt   = 0;
    pathlib_bestcash_hits  = 0;
    pathlib_bestcash_saved = 0;
    pathlib_recycle_cnt    = 0;

    pathlib_gridsize       = 192;
    pathlib_movecost       = pathlib_gridsize;
    pathlib_movecost_diag  = vlen(('1 1 0' * pathlib_gridsize));
    pathlib_movecost_waterfactor = 1.1;
    pathlib_foundgoal      = 0;

    walknode_boxmax   = self.maxs * 1.5;
    walknode_boxmin   = self.mins * 1.5;

    pathlib_edge_check_size = (vlen(walknode_boxmin - walknode_boxmax) * 0.25);

    walknode_boxup    = '0 0 2' * self.maxs_z;
    walknode_stepsize = 32;
    walknode_stepup   = '0 0 1' * walknode_stepsize;
    walknode_maxdrop  = '0 0 3' * walknode_stepsize;

    dprint("AStar init. ", ftos(pathlib_scraplist_cnt), " nodes on scrap\n");
    path = pathlib_mknode(from,world);
    pathlib_close_node(path,to);
    if(pathlib_foundgoal)
    {
        dprint("A* Goal fond in first square!\n");

        open           = spawn();
        open.owner     = open;
        open.classname = "path_end";
        setorigin(open,path.origin);
        pathlib_cleanup();

        return open;
    }

    if(pathlib_expandnode(path,from,to) <= 0)
    {
        dprint("A* pathing fail\n");
        pathlib_cleanup();
        return world;
    }

    best_open_node = pathlib_getbestopen();
    n = best_open_node;
    pathlib_close_node(best_open_node,to);
    if(inwater(n.origin))
        pathlib_expandnode_box(n,from,to);
    else
        pathlib_expandnode_star(n,from,to);

    while(pathlib_open_cnt)
    {
        best_open_node = pathlib_getbestopen();
        n = best_open_node;
        pathlib_close_node(best_open_node,to);

        if(inwater(n.origin))
            pathlib_expandnode_box(n,from,to);
        else
            pathlib_expandnode(n,from,to);

        if(pathlib_foundgoal)
        {
            dprint("Path found, re-tracing...\n");

            open              = goal_node;
            open.is_path_node = FALSE;
            open.classname    = "path_end";
            open.owner        = path;
            open.path_next    = world;


            while(open.path_prev != path)
            {
                n                 = open;
                open              = open.path_prev;
                open.owner        = path;
                open.path_next    = n;

                open.is_path_node = FALSE;
                open.classname    = "path_node";
            }

            open.path_prev    = path;
            path.path_next    = open;
            path.classname    = "path_master";
            path.is_path_node = FALSE;
            path.owner        = path;

            pathlib_cleanup();

#ifdef DEBUGPATHING
            dprint("Chain done..\n");
            pathlib_showpath2(path);


            dprint("           Nodes reused: ", ftos(pathlib_recycle_cnt),"\n");
            dprint("          Nodes created: ", ftos(pathlib_made_cnt),"\n");
            dprint("       Nodes make/reuse: ", ftos(pathlib_made_cnt / pathlib_recycle_cnt),"\n");
            dprint("             Nodes open: ", ftos(pathlib_open_cnt),"\n");
            dprint("           Nodes merged: ", ftos(pathlib_merge_cnt),"\n");
            dprint("           Nodes closed: ", ftos(pathlib_closed_cnt),"\n");
            dprint("         Nodes searched: ", ftos(pathlib_searched_cnt),"\n");
            dprint("Nodes bestopen searched: ", ftos(pathlib_bestopen_seached),"\n");
            dprint("    Nodes bestcash hits: ", ftos(pathlib_bestcash_hits),"\n");
            dprint("    Nodes bestcash save: ", ftos(pathlib_bestcash_saved),"\n");
            dprint("AStar done. ", ftos(pathlib_scraplist_cnt), " nodes on scrap\n\n");

#endif
            return path;
        }
    }

    dprint("A* Faild to find a path! Try a smaller gridsize.\n");

    pathlib_cleanup();

    return world;
}

