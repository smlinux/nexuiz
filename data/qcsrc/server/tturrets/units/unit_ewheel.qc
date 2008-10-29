void turret_ewheel_projectile_explode()
{
    vector org2;

    org2 = findbetterlocation (self.origin, 8);
    pointparticles(particleeffectnum("laser_impact"), org2, trace_plane_normal * 1000, 1);

#ifdef TURRET_DEBUG
    float d;

    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#else
    RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
#endif
    sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", 1, ATTN_NORM);

    remove (self);
}


void ewheel_attack()
{
    entity proj;
    vector v;
    float f,i;

    for(i=0;i<2;i++)
    {
        f = gettagindex(self.tur_head,"tag_fire");
        v = gettaginfo(self.tur_head,f);
        v_y = v_y * -1;
        self.tur_shotorg = v;
        turret_do_updates(self);

        sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", 1, ATTN_NORM);
        pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg_updated, self.tur_shotdir_updated * 1000, 1);

        proj                    = spawn ();
        setorigin(proj, self.tur_shotorg_updated);
        setsize(proj, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');
        setmodel(proj, "models/laser.mdl"); // precision set above
        proj.classname       = "ewheel bolt";
        proj.owner           = self;
        proj.bot_dodge       = FALSE;
        proj.bot_dodgerating = self.shot_dmg;
        proj.think           = turret_ewheel_projectile_explode;
        proj.nextthink       = time + 9;
        proj.solid           = SOLID_BBOX;
        proj.movetype        = MOVETYPE_FLYMISSILE;
        proj.velocity        = (self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
        proj.angles          = vectoangles(proj.velocity);
        proj.touch           = turret_ewheel_projectile_explode;
        proj.effects         = EF_LOWPRECISION |  EF_BRIGHTFIELD;
        proj.enemy           = self.enemy;
        proj.flags           = FL_PROJECTILE | FL_NOTARGET;

        self.tur_head.frame += 1;

        if (self.tur_head.frame > 3)
        self.tur_head.frame = 0;
        }

}

void ewheel_postthink()
{
    vector wish_angle,real_angle;
    float turn_limit;

    if (!self.enemy)
    {
        self.velocity = '0 0 0';
        return;
    }

    wish_angle = normalize(self.enemy.origin - self.origin);
    wish_angle = vectoangles(wish_angle);
    real_angle = wish_angle - self.angles;

    if (real_angle_y < 0) real_angle_y += 360;
    if (real_angle_y > 180) real_angle_y -= 360;

    turn_limit = cvar("g_turrets_unit_ewheel_turnrate");
    // Convert from dgr/sec to dgr/tic
    turn_limit  = turn_limit / (1 / self.ticrate);
    real_angle_y = bound(turn_limit * -1,real_angle_y,turn_limit);
    self.angles_y = self.angles_y + real_angle_y;
    self.angles_z = bound(-10,real_angle_y * -1,10);

    if(self.frame > 40)
        self.frame = 1;

    self.angles_z = 0;
    if(self.tur_dist_enemy > self.target_range_optimal)
    {
        self.angles_z = bound(-15,real_angle_y * -1,15);
        makevectors(self.angles);
        self.velocity = v_forward * 250;
        self.frame += 2;
        return;
    }

    self.velocity = '0 0 0';


}

void ewheel_respawnhook()
{


    setorigin(self,self.pos1);

    //self.angles = self.wkr_spawn.angles;

}

void ewheel_diehook()
{
}

void turret_ewheel_dinit()
{
    entity e;

    if (self.netname == "")      self.netname     = "Ewheel Turret";

    // self.ticrate = 0.05;

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            bprint("Warning! initital waypoint for ewheel does NOT exsist!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
            self.goalcurrent = e;
    }

    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE | TFL_TURRCAPS_ROAM | TFL_TURRCAPS_LINKED;
    self.aim_flags = TFL_AIM_SIMPLE;// TFL_AIM_LEAD | TFL_AIM_ZEASE;

    self.turret_respawnhook = ewheel_respawnhook;
    self.turret_diehook = ewheel_diehook;

    self.ticrate = 0.05;
    if (turret_stdproc_init("ewheel_std") == 0)
    {
        remove(self);
        return;
    }

    self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.damage_flags |= RFL_DMG_DEATH_NOGIBS;

    //self.flags      = FL_CLIENT;
    self.iscreature = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;

    setmodel(self,"models/turrets/ewheel-base.md3");
    setmodel(self.tur_head,"models/turrets/ewheel-gun1.md3");

    setattachment(self.tur_head,self,"tag_head");

    self.pos1 = self.origin;

    vector v;
    float f;
    f = gettagindex(self.tur_head,"tag_fire");
    v = gettaginfo(self.tur_head,f);
    v_y = v_y * -1;

    //setsize(self,WALKER_MIN,WALKER_MAX);
    //setsize(self,'-70 -70 0','70 70 55');

    self.tur_shotorg = v;
    self.tur_aimorg  = v;

    self.tur_aimorg_x = 0;
    self.tur_aimorg_y = 0;
    self.tur_aimorg_z = 25;

    self.idle_aim = '0 0 0';

    // Our fire routine
    self.turret_firefunc  = ewheel_attack;
    self.turret_postthink = ewheel_postthink;
    self.tur_head.frame = 1;
}


void spawnfunc_turret_ewheel()
{
    precache_model ("models/turrets/ewheel-base.md3");
    precache_model ("models/turrets/ewheel-gun1.md3");

    self.think = turret_ewheel_dinit;
    self.nextthink = time + 0.5;
}
