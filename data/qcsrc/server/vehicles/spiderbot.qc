#define MODEL_SPIDERBOT_FORWARD_START 1
#define MODEL_SPIDERBOT_FORWARD_END 31
#define MODEL_SPIDERBOT_FORWARD_LENGTH 31

#define MODEL_SPIDERBOT_BACKWARDS_START 32
#define MODEL_SPIDERBOT_BACKWARDS_END 62
#define MODEL_SPIDERBOT_BACKWARDS_LENGTH 31

#define MODEL_SPIDERBOT_LEFT_START 63
#define MODEL_SPIDERBOT_LEFT_END 93
#define MODEL_SPIDERBOT_LEFT_LENGTH 31

#define MODEL_SPIDERBOT_RIGHT_START 94
#define MODEL_SPIDERBOT_RIGHT_END 124
#define MODEL_SPIDERBOT_RIGHT_LENGTH 31

#define MODEL_SPIDERBOT_JUMP_START 125
#define MODEL_SPIDERBOT_JUMP_END 155
#define MODEL_SPIDERBOT_JUMP_LENGTH 31

#define spiderbot_MIN '-75 -75 5'
#define spiderbot_MAX '75 75 105'

/*
.void() anim_now;
.void() anim_next;

void spider_anim_idle()
{
    movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));
    if(self.anim_next != self.anim_now)
        self.anim_now = self.anim_next;
}

void spider_anim_forward()
{
    movelib_move_simple(normalize(v_forward),cvar("g_vehicle_spiderbot_speed_walk"),cvar("g_vehicle_spiderbot_movement_inertia"));

    if((self.frame < MODEL_SPIDERBOT_FORWARD_START) || (self.frame > MODEL_SPIDERBOT_FORWARD_END))
        self.frame = MODEL_SPIDERBOT_FORWARD_START;
    else
        self.frame += 0.8;

    if(self.frame > MODEL_SPIDERBOT_FORWARD_END)
        self.anim_now = self.anim_next;
}

void spider_anim_backward()
{
    movelib_move_simple(normalize(v_forward * -1),cvar("g_vehicle_spiderbot_speed_walk"),cvar("g_vehicle_spiderbot_movement_inertia"));

    if(self.frame < MODEL_SPIDERBOT_BACKWARDS_START)
        self.frame = MODEL_SPIDERBOT_BACKWARDS_START;
    else
        self.frame += 0.8;

    if(self.frame > MODEL_SPIDERBOT_BACKWARDS_END)
        self.anim_now = self.anim_next;
}

void spider_anim_strafel()
{
    movelib_move_simple(normalize(v_right * -1),cvar("g_vehicle_spiderbot_speed_strafe"),cvar("g_vehicle_spiderbot_movement_inertia"));

    if(self.frame < MODEL_SPIDERBOT_LEFT_START)
        self.frame = MODEL_SPIDERBOT_LEFT_START;
    else
        self.frame += 0.8;

    if(self.frame > MODEL_SPIDERBOT_LEFT_END)
        self.anim_now = self.anim_next;
}

void spider_anim_strafer()
{
    movelib_move_simple(normalize(v_right),cvar("g_vehicle_spiderbot_speed_strafe"),cvar("g_vehicle_spiderbot_movement_inertia"));

    if(self.frame < MODEL_SPIDERBOT_RIGHT_START)
        self.frame = MODEL_SPIDERBOT_RIGHT_START;
    else
        self.frame += 0.8;

    if(self.frame > MODEL_SPIDERBOT_RIGHT_END)
        self.anim_now = self.anim_next;
}

void spider_anim_jump()
{
    //movelib_move_simple(normalize(v_forward),cvar("g_vehicle_spiderbot_speed_walk"),cvar("g_vehicle_spiderbot_movement_inertia"));

    if(self.frame < MODEL_SPIDERBOT_JUMP_START)
        self.frame = MODEL_SPIDERBOT_JUMP_START;
    else
        self.frame += 1;

    if(self.frame <= 8)
        movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));

    if(self.frame == 9)
        self.velocity = v_forward * 400 + v_up * 400;

    if(self.frame >= 19)
        movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));

    if(self.frame > MODEL_SPIDERBOT_JUMP_END)
        self.anim_now = self.anim_next;
}

void anim_do()
{
    if not (self.anim_now)
        self.anim_now = self.anim_next;

    self.anim_now();
}

*/

