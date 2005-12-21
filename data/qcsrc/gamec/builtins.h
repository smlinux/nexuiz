
void	makevectors (vector ang)							= #1;
void	setorigin (entity e, vector o)							= #2;
void	setmodel (entity e, string m)							= #3;
void	setsize (entity e, vector min, vector max)					= #4;

void	crash (void)									= #6;
float	random (void)									= #7;
//void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector	normalize (vector v)								= #9;
void	error (string e)								= #10;
void	objerror (string e)								= #11;
float	vlen (vector v)									= #12;
float	vectoyaw (vector v)								= #13;
entity	spawn (void)									= #14;
void	remove (entity e)								= #15;
void	traceline (vector v1, vector v2, float nomonst, entity forent)			= #16;
entity	checkclient (void)								= #17;
entity	find (entity start, .string fld, string match)					= #18;
string	precache_sound (string s)							= #19;
string	precache_model (string s)							= #20;
//void(entity client, string s)stuffcmd = #21;
entity	findradius (vector org, float rad)						= #22;
void	bprint (string s, ...)								= #23;
//void(entity client, string s) sprint = #24;
void	dprint (string s, ...)								= #25;
string	ftos (float f)									= #26;
string	vtos (vector v)									= #27;
void	coredump (void)									= #28;
void	traceon (void)									= #29;
void	traceoff (void)									= #30;
void	eprint (entity e)								= #31;
float	walkmove (float yaw, float dist)						= #32;

float	droptofloor (float yaw, float dist)						= #34;
void	lightstyle (float style, string value)						= #35;
float	rint (float v)									= #36;
float	floor (float v)									= #37;
float	ceil (float v)									= #38;

float	checkbottom (entity e)								= #40;
float	pointcontents (vector v)							= #41;

float	fabs (float f)									= #43;
//vector(entity e, float speed) aim = #44;
float	cvar (string s)									= #45;
void	localcmd (string s)								= #46;
entity	nextent (entity e)								= #47;
void	particle (vector v, vector d, float colour, float count)			= #48;
void	ChangeYaw (void)								= #49;

vector	vectoangles (vector v)								= #51;
//void(float to, float f) WriteByte		= #52;
//void(float to, float f) WriteCoord		= #56;
void	movetogoal (float step)								= #67;
string	precache_file (string s)							= #68;
void	makestatic (entity e)								= #69;
void	changelevel (string s)								= #70;

void	cvar_set (string var, string val)						= #72;
//void(entity client, string s) centerprint = #73;
void	ambientsound (vector pos, string samp, float vol, float atten)			= #74;
string	precache_model2 (string s)							= #75;
string	precache_sound2 (string s)							= #76;
string	precache_file2 (string s)							= #77;
entity(.float fld, float match) findchainflags = #450;