/*
* Trow a turret gib
*/
void turret_gib_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.velocity += vforce;
}

void turret_trowgib(
    vector v_from, vector v_to, vector v_colormod,
    string smodel,
    float f_lifetime, float f_fadetime, float b_burn)
{
    local entity gib;
    local entity burn;

    gib = spawn();

    gib.classname = "turret_gib";
    setmodel(gib,smodel);
    setorigin(gib,v_from);
    SUB_SetFade(gib,time + f_lifetime,2);

    gib.solid              = SOLID_BBOX;

    gib.movetype           = MOVETYPE_BOUNCE;
    gib.takedamage         = DAMAGE_YES;
    gib.event_damage       = turret_gib_damage;
    gib.health             = -1;
    gib.effects            = EF_LOWPRECISION;
    gib.flags              = FL_NOTARGET;
    gib.colormod           = v_colormod;
    gib.velocity           = v_to;

    if (b_burn)
    {
        burn = spawn();
        burn.effects        = EF_LOWPRECISION;//|EF_FLAME;
        setattachment(burn,gib,"");
        setorigin(burn,(gib.mins + gib.maxs) * 0.5);
        SUB_SetFade(burn,time + (f_lifetime * 0.5) ,2);
    }
}

void turret_gib_boom()
{
    entity gib;
    float i;
    string s;

    for (i = 1; i < 5; i = i +1)
    {
        gib = spawn();
        gib.classname = "turret_gib";

        s = strcat("models/turrets/head-gib",ftos(i));
        s = strcat(s,".md3");
        // bprint("s:",s,"\n");
        setmodel(gib,s);

        setorigin(gib,self.origin);

        SUB_SetFade(gib,time + 5,2);

        gib.solid              = SOLID_BBOX;

        gib.movetype           = MOVETYPE_BOUNCE;
        gib.gravity            = 0.5;
        gib.damageforcescale   = 2;
        gib.takedamage         = DAMAGE_YES;
        gib.event_damage       = turret_gib_damage;
        gib.health             = -1;
        gib.effects            = EF_LOWPRECISION;
        gib.flags              = FL_NOTARGET;
        gib.velocity           = self.velocity + (randomvec() * 700);
        gib.avelocity          = randomvec() * 64;
    }

    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, 78);
    WriteCoord (MSG_BROADCAST, self.origin_x);
    WriteCoord (MSG_BROADCAST, self.origin_y);
    WriteCoord (MSG_BROADCAST, self.origin_z);

    remove(self);
}

void turret_trowgib2(
    vector v_from, vector v_to, vector v_colormod,
    entity e_mimic, float boomtime)
{
    entity gib;

    gib = spawn();

    gib.classname = "turret_gib";
    setmodel(gib,e_mimic.model);
    setorigin(gib,v_from);

    gib.solid              = SOLID_BBOX;

    gib.movetype           = MOVETYPE_BOUNCE;
    gib.gravity            = 0.75;
    gib.damageforcescale   = 2;
    gib.takedamage         = DAMAGE_YES;
    gib.event_damage       = turret_gib_damage;
    gib.health             = -1;
    gib.effects            = EF_LOWPRECISION;
    gib.flags              = FL_NOTARGET;
    gib.colormod           = v_colormod;
    gib.velocity           = v_to;
    gib.avelocity          = randomvec() * 32;
    gib.think              = turret_gib_boom;
    gib.nextthink          = boomtime;
    //gib.effects            = EF_FLAME;


}
/*
* Spawn a boom, trow fake bits arround
* and hide the real ones.
*/
void turret_stdproc_die()
{
    vector org2;
    vector t_dir;

    self.deadflag           = DEAD_DEAD;
    self.tur_head.deadflag  = self.deadflag;

    sound (self, CHAN_PLAYER, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = self.origin + '0 0 40';

// Explotion grafix
    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, 78);
    WriteCoord (MSG_BROADCAST, org2_x);
    WriteCoord (MSG_BROADCAST, org2_y);
    WriteCoord (MSG_BROADCAST, org2_z);

// Unsolidify and hide real parts
    self.solid              = SOLID_NOT;
    self.tur_head.solid     = self.solid;

    self.alpha             = -1;
    self.tur_head.alpha    = self.alpha;
    self.customizeentityforclient = SUB_False;
    self.tur_head.customizeentityforclient = SUB_False;

    self.event_damage           = SUB_Null;
    self.takedamage             = DAMAGE_NO;

    self.effects            = 0;
    self.tur_head.effects   = self.effects;
    self.health             = 0;

// Trow fake parts arround
    // base
    if not(self.damage_flags & TFL_DMG_DEATH_NOGIBS)
    {
        makevectors(self.angles);
        if (random() > 0.5)
        {
            turret_trowgib(self.origin, '0 0 0','1 1 1',"models/turrets/base-gib2.md3",min(self.respawntime,20),1,1);
            t_dir = (v_up * 700) + (randomvec() * 300);
            turret_trowgib(self.origin, t_dir,'1 1 1',"models/turrets/base-gib3.md3",min(self.respawntime,10),1,1);
            t_dir = (v_up * 700) + (randomvec() * 300);
            turret_trowgib(self.origin, t_dir,'1 1 1',"models/turrets/base-gib4.md3",min(self.respawntime,10),1,1);
        }
        else
        {
            turret_trowgib(self.origin, '0 0 0','1 1 1',"models/turrets/base-gib1.md3",min(self.respawntime,20),1,1);
        }

        // Blow the top part up into the air
        turret_trowgib2( self.origin + (v_up * 50),
                         v_up * 150 + randomvec() * 50,
                         '0.2 0.2 0.2',
                         self.tur_head,time + 0.5 + (random() * 0.5));
    }

// Go boom
    //RadiusDamage (self,self, min(self.ammo,50),min(self.ammo,50) * 0.25,250,world,min(self.ammo,50)*5,DEATH_TURRET,world);

    if(self.damage_flags & TFL_DMG_DEATH_NORESPAWN)
    {
        if (self.turret_diehook)
            self.turret_diehook();

        remove(self.tur_head);
        remove(self);
    }
    else
    {
    // Setup respawn
        self.nextthink      = time + self.respawntime;
        //self.think          = self.turret_spawnfunc;
        self.think          = turret_stdproc_respawn;
        if (self.turret_diehook)
            self.turret_diehook();
    }

}

