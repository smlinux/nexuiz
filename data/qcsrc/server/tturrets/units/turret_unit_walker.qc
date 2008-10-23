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

//.float e_time;
//.vector v_home;
//.vector movepoint;
//.entity wkr_waypoint;
.entity wkr_props;
.entity wkr_spawn;

//.entity next;
//.entity prev;
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

void checkpoint_think()
{
    if(self.goalcurrent != world)
        te_lightning1(self,self.origin,self.goalcurrent.origin);


    self.nextthink = time + 0.5;
}

void turret_checkpoint_dinit()
{
    entity e;


    if(self.target != "")
    {
        e = find(world,targetname,self.target);
        if(!e)
        {
            bprint("turret_checkpoint without valid target! (",vtos(self.origin),")\n");
            remove(self);
            return;
        }

        // TODO:: ADD WORLD-INTERACTIVE PATH SUBDEVISION IF PATH NOT CLEAR
        self.goalcurrent = e;
    }

    /*
    if(self.goalcurrent == world)
    {
        bprint("turret_checkpoint without valid target (",vtos(self.origin),")\n");
        remove(self);
        return;
    }
    */

    //self.think = checkpoint_think;
    //self.nextthink = 1;

}

/**
.wait
**/
void spawnfunc_walker_checkpoint()
{
    if(!self.wait)
        self.wait = 5;

    self.think = turret_checkpoint_dinit;
    self.nextthink = time + 0.25;
}



float walker_firecheck()
{
    if (!turret_stdproc_firecheck()) return 0;
    //if(self.tur_cannon.frame != 0) return 0;

    //if(self.walking  == 1) self.walking = 2;
    //if(self.walking != 0)
    //    return 0;

    return 1;
}

void walker_meele_dmg()
{
    vector where;
    entity e;

    makevectors(self.angles);
    where = self.origin + v_forward * 128;

    e = findradius(where,80);
    while(e)
    {
        if(turret_validate_target(self,e,self.target_validate_flags))
            if(e != self)
                Damage(e,self,self,cvar("g_turrets_unit_walker_std_meele_dmg "),DEATH_TURRET,'0 0 0', v_forward * cvar("g_turrets_unit_walker_std_meele_force") );

        e = e.chain;
    }
}

void walker_animate()
{

    if(self.tur_head.frame != 0)
        self.tur_head.frame = self.tur_head.frame +1;

    if(self.tur_head.frame > 12)
        self.tur_head.frame = 0;


    switch(self.animflag)
    {
        case ANIM_NO:
            //if(self.frame != 0)
            //    self.frame = 0;
        break;

        case ANIM_WALK:
            self.frame = self.frame + 1;
            if(self.frame > 25)
                self.frame = 5;
        break;

        case ANIM_RUN:
            self.frame = self.frame + 2;
            if(self.frame > 25)
                self.frame = 5;
        break;

        case ANIM_STRAFE_L:
            if(self.frame < 35) self.frame = 35;
            self.frame = self.frame + 1;
            if(self.frame > 55) self.frame = 35;
        break;

        case ANIM_STRAFE_R:
            if(self.frame < 65) self.frame = 65;
            self.frame = self.frame + 1;
            if(self.frame > 85) self.frame = 65;
        break;

        case ANIM_JUMP:
            if(self.frame < 95) self.frame = 95;
            if(self.frame > 100)
            self.frame = self.frame + 1;

        break;

        case ANIM_LAND:
            if(self.frame < 100) self.frame = 100;
            self.frame = self.frame + 1;
            if(self.frame > 107)
                self.animflag = ANIM_NO;
        break;

        case ANIM_PAIN:
            if(self.frame < 90) self.frame = 90;
            self.frame = self.frame + 1;
            if(self.frame > 95)
                self.animflag = ANIM_NO;
        break;

        case ANIM_MEELE:
            if(self.frame < 123) self.frame = 123;
            self.frame = self.frame + 1;

            if(self.frame == 133)
                walker_meele_dmg();

            if(self.frame > 140)
                self.animflag = ANIM_NO;

    }
}





