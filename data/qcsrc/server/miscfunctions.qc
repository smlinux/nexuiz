void() spawnfunc_info_player_deathmatch; // needed for the other spawnpoints
void() spawnpoint_use;
string ColoredTeamName(float t);

float RandomSelection_totalweight;
float RandomSelection_best_priority;
entity RandomSelection_chosen_ent;
float RandomSelection_chosen_float;
void RandomSelection_Init()
{
	RandomSelection_totalweight = 0;
	RandomSelection_chosen_ent = world;
	RandomSelection_chosen_float = 0;
	RandomSelection_best_priority = -1;
}
void RandomSelection_Add(entity e, float f, float weight, float priority)
{
	if(priority > RandomSelection_best_priority)
	{
		RandomSelection_best_priority = priority;
		RandomSelection_chosen_ent = e;
		RandomSelection_chosen_float = f;
		RandomSelection_totalweight = weight;
	}
	else if(priority == RandomSelection_best_priority)
	{
		RandomSelection_totalweight += weight;
		if(random() * RandomSelection_totalweight <= weight)
		{
			RandomSelection_chosen_ent = e;
			RandomSelection_chosen_float = f;
		}
	}
}

float DistributeEvenly_amount;
float DistributeEvenly_totalweight;
void DistributeEvenly_Init(float amount, float totalweight)
{
	if(DistributeEvenly_amount)
	{
		dprint("DistributeEvenly_Init: UNFINISHED DISTRIBUTION (", ftos(DistributeEvenly_amount), " for ");
		dprint(ftos(DistributeEvenly_totalweight), " left!)\n");
	}
	if(totalweight == 0)
		DistributeEvenly_amount = 0;
	else
		DistributeEvenly_amount = amount;
	DistributeEvenly_totalweight = totalweight;
}
float DistributeEvenly_Get(float weight)
{
	float f;
	if(weight <= 0)
		return 0;
	f = floor(0.5 + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
	DistributeEvenly_totalweight -= weight;
	DistributeEvenly_amount -= f;
	return f;
}

void move_out_of_solid_expand(entity e, vector by)
{
	float eps = 0.0625;
	tracebox(e.origin, e.mins - '1 1 1' * eps, e.maxs + '1 1 1' * eps, e.origin + by, MOVE_WORLDONLY, e);
	if(trace_startsolid)
		return;
	if(trace_fraction < 1)
	{
		// hit something
		// adjust origin in the other direction...
		e.origin = e.origin - by * (1 - trace_fraction);
	}
}

float move_out_of_solid(entity e)
{
	vector o, m0, m1;

	o = e.origin;
	traceline(o, o, MOVE_WORLDONLY, e);
	if(trace_startsolid)
		return 0;

	tracebox(o, e.mins, e.maxs, o, MOVE_WORLDONLY, e);
	if(!trace_startsolid)
		return 1;

	m0 = e.mins;
	m1 = e.maxs;
	e.mins = '0 0 0';
	e.maxs = '0 0 0';
	move_out_of_solid_expand(e, '1 0 0' * m0_x); e.mins_x = m0_x;
	move_out_of_solid_expand(e, '1 0 0' * m1_x); e.maxs_x = m1_x;
	move_out_of_solid_expand(e, '0 1 0' * m0_y); e.mins_y = m0_y;
	move_out_of_solid_expand(e, '0 1 0' * m1_y); e.maxs_y = m1_y;
	move_out_of_solid_expand(e, '0 0 1' * m0_z); e.mins_z = m0_z;
	move_out_of_solid_expand(e, '0 0 1' * m1_z); e.maxs_z = m1_z;
	setorigin(e, e.origin);

	tracebox(e.origin, e.mins, e.maxs, e.origin, MOVE_WORLDONLY, e);
	if(trace_startsolid)
	{
		setorigin(e, o);
		return 0;
	}

	return 1;
}

string STR_PLAYER = "player";
string STR_SPECTATOR = "spectator";
string STR_OBSERVER = "observer";

#if 0
#define FOR_EACH_CLIENT(v) for(v = world; (v = findflags(v, flags, FL_CLIENT)) != world; )
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) for(v = world; (v = find(v, classname, STR_PLAYER)) != world; )
#define FOR_EACH_REALPLAYER(v) FOR_EACH_PLAYER(v) if(clienttype(v) == CLIENTTYPE_REAL)
#else
#define FOR_EACH_CLIENTSLOT(v) for(v = world; (v = nextent(v)) && (num_for_edict(v) <= maxclients); )
#define FOR_EACH_CLIENT(v) FOR_EACH_CLIENTSLOT(v) if(v.flags & FL_CLIENT)
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) FOR_EACH_CLIENT(v) if(v.classname == STR_PLAYER)
#define FOR_EACH_REALPLAYER(v) FOR_EACH_REALCLIENT(v) if(v.classname == STR_PLAYER)
#endif

// copies a string to a tempstring (so one can strunzone it)
string strcat1(string s) = #115; // FRIK_FILE

float logfile_open;
float logfile;

void bcenterprint(string s)
{
	// TODO replace by MSG_ALL (would show it to spectators too, though)?
	entity head;
	FOR_EACH_PLAYER(head)
		if(clienttype(head) == CLIENTTYPE_REAL)
			centerprint(head, s);
}

void GameLogEcho(string s)
{
	string fn;
	float matches;

	if(cvar("sv_eventlog_files"))
	{
		if(!logfile_open)
		{
			logfile_open = TRUE;
			matches = cvar("sv_eventlog_files_counter") + 1;
			cvar_set("sv_eventlog_files_counter", ftos(matches));
			fn = ftos(matches);
			if(strlen(fn) < 8)
				fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
			fn = strcat(cvar_string("sv_eventlog_files_nameprefix"), fn, cvar_string("sv_eventlog_files_namesuffix"));
			logfile = fopen(fn, FILE_APPEND);
			fputs(logfile, ":logversion:2\n");
		}
		if(logfile >= 0)
		{
			if(cvar("sv_eventlog_files_timestamps"))
				fputs(logfile, strcat(":time:", strftime(TRUE, "%Y-%m-%d %H:%M:%S", "\n", s, "\n")));
			else
				fputs(logfile, strcat(s, "\n"));
		}
	}
	if(cvar("sv_eventlog_console"))
	{
		print(s, "\n");
	}
}

