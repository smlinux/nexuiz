void spawnfunc_turret_machinegun();
void turret_machinegun_std_init();
void turret_machinegun_attack();

//.float bulletcounter;
void turret_machinegun_attack()
{

    entity flash;
    sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", VOL_BASE, ATTN_NORM);
    fireBullet (self.tur_shotorg_updated, self.tur_shotdir_updated,self.shot_spread, self.shot_dmg, self.shot_force, DEATH_TURRET, FALSE);

    te_smallflash(self.tur_shotorg_updated);
    trailparticles(self,particleeffectnum("EF_MGTURRETTRAIL"),self.tur_shotorg_updated,trace_endpos);

    // muzzle flash for 3rd person view
    flash = spawn();
    //setorigin(flash, '43 1 8');
    setmodel(flash, "models/uziflash.md3"); // precision set below
    setattachment(flash, self.tur_head, "tag_fire");
    flash.think = W_Uzi_Flash_Go;
    flash.nextthink = time + 0.02;
    flash.frame = 2;
    flash.angles_z = flash.v_angle_z + random() * 180;
    flash.alpha = 1;
    flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
}


void turret_machinegun_std_init()
{
    if (self.netname == "")      self.netname     = "Machinegun Turret";

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_HITSCAN | TFL_TURRCAPS_PLAYERKILL;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_ZEASE;

    if (turret_stdproc_init("machinegun_std") == 0)
    {
        remove(self);
        return;
    }

    setmodel(self,"models/turrets/base.md3");
    setmodel(self.tur_head,"models/turrets/machinegun.md3");

    if (!turret_tag_setup(0))
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_machinegun_attack;

}



/*
* machinegun turret. does what you'd expect
*/

/*QUAKED turret_machinegun (0 .5 .8) ?
*/
void spawnfunc_turret_machinegun()
{
    //precache_model ("models/turrets/machinegun.md3");
    //precache_model ("models/turrets/base.md3");

    self.think = turret_machinegun_std_init;
    self.nextthink = time + 0.5;
}

