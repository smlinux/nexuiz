void vehicle_stdproc_enter()
{
}

void vehicle_stdproc_exit(float eject)
{
}

void vehicle_stdproc_shiledregen(float rmax, float dt)
{
    if(self.vehicle_shield < rmax)
    if(self.dmg_time + CCVAR("_shield_regen_dmgpause") < time)
    {
        self.vehicle_shield = min(self.vehicle_shield + CCVAR("_shield_regen") * dt, rmax);

        if(self.owner)
            self.owner.vehicle_shield = self.vehicle_shield / rmax;
    }
}

void vehicle_stdproc_healthregen(float rmax, float dt)
{

    if(self.dmg_time + CCVAR("_health_regen_dmgpause") < time)
    if(self.vehicle_health < rmax)
    {
        self.vehicle_health = min(self.vehicle_health + CCVAR("_health_regen") * dt, rmax);

        if(self.owner)
            self.owner.vehicle_health = self.vehicle_health / rmax;
    }
}

void vehicle_stdproc_energyregen(float rmax, float dt)
{
    if(self.vehicle_energy < rmax)
    {
        self.vehicle_energy = min(self.vehicle_energy + CCVAR("_energy_regen") * dt, rmax);

        if(self.owner)
            self.owner.vehicle_energy = self.vehicle_energy / rmax;
    }
}

void shieldhit_think()
{
    self.alpha = self.alpha - 0.2;
    if (self.alpha <= 0)
    {
        setmodel(self,"");
        self.alpha = -1;
    }
    else
    {
        self.nextthink = time + 0.1;
    }
}

void vehicle_stdproc_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{

    float ddmg_take;

    self.dmg_time = time;

    if((self.vehicle_flags & VHF_HASSHIELD) && (self.vehicle_shield > 0))
    {

        if not (self.tur_head.enemy)
        {
            self.tur_head.enemy = spawn();
            self.tur_head.enemy.effects = EF_LOWPRECISION;
        }

        setmodel(self.tur_head.enemy,"models/vhshield.md3");
        setattachment(self.tur_head.enemy,self,"");

        self.tur_head.enemy.colormod = '1 1 1';
        self.tur_head.enemy.alpha = 0.45;
        self.tur_head.enemy.scale  = (256 / vlen(self.maxs - self.mins));
        self.tur_head.enemy.angles = vectoangles(normalize(hitloc - self.origin)) - self.angles;
        self.tur_head.enemy.think = shieldhit_think;
        self.tur_head.enemy.nextthink = time;

        self.vehicle_shield -= damage;
        if(self.vehicle_shield < 0)
        {
            self.tur_head.enemy.colormod = '10 0 -1';
            ddmg_take = fabs(self.vehicle_shield);
            self.vehicle_shield = 0;
            self.tur_head.enemy.alpha = 0.75;
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
            if(self.vehicle_flags & VHF_DEATHEJECT)
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
    //self.vehicle_message    = self.vehicle_exit;
}