void GameLogInit()
{
	logfile_open = 0;
	// will be opened later
}

void GameLogClose()
{
	if(logfile_open && logfile >= 0)
	{
		fclose(logfile);
		logfile = -1;
	}
}

float spawnpoint_nag;
void relocate_spawnpoint()
{
	// nudge off the floor
	setorigin(self, self.origin + '0 0 1');

	tracebox(self.origin, PL_MIN, PL_MAX, self.origin, TRUE, self);
	if (trace_startsolid)
	{
		vector o;
		o = self.origin;
		self.mins = PL_MIN;
		self.maxs = PL_MAX;
		if(!move_out_of_solid(self))
			objerror("could not get out of solid at all!");
		print("^1NOTE: this map needs FIXING. Spawnpoint at ", vtos(o - '0 0 1'));
		print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
		print(" ", ftos(self.origin_y - o_y));
		print(" ", ftos(self.origin_z - o_z), "'\n");
		if(cvar("g_spawnpoints_auto_move_out_of_solid"))
		{
			if(!spawnpoint_nag)
				print("\{1}^1NOTE: this map needs FIXING (it contains spawnpoints in solid, see server log)\n");
			spawnpoint_nag = 1;
		}
		else
		{
			self.origin = o;
			self.mins = self.maxs = '0 0 0';
			objerror("player spawn point in solid, mapper sucks!\n");
			return;
		}
	}

	if(cvar("g_spawnpoints_autodrop"))
	{
		setsize(self, PL_MIN, PL_MAX);
		droptofloor();
	}

	self.use = spawnpoint_use;
	self.team_saved = self.team;
	if(!self.cnt)
		self.cnt = 1;

	if(g_ctf || g_assault || g_onslaught || g_domination)
	if(self.team)
		have_team_spawns = 1;

	if(cvar("r_showbboxes"))
	{
		// show where spawnpoints point at too
		makevectors(self.angles);
		entity e;
		e = spawn();
		e.classname = "info_player_foo";
		setorigin(e, self.origin + v_forward * 24);
		setsize(e, '-8 -8 -8', '8 8 8');
		e.solid = SOLID_TRIGGER;
	}
}

#define strstr strstrofs
/*
// NOTE: DO NOT USE THIS FUNCTION TOO OFTEN.
// IT WILL MOST PROBABLY DESTROY _ALL_ OTHER TEMP
// STRINGS AND TAKE QUITE LONG. haystack and needle MUST
// BE CONSTANT OR strzoneD!
float strstr(string haystack, string needle, float offset)
{
	float len, endpos;
	string found;
	len = strlen(needle);
	endpos = strlen(haystack) - len;
	while(offset <= endpos)
	{
		found = substring(haystack, offset, len);
		if(found == needle)
			return offset;
		offset = offset + 1;
	}
	return -1;
}
*/

float NUM_NEAREST_ENTITIES = 4;
entity nearest_entity[NUM_NEAREST_ENTITIES];
float nearest_length[NUM_NEAREST_ENTITIES];
entity findnearest(vector point, .string field, string value, vector axismod)
{
	entity localhead;
	float i;
	float j;
	float len;
	vector dist;

	float num_nearest;
	num_nearest = 0;

	localhead = find(world, field, value);
	while(localhead)
	{
		if((localhead.items == IT_KEY1 || localhead.items == IT_KEY2) && localhead.target == "###item###")
			dist = localhead.oldorigin;
		else
			dist = localhead.origin;
		dist = dist - point;
		dist = dist_x * axismod_x * '1 0 0' + dist_y * axismod_y * '0 1 0' + dist_z * axismod_z * '0 0 1';
		len = vlen(dist);

		for(i = 0; i < num_nearest; ++i)
		{
			if(len < nearest_length[i])
				break;
		}

		// now i tells us where to insert at
		//   INSERTION SORT! YOU'VE SEEN IT! RUN!
		if(i < NUM_NEAREST_ENTITIES)
		{
			for(j = NUM_NEAREST_ENTITIES - 1; j >= i; --j)
			{
				nearest_length[j + 1] = nearest_length[j];
				nearest_entity[j + 1] = nearest_entity[j];
			}
			nearest_length[i] = len;
			nearest_entity[i] = localhead;
			if(num_nearest < NUM_NEAREST_ENTITIES)
				num_nearest = num_nearest + 1;
		}

		localhead = find(localhead, field, value);
	}

	// now use the first one from our list that we can see
	for(i = 0; i < num_nearest; ++i)
	{
		traceline(point, nearest_entity[i].origin, TRUE, world);
		if(trace_fraction == 1)
		{
			if(i != 0)
			{
				dprint("Nearest point (");
				dprint(nearest_entity[0].netname);
				dprint(") is not visible, using a visible one.\n");
			}
			return nearest_entity[i];
		}
	}

	if(num_nearest == 0)
		return world;

	dprint("Not seeing any location point, using nearest as fallback.\n");
	/* DEBUGGING CODE:
	dprint("Candidates were: ");
	for(j = 0; j < num_nearest; ++j)
	{
		if(j != 0)
			dprint(", ");
		dprint(nearest_entity[j].netname);
	}
	dprint("\n");
	*/

	return nearest_entity[0];
}

void spawnfunc_target_location()
{
	self.classname = "target_location";
	// location name in netname
	// eventually support: count, teamgame selectors, line of sight?
};

void spawnfunc_info_location()
{
	self.classname = "target_location";
	self.message = self.netname;
};

