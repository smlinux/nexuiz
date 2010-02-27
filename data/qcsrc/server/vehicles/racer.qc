#define RACER_MIN '-80 -80 -40'
#define RACER_MAX '80 80 40'
#define RACER_TICRATE 0.05

void racer_exit(float eject);
void racer_enter();
//void racer_think();

float racer_power_air;
float racer_power_solid;
float racer_power_min;
float racer_anglestabilizer;
float racer_springlength;

float racer_healthmax;
float racer_shieldmax;
float racer_energymax;

float racer_pitchspeed;
float racer_turnspeed;
float racer_turnroll;
float racer_speed_forward;
float racer_speed_strafe;

float  jetfromtag_power;
float  jetfromtag_normpower;
vector jetfromtag_origin;
float  jetfromtag_groundcontact;

void racer_loadsettings()
{
    racer_power_min         = cvar("g_vehicle_racer_power_min")   * 0.25;
    racer_power_air         = cvar("g_vehicle_racer_power_air")   * 0.25;
    racer_power_solid       = cvar("g_vehicle_racer_power_solid") * 0.25;

    racer_springlength      = cvar("g_vehicle_racer_springlength");
    racer_anglestabilizer   = cvar("g_vehicle_racer_anglestabilizer");
    racer_pitchspeed        = cvar("g_vehicle_racer_pitchspeed");
    racer_turnspeed         = cvar("g_vehicle_racer_turnspeed");
    racer_turnroll          = cvar("g_vehicle_racer_turnroll");
    racer_speed_forward     = cvar("g_vehicle_racer_speed_forward");
    racer_speed_strafe      = cvar("g_vehicle_racer_speed_strafe");

    racer_healthmax = cvar("g_vehicle_racer_health");
    racer_shieldmax = cvar("g_vehicle_racer_shield");
    racer_energymax = cvar("g_vehicle_racer_energy");

}

vector racer_jetfromtag(string tagname)
{
    vector force_dir;
    float  air_frac, solid_frac, air_pwr, solid_pwr;

    jetfromtag_origin = gettaginfo(self,gettagindex(self,tagname));
    v_forward  = normalize(v_forward) * -1;

    force_dir = jetfromtag_origin - (v_forward  * racer_springlength);
    traceline(jetfromtag_origin, force_dir, MOVE_NORMAL, self);
    //te_lightning1(world,jetfromtag_origin, force_dir);

    //trace_fraction *= trace_fraction;

    solid_frac = 1 - trace_fraction;
    air_frac = trace_fraction;

    if (trace_fraction != 1.0)
        jetfromtag_groundcontact = 1;

    solid_pwr = solid_frac * racer_power_solid;
    air_pwr   = air_frac * racer_power_air;

    jetfromtag_power     = solid_pwr + air_pwr;
    jetfromtag_normpower = jetfromtag_power / (racer_power_air + racer_power_solid);

    //te_lightning1(world,jetfromtag_origin,jetfromtag_origin + normalize(self.origin - force_dir) * max(jetfromtag_power, racer_power_min));
    //return normalize(self.origin - force_dir) * max(jetfromtag_power, racer_power_min);
    return v_forward  * max(jetfromtag_power, racer_power_min);
}

