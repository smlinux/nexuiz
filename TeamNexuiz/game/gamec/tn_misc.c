/*-----===================================-------
		Team:Nexuiz Misc. Items/Functions
				-=[ by avirox ]=-
-------===================================-----*/

// Ice/Slippery ground
.vector area_min;
.vector area_max;
.float slip_time;
.float slip_amount;

void () slippery_touch =
{
	other.slip_time = time + .2;				// amount of time the player is slipping (this gets constantly updated)
	other.slip_amount = self.slip_amount;		// handled in cl_physics.c
};

void () func_slippery =
{
	if (self.area_min != '0 0 0')
	{
		setsize(self, self.area_min, self.area_max);
	}
	else
	{
		setsize(self, '-16 -16 -24', '16 16 32');
	}
	self.solid = SOLID_TRIGGER;
	self.touch = slippery_touch;
};

void () func_ice =
{
	self.classname = "func_slippery";
	func_slippery();
};

// XavioR's QuakeC String Tools
// Copyright Team:Nexuiz (2006)
float(string s) strlen;/* = #114;*/ // returns how many characters are in a string
float (string st, string findme) SearchString =
{
	local float stleng;		// string length
	local float stpos;		// start part of the string to check
	local string srcstr;		// search string
	stleng = strlen(findme);

	stpos = 0;
	srcstr = substring(st, stpos, stleng);
	while (srcstr != "")
	{
		srcstr = substring(st, stpos, stleng);
		if (srcstr == findme)
			return (stpos);
		else
			stpos = stpos + 1;
	}
	return (-1);			// -1 being "NOT FOUND"
};

// Returns the value of a string after the "=" of properties such as "health" or "ammo_cells" etc
float (string st, string valueof, float stpos) ValueString =
{
	local float posneg;		// is it positive or negative
	local float stleng;		// string length
	local float stpos2;
	local string fdigit;		// finds the digits
	local string totalstring;	// total value
	stleng = strlen(valueof);
	stpos2 = stpos + stleng + 1;		// this puts us at "property="
	fdigit = substring(st, stpos2, 1);			// now we look for a "+" or a "-" (IE health=+2 etc)
	if (fdigit = "-")
		posneg = -1;
	else
		posneg = 1;

	stpos2 = stpos2 + 1;			// this puts us at "property=+" or "property=-"
	fdigit = substring(st, stpos2, 1);			// find the first digit..
	while (fdigit != "" || fdigit != ",")
	{
		totalstring = strcat(totalstring, fdigit);		//combine the digits..
		stpos2 = stpos2 + 1;
		fdigit = substring(st, stpos2, 1);
		if (fdigit == "" || fdigit == ",")
			return (stof(totalstring) * posneg);
	}
	return (stof(totalstring) * posneg);
};

// Replace String - Replaces a part of a string value
string (string st, string findme, string replacewith) ReplaceString =
{
	local float stleng;		// string length
	local float stpos;		// starting position of the string to replace
	local string st1;		// first half of the string
	local string st2;		// last half of the string
	local string resultstring;	// result of the combination

	stleng = strlen(findme);		// find the length of the string
	stpos = SearchString(st, findme);		// find where the string begins
	if (stpos == -1)
	{
		bprint(strcat("Warning: Value not found in string: ",findme,"\n"));
		return (st);
	}
	bprint(strcat(ftos(stpos),"\n"));
	st1 = substring(st, 0, stpos);
	st2 = substring(st, stpos + stleng, -1);	
	resultstring = strcat(st1, replacewith, st2);
	bprint(strcat(resultstring,"\n"));
	return(resultstring);
};
