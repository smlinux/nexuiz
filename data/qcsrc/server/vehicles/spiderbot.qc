const vector spiderbot_MIN = '-75 -75 0';
const vector spiderbot_MAX  = '75 75 100';

#define spiderbot_spawnpnt wkr_spawn

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
        cvar("g_vehicle_spiderbot_rocket_force"), DEATH_SBROCKET, world);

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

void spiderbot_rocket_guided()
{
    vector newdir,olddir;

    self.nextthink  = time;
    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        spiderbot_rocket_explode();
        return;
    }

    if not (self.owner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    crosshair_trace(self.owner);
    newdir = normalize(trace_endpos - self.origin) + randomvec() * cvar("g_vehicle_spiderbot_rocket_noise");
    self.velocity = normalize(olddir + newdir * cvar("g_vehicle_spiderbot_rocket_turnrate")) * cvar("g_vehicle_spiderbot_rocket_speed");

    UpdateCSQCProjectile(self);
}

void spiderbot_rocket_unguided()
{
    vector newdir,olddir;

    self.nextthink  = time;
    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        spiderbot_rocket_explode();
        return;
    }

    if not (self.owner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    newdir = normalize(self.pos1 - self.origin) + randomvec() * cvar("g_vehicle_spiderbot_rocket_noise");
    self.velocity = normalize(olddir + newdir * cvar("g_vehicle_spiderbot_rocket_turnrate")) * cvar("g_vehicle_spiderbot_rocket_speed");

    UpdateCSQCProjectile(self);
}


void spiderbot_rocket_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    self.health -= damage;
    self.velocity += force;
    if(self.health < 1)
        spiderbot_rocket_explode();
}

void spiderbot_guide_release()
{
    entity rkt;
    rkt = findchainentity(owner,self.owner);
    if not (rkt)
        return;

    crosshair_trace(self.owner);

    while(rkt)
    {
        if(rkt.think == spiderbot_rocket_guided)
        {
            rkt.pos1 = trace_endpos;
            rkt.think = spiderbot_rocket_unguided;
        }

        rkt = rkt.chain;
    }
}

void spiderbot_rocket_do()
{
    entity rocket;

    if (self.owner.BUTTON_ATCK2)
    {
        if (self.wait == 1)
        if (self.tur_head.frame == 9 || self.tur_head.frame == 1)
        {
            if(self.gun2.cnt < time && self.tur_head.frame == 9)
                self.tur_head.frame = 1;

            return;
        }

        self.wait = 1;
    }
    else
    {
        if(self.wait)
            spiderbot_guide_release();

        self.wait = 0;
    }

    if(self.gun2.cnt > time)
        return;

    if (self.tur_head.frame >= 9)
        self.tur_head.frame = 1;

    if not (self.owner.BUTTON_ATCK2)
        return;

    sound (self, CHAN_WEAPON, "weapons/rocket_fire.wav", VOL_BASE, ATTN_NORM);
    rocket                    = spawn ();
    setsize (rocket, '-1 -1 -1', '1 1 1'); // give it some size so it can be shot
    setorigin(rocket,gettaginfo(self.tur_head,gettagindex(self.tur_head,"tag_fire")));
    te_explosion (rocket.origin);

    crosshair_trace(self.owner);

    rocket.classname       = "spiderbot_rocket";
    rocket.bot_dodge       = TRUE;
    rocket.bot_dodgerating = cvar("g_vehicle_spiderbot_rocket_damage");
    rocket.cnt             = time + cvar("g_vehicle_spiderbot_rocket_lifetime");
    rocket.health          = cvar("g_vehicle_spiderbot_rocket_health");
    rocket.takedamage      = DAMAGE_AIM;
    rocket.event_damage    = spiderbot_rocket_damage;
    rocket.owner           = self.owner;
    rocket.nextthink       = time;
    rocket.movetype        = MOVETYPE_FLYMISSILE;
    rocket.velocity        = normalize(v_forward + (v_up * 0.5) + randomvec() * 0.25) * cvar("g_vehicle_spiderbot_rocket_speed");
    rocket.angles          = vectoangles(rocket.velocity);
    rocket.think           = spiderbot_rocket_guided;
    rocket.touch           = spiderbot_rocket_touch;
    rocket.flags           = FL_PROJECTILE;
    rocket.solid           = SOLID_TRIGGER;
    rocket.pos1            = trace_endpos;

	CSQCProjectile(rocket, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound

    self.tur_head.frame += 1;
    if (self.tur_head.frame == 9)
        self.attack_finished_single = cvar("g_vehicle_spiderbot_rocket_reload");
    else
        self.attack_finished_single = cvar("g_vehicle_spiderbot_rocket_refire");

    self.gun2.cnt = time + self.attack_finished_single;
}

void spiderbot_minigun_fire_Flash_Go() {
	if (self.frame > 10)
	{
		self.alpha = -1;
		setmodel(self,"");
		return;
	}

	self.frame = self.frame + 2;
	self.alpha = self.alpha - 0.2;
	self.scale -= 0.01;
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
        cvar("g_vehicle_spiderbot_minigun_spread"), DEATH_SBMINIGUN, 0);

    if not (gun.enemy)
    {
        gun.enemy = spawn();
        setattachment(gun.enemy , gun, "barrels");
        setorigin(gun.enemy ,gun.enemy.origin + '52 0 0');
    }

    flash = gun.enemy;
    setmodel(flash, "models/uziflash.md3");
    flash.think = spiderbot_minigun_fire_Flash_Go;
    flash.nextthink = time + 0.02;
    flash.frame = 2;
    flash.angles_z = flash.v_angle_z + random() * 180;
    flash.alpha = 1;
    flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
    flash.scale = 1;

    if(trail)
        trailparticles(self, particleeffectnum("EF_MGTURRETTRAIL"), v, trace_endpos);
}

