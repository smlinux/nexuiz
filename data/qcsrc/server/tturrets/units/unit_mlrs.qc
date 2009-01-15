void spawnfunc_turret_mlrs();
void turret_mlrs_dinit();
void turret_mlrs_attack();
void turret_mlrs_rocket_explode();

void turret_mlrs_postthink()
{

    // 0 = full, 6 = empty

    self.tur_head.frame = rint(6 - (self.ammo / self.shot_dmg));

    //if ((self.tur_head.frame >= 6) && (self.attack_finished_single <= time))
    //    self.tur_head.frame = 0;
}

void turret_mlrs_attack()
{
    entity missile;

    turret_tag_fire_update();

    sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", 1, ATTN_NORM);

    missile                    = spawn ();
    setmodel (missile, "models/turrets/rocket.md3"); // precision set below
    setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot
    sound (missile, CHAN_PAIN, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);
    setorigin(missile, self.tur_shotorg_updated);
    missile.classname          = "mlrs_missile";
    missile.owner              = self;
    missile.bot_dodge          = TRUE;
    missile.bot_dodgerating    = self.shot_dmg;
    missile.takedamage         = DAMAGE_YES;
    missile.damageforcescale   = 4;
    missile.health             = 30;
    missile.think              = turret_mlrs_rocket_explode;
    missile.nextthink          = time + max(self.tur_impacttime,(self.shot_radius * 2) / self.shot_speed);
    missile.solid              = SOLID_BBOX;
    missile.movetype           = MOVETYPE_FLYMISSILE;
    missile.effects            = EF_LOWPRECISION;
    missile.velocity           = (self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
    missile.angles             = vectoangles(missile.velocity);
    missile.touch              = turret_mlrs_rocket_explode;
    missile.flags              = FL_PROJECTILE;
    missile.solid              = SOLID_BBOX;
    missile.enemy              = self.enemy;

    te_explosion (missile.origin);

    //self.tur_head.frame = 7 - self.volly_counter;
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


	stopsound (self, CHAN_PAIN);
    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", 1, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);
    pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);

#ifdef TURRET_DEBUG
    float d;

    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif

    // Target dead, get another is still targeting the same.
    if ((self.enemy.deadflag != DEAD_NO) && (self.enemy == self.owner.enemy))
        self.owner.enemy = world;

    remove (self);
}

void turret_mlrs_dinit()
{
    if (self.netname == "")      self.netname  = "MLRS turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_ZEASE | TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("mlrs_std") == 0)
    {
        remove(self);
        return;
    }

    setmodel(self,"models/turrets/base.md3");
    setmodel(self.tur_head,"models/turrets/mlrs.md3");

    if (!turret_tag_setup(0))
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    // Our fire routine
    self.turret_firefunc  = turret_mlrs_attack;
    self.turret_postthink = turret_mlrs_postthink;

}

/*QUAKED turret_mlrs (0 .5 .8) ?
*/

void spawnfunc_turret_mlrs()
{
    //precache_model ( "models/turrets/rocket.md3");
    //precache_model ("models/turrets/mlrs.md3");
    //precache_model ("models/turrets/base.md3");

    self.think = turret_mlrs_dinit;
    self.nextthink = time + 0.5;
}