void anim_do()
{
    self.frame = self.frame + 0.8;
    if ((self.frame < self.anim_start) || (self.frame > self.anim_end))
        if(self.anim_start == 0)
        {
            self.frame = 0;
            self.anim_end = 0;
        }
        else
            self.frame = self.anim_start;
}

void spiderbot_exit(float eject);
void spiderbot_enter();

void spiderbot_rocket_explode()
{
    vector org2;

    if(self.event_damage != SUB_Null)
    {
        self.event_damage = SUB_Null;
        self.think = spiderbot_rocket_explode;
        self.nextthink = time;
        return;
    }

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);
    pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
    w_deathtypestring = "dident escape the rocket barrage";

    if(!self.owner)
        self.owner = self.realowner;

    RadiusDamage (self, self.owner,
     cvar("g_vehicle_spiderbot_rocket_damage"),
     cvar("g_vehicle_spiderbot_rocket_edgedamage"),
     cvar("g_vehicle_spiderbot_rocket_radius"), world,
     cvar("g_vehicle_spiderbot_rocket_force"), DEATH_TURRET, world);

    remove (self);
}

void spiderbot_rocket_touch()
{
    if(self.owner)
    {
        if(other == self.owner.vehicle)
            return;

        if(other == self.owner.vehicle.tur_head)
            return;
    }

    PROJECTILE_TOUCH;
    spiderbot_rocket_explode();
}

void spiderbot_rocket_think()
{
    vector newdir,olddir;

    self.nextthink  = time;
    if not(self.owner)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    self.solid      = SOLID_BBOX;
    self.touch      = spiderbot_rocket_touch;
    olddir = normalize(self.velocity);
    newdir = normalize(self.owner.cursor_trace_endpos - self.origin);
    newdir += randomvec() * cvar("g_vehicle_spiderbot_rocket_noise");
    self.velocity = normalize(olddir + newdir * cvar("g_vehicle_spiderbot_rocket_turnrate")) * cvar("g_vehicle_spiderbot_rocket_speed");

    UpdateCSQCProjectile(self);
}

