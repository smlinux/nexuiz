
// Globals

entity	activator;
string	string_null;
entity	casing;
entity dest;

// Fields

.void(vector hitloc, float damage, entity inflictor, entity attacker, float deathtype) event_damage;

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
.float  crouch;	// Crouching or not?
.float  hasaliases; // Has aliases (like +crouch) binded or not?

.float	strength_finished;
.float	speed_finished;
.float	invincible_finished;
.float	slowmo_finished;

.vector		finaldest, finalangle; 		//plat.qc stuff
.void()		think1;
.float state;
.float		t_length, t_width;

.vector destvec;		// for rain
.float cnt;		// for rain
.float count;
.float cnt2;

.float death_time;
.float dead_time;
.float dead_frame;
.float die_frame;
.float fade_time;

.string mdl;

.float	norespawn;
.float	respawntime;
.float	chasecam;

.float electrocount;
.float crylinkcount;

.float	damageforcescale;

.float          gravity;

.float		dmg;

.vector angleoffset; // for incorrectly player models
