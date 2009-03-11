/**
    Simulate drag
    self.velocity = movelib_vdrag(self.velocity,0.02,0.5);
**/
vector movelib_dragvec(float drag, float exp)
{
    float lspeed,ldrag;

    lspeed = vlen(self.velocity);
    ldrag = lspeed * drag;
    ldrag = ldrag * (drag * exp);
    ldrag = 1 - (ldrag / lspeed);

    return self.velocity * ldrag;
}

/**
    Simulate drag
    self.velocity = movelib_vdrag(somespeed,0.01,0.7);
**/
float movelib_dragflt(float fspeed,float drag,float exp)
{
    float ldrag;

    ldrag = fspeed * drag;
    ldrag = ldrag * ldrag * exp;
    ldrag = 1 - (ldrag / fspeed);

    return ldrag;
}

/**
    Do a inertia simulation based on velocity.
    Basicaly, this allows you to simulate objects loss steering with speed.
    self.velocity = movelib_inertia_fromspeed(self.velocity,newvel,1000,0.1,0.9);
**/
vector movelib_inertmove_byspeed(vector vel_new, float vel_max,float newmin,float oldmax)
{
    float influense;

    influense = vlen(self.velocity) * (1 / vel_max);

    influense = bound(newmin,influense,oldmax);

    return (vel_new * (1 - influense)) + (self.velocity * influense);
}

vector movelib_inertmove(vector new_vel,float new_bias)
{
    return new_vel * new_bias + self.velocity * (1-new_bias);
}

.float  movelib_lastupdate;
void movelib_move(vector force,float max_velocity,float drag,float mass,float breakforce)
{
    float deltatime;
    float acceleration;
    //float mspeed;

    deltatime = time - self.movelib_lastupdate;
    if (deltatime > 0.15) deltatime = 0;
    self.movelib_lastupdate = time;
    if(!deltatime) return;

    //mspeed = vlen(self.velocity);

    if(mass)
        acceleration = vlen(force) / mass;
    else
        acceleration = vlen(force);

    if(self.flags & FL_ONGROUND)
    {
        if(breakforce)
        {
            breakforce = 1 - ((breakforce / mass) * deltatime);
            self.velocity = self.velocity * breakforce;
        }

        self.velocity = self.velocity + force * (acceleration * deltatime);
    }

    self.velocity = self.velocity + '0 0 -1' * sv_gravity * deltatime;

    if(drag)
        self.velocity = movelib_dragvec(drag, 1);

    if(max_velocity)
    if(vlen(self.velocity) > max_velocity)
        self.velocity = normalize(self.velocity) * max_velocity;
}

void movelib_move_simple(vector newdir,float velo,float turnrate)
{
    vector olddir;

    olddir = normalize(self.velocity);

    self.velocity = normalize(olddir + newdir * turnrate) * velo;
}

/*
vector movelib_accelerate(float force)
{
    vector vel;
    vel = self.velocity;
    vel = normalize(vel) * (vlen(vel) + force);
    self.velocity = self.velocity  + vel;
}


vector movelib_decelerate(float force,float mass)
{
    vector vel;
    float decel;

    if(mass)
        decel = force / mass;
    else
        decel = force;

    vel = self.velocity;
    vel = normalize(vel) * max((vlen(vel) - decel),0);
    self.velocity = self.velocity - vel;

    if(vlen(self.velocity) < 5) self.velocity = '0 0 0';
}
*/
vector movelib_velocity_transfer(entity source,entity destination)
{
    return '0 0 0';
}