void racer_align4point()
{
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    jetfromtag_groundcontact = 0;

    push_vector = racer_jetfromtag("tag_engine_fr");
    fr_push = jetfromtag_normpower;
    traceline(jetfromtag_origin, jetfromtag_origin + self.velocity * frametime, MOVE_NORMAL,self);
    if(trace_fraction != 1)
        self.velocity += normalize(self.origin - trace_endpos) * (vlen(self.velocity) * 1.25);

    push_vector += racer_jetfromtag("tag_engine_fl");
    fl_push = jetfromtag_normpower;
    traceline(jetfromtag_origin, jetfromtag_origin + self.velocity * frametime, MOVE_NORMAL,self);
    if(trace_fraction != 1)
        self.velocity += normalize(self.origin - trace_endpos) * (vlen(self.velocity) * 1.25);

    push_vector += racer_jetfromtag("tag_engine_br");
    br_push = jetfromtag_normpower;
    traceline(jetfromtag_origin, jetfromtag_origin + self.velocity * frametime, MOVE_NORMAL,self);
    if(trace_fraction != 1)
        self.velocity += normalize(self.origin - trace_endpos) * (vlen(self.velocity) * 1.25);

    push_vector += racer_jetfromtag("tag_engine_bl");
    bl_push = jetfromtag_normpower;
    traceline(jetfromtag_origin, jetfromtag_origin + self.velocity * frametime, MOVE_NORMAL,self);
    if(trace_fraction != 1)
        self.velocity += normalize(self.origin - trace_endpos) * (vlen(self.velocity) * 1.25);

    self.velocity =  self.velocity + (push_vector * frametime);
    self.velocity_z -= sv_gravity * frametime;

    push_vector_x = (fl_push - bl_push);
    push_vector_x += (fr_push - br_push);
    push_vector_x *= 360;

    push_vector_z = (fr_push - fl_push);
    push_vector_z += (br_push - bl_push);
    push_vector_z *= 360;

    //if (push_vector_z != 0)
        if(self.angles_z > 0)
            self.angles_z = max(0, self.angles_z - (racer_anglestabilizer * frametime));
        else
            self.angles_z = min(0, self.angles_z + (racer_anglestabilizer * frametime));
    //else
        self.angles_z += push_vector_z * frametime;

    //if (push_vector_x != 0)
        if(self.angles_x > 0)
            self.angles_x = max(0, self.angles_x - (racer_anglestabilizer * frametime));
        else
            self.angles_x = min(0, self.angles_x + (racer_anglestabilizer * frametime));
    //else
        self.angles_x += push_vector_x * frametime;
}

void racer_bolt_explode()
{
    vector org2;

    org2 = findbetterlocation (self.origin, 8);
    pointparticles(particleeffectnum("laser_impact"), org2, trace_plane_normal * 1000, 1);
    RadiusDamage (self, self.realowner, cvar("g_vehicle_racer_laser_damage"), 0, cvar("g_vehicle_racer_laser_radius"), world, 150, DEATH_WAKIGUN, world);
    sound (self, CHAN_PROJECTILE, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);

    remove (self);
}

void racer_rocket_explode()
{
    vector org2;

    //if not(self.owner)
    //    self.owner = self.realowner;

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);
    pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
    RadiusDamage (self, self.realowner ,cvar("g_vehicle_racer_rocket_damage"), 0, cvar("g_vehicle_racer_rocket_radius"), world, 150, DEATH_WAKIROCKET, world);

    remove (self);
}

void racer_rocket_touch()
{
    if(other.owner == self.owner)
        return;

    PROJECTILE_TOUCH;
    /*
    if(pointcontents(self.origin) == CONTENT_SKY)
    {
        self.think = SUB_Remove;
        self.nextthink = time;
        return;
    }
    */

    racer_rocket_explode();
}

void racer_fire_cannon(string tagname)
{
    entity bolt;

    bolt = spawn();
    bolt.solid           = SOLID_TRIGGER;
    bolt.movetype        = MOVETYPE_FLYMISSILE;
    bolt.flags           = FL_PROJECTILE | FL_NOTARGET;
    bolt.owner           = self;
    bolt.realowner       = self.owner;
    bolt.touch           = racer_bolt_explode;
    bolt.think           = racer_bolt_explode;
    bolt.nextthink       = time + 9;
    bolt.bot_dodge       = TRUE;
    bolt.bot_dodgerating = cvar("g_vehicle_racer_laser_damage");
    setorigin(bolt, gettaginfo(self,gettagindex(self,tagname)));

    vector v;
	// FIXME this uses prydon cursor
    v = normalize(self.owner.cursor_trace_endpos - bolt.origin);
    v_forward_z = v_z * 0.5;
    //v_forward_z *= 0.5;

    bolt.velocity = v_forward * cvar("g_vehicle_racer_laser_speed");

    CSQCProjectile(bolt, TRUE, PROJECTILE_LASER, TRUE);
}