string NearestLocation(vector p)
{
	entity loc;
	string ret;
	ret = "somewhere";
	loc = findnearest(p, classname, "target_location", '1 1 1');
	if(loc)
	{
		ret = loc.message;
	}
	else
	{
		loc = findnearest(p, target, "###item###", '1 1 4');
		if(loc)
			ret = loc.netname;
	}
	return ret;
}

string formatmessage(string msg)
{
	float p;
	float n;
	string msg_save;
	string escape;
	string replacement;
	msg_save = strzone(msg);
	p = 0;
	n = 7;
	while(1)
	{
		if(n < 1)
			break; // too many replacements
		n = n - 1;
		p = strstr(msg_save, "%", p); // NOTE: this destroys msg as it's a tempstring!
		if(p < 0)
			break;
		replacement = substring(msg_save, p, 2);
		escape = substring(msg_save, p + 1, 1);
		if(escape == "%")
			replacement = "%";
		else if(escape == "a")
			replacement = ftos(floor(self.armorvalue));
		else if(escape == "h")
			replacement = ftos(floor(self.health));
		else if(escape == "l")
			replacement = NearestLocation(self.origin);
		else if(escape == "y")
			replacement = NearestLocation(self.cursor_trace_endpos);
		else if(escape == "d")
			replacement = NearestLocation(self.death_origin);
		else if(escape == "w")
		{
			float wep;
			wep = self.weapon;
			if(!wep)
				wep = self.switchweapon;
			if(!wep)
				wep = self.cnt;
			replacement = W_Name(wep);
		}
		else if(escape == "W")
		{
			if(self.items & IT_SHELLS) replacement = "shells";
			else if(self.items & IT_NAILS) replacement = "bullets";
			else if(self.items & IT_ROCKETS) replacement = "rockets";
			else if(self.items & IT_CELLS) replacement = "cells";
			else replacement = "batteries"; // ;)
		}
		else if(escape == "x")
		{
			replacement = self.cursor_trace_ent.netname;
			if(!replacement || !self.cursor_trace_ent)
				replacement = "nothing";
		}
		else if(escape == "p")
		{
			if(self.last_selected_player)
				replacement = self.last_selected_player.netname;
			else
				replacement = "(nobody)";
		}
		msg = strcat(substring(msg_save, 0, p), replacement);
		msg = strcat(msg, substring(msg_save, p+2, strlen(msg_save) - (p+2)));
		strunzone(msg_save);
		msg_save = strzone(msg);
		p = p + 2;
	}
	msg = strcat(msg_save, "");
	strunzone(msg_save);
	return msg;
}

