
float	FALSE					= 0;
float	TRUE					= 1;

float	FL_FLY					= 1;
float	FL_SWIM					= 2;
float	FL_CLIENT				= 8;
float	FL_INWATER				= 16;
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;
float	FL_NOTARGET				= 128;
float	FL_ITEM					= 256;
float	FL_ONGROUND				= 512;
float	FL_PARTIALGROUND		= 1024;
float	FL_WATERJUMP			= 2048;
float	FL_JUMPRELEASED			= 4096;
float	FL_WEAPON				= 8192;

float	MOVETYPE_NONE			= 0;
float	MOVETYPE_ANGLENOCLIP	= 1;
float	MOVETYPE_ANGLECLIP		= 2;
float	MOVETYPE_WALK			= 3;
float	MOVETYPE_STEP			= 4;
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;
float	MOVETYPE_PUSH			= 7;
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;
float	MOVETYPE_BOUNCE			= 10;
//float	MOVETYPE_BOUNCEMISSILE	= 11;	// Like bounce but doesn't lose speed on bouncing
//float	MOVETYPE_FOLLOW			= 12;	// 'Attaches' the entity to its aim_ent

float	SOLID_NOT				= 0;
float	SOLID_TRIGGER			= 1;
float	SOLID_BBOX				= 2;
float	SOLID_SLIDEBOX			= 3;
float	SOLID_BSP				= 4;
//float	SOLID_CORPSE			= 5;	// Unobstructed by CORPSE or SLIDEBOX

float	DEAD_NO					= 0;
float	DEAD_DYING				= 1;
float	DEAD_DEAD				= 2;
float	DEAD_RESPAWNABLE		= 3;

float	DAMAGE_NO				= 0;
float	DAMAGE_YES				= 1;
float	DAMAGE_AIM				= 2;

float	CONTENT_EMPTY			= -1;
float	CONTENT_SOLID			= -2;
float	CONTENT_WATER			= -3;
float	CONTENT_SLIME			= -4;
float	CONTENT_LAVA			= -5;
float	CONTENT_SKY				= -6;

float	SVC_BAD					= 0;
float	SVC_NOP					= 1;
float	SVC_DISCONNECT			= 2;
float	SVC_UPDATESTAT			= 3;
float	SVC_VERSION				= 4;
float	SVC_SETVIEW				= 5;
float	SVC_SOUND				= 6;
float	SVC_TIME				= 7;
float	SVC_PRINT				= 8;
float	SVC_STUFFTEXT			= 9;
float	SVC_SETANGLE			= 10;
float	SVC_SERVERINFO			= 11;
float	SVC_LIGHTSTYLE			= 12;
float	SVC_UPDATENAME			= 13;
float	SVC_UPDATEFRAGS			= 14;
float	SVC_CLIENTDATA			= 15;
float	SVC_STOPSOUND			= 16;
float	SVC_UPDATECOLORS		= 17;
float	SVC_PARTICLE			= 18;
float	SVC_DAMAGE				= 19;
float	SVC_SPAWNSTATIC			= 20;
float	SVC_SPAWNBINARY			= 21;
float	SVC_SPAWNBASELINE		= 22;
float	SVC_TEMPENTITY			= 23;
float	SVC_SETPAUSE			= 24;
float	SVC_SIGNONNUM			= 25;
float	SVC_CENTERPRINT			= 26;
float	SVC_KILLEDMONSTER		= 27;
float	SVC_FOUNDSECRET			= 28;
float	SVC_SPAWNSTATICSOUND	= 29;
float	SVC_INTERMISSION		= 30;
float	SVC_FINALE				= 31;
float	SVC_CDTRACK				= 32;
float	SVC_SELLSCREEN			= 33;
float	SVC_CUTSCENE			= 34;

float	TE_SPIKE				= 0;
float	TE_SUPERSPIKE			= 1;
float	TE_GUNSHOT				= 2;
float	TE_EXPLOSION			= 3;
float	TE_TAREXPLOSION			= 4;
float	TE_LIGHTNING1			= 5;
float	TE_LIGHTNING2			= 6;
float	TE_WIZSPIKE				= 7;
float	TE_KNIGHTSPIKE			= 8;
float	TE_LIGHTNING3			= 9;
float	TE_LAVASPLASH			= 10;
float	TE_TELEPORT				= 11;