void racer_rocket_groundhugger()
{
    vector newdir,olddir;
    float oldspeed, newspeed;

    self.nextthink  = time;

    if ((self.owner.deadflag != DEAD_NO) || (self.cnt < time))
    {
        racer_rocket_explode();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir   = normalize(self.velocity);
    oldspeed = vlen(self.velocity);

    tracebox(self.origin, self.mins, self.maxs, self.origin + olddir * 512, MOVE_WORLDONLY,self);
    if(trace_fraction >= 0.35)
    {
        traceline(trace_endpos, trace_endpos - '0 0 512', MOVE_NORMAL, self);
        if(trace_fraction != 1.0)
            newdir = trace_endpos + '0 0 32';

        newdir = normalize(newdir - self.origin);
    }

    newspeed = oldspeed + self.lip;
    self.velocity = normalize(olddir + newdir * self.wait) * newspeed;

    UpdateCSQCProjectile(self);
}

void racer_rocket_think()
{
    vector newdir,olddir, eorg, edir;
    float oldspeed, newspeed, dist;

    self.nextthink  = time;

    if ((self.owner.deadflag != DEAD_NO) || (self.cnt < time))
    {
        racer_rocket_explode();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldspeed = vlen(self.velocity);
    fixedmakevectors(olddir);
    eorg = 0.5 * (self.enemy.absmin + self.enemy.absmax);
    edir = normalize(eorg - self.origin);
    dist = vlen(self.origin - self.enemy.origin);

    if(dist > 512)
    {
        vector ddir;
        float p;
        p = dist / self.delay;
        p = max(0.05, p * 0.25);
        ddir = steerlib_traceavoid(p, oldspeed * 0.25);
        edir += ddir * 0.95;
    }

    newdir = normalize(olddir + edir * self.wait);
    newspeed = oldspeed + self.lip;
    self.velocity = normalize(olddir + newdir * self.wait) * newspeed;

    UpdateCSQCProjectile(self);
}

void racer_fire_rocket(string tagname)
{
    entity rocket;

    rocket = spawn();
    setsize (rocket, '-1 -1 -1', '1 1 1');
    rocket.lip             = cvar("g_vehicle_racer_rocket_accel") * sys_frametime;
    rocket.wait            = cvar("g_vehicle_racer_rocket_turnrate");
    rocket.solid           = SOLID_BBOX;
    rocket.movetype        = MOVETYPE_FLYMISSILE;
    rocket.flags           = FL_PROJECTILE;
    rocket.owner           = self;
    rocket.realowner       = self.owner;
    rocket.touch           = racer_rocket_touch;
    rocket.bot_dodge       = TRUE;
    rocket.bot_dodgerating = cvar("g_vehicle_racer_rocket_damage");
    setorigin(rocket, gettaginfo(self,gettagindex(self,tagname)));

    /*
    if( (self.tur_head.gun1) && (self.tur_head.cnt > time))
        rocket.enemy = self.tur_head.gun1;

    if(rocket.enemy)
    {
        rocket.delay           = vlen(rocket.enemy.origin  - rocket.origin);
        rocket.cnt             = time + 9;
        rocket.velocity = v_forward * cvar("g_vehicle_racer_rocket_speed");
        rocket.think = racer_rocket_think;
        rocket.nextthink = time;
        CSQCProjectile(rocket, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound
    }
    else
    {
    */
        rocket.cnt             = time + 9;
        rocket.velocity = v_forward * cvar("g_vehicle_racer_rocket_speed");
        rocket.think = racer_rocket_groundhugger;
        rocket.nextthink = time;
        CSQCProjectile(rocket, TRUE, PROJECTILE_ROCKET, TRUE);
    //}
}

float racer_customizeentityforclient()
{

    if(self.deadflag == DEAD_DEAD)
        return FALSE;

    /*
    if(other == self.owner)
        self.alpha = -1;
    else
        self.alpha = 1;
    */

    return TRUE;
}

float racer_pplug()
{
    entity player, racer;
    float ftmp, ftmp2;
    vector df;


    if(cvar("g_vehicle_racer_reload"))
    {
        racer_loadsettings();
        cvar_set("g_vehicle_racer_reload","0");
    }

    player          = self;
    racer           = self.vehicle;

    player.BUTTON_ZOOM = 0;
    player.BUTTON_CROUCH = 0;

    self = racer;

    if(player.BUTTON_USE)
    {
        self = racer;
        racer_exit(0);
        self = player;
        return 0;
    }

    if(racer.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }


    racer_align4point();

    racer.angles_x *= -1;
    makevectors(racer.angles);

    // Rotate Body
    ftmp = racer_turnspeed * sys_frametime;
    ftmp2 = ftmp * -1;

    ftmp = bound(ftmp2,shortangle_f(player.v_angle_y - racer.angles_y,racer.angles_y),ftmp);
    ftmp2 = safeangle(racer.angles_y + ftmp);

    // Roll
    ftmp = bound(-45,shortangle_f(player.v_angle_z + ((racer.angles_y - ftmp2) * racer_turnroll), racer.angles_z),45);
    ftmp = safeangle(racer.angles_z + ftmp);
    racer.angles_z = bound(-85,ftmp,85);

    // Turn
    racer.angles_y = ftmp2;

    // Pitch Body
    ftmp = racer_pitchspeed * sys_frametime;
    ftmp2 = ftmp * -1;

    ftmp = bound(ftmp2,shortangle_f(player.v_angle_x - racer.angles_x,racer.angles_x),ftmp);
    racer.angles_x = safeangle(racer.angles_x + ftmp);
    racer.angles_x *= -1;

    df = racer.velocity * -1;

    if(player.movement_x != 0)
    {
        if(player.movement_x > 0)
            df += v_forward  * racer_speed_forward;
        else if(player.movement_x < 0)
            df -= v_forward  * racer_speed_forward;
    }

    if(player.movement_y != 0)
    {
        if(player.movement_y < 0)
            df -= v_right * racer_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * racer_speed_strafe;
    }

    // limit _z to avoid flying on normal thrust
    if(df_z > 0)
        df_z = min(df_z,700);


    // Afterburn
    //if (jetfromtag_groundcontact)
    if (player.BUTTON_JUMP)
    if(racer.vehicle_energy >= (cvar("g_vehicle_racer_speed_afterburn_cost") * frametime))
    {
        racer.wait = time + cvar("g_vehicle_racer_energy_usepause");
        racer.vehicle_energy -= cvar("g_vehicle_racer_speed_afterburn_cost") * frametime;
        df += (v_forward * cvar("g_vehicle_racer_speed_afterburn"));
    }

    racer.velocity  += df * frametime;

    df = (vlen(racer.velocity) * cvar("g_vehicle_racer_downforce") * v_up) * frametime;
    racer.velocity  = racer.velocity - df;
    player.movement = racer.velocity;

    /*
    // for homing rockets
	// FIXME this uses prydon cursor
    if(self.owner.cursor_trace_ent)
    {
        self.tur_head.gun1 = self.owner.cursor_trace_ent;
        self.tur_head.cnt = time + 1;
    }
    */

    if(player.BUTTON_ATCK)
    if(time > racer.attack_finished_single)
    if(racer.vehicle_energy >= cvar("g_vehicle_racer_laser_cost"))
    {
        racer.vehicle_energy -= cvar("g_vehicle_racer_laser_cost");
        racer.wait = time + cvar("g_vehicle_racer_energy_usepause");

        if(racer.cnt)
        {
            racer_fire_cannon("tag_fire1");
            racer.cnt = 0;
        }
        else
        {
            racer_fire_cannon("tag_fire2");
            racer.cnt = 1;
        }
        racer.attack_finished_single = time + cvar("g_vehicle_racer_laser_refire");
    }

    if(player.BUTTON_ATCK2)
    if(time > racer.delay)
    {
        racer_fire_rocket("tag_rocket_r");
        racer_fire_rocket("tag_rocket_l");
        racer.delay = time + cvar("g_vehicle_racer_rocket_refire");
        racer.lip = time;

    }

    player.vehicle_reload1 = (time - racer.lip) / (racer.delay-racer.lip);
    //player.vehicle_energy = racer.vehicle_energy;

    vehicle_stdproc_shiledregen(racer_shieldmax, frametime);
    vehicle_stdproc_healthregen(racer_healthmax, frametime);

    if (racer.wait < time)
        vehicle_stdproc_energyregen(racer_energymax, frametime);
    else
        player.vehicle_energy = (racer.vehicle_energy / racer_energymax);

    self = player;

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    setorigin(player,racer.origin + '0 0 32');
    player.velocity = racer.velocity;

    return 1;
}

void racer_exitthink()
{
    float a, b, c;

    self.nextthink = time;

    a = racer_anglestabilizer;
    b = racer_springlength;
    c = racer_power_solid;

    racer_anglestabilizer = 36;
    racer_springlength = 96;
    racer_power_solid = 300;

    racer_align4point();

    if(self.velocity_z < 0)
        self.velocity_z *= 0.95;

    racer_anglestabilizer = a;
    racer_springlength = b;
    racer_power_solid = c;

    self.velocity_x *= 0.95;
    self.velocity_y *= 0.95;
}

void racer_spawnthink()
{
    float a, b, c;
    vector dorg;

    self.nextthink = time;

    a = racer_anglestabilizer;
    b = racer_springlength;
    c = racer_power_solid;

    racer_anglestabilizer = 36;
    racer_springlength = 96;
    racer_power_solid = 300;

    // self.velocity_z += sin(time * 128) * 4;

    racer_align4point();

    if(self.velocity_z < 0)
        self.velocity_z *= 0.98;

    racer_anglestabilizer = a;
    racer_springlength = b;
    racer_power_solid = c;

    self.velocity_x *= 0.95;
    self.velocity_y *= 0.95;

    dorg = self.pos1 - self.origin ;

    self.velocity_x = bound(-32, self.velocity_x + dorg_x, 32);
    self.velocity_y = bound(-32, self.velocity_y + dorg_y, 32);
}

void racer_enter()
{
    self.owner = other;


    self.nextthink = 0;
    self.flags               = 0;
    self.vehicle_hudmodel.viewmodelforclient = self.owner;
    self.colormap             = self.owner.colormap;

    self.owner.PlayerPhysplug = racer_pplug;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.event_damage   = SUB_Null;
    self.owner.vehicle        = self;
    self.owner.angles = self.angles;
    self.owner.solid          = SOLID_NOT;
    self.owner.movetype       = MOVETYPE_NOCLIP;
    self.owner.alpha          = -1;
    self.owner.hud            = HUD_WAKIZASHI;
    self.owner.effects        |= EF_NODRAW;
    self.owner.view_ofs = '0 0 0';

    self.owner.vehicle_health = (self.vehicle_health / cvar("g_vehicle_racer_health"));
    self.owner.vehicle_shield = (self.vehicle_shield / cvar("g_vehicle_racer_shield"));

    setorigin(other,self.origin + '0 0 32');
    other.velocity = self.velocity;

    other.flags &~= FL_ONGROUND;
    msg_entity = other;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.vehicle_viewport);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES); // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE,  self.angles_x * -1);    // tilt
    WriteAngle(MSG_ONE,  self.angles_y);    // yaw
    WriteAngle(MSG_ONE,  0);                // roll
}

