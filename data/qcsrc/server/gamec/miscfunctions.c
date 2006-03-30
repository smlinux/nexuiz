string W_Name(float weaponid);

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
