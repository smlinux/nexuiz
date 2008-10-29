/**
    turret_checkpoint
    Semi smart pathing system for move capable turrets.
**/

#define checkpoint_path swampslug
#define checkpoint_target enemy

#define checkpoint_cache_who flagcarried
#define checkpoint_cache_from lastrocket
#define checkpoint_cache_to selected_player

entity path_makeorcache(entity forwho,entity start, entity end)
{
    entity oldself;
    entity pth;
    oldself = self;
    self = forwho;

    pth = pathlib_makepath(start.origin,end.origin,PLF_GROUNDSNAP,500,1.5);
    self = oldself;
    return pth;
}

void turret_checkpoint_use()
{
    if(other.checkpoint_path)
        pathlib_deletepath(other.checkpoint_path);

    other.checkpoint_path = world;

    if(self.checkpoint_target)
        other.checkpoint_path = path_makeorcache(other,self,self.checkpoint_target);

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
void spawnfunc_turret_checkpoint()
{
    if(self.target != "")
    {
        self.checkpoint_target = find(world,targetname,self.target);
        if(!self.checkpoint_target)
            dprint("A turret_checkpoint faild to find its target!\n");
    }

}

// Compat.
void spawnfunc_walker_checkpoint()
{
    self.classname = "turret_checkpoint";
    spawnfunc_turret_checkpoint();
}
