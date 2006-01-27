
// Globals

entity	activator;
string	string_null;

//entity	casing;
//entity dest;

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

.vector dest1;
.vector dest2;
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

// not part of weapon requests, but almost was, thus the naming convention
float WR_GRENADE1	  = 11;
float WR_GRENADE2	  = 12;

// Weapon indexes
float WEP_LASER				=  1; // float	IT_LASER				= 4096;
float WEP_SHOTGUN			=  2; // float	IT_SHOTGUN				= 1;
float WEP_UZI				=  3; // float	IT_UZI					= 2;
float WEP_GRENADE_LAUNCHER	=  4; // float	IT_GRENADE_LAUNCHER		= 4;
float WEP_ELECTRO			=  5; // float	IT_ELECTRO				= 8;
float WEP_CRYLINK			=  6; // float	IT_CRYLINK				= 16;
float WEP_NEX				=  7; // float	IT_NEX					= 32;
float WEP_HAGAR				=  8; // float	IT_HAGAR				= 64;
float WEP_ROCKET_LAUNCHER	=  9; // float	IT_ROCKET_LAUNCHER		= 128;
float WEP_BOMBLETTS			= 10;
float WEP_ROCKET_INCENDIARY	= 11;
float WEP_FLAMER			= 12;
float WEP_HOTBOMBS			= 13;
float WEP_GRAPPLE			= 14;
float WEP_NAMEK				= 15;
float WEP_RAILGUN			= 16;
float WEP_HEALGUN			= 17;
float WEP_MAC				= 18;
float WEP_PISTOL			= 19;

float WEP_SCOUT_SPECIAL		= 50;
float WEP_SPY_SPECIAL		= 51;
float WEP_SOLDIER_SPECIAL	= 52;
float WEP_PYRO_SPECIAL		= 53;
float WEP_MEDIC_SPECIAL		= 54;
float WEP_ENGINEER_SPECIAL	= 55;

float WEP_GRENADE_MIRV		= 60;
float WEP_GRENADE_FRAG		= 61;

float WEP1	= 1;
float WEP2	= 2;
float WEP3	= 3;
float WEP4	= 4;
float WEP5	= 5;

// For weapon cycling commands
float WEP_FIRST				= 1;
float WEP_LAST				= 5;//9;







// class definitions

float	CLASS_SCOUT		=  1;
float	CLASS_SPY		=  2;
float	CLASS_SOLDIER	=  4;
float	CLASS_PYRO		=  8;
float	CLASS_MEDIC		= 16;
float	CLASS_ENGINEER	= 32;

.float team_no;

.float	class;
.float	max_health;
.float	max_armor;
.float	mass;
.float	wpn;	// the weapon that's in the slot I've selected
.entity	wpn5;	// what weapon I'm holding in my extra (5th) slot
//.float	oldclass;
.string change_mdl_on_respawn; // for changing class after death

.float	special_active;
.float	special_time;

.float	grenade_time;

.float	jump_pad;	// true if just hit a jump pad (don't slow player when jump pads launch him)

.entity onfire;		// world if not on fire, otherwise points to entity burning you
.float flame_heat;	// starts at 0.  Being near someone on fire raises it.  When it hits 1, the flame spreads to you.
.float flame_heat_time; // set when near a fire so code elsewhere knows to heat up instead of cool down

.float	poison_damage;	// total damage poison will deal over time
.float	poison_rate;	// how fast to deal the poison

.float create_time;	// tracks the time an entity was created to we can know which
					// is the oldest when limiting the player's # of turrets or
					// hotbombs, for example


.float buttonuse;	// 1 if player is using +use


// health regen/rot
.float	health_regen_delay;
.float	health_rot_delay;
.float	armor_regen_delay;
.float	armor_rot_delay;

void DelayHealthRegen(entity e);
void DelayHealthRot(entity e);
void DelayArmorRegen(entity e);
void DelayArmorRot(entity e);


// grappling hook
.entity		hook;
void GrapplingHookFrame();
void RemoveGrapplingHook(entity pl);



string NameOfClass(float cl);
float GetPlayerClass();
void ResetPlayerModel(entity pl);
void SetPlayerSpeed(entity pl);


// entity limiting function, to limit # of bombs etc a player can have.
float W_LimitNumEnts(string clname, float num_allowed, void() DeathFunc);

// functions to let players cross lasergates
void PlayerLasergatePreThink();
void PlayerLasergatePostThink();

void SpyCloakFlicker(entity pl);

// BH Test Var
.float air_time;