void racer_spawn();
void racer_return()
{
    pointparticles(particleeffectnum("teleport"), self.enemy.origin + '0 0 64', '0 0 0', 1);
    self.enemy.think = racer_spawn;
    self.enemy.nextthink = time;
    remove(self);
}

void racer_exit(float eject)
{
	self.colormap   = 1024;
	self.flags      = FL_NOTARGET;

    if not (self.owner)
        return;

    msg_entity = self.owner;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.owner);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);    // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE,  0);                   // tilt
    WriteAngle(MSG_ONE,  self.angles_y); // yaw
    WriteAngle(MSG_ONE,  0);                   // roll

    if (self.deadflag == DEAD_NO)
    {
        self.think = racer_exitthink;
        self.nextthink = time;
    }

    self.owner.takedamage     = DAMAGE_AIM;
    self.owner.solid          = SOLID_SLIDEBOX;
    self.owner.movetype       = MOVETYPE_WALK;

    setsize(self.owner,PL_MIN,PL_MAX);

    self.owner.effects        &~= EF_NODRAW;
    self.owner.alpha          = 1;
    self.owner.PlayerPhysplug = SUB_Null;
    self.owner.vehicle        = world;
	self.owner.view_ofs       = PL_VIEW_OFS;
	self.owner.event_damage   = PlayerDamage;
	self.owner.hud            = HUD_NORMAL;

    self.vehicle_hudmodel.viewmodelforclient = self;

	if(eject)
	{
	    makevectors(self.angles);
	    setorigin(self.owner,self.origin + v_forward * 100);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	}
	else
	{
	    self.owner.velocity = (v_forward) * -150;
        setorigin(self.owner,self.origin - v_forward * 128);
	}

    self.owner = world;

    if (self.deadflag != DEAD_NO)
    {
        entity ret;
        ret = spawn();
        ret.enemy = self;
        ret.think = racer_return;
        ret.nextthink = time + cvar("g_vehicle_racer_respawntime");
    }
}

