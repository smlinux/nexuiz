string wordwrap_buffer;

void wordwrap_buffer_put(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
}

string wordwrap(string s, float l)
{
	wordwrap_buffer = "";
	wordwrap_cb(s, l, wordwrap_buffer_put);
	return wordwrap_buffer;
}

#ifndef MENUQC
void wordwrap_buffer_sprint(string s)
{
	wordwrap_buffer = strcat(wordwrap_buffer, s);
	if(s == "\n")
	{
		sprint(self, wordwrap_buffer);
		wordwrap_buffer = "";
	}
}

void wordwrap_sprint(string s, float l)
{
	wordwrap_buffer = "";
	wordwrap_cb(s, l, wordwrap_buffer_sprint);
	if(wordwrap_buffer != "")
		sprint(self, strcat(wordwrap_buffer, "\n"));
	return;
}
#endif

void wordwrap_cb(string s, float l, void(string) callback)
{
	local string c;
	local float lleft, i, j, wlen;

	s = strzone(s);
	lleft = l;
	for (i = 0;i < strlen(s);i++)
	{
		if (substring(s, i, 2) == "\\n")
		{
			callback("\n");
			lleft = l;
			i++;
		}
		else if (substring(s, i, 1) == " ")
		{
			if (lleft > 0)
			{
				callback(" ");
				lleft = lleft - 1;
			}
		}
		else
		{
			for (j = i+1;j < strlen(s);j++)
				//    ^^ this skips over the first character of a word, which
				//       is ALWAYS part of the word
				//       this is safe since if i+1 == strlen(s), i will become
				//       strlen(s)-1 at the end of this block and the function
				//       will terminate. A space can't be the first character we
				//       read here, and neither can a \n be the start, since these
				//       two cases have been handled above.
			{
				c = substring(s, j, 1);
				if (c == " ")
					break;
				if (c == "\\")
					break;
				// we need to keep this tempstring alive even if substring is
				// called repeatedly, so call strcat even though we're not
				// doing anything
				callback("");
			}
			wlen = j - i;
			if (lleft < wlen)
			{
				callback("\n");
				lleft = l;
			}
			callback(substring(s, i, wlen));
			lleft = lleft - wlen;
			i = j - 1;
		}
	}
	strunzone(s);
}

float dist_point_line(vector p, vector l0, vector ldir)
{
	ldir = normalize(ldir);
	
	// remove the component in line direction
	p = p - (p * ldir) * ldir;

	// vlen of the remaining vector
	return vlen(p);
}

void depthfirst(entity start, .entity up, .entity downleft, .entity right, void(entity, entity) funcPre, void(entity, entity) funcPost, entity pass)
{
	entity e;
	e = start;
	funcPre(pass, e);
	while(e.downleft)
	{
		e = e.downleft;
		funcPre(pass, e);
	}
	funcPost(pass, e);
	while(e != start)
	{
		if(e.right)
		{
			e = e.right;
			funcPre(pass, e);
			while(e.downleft)
			{
				e = e.downleft;
				funcPre(pass, e);
			}
		}
		else
			e = e.up;
		funcPost(pass, e);
	}
}

float median(float a, float b, float c)
{
	if(a < c)
		return bound(a, b, c);
	return bound(c, b, a);
}

// converts a number to a string with the indicated number of decimals
// works for up to 10 decimals!
string ftos_decimals(float number, float decimals)
{
	string result;
	string tmp;
	float len;

	// if negative, cut off the sign first
	if(number < 0)
		return strcat("-", ftos_decimals(-number, decimals));
	// it now is always positive!

	// 3.516 -> 352
	number = floor(number * pow(10, decimals) + 0.5);

	// 352 -> "352"
	result = ftos(number);
	len = strlen(result);
	// does it have a decimal point (should not happen)? If there is one, it is always at len-7)
		// if ftos had fucked it up, which should never happen: "34278.000000"
	if(len >= 7)
		if(substring(result, len - 7, 1) == ".")
		{
			dprint("ftos(integer) has comma? Can't be. Affected result: ", result, "\n");
			result = substring(result, 0, len - 7);
			len -= 7;
		}
		// "34278"
	if(decimals == 0)
		return result; // don't insert a point for zero decimals
	// is it too short? If yes, insert leading zeroes
	if(len <= decimals)
	{
		result = strcat(substring("0000000000", 0, decimals - len + 1), result);
		len = decimals + 1;
	}
	// and now... INSERT THE POINT!
	tmp = substring(result, len - decimals, decimals);
	result = strcat(substring(result, 0, len - decimals), ".", tmp);
	return result;
}
