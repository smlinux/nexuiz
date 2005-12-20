
// DO NOT modify the contents of this file, or you will risk incompatibility with the game engine.

entity		self;
entity		other;
entity		world;

float		time;
float		frametime;
float		force_retouch;
string		mapname;
float		deathmatch;
float		coop;
float		teamplay;
float		serverflags;
float		total_secrets;
float		total_monsters;
float		found_secrets;
float		killed_monsters;
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
vector		v_forward, v_up, v_right;
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;

void		main (void);
void		StartFrame (void);
void		PlayerPreThink (void);
void		PlayerPostThink (void);
void		ClientKill (void);
void		ClientConnect (void);
void		PutClientInServer (void);
void		ClientDisconnect (void);
void		SetNewParms (void);
void		SetChangeParms (void);

/////////////////////////////////////////////////////////
void		end_sys_globals;
/////////////////////////////////////////////////////////

.float		modelindex;

.vector		absmin, absmax;

.float		ltime;
.float		movetype;
.float		solid;

.vector		origin;
.vector		oldorigin;
.vector		velocity;
.vector		angles;
.vector		avelocity;
.vector		punchangle;

.string		classname;
.string		model;

.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;
.vector		size;

.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;

.float		nextthink;

.entity		groundentity;

.float		health;
.float		frags;

.float		weapon;
.string		weaponmodel;
.float		weaponframe;

.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		items;

.float		takedamage;

.entity		chain;

.float		deadflag;

.vector		view_ofs;

.float		button0;
.float		button1;
.float		button2;
.float		impulse;
.float		fixangle;
.vector		v_angle;
.float		idealpitch;

.string		netname;
.entity 	enemy;

.float		flags;
.float		colormap;
.float		team;
.float		max_health;
.float		teleport_time;
.float		armortype;
.float		armorvalue;
.float		waterlevel;
.float		watertype;
.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;
.entity 	goalentity;

.float		spawnflags;

.string		target;
.string		targetname;

.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;
.vector		movedir;
.string		message;
.float		sounds;
.string		noise, noise1, noise2, noise3;

/////////////////////////////////////////////////////////
void		end_sys_fields;
/////////////////////////////////////////////////////////
