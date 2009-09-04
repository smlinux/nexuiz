/**
    turret_checkpoint
**/


//.entity checkpoint_target;

/*
#define checkpoint_cache_who  flagcarried
#define checkpoint_cache_from lastrocket
#define checkpoint_cache_to   selected_player
*/

.entity pathgoal;
.entity pathcurrent;

/*
entity path_makeorcache(entity forwho,entity start, entity end)
{
    entity oldself;
    entity pth;
    oldself = self;
    self = forwho;

    //pth = pathlib_makepath(start.origin,end.origin,PFL_GROUNDSNAP,500,1.5,PT_QUICKSTAR);

    self = oldself;
    return pth;
}
*/

void turret_checkpoint_use()
{
}

/*QUAKED turret_checkpoint (1 0 1) (-32 -32 -32) (32 32 32)
-----------KEYS------------
target: .targetname of next waypoint in chain.
wait:   Pause at this point # seconds.
-----------SPAWNFLAGS-----------
---------NOTES----------
If a loop is of targets are formed, any unit entering this loop will patrol it indefinitly.
If the checkpoint chain in not looped, the unit will go "Roaming" when the last point is reached.
*/
void turret_checkpoint_init()
{
    traceline(self.origin, self.origin - '0 0 1024', MOVE_WORLDONLY, self);
    setorigin(self,trace_endpos + '0 0 8');

    if(self.target != "")
    {
        self.enemy = find(world,targetname,self.target);
        if(self.enemy == world)
            dprint("A turret_checkpoint faild to find its target!\n");
    }
}

void spawnfunc_turret_checkpoint()
{
    setorigin(self,self.origin);
    self.think = turret_checkpoint_init;
    self.nextthink = time + 0.1;
}

// Compat.
void spawnfunc_walker_checkpoint()
{
    self.classname = "turret_checkpoint";
    spawnfunc_turret_checkpoint();
}
