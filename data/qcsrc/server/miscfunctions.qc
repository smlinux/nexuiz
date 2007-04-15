#define FOR_EACH_CLIENT(v) for(v = world; (v = findflags(v, flags, FL_CLIENT)) != world; )
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
string STR_PLAYER = "player";
#define FOR_EACH_PLAYER(v) for(v = world; (v = find(v, classname, STR_PLAYER)) != world; )
#define FOR_EACH_REALPLAYER(v) FOR_EACH_PLAYER(v) if(clienttype(v) == CLIENTTYPE_REAL)

// change that to actually calling strcat when running on an engine without
// unlimited tempstrings:
// string strcat1(string s) = #115; // FRIK_FILE
#define strcat1(s) (s)

float logfile_open;
float logfile;

void(string s) bcenterprint
{
	// TODO replace by MSG_ALL (would show it to spectators too, though)?
	entity head;
	FOR_EACH_PLAYER(head)
		if(clienttype(head) == CLIENTTYPE_REAL)
			centerprint(head, s);
}

void(string s, float check_dangerous) ServerConsoleEcho =
{
	local string ch;
	if (checkextension("DP_SV_PRINT"))
		print(s, "\n");
	else
	{
		localcmd("echo \"");
		if(check_dangerous)
		{
			while(strlen(s))
			{
				ch = substring(s, 0, 1);
				if(ch != "\"" && ch != "\r" && ch != "\n")
					localcmd(ch);
				s = substring(s, 1, strlen(s) - 1);
			}
		}
		else
		{
			localcmd(s);
		}
		localcmd("\"\n");
	}
}

void(string s, float check_dangerous) GameLogEcho =
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
		}
		if(logfile >= 0)
			fputs(logfile, strcat(s, "\n"));
	}
	if(cvar("sv_eventlog_console"))
	{
		ServerConsoleEcho(s, check_dangerous);
	}
}

void() GameLogInit =
{
	logfile_open = 0;
	// will be opened later
}

void() GameLogClose =
{
	if(logfile_open && logfile >= 0)
	{
		fclose(logfile);
		logfile = -1;
	}
}

float math_mod(float a, float b)
{
	return a - (floor(a / b) * b);
}

void relocate_spawnpoint()
{
	// nudge off the floor
	setorigin(self, self.origin + '0 0 1');

	tracebox(self.origin, PL_MIN, PL_MAX, self.origin, TRUE, self);
	if (trace_startsolid)
	{
		objerror("player spawn point in solid, mapper sucks!\n");
		return;
	}
}

// NOTE: DO NOT USE THIS FUNCTION TOO OFTEN.
// IT WILL MOST PROBABLY DESTROY _ALL_ OTHER TEMP
// STRINGS AND TAKE QUITE LONG. haystack and needle MUST
// BE CONSTANT OR strzoneD!
float(string haystack, string needle, float offset) strstr =
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

float NUM_NEAREST_ENTITIES = 4;
entity nearest_entity[NUM_NEAREST_ENTITIES];
float nearest_length[NUM_NEAREST_ENTITIES];
entity(vector point, .string field, string value, vector axismod) findnearest =
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

void() target_location =
{
	self.classname = "target_location";
	// location name in netname
	// eventually support: count, teamgame selectors, line of sight?
};

void() info_location =
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