void turret_stdproc_respawn()
{
    // Make sure all parts belong to the same team since
    // this function doubles as "teamchange" function.

    self.tur_head.team = self.team;

    /*
    COLOR_TEAM1       = 4;  // red
    COLOR_TEAM2       = 13; // blue
    COLOR_TEAM3       = 12; // yellow
    COLOR_TEAM4       = 9; // pink
    */

	self.colormod = '0 0 0';

	switch(self.team)
	{
        case COLOR_TEAM1: // Red
            self.colormod = '1.4 0.8 0.8';
            break;

        case COLOR_TEAM2: // Blue
            self.colormod = '0.8 0.8 1.4';
            break;

        case COLOR_TEAM3: // Yellow
            self.colormod = '1.4 1.4 0.6';
            break;

        case COLOR_TEAM4: // Pink
            self.colormod = '1.4 0.6 1.4';
            break;
	}

    self.deadflag           = DEAD_NO;
    self.effects            = 0;
    self.tur_head.effects   = self.effects;

    self.solid              = SOLID_BBOX;

    self.alpha = 1;
    self.tur_head.alpha     = self.alpha;
    self.customizeentityforclient = SUB_True;
    self.tur_head.customizeentityforclient = SUB_True;

    self.takedamage = DAMAGE_AIM;
    self.event_damage           = turret_stdproc_damage;

    self.avelocity              = '0 0 0';
    self.tur_head.avelocity     = self.avelocity;
    self.tur_head.angles        = self.idle_aim;
    self.health                 = self.tur_health;

    self.enemy                  = world;
    self.volly_counter          = self.shot_volly;
    self.ammo                   = self.ammo_max;

    self.nextthink  = time + self.ticrate;
    self.think      = turret_think;

    if (self.turret_respawnhook)
        self.turret_respawnhook();

}

/*
* Standard damage proc.
*/
void turret_stdproc_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{

    // Enougth allready!
    if (self.health <= 0)
        return;

    // Inactive turrets take no damage. (hm..)
    if not (self.tur_active)
        return;

    if (teamplay != 0)
    if (self.team == attacker.team)
    {
        // This does not happen anymore. Re-enable if you fix that.
        if(clienttype(attacker) == CLIENTTYPE_REAL)
            sprint(attacker, "\{1}Turret tells you: I'm on your team!\n");

        if(cvar("g_friendlyfire"))
            damage = damage * cvar("g_friendlyfire");
        else
            return;
    }

    self.health = self.health - damage;

    // thorw head slightly off aim when hit?
    if (self.damage_flags & TFL_DMG_HEADSHAKE)
    {
        //baseent.tur_aimoff_x += (random() * damage);
        //baseent.tur_aimoff_y += ((random()*0.75) * damage);
        self.tur_head.angles_x = self.tur_head.angles_x + (-0.5 + random()) * damage;
        self.tur_head.angles_y = self.tur_head.angles_y + (-0.5 + random()) * damage;
    }

    if (self.turrcaps_flags & TFL_TURRCAPS_MOVE)
        self.velocity = self.velocity + vforce;

    // FIXME: Better damage feedback
    // Start burning when we have 10% or less health left
    //if (self.health < (self.tur_health * 0.1))
    //    self.effects = EF_FLAME;

    if (self.health <= 0)
    {
        self.event_damage           = SUB_Null;
        self.tur_head.event_damage  = SUB_Null;
        self.takedamage             = DAMAGE_NO;
        self.nextthink = time;
        self.think = turret_stdproc_die;
    }
}
