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

	if(cvar("sv_logspam_console"))
	{
		ServerConsoleEcho(s, check_dangerous);
	}
	if(cvar("sv_logspam_files"))
	{
		if(!logfile_open)
		{
			logfile_open = TRUE;
			matches = cvar("sv_logspam_files_counter") + 1;
			cvar_set("sv_logspam_files_counter", ftos(matches));
			fn = ftos(matches);
			if(strlen(fn) < 8)
				fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
			fn = strcat(cvar_string("sv_logspam_files_nameprefix"), fn, cvar_string("sv_logspam_files_namesuffix"));
			logfile = fopen(fn, FILE_APPEND);
			dprint(strcat("\n\n\n\n**********\nlogfile id: ", ftos(logfile), "\n\n\n"));
		}
		if(logfile >= 0)
			fputs(logfile, strcat(s, "\n"));
	}
}

void(string s, float check_dangerous) GameLogInit =
{
	logfile_open = 0;
	// will be opened later
}

void(string s, float check_dangerous) GameLogClose =
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