string(string msg) formatmessage =
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
void GetCvars_handleString(float f, .string field, string name)
{
	if(f < 0)
	{
		if(self.field)
			strunzone(self.field);
	}
	else if(f > 0)
	{
		if(argv(f) == name)
		{
			if(self.field)
				strunzone(self.field);
			self.field = strzone(argv(f + 1));
		}
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
void GetCvars_handleFloat(float f, .float field, string name)
{
	if(f < 0)
	{
	}
	else if(f > 0)
	{
		if(argv(f) == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("sendcvar ", name, "\n"));
}
void GetCvars(float f)
{
	GetCvars_handleFloat(f, autoswitch, "cl_autoswitch");
	GetCvars_handleFloat(f, cvar_cl_hidewaypoints, "cl_hidewaypoints");
	GetCvars_handleFloat(f, cvar_cl_zoomfactor, "cl_zoomfactor");
	GetCvars_handleFloat(f, cvar_cl_zoomspeed, "cl_zoomspeed");
	GetCvars_handleFloat(f, cvar_cl_playerdetailreduction, "cl_playerdetailreduction");
	GetCvars_handleFloat(f, cvar_cl_nogibs, "cl_nogibs");
	GetCvars_handleFloat(f, cvar_scr_centertime, "scr_centertime");
	GetCvars_handleFloat(f, cvar_cl_shownames, "cl_shownames");
	GetCvars_handleString(f, cvar_g_nexuizversion, "g_nexuizversion");
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

void DistributeFragsAmongTeam(entity p, float targetteam, float factor)
{
	float f;
	float d;
	float nTeam;
	entity head;

	if(!teams_matter)
		return;

	//if(p.frags < 0)
	//{
	//	p.frags = 0; // do not harm the new team!
	//	return; // won't distribute negative scores
	//}

	if(p.frags == -666)
		return;

	f = ceil(factor * p.frags);
	p.frags = p.frags - f;

	nTeam = 0;
	FOR_EACH_PLAYER(head)
		if(head != p)
			if(head.team == targetteam)
				nTeam = nTeam + 1;

	if(nTeam == 0)
		return;

	FOR_EACH_PLAYER(head)
		if(head != p)
			if(head.team == targetteam)
			{
				d = floor(f / nTeam);
				head.frags = head.frags + d;
				f = f - d;
				nTeam = nTeam - 1;
			}

	if(nTeam != 0)
		error("nPlayers in team changed!");
	if(f != 0)
		error(strcat("There were ", ftos(f), " frags left. BAD!"));
}

string Team_ColorCode(float teamid)
{
	if(teamid == COLOR_TEAM1)
		return "^1";
	else if(teamid == COLOR_TEAM2)
		return "^4";
	else if(teamid == COLOR_TEAM3)
		return "^6";
	else if(teamid == COLOR_TEAM4)
		return "^3";
	else
		return "^7";
}

string decolorize(string s)
{
	string out;
	out = "";
	while(s != "")
	{
		float n;
		string ch1, ch2;
		n = 1;
		ch1 = substring(s, 0, 1);
		ch2 = substring(s, 1, 1);
		if(ch1 == "^")
		{
			n = 2;
			if(ch2 == "^")
				out = strcat(out, "^^");
			else if(ch2 == "0")
				out = strcat1(out);
			else if(ch2 == "1")
				out = strcat1(out);
			else if(ch2 == "2")
				out = strcat1(out);
			else if(ch2 == "3")
				out = strcat1(out);
			else if(ch2 == "4")
				out = strcat1(out);
			else if(ch2 == "5")
				out = strcat1(out);
			else if(ch2 == "6")
				out = strcat1(out);
			else if(ch2 == "7")
				out = strcat1(out);
			else if(ch2 == "8")
				out = strcat1(out);
			else if(ch2 == "9")
				out = strcat1(out);
			else
			{
				n = 1;
				out = strcat(out, "^^");
			}
			s = substring(s, n, strlen(s) - n);
		}
		else
		{
			s = substring(s, 1, strlen(s) - 1);
			out = strcat(out, ch1);
		}
	}
	return out;
}
#define strdecolorize(s) decolorize(s)
#define strlennocol(s) strlen(decolorize(s))

#define CENTERPRIO_POINT 1
#define CENTERPRIO_REBALANCE 2
#define CENTERPRIO_VOTE 4
#define CENTERPRIO_NORMAL 5
#define CENTERPRIO_MAPVOTE 9
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

void VoteNag();

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

// requires that m2>m1 in all coordinates, and that m4>m3
float(vector m1, vector m2, vector m3, vector m4) boxesoverlap = {return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z;};

// requires the same, but is a stronger condition
float(vector smins, vector smaxs, vector bmins, vector bmaxs) boxinsidebox = {return smins_x >= bmins_x && smaxs_x <= bmaxs_x && smins_y >= bmins_y && smaxs_y <= bmaxs_y && smins_z >= bmins_z && smaxs_z <= bmaxs_z;};

float g_pickup_shells;
float g_pickup_shells_max;
float g_pickup_nails;
float g_pickup_nails_max;
float g_pickup_rockets;
float g_pickup_rockets_max;
float g_pickup_cells;
float g_pickup_cells_max;
float g_pickup_armorshard;
float g_pickup_armorshard_max;
float g_pickup_armor;
float g_pickup_armor_max;
float g_pickup_healthshard;
float g_pickup_healthshard_max;
float g_pickup_health;
float g_pickup_health_max;
float g_pickup_healthmega;
float g_pickup_healthmega_max;

void readlevelcvars(void)
{
	g_pickup_shells                    = cvar("g_pickup_shells");
	g_pickup_shells_max                = cvar("g_pickup_shells_max");
	g_pickup_nails                     = cvar("g_pickup_nails");
	g_pickup_nails_max                 = cvar("g_pickup_nails_max");
	g_pickup_rockets                   = cvar("g_pickup_rockets");
	g_pickup_rockets_max               = cvar("g_pickup_rockets_max");
	g_pickup_cells                     = cvar("g_pickup_cells");
	g_pickup_cells_max                 = cvar("g_pickup_cells_max");
	g_pickup_armorshard                = cvar("g_pickup_armorshard");
	g_pickup_armorshard_max            = cvar("g_pickup_armorshard_max");
	g_pickup_armor                     = cvar("g_pickup_armor");
	g_pickup_armor_max                 = cvar("g_pickup_armor_max");
	g_pickup_healthshard               = cvar("g_pickup_healthshard");
	g_pickup_healthshard_max           = cvar("g_pickup_healthshard_max");
	g_pickup_health                    = cvar("g_pickup_health");
	g_pickup_health_max                = cvar("g_pickup_health_max");
	g_pickup_healthmega                = cvar("g_pickup_healthmega");
	g_pickup_healthmega_max            = cvar("g_pickup_healthmega_max");
}
