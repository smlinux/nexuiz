///////////////////////////////////////////////
// Graphic Header File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all gfx prototypes, etc.
///////////////////////////////////////////////

const float GFX_WIDTH = 800;
const float GFX_HEIGHT = 600;

float vid_conwidth;
float vid_conheight;

////////////////
// prototypes
///

void(void) gfx_init;
void(void) gfx_frame;
void(void) gfx_toggle;
void(float keynr, float ascii) gfx_keydown;// perhaps we want to do some special fx for specail keys
void(void) gfx_draw;
void(void) gfx_shutdown;

// convert from menu coords to gfx coords
vector(vector vec) gfx_conmentogfx;
// convert from gfx coords to console coords
vector(vector vec) gfx_converttocon;
// convert from console coords to gfx coords
vector(vector vec) gfx_converttogfx;
// convert to menu coords
vector(vector vec) gfx_congfxtomen;

string(string pic_name, float complain) gfx_loadpic;
void(string pic_name) gfx_unloadpic;

void(vector position, float character, vector scale, vector rgb, float alpha, float flag)
gfx_drawchar;

void(vector position, string text, vector scale, vector rgb, float alpha, float flag)
gfx_drawstring;

void(vector position, string pic_name, vector size, vector rgb, float alpha, float flag)
gfx_drawpic;

void(vector position, vector size, vector rgb, float alpha, float flag)
gfx_fillarea;

void(vector position, vector size) gfx_setcliparea;

void(void) gfx_resetcliparea;

void(vector position, float character, vector scale, vector rgb, float alpha, float flag)
menu_drawchar;

void(vector position, string text, vector scale, vector rgb, float alpha, float flag)
menu_drawstring;

void(vector position, string pic_name, vector size, vector rgb, float alpha, float flag)
menu_drawpic;

void(vector position, vector size, vector rgb, float alpha, float flag)
menu_fillarea;

void(vector position, vector size) menu_setcliparea;

void(void) menu_resetcliparea;

vector(string pic_name) gfx_getimagesize;

