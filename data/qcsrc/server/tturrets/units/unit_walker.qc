//#define rocket_rack tur_head.enemy

#define ANIM_NO 0
#define ANIM_WALK 1
#define ANIM_RUN 1.1
#define ANIM_STRAFE_L 2
#define ANIM_STRAFE_R 3
#define ANIM_TURN 2
#define ANIM_JUMP 4
#define ANIM_LAND 5
#define ANIM_PAIN 6
#define ANIM_MEELE 7

.float animflag;

.entity wkr_props;
.entity wkr_spawn;

#define WALKER_MIN '-70 -70 5'
#define WALKER_MAX '70 70 70'

/*
.entity goalcurrent, goalstack01, goalstack02, goalstack03;
.entity goalstack04, goalstack05, goalstack06, goalstack07;
.entity goalstack08, goalstack09, goalstack10, goalstack11;
.entity goalstack12, goalstack13, goalstack14, goalstack15;
.entity goalstack16, goalstack17, goalstack18, goalstack19;
.entity goalstack20, goalstack21, goalstack22, goalstack23;
.entity goalstack24, goalstack25, goalstack26, goalstack27;
.entity goalstack28, goalstack29, goalstack30, goalstack31;
*/


float walker_firecheck()
{
    return turret_stdproc_firecheck();
}

void walker_meele_do_dmg()
{
    vector where;
    entity e;
    makevectors(self.angles);
    where = self.origin + v_forward * 128;

    e = findradius(where,128);
    while (e)
    {
        if (turret_validate_target(self,e,self.target_validate_flags))
            if (e != self)
                Damage(e,self,self,cvar("g_turrets_unit_walker_std_meele_dmg"),DEATH_TURRET,'0 0 0', v_forward * cvar("g_turrets_unit_walker_std_meele_force") );

        e = e.chain;
    }
}

void walker_animate()
{

    switch (self.animflag)
    {
    case ANIM_NO:
        if(self.frame != 0)
            self.frame = 0;
        break;

    case ANIM_WALK:
        self.frame = self.frame + 1;
        if (self.frame > 25)
            self.frame = 5;
        break;

    case ANIM_RUN:

        self.frame = self.frame + 2;
        if (self.frame > 25)
            self.frame = 5;
        break;

    case ANIM_STRAFE_L:
        if (self.frame < 35) self.frame = 35;
        self.frame = self.frame + 1;
        if (self.frame > 55) self.frame = 35;
        break;

    case ANIM_STRAFE_R:
        if (self.frame < 65) self.frame = 65;
        self.frame = self.frame + 1;
        if (self.frame > 85) self.frame = 65;
        break;

    case ANIM_JUMP:
        if (self.frame < 95) self.frame = 95;
        if (self.frame > 100)
            self.frame = self.frame + 1;

        break;

    case ANIM_LAND:
        if (self.frame < 100) self.frame = 100;
        self.frame = self.frame + 1;
        if (self.frame > 107)
            self.animflag = ANIM_NO;
        break;

    case ANIM_PAIN:
        if (self.frame < 60) self.frame = 90;
        self.frame = self.frame + 1;
        if (self.frame > 95)
            self.animflag = ANIM_NO;
        break;

    case ANIM_MEELE:
        if (self.frame < 123) self.frame = 123;
        self.frame = self.frame + 1;

        if (self.frame == 133)
            walker_meele_do_dmg();

        if (self.frame > 140)
            self.animflag = ANIM_NO;

    }
}


void walker_rocket_explode()
{
    vector org2;

    if(self.event_damage != SUB_Null)
    {
        self.event_damage = SUB_Null;
        self.think = walker_rocket_explode;
        self.nextthink = time;
        return;
    }

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);

    pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);

    RadiusDamage (self, self.owner, cvar("g_turrets_unit_walker_std_rocket_dmg"), 0, cvar("g_turrets_unit_walker_std_rocket_radius"), world, cvar("g_turrets_unit_walker_std_rocket_force"), DEATH_TURRET, world);

    remove (self);
}

