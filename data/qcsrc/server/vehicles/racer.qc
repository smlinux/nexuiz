#define RACER_MIN '-40 -40 0'
#define RACER_MAX '40 40 44'

void racer_exit(float eject);
void racer_enter();

float  jetfromtag_power;
float  jetfromtag_normpower;
float  jetfromtag_nosolid;
vector jetfromtag_origin;

vector jetfromtag(string tagname,float jet_length,float air_power,float solid_power)
{
    vector force_dir;
    float  air_frac, solid_frac, air_pwr, solid_pwr;

    jetfromtag_origin = gettaginfo(self,gettagindex(self,tagname));
    v_forward = normalize(v_forward);

    force_dir = jetfromtag_origin - v_forward * jet_length;
    traceline(jetfromtag_origin, force_dir, MOVE_NORMAL, self);

    solid_frac = 1 - trace_fraction;
    air_frac   = trace_fraction;

    if(solid_frac < 0.1)
        jetfromtag_nosolid += 1;

    solid_pwr = solid_frac * solid_power;
    air_pwr   = air_frac * air_power;

    jetfromtag_power     = solid_pwr + air_pwr;
    jetfromtag_normpower = jetfromtag_power / (air_power+solid_power);
    if(trace_fraction == 1)
        return v_forward;
    else
        return v_forward * (jetfromtag_power + cvar("g_vehicle_racer_power_min"));
}

void racer_align4point(float spring_length,float spring_up,float blendrate)
{
    vector fl_org,fl_force,fr_org,fr_force,bl_org,bl_force,br_org,br_force;
    vector push_vector,align;
    float fl_push, fr_push, bl_push, br_push;

    jetfromtag_nosolid = 0;

    fr_force = jetfromtag("tag_engine_fr",spring_length,cvar("g_vehicle_racer_power_air"), cvar("g_vehicle_racer_power_solid"));
    fr_org   = jetfromtag_origin; fr_push = jetfromtag_normpower;

    fl_force = jetfromtag("tag_engine_fl",spring_length,cvar("g_vehicle_racer_power_air"), cvar("g_vehicle_racer_power_solid"));
    fl_org   = jetfromtag_origin; fl_push = jetfromtag_normpower;

    br_force = jetfromtag("tag_engine_br",spring_length,cvar("g_vehicle_racer_power_air"), cvar("g_vehicle_racer_power_solid"));
    br_org   = jetfromtag_origin; br_push = jetfromtag_normpower;

    bl_force = jetfromtag("tag_engine_bl",spring_length,cvar("g_vehicle_racer_power_air"), cvar("g_vehicle_racer_power_solid"));
    bl_org   = jetfromtag_origin; bl_push = jetfromtag_normpower;

    push_vector = fr_force + fl_force + br_force + bl_force;

    align = align;

    align_x = (fl_push - bl_push);
    align_x += (fr_push - br_push);
    align_x *= 360;

    align_z = (fl_push - fr_push);
    align_z += (bl_push - br_push);
    align_z *= 360;

    self.angles_x *= 0.96;
    self.angles_z *= 0.96;

    self.angles_x += align_x * frametime;
    self.angles_z += align_z * frametime;

    self.velocity =  self.velocity + (push_vector * frametime);
    self.velocity_z -= sv_gravity * frametime;
}

void racer_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    self.velocity += force;
}

