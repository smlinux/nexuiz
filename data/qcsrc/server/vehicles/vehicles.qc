void vehicle_stdproc_enter()
{
    self.owner = other;

    msg_entity = other;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.vehicle_viewport);

    WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
    WriteAngle(MSG_ONE, self.vehicle_viewport.angles_x + self.angles_x);    // tilt
    WriteAngle(MSG_ONE, self.vehicle_viewport.angles_y + self.angles_y);    // yaw
    WriteAngle(MSG_ONE, self.vehicle_viewport.angles_z + self.angles_z);    // flip

    //setattachment(other,self,"");
    self.nextthink = 0;
    self.owner.takedamage     = DAMAGE_NO;
    self.owner.solid          = SOLID_NOT;
    self.owner.alpha          = -1;
    //self.owner.PlayerPhysplug = spiderbot_pplug;
    self.owner.vehicle           = self;
    self.owner.event_damage   = SUB_Null;
    self.owner.vehicle_health             = (self.health / cvar("g_vehicle_spiderbot_health"));
    self.owner.hud            = HUD_SPIDEBOT;
    self.colormap             = self.owner.colormap;
    self.tur_head.colormap    = self.owner.colormap;
    self.vehicle_hudmodel.viewmodelforclient   = self.owner;
    //self.tur_head.nodrawtoclient = self.owner;


}

void vehicle_stdproc_exit(float eject)
{
    self.velocity = '0 0 0';

    msg_entity = self.owner;
    WriteByte (MSG_ONE, SVC_SETVIEWPORT);
    WriteEntity( MSG_ONE, self.owner);

    //setattachment(self.owner,world,"");
    //self.think = spiderbot_think;
    //self.nextthink = time;

    self.owner.takedamage     = DAMAGE_AIM;
    self.owner.solid          = SOLID_SLIDEBOX;
    self.owner.alpha          = 1;
    self.owner.PlayerPhysplug = SUB_Null;
    self.owner.vehicle        = world;
	self.owner.view_ofs       = PL_VIEW_OFS;
	self.owner.hud            = HUD_NORMAL;
	self.owner.event_damage   = PlayerDamage;
	self.colormap = 1024;
	self.tur_head.colormap = 1024;
	self.vehicle_hudmodel.viewmodelforclient   = self;
	//self.tur_head.nodrawtoclient = self;

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

void vehicle_stdproc_regen()
{
    float smax,hmax;

    smax = CCVAR("_shield");
    hmax = CCVAR("_health");

    if(self.vehicle_flags & VHF_HASSHIELD)
    if(self.vehicle_flags & VHF_SHIELDREGEN)
    if(self.vehicle_shield < smax)
    if(self.dmg_time + CCVAR("_shield_regen_dmgpause") < time)
    {
        self.vehicle_shield = min(self.vehicle_shield + CCVAR("_shield_regen") / server_fps,smax);

        if(self.owner)
            self.owner.vehicle_shield = self.vehicle_shield / cvar(strcat(self.cvar_basename,"_shield"));
    }

    if(self.vehicle_flags & VHF_HEALTHREGEN)
    if(self.dmg_time + CCVAR("_health_regen_dmgpause") < time)
    if(self.vehicle_health < hmax)
    {
        self.vehicle_health = min(self.vehicle_health + CCVAR("_health_regen") / server_fps,hmax);

        if(self.owner)
            self.owner.vehicle_health = self.vehicle_health / CCVAR("_health");
    }
}

void shieldhit_think()
{
    self.alpha = self.alpha - 0.125;
    if not(self.alpha <= 0)
    {
        self.nextthink = time;
    }
    else
    {
        setmodel(self,"");
        self.alpha = -1;
    }
    //self.think = SUB_Remove;
}

void vehicle_stdproc_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{

    float ddmg_take;

    self.dmg_time = time;

    if((self.vehicle_flags & VHF_HASSHIELD) && (self.vehicle_shield > 0))
    {
        if not (self.tur_head.enemy)
            self.tur_head.enemy = spawn();

        entity sh;

        sh = self.tur_head.enemy;
        sh.colormod = '1 1 1';
        sh.alpha = 0.5;
        sh.scale  = (128 / vlen(self.maxs - self.mins))*2;
        //sh.scale = 1.25;

        sh.effects = EF_LOWPRECISION;
        sh.angles = vectoangles(normalize(hitloc - self.origin)) - self.angles;

        setmodel(sh,"models/vhshield.md3");
        setattachment(sh,self,"");
        sh.think = shieldhit_think;
        sh.nextthink = time;


        self.vehicle_shield -= damage;
        if(self.vehicle_shield < 0)
        {
            sh.colormod = '10 0 -1';
            ddmg_take = fabs(self.vehicle_shield);
            self.vehicle_shield = 0;

            self.vehicle_health -= ddmg_take;
        }
    }
    else
        self.vehicle_health -= damage;


    if(self.owner)
    {
        self.owner.vehicle_health = self.vehicle_health / CCVAR("_health");

        if(self.vehicle_flags & VHF_HASSHIELD)
            self.owner.vehicle_shield = self.vehicle_shield / cvar(strcat(self.cvar_basename,"_shield"));

    }

    if(self.vehicle_health <= 0)
    {
        if(self.owner)
            self.vehicle_exit(VHEF_EJECT);

        self.vehicle_die();
    }


}

void bugmenot()
{
    self.vehicle_exit       = self.vehicle_exit;
    self.vehicle_enter      = self.vehicle_exit;
    self.vehicle_die        = self.vehicle_exit;
    self.vehicle_spawn      = self.vehicle_exit;
    self.vehicle_message    = self.vehicle_exit;
}