void walker_rocket_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.health = self.health - damage;
    self.velocity = self.velocity + vforce;
    if (self.health <= 0)
        walker_rocket_explode();
}

//#define WALKER_ROCKET_MOVE movelib_move(newdir * 275,900,0.1,10)
#define WALKER_ROCKET_MOVE movelib_move_simple(newdir,1000,cvar("g_turrets_unit_walker_std_rocket_tunrate")); UpdateCSQCProjectile(self)
void walker_rocket_loop();
void walker_rocket_think()
{
    vector newdir;
    float edist;
    float itime;
    float m_speed;

    self.nextthink = time;

    edist = vlen(self.enemy.origin - self.origin);

    // Simulate crude guidance
    if (self.cnt < time)
    {
        if (edist < 1000)
            self.tur_shotorg = randomvec() * min(edist,64);
        else
            self.tur_shotorg = randomvec() * min(edist,256);

        self.cnt = time + 0.5;
    }

    if (edist < 256)
        self.tur_shotorg = '0 0 0';


    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        self.nextthink = time;
        return;
    }

    if (self.shot_dmg != 1337)
    if (random() < 0.01)
    {
        walker_rocket_loop();
        return;
    }

    m_speed = vlen(self.velocity) + cvar("g_turrets_unit_walker_std_rocket_speed_add");

    // Enemy dead? just keep on the current heading then.
    if ((self.enemy == world) || (self.enemy.deadflag != DEAD_NO))
    {

        // Make sure we dont return to tracking a respawned player
        self.enemy = world;

        // Turn model
        self.angles = vectoangles(self.velocity);
    }

    if (self.enemy)
    {
        itime = max(edist / m_speed,1);
        newdir = steerlib_pull(self.enemy.origin + self.tur_shotorg);
    }
    else
    {
        newdir  = normalize(self.velocity);
    }

    // Turn model
    self.angles = vectoangles(self.velocity);


    WALKER_ROCKET_MOVE;
    //UpdateCSQCProjectile(self);
}

void walker_rocket_loop3()
{
    vector newdir;
    self.nextthink = time;

    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        return;
    }

    if (vlen(self.origin - self.tur_shotorg) < 128 )
    {
        self.think = walker_rocket_think;
        return;
    }


    newdir = steerlib_pull(self.tur_shotorg);
    WALKER_ROCKET_MOVE;

    self.angles = vectoangles(self.velocity);
}

void walker_rocket_loop2()
{
    vector newdir;

    self.nextthink = time;

    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        return;
    }

    if (vlen(self.origin - self.tur_shotorg) < 128 )
    {
        self.tur_shotorg = self.origin - '0 0 200';
        self.think = walker_rocket_loop3;
        return;
    }

    self.angles = vectoangles(self.velocity);
    newdir = steerlib_pull(self.tur_shotorg);
    WALKER_ROCKET_MOVE;
}

void walker_rocket_loop()
{
    self.nextthink = time;
    self.tur_shotorg = self.origin + '0 0 400';
    self.think = walker_rocket_loop2;
    self.shot_dmg = 1337;
}