void walker_rocket_explode()
{
    vector org2;

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", 1, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, 78);
    WriteCoord (MSG_BROADCAST, org2_x);
    WriteCoord (MSG_BROADCAST, org2_y);
    WriteCoord (MSG_BROADCAST, org2_z);

    self.event_damage = SUB_Null;

    RadiusDamage (self, self.owner, cvar("g_turrets_unit_walker_std_rocket_dmg"), 0, cvar("g_turrets_unit_walker_std_rocket_radius"), world, cvar("g_turrets_unit_walker_std_rocket_force"), DEATH_TURRET, world);

    remove (self);
}

void walker_rocket_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.health = self.health - damage;
    self.velocity = self.velocity + vforce;
    if (self.health <= 0) walker_rocket_explode();
}


/*
g_turrets_unit_walker_std_rocket_refire
g_turrets_unit_walker_std_rocket_dmg
g_turrets_unit_walker_std_rocket_radius
g_turrets_unit_walker_std_rocket_force
g_turrets_unit_walker_std_rocket_tunrate
g_turrets_unit_walker_std_rocket_speed
g_turrets_unit_walker_std_rocket_speed_add
*/

void walker_rocket_loop();
void walker_rocket_think()
{
    vector olddir,newdir;
    float edist;
    float itime;
    float m_speed;

    self.nextthink          = time + 0.1;

    olddir = normalize(self.velocity);
    edist = vlen(self.enemy.origin - self.origin);

    // Simulate crudely guidance
    if(self.cnt < time)
    {
        if(edist < 1000)
            self.tur_shotorg = randomvec() * min(edist,64);
        else
            self.tur_shotorg = randomvec() * min(edist,256);
        self.cnt = time + 0.5;
    }
    if(edist < 256)
        self.tur_shotorg = '0 0 0';


    if (self.tur_health < time)
    {
        self.think = walker_rocket_explode;
        self.nextthink = time;
        return;
    }

    if((random() < 0.01) && (self.shot_dmg != 1337))
    {
        walker_rocket_loop();
        return;
    }

    olddir = normalize(self.velocity);

    // Accelerate
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
        // Predict enemy position
        itime = max(edist / m_speed,1);
        newdir = normalize((self.enemy.origin + self.tur_shotorg) - self.origin);
    }
    else
    {
        //pre_pos = self.origin + olddir;
        newdir  = olddir;
    }

    // Turn
    newdir = normalize(olddir + newdir * cvar("g_turrets_unit_walker_std_rocket_tunrate"));

    self.velocity = newdir * m_speed;

    // Turn model
    self.angles = vectoangles(self.velocity);

    if (time+itime < time+0.1)
    {
        self.think = turret_hellion_missile_explode;
        self.nextthink = time + itime;
    }
}

void walker_rocket_loop3()
{
    self.nextthink = time + 0.1;
    if(vlen(self.origin - self.tur_shotorg) < 128 )
    {
        self.think = walker_rocket_think;
        return;
    }

    vector newdir;
    vector olddir;
    float m_speed;

    m_speed = vlen(self.velocity) + cvar("g_turrets_unit_walker_std_rocket_speed_add");

    olddir = normalize(self.velocity);


    newdir = normalize(self.tur_shotorg  - self.origin);

    newdir = normalize(olddir + newdir * cvar("g_turrets_unit_walker_std_rocket_tunrate"));


    self.velocity = newdir * m_speed;
    self.angles = vectoangles(self.velocity);
}

void walker_rocket_loop2()
{
    self.nextthink = time + 0;

    if(vlen(self.origin - self.tur_shotorg) < 128 )
    {
        self.tur_shotorg = self.origin - '0 0 200';
        self.think = walker_rocket_loop3;
        return;
    }

    vector newdir;
    vector olddir;
    float m_speed;

    m_speed = vlen(self.velocity) + cvar("g_turrets_unit_walker_std_rocket_speed_add");

    olddir = normalize(self.velocity);

    newdir = normalize(self.tur_shotorg  - self.origin);

    newdir = normalize(olddir + newdir * cvar("g_turrets_unit_walker_std_rocket_tunrate"));

    self.velocity = newdir * m_speed;

    self.angles = vectoangles(self.velocity);

}

