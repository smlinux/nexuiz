///////////////////////////////////////////////
// Functions Header File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all menu controlling stuff (sub-menus)
///////////////////////////////////////////////

////////////////
// prototypes
///

// some gfx helper functions
float(float tfactor) getflicker;

void(void)	def_refresh;
void(float keynr, float ascii) def_keyevent;

// default control functions - assign only to the _* event functions
// (assigning to the 'normal' event functions will crash the vm !)
// are used by ITEM_CUSTOM and can be used to test new ITEMs easily
void(void)  defct_reinit;
void(void)	defct_destroy;
void(float keynr, float ascii)  defct_key;
void(void)	defct_draw;
void(void)	defct_mouse_enter;
void(void)	defct_mouse_leave;
void(void)	defct_action;
void(void) 	defct_refresh;

// use this to raise an event from another item or function
void(entity ent)  raise_reinit;
void(entity ent)  raise_destroy;
void(entity ent, float keynr, float ascii)  raise_key;
void(entity ent)  raise_draw;
void(entity ent)  raise_mouse_enter;
void(entity ent)  raise_mouse_leave;
void(entity ent)  raise_action;
void(entity ent)  raise_refresh;

// safe call the normal control functions (only used by the mcontrols function)
void(void)	ctcall_init;
void(void)	ctcall_reinit;
void(void)	ctcall_destroy;
float(float keynr, float ascii)  ctcall_key;
void(void)	ctcall_draw;
void(void)	ctcall_mouse_enter;
void(void)	ctcall_mouse_leave;
void(void)	ctcall_action;
void(void)	ctcall_refresh;

// control event function initializer
void(void(void) reinitevent, void(void) destroyevent, void(float key, float ascii) keyevent, void(void) drawevent, void(void) mouse_enterevent, void(void) mouse_leaveevent, void(void) actionevent, void(void) refreshevent)
	item_init;

float(vector point, vector r_xy, vector r_size) inrect;

// clips are rectangle against a clip area
// cliprectsize returns '0 0 0' if it is clipped totally
vector(vector r_pos, vector r_size, vector c_pos, vector c_size) cliprectpos;
vector(vector r_pos, vector r_size, vector c_pos, vector c_size) cliprectsize;

// used to extract 'string' strings from a normal string
float(string s) getaltstringcount;
string(float c, string s) getaltstring;
