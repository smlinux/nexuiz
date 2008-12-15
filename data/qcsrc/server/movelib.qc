/**
    Simulate drag
    self.velocity = movelib_vdrag(self.velocity,0.02,0.5);
**/
vector movelib_drag(float drag, float exp)
{
    float lspeed,ldrag;

    lspeed = vlen(self.velocity);
    ldrag = lspeed * drag;
    ldrag = ldrag * drag * exp;
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


/**
    Applies absolute force to a velocity
**/
vector movelib_accelerate(vector vel,float force)
{
    return normalize(vel) * (vlen(vel) + force);
}
vector movelib_decelerate(vector vel,float force)
{
    return normalize(vel) * (vlen(vel) - force);
}

vector movelib_velocity_transfer(entity source,entity destination)
{
    return '0 0 0';
}
