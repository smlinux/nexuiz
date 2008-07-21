void spawnfunc_turret_tesla();
void turret_tesla_dinit();
void turret_tesla_fire();

.float toasted;
entity toast(entity from, float range, float damage)
{
    entity e;
    entity etarget;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if((e.toasted != 1) && (e != from))
        if (turret_validate_target(self,e,self.target_validate_flags) > 0)
        {

            traceline(from.origin,e.origin,0,from);
            if(trace_fraction > 0.9)
            {
                d = vlen(e.origin - from.origin);
                if(d < dd)
                {
                    dd = d;
                    etarget = e;
                }
            }
        }
        e = e.chain;
    }

    if(etarget)
    {
        te_smallflash(etarget.origin);
        te_lightning1(world,from.origin,etarget.origin);
        Damage(etarget,self,self,damage,DEATH_TURRET,etarget.origin,'0 0 0');
        etarget.toasted = 1;
    }

    return etarget;
}

void turret_tesla_fire()
{
    entity e,t;
    float d,r,i;

    if(cvar("g_turrets_nofire") != 0)
        return;

    if(self.attack_finished > time) return;

    d = self.shot_dmg;
    r = self.target_range;
    e = spawn();
    setorigin(e,self.origin + self.tur_shotorg);


    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES |
                                 TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = toast(e,r,d);
    remove(e);

    if(t == world) return;

    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES |
                                 TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished = time + self.shot_refire;
    self.ammo = self.ammo - self.shot_dmg;
    for(i = 0;i < 10;i++)
    {
        d *= 0.5; r *= 0.75;
        t = toast(t,r,d);
        if(t == world) break;
    }

    e = findchainfloat(toasted, 1);
    while(e)
    {
        e.toasted = 0;
        e = e.chain;
    }
}

void turret_tesla_postthink()
{
    turret_tesla_fire();

    self.tur_head.frame = self.tur_head.frame + 1;

    if(self.tur_head.frame >= 11)
        self.tur_head.frame = 0;

    if(self.tur_head.avelocity == '0 0 0')
        self.tur_head.avelocity = '0 35 0';
}


void turret_tesla_dinit()
{
    if (self.netname == "")      self.netname     = "Tesla Coil";

    self.turrcaps_flags = TFL_TURRCAPS_HITSCAN | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MISSILEKILL;
    self.target_select_flags = TFL_TARGETSELECT_NO;
    self.firecheck_flags = TFL_FIRECHECK_REFIRE;
    self.shoot_flags = TFL_SHOOT_CUSTOM;
    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.aim_flags = TFL_AIM_NO;
    self.track_flags = TFL_TRACK_NO;

    precache_model ("models/turrets/tesla_head.md3");
    precache_model ("models/turrets/tesla_base.md3");

    if (turret_stdproc_init("tesla_std") == 0)
    {
        remove(self);
        return;
    }

    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES |
                                 TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;


    setmodel(self,"models/turrets/tesla_base.md3");
    setmodel(self.tur_head,"models/turrets/tesla_head.md3");

    if(!turret_tag_setup(0))
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    self.turret_firefunc = turret_stdproc_nothing;
    self.turret_postthink = turret_tesla_postthink;
}

/*QUAKED turret_tesla (0 .5 .8) ?
*/
void spawnfunc_turret_tesla()
{
    // return;
    self.think = turret_tesla_dinit;
    self.nextthink = time + 0.5;
}