void racer_touch()
{
    if(self.owner)
    {
        if(vlen(self.velocity) == 0)
            return;

        if(other.classname != "player")
            return;

        vector a;
        a = normalize(other.origin - self.origin);
        a = a - normalize(self.velocity);

        return;
    }

    if(other.classname != "player")
        return;

    if(other.deadflag != DEAD_NO)
        return;

    if(other.vehicle != world)
        return;

    racer_enter();
}

/*
float racer_customizeentityforclient()
{
    if(self.deadflag == DEAD_DEAD)
        return FALSE;

    return TRUE;
}
*/

void racer_spawn()
{
    self.think = racer_spawnthink;
    self.nextthink = time;

    self.flags      = FL_NOTARGET;
    self.effects   = 0;

    self.vehicle_health = racer_healthmax;
    self.vehicle_shield = racer_shieldmax;

    self.event_damage = vehicle_stdproc_damage;
    self.touch      = racer_touch;

    self.iscreature = TRUE;
    self.scale      = 0.5;
    self.movetype   = MOVETYPE_FLY;
    self.solid      = SOLID_SLIDEBOX;
    self.takedamage = DAMAGE_AIM;

    self.alpha = 1;
	self.colormap = 1024;
	self.deadflag    = DEAD_NO;
    self.bot_attack = TRUE;

    self.vehicle_energy = 1;
    self.vehicle_hudmodel.viewmodelforclient = self;

    setorigin(self, self.pos1);
    self.angles = self.pos2;

    setsize(self,RACER_MIN * 0.5,RACER_MAX * 0.5);
    pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
    self.delay = time;
}


