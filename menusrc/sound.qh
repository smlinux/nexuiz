///////////////////////////////////////////////
// Sound Header File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all manager constants, etc.
///////////////////////////////////////////////
// constants

// complain if the vm is unable to load a file ?
const float SOUND_ENFORCELOADING = false;

// file names
const string SOUND_SELECT			= "misc/menu1.wav";
const string SOUND_CHANGE		 	= "misc/menu2.wav";
const string SOUND_ACTION			= "misc/menu3.wav";

//  prototypes

void(void) snd_init;
void(void) snd_toggle;
void(float keynr, float ascii)snd_keydown;
void(void) snd_frame;
void(void) snd_shutdown;

void(string sound_name) snd_play;

string(string sound_name, float complain) snd_loadsound;
void(string sound_name) snd_unloadsound;

