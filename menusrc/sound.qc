///////////////////////////////////////////////
// Sound Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all manager constants, etc.
///////////////////////////////////////////////

void(void) snd_init =
{
	snd_loadsound(SOUND_SELECT, SOUND_ENFORCELOADING);
	snd_loadsound(SOUND_CHANGE, SOUND_ENFORCELOADING);
	snd_loadsound(SOUND_ACTION, SOUND_ENFORCELOADING);
};

void(void) snd_frame =
{
};

void(void) snd_toggle =
{
};

void(float keynr, float ascii) snd_keydown =
{
};

void(void) snd_shutdown =
{
	snd_unloadsound(SOUND_SELECT);
	snd_unloadsound(SOUND_CHANGE);
	snd_unloadsound(SOUND_ACTION);
};

void(string sound_name) snd_play =
{
	localsound(sound_name);
};

string(string sound_name, float complain) snd_loadsound =
{
	string c;

	c = precache_sound(sound_name);

	if(c == "" && complain)
		error("Couldn't load ", sound_name, " !\n");
	return c;
};

void(string sound_name) snd_unloadsound =
{
	// FIXME: there is now free/unload sound at the moment
	// at least non that works the way it should
};

