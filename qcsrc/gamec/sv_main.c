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

	if (slowmoactive)
	{
		if (!slowmowasactive)
		{
			slowmowasactive = TRUE;
			slowmooldvalue = cvar("slowmo");
			s = strcat("slowmo ", ftos(slowmooldvalue * 0.25), "\n");
			localcmd(s);
		}
	}
	else
	{
		if (slowmowasactive)
		{
			slowmowasactive = FALSE;
			s = strcat("slowmo ", ftos(slowmooldvalue), "\n");
			localcmd(s);
		}
	}
	slowmoactive = FALSE;
}