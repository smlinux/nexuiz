string W_Name(float weaponid);
float(float index) weapon_translateindextoflag;

float logfile_open;
float logfile;

void(string s) bcenterprint
{
	entity head;
	head = find(world, classname, "player");
	while(head)
	{
		if(clienttype(head) == CLIENTTYPE_REAL)
			centerprint(head, s);
		head = find(head, classname, "player");
	}
}

void(string s, float check_dangerous) ServerConsoleEcho =
{
	local string ch;
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

string linewrap(string s, float l)
{
	string t;

/*
	t = "";
	while(l < strlen(s))
	{
		t = strcat(t, substring(s, 0, l), "\n");
		s = substring(s, l+1, strlen(s));
	}
	return strcat(t, s);
*/
	// this function seems broken (character wrap, no word wrap)
	// use WORD wrap instead... importing it from campaign code
	s = strzone(s);
	t = Campaign_wordwrap(s, l);
	strunzone(s);
	return t;
}

vector find_floor(vector org)
{
	traceline(org + '0 0 5', org - '0 0 255', TRUE, self);
	if (trace_fraction < 1)
		return trace_endpos;
	else
		return org;
}

void relocate_spawnpoint()
{
	vector org, loc;
	string error_msg;

	error_msg = "spawn point too close to a wall";
	
	org = find_floor(self.origin) + '0 0 30';

	traceline(org, org - '18 0 0', TRUE, world);
	if(trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline(loc, loc + '36 0 0', TRUE, world);
		if(trace_fraction >= 1 && !self.noalign)
			org = loc + '18 0 0';
		else
		{
			objerror(error_msg);
			return;
		}
	}

	traceline (org, org - '-18 0 0', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '-36 0 0', TRUE, world);
		if(trace_fraction >= 1 && !self.noalign)
			org = loc + '-18 0 0';
		else
		{
			objerror(error_msg);
			return;
		}
	}

	traceline (org, org - '0 18 0' , TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 36 0', TRUE, world);
		if(trace_fraction >= 1 && !self.noalign)
			org = loc + '0 18 0';
		else
		{			
			objerror(error_msg);
			return;
		}
	}

	traceline (org, org - '0 -18 0', TRUE, world);
	if (trace_fraction < 1)
	{
		loc = trace_endpos;
		traceline (loc, loc + '0 -36 0', TRUE, world);
		if(trace_fraction >= 1 && !self.noalign)
			org = loc + '0 -18 0';
		else
		{
			objerror(error_msg);
			return;
		}
	}
	
	if(!self.noalign)
		setorigin(self, org);
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
	while(offset < endpos)
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
		msg = strcat(substring(msg_save, 0, p), replacement);
		msg = strcat(msg, substring(msg_save, p+2, strlen(msg_save) - (p+2)));
		strunzone(msg_save);
		msg_save = strzone(msg);
		p = p + 2;
	}
	msg = strcat(msg_save);
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
	if(f)
	{
		if(argv(f) == name)
			self.field = argv(f + 1);
	}
	else
		stuffcmd(self, strcat("cmd reportcvar ", name, " $", name, "\n"));
}
void GetCvars_handleFloat(float f, .float field, string name)
{
	if(f)
	{
		if(argv(f) == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("cmd reportcvar ", name, " $", name, "\n"));
}
void GetCvars(float f)
{
	GetCvars_handleFloat(f, cvar_cl_playerdetailreduction, "cl_playerdetailreduction");
	GetCvars_handleFloat(f, cvar_cl_nogibs, "cl_nogibs");
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