float racer_pplug()
{
    entity player,racer;
    float ftmp,ftmp2;


    player = self;
    racer = self.vehicle;
    player.fixangle = FALSE;

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

    racer.angles_x *= -1;
    makevectors(racer.angles);
    racer.angles_x *= -1;

    // Turn Body
    ftmp = cvar("g_vehicle_racer_turnspeed") / server_fps;
    ftmp2 = ftmp * -1;

    ftmp = bound(ftmp2,shortangle_f(player.v_angle_y - racer.angles_y,racer.angles_y),ftmp);

    {
        racer.angles_y = safeangle(racer.angles_y + ftmp);
        if(player.BUTTON_JUMP)
        {
            player.BUTTON_JUMP = 0;
            racer.velocity  = racer.velocity  + v_forward * 250 + v_up * 600;
        }
        else
        {
            if(vlen(player.movement) == 0)
            {
                self = racer;
                ftmp = self.velocity_z;
                self.velocity = self.velocity - self.velocity * cvar("g_vehicle_racer_speed_stop");
                self.velocity_z = ftmp;
            }
            else
            {

                if(player.movement_x != 0)
                {
                    if(player.movement_x > 0)
                        player.movement_x = 1;
                    else if(player.movement_x < 0)
                        player.movement_x = -1;
                }

                if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                        player.movement_y = -1;
                    else if(player.movement_y > 0)
                        player.movement_y = 1;
                }

                self = racer;
                self.velocity  = self.velocity + ((v_right * player.movement_y) * cvar("g_vehicle_racer_speed_strafe")) * frametime;
                self.velocity  = self.velocity + ((v_forward * player.movement_x) * cvar("g_vehicle_racer_speed_forward")) * frametime;
            }
        }
        self = racer;
    }

    vector df;

    self = racer;

    df = vlen(self.velocity) * cvar("g_vehicle_racer_downforce") * v_up;
    self.velocity = self.velocity - df;
    player.movement = racer.velocity;
    racer_align4point(cvar("g_vehicle_racer_springlength"),100,cvar("g_vehicle_racer_inert"));

    if(cvar("g_vehicle_racer_drag"))
        self.velocity  = movelib_dragvec(cvar("g_vehicle_racer_drag"),cvar("g_vehicle_racer_dragexp"));

    self = player;
    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    setorigin(player,racer.origin + '0 0 32');
    player.velocity = racer.velocity;

    return 1;
}

void racer_think()
{
    movelib_beak_simple(cvar("g_vehicle_racer_speed_stop"));

    self.nextthink = time;
}

void racer_enter()
{
    self.owner = other;
    self.owner.angles = self.angles;

    //setattachment(other,self,"");
    self.nextthink = 0;
    self.think = SUB_Null;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.solid          = SOLID_NOT;
    self.owner.movetype       = MOVETYPE_NOCLIP;
    //setsize(self.owner,spiderbot_MIN,spiderbot_MAX);
    self.owner.alpha          = -1;
    self.owner.PlayerPhysplug = racer_pplug;
    self.owner.vehicle        = self;
    self.owner.event_damage   = SUB_Null;
    //self.event_damage         = vehicle_stdproc_damage ;
    self.colormap             = self.owner.colormap;
    //self.tur_head.colormap    = self.owner.colormap;
    //self.vehicle_hudmodel.viewmodelforclient = self.owner;
    //self.owner.hud            = HUD_SPIDEBOT;
    //self.owner.vehicle_health = (self.vehicle_health / cvar("g_vehicle_spiderbot_health"));
    //self.owner.vehicle_shield = (self.vehicle_shield / cvar("g_vehicle_spiderbot_shield"));

    //setorigin(self.owner,self.origin);
    //setattachment(self.owner,self,"");
    //setorigin(self.owner,'0 0 0');

    msg_entity = other;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.vehicle_viewport);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE,  self.angles_x);    // tilt
    WriteAngle(MSG_ONE,  self.angles_y);    // yaw
    WriteAngle(MSG_ONE,  0);                // roll

    //self.owner.view_ofs = '0 0 0';
    //self.tur_head.nodrawtoclient = self.owner;
}

void racer_exit(float eject)
{
    self.velocity = '0 0 0';

    msg_entity = self.owner;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.owner);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
    WriteAngle(MSG_ONE,  0);                // tilt
    WriteAngle(MSG_ONE,  self.angles_y);    // yaw
    WriteAngle(MSG_ONE,  0);                // roll

    self.think = racer_think;
    self.nextthink = time;

    self.owner.takedamage     = DAMAGE_AIM;
    self.owner.solid          = SOLID_SLIDEBOX;
    self.owner.movetype       = MOVETYPE_WALK;

    setsize(self.owner,PL_MIN,PL_MAX);

    self.owner.alpha          = 1;
    self.owner.PlayerPhysplug = SUB_Null;
    self.owner.vehicle        = world;
	self.owner.view_ofs       = PL_VIEW_OFS;
	self.owner.event_damage   = PlayerDamage;
	//self.owner.hud            = HUD_NORMAL;

	self.colormap            = 1024;
	//self.tur_head.colormap = 1024;

	//self.vehicle_hudmodel.viewmodelforclient = self;
	//self.tur_head.nodrawtoclient             = self;
    setattachment(self.owner,world,"");

	if(eject)
	{
	    makevectors(self.angles);
	    setorigin(self.owner,self.origin + v_forward * 100);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	}
	else
        setorigin(self.owner,self.origin + '0 0 64' - v_forward * 200);

    self.owner = world;
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