void spiderbot_rocket_do()
{
    entity missile;

    if(self.gun2.cnt > time)
        return;

    if(self.tur_head.frame > 7)
        self.tur_head.frame = 0;

    if not (self.owner.BUTTON_ATCK2)
        return;

    self.tur_head.frame += 1;
    if(self.tur_head.frame > 7)
        self.attack_finished_single = cvar("g_vehicle_spiderbot_rocket_reload");
    else
        self.attack_finished_single = cvar("g_vehicle_spiderbot_rocket_refire");

    self.gun2.cnt = time + self.attack_finished_single;

    sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", VOL_BASE, ATTN_NORM);
    missile                    = spawn ();
    setsize (missile, '-3 -1 -1', '3 1 1'); // give it some size so it can be shot
    setorigin(missile,gettaginfo(self.tur_head,gettagindex(self.tur_head,"tag_fire")));
    te_explosion (missile.origin);

    missile.classname       = "spiderbot_rocket";
    missile.owner           = self.owner;
    missile.bot_dodge       = TRUE;
    missile.bot_dodgerating = 75;
    missile.nextthink       = time;// + 0.2;
    missile.movetype        = MOVETYPE_FLYMISSILE;
    missile.velocity        = normalize(v_forward + (v_up * 0.5) + randomvec() * 0.25) * cvar("g_vehicle_spiderbot_rocket_speed");
    missile.angles          = vectoangles(missile.velocity);
    missile.think           = spiderbot_rocket_think;
    missile.flags           = FL_PROJECTILE;
    missile.solid           = SOLID_NOT;

	CSQCProjectile(missile, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound
}

void spiderbot_minigun_fire_Flash_Go() {
	if (self.frame > 10){
		self.alpha = -1;
		setmodel(self,"");
		return;
	}

	self.frame = self.frame + 2;
	self.alpha = self.alpha - 0.2;
	self.nextthink = time + 0.02;
}

void spiderbot_minigun_fire(entity gun,float trail)
{

    entity flash;
    vector v;
    v = gettaginfo(gun,gettagindex(gun,"barrels"));
    v_forward = normalize(v_forward);

    sound (gun, CHAN_WEAPON, "weapons/uzi_fire.wav", VOL_BASE, ATTN_NORM);

    fireBullet (v, v_forward, cvar("g_vehicle_spiderbot_minigun_spread"), cvar("g_vehicle_spiderbot_minigun_damage"),
        cvar("g_vehicle_spiderbot_minigun_spread"), DEATH_TURRET, 0);

    if not (gun.enemy)
    {
        gun.enemy = spawn();
        setattachment(gun.enemy , gun, "barrels");
        setorigin(gun.enemy ,gun.enemy.origin + '48 0 0');
    }

    flash = gun.enemy; //spawn();
    setmodel(flash, "models/uziflash.md3"); // precision set below
    flash.think = spiderbot_minigun_fire_Flash_Go;
    flash.nextthink = time + 0.02;
    flash.frame = 2;
    flash.angles_z = flash.v_angle_z + random() * 180;
    flash.alpha = 1;
    flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    if(trail)
        trailparticles(self, particleeffectnum("EF_MGTURRETTRAIL"), v, trace_endpos);
}

void spiderbot_miniguns_do()
{
    if ((self.owner.BUTTON_ATCK) && (self.owner.vehicle_heat < 1) && (self.tur_head.attack_finished_single < time))
    {

        self.gun1.angles_z += 36;
        self.gun2.angles_z -= 36;
        if(self.gun1.angles_z >= 360)
        {
            self.gun1.angles_z = 0;
            self.gun2.angles_z = 360;
        }

        self = self.owner;
        if(self.uzi_bulletcounter == 1)
        {
            spiderbot_minigun_fire(self.vehicle.gun1,0);
            spiderbot_minigun_fire(self.vehicle.gun2,1);
            self.uzi_bulletcounter = 0;
        }
        else
        {
            spiderbot_minigun_fire(self.vehicle.gun1,1);
            spiderbot_minigun_fire(self.vehicle.gun2,0);
            self.uzi_bulletcounter += 1;
        }

        self = self.vehicle;
        self.owner.vehicle_heat += cvar("g_vehicle_spiderbot_minigun_heat");
        if(self.owner.vehicle_heat >= 1)
        {
            self.vehicle_heat = 1;
            self.owner.vehicle_heat = 1;
            self.tur_head.attack_finished_single = (1/(cvar("g_vehicle_spiderbot_minigun_cooldown") * server_fps))+time;
        }
        else
            self.tur_head.attack_finished_single = cvar("g_vehicle_spiderbot_minigun_refire") + time;

        return;
    }
    else
        if(self.vehicle_heat != 0)
        {
            self.vehicle_heat = max(self.vehicle_heat - cvar("g_vehicle_spiderbot_minigun_cooldown"),0);
            if(self.tur_head.attack_finished_single < time)
            {
                self.vehicle_heat = 0;
                self.owner.vehicle_heat = 0;
            }
            else
            {
                if(self.tur_head.uzi_bulletcounter < time)
                {
                    self.tur_head.uzi_bulletcounter = time + 0.2;
                    self.owner.vehicle_heat  = self.vehicle_heat;
                }
                else
                    self.owner.vehicle_heat = 1;
            }
        }
        else
            self.owner.vehicle_heat = max(self.owner.vehicle_heat - cvar("g_vehicle_spiderbot_minigun_cooldown"),0);

}

float spiderbot_pplug()
{
    vector ad;
    entity player,spider;
    float ftmp,ftmp2;

    player = self;
    spider = self.vehicle;

/*
	self.BUTTON_ATCK = 0;
	self.button1 = 0;
	self.BUTTON_JUMP = 0;
	self.BUTTON_ATCK2 = 0;


	self.BUTTON_HOOK = 0;
	self.BUTTON_INFO = 0;
	self.button8 = 0;
	self.BUTTON_CHAT = 0;
	self.BUTTON_USE = 0;
*/

    player.BUTTON_ZOOM = 0;
    player.BUTTON_CROUCH = 0;


    if(player.BUTTON_USE)
    {
        self = spider;
        spiderbot_exit(0);
        self = player;
        return 0;
    }

    player.exteriormodeltoclient = spider.tur_head;

    spider.tur_head.angles_x *= -1;
    spider.angles_x *= -1;
    //player.angles_x *= -1;
    makevectors(spider.angles);

    //ad = player.v_angle - (spider.tur_head.angles + spider.angles);
    ad = player.v_angle -  (spider.tur_head.angles + spider.angles);

    // Rotate head
    ftmp = cvar("g_vehicle_spiderbot_head_turnspeed") / server_fps;
    ftmp2 = ftmp * -1;
    spider.tur_head.angles_y += bound(ftmp2,shortangle_f(ad_y,spider.tur_head.angles_y),ftmp);
    spider.tur_head.angles_y = bound(cvar("g_vehicle_spiderbot_head_turnlimit") * -1,spider.tur_head.angles_y,cvar("g_vehicle_spiderbot_head_turnlimit"));

    // Pitch head
    ftmp = cvar("g_vehicle_spiderbot_head_pitchspeed") / server_fps;
    ftmp2 = ftmp * -1;
    spider.tur_head.angles_x += bound(ftmp2,shortangle_f(ad_x,spider.tur_head.angles_x),ftmp);
    spider.tur_head.angles_x = bound(cvar("g_vehicle_spiderbot_head_pitchlimit_down"),spider.tur_head.angles_x,cvar("g_vehicle_spiderbot_head_pitchlimit_up"));

    spider.tur_head.angles_x *= -1;
    spider.angles_x *= -1;
    //player.angles_x *= -1;

    // Turn Body
    ftmp = cvar("g_vehicle_spiderbot_turnspeed") / server_fps;
    ftmp2 = ftmp * -1;
    ftmp = bound(ftmp2,spider.tur_head.angles_y,ftmp);

    self = spider;
    if(spider.flags & FL_ONGROUND)
    {
        if(player.BUTTON_JUMP)
        {
            player.BUTTON_JUMP = 0;
            spider.anim_start = MODEL_SPIDERBOT_JUMP_START;
            spider.anim_end   = MODEL_SPIDERBOT_JUMP_END;
            spider.velocity   = v_forward * 700 + v_up * 600;
        }
        else
        {
            if(vlen(player.movement) == 0)
            {
                movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));
                spider.anim_start = 0;
                spider.anim_end = 0;
            }
            else
            {
                spider.angles_y = safeangle(spider.angles_y + ftmp);
                spider.tur_head.angles_y -= ftmp;

                if(player.movement_x != 0)
                {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        spider.anim_start = MODEL_SPIDERBOT_FORWARD_START;
                        spider.anim_end   = MODEL_SPIDERBOT_FORWARD_END;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        spider.anim_start = MODEL_SPIDERBOT_BACKWARDS_START;
                        spider.anim_end   = MODEL_SPIDERBOT_BACKWARDS_END;

                    }
                    player.movement_y = 0;
                    movelib_move_simple(normalize(v_forward * player.movement_x),cvar("g_vehicle_spiderbot_speed_walk"),cvar("g_vehicle_spiderbot_movement_inertia"));
                }
                else if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                    {
                        player.movement_y = -1;
                        spider.anim_start = MODEL_SPIDERBOT_LEFT_START;
                        spider.anim_end   = MODEL_SPIDERBOT_LEFT_END;
                    }
                    else if(player.movement_y > 0)
                    {
                        player.movement_y = 1;
                        spider.anim_start = MODEL_SPIDERBOT_RIGHT_START;
                        spider.anim_end   = MODEL_SPIDERBOT_RIGHT_END;
                    }
                    movelib_move_simple(normalize(v_right * player.movement_y),cvar("g_vehicle_spiderbot_speed_strafe"),cvar("g_vehicle_spiderbot_movement_inertia"));
                }

            }
        }
        movelib_groundalign4point(300,100,0.25);
    }

    anim_do();
    spiderbot_miniguns_do();
    spiderbot_rocket_do();
    vehicle_stdproc_regen();

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    player.rockets = spider.tur_head.frame;

    if(spider.gun2.cnt <= time)
        player.rockets_reload = 1;
    else
        player.rockets_reload = 1 - ((spider.gun2.cnt - time) /spider.attack_finished_single);

    self = player;

    setorigin(player,spider.origin + '0 0 64');
    player.velocity = spider.velocity;

    return 1;
}

