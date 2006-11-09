/*
=============
StartFrame

Called before each frame by the server
=============
*/
void StartFrame (void)
{
	sv_maxairspeed = cvar("sv_maxairspeed");
	sv_maxspeed = cvar ("sv_maxspeed");
	sv_friction = cvar ("sv_friction");
	sv_accelerate = cvar ("sv_accelerate");
	sv_stopspeed = cvar ("sv_stopspeed");
	teamplay = cvar ("teamplay");

	CheckRules_World ();
}