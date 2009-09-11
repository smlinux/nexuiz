void spawnfunc_turret_machinegun();
void turret_machinegun_std_init();
void turret_machinegun_attack();

//.float bulletcounter;
void turret_machinegun_attack()
{

    entity flash;

    sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", VOL_BASE, ATTN_NORM);
    fireBallisticBullet (self.tur_shotorg, self.tur_shotdir_updated,self.shot_spread, self.shot_speed, 5, self.shot_dmg, 0, self.shot_force, DEATH_TURRET, 0, 1, cvar("g_balance_uzi_bulletconstant"));
    endFireBallisticBullet();

    //w_deathtypestring = "had an alergic reaction due to 10 kilos of led";
    te_smallflash(self.tur_shotorg);

    // muzzle flash for 3rd person view
    flash = spawn();
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
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL;
    self.aim_flags = TFL_AIM_LEAD;

    if(cvar("g_antilag_bullets"))
        self.turrcaps_flags |= TFL_TURRCAPS_HITSCAN;
    else
        self.aim_flags      |= TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("machinegun_std",0,"models/turrets/base.md3","models/turrets/machinegun.md3") == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;

    if (!turret_tag_setup())
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_machinegun_attack;

}


/*QUAKED turret_machinegun (0 .5 .8) ?
* machinegun turret. does what you'd expect
*/
void spawnfunc_turret_machinegun()
{
    precache_model ("models/turrets/machinegun.md3");
    precache_model ("models/turrets/base.md3");
    precache_sound ("weapons/uzi_fire.wav");

    self.think = turret_machinegun_std_init;
    self.nextthink = time + 0.5;
}