void spiderbot_think()
{
    if(self.flags & FL_ONGROUND)
    {
        movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));
        //movelib_groundalign4point(300,100);
    }

    self.nextthink = time;
}

void spiderbot_enter()
{
    self.owner = other;

    self.event_damage         = vehicle_stdproc_damage ;
    self.colormap             = self.owner.colormap;
    self.tur_head.colormap    = self.owner.colormap;
    self.vehicle_hudmodel.viewmodelforclient = self.owner;
    self.nextthink = 0;
    self.owner.angles         = self.angles;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.solid          = SOLID_NOT;
    self.owner.movetype       = MOVETYPE_NOCLIP;
    self.owner.alpha          = -1;
    self.owner.PlayerPhysplug = spiderbot_pplug;
    self.owner.vehicle        = self;
    self.owner.event_damage   = SUB_Null;
    self.owner.hud            = HUD_SPIDEBOT;
    self.owner.vehicle_health = (self.vehicle_health / cvar("g_vehicle_spiderbot_health"));
    self.owner.vehicle_shield = (self.vehicle_shield / cvar("g_vehicle_spiderbot_shield"));
    self.team                   = self.owner.team;

    //setorigin(self.owner,self.origin);
    //setattachment(self.owner,self,"");
    //setorigin(self.owner,'0 0 0');

    msg_entity = other;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.vehicle_viewport);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE, self.tur_head.angles_x + self.angles_x);    // tilt
    WriteAngle(MSG_ONE, self.tur_head.angles_y + self.angles_y);    // yaw
    WriteAngle(MSG_ONE, 0);    // roll
    //WriteAngle(MSG_ONE, self.tur_head.angles_z + self.angles_z);    // roll

    //self.owner.view_ofs = '0 0 0';
    //self.tur_head.nodrawtoclient = self.owner;
}

