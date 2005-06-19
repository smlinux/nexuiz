
// Globals

entity	activator;
string	string_null;

//entity	casing;
entity dest;

// Fields

.void(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) event_damage;

//.string	wad;
//.string	map;

//.float	worldtype;
.float	delay;
.float	wait;
.float	lip;
//.float	light_lev;
.float	speed;
//.float	style;
//.float	skill;

.string killtarget;

.vector	pos1, pos2;
.vector	mangle;

.float	jump_flag;				// storing velocity_z for falling damage
.float	attack_finished;
.float	pain_finished;			//Added by Supajoe
.float	pain_frame;			//"
.float	statdraintime;			// record the one-second intervals between draining health and armour when they're over 100
.float  crouch;	// Crouching or not?

.float	strength_finished;
//.float	speed_finished;
.float	invincible_finished;
//.float	slowmo_finished;

.vector		finaldest, finalangle; 		//plat.qc stuff
.void()		think1;
.float state;
.float		t_length, t_width;

.vector destvec;		// for rain
.float cnt;		// for rain
.float count;
//.float cnt2;

.float death_time;
.float dead_time;
.float dead_frame;
.float die_frame;
.float fade_time;
.float fade_rate;

.string mdl;

.string playermodel;
.string playerskin;

.float	respawntime;
//.float	chasecam;

.float electrocount;
//.float crylinkcount;

.float	damageforcescale;

//.float          gravity;

.float		dmg;

// for railgun damage (hitting multiple enemies)
.float railgunhit;
.float railgunhitsolidbackup;
.vector railgunhitloc;

.float		air_finished;
.float		dmgtime;

.float		killcount;

// definistions for weaponsystem

.entity weaponentity;
.entity exteriorweaponentity;
.float switchweapon;
void(float wpn, float wrequest) weapon_action;
float(entity cl, float wpn, float andammo) client_hasweapon;
void() w_clear;
// VorteX: standalone think for weapons, so normal think on weaponentity can be reserved by weaponflashes (which needs update even player dies)
.float weapon_nextthink;
.void() weapon_think;
.vector shotdir, shotorg; // new generic aiming system for all weapons (not finished yet, can be removed)
float	weapon_hasammo; // sets by WR_CHECKAMMO request

//float	PLAYER_WEAPONSELECTION_DELAY = );
float	PLAYER_WEAPONSELECTION_SPEED = 18;
vector	PLAYER_WEAPONSELECTION_RANGE = '0 20 -40';

// weapon states (self.weaponentity.state)
float WS_CLEAR			= 0; // no weapon selected
float WS_RAISE			= 1; // raise frame
float WS_DROP			= 2; // deselecting frame
float WS_INUSE			= 3; // fire state
float WS_READY			= 4; // idle frame

// weapon requests
float WR_SETUP		  = 1;	// setup weapon data
float WR_UPDATECOUNTS = 2;  // update ammo display
float WR_IDLE		  = 3;  // idle frame
float WR_DROP		  = 4;	// deselect frame
float WR_RAISE		  = 5;	// select frame
float WR_FIRE1		  = 6;  // primary fire frame
float WR_FIRE2		  = 7;  // secondary fire
float WR_FIRE3		  = 8;  // third fire
float WR_CHECKAMMO	  = 9;  // checks ammo for weapon
float WR_CLEAR		  = 10;  // runs afted deselecting frames, remove weapon parts (if presented). This useful for quake3-style chaingun

// Weapon indexes
float WEP_LASER				= 1; // float	IT_LASER				= 4096;
float WEP_SHOTGUN			= 2; // float	IT_SHOTGUN				= 1;
float WEP_UZI				= 3; // float	IT_UZI					= 2;
float WEP_GRENADE_LAUNCHER	= 4; // float	IT_GRENADE_LAUNCHER		= 4;
float WEP_ELECTRO			= 5; // float	IT_ELECTRO				= 8;
float WEP_CRYLINK			= 6; // float	IT_CRYLINK				= 16;
float WEP_NEX				= 7; // float	IT_NEX					= 32;
float WEP_HAGAR				= 8; // float	IT_HAGAR				= 64;
float WEP_ROCKET_LAUNCHER	= 9; // float	IT_ROCKET_LAUNCHER		= 128;

// For weapon cycling commands
float WEP_FIRST				= 1;
float WEP_LAST				= 9;

void(entity e, float chan, string samp, float vol, float atten) sound = #8;
void(entity client, string s)	stuffcmd = #21;
void(entity client, string s)	sprint = #24;
vector(entity e, float sped)	aim = #44;
void(entity client, string s)	centerprint = #73;
void(entity e)			setspawnparms = #78;
void(float to, float f)		WriteByte = #52;
void(float to, float f)		WriteChar = #53;
void(float to, float f)		WriteShort = #54;
void(float to, float f)		WriteLong = #55;
void(float to, float f)		WriteCoord = #56;
void(float to, float f)		WriteAngle = #57;
void(float to, string s)	WriteString	= #58;
void(float to, entity s)	WriteEntity	= #59;
.vector dest1, dest2;
void(entity clent) dropclient = #453;