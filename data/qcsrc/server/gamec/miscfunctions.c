string W_Name(float weaponid);
float(float index) weapon_translateindextoflag;

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