void racer_blowup()
{

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);

    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);
    RadiusDamage (self, self, 250, 15, 250, world, 250, DEATH_WAKIBLOWUP, world);

    self.alpha = -1;
    self.nextthink  = time + cvar("g_vehicle_racer_respawntime");
    self.think      = racer_spawn;
    self.movetype   = MOVETYPE_NONE;
    self.effects    = EF_NODRAW;

    self.avelocity_z  = 0;
    self.colormod = '0 0 0';

    setorigin(self,self.pos1);
}

void racer_dietouch()
{
    if(self.wait > time)
        return;

    self.wait = time + 0.75;

    pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
}

void racer_die()
{
    self.health       = 0;
    self.event_damage = SUB_Null;
    self.iscreature   = FALSE;
    self.solid        = SOLID_NOT;
    self.takedamage   = DAMAGE_NO;
    self.touch        = racer_dietouch;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.wait = time;

    pointparticles(particleeffectnum("rocket_explode"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity     += '0 0 128';

    if(random() < 0.5)
        self.avelocity_z  = 16;
    else
        self.avelocity_z  = -16;

    self.colormod = '-0.5 -0.5 -0.5';

	self.think     = racer_blowup;
	self.nextthink = time + 3;
}

void racer_dinit()
{

    tracebox(self.origin + '0 0 100', RACER_MIN * 0.5, RACER_MAX * 0.5, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
    setorigin(self,trace_endpos);

    if (self.netname == "")
        self.netname     = "Race PoD";

    self.cvar_basename      = "g_vehicle_racer";

    self.vehicle_viewport   = spawn();
    self.vehicle_hudmodel   = spawn();
    //self.ccamera            = spawn();

    setorigin(self, self.origin);

    setmodel(self,"models/vehicles/wakizashi.dpm");
    setmodel(self.vehicle_hudmodel, "models/vehicles/wakizashi_cockpit.dpm");
    setmodel (self.vehicle_viewport, "null");

    setattachment(self.vehicle_hudmodel, self, "");
    setattachment(self.vehicle_viewport, self, "tag_viewport");

    self.vehicle_hudmodel.viewmodelforclient = self;
    self.customizeentityforclient            = racer_customizeentityforclient;

    self.tur_head     = spawn();

    self.pos1         = self.origin;
    self.pos2         = self.angles;
    self.angles       = '0 0 0';
    self.angles       = self.pos1;

    self.vehicle_die  = racer_die;
    self.vehicle_exit = racer_exit;

    addstat(STAT_HUD, AS_INT,  hud);
	addstat(STAT_VEHICLESTAT_HEALTH,  AS_FLOAT, vehicle_health);
	addstat(STAT_VEHICLESTAT_SHIELD,  AS_FLOAT, vehicle_shield);
	addstat(STAT_VEHICLESTAT_ENERGY,  AS_FLOAT, vehicle_energy);

	addstat(STAT_VEHICLESTAT_AMMO1,   AS_INT,   vehicle_ammo1);
	addstat(STAT_VEHICLESTAT_RELOAD1, AS_FLOAT, vehicle_reload1);

	addstat(STAT_VEHICLESTAT_AMMO2,   AS_INT,   vehicle_ammo2);
	addstat(STAT_VEHICLESTAT_RELOAD2, AS_FLOAT, vehicle_reload2);

    racer_spawn();
}

void spawnfunc_vehicle_racer()
{
    g_turrets_common_precash();
    racer_loadsettings();

    self.vehicle_flags      = VHF_HASSHIELD | VHF_SHIELDREGEN;

    /*
    traceline(self.origin,self.origin - '0 0 2048',MOVE_WORLDONLY,self);
    if(trace_startsolid)
    {
        dprint("WARNING: vehicle_racer placed in solid\n");
        traceline(self.origin + '0 0 512' ,self.origin - '0 0 2048',MOVE_WORLDONLY,self);
        if(trace_startsolid || trace_fraction == 1.0)
        {
            dprint("ERROR: vehicle_racer placed in more then 512 units into solid\n");
            remove(self);
            return;
        }
    }
    */

    if(trace_fraction != 1.0)
        setorigin(self,trace_endpos + '0 0 128');
    else
        dprint("WARNING: vehicle_racer placed more then 2048 units above ground.\n");

    precache_model ("models/vehicles/wakizashi.dpm");
    precache_model ("models/vehicles/wakizashi_cockpit.dpm");
    precache_model ("maps/bspmodel.bsp");


    self.think = racer_dinit;
    self.nextthink = time + 1;
}