/*
=============
GetCvars
=============
Called with:
  0:  sends the request
  >0: receives a cvar from name=argv(f) value=argv(f+1)
*/
void GetCvars_handleString(string thisname, float f, .string field, string name)
{
	if(f < 0)
	{
		if(self.field)
			strunzone(self.field);
	}
	else if(f > 0)
	{
		if(thisname == name)
		{
			if(self.field)
				strunzone(self.field);
			self.field = strzone(argv(f + 1));
		}
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
void GetCvars_handleString_Fixup(string thisname, float f, .string field, string name, string(string) func)
{
	GetCvars_handleString(thisname, f, field, name);
	if(f >= 0) // also initialize to the fitting value for "" when sending cvars out
	if(thisname == name)
	{
		string s;
		s = func(strcat1(self.field));
		if(s != self.field)
		{
			strunzone(self.field);
			self.field = strzone(s);
		}
	}
}
void GetCvars_handleFloat(string thisname, float f, .float field, string name)
{
	if(f < 0)
	{
	}
	else if(f > 0)
	{
		if(thisname == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
string W_FixWeaponOrder_ForceComplete(string s);
string W_FixWeaponOrder_AllowIncomplete(string s);
float w_getbestweapon(entity e);
void GetCvars(float f)
{
	string s;
	if(f > 0)
		s = strcat1(argv(f));
	GetCvars_handleFloat(s, f, autoswitch, "cl_autoswitch");
	GetCvars_handleFloat(s, f, cvar_cl_playerdetailreduction, "cl_playerdetailreduction");
	GetCvars_handleFloat(s, f, cvar_cl_nogibs, "cl_nogibs");
	GetCvars_handleFloat(s, f, cvar_scr_centertime, "scr_centertime");
	GetCvars_handleFloat(s, f, cvar_cl_shownames, "cl_shownames");
	GetCvars_handleString(s, f, cvar_g_nexuizversion, "g_nexuizversion");
	GetCvars_handleFloat(s, f, cvar_cl_handicap, "cl_handicap");
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriority, "cl_weaponpriority", W_FixWeaponOrder_ForceComplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[0], "cl_weaponpriority0", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[1], "cl_weaponpriority1", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[2], "cl_weaponpriority2", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[3], "cl_weaponpriority3", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[4], "cl_weaponpriority4", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[5], "cl_weaponpriority5", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[6], "cl_weaponpriority6", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[7], "cl_weaponpriority7", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[8], "cl_weaponpriority8", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[9], "cl_weaponpriority9", W_FixWeaponOrder_AllowIncomplete);

	// fixup of switchweapon (needed for LMS or when spectating is disabled, as PutClientInServer comes too early)
	if(f > 0)
	{
		if(s == "cl_weaponpriority")
			self.switchweapon = w_getbestweapon(self);
	}
}

float fexists(string f)
{
	float fh;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return FALSE;
	fclose(fh);
	return TRUE;
}

void backtrace(string msg)
{
	float dev;
	dev = cvar("developer");
	cvar_set("developer", "1");
	dprint("\n");
	dprint("--- CUT HERE ---\nWARNING: ");
	dprint(msg);
	dprint("\n");
	remove(world); // isn't there any better way to cause a backtrace?
	dprint("\n--- CUT UNTIL HERE ---\n");
	cvar_set("developer", ftos(dev));
}

string Team_ColorCode(float teamid)
{
	if(teamid == COLOR_TEAM1)
		return "^1";
	else if(teamid == COLOR_TEAM2)
		return "^4";
	else if(teamid == COLOR_TEAM3)
		return "^3";
	else if(teamid == COLOR_TEAM4)
		return "^6";
	else
		return "^7";
}
string Team_ColorName(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == COLOR_TEAM1)
		return "Red";
	if(t == COLOR_TEAM2)
		return "Blue";
	if(t == COLOR_TEAM3)
		return "Yellow";
	if(t == COLOR_TEAM4)
		return "Pink";
	return "Neutral";
}
string Team_ColorNameLowerCase(float t)
{
	// fixme: Search for team entities and get their .netname's!
	if(t == COLOR_TEAM1)
		return "red";
	if(t == COLOR_TEAM2)
		return "blue";
	if(t == COLOR_TEAM3)
		return "yellow";
	if(t == COLOR_TEAM4)
		return "pink";
	return "neutral";
}

#define CENTERPRIO_POINT 1
#define CENTERPRIO_SPAM 2
#define CENTERPRIO_REBALANCE 2
#define CENTERPRIO_VOTE 4
#define CENTERPRIO_NORMAL 5
#define CENTERPRIO_MAPVOTE 9
#define CENTERPRIO_IDLEKICK 50
#define CENTERPRIO_ADMIN 99
.float centerprint_priority;
.float centerprint_expires;
void centerprint_atprio(entity e, float prio, string s)
{
	if(intermission_running)
		if(prio < CENTERPRIO_MAPVOTE)
			return;
	if(time > e.centerprint_expires)
		e.centerprint_priority = 0;
	if(prio >= e.centerprint_priority)
	{
		e.centerprint_priority = prio;
		if(timeoutStatus == 2)
			e.centerprint_expires = time + (e.cvar_scr_centertime * TIMEOUT_SLOWMO_VALUE);
		else
			e.centerprint_expires = time + e.cvar_scr_centertime;
		centerprint_builtin(e, s);
	}
}
void centerprint_expire(entity e, float prio)
{
	if(prio == e.centerprint_priority)
	{
		e.centerprint_priority = 0;
		centerprint_builtin(e, "");
	}
}
void centerprint(entity e, string s)
{
	centerprint_atprio(e, CENTERPRIO_NORMAL, s);
}

// decolorizes and team colors the player name when needed
string playername(entity p)
{
	string t;
	if(teams_matter && !intermission_running && p.classname == "player")
	{
		t = Team_ColorCode(p.team);
		return strcat(t, strdecolorize(p.netname));
	}
	else
		return p.netname;
}

vector randompos(vector m1, vector m2)
{
	local vector v;
	m2 = m2 - m1;
	v_x = m2_x * random() + m1_x;
	v_y = m2_y * random() + m1_y;
	v_z = m2_z * random() + m1_z;
	return  v;
};

// requires that m2>m1 in all coordinates, and that m4>m3
float boxesoverlap(vector m1, vector m2, vector m3, vector m4) {return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;};

// requires the same, but is a stronger condition
float boxinsidebox(vector smins, vector smaxs, vector bmins, vector bmaxs) {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;};

float g_pickup_shells;
float g_pickup_shells_max;
float g_pickup_nails;
float g_pickup_nails_max;
float g_pickup_rockets;
float g_pickup_rockets_max;
float g_pickup_cells;
float g_pickup_cells_max;
float g_pickup_armorsmall;
float g_pickup_armorsmall_max;
float g_pickup_armormedium;
float g_pickup_armormedium_max;
float g_pickup_armorlarge;
float g_pickup_armorlarge_max;
float g_pickup_healthsmall;
float g_pickup_healthsmall_max;
float g_pickup_healthmedium;
float g_pickup_healthmedium_max;
float g_pickup_healthlarge;
float g_pickup_healthlarge_max;
float g_pickup_healthmega;
float g_pickup_healthmega_max;

float start_weapons;
float start_items;
float start_ammo_shells;
float start_ammo_nails;
float start_ammo_rockets;
float start_ammo_cells;
float start_health;
float start_armorvalue;
float warmup_start_weapons;
float warmup_start_ammo_shells;
float warmup_start_ammo_nails;
float warmup_start_ammo_rockets;
float warmup_start_ammo_cells;
float warmup_start_health;
float warmup_start_armorvalue;

entity get_weaponinfo(float w);

void readplayerstartcvars() 
{
	entity e;
	float i;

  	// initialize starting values for players
	start_weapons = 0;
	start_items = 0;
	start_ammo_shells = 0;
	start_ammo_nails = 0;
	start_ammo_rockets = 0;
	start_ammo_cells = 0;
	start_health = cvar("g_balance_health_start");
	start_armorvalue = cvar("g_balance_armor_start");

	if(g_rocketarena)
	{
		start_weapons = WEPBIT_ROCKET_LAUNCHER;
		weapon_action(WEP_ROCKET_LAUNCHER, WR_PRECACHE);
		start_ammo_rockets = 999;
		start_items |= IT_UNLIMITED_AMMO;
	}
	else if(g_nixnex)
	{
		start_weapons = 0;
		// will be done later
	}
	else if(g_minstagib)
	{
		start_health = 100;
		start_armorvalue = 0;
		start_weapons = WEPBIT_MINSTANEX;
		weapon_action(WEP_MINSTANEX, WR_PRECACHE);
		start_ammo_cells = cvar("g_minstagib_ammo_start");
		g_minstagib_invis_alpha = cvar("g_minstagib_invis_alpha");
	}
	else
	{
		if(g_lms)
		{
			start_ammo_shells = cvar("g_lms_start_ammo_shells");
			start_ammo_nails = cvar("g_lms_start_ammo_nails");
			start_ammo_rockets = cvar("g_lms_start_ammo_rockets");
			start_ammo_cells = cvar("g_lms_start_ammo_cells");
			start_health = cvar("g_lms_start_health");
			start_armorvalue = cvar("g_lms_start_armor");
		} else if (cvar("g_use_ammunition")) {
			start_ammo_shells = cvar("g_start_ammo_shells");
			start_ammo_nails = cvar("g_start_ammo_nails");
			start_ammo_rockets = cvar("g_start_ammo_rockets");
			start_ammo_cells = cvar("g_start_ammo_cells");
		} else {
			start_ammo_shells = cvar("g_pickup_shells_max");
			start_ammo_nails = cvar("g_pickup_nails_max");
			start_ammo_rockets = cvar("g_pickup_rockets_max");
			start_ammo_cells = cvar("g_pickup_cells_max");
			start_items |= IT_UNLIMITED_AMMO;
		}

		for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			e = get_weaponinfo(i);
			if(!(e.weapon))
				continue;
			if(((e.spawnflags & 1) && g_lms) || cvar(strcat("g_start_weapon_", e.netname)))
			{
				start_weapons |= e.weapons;
				weapon_action(e.weapon, WR_PRECACHE);
			}
		}
	}

	if(inWarmupStage)
	{
		warmup_start_ammo_shells = start_ammo_shells;
		warmup_start_ammo_nails = start_ammo_nails;
		warmup_start_ammo_rockets = start_ammo_rockets;
		warmup_start_ammo_cells = start_ammo_cells;
		warmup_start_health = start_health;
		warmup_start_armorvalue = start_armorvalue;
		warmup_start_weapons = start_weapons;

		if(!g_rocketarena && !g_nixnex && !g_minstagib)
		{
			if(cvar("g_use_ammunition"))
			{
				warmup_start_ammo_shells = cvar("g_warmup_start_ammo_shells");
				warmup_start_ammo_cells = cvar("g_warmup_start_ammo_cells");
				warmup_start_ammo_nails = cvar("g_warmup_start_ammo_nails");
				warmup_start_ammo_rockets = cvar("g_warmup_start_ammo_rockets");
			}
			warmup_start_health = cvar("g_warmup_start_health");
			warmup_start_armorvalue = cvar("g_warmup_start_armor");
			if(cvar("g_warmup_allguns"))
			{
				for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				{
					e = get_weaponinfo(i);
					if(!(e.weapon))
						continue;
					if(e.spawnflags & 1)
					{
						warmup_start_weapons |= e.weapons;
						weapon_action(e.weapon, WR_PRECACHE);
					}
				}
			}
		}
	}
}

void readlevelcvars(void)
{
	sv_cheats = cvar("sv_cheats");
	sv_gentle = cvar("sv_gentle");
	sv_foginterval = cvar("sv_foginterval");
	g_cloaked = cvar("g_cloaked");
	g_jump_grunt = cvar("g_jump_grunt");
	g_footsteps = cvar("g_footsteps");
	g_grappling_hook = cvar("g_grappling_hook");
	g_laserguided_missile = cvar("g_laserguided_missile");
	g_midair = cvar("g_midair");
	g_minstagib = cvar("g_minstagib");
	g_nixnex = cvar("g_nixnex");
	g_nixnex_with_laser = cvar("g_nixnex_with_laser");
	g_norecoil = cvar("g_norecoil");
	g_rocketarena = cvar("g_rocketarena");
	g_vampire = cvar("g_vampire");
	sv_maxidle = cvar("sv_maxidle");
	sv_maxidle_spectatorsareidle = cvar("sv_maxidle_spectatorsareidle");
	sv_pogostick = cvar("sv_pogostick");
	sv_doublejump = cvar("sv_doublejump");

	inWarmupStage = cvar("g_warmup");
	g_warmup_limit = cvar("g_warmup_limit");
	g_warmup_allguns = cvar("g_warmup_allguns");
	g_warmup_allow_timeout = cvar("g_warmup_allow_timeout");

	if(g_race && g_race_qualifying == 2 || g_arena || g_assault || cvar("g_campaign"))
		inWarmupStage = 0; // these modes cannot work together, sorry

	g_pickup_respawntime_short = cvar("g_pickup_respawntime_short");
	g_pickup_respawntime_medium = cvar("g_pickup_respawntime_medium");
	g_pickup_respawntime_long = cvar("g_pickup_respawntime_long");
	g_pickup_respawntime_powerup = cvar("g_pickup_respawntime_powerup");

	if(g_minstagib) g_nixnex = g_rocketarena = 0;
	if(g_nixnex) g_rocketarena = 0;

	g_pickup_shells                    = cvar("g_pickup_shells");
	g_pickup_shells_max                = cvar("g_pickup_shells_max");
	g_pickup_nails                     = cvar("g_pickup_nails");
	g_pickup_nails_max                 = cvar("g_pickup_nails_max");
	g_pickup_rockets                   = cvar("g_pickup_rockets");
	g_pickup_rockets_max               = cvar("g_pickup_rockets_max");
	g_pickup_cells                     = cvar("g_pickup_cells");
	g_pickup_cells_max                 = cvar("g_pickup_cells_max");
	g_pickup_armorsmall                = cvar("g_pickup_armorsmall");
	g_pickup_armorsmall_max            = cvar("g_pickup_armorsmall_max");
	g_pickup_armormedium               = cvar("g_pickup_armormedium");
	g_pickup_armormedium_max           = cvar("g_pickup_armormedium_max");
	g_pickup_armorlarge                = cvar("g_pickup_armorlarge");
	g_pickup_armorlarge_max            = cvar("g_pickup_armorlarge_max");
	g_pickup_healthsmall               = cvar("g_pickup_healthsmall");
	g_pickup_healthsmall_max           = cvar("g_pickup_healthsmall_max");
	g_pickup_healthmedium              = cvar("g_pickup_healthmedium");
	g_pickup_healthmedium_max          = cvar("g_pickup_healthmedium_max");
	g_pickup_healthlarge               = cvar("g_pickup_healthlarge");
	g_pickup_healthlarge_max           = cvar("g_pickup_healthlarge_max");
	g_pickup_healthmega                = cvar("g_pickup_healthmega");
	g_pickup_healthmega_max            = cvar("g_pickup_healthmega_max");

	readplayerstartcvars();
}

/*
// TODO sound pack system
string soundpack;

string precache_sound_builtin (string s) = #19;
void(entity e, float chan, string samp, float vol, float atten) sound_builtin = #8;
string precache_sound(string s)
{
	return precache_sound_builtin(strcat(soundpack, s));
}
void play2(entity e, string filename)
{
	stuffcmd(e, strcat("play2 ", soundpack, filename, "\n"));
}
void sound(entity e, float chan, string samp, float vol, float atten)
{
	sound_builtin(e, chan, strcat(soundpack, samp), vol, atten);
}
*/

// Sound functions
string precache_sound (string s) = #19;
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
float precache_sound_index (string s) = #19;

void soundtoat(float dest, entity e, vector o, float chan, string samp, float vol, float atten)
{
	WriteByte(dest, 6);
	WriteByte(dest, 27); // all bits except SND_LOOPING
	WriteByte(dest, vol * 255);
	WriteByte(dest, atten * 64);
	WriteEntity(dest, e);
	WriteByte(dest, chan);
	WriteShort(dest, precache_sound_index(samp));
	WriteCoord(dest, o_x);
	WriteCoord(dest, o_y);
	WriteCoord(dest, o_z);
}
void soundto(float dest, entity e, float chan, string samp, float vol, float atten)
{
	vector o;
	o = e.origin + 0.5 * (e.mins + e.maxs);
	soundtoat(dest, e, o, chan, samp, vol, atten);
}
void soundat(entity e, vector o, float chan, string samp, float vol, float atten)
{
	soundtoat(MSG_BROADCAST, e, o, chan, samp, vol, atten);
}

void play2(entity e, string filename)
{
	//stuffcmd(e, strcat("play2 ", filename, "\n"));
	msg_entity = e;
	soundtoat(MSG_ONE, world, '0 0 0', CHAN_AUTO, filename, VOL_BASE, ATTN_NONE);
}

.float announcetime;
void announce(entity player, string msg)
{
	if(time > player.announcetime)
	if(clienttype(player) == CLIENTTYPE_REAL)
	{
		player.announcetime = time + 0.3;
		play2(player, msg);
	}
}

void play2team(float t, string filename)
{
	local entity head;
	FOR_EACH_REALPLAYER(head)
	{
		if (head.team == t)
			play2(head, filename);
	}
}

void play2all(string samp)
{
	sound(world, CHAN_AUTO, samp, VOL_BASE, ATTN_NONE);
}

void PrecachePlayerSounds(string f);
void precache_all_models(string pattern)
{
	float globhandle, i, n;
	string f;

	globhandle = search_begin(pattern, TRUE, FALSE);
	if(globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for(i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		precache_model(f);
		PrecachePlayerSounds(strcat(f, ".sounds"));
	}
	search_end(globhandle);
}

void precache()
{
	// gamemode related things
	precache_model ("models/misc/chatbubble.spr");
	precache_model ("models/misc/teambubble.spr");
	if (g_runematch)
	{
		precache_model ("models/runematch/curse.mdl");
		precache_model ("models/runematch/rune.mdl");
	}

	// Precache all player models if desired
	if (cvar("sv_precacheplayermodels"))
	{
		PrecachePlayerSounds("sound/player/default.sounds");
		precache_all_models("models/player/*.zym");
		precache_all_models("models/player/*.dpm");
		precache_all_models("models/player/*.md3");
		precache_all_models("models/player/*.psk");
		//precache_model("models/player/carni.zym");
		//precache_model("models/player/crash.zym");
		//precache_model("models/player/grunt.zym");
		//precache_model("models/player/headhunter.zym");
		//precache_model("models/player/insurrectionist.zym");
		//precache_model("models/player/jeandarc.zym");
		//precache_model("models/player/lurk.zym");
		//precache_model("models/player/lycanthrope.zym");
		//precache_model("models/player/marine.zym");
		//precache_model("models/player/nexus.zym");
		//precache_model("models/player/pyria.zym");
		//precache_model("models/player/shock.zym");
		//precache_model("models/player/skadi.zym");
		//precache_model("models/player/specop.zym");
		//precache_model("models/player/visitant.zym");
	}

	if (g_footsteps)
	{
		PrecacheGlobalSound((globalsound_step = "misc/footstep0 6"));
		PrecacheGlobalSound((globalsound_metalstep = "misc/metalfootstep0 6"));
	}

	// gore and miscellaneous sounds
	//precache_sound ("misc/h2ohit.wav");
	precache_model ("models/gibs/bloodyskull.md3");
	precache_model ("models/gibs/chunk.mdl");
	precache_model ("models/gibs/eye.md3");
	precache_model ("models/gibs/gib1.md3");
	precache_model ("models/gibs/gib2.md3");
	precache_model ("models/gibs/gib3.md3");
	precache_model ("models/gibs/gib4.md3");
	precache_model ("models/gibs/gib5.md3");
	precache_model ("models/gibs/gib6.md3");
	precache_model ("models/gibs/smallchest.md3");
	precache_model ("models/gibs/chest.md3");
	precache_model ("models/gibs/arm.md3");
	precache_model ("models/gibs/leg1.md3");
	precache_model ("models/gibs/leg2.md3");
	precache_model ("models/hook.md3");
	precache_sound ("misc/armorimpact.wav");
	precache_sound ("misc/bodyimpact1.wav");
	precache_sound ("misc/bodyimpact2.wav");
	precache_sound ("misc/gib.wav");
	precache_sound ("misc/gib_splat01.wav");
	precache_sound ("misc/gib_splat02.wav");
	precache_sound ("misc/gib_splat03.wav");
	precache_sound ("misc/gib_splat04.wav");
	precache_sound ("misc/hit.wav");
	PrecacheGlobalSound((globalsound_fall = "misc/hitground 4"));
	PrecacheGlobalSound((globalsound_metalfall = "misc/metalhitground 4"));
	precache_sound ("misc/null.wav");
	precache_sound ("misc/spawn.wav");
	precache_sound ("misc/talk.wav");
	precache_sound ("misc/teleport.wav");
	precache_sound ("player/lava.wav");
	precache_sound ("player/slime.wav");

	// announcer sounds - male
	//precache_sound ("announcer/male/electrobitch.wav");
	precache_sound ("announcer/male/03kills.wav");
	precache_sound ("announcer/male/05kills.wav");
	precache_sound ("announcer/male/10kills.wav");
	precache_sound ("announcer/male/15kills.wav");
	precache_sound ("announcer/male/20kills.wav");
	precache_sound ("announcer/male/25kills.wav");
	precache_sound ("announcer/male/30kills.wav");
	precache_sound ("announcer/male/botlike.wav");
	precache_sound ("announcer/male/yoda.wav");

	// announcer sounds - robotic
	precache_sound ("announcer/robotic/prepareforbattle.wav");
	precache_sound ("announcer/robotic/begin.wav");
	precache_sound ("announcer/robotic/timeoutcalled.wav");
	precache_sound ("announcer/robotic/1fragleft.wav");
	precache_sound ("announcer/robotic/1minuteremains.wav");
	precache_sound ("announcer/robotic/2fragsleft.wav");
	precache_sound ("announcer/robotic/3fragsleft.wav");
	if (g_minstagib)
	{
		precache_sound ("announcer/robotic/lastsecond.wav");
		precache_sound ("announcer/robotic/narrowly.wav");
	}

	precache_model ("models/sprites/1.spr32");
	precache_model ("models/sprites/2.spr32");
	precache_model ("models/sprites/3.spr32");
	precache_model ("models/sprites/4.spr32");
	precache_model ("models/sprites/5.spr32");
	precache_model ("models/sprites/6.spr32");
	precache_model ("models/sprites/7.spr32");
	precache_model ("models/sprites/8.spr32");
	precache_model ("models/sprites/9.spr32");
	precache_model ("models/sprites/10.spr32");
	precache_sound ("announcer/robotic/1.ogg");
	precache_sound ("announcer/robotic/2.ogg");
	precache_sound ("announcer/robotic/3.ogg");
	precache_sound ("announcer/robotic/4.ogg");
	precache_sound ("announcer/robotic/5.ogg");
	precache_sound ("announcer/robotic/6.ogg");
	precache_sound ("announcer/robotic/7.ogg");
	precache_sound ("announcer/robotic/8.ogg");
	precache_sound ("announcer/robotic/9.ogg");
	precache_sound ("announcer/robotic/10.ogg");

	// common weapon precaches
	precache_sound ("weapons/weapon_switch.wav");
	precache_sound ("weapons/weaponpickup.wav");
	if (cvar("g_grappling_hook"))
	{
		precache_sound ("weapons/hook_fire.wav"); // hook
		precache_sound ("weapons/hook_impact.wav"); // hook
	}

	if (cvar("sv_precacheweapons") || g_nixnex)
	{
		//precache weapon models/sounds
		local float wep;
		wep = WEP_FIRST;
		while (wep <= WEP_LAST)
		{
			weapon_action(wep, WR_PRECACHE);
			wep = wep + 1;
		}
	}

	// plays music for the level if there is any
	if (self.noise)
	{
		precache_sound (self.noise);
		ambientsound ('0 0 0', self.noise, VOL_BASE, ATTN_NONE);
	}
}

// sorry, but using \ in macros breaks line numbers
#define WRITESPECTATABLE_MSG_ONE_VARNAME(varname,statement) entity varname; varname = msg_entity; FOR_EACH_REALCLIENT(msg_entity) if(msg_entity == varname || (msg_entity.classname == STR_SPECTATOR && msg_entity.enemy == varname)) statement msg_entity = varname
#define WRITESPECTATABLE_MSG_ONE(statement) WRITESPECTATABLE_MSG_ONE_VARNAME(oldmsg_entity, statement)
#define WRITESPECTATABLE(msg,statement) if(msg == MSG_ONE) { WRITESPECTATABLE_MSG_ONE(statement); } else statement float WRITESPECTATABLE_workaround = 0

vector ExactTriggerHit_mins;
vector ExactTriggerHit_maxs;
float ExactTriggerHit_Recurse()
{
	float s;
	entity se;
	float f;

	tracebox('0 0 0', ExactTriggerHit_mins, ExactTriggerHit_maxs, '0 0 0', MOVE_NORMAL, other);
	if not(trace_ent)
		return 0;
	if(trace_ent == self)
		return 1;

	se = trace_ent;
	s = se.solid;
	se.solid = SOLID_NOT;
	f = ExactTriggerHit_Recurse();
	se.solid = s;

	return f;
}

float ExactTriggerHit()
{
	float f, s;

	if not(self.modelindex)
		return 1;

	s = self.solid;
	self.solid = SOLID_BSP;
	ExactTriggerHit_mins = other.absmin;
	ExactTriggerHit_maxs = other.absmax;
	f = ExactTriggerHit_Recurse();
	self.solid = s;

	return f;
}

// WARNING: this kills the trace globals
#define EXACTTRIGGER_TOUCH if not(ExactTriggerHit()) return
#define EXACTTRIGGER_INIT  InitSolidBSPTrigger(); self.solid = SOLID_TRIGGER

#define INITPRIO_FIRST              0
#define INITPRIO_GAMETYPE           0
#define INITPRIO_GAMETYPE_FALLBACK  1
#define INITPRIO_CVARS              5
#define INITPRIO_FINDTARGET        10
#define INITPRIO_SETLOCATION       90
#define INITPRIO_LINKDOORS         91
#define INITPRIO_LAST              99

.void(void) initialize_entity;
.float initialize_entity_order;
.entity initialize_entity_next;
entity initialize_entity_first;
void InitializeEntity(entity e, void(void) func, float order)
{
	entity prev, cur;

	if(!e || e.initialize_entity)
	{
		// make a proxy initializer entity
		entity e_old;
		e_old = e;
		e = spawn();
		e.classname = "initialize_entity";
		e.enemy = e_old;
	}

	e.initialize_entity = func;
	e.initialize_entity_order = order;

	cur = initialize_entity_first;
	for(;;)
	{
		if(!cur || cur.initialize_entity_order > order)
		{
			// insert between prev and cur
			if(prev)
				prev.initialize_entity_next = e;
			else
				initialize_entity_first = e;
			e.initialize_entity_next = cur;
			return;
		}
		prev = cur;
		cur = cur.initialize_entity_next;
	}
}
void InitializeEntitiesRun()
{
	for(self = initialize_entity_first; self; )
	{
		entity e;
		var void(void) func;
		e = self.initialize_entity_next;
		func = self.initialize_entity;
		self.initialize_entity_order = 0;
		self.initialize_entity = func_null;
		self.initialize_entity_next = world;
		if(self.classname == "initialize_entity")
		{
			entity e_old;
			e_old = self.enemy;
			remove(self);
			self = e_old;
		}
		dprint("Delayed initialization: ", self.classname, "\n");
		func();
		self = e;
	}
	initialize_entity_first = world;
}

.float uncustomizeentityforclient_set;
.void(void) uncustomizeentityforclient;
void(void) SUB_Nullpointer = #0;
void UncustomizeEntitiesRun()
{
	entity oldself;
	oldself = self;
	for(self = world; (self = findfloat(self, uncustomizeentityforclient_set, 1)); )
		self.uncustomizeentityforclient();
	self = oldself;
}
void SetCustomizer(entity e, float(void) customizer, void(void) uncustomizer)
{
	e.customizeentityforclient = customizer;
	e.uncustomizeentityforclient = uncustomizer;
	e.uncustomizeentityforclient_set = (uncustomizer != SUB_Nullpointer);
}

.float nottargeted;
#define IFTARGETED if(!self.nottargeted && self.targetname != "")

float power2of(float e)
{
	return pow(2, e);
}
float log2of(float x)
{
	// NOTE: generated code
	if(x > 2048)
		if(x > 131072)
			if(x > 1048576)
				if(x > 4194304)
					return 23;
				else
					if(x > 2097152)
						return 22;
					else
						return 21;
			else
				if(x > 524288)
					return 20;
				else
					if(x > 262144)
						return 19;
					else
						return 18;
		else
			if(x > 16384)
				if(x > 65536)
					return 17;
				else
					if(x > 32768)
						return 16;
					else
						return 15;
			else
				if(x > 8192)
					return 14;
				else
					if(x > 4096)
						return 13;
					else
						return 12;
	else
		if(x > 32)
			if(x > 256)
				if(x > 1024)
					return 11;
				else
					if(x > 512)
						return 10;
					else
						return 9;
			else
				if(x > 128)
					return 8;
				else
					if(x > 64)
						return 7;
					else
						return 6;
		else
			if(x > 4)
				if(x > 16)
					return 5;
				else
					if(x > 8)
						return 4;
					else
						return 3;
			else
				if(x > 2)
					return 2;
				else
					if(x > 1)
						return 1;
					else
						return 0;
}

//
// func_breakable 
// - basically func_assault_destructible for general gameplay use
//
float () crandom;
void () SUB_UseTargets, assault_destructible_use, SUB_Remove, SUB_Null;
void LaunchDebris (string debrisname) =
{
	local	entity dbr;
	
	if (debrisname == "" || !debrisname)
		return;
	
	dbr = spawn();
	dbr.origin = self.origin;
	setmodel (dbr, debrisname );
	setsize (dbr, '0 0 0', '0 0 0');
	dbr.velocity_x = 70 * crandom();
	dbr.velocity_y = 70 * crandom();
	dbr.velocity_z = 140 + 70 * random();
	dbr.movetype = MOVETYPE_BOUNCE;
	dbr.solid = SOLID_BBOX;
	dbr.avelocity_x = random()*600;
	dbr.avelocity_y = random()*600;
	dbr.avelocity_z = random()*600;
	dbr.think = SUB_Remove;
	dbr.nextthink = time + 13 + random()*10;
};

.string debris1, debris2, debris3;
.string mdl_dead;
void func_breakable_destroy() {
	if (self.mdl_dead)
		setmodel(self, self.mdl_dead);
	else {
		self.model = "";
		self.solid = SOLID_NOT;
	}
	self.takedamage = DAMAGE_NO;
	
	// now throw around the debris
	LaunchDebris(self.debris1);
	LaunchDebris(self.debris2);
	LaunchDebris(self.debris3);
	
	SUB_UseTargets();
	
	self.event_damage = SUB_Null;
}

void func_breakable_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force) {

	if(self.cnt > 0) {
		self.health = self.health - damage;
		// add pain effects?
	}

	if(self.health < 0) {
		activator = attacker;
		func_breakable_destroy();
	}
}

// destructible walls that can be used to trigger target_objective_decrease
void spawnfunc_func_breakable() {
	if(!self.health)
		self.health = 100;

	self.max_health = self.health;

	//self.cnt = 0; // not yet activated



	self.classname = "func_breakable";	
	self.mdl = self.model;
	setmodel(self, self.mdl);
	
	self.solid = SOLID_BSP;
	
	// precache all the models
	if (self.mdl_dead)
		precache_model(self.mdl_dead);
	if (self.debris1)
		precache_model(self.debris1);
	if (self.debris2)
		precache_model(self.debris2);
	if (self.debris3)
		precache_model(self.debris3);
	
	self.use = assault_destructible_use;	// shared use function, b/c they woudl do the same thing anyways
	self.event_damage = func_breakable_damage;
}

void Net_LinkEntity(entity e)
{
	e.model = "net_entity";
	e.modelindex = 1;
	e.effects = EF_NODEPTHTEST | EF_LOWPRECISION;
}