void spiderbot_miniguns_do()
{
    float ftmp;

    if((self.vehicle_reload1 == 1) || (!self.owner.BUTTON_ATCK))
    {

        ftmp = 1 / cvar("g_vehicle_spiderbot_minigun_cooldown") * sys_frametime;
        self.owner.vehicle_reload1 = max(self.owner.vehicle_reload1 - ftmp, 0);
        if(self.owner.vehicle_reload1 <= 0)
            self.vehicle_reload1 = 0;

        return ;
    }

    if (self.owner.BUTTON_ATCK)
    {

        // Animate miniguns
        self.gun1.angles_z += (1440 * sys_frametime);
        self.gun2.angles_z -= (1440 * sys_frametime);
        if(self.gun1.angles_z >= 360)
        {
            self.gun1.angles_z = 0;
            self.gun2.angles_z = 360;
        }

        if (self.tur_head.attack_finished_single < time)
        {
            // Fire bullets, alternating trails left<->right
            self = self.owner;
            if(self.uzi_bulletcounter == 1)
            {
                spiderbot_minigun_fire(self.vehicle.gun1, 0);
                spiderbot_minigun_fire(self.vehicle.gun2, 1);
                self.uzi_bulletcounter = 0;
            }
            else
            {
                spiderbot_minigun_fire(self.vehicle.gun1, 1);
                spiderbot_minigun_fire(self.vehicle.gun2, 0);
                self.uzi_bulletcounter += 1;
            }

            self = self.vehicle;

            ftmp = cvar("g_vehicle_spiderbot_minigun_refire") / cvar("g_vehicle_spiderbot_minigun_heat");
            self.owner.vehicle_reload1 +=  ftmp;

            if(self.owner.vehicle_reload1 >= 1)
            {
                self.vehicle_reload1 = 1;
                self.owner.vehicle_reload1 = 1;
                self.tur_head.attack_finished_single = cvar("g_vehicle_spiderbot_minigun_cooldown") + time;
            }
            else
                self.tur_head.attack_finished_single = cvar("g_vehicle_spiderbot_minigun_refire") + time;
        }

        self = self.owner;
        return;
    }
}
#define SBS_IDLE  0
#define SBS_JUMP  1
#define SBS_WALK  2
#define SBS_BACK  3
#define SBS_LEFT  4
#define SBS_RIGHT 5
.float state;

