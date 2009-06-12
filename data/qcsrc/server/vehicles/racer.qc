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
    //dprint("dd:",vtos(v_forward)," - ",vtos(force_dir),"\n");

    force_dir = jetfromtag_origin - v_forward * jet_length;
    traceline(jetfromtag_origin, force_dir, MOVE_NORMAL, self);
    //te_lightning1(world,jetfromtag_origin,force_dir);

    solid_frac = 1 - trace_fraction;
    air_frac   = trace_fraction;

    if(solid_frac < 0.1)
        jetfromtag_nosolid += 1;

    //if(solid_frac < 0.5)
        //solid_frac = solid_frac * solid_frac;
        //solid_frac = solid_frac * 1.5;

    solid_pwr = solid_frac * solid_power;
    air_pwr   = air_frac * air_power;

    //float pmax;
    //pmax = air_power+solid_power;
    //pmax = min(pmax,max(self.velocity_z * cvar("g_vehicle_racer_powerfac"),800));
    //jetfromtag_power     = min(solid_pwr + air_pwr,max(self.velocity_z * cvar("g_vehicle_racer_powerfac"),800));
    jetfromtag_power     = solid_pwr + air_pwr;
    jetfromtag_normpower = jetfromtag_power / (air_power+solid_power);
    if(trace_fraction == 1)
        return v_forward;
    else
        return v_forward * (jetfromtag_power + cvar("g_vehicle_racer_power_min"));

    // - (v_forward * cvar("g_vehicle_racer_springk"));
}

/*
vector jetfromtag2(string tagname,float jet_length,float air_power,float solid_power)
{
    vector force_dir;
    float  solid_frac, solid_pwr;

    jetfromtag_origin = gettaginfo(self,gettagindex(self,tagname));
    v_forward = normalize(v_forward);

    force_dir = jetfromtag_origin - v_forward * jet_length;
    traceline(jetfromtag_origin, force_dir, MOVE_NORMAL, self);

    if(trace_fraction == 1)
    {
        jetfromtag_power     = 0;
        jetfromtag_normpower = 0;
        return v_forward * 0.1;
    }

    float pwr_up,pwr_down;

    pwr_up = (1 - trace_fraction);
    pwr_down = (trace_fraction * -1);

    jetfromtag_power = pwr_up + pwr_down;
    jetfromtag_normpower = jetfromtag_power / solid_power;
    return v_forward * jetfromtag_power;



}
*/

void racer_align4point(float spring_length,float spring_up,float blendrate)
{
    vector fl_org,fl_force,fr_org,fr_force,bl_org,bl_force,br_org,br_force;
    vector push_vector,align;
    //vector c1,c2;
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
    //c1 = (fr_org + fl_org + br_org + bl_org) - (self.origin *4);

    /*
    vector vtmp;
    vtmp =  normalize((fr_org + fr_force) - self.origin);
    vtmp += normalize((br_org + br_force) - self.origin);
    vtmp += normalize((fl_org + fl_force) - self.origin);
    vtmp += normalize((bl_org + bl_force) - self.origin);
    //vtmp = vtmp * 0.25;
    */
    //dprint("a1:",vtos(vtmp)," a2",vtos(vtmp - self.angles),"\n");
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
    //c1 = normalize(self.velocity);
    //c2 = normalize(push_vector - self.velocity);
   // dprint("VR: ",vtos(c2),"\n");
    //if(c2_z == -1)
    //    push_vector_z *= 5;

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

    //if(racer.flags & FL_ONGROUND)
    {
        racer.angles_y = safeangle(racer.angles_y + ftmp);
        //player.angles = racer.angles;
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
                //movelib_beak_simple(cvar("g_vehicle_racer_speed_stop"));
                ftmp = self.velocity_z;
                self.velocity = self.velocity - self.velocity * cvar("g_vehicle_racer_speed_stop");
                self.velocity_z = ftmp;
            }
            else
            {

                if(player.movement_x != 0)
                {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                    }
                }

                if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                    {
                        player.movement_y = -1;
                    }
                    else if(player.movement_y > 0)
                    {
                        player.movement_y = 1;
                    }
                }

                self = racer;
                self.velocity  = self.velocity + ((v_right * player.movement_y) * cvar("g_vehicle_racer_speed_strafe")) * frametime;
                self.velocity  = self.velocity + ((v_forward * player.movement_x) * cvar("g_vehicle_racer_speed_forward")) * frametime;
            }
        }
        self = racer;
    }

    vector df;
    df = vlen(self.velocity) * cvar("g_vehicle_racer_downforce") * v_up;
    //te_lightning1(self,self.origin,self.origin - df);
    self.velocity = self.velocity - df;

    player.movement = racer.velocity;
    self = racer;
    racer_align4point(cvar("g_vehicle_racer_springlength"),100,cvar("g_vehicle_racer_inert"));

    if(cvar("g_vehicle_racer_drag"))
        self.velocity  = movelib_dragvec(cvar("g_vehicle_racer_drag"),cvar("g_vehicle_racer_dragexp"));



    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    self = player;
    setorigin(player,racer.origin);
    player.velocity = racer.velocity;

    //player.v_angle = racer.angles;
    //player.v_angle_x *= -1;

    /*
    msg_entity = player;
    player.angles = racer.angles;
    //player.fixangle = TRUE;
    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);  // 10 = SVC_SETVIEWANGLES
    //WriteAngle(MSG_ONE, player.v_angle_x - (racer.angles_x * -1));    // tilt
    WriteAngle(MSG_ONE, racer.angles_x * -1);    // tilt
    WriteAngle(MSG_ONE, player.v_angle_y);    // yaw
    WriteAngle(MSG_ONE, (racer.angles_z + player.v_angle_z) * 0.5);    // flip
    */

    return 1;
}

