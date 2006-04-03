string W_Name(float weaponid);
float(float index) weapon_translateindextoflag;

void(string s) ServerConsoleEcho =
{
	local string ch;
	local string str;
	localcmd(strcat("echo \"", s));
	while(strlen(str))
	{
		ch = substring(str, 0, 1);
		if(ch != "\"" && ch != "\r" && ch != "\n")
			localcmd(ch);
		str = substring(str, 1, strlen(str) - 1);
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
