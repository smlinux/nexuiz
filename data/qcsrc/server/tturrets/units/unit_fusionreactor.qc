void spawnfunc_turret_fusionreactor();
void turret_fusionreactor_dinit();
void turret_fusionreactor_fire();

float turret_fusionreactor_firecheck()
{
    if (self.enemy == world) return 0;

    if (!(self.enemy.ammo_flags & TFL_AMMO_RECIVE)) return 0;
    if (!(self.enemy.ammo_flags & TFL_AMMO_ENERGY)) return 0;

    if (self.ammo < self.shot_dmg) return 0;
    if (self.enemy.ammo >= self.enemy.ammo_max) return 0;
    if (self.tur_dist_aimpos > self.target_range) return 0;
    if (self.tur_dist_aimpos < self.target_range_min) return 0;

    return 1;
}


void turret_fusionreactor_fire()
{
    self.enemy.ammo = min(self.enemy.ammo + self.shot_dmg,self.enemy.ammo_max);
    //te_lightning1(world,self.origin,self.enemy.origin);
}

void turret_fusionreactor_postthink()
{
}

void turret_fusionreactor_respawnhook()
{
    self.tur_head.avelocity = '0 50 0';
}

void turret_fusionreactor_dinit()
{
    if (self.netname == "")      self.netname     = "Fusionreactor";

    self.turrcaps_flags = TFL_TURRCAPS_SUPPORT | TFL_TURRCAPS_AMMOSOURCE;

    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;

    self.target_select_flags = TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_OWNTEAM | TFL_TARGETSELECT_RANGELIMTS;

    self.firecheck_flags = TFL_FIRECHECK_OWM_AMMO | TFL_FIRECHECK_OTHER_AMMO | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_DEAD | TFL_FIRECHECK_WORLD;

    self.shoot_flags = TFL_SHOOT_HITALLVALID;
    self.aim_flags = TFL_AIM_NO;
    self.track_flags = TFL_TRACK_NO;
    self.turret_respawnhook = turret_fusionreactor_respawnhook;
    if (turret_stdproc_init("fusreac_std",0,"models/turrets/base.md3","models/turrets/reactor.md3") == 0)
    {
        remove(self);
        return;
    }
    setsize(self.tur_head,'-32 -32 0','32 32 64');

    self.tur_head.scale = 0.75;
    setorigin(self.tur_head,self.origin + '0 0 25');
    self.tur_head.avelocity = '0 50 0';

    self.turret_firecheckfunc = turret_fusionreactor_firecheck;
    self.turret_firefunc = turret_fusionreactor_fire;

    self.turret_postthink = turret_fusionreactor_postthink;
}

/*QUAKED turret_fusionreactor (0 .5 .8) ?
*/
void spawnfunc_turret_fusionreactor()
{
    precache_model ("models/turrets/reactor.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_fusionreactor_dinit;
    self.nextthink = time + 0.5;
}
