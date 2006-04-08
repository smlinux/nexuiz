string W_Name(float weaponid);
float(float index) weapon_translateindextoflag;

float logfile_open;
float logfile;

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

	t = "";
	while(l < strlen(s))
	{
		t = strcat(t, substring(s, 0, l), "\n");
		s = substring(s, l+1, strlen(s));
	}
	return strcat(t, s);
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
	if(self.noalign)
		return;

	setorigin(self, find_floor(self.origin) + '0 0 30');
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

entity(vector point, .string field, string value, vector axismod) findnearest =
{
	entity localhead;
	entity best;
	float bestlen;

	float len;
	vector dist;

	best = world;
	bestlen = 10000;
	localhead = find(world, field, value);
	while(localhead)
	{
		if((localhead.items == IT_KEY1 || localhead.items == IT_KEY2) && localhead.target = "###item###")
			dist = localhead.oldorigin;
		else
			dist = localhead.origin;
		dist = dist - point;
		dist = dist_x * axismod_x * '1 0 0' + dist_y * axismod_y * '0 1 0' + dist_z * axismod_z * '0 0 1';
		len = vlen(dist);
		if(len < bestlen)
		{
			bestlen = len;
			best = localhead;
		}
		localhead = find(localhead, field, value);
	}
	return best;
}

string(string msg) formatmessage =
{
	float p;
	string msg_save;
	string escape;
	string replacement;
	msg_save = strzone(msg);
	p = 0;
	while(1)
	{
		p = strstr(msg_save, "%", p);
		if(p < 0)
			break;
		replacement = substring(msg_save, p, 2);
		escape = substring(msg_save, p + 1, 1);
		if(escape == "a")
			replacement = ftos(floor(self.armorvalue));
		else if(escape == "h")
			replacement = ftos(floor(self.health));
		else if(escape == "l")
		{
			entity loc;
			loc = findnearest(self.origin, classname, "info_location", '1 1 1');
			if(!loc)
				loc = findnearest(self.origin, target, "###item###", '1 1 4');
			if(loc)
				replacement = loc.netname;
			else
				replacement = "someplace";
		}
		else if(escape == "x")
		{
			if(self.cursor_trace_ent)
				replacement = self.cursor_trace_ent.netname;
			else
				replacement = "nothing";
		}
		dprint(strcat(ftos(p), "<", msg, "\n"));
		msg = strcat(substring(msg_save, 0, p), replacement);
		msg = strcat(msg, substring(msg_save, p+2, strlen(msg_save) - (p+2)));
		dprint(strcat(ftos(p), ">", msg, "\n"));
		strunzone(msg_save);
		msg_save = strzone(msg);
		p = p + 2;
	}
	strunzone(msg_save);
	return msg;
}
