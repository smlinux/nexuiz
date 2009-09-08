.float      shot_speed_max;
.float      shot_speed_gain;

void spawnfunc_turret_hellion();
void turret_hellion_dinit();
void turret_hellion_attack();
void turret_hellion_missile_explode();
void turret_hellion_missile_think();
void turret_hellion_missile_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)

void turret_hellion_postthink()
{
    if (cvar("g_turrets_reloadcvars"))
    {
        if (!self.shot_speed_max)  self.shot_speed_max  = cvar("g_turrets_unit_hellion_std_shot_speed_max");
        if (!self.shot_speed_gain) self.shot_speed_gain = cvar("g_turrets_unit_hellion_std_shot_speed_gain");
    }

    if (self.tur_head.frame != 0)
        self.tur_head.frame = self.tur_head.frame + 1;

    if (self.tur_head.frame > 7)
        self.tur_head.frame = 0;
}

void turret_hellion_attack()
{
    local entity missile;

    sound (self, CHAN_WEAPON, "weapons/hagar_fire.wav", VOL_BASE, ATTN_NORM);

    // switch tubes
    //self.tur_shotorg_y = self.tur_shotorg_y * -1;

    missile = spawn ();
    setorigin(missile, self.tur_shotorg);
    setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

    missile.classname          = "hellion_missile";
    missile.owner              = self;
    missile.bot_dodge          = TRUE;
    missile.bot_dodgerating    = self.shot_dmg;
    missile.takedamage         = DAMAGE_YES;
    missile.event_damage       = turret_hellion_missile_damage;
    missile.damageforcescale   = 2;
    missile.health             = 10;
    missile.enemy              = self.enemy;
    missile.think              = turret_hellion_missile_think;
    missile.nextthink          = time;// + 0.2;
    missile.solid              = SOLID_BBOX;
    missile.movetype           = MOVETYPE_FLY;
    missile.velocity           = normalize(self.tur_shotdir_updated + randomvec() * self.shot_spread) * self.shot_speed;
    missile.angles             = vectoangles(missile.velocity);
    missile.touch              = turret_hellion_missile_explode;
    missile.flags              = FL_PROJECTILE;
    missile.solid              = SOLID_BBOX;
    missile.tur_health         = time + 9;
    missile.tur_aimpos         = randomvec() * 128;
    te_explosion (missile.origin);

	CSQCProjectile(missile, FALSE, PROJECTILE_ROCKET, FALSE); // no culling, has fly sound

    if (self.tur_head.frame == 0)
        self.tur_head.frame = self.tur_head.frame + 1;

}

void turret_hellion_missile_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector vforce)
{
    self.health = self.health - damage;
    self.velocity = self.velocity + vforce;
    if (self.health <= 0) turret_hellion_missile_explode();
}

void turret_hellion_missile_think()
{
    vector olddir,newdir;
    vector pre_pos;
    float itime;

    self.nextthink = time + 0.05;

    olddir = normalize(self.velocity);

    if(self.tur_health < time)
        turret_hellion_missile_explode();

    // Enemy dead? just keep on the current heading then.
    if ((self.enemy == world) || (self.enemy.deadflag != DEAD_NO))
    {

        // Make sure we dont return to tracking a respawned player
        self.enemy = world;

        // Turn model
        self.angles = vectoangles(self.velocity);

        if ( (vlen(self.origin - self.owner.origin)) > (self.owner.shot_radius * 5) )
            turret_hellion_missile_explode();

        // Accelerate
        self.velocity = olddir * min(vlen(self.velocity) * self.owner.shot_speed_gain,self.owner.shot_speed_max);

        UpdateCSQCProjectile(self);

        return;
    }

    // Enemy in range?
    if (vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 0.2)
        turret_hellion_missile_explode();

    // Predict enemy position
    itime = vlen(self.enemy.origin - self.origin) / vlen(self.velocity);
    pre_pos = self.enemy.origin + self.enemy.velocity * itime;

    pre_pos = (pre_pos + self.enemy.origin) * 0.5;

    // Find out the direction to that place
    newdir = normalize(pre_pos - self.origin);

    // Turn
    newdir = normalize(olddir + newdir * 0.35);

    // Turn model
    self.angles = vectoangles(self.velocity);

    // Accelerate
    self.velocity = newdir * min(vlen(self.velocity) * self.owner.shot_speed_gain,self.owner.shot_speed_max);

    if (itime < 0.05)
        self.think = turret_hellion_missile_explode;

    UpdateCSQCProjectile(self);
}

void turret_hellion_missile_explode()
{
    vector org2;
    float d;

    if(self.event_damage != SUB_Null)
    {
        self.event_damage = SUB_Null;
        self.think = turret_hellion_missile_explode;
        self.nextthink = time;
        return;
    }

    sound (self, CHAN_PROJECTILE, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
    org2 = findbetterlocation (self.origin, 16);

    // LordHavoc: TE_TEI_BIGEXPLOSION
    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, 78);
    WriteCoord (MSG_BROADCAST, org2_x);
    WriteCoord (MSG_BROADCAST, org2_y);
    WriteCoord (MSG_BROADCAST, org2_z);

    //w_deathtypestring = "could not dodge the twin missiles.";
    self.event_damage = SUB_Null;
    d = RadiusDamage (self, self.owner, self.owner.shot_dmg, 0, self.owner.shot_radius, world, self.owner.shot_force, DEATH_TURRET, world);

#ifdef TURRET_DEBUG
    self.owner.tur_dbg_dmg_t_h = self.owner.tur_dbg_dmg_t_h + d; //self.owner.shot_dmg;
    self.owner.tur_dbg_dmg_t_f = self.owner.tur_dbg_dmg_t_f + self.owner.shot_dmg;
#endif

    // Target dead, get another is still targeting the same.
    if ((self.enemy.deadflag != DEAD_NO) && (self.enemy == self.owner.enemy))
        self.owner.enemy = world;

    remove (self);
}

void turret_hellion_dinit()
{
    if (self.netname == "")      self.netname  = "Hellion Missile Turret";

    if not (self.shot_speed_max)
        self.shot_speed_max  = cvar("g_turrets_unit_hellion_std_shot_speed_max");

    if not (self.shot_speed_gain)
        self.shot_speed_gain = cvar("g_turrets_unit_hellion_std_shot_speed_gain");

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MISSILEKILL;
    self.aim_flags = TFL_AIM_SIMPLE;
    self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK ;
    self.firecheck_flags = TFL_FIRECHECK_WORLD | TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_TEAMCECK | TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_AFF | TFL_FIRECHECK_OWM_AMMO;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;

    if (turret_stdproc_init("hellion_std",0,"models/turrets/base.md3","models/turrets/hellion.md3") == 0)
    {
        remove(self);
        return;
    }

    if (!turret_tag_setup())
        dprint("Warning: Turret ",self.classname, " faild to initialize md3 tags\n");

    self.turret_firefunc  = turret_hellion_attack;
    self.turret_postthink = turret_hellion_postthink;
}

/*QUAKED turret_hellion (0 .5 .8) ?
*/
void spawnfunc_turret_hellion()
{
    precache_model ("models/turrets/hellion.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_hellion_dinit;
    self.nextthink = time + 0.5;
}