void racer_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force);
void racer_spawn()
{
    self.think = racer_think;
    self.nextthink = time;

    //self.vehicle_health = CCVAR("_health");
    //self.vehicle_shield = CCVAR("_shield");
    //self.event_damage = vehicle_stdproc_damage;
    self.event_damage = racer_damage;
    //self.iscreature = TRUE;
    self.scale = 0.5;
    self.movetype   = MOVETYPE_FLY;
    self.solid      = SOLID_SLIDEBOX;
    //self.takedamage = DAMAGE_AIM;
    self.touch      = racer_touch;
    //self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = 1;
    self.alpha = 1;
    //self.tur_head.angles = '0 0 0';
	//self.colormap = 1024;
	//self.tur_head.colormap = 1024;
	self.deadflag    = DEAD_NO;
    self.bot_attack = TRUE;
    setorigin(self,self.origin + '0 0 128');
    setsize(self,RACER_MIN*0.5,RACER_MAX*0.5);
    setorigin(self,self.tur_aimpos);
    pointparticles(particleeffectnum("teleport"), self.origin + '0 0 64', '0 0 0', 1);
}

void racer_blowup()
{
    /*
    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    pointparticles(particleeffectnum("rocket_explode"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    //RadiusDamage (self, self.owner, self.owner.shot_dmg, self.owner.shot_dmg * 0.5, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);
    RadiusDamage (self, self, 250, 15, 250, world, 250, DEATH_TURRET, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = -1;
    self.nextthink  = time + 10;
    self.think      = spiderbot_spawn;

    setorigin(self,self.tur_aimpos);
    */
}

void racer_die()
{

    /*
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
	*/
}

void racer_dinit()
{

    server_fps = (1 / sys_ticrate);

    /*
    addstat(STAT_HUD, AS_INT,  hud);
	addstat(STAT_SPIDERBOT_ROCKETS, AS_INT,   rockets);
	addstat(STAT_SPIDERBOT_RELOAD,  AS_FLOAT, rockets_reload);
	addstat(STAT_SPIDERBOT_HEAT,    AS_FLOAT, vehicle_heat);
	addstat(STAT_SPIDERBOT_HEALTH,  AS_FLOAT, vehicle_health);
	addstat(STAT_SPIDERBOT_SHIELD,  AS_FLOAT, vehicle_shield);
	*/

    if (self.netname == "")      self.netname     = "Race PoD";

    self.vehicle_viewport = spawn();
    self.event_damage = racer_damage;
    //self.gravity = 2;
    //self.vehicle_hudmodel = spawn();
    //self.vehicle_flags = VHF_HASSHIELD | VHF_SHIELDREGEN | VHF_HEALTHREGEN;
    //self.cvar_basename = "g_vehicle_spiderbot";

    setmodel (self.vehicle_viewport, "models/null.md3");
    setmodel(self,"models/racers/waka.dpm");

    setattachment(self.vehicle_viewport,self,"");
    //self.tur_head.customizeentityforclient = spiderbot_customizeentityforclient;

    setorigin(self.vehicle_viewport,'-400 0 40');
    self.tur_aimpos = self.origin;
    racer_spawn();

    //self.vehicle_die = spiderbot_die;
    //self.vehicle_exit = spiderbot_exit;
}

void spawnfunc_racer()
{
    g_turrets_common_precash();

    precache_model ( "models/racers/waka.dpm");

    self.think = racer_dinit;
    self.nextthink = time + 0.5;
}
