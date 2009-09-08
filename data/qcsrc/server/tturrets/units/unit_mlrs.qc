void spawnfunc_turret_mlrs();
void turret_mlrs_dinit();
void turret_mlrs_attack();
void turret_mlrs_rocket_explode();
void turret_mlrs_rocket_touch();

void turret_mlrs_postthink()
{

    // 0 = full, 6 = empty
    self.tur_head.frame = rint(6 - (self.ammo / self.shot_dmg));
}

void turret_mlrs_attack()
{
    entity missile;

    turret_tag_fire_update();

    sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", VOL_BASE, ATTN_NORM);

    missile                    = spawn ();
    setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot
    setorigin(missile, self.tur_shotorg);
    missile.classname          = "mlrs_missile";
    missile.owner              = self;
    missile.bot_dodge          = TRUE;
    missile.bot_dodgerating    = self.shot_dmg;
    missile.takedamage         = DAMAGE_NO;
    missile.damageforcescale   = 4;
    missile.think              = turret_mlrs_rocket_explode;
    missile.nextthink          = time + max(self.tur_impacttime,(self.shot_radius * 2) / self.shot_speed);
    missile.solid              = SOLID_BBOX;
    missile.movetype           = MOVETYPE_FLYMISSILE;
    missile.velocity           = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
    missile.angles             = vectoangles(missile.velocity);
    missile.touch              = turret_mlrs_rocket_touch;
    missile.flags              = FL_PROJECTILE;
    missile.solid              = SOLID_BBOX;
    missile.enemy              = self.enemy;

	CSQCProjectile(missile, TRUE, PROJECTILE_ROCKET, FALSE); // no cull, fly sound

    te_explosion (missile.origin);
}

void turret_mlrs_rocket_touch()
{
    if( (other == self.owner) || (other == self.owner.tur_head) )
        return;

    PROJECTILE_TOUCH;

    turret_mlrs_rocket_explode();
}

void turret_mlrs_rocket_explode()
{
    vector org2;

    if(self.event_damage != SUB_Null)
    {
        self.event_damage = SUB_Null;
        self.think = turret_mlrs_rocket_explode;
        self.nextthink = time;
        return;
    }


    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);
    pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
    //w_deathtypestring = "dident escape the rocket barrage";
#ifdef TURRET_DEBUG
    float d;

    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.owner, self.owner.shot_dmg, self.owner.shot_dmg * 0.5, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif

    // Target dead, Tell turret.
    if ((self.enemy.deadflag != DEAD_NO) && (self.enemy == self.owner.enemy))
        self.owner.enemy = world;

    remove (self);
}

void turret_mlrs_dinit()
{
    if (self.netname == "")      self.netname  = "MLRS turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;// | TFL_AIM_GROUND2;

    if (turret_stdproc_init("mlrs_std",0,"models/turrets/base.md3","models/turrets/mlrs.md3") == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;
    self.shoot_flags  |= TFL_SHOOT_VOLLYALWAYS;
    self.volly_counter = self.shot_volly;

    if (!turret_tag_setup())
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_mlrs_attack;
    self.turret_postthink = turret_mlrs_postthink;

}

/*QUAKED turret_mlrs (0 .5 .8) ?
*/

void spawnfunc_turret_mlrs()
{
    precache_model ("models/turrets/mlrs.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_mlrs_dinit;
    self.nextthink = time + 0.5;
}


