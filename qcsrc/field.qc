
// Globals

entity	activator;
string	string_null;
entity	casing;
entity dest;

// Fields

.void(vector hitloc, float damage)	event_hurt;
.void(vector hitloc, float damage)	event_die;

.string	wad;
.string	map;

.float	worldtype;
.float	delay;
.float	wait;
.float	lip;
.float	light_lev;
.float	speed;
.float	style;
.float	skill;

.string killtarget;

.vector	pos1, pos2;
.vector	mangle;

.float	jump_flag;				// storing velocity_z for falling damage
.float	attack_finished;
.float	pain_finished			//Added by Supajoe
.float	pain_frame			//"
.float	statdraintime;			// record the one-second intervals between draining health and armour when they're over 100

.vector		finaldest, finalangle; 		//plat.qc stuff
.void()		think1;
.float state;
.float		t_length, t_width;

.vector destvec;		// for rain
.float cnt;		// for rain
.float count;
.float cnt2;

.vector dead_angles;
.float death_time;

.string mdl;

.float	norespawn;
.float	respawntime;
.float	chasecam;

.float electrocount;

.float	damageforcescale;

.float          gravity;

.float		dmg;