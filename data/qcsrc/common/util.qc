
string wordwrap(string s, float l)
{
	local string t, c;
	local float lleft, i, j, wlen;

	s = strzone(s);
	t = "";
	lleft = l;
	for (i = 0;i < strlen(s);i++)
	{
		if (substring(s, i, 2) == "\\n")
		{
			t = strcat(t, "\n");
			lleft = l;
			i++;
		}
		else if (substring(s, i, 1) == " ")
		{
			if (lleft > 0)
			{
				t = strcat(t, " ");
				lleft = lleft - 1;
			}
		}
		else
		{
			for (j = i;j < strlen(s);j++)
			{
				c = substring(s, j, 1);
				if (c == " ")
					break;
				if (c == "\\")
					if(j+1 < strlen(s))
						break;
				// we need to keep this tempstring alive even if substring is
				// called repeatedly, so call strcat even though we're not
				// doing anything
				t = strcat(t);
			}
			wlen = j - i;
			if (lleft < wlen)
			{
				t = strcat(t, "\n");
				lleft = l;
			}
			t = strcat(t, substring(s, i, wlen));
			lleft = lleft - wlen;
			i = j - 1;
		}
	}
	strunzone(s);
	return t;

/*
	string t;
	string word;

	float lleft;
	float i;

	float startidx;

	startidx = 0;

	t = "";
	word = "";
	for (i = 0;i < strlen(s);i++)
	{
		c = substring(s, i, 1);
		forceflush = false;
		if (c == " ")
			dowhat = 0;
		else if (c == "\\" && substring(s, i + 1, 1) == "n")
			dowhat = 1;
		else
		{
			dowhat = 2;
			word = strcat(word, c);
		}

		if (dowhat < 2)
		{
			// a space may add some whitespace to the output, and flushes the word buffer
			if (word != "")
			{
				if (lleft < strlen(word) + 1)
				{
					// add a newline
					t = strcat(t, "\n");
					lleft = l;
				}
				else
				{
					// otherwise just add a space if there's already text in
					// this line
					if (lleft != l)
						t = strcat(t, " ");
				}
				t = strcat(t, word);
				word = "";
			}
			if (dowhat == 0)
			{
				// if this is a double space, add the space
				if (lleft)
					t = strcat(t, " ");
			}
			else if (dowhat == 1)
			{
				t = strcat(t, "\n");
				lleft = l;
			}
		}
		// we need to keep these tempstrings alive even if substring is
		// called repeatedly, so call strcat even though we're not doing
		// anything
		t = strcat(t);
		word = strcat(word);
	}
	return t;
*/

/*
	string t;
	string word;

	float lleft;
	float i;

	float startidx;

	startidx = 0;

	t = "";

	lleft = l;
	for(i = 0; i <= strlen(s); ++i)
	{
		if(i != strlen(s) && substring(s, i, 1) != " ")
		{
			// we need to keep this tempstring alive even if substring is
			// called repeatedly, so call strcat even though we're not doing
			// anything
			t = strcat(t);
			continue;
		}

		word = substring(s, startidx, i - startidx);
		startidx = i + 1;

		if(word == "+++")
		{
			t = strcat(t, "\n\n");
			lleft = l;
		}
		else if(!l || (strlen(word) < lleft))
		{
			if(lleft != l)
			{
				t = strcat(t, " ");
				lleft = lleft - 1;
			}
			t = strcat(t, word);
			lleft = lleft - strlen(word);
		}
		else
		{
			t = strcat(t, "\n", word);
			lleft = l - strlen(word);
		}
	}
	return t;
*/
}

float dist_point_line(vector p, vector l0, vector ldir)
{
	ldir = normalize(ldir);
	
	// remove the component in line direction
	p = p - (p * ldir) * ldir;

	// vlen of the remaining vector
	return vlen(p);
}