void racer_think()
{
    //if(self.flags & FL_ONGROUND)
    //{
        movelib_beak_simple(cvar("g_vehicle_racer_speed_stop"));
        //racer_align4point(300,100);
    //}
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
    //self.colormap             = self.owner.colormap;
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
    WriteAngle(MSG_ONE,  self.angles_z);    // flip

    //self.owner.view_ofs = '0 0 0';
    //self.tur_head.nodrawtoclient = self.owner;
}

void racer_exit(float eject)
{
    self.velocity = '0 0 0';

    msg_entity = self.owner;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.owner);

    //setattachment(self.owner,world,"");
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
	//self.owner.hud            = HUD_NORMAL;
	self.owner.event_damage   = PlayerDamage;

	//self.colormap            = 1024;
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
        setorigin(self.owner,self.origin - v_forward * 200);

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
        //dprint("a:",vtos(a),"\n");

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
float spiderbot_customizeentityforclient()
{
    if(self.deadflag == DEAD_DEAD)
        return FALSE;
    if(self.owner == other)
        self.tur_head.alpha = -1;
    else
        self.tur_head.alpha = 1;
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
    //self.event_damage = spiderbot_damage;
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

    setorigin(self.vehicle_viewport,'-400 0 40  ');
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
/*
onClipEvent (load) {
	// inertia relates to the quantity of energy that
	// the spring will carry
	// inertia = 1 would mean that the spring doesn't
	// loose any energy, and that it will oscillate
	// forever
	inertia = 0.9 ;

	// k relates to the spring, and how "hard" it will be.
	// The higher k the faster the mass will come back.
	k = 0.1 ;
}

onClipEvent (enterFrame) {

	// We calculate the distance to the mouse
	x = -this._x + _root._xmouse ;
	y = -this._y + _root._ymouse ;

	//We calculate the amount by which the mass will to move
	xp = xp * inertia + x*k ;
	yp = yp * inertia + y*k ;

	//We move it
	_x += xp ;
	_y += yp ;
}
*/

/*
.float inertia;
.float k;
.float mass;
.entity springtarget;
//.float dt;
void func_spring_think()
{

    float deltatime;
    deltatime = time - other.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    other.lastpushtime = time;
    if(!pushdeltatime) return;


    vector dist;
    //vector move;
    dist = (self.springtarget.origin *-1) + self.origin;
    dist = '-1 -1 -1' * vlen(self.springtarget.origin - self.origin);
    self.springtarget.velocity_x *= self.inertia + dist_x * self.k;
    self.springtarget.velocity_y *= self.inertia + dist_y * self.k;
    self.springtarget.velocity_z *= self.inertia + dist_z * self.k;

    self.nextthink = time;
}

void func_spring_init()
{
    self.springtarget = find(world, targetname, self.target);
    if(!self.springtarget)
    {
        objerror("func_spring cant find its .target!\n");
        remove(self);
        return;
    }
    self.think = func_spring_think;
    self.nextthink = time;
}

void springtarget_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    dprint("Smack!\n");
    self.velocity = self.velocity +force;
}

void spawnfunc_func_springtarget()
{
	self.mdl = self.model;
	setmodel(self, self.mdl);

	self.effects |= EF_LOWPRECISION;
	setsize (self, self.mins , self.maxs);
    self.movetype = MOVETYPE_BOUNCE;
    setorigin(self,self.origin);
    self.solid = SOLID_BSP;
    self.takedamage = DAMAGE_YES;
    self.event_damage = springtarget_damage;
    dprint("spawnfunc_func_springtarget!\n");
}

void spawnfunc_func_spring()
{
    if(self.target == "")
    {
        objerror("func_spring w/o target!\n");
        //remove(self);
        return;
    }

    if(!self.inertia)
        self.inertia = 0.9;

    if(!self.k)
        self.k = 0.1;

    if(!self.mass)
        self.mass = 1;

	self.mdl = self.model;
	setmodel(self, self.mdl);

	self.effects |= EF_LOWPRECISION;
	setsize (self, self.mins , self.maxs);
	self.movetype = MOVETYPE_FLY;
	self.think = func_spring_init;
	self.nextthink = time +1;
	dprint("spawnfunc_func_spring!\n");

}
*/
