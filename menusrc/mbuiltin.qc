//////////////////////////////////////////////////
// common cmd
//////////////////////////////////////////////////
// AK FIXME: Create perhaps a special builtin file for the common cmds

void 	checkextension(string ext) = #1;

// error cmds
void 	error(string err,...) 	= #2;
void 	objerror(string err,...) 	= #3;

// print

void 	print(string text,...) 	= #4;
void 	bprint(string text,...)	= #5;
void	sprint(float clientnum, string text,...) = #6;
void 	centerprint(string text,...) = #7;

// vector stuff

vector	normalize(vector v) 	= #8;
float 	vlen(vector v)			= #9;
float  	vectoyaw(vector v)		= #10;
vector 	vectoangles(vector v)	= #11;

float	random(void)  = #12;

void	cmd(string command) = #13;

// cvar cmds

float 	cvar(string name) = #14;
const string str_cvar(string name) = #71;
void	cvar_set(string name, string value) = #15;

void	dprint(string text,...) = #16;

// conversion functions

string	ftos(float f)  = #17;
float	fabs(float f)	= #18;
string	vtos(vector v)  = #19;
string	etos(entity e) = #20;

float	stof(string val,...)  = #21;

entity	spawn(void) = #22;
void	remove(entity e) = #23;

entity	findstring(entity start, .string field, string match)  = #24;
entity	findfloat(entity start, .float field, float match) = #25;
entity	findentity(entity start, .entity field, entity match) = #25;

entity	findchainstring(.string field, string match) = #26;
entity	findchainfloat(.float field, float match) = #27;
entity	findchainentity(.entity field, entity match) = #27;

string	precache_file(string file) = #28;
string	precache_sound(string sample) = #29;

void	crash(void)	= #72;
void	coredump(void) = #30;
void	traceon(void) = #31;
void	traceoff(void) = #32;

void	eprint(entity e)  = #33;
float	rint(float f) = #34;
float	floor(float f)  = #35;
float	ceil(float f)  = #36;
entity	nextent(entity e)  = #37;
float	sin(float f)  = #38;
float	cos(float f)  = #39;
float	sqrt(float f)  = #40;
vector	randomvec(void)  = #41;

float	registercvar(string name, string value)  = #42; // returns 1 if success
float	min(float f,...)  = #43;
float	max(float f,...)  = #44;
float	bound(float min,float value, float max)  = #45;
float	pow(float a, float b)  = #46;
void	copyentity(entity src, entity dst)  = #47;

float	fopen(string filename, float mode)  = #48;
void	fclose(float fhandle)  = #49;
string	fgets(float fhandle)  = #50;
void	fputs(float fhandle, string s)  = #51;

float	strlen(string s)  = #52;
string	strcat(string s1,string s2,...)  = #53;
string	substring(string s, float start, float length)  = #54;

vector	stov(string s)  = #55;

string	strzone(string s)  = #56;
void	strunzone(string s) = #57;

float	tokenize(string s)  = #58
string	argv(float n)  = #59;

float	isserver(void)  = #60;
float	clientcount(void)  = #61;
float	clientstate(void)  = #62;
void	clientcommand(float client, string s)  = #63;
void	changelevel(string map)  = #64;
void	localsound(string sample)  = #65;
vector	getmousepos(void)  	= #66;
float	gettime(void)		= #67;
void 	loadfromdata(string data) = #68;
void	loadfromfile(string file) = #69;

float	mod(float val, float m) = #70;

/////////////////////////////////////////////////
// Write* Functions
/////////////////////////////////////////////////
void	WriteByte(float data, float dest, float desto)	= #401;
void	WriteChar(float data, float dest, float desto)	= #402;
void	WriteShort(float data, float dest, float desto)	= #403;
void	WriteLong(float data, float dest, float desto)	= #404;
void	WriteAngle(float data, float dest, float desto)	= #405;
void	WriteCoord(float data, float dest, float desto)	= #406;
void	WriteString(string data, float dest, float desto)= #407;
void	WriteEntity(entity data, float dest, float desto) = #408;

//////////////////////////////////////////////////
// Draw funtions
//////////////////////////////////////////////////

float	iscachedpic(string name)	= #451;
string	precache_pic(string name)	= #452;
void	freepic(string name)		= #453;

float	drawcharacter(vector position, float character, vector scale, vector rgb, float alpha, float flag) = #454;

float	drawstring(vector position, string text, vector scale, vector rgb, float alpha, float flag) = #455;

float	drawpic(vector position, string pic, vector size, vector rgb, float alpha, float flag) = #456;

float	drawfill(vector position, vector size, vector rgb, float alpha, float flag) = #457;

void	drawsetcliparea(float x, float y, float width, float height) = #458;

void	drawresetcliparea(void) = #459;

vector  drawgetimagesize(string pic) = #460;

////////////////////////////////////////////////
// Menu functions
////////////////////////////////////////////////

void	setkeydest(float dest) 	= #601;
float	getkeydest(void)	= #602;

void	setmousetarget(float trg) = #603;
float	getmousetarget(void)	  = #604;

float	isfunction(string function_name) = #607;
void	callfunction(...) = #605;
void	writetofile(float fhandle, entity ent) = #606;