void spiderbot_exit(float eject)
{
    entity e;

    e = findchain(classname,"spiderbot_rocket");
    while(e)
    {
        if(e.owner == self.owner)
        {
            e.realowner = self.owner;
            e.owner = world;
            //e.solid = SOLID_BBOX;
            //e.think = SUB_Null;
            //e.nextthink = -1;
        }
        e = e.chain;
    }

    self.velocity = '0 0 0';

    msg_entity = self.owner;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.owner);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE, 0);    // tilt
    WriteAngle(MSG_ONE, self.angles_y);    // yaw
    WriteAngle(MSG_ONE, 0);    // roll

    //setattachment(self.owner,world,"");
    self.think = spiderbot_think;
    self.nextthink = time;
    self.owner.takedamage     = DAMAGE_AIM;
    self.owner.solid          = SOLID_SLIDEBOX;
    self.owner.movetype       = MOVETYPE_WALK;

    setsize(self.owner,PL_MIN,PL_MAX);

    self.owner.alpha          = 1;
    self.owner.PlayerPhysplug = SUB_Null;
    self.owner.vehicle        = world;
	self.owner.view_ofs       = PL_VIEW_OFS;
	self.owner.hud            = HUD_NORMAL;
	self.owner.event_damage   = PlayerDamage;

	self.colormap            = 1024;
	self.tur_head.colormap   = 1024;
    self.team                = -1;

	self.vehicle_hudmodel.viewmodelforclient = self;
	self.tur_head.nodrawtoclient             = self;

    setattachment(self.owner,world,"");

	makevectors(self.angles);
	if(eject)
	{
	    setorigin(self.owner,self.origin + v_forward * 100 + '0 0 64');
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	}
	else
        setorigin(self.owner,self.origin - v_forward * 200 + '0 0 64');

    self.owner = world;
}

void spiderbot_touch()
{
    if(self.owner)
    {
        if(vlen(self.velocity) == 0)
            return;

        if(other.classname != "player")
            return;

        //todo: add check for velocity here (so we dont cush players runing onto us from behind)

        Damage(other,self,self.owner,cvar("g_vehicle_spiderbot_crush_dmg"),DEATH_TURRET,'0 0 0', normalize(other.origin - self.origin) * cvar("g_vehicle_spiderbot_crush_force") );
        return;
    }

    if(other.classname != "player")
        return;

    if(other.deadflag != DEAD_NO)
        return;

    if(other.vehicle != world)
        return;

    spiderbot_enter();
}

float spiderbot_customizeentityforclient()
{
    if(self.deadflag == DEAD_DEAD)
        return FALSE;

    return TRUE;
}