void walker_fire_rocket(vector org)
{

    entity rocket;


    //self.angles_x *= -1;
    makevectors(self.angles);
    //self.angles_x *= -1;

    te_explosion (org);

    rocket = spawn ();
    setorigin(rocket, org);

    sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", VOL_BASE, ATTN_NORM);
    setsize (rocket, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

    rocket.classname          = "walker_rocket";
    rocket.owner              = self;

    rocket.bot_dodge          = TRUE;
    rocket.bot_dodgerating    = 50;

    rocket.takedamage         = DAMAGE_YES;

    rocket.damageforcescale   = 2;
    rocket.health             = 25;
    rocket.tur_shotorg        = randomvec() * 512;
    rocket.cnt                = time + 1;
    rocket.enemy              = self.enemy;

    if (random() < 0.01)
        rocket.think          = walker_rocket_loop;
    else
        rocket.think          = walker_rocket_think;

    rocket.event_damage       = walker_rocket_damage;

    rocket.nextthink          = time;// + 0.25;
    rocket.movetype           = MOVETYPE_FLY;
    rocket.velocity           = normalize((v_forward + v_up * 0.25) + (randomvec() * 0.1)) * cvar("g_turrets_unit_walker_std_rocket_speed");
    rocket.angles             = vectoangles(rocket.velocity);
    rocket.touch              = walker_rocket_explode;
    rocket.flags              = FL_PROJECTILE;
    rocket.solid              = SOLID_BBOX;
    rocket.tur_health         = time + 9;

	CSQCProjectile(rocket, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound
}

/*
#define s_turn 10
#define s_walk 100
#define s_run 300
#define s_accel1 8
#define s_accel2 16
#define s_decel 8
*/

void rv_think()
{
    float f;
    vector org;
    entity oldself;

    if(self.owner.deadflag != DEAD_NO)
    {
        remove(self);
        return;
    }

    self.cnt = self.cnt -1;

    if (self.cnt < 0)
    {
        remove(self);
        return;
    }

    if (self.cnt > 1)
        f = gettagindex(self.owner,"tag_rocket01");
    else
        f = gettagindex(self.owner,"tag_rocket02");

    org = self.owner.origin + gettaginfo_relative(self.owner,f);

    self.nextthink = time + 0.2;
    oldself = self;
    self = self.owner;
    walker_fire_rocket(org);
    self = oldself;
}

/*
void acb_run()
{
    //bprint("run\n");
    animation_set(self,5,25,40,AF_ENDCALLBACK,5);
}
void acb_walk()
{
    bprint("walk\n");
    animation_set(self,5,25,20,AF_ENDCALLBACK,5);
}
void acb_meele()
{
    walker_do_meele();
}

void set_acb(void() acb_func)
{
    self.animator_callback = acb_func;
    if(animation_query(self) != AS_RUNNING)
    {
        bprint("Not running\n");
        acb_func();
    }
    else
    {
        if not(self.animator.anim_flags & AF_ENDCALLBACK)
            self.animator.anim_flags = self.animator.anim_flags | AF_ENDCALLBACK;
    }
}
*/

void walker_postthink()
{
    vector wish_angle;
    vector real_angle;
    vector steer;
    float vel;

    //if (self.flags & FL_ONGROUND)
    //if (self.animflag != ANIM_MEELE)
    //    self.animflag = ANIM_NO;

    if (self.tur_head.attack_finished_single < time)
    if (self.enemy)
    {
        entity rv;

        rv = spawn();
        rv.think = rv_think;
        rv.nextthink = time;
        rv.cnt = 4;
        rv.owner = self;

        self.tur_head.attack_finished_single = time + cvar("g_turrets_unit_walker_std_rocket_refire");
    }

    // Do we have a path?
    if (self.pathcurrent)
    {
        //set_acb(acb_walk);
        self.animflag = ANIM_WALK;

        // Are we close enougth to a path node to switch to the next?
        if (vlen(self.origin  - self.pathcurrent.origin) < 64)
            if (self.pathcurrent.path_next == world)
            {
                // Path endpoint reached
                pathlib_deletepath(self.pathcurrent.owner);
                self.pathcurrent = world;

                if(self.pathgoal)
                {
                    if(self.pathgoal.use)
                        self.pathgoal.use();

                    if(self.pathgoal.enemy)
                    {
                        self.pathcurrent = pathlib_makepath(self.pathgoal.origin,self.pathgoal.enemy.origin,PFL_GROUNDSNAP,1500,2,PT_QUICKBOX);
                        self.pathgoal = self.pathgoal.enemy;
                    }
                }
                else
                    self.pathgoal = world;
            }
            else
                self.pathcurrent = self.pathcurrent.path_next;

        steer = steerlib_attract2(self.pathcurrent.origin,0.5,2000,0.95);
        vel = 150;
    }
    else // Roaming mode
    {
        if (self.enemy)
        {
            wish_angle = angleofs(self,self.enemy);
            steer = steerlib_pull(self.enemy.origin);

            if (self.tur_dist_aimpos < cvar("g_turrets_unit_walker_std_meele_range"))
            {
                if (fabs(wish_angle_y) < 15)
                {
                    vel = 0;
                    //set_acb(acb_meele);
                    //walker_do_meele();
                    self.animflag = ANIM_MEELE;
                    return;
                }
            }
            else
            {
                if (fabs(wish_angle_y) < 15)
                {
                    //set_acb(acb_run);
                    self.animflag = ANIM_RUN;
                    vel = 300;
                }
                else if (fabs(wish_angle_y) < 30)
                {
                    //set_acb(acb_walk);
                    self.animflag = ANIM_WALK;
                    vel = 150;
                }
                else
                {
                    //set_acb(acb_walk);
                    self.animflag = ANIM_WALK;
                    vel = 50;
                }
            }
        }
        else
        {
            vel = 0;

            if(self.animflag != ANIM_MEELE)
                self.animflag = ANIM_NO;
        }
    }

    // Align the walker to the ground

    self.angles_x = self.angles_x  * -1;
    makevectors(self.angles);
    self.angles_x = self.angles_x  * -1;

    traceline(self.origin + '0 0 15', self.origin - '0 0 150' ,MOVE_WORLDONLY,self);
    wish_angle = (trace_endpos);
    traceline(self.origin  + v_forward * 10 + '0 0 15', self.origin + v_forward * 10 - '0 0 150' ,MOVE_WORLDONLY,self);
    real_angle = vectoangles(normalize( trace_endpos - wish_angle));

    self.angles_x = real_angle_x;
    self.angles_z = real_angle_z;

    if(vel == 0)
    {
        self.velocity = '0 0 0';
        //animator_remove(self);
    }
    else
    {
        steer  = steer * 0.5  + steerlib_traceavoid(0.3,256);
        float vz;
        vz = self.velocity_z;
        movelib_move_simple(steer * 200,vel,0.5);
        self.velocity_z = vz;

        wish_angle = vectoangles(self.velocity);

        real_angle = wish_angle - self.angles;

        real_angle_y = shortangle_f(real_angle_y,self.angles_y);

        self.angles_y = self.angles_y + bound(-5,real_angle_y,5);
    }
    walker_animate();

    if (self.tur_head.frame != 0)
        self.tur_head.frame = self.tur_head.frame +1;

    if (self.tur_head.frame > 12)
        self.tur_head.frame = 0;


}

void walker_attack()
{
    entity flash;

    //turret_do_updates(self);

    self.tur_head.frame = self.tur_head.frame + 1;

    sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", VOL_BASE, ATTN_NORM);

    fireBallisticBullet (self.tur_shotorg_updated, self.tur_shotdir_updated,self.shot_spread, self.shot_speed, 5, self.shot_dmg, 0, self.shot_force, DEATH_TURRET, 0, 1, cvar("g_balance_uzi_bulletconstant"));
    te_smallflash(self.tur_shotorg_updated);

    if (!(self.uzi_bulletcounter & 3))
    {

        trailparticles(self,particleeffectnum("EF_MGTURRETTRAIL"),self.tur_shotorg_updated,trace_endpos);
        // te_lightning1(self,self.tur_shotorg_updated,trace_endpos);
        flash = spawn();
        setmodel(flash, "models/uziflash.md3"); // precision set below
        setattachment(flash, self.tur_head, "tag_fire");
        flash.scale = 3;
        flash.think = W_Uzi_Flash_Go;
        flash.nextthink = time + 0.02;
        flash.frame = 2;
        flash.angles_z = flash.v_angle_z + random() * 180;
        flash.alpha = 1;
        flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    }

    self.uzi_bulletcounter = self.uzi_bulletcounter + 1;
}


void walker_respawnhook()
{
    vector vtmp;
    entity e;

    //load_unit_settings(self.rocket_rack,"walker_std_rocket",1);

    self.origin = self.wkr_spawn.origin;
    self.wkr_props.solid = SOLID_BBOX;
    self.wkr_props.alpha = 1;

    self.angles = self.wkr_spawn.angles;
    vtmp = self.origin;
    vtmp_z +=self.wkr_spawn.origin_z + self.wkr_spawn.maxs_z;
    setorigin(self,vtmp);

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            bprint("Warning! initital waypoint for Walker does NOT exsist!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
            self.pathcurrent = pathlib_makepath(self.origin,e.origin,PFL_GROUNDSNAP,500,2,PT_QUICKBOX);
            self.pathgoal = e;
        }
    }
}
void walker_diehook()
{
    //animator_remove(self);

    if(self.pathcurrent)
        pathlib_deletepath(self.pathcurrent.owner);

    self.pathcurrent = world;

    self.wkr_props.solid = SOLID_NOT;
    self.wkr_props.alpha = -1;

    if(self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
    {

        remove(self.wkr_props);
        //remove(self.rocket_rack);
        remove(self.wkr_spawn);
    }

}

//.string target_start;
void turret_walker_dinit()
{

    entity e;

    if (self.netname == "")      self.netname     = "Walker Turret";


    self.wkr_props = spawn();
    self.wkr_spawn = spawn();

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE | TFL_TURRCAPS_ROAM | TFL_TURRCAPS_LINKED;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_ZEASE | TFL_AIM_SHOTTIMECOMPENSATE;

    self.turret_respawnhook = walker_respawnhook;
    self.turret_diehook = walker_diehook;

    self.ticrate = 0.05;
    if (turret_stdproc_init("walker_std") == 0)
    {
        remove(self);
        return;
    }
    self.damage_flags |= RFL_DMG_DEATH_NOGIBS;

    self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;// | TFL_TARGETSELECT_LOS;

    //self.flags      = FL_CLIENT;
    self.iscreature = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;

    setmodel(self.wkr_props,"models/turrets/walker_props.md3");
    setmodel(self.wkr_spawn,"models/turrets/walker_spawn.md3");
    setorigin(self.wkr_spawn,self.origin);

    self.wkr_spawn.angles   = self.angles;
    self.wkr_spawn.solid    = SOLID_NOT;


    traceline(self.wkr_spawn.origin + '0 0 16', self.wkr_spawn.origin - '0 0 10000', MOVE_NOMONSTERS, self);
    setorigin(self.wkr_spawn,trace_endpos + '0 0 4');
    setorigin(self,self.wkr_spawn.origin);

    setmodel(self,"models/turrets/walker_body.md3");
    setmodel(self.tur_head,"models/turrets/walker_head_minigun.md3");

    setattachment(self.tur_head,self,"tag_head");
    setattachment(self.wkr_props,self,"tag_head");

    vector v;
    float f;
    f = gettagindex(self.tur_head,"tag_fire");
    v = gettaginfo_relative(self.tur_head,f);
    v_y = v_y * -1;

    setsize(self,WALKER_MIN,WALKER_MAX);
    //setsize(self,'-70 -70 0','70 70 55');

    self.tur_shotorg = v;
    self.tur_aimorg  = v;// + '0 0 10';

    self.idle_aim = '0 0 0';

//    self.v_home = self.origin;

    self.turret_firecheckfunc   = walker_firecheck;

    // Our fire routine
    self.turret_firefunc  = walker_attack;

    self.turret_postthink = walker_postthink;

    if (self.target != "")
    {
        e = find(world,targetname,self.target);
        if (!e)
        {
            dprint("Initital waypoint for walker does NOT exsist, fix your map!\n");
            self.target = "";
        }

        if (e.classname != "turret_checkpoint")
            dprint("Warning: not a turrret path\n");
        else
        {
            self.pathcurrent = pathlib_makepath(self.origin,e.origin,PFL_GROUNDSNAP,500,2,PT_QUICKBOX);
            self.pathgoal = e;
        }
    }

    //self.solid    = SOLID_NOT;

}


void spawnfunc_turret_walker()
{
    precache_model ("models/turrets/walker_head_minigun.md3");
    precache_model ("models/turrets/walker_body.md3");
    precache_model ("models/turrets/walker_props.md3");
    precache_model ("models/turrets/walker_spawn.md3");
    precache_model ( "models/turrets/rocket.md3");

    self.think = turret_walker_dinit;
    self.nextthink = time + 0.5;
}