float spiderbot_pplug()
{
    vector ad;
    entity player,spider;
    float ftmp;

    player = self;
    spider = self.vehicle;

    player.BUTTON_ZOOM = 0;
    player.BUTTON_CROUCH = 0;
    player.switchweapon = 0;

    if(player.BUTTON_USE)
    {
        self = spider;
        spiderbot_exit(0);
        self = player;
        return 0;
    }

    crosshair_trace(player);
    ad = vectoangles(normalize(trace_endpos - gettaginfo(spider.tur_head,gettagindex(spider.tur_head,"tag_hud")))) - (spider.tur_head.angles + spider.angles);

    fixedmakevectors(spider.angles);
    if(ad_x > 180) ad_x -= 360;
    if(ad_x < -180) ad_x += 360;
    if(ad_y > 180) ad_y -= 360;
    if(ad_y < -180) ad_y += 360;

    // Rotate head
    ftmp = cvar("g_vehicle_spiderbot_head_turnspeed") * sys_frametime;
    ad_y = bound(-ftmp, ad_y, ftmp);
    spider.tur_head.angles_y = bound(cvar("g_vehicle_spiderbot_head_turnlimit") * -1, spider.tur_head.angles_y + ad_y, cvar("g_vehicle_spiderbot_head_turnlimit"));

    // Pitch head
    ftmp = cvar("g_vehicle_spiderbot_head_pitchspeed") * sys_frametime;
    ad_x = bound(-ftmp, ad_x, ftmp);
    spider.tur_head.angles_x = bound(cvar("g_vehicle_spiderbot_head_pitchlimit_down"), spider.tur_head.angles_x + ad_x, cvar("g_vehicle_spiderbot_head_pitchlimit_up"));

    // Turn Body
    ftmp = cvar("g_vehicle_spiderbot_turnspeed") * sys_frametime;
    ftmp = bound(-ftmp, spider.tur_head.angles_y, ftmp);

    self = spider;
    if(spider.flags & FL_ONGROUND)
    {
        if(player.BUTTON_JUMP)
        {
            player.BUTTON_JUMP = 0;
            spider.velocity   = v_forward * 700 + v_up * 600;
            spider.frame = 4;
        }
        else
        {
            if(vlen(player.movement) == 0)
            {
                movelib_beak_simple(cvar("g_vehicle_spiderbot_speed_stop"));
                spider.frame = 5;
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
                        spider.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        spider.frame = 1;
                    }
                    player.movement_y = 0;
                    movelib_move_simple(normalize(v_forward * player.movement_x),cvar("g_vehicle_spiderbot_speed_walk"),cvar("g_vehicle_spiderbot_movement_inertia"));
                }
                else if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                    {
                        player.movement_y = -1;
                        spider.frame = 2;
                    }
                    else if(player.movement_y > 0)
                    {
                        player.movement_y = 1;
                        spider.frame = 3;
                    }
                    movelib_move_simple(normalize(v_right * player.movement_y),cvar("g_vehicle_spiderbot_speed_strafe"),cvar("g_vehicle_spiderbot_movement_inertia"));
                }

            }
        }
        movelib_groundalign4point(300,100,0.25);
    }

    spiderbot_miniguns_do();
    spiderbot_rocket_do();
    vehicle_stdproc_shiledregen(CCVAR("_shield"), frametime);
    vehicle_stdproc_healthregen(CCVAR("_health"), frametime);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    player.vehicle_ammo2 = spider.tur_head.frame;

    if(spider.gun2.cnt <= time)
        player.vehicle_reload2 = 1;
    else
        player.vehicle_reload2 = 1 - ((spider.gun2.cnt - time) / spider.attack_finished_single);

    //setorigin(spider,spider.origin);
    setorigin(player,spider.origin + '0 0 64');
    player.velocity = spider.velocity;

    self = player;

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
    // Remove this when bots know how to use the spiderbot
    if (clienttype(other) != CLIENTTYPE_REAL)
        return;

    self.colormod = self.tur_head.colormod = '0 0 0';

    if(teamplay)
    if(self.team)
    if(self.team != other.team)
        return;

    self.owner = other;
    self.switchweapon = other.switchweapon;

    self.event_damage         = vehicle_stdproc_damage ;
    self.colormap             = self.owner.colormap;
    self.tur_head.colormap    = self.owner.colormap;
    self.vehicle_hudmodel.viewmodelforclient = self.owner;
    self.nextthink            = 0;
    self.owner.angles         = self.angles;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.solid          = SOLID_NOT;
    self.owner.movetype       = MOVETYPE_NOCLIP;
    self.owner.alpha          = -1;
    self.owner.PlayerPhysplug = spiderbot_pplug;
    self.owner.vehicle        = self;
    self.owner.event_damage   = SUB_Null;
    self.owner.hud            = HUD_SPIDERBOT;
    self.owner.vehicle_health = (self.vehicle_health / cvar("g_vehicle_spiderbot_health"));
    self.owner.vehicle_shield = (self.vehicle_shield / cvar("g_vehicle_spiderbot_shield"));
    self.owner.view_ofs       = '0 0 0';
    self.owner.vehicle_ammo1 = self.vehicle_ammo1;
    self.owner.vehicle_ammo2 = self.vehicle_ammo2;
    self.owner.vehicle_reload1 = self.vehicle_reload1;
    self.owner.vehicle_reload2 = self.vehicle_reload2;

    //if(other.flags & FL_ONGROUND)
        other.flags &~= FL_ONGROUND;

    //if(self.flags & FL_ONGROUND)
        self.flags &~= FL_ONGROUND;

    self.team                 = self.owner.team;
    self.flags               -= FL_NOTARGET;

    if(clienttype(other) == CLIENTTYPE_REAL)
    {
        msg_entity = other;
        WriteByte (MSG_ONE, SVC_SETVIEWPORT);
        WriteEntity(MSG_ONE, self.vehicle_viewport);

        WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
        WriteAngle(MSG_ONE, self.tur_head.angles_x + self.angles_x);    // tilt
        WriteAngle(MSG_ONE, self.tur_head.angles_y + self.angles_y);    // yaw
        WriteAngle(MSG_ONE, 0);    // roll
    }
}

