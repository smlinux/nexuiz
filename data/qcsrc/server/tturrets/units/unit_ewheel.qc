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
    sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);

    remove (self);
}


void ewheel_attack()
{
    entity proj;
    vector v;
    float f,i;

    for (i=0;i<1;++i)
    {
        f = gettagindex(self.tur_head,"tag_fire");
        v = gettaginfo(self.tur_head,f);
        v_y = v_y * -1;
        self.tur_shotorg = v;
        turret_do_updates(self);

        sound (self, CHAN_WEAPON, "weapons/lasergun_fire.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("laser_muzzleflash"), self.tur_shotorg_updated, self.tur_shotdir_updated * 1000, 1);

        proj                    = spawn ();
        setorigin(proj, self.tur_shotorg_updated);
        //setsize(proj, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');
        //setmodel(proj, "models/laser.mdl"); // precision set above
        proj.classname       = "ewheel bolt";
        proj.owner           = self;
        proj.bot_dodge       = FALSE;
        proj.bot_dodgerating = self.shot_dmg;
        proj.think           = turret_ewheel_projectile_explode;
        proj.nextthink       = time + 9;
        proj.solid           = SOLID_BBOX;
        proj.movetype        = MOVETYPE_FLYMISSILE;
        proj.velocity        = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
        proj.angles          = vectoangles(proj.velocity);
        proj.touch           = turret_ewheel_projectile_explode;
        //proj.effects         = EF_LOWPRECISION |  EF_BRIGHTFIELD;
        proj.enemy           = self.enemy;
        proj.flags           = FL_PROJECTILE | FL_NOTARGET;

        CSQCProjectile(proj, TRUE, PROJECTILE_LASER, TRUE);

        self.tur_head.frame += 2;

        if (self.tur_head.frame > 3)
            self.tur_head.frame = 0;
    }

}

#define EWHEEL_MASS 50
#define EWHEEL_MAXSPEED 800
#define EWHEEL_ACCEL_SLOW 25
#define EWHEEL_ACCEL_FAST 100
#define EWHEEL_BREAK_SLOW 100
#define EWHEEL_BREAK_FAST 250

void ewheel_enemymove()
{
    vector wish_angle,real_angle,steer,avoid;
    float turn_limit,angle_ofs;

    //steer = steerlib_attract2(point,0.5,2000,0.95);
    steer = steerlib_pull(self.enemy.origin);
    avoid = steerlib_traceavoid(0.3,350);

    wish_angle = normalize(avoid * 0.5 + steer);
    wish_angle = vectoangles(wish_angle);
    real_angle = wish_angle - self.angles;

    if (real_angle_x > self.angles_x)
    {
        if (real_angle_x >= 180)
            real_angle_x -= 360;
    }
    else
    {
        if (real_angle_x <= -180)
            real_angle_x += 360;
    }

    if (real_angle_y > self.tur_head.angles_y)
    {
        if (real_angle_y >= 180)
            real_angle_y -= 360;
    }
    else
    {
        if (real_angle_y <= -180)
            real_angle_y += 360;
    }

    turn_limit = cvar("g_turrets_unit_ewheel_turnrate");
    // Convert from dgr / sec to dgr / tic
    turn_limit    = turn_limit / (1 / self.ticrate);
    angle_ofs     = fabs(real_angle_y);
    real_angle_y  = bound(turn_limit * -1,real_angle_y,turn_limit);
    self.angles_y = (self.angles_y + real_angle_y);

    // Simulate banking
    self.angles_z = bound(-45,real_angle_y * -1,45);


    if (self.frame > 40)
        self.frame = 1;

    makevectors(self.angles);

    if (self.tur_dist_aimpos > self.target_range_optimal)
    {
        if ( angle_ofs < 10 )
        {
            self.frame += 2;
            movelib_move(v_forward * EWHEEL_ACCEL_FAST,EWHEEL_MAXSPEED,0,EWHEEL_MASS,0);
        }
        else if (angle_ofs < 16)
        {
            self.frame += 0.5;
            movelib_move(v_forward,EWHEEL_MAXSPEED,0,EWHEEL_MASS,EWHEEL_BREAK_SLOW);
        }
        else
        {
            movelib_move('0 0 0',EWHEEL_MAXSPEED,0,EWHEEL_MASS,EWHEEL_BREAK_FAST);
        }
    }
    else
        movelib_move('0 0 0',EWHEEL_MAXSPEED,0,EWHEEL_MASS,EWHEEL_BREAK_FAST);
}

void ewheel_roammove()
{
    movelib_move(v_forward,EWHEEL_MAXSPEED,0,EWHEEL_MASS,EWHEEL_BREAK_SLOW);
    self.angles_z = 0;

    /*
    vector wish_angle,real_angle,steer,avoid;
    float turn_limit,angle_ofs;
    float dist;

    return;

    dist = vlen(self.origin - self.pos1);

    //steer = steerlib_attract2(point,0.5,2000,0.95);
    steer = steerlib_pull(self.pos1);
    avoid = steerlib_traceavoid(0.3,350);

    wish_angle = normalize(avoid * 0.5 + steer);
    wish_angle = vectoangles(wish_angle);
    real_angle = wish_angle - self.angles;

    real_angle_y = shortangle_f(real_angle_y,self.angles_y);

    turn_limit = cvar("g_turrets_unit_ewheel_turnrate");
    // Convert from dgr/sec to dgr/tic
    turn_limit  = turn_limit / (1 / self.ticrate);
    angle_ofs = fabs(real_angle_y);

    real_angle_y = bound(turn_limit * -1,real_angle_y,turn_limit);
    self.angles_y = (self.angles_y + real_angle_y);

    self.angles_z = bound(-12,real_angle_y * -1,12);

    if(self.frame > 40)
        self.frame = 1;

    makevectors(self.angles);
    float lspeed;
    lspeed = vlen(self.velocity);

    if((dist < 64)||(self.phase < time))
    {
        movelib_move('0 0 0',150,0,50,200);
        self.pos1 = self.origin + v_forward * 256 + randomvec() * 128;
        self.pos1_z = self.origin_z;
        self.phase = time + 5;
    }
    else if(dist < 128)
    {
        self.frame += 1;
        if(lspeed > 100)
            movelib_move(v_forward * 50,150,0,50,50);
        else
            movelib_move(v_forward * 100,150,0,50,0);
    }
    else
    {
        self.frame += 1;
        if(angle_ofs > 10)
            movelib_move(v_forward * 50,150,0,50,50);
        else
            movelib_move(v_forward * 250,150,0,50,0);
    }
    */
}

void ewheel_postthink()
{
    if (self.enemy)
        ewheel_enemymove();
    else
        ewheel_roammove();

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
    self.gravity = 0.01;
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
