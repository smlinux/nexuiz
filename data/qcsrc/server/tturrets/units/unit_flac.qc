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
    setorigin(proj, self.tur_shotorg);
    setsize(proj, '0 0 0', '0 0 0');
    proj.classname          = "flac_projectile";
    proj.owner              = self;
    proj.bot_dodge          = TRUE;
    proj.bot_dodgerating    = self.shot_dmg;
    proj.solid              = SOLID_BBOX;
    proj.movetype           = MOVETYPE_FLYMISSILE;
    proj.flags              = FL_PROJECTILE;
    proj.takedamage         = DAMAGE_NO;
    proj.velocity           = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
    proj.angles             = vectoangles(proj.velocity);
    proj.touch              = turret_flac_projectile_explode;
    proj.think              = turret_flac_projectile_explode;
    proj.nextthink          = time + max(self.tur_impacttime,(self.shot_radius * 3) / self.shot_speed);
    proj.enemy              = self.enemy;
    proj.cnt                = time + 5;

    CSQCProjectile(proj, TRUE, PROJECTILE_HAGAR, TRUE);

    self.tur_head.frame = self.tur_head.frame + 1;
    if (self.tur_head.frame >= 4) self.tur_head.frame = 0;

}

void turret_flac_projectile_explode()
{
    float ftmp;

    // FIXME: tur_impacttime is not accurate enougth, this is a dirty hakk to make flac work.

    //w_deathtypestring = "got caught in the flack.";



    if( (self.enemy != world) &&
        (vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 3) )
    {
        // OMG HAXX!
        setorigin(self,self.enemy.origin + randomvec() * self.owner.shot_radius);
    }



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
    RadiusDamage (self, self.owner, self.owner.shot_dmg, self.owner.shot_dmg * 0.5, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif

    remove (self);
}


void turret_flac_dinit()
{
    if (self.netname == "")      self.netname  = "FLAC Cannon";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_MISSILEKILL;
    self.ammo_flags     = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags      = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("flac_std",0,"models/turrets/base.md3","models/turrets/flac.md3") == 0)
    {
        remove(self);
        return;
    }
    setsize(self.tur_head,'-32 -32 0','32 32 64');

    self.damage_flags |= TFL_DMG_HEADSHAKE;
    self.target_select_flags |= TFL_TARGETSELECT_NOTURRETS | TFL_TARGETSELECT_MISSILESONLY;

    if (!turret_tag_setup())
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_flac_attack;

}
/*QUAKED turret_flac (0 .5 .8) ?
*/

void spawnfunc_turret_flac()
{
    precache_model ("models/turrets/base.md3");
    precache_model ("models/turrets/flac.md3");

    self.think = turret_flac_dinit;
    self.nextthink = time + 0.5;
}