void walker_rocket_loop()
{

    self.nextthink= time + 0;

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

    rocket = spawn ();
    setorigin(rocket, org);

    sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", 1, ATTN_NORM);
    sound (rocket, CHAN_PROJECTILE, "weapons/rocket_fly.wav", 0.4, ATTN_NORM);
    setmodel (rocket, "models/turrets/rocket.md3"); // precision set below
    setsize (rocket, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

    rocket.classname          = "walker_rocket";
    rocket.owner              = self;
    rocket.bot_dodge          = TRUE;
    rocket.bot_dodgerating    = 50;
    rocket.takedamage         = DAMAGE_YES;

    rocket.damageforcescale   = 2;
    rocket.health             = 10;
    rocket.tur_shotorg        = randomvec() * 512;
    rocket.cnt                = time + 1;
    rocket.enemy              = self.enemy;

    if(random() < 0.01)
        rocket.think          = walker_rocket_loop;
    else
        rocket.think          = walker_rocket_think;

    rocket.nextthink          = time + 0.2;
    rocket.solid              = SOLID_BBOX;
    rocket.movetype           = MOVETYPE_FLYMISSILE;
    rocket.effects            = EF_LOWPRECISION;
    rocket.velocity           = ((v_forward + v_up * 0.5) +(randomvec() * 0.15))* cvar("g_turrets_unit_walker_std_rocket_speed");
    rocket.angles             = vectoangles(rocket.velocity);
    rocket.touch              = walker_rocket_explode;
    rocket.flags              = FL_PROJECTILE;
    rocket.solid              = SOLID_BBOX;
    rocket.tur_health         = time + 9;

    te_explosion (rocket.origin);

}

#define s_turn 10
#define s_walk 100
#define s_run 300
#define s_accel1 8
#define s_accel2 16
#define s_decel 8

void rv_think()
{
    float f;
    vector org;

    self.cnt = self.cnt -1;
    if(self.cnt < 0)
    {
        remove(self);
        return;
    }

    if(self.cnt> 1)
        f = gettagindex(self.owner,"tag_rocket01");
    else
        f = gettagindex(self.owner,"tag_rocket02");

    org = self.owner.origin + gettaginfo(self.owner,f);


    self.nextthink = time + 0.2;

    self = self.owner;
    walker_fire_rocket(org);
}

void walker_postthink()
{
    vector wish_angle;
    vector real_angle;
    float turn_limit;



    if(self.flags & FL_ONGROUND)
    {
        self.animflag = ANIM_NO;
    }

    if(self.enemy)
    {
        if(self.tur_head.attack_finished_single < time)
        {
            entity rv;
            rv = spawn();
            rv.think = rv_think;
            rv.nextthink = time;
            rv.cnt = 4;
            rv.owner = self;

            self.tur_head.attack_finished_single = time + cvar("g_turrets_unit_walker_std_rocket_refire");
        }

    }

    if(self.goalcurrent)
    {
        //if(self.enemy && (self.tur_dist_enemy < self.target_range_fire))
        //   self.animflag = ANIM_TURN;
        //else
        //{
            if(vlen(self.origin  - self.goalcurrent.origin) < 32)
                if(self.goalcurrent.goalcurrent == world)
                    self.goalcurrent = world; // Path endpoint reached, go roaming.
                else
                    self.goalcurrent = self.goalcurrent.goalcurrent;

            self.animflag = ANIM_WALK;
        //}


    }
    else // Roaming mode
    {

        if(self.enemy)
        {
            wish_angle = angleofs(self,self.enemy); //normalize(self.origin-self.enemy.origin);

            if(self.tur_dist_enemy < cvar("g_turrets_unit_walker_std_meele_range"))
            {

                if(fabs(wish_angle_y) < 15)
                    self.animflag = ANIM_MEELE;
            }
            else
            {
                if(fabs(wish_angle_y) < 15)
                    self.animflag = ANIM_RUN;
                else if(fabs(wish_angle_y) < 30)
                    self.animflag = ANIM_WALK;
                else
                    self.animflag = ANIM_TURN;

                /*
                if(self.tur_dist_enemy > self.target_range_fire)
                    self.animflag = ANIM_RUN;
                else if(vlen(self.origin - self.enemy.origin) > self.target_range_min)
                    self.animflag = ANIM_WALK;
                else
                    self.animflag = ANIM_TURN;
                */
            }

        }
        else
            self.animflag = ANIM_NO;
    }


    float s_speed;

    s_speed = vlen(self.velocity);

    // Turn on the spot
    if (self.animflag == ANIM_TURN) {
        if(self.enemy)
            wish_angle = normalize(self.enemy.origin - self.origin);
        else
            wish_angle = normalize(self.goalcurrent.origin - self.origin);        wish_angle = vectoangles(wish_angle);                  // And make a angle

        real_angle = wish_angle - self.angles;

        if (real_angle_x < 0) real_angle_x += 360;
        if (real_angle_x > 180) real_angle_x -= 360;

        if (real_angle_y < 0) real_angle_y += 360;
        if (real_angle_y > 180) real_angle_y -= 360;

        turn_limit = cvar("g_turrets_unit_walker_turn_turnrate");
        // Convert from dgr/sec to dgr/tic
        turn_limit  = turn_limit / (1 / self.ticrate);

        //real_angle_x = bound((-1 * turn_limit),real_angle_x, turn_limit);
        real_angle_y = bound((-1 * turn_limit),real_angle_y, turn_limit);

        self.angles_y = self.angles_y + real_angle_y;

        if(self.enemy)
            v_forward = normalize(self.enemy.origin - self.origin);
        else
            v_forward = normalize(self.goalcurrent.origin - self.origin);

        if(s_speed > s_turn)
            self.velocity = (v_forward * max((s_speed - s_decel),s_turn));
        if(s_speed < s_turn)
            self.velocity = (v_forward * min((s_speed + s_accel1),s_turn));
    }
    else if (self.animflag == ANIM_WALK) // Gg walking
    {
        if(self.goalcurrent)
            wish_angle = normalize(self.goalcurrent.origin - self.origin);
        else
            if(self.enemy)
                wish_angle = normalize(self.enemy.origin - self.origin);
            else
                wish_angle = self.angles;


        wish_angle = vectoangles(wish_angle);                  // And make a angle
        real_angle = wish_angle - self.angles;

        if (real_angle_x < 0) real_angle_x += 360;
        if (real_angle_x > 180) real_angle_x -= 360;

        if (real_angle_y < 0) real_angle_y += 360;
        if (real_angle_y > 180) real_angle_y -= 360;

        turn_limit = cvar("g_turrets_unit_walker_walk_turnrate");
        // Convert from dgr/sec to dgr/tic
        turn_limit  = turn_limit / (1 / self.ticrate);

        //real_angle_x = bound((-1 * turn_limit),real_angle_x, turn_limit);
        real_angle_y = bound((-1 * turn_limit),real_angle_y, turn_limit);

        self.angles_y = self.angles_y + real_angle_y;


        if(self.goalcurrent)
            v_forward = normalize(self.goalcurrent.origin - self.origin);
        else
            if(self.enemy)
                v_forward = normalize(self.enemy.origin - self.origin);

        //self.velocity = v_forward * s_walk;

        if(self.flags & FL_ONGROUND)
        {
            if(s_speed > s_walk)
                self.velocity = (v_forward * max((s_speed - s_decel),s_walk));
            if(s_speed <= s_walk)
                self.velocity = (v_forward * min((s_speed + s_accel1),s_walk));
        }


    }
    else if (self.animflag == ANIM_RUN) // Move fast, turn slow
    {
        if(self.goalcurrent)
            wish_angle = normalize(self.goalcurrent.origin - self.origin);
        else
            if(self.enemy)
                wish_angle = normalize(self.enemy.origin - self.origin);
            else
                wish_angle = self.angles;

        wish_angle = vectoangles(wish_angle);                  // And make a angle
        real_angle = wish_angle - self.angles;

        if (real_angle_x < 0) real_angle_x += 360;
        if (real_angle_x > 180) real_angle_x -= 360;

        if (real_angle_y < 0) real_angle_y += 360;
        if (real_angle_y > 180) real_angle_y -= 360;

        turn_limit = cvar("g_turrets_unit_walker_run_turnrate");
        // Convert from dgr/sec to dgr/tic
        turn_limit  = turn_limit / (1 / self.ticrate);

        //real_angle_x = bound((-1 * turn_limit),real_angle_x, turn_limit);
        real_angle_y = bound((-1 * turn_limit),real_angle_y, turn_limit);

        self.angles_y = self.angles_y + real_angle_y;


        if(self.enemy)
            v_forward = normalize(self.enemy.origin - self.origin);
        else
            v_forward = normalize(self.goalcurrent.origin - self.origin);

        if(self.flags & FL_ONGROUND)
        {
            if(s_speed > s_run)
                self.velocity = (v_forward * max((s_speed - s_decel),s_run));
            if(s_speed <= s_run)
                self.velocity = (v_forward * min((s_speed + s_accel2),s_run));
        }
    } else {

        if(self.flags & FL_ONGROUND)
        {
            makevectors(self.angles);
            if(s_speed > 0)
                self.velocity = min(s_speed - s_decel,0) * v_forward;
        }
    }



    walker_animate();


}

void walker_attack()
{
    entity flash;

    //turret_do_updates(self);

    self.tur_head.frame = self.tur_head.frame + 1;

    sound (self, CHAN_WEAPON, "weapons/uzi_fire.wav", 1, ATTN_NORM);


    fireBullet (self.tur_shotorg_updated, self.tur_shotdir_updated,self.shot_spread, self.shot_dmg, self.shot_force, DEATH_TURRET, FALSE);

    te_smallflash(self.tur_shotorg_updated);

    if(!(self.uzi_bulletcounter & 3))
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
    self.origin = self.wkr_spawn.origin;
    self.wkr_props.solid = SOLID_BBOX;
    self.wkr_props.alpha = 1;

    self.angles = self.wkr_spawn.angles;
    vtmp = self.origin;
    vtmp_z +=self.wkr_spawn.origin_z + self.wkr_spawn.maxs_z;
    setorigin(self,vtmp);

}
void walker_diehook()
{
    self.wkr_props.solid = SOLID_NOT;
    self.wkr_props.alpha = -1;
}

//.string target_start;
void turret_walker_dinit()
{
    entity e;

    if (self.netname == "")      self.netname     = "Walker Turret";

    if(self.target != "")
    {
        e = find(world,targetname,self.target);
        if(!e)
        {
            bprint("Warning! initital waypoint for Walker does NOT exsist!\n");
            self.target = "";

            //remove(self);
            //return;
        }
        self.goalcurrent = e;
    }




    self.wkr_props = spawn();
    self.wkr_spawn = spawn();

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_HITSCAN | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MOVE | TFL_TURRCAPS_ROAM | TFL_TURRCAPS_LINKED;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_ZEASE;

    self.turret_respawnhook = walker_respawnhook;
    self.turret_diehook = walker_diehook;

    self.ticrate = 0.05;
    if (turret_stdproc_init("walker_std") == 0)
    {
        remove(self);
        return;
    }
    // self.scale = 1.5;
    //setsize(self,'38 38 55','-38 -38 1');

    self.target_select_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;
    self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_LOS;

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

    traceline(self.wkr_spawn.origin + '0 0 10', self.wkr_spawn.origin - '0 0 10000', MOVE_NOMONSTERS, self);
    setorigin(self.wkr_spawn,trace_endpos + '0 0 4');

    setmodel(self,"models/turrets/walker_body.md3");
    setmodel(self.tur_head,"models/turrets/walker_head_minigun.md3");

    setattachment(self.tur_head,self,"tag_head");
    setattachment(self.wkr_props,self,"tag_head");

    vector v;
    float f;
    f = gettagindex(self.tur_head,"tag_fire");
    v = gettaginfo(self.tur_head,f);
    v_y = v_y * -1;


    //setsize(self,self.maxs,self.mins);


    self.tur_shotorg = v;
    self.tur_aimorg  = v;

    self.idle_aim = '0 0 0';

//    self.v_home = self.origin;

    self.turret_firecheckfunc   = walker_firecheck;

    // Our fire routine
    self.turret_firefunc  = walker_attack;

    self.turret_postthink = walker_postthink;

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
