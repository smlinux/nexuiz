/*
=============
StartFrame

Called before each frame by the server
=============
*/
float slowmoactive;
float slowmowasactive;
float slowmooldvalue;
void StartFrame (void)
{
	local string s;
	sv_maxspeed = cvar ("sv_maxspeed");
	sv_friction = cvar ("sv_friction");
	sv_accelerate = cvar ("sv_accelerate");
	sv_stopspeed = cvar ("sv_stopspeed");
	teamplay = cvar ("teamplay");

	BotFrame ();
	CheckRules ();
}