void spiderbot_exit(float eject)
{
    entity e;
    self.frame = 5;

    self.flags      |= FL_NOTARGET;

    e = findchain(classname,"spiderbot_rocket");
    while(e)
    {
        if(e.owner == self.owner)
        {
            e.realowner = self.owner;
            e.owner = world;
        }
        e = e.chain;
    }

    self.owner.switchweapon = self.switchweapon;

    self.velocity = '0 0 0';
    if(clienttype(self.owner) == CLIENTTYPE_REAL)
    {
        msg_entity = self.owner;
        WriteByte (MSG_ONE, SVC_SETVIEWPORT);
        WriteEntity( MSG_ONE, self.owner);

        WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
        WriteAngle(MSG_ONE, 0);    // tilt
        WriteAngle(MSG_ONE, self.angles_y);    // yaw
        WriteAngle(MSG_ONE, 0);    // roll
    }

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

    if not (teamplay)
        self.team                = 0;
    else
    {
        self.team = self.spiderbot_spawnpnt.team ;
        if (self.team == COLOR_TEAM1) self.colormod = '1.4 0.8 0.8';
        if (self.team == COLOR_TEAM2) self.colormod = '0.8 0.8 1.4';
        self.tur_head.colormod = self.colormod;
    }

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

float spiderbot_crushable(entity e)
{
    if(e.classname == "corpse")
        return 1;

    if(e.classname == "player")
        return 1;

    if(e.classname == "monster_zombie")
        return 1;

    return 0;
}

void spiderbot_touch()
{
    if(self.owner)
    {
        if(vlen(self.velocity) == 0)
            return;

        if not (spiderbot_crushable(other))
            return;

        //todo: add check for velocity/angle here (so we dont cush players runing into us from behind)

        Damage(other,self,self.owner,cvar("g_vehicle_spiderbot_crush_dmg"),DEATH_SBCRUSH,'0 0 0', normalize(other.origin - self.origin) * cvar("g_vehicle_spiderbot_crush_force") );
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

void spiderbot_spawn()
{
    self.frame = 5;
    self.think = spiderbot_think;
    self.nextthink = time;

    setsize(self,spiderbot_MIN,spiderbot_MAX);

    self.velocity = '0 0 0';
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
    self.flags      |= FL_NOTARGET;
    self.vehicle_hudmodel.viewmodelforclient = self;
    self.tur_head.frame = 1;

    setorigin(self,self.spiderbot_spawnpnt.origin + '0 0 1.25' * spiderbot_MAX_z);
    self.angles = self.spiderbot_spawnpnt.angles;

    if (self.team == COLOR_TEAM1)
        self.colormod = '1.4 0.8 0.8';
    else if (self.team == COLOR_TEAM2)
        self.colormod = '0.8 0.8 1.4';
    else
        self.colormod = '0 0 0';

    self.tur_head.colormod = self.colormod;


    pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
}

void spiderbot_blowup()
{
    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    pointparticles(particleeffectnum("rocket_explode"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    RadiusDamage (self, self, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = -1;
    self.nextthink  = time + cvar("g_vehicle_spiderbot_respawntime");
    self.think      = spiderbot_spawn;
    self.movetype   = MOVETYPE_NONE;

    setorigin(self, self.tur_aimpos);
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
	self.tur_head.frame = 1;

}

void vewhicle_spiderbot_dinit()
{

    self.spiderbot_spawnpnt = spawn();
    self.spiderbot_spawnpnt.angles = self.angles;

    setorigin(self,self.origin);
    tracebox(self.origin + '0 0 100', spiderbot_MIN, spiderbot_MAX, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
    setorigin(self.spiderbot_spawnpnt,trace_endpos);

    if(self.team && !teamplay)
        self.team = 0;
    else
        self.spiderbot_spawnpnt.team = self.team;

    addstat(STAT_HUD, AS_INT,  hud);
	addstat(STAT_VEHICLESTAT_HEALTH,  AS_FLOAT, vehicle_health);
	addstat(STAT_VEHICLESTAT_SHIELD,  AS_FLOAT, vehicle_shield);
	addstat(STAT_VEHICLESTAT_ENERGY,  AS_FLOAT, vehicle_energy);
	addstat(STAT_VEHICLESTAT_AMMO1,   AS_INT,   vehicle_ammo1);
	addstat(STAT_VEHICLESTAT_RELOAD1, AS_FLOAT, vehicle_reload1);
	addstat(STAT_VEHICLESTAT_AMMO2,   AS_INT,   vehicle_ammo2);
	addstat(STAT_VEHICLESTAT_RELOAD2, AS_FLOAT, vehicle_reload2);

    if (self.netname == "")
        self.netname     = "spiderbot";

    self.tur_head           = spawn();
    self.gun1               = spawn();
    self.gun2               = spawn();
    self.vehicle_viewport   = spawn();
    self.vehicle_hudmodel   = spawn();
    self.vehicle_flags      = VHF_HASSHIELD | VHF_SHIELDREGEN | VHF_HEALTHREGEN | VHF_DEATHEJECT;
    self.cvar_basename      = "g_vehicle_spiderbot";
    self.gravity            = 2;

    setmodel(self, "models/vehicles/spiderbot.dpm");
    setmodel(self.tur_head, "models/vehicles/spiderbot_top.dpm");
    setmodel(self.gun1, "models/vehicles/spiderbot_barrels.dpm");
    setmodel(self.gun2, "models/vehicles/spiderbot_barrels.dpm");
    setmodel(self.vehicle_hudmodel, "models/vehicles/spiderbot_cockpit.dpm");
    setmodel(self.vehicle_viewport, "null");

    setattachment(self.tur_head, self, "tag_head");
    setattachment(self.vehicle_hudmodel, self.tur_head, "tag_hud");
    setattachment(self.vehicle_viewport, self.vehicle_hudmodel, "");

    setattachment(self.gun1, self.tur_head, "tag_hardpoint01");
    setattachment(self.gun2, self.tur_head, "tag_hardpoint02");

    self.tur_head.owner = self;
    self.customizeentityforclient          = spiderbot_customizeentityforclient;

    self.tur_aimpos = self.origin;

    spiderbot_spawn();

    self.vehicle_die = spiderbot_die;
    self.vehicle_exit = spiderbot_exit;
}

void spawnfunc_vehicle_spiderbot()
{
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/vehicles/spiderbot.dpm");
    precache_model ( "models/vehicles/spiderbot_top.dpm");
    precache_model ( "models/vehicles/spiderbot_barrels.dpm");
    precache_model ( "models/vehicles/spiderbot_cockpit.dpm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/rocket_impact.wav" );

    //self.team                = -1;
    self.think = vewhicle_spiderbot_dinit;
    self.nextthink = time + 0.5;
}
