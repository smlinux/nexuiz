void spawnfunc_turret_flac();
void turret_flac_dinit();
void turret_flac_attack();
void turret_flac_projectile_explode();

void turret_flac_attack()
{
    local entity proj;

    turret_tag_fire_update();

    sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", VOL_BASE, ATTN_NORM);
    proj = spawn ();
    setorigin(proj, self.tur_shotorg_updated);
    setmodel(proj, "models/turrets/pd_proj.md3");
    setsize(proj, '0 0 0', '0 0 0');
    proj.classname          = "turret_fire";
    proj.owner              = self;
    proj.bot_dodge          = TRUE;
    proj.bot_dodgerating    = self.shot_dmg;
    proj.solid              = SOLID_NOT;
    proj.movetype           = MOVETYPE_FLYMISSILE;
    proj.flags              = FL_PROJECTILE;
    proj.effects            = EF_LOWPRECISION;
    proj.takedamage         = DAMAGE_YES;
    proj.health             = 10;
    proj.velocity           = (self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
    proj.angles             = vectoangles(proj.velocity);
    proj.touch              = turret_flac_projectile_explode;
    proj.think              = turret_flac_projectile_explode;
    proj.nextthink          = time + (vlen(self.tur_aimpos - self.tur_shotorg_updated) / self.shot_speed) + (random() * self.shot_spread);

    self.tur_head.frame = self.tur_head.frame + 1;
    if (self.tur_head.frame >= 4) self.tur_head.frame = 0;

}

void turret_flac_projectile_explode()
{
    float ftmp;

    te_explosion (self.origin);

    ftmp = crandom();
    if (ftmp<-0.7)
        sound (self, CHAN_PROJECTILE, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
    else if (ftmp<0.4)
        sound (self, CHAN_PROJECTILE, "weapons/hagexp2.wav", VOL_BASE, ATTN_NORM);
    else if (ftmp<1)
        sound (self, CHAN_PROJECTILE, "weapons/hagexp3.wav", VOL_BASE, ATTN_NORM);


    self.event_damage = SUB_Null;


#ifdef TURRET_DEBUG

    ftmp = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + ftmp; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif

    remove (self);
}


void turret_flac_dinit()
{
    if (self.netname == "")      self.netname  = "FLAC Cannon";


    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_MISSILEKILL;
    self.ammo_flags     = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags      = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("flac_std") == 0)
    {
        remove(self);
        return;
    }

    setmodel(self,"models/turrets/base.md3");
    setmodel(self.tur_head,"models/turrets/flac.md3");

    if (!turret_tag_setup(0))
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_flac_attack;

}
/*QUAKED turret_flac (0 .5 .8) ?
*/

void spawnfunc_turret_flac()
{
    //precache_model ("models/turrets/base.md3");
    //precache_model ("models/turrets/flac.md3");
    //precache_model("models/turrets/pd_proj.md3");

    self.think = turret_flac_dinit;
    self.nextthink = time + 0.5;
}

