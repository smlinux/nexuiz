/*
=============
StartFrame

Called before each frame by the server
=============
*/
void StartFrame (void)
{
	sv_maxspeed = cvar ("sv_maxspeed");
	sv_friction = cvar ("sv_friction");
	sv_accelerate = cvar ("sv_accelerate");
	sv_stopspeed = cvar ("sv_stopspeed");

	cl_rollangle = cvar ("cl_rollangle") * 4;
	cl_divspeed = 1 / cvar ("cl_rollspeed");

	BotFrame ();
}