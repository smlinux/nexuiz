void checkpoint_think()
{
    if(self.goalcurrent != world)
        te_lightning1(self,self.origin,self.goalcurrent.origin);


    self.nextthink = time + 0.5;
}

void turret_checkpoint_dinit()
{
    entity e;


    if(self.target != "")
    {
        e = find(world,targetname,self.target);
        if(!e)
        {
            bprint("turret_checkpoint without valid target! (",vtos(self.origin),")\n");
            remove(self);
            return;
        }

        // TODO:: ADD WORLD-INTERACTIVE PATH SUBDEVISION IF PATH NOT CLEAR
        self.goalcurrent = e;
    }

}

/**
.wait
**/
void spawnfunc_turret_checkpoint()
{
    if(!self.wait)
        self.wait = 5;

    self.think = turret_checkpoint_dinit;
    self.nextthink = time + 0.25;
}