//void spiderbot_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
void spiderbot_spawn()
{
    self.think = spiderbot_think;
    self.nextthink = time;

    self.vehicle_health = CCVAR("_health");
    self.vehicle_shield = CCVAR("_shield");
    self.event_damage = vehicle_stdproc_damage;
    self.iscreature = TRUE;
    self.movetype   = MOVETYPE_WALK;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;
    self.touch      = spiderbot_touch;
    self.alpha      = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = 1;
    self.tur_head.angles = '0 0 0';
	self.colormap = 1024;
	self.tur_head.colormap = 1024;
	self.deadflag    = DEAD_NO;
    self.bot_attack = TRUE;

    setsize(self,spiderbot_MIN,spiderbot_MAX);
    setorigin(self,self.tur_aimpos);
    pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
}

void spiderbot_blowup()
{
    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    pointparticles(particleeffectnum("rocket_explode"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    RadiusDamage (self, self, 250, 15, 250, world, 250, DEATH_TURRET, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = -1;
    self.nextthink  = time + 10;
    self.think      = spiderbot_spawn;

    setorigin(self,self.tur_aimpos);
}

void spiderbot_die()
{

    self.health = 0;
    self.event_damage = SUB_Null;
    self.iscreature = FALSE;
    self.solid      = SOLID_NOT;
    self.takedamage = DAMAGE_NO;
    self.touch      = SUB_Null;
    self.nextthink  = time + random() * 2;
    self.think      = spiderbot_blowup;
    self.deadflag    = DEAD_DEAD;
	self.vehicle_hudmodel.viewmodelforclient = self;
	self.frame = 0;
	self.tur_head.frame = 0;

}

void vewhicle_spiderbot_dinit()
{

    server_fps = (1 / sys_ticrate);

    addstat(STAT_HUD, AS_INT,  hud);
	addstat(STAT_SPIDERBOT_ROCKETS, AS_INT,   rockets);
	addstat(STAT_SPIDERBOT_RELOAD,  AS_FLOAT, rockets_reload);
	addstat(STAT_SPIDERBOT_HEAT,    AS_FLOAT, vehicle_heat);
	addstat(STAT_SPIDERBOT_HEALTH,  AS_FLOAT, vehicle_health);
	addstat(STAT_SPIDERBOT_SHIELD,  AS_FLOAT, vehicle_shield);

    if (self.netname == "")      self.netname     = "spiderbot";

    self.tur_head = spawn();
    self.gun1 = spawn();
    self.gun2 = spawn();
    self.vehicle_viewport = spawn();
    self.gravity = 2;
    self.vehicle_hudmodel = spawn();
    self.vehicle_flags = VHF_HASSHIELD | VHF_SHIELDREGEN | VHF_HEALTHREGEN;
    self.cvar_basename = "g_vehicle_spiderbot";

    setmodel (self.vehicle_hudmodel, "models/spiderbot/cp.md3");
    setmodel (self.vehicle_viewport, "models/null.md3");
    setmodel(self,"models/spiderbot/spiderbot.dpm");
    setmodel(self.tur_head,"models/spiderbot/spiderbot_top.dpm");
    setmodel(self.gun1,"models/spiderbot/spiderbot_barrels.dpm");
    setmodel(self.gun2,"models/spiderbot/spiderbot_barrels.dpm");

    setattachment(self.tur_head,self,"tag_head");
    setattachment(self.vehicle_hudmodel,self.tur_head,"");
    setattachment(self.vehicle_viewport,self.vehicle_hudmodel,"");
    setattachment(self.gun1,self.tur_head,"tag_hardpoint01");
    setattachment(self.gun2,self.tur_head,"tag_hardpoint02");

    self.tur_head.owner = self;
    self.customizeentityforclient          = spiderbot_customizeentityforclient;

    setorigin(self.vehicle_viewport,'35 0 -14');
    self.tur_aimpos = self.origin;
    spiderbot_spawn();

    self.vehicle_die = spiderbot_die;
    self.vehicle_exit = spiderbot_exit;
}

void spawnfunc_vehicle_spiderbot()
{
    // g_turrets_common_precash();

    precache_model ( "models/spiderbot/cr.md3");
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/spiderbot/cp.md3");
    precache_model ( "models/spiderbot/spiderbot.dpm");
    precache_model ( "models/spiderbot/spiderbot_top.dpm");
    precache_model ( "models/spiderbot/spiderbot_barrels.dpm");

    precache_model ( "models/turrets/rocket.md3");
    precache_sound ( "weapons/rocket_impact.wav" );

    self.team                = -1;
    self.think = vewhicle_spiderbot_dinit;
    self.nextthink = time + 0.5;
}
