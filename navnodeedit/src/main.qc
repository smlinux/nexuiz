void() main = {};

void() precaches =
{
	precache_model ("progs/beam.mdl");
	precache_model ("progs/bolt.mdl");
	precache_model ("progs/plane.mdl");
	precache_model ("progs/org.mdl");
	precache_model ("progs/org2.mdl");
	precache_model ("progs/null.spr");
	precache_model ("progs/navnode.spr");
	precache_model ("progs/point.spr");
};

void() worldspawn =
{
	precaches ();
	LightStyles_setup();
};

void() SetNewParms = {};

void() SetChangeParms = {};

void() StartFrame =
{
	sv_gravity = cvar("sv_gravity");
	sv_maxspeed = cvar("sv_maxspeed");
	sv_friction = cvar("sv_friction");
	sv_accelerate = cvar("sv_accelerate");
	sv_stopspeed = cvar("sv_stopspeed");
};