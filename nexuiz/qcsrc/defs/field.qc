// Copyright (C) 2003 SeienAbunae
// Nexuiz
//
// defs/field.qc
//
//

// Globals

entity	activator;
string	string_null;

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
.float	statdraintime;			// record the one-second intervals between draining health and armour when they're over 100