float	CHAN_AUTO				= 0;
float	CHAN_WEAPON				= 1;
float	CHAN_VOICE				= 2;
float	CHAN_ITEM				= 3;
float	CHAN_BODY				= 4;
float	CHAN_IMPACT				= 5;

float	ATTN_NONE				= 0;
float	ATTN_NORM				= 0.5;
float	ATTN_IDLE				= 2;
float	ATTN_STATIC				= 3;

float	UPDATE_GENERAL			= 0;
float	UPDATE_STATIC			= 1;
float	UPDATE_BINARY			= 2;
float	UPDATE_TEMP				= 3;

float	EF_BRIGHTFIELD			= 1;
float	EF_MUZZLEFLASH			= 2;
float	EF_BRIGHTLIGHT			= 4;
float	EF_DIMLIGHT				= 8;

float	MSG_BROADCAST			= 0;
float	MSG_ONE					= 1;
float	MSG_ALL					= 2;
float	MSG_INIT				= 3;

// Deathtypes (weapon deathtypes are the IT_* constants below)
float	DEATH_FALL				= 10000;
float	DEATH_BIGFALL			= 10001;
float	DEATH_DROWN				= 10002;
float	DEATH_HURTTRIGGER		= 10003;
float	DEATH_LAVA				= 10004;
float	DEATH_SLIME				= 10005;

float	IT_LASER				= 4096;
float	IT_SHOTGUN				= 1;
float	IT_UZI					= 2;
float	IT_GRENADE_LAUNCHER		= 4;
float	IT_ELECTRO				= 8;
float	IT_CRYLINK				= 16;
float	IT_NEX					= 32;
float	IT_HAGAR				= 64;
float	IT_ROCKET_LAUNCHER		= 128;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

float	IT_STRENGTH				= 8192;
float	IT_INVINCIBLE			= 16384;
float	IT_SPEED				= 32768;
float	IT_SLOWMO				= 65536;

vector	PL_VIEW_OFS				= '0 0 35';
vector	PL_MIN					= '-16 -16 -24';
vector	PL_MAX					= '16 16 45';

// Sajt - added these, just as constants. Not sure how you want them actually put in the game, but I just
// did this so at least they worked
// NOTE: instagib IS NOT compatible with rocket-arena, so make sure to prevent selecting both in a menu
float	GAME_INSTAGIB			= 1;   /// everyone gets the nex gun with infinite ammo, and one shot kills
float	GAME_INSANE			= 2;   /// no time between shots for any gun
float 	GAME_STRENGTH_GAIN		= 4;   /// NOT DONE
float	GAME_REGENERATION		= 8;   /// Fast health regeneration
float	GAME_ROCKET_ARENA		= 16;  /// Everyone starts with a rocket launcher
float	GAME_NO_SELF_DAMAGE		= 32;  /// no self damage, so rocket jumping and such can be used a lot more
float	GAME_NO_AIR_CONTROL		= 64;  /// turns off air control
float	GAME_LOW_GRAVITY		= 128; /// has 1/4 of the gravity
float	GAME_FULLBRIGHT_PLAYERS		= 256; /// makes the players model fullbright

float	game;	// set to "gamecfg" on worldspawn



float	POWERUP_SPEED_MOVEMENT	= 3; // movement multiplier for speed powerup
float	POWERUP_SPEED_JUMPVELOCITY = 640; // how much jump velocity with speed powerup
float	JUMP_VELOCITY = 300; // normal jump velocity

float	POWERUP_STRENGTH_DAMAGE	= 2; // damage multiplier for strength powerup
float	POWERUP_STRENGTH_FORCE	= 4; // force multiplier for strength powerup

float	POWERUP_INVINCIBLE_TAKEDAMAGE	= 0.2; // received damage multiplier for invincible powerup

float	POWERUP_SLOWMO_MOVEMENT	= 0.3; // movement speed multiplier for slowmo powerup

