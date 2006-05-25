// CampaignFileLoad(offset, n)
// - Loads campaign level data (up to n entries starting at offset)
//   into the globals
// - Returns the number of entries successfully read
float CampaignFile_Load(float offset, float n)
{
	float fh;
	float lineno;
	float entlen;
	float i;
	string l;

	if(n > CAMPAIGN_MAX_ENTRIES)
		n = CAMPAIGN_MAX_ENTRIES;

	campaign_offset = offset;
	campaign_entries = 0;

	fh = fopen("maps/campaign.txt", FILE_READ);
	if(fh >= 0)
	{
		for(lineno = 0; (l = fgets(fh)); )
		{
			if(strlen(l) == 0)
				continue; // empty line
			if(substring(l, 0, 2) == "//")
				continue; // comment
			if(lineno >= offset)
			{
				entlen = tokenize(l);
				if(entlen != 8)
					error("syntax error in campaign file");

				i = 0;
				campaign_gametype[campaign_entries] = strzone(argv(i++));
				campaign_mapname[campaign_entries] = strzone(argv(i++));
				campaign_bots[campaign_entries] = stof(argv(i++));
				campaign_botskill[campaign_entries] = stof(argv(i++));
				campaign_fraglimit[campaign_entries] = stof(argv(i++));
				campaign_mutators[campaign_entries] = strzone(argv(i++));
				campaign_shortdesc[campaign_entries] = strzone(argv(i++));
				campaign_longdesc[campaign_entries] = strzone(argv(i++));
				campaign_entries = campaign_entries + 1;

				if(campaign_entries >= n)
					break;
			}
			lineno = lineno + 1;
		}
		fclose(fh);
	}

	return campaign_entries;
}

void CampaignFile_Unload()
{
	float i;
	for(i = 0; i < campaign_entries; ++i)
	{
		strunzone(campaign_gametype[i]);
		strunzone(campaign_mapname[i]);
		strunzone(campaign_mutators[i]);
		strunzone(campaign_shortdesc[i]);
		strunzone(campaign_longdesc[i]);
	}
	campaign_entries = 0;
}


// stuff to handle the campaign_longdesc field
string fstrunzone(string s)
{
	string t;
	t = strcat(s);
	strunzone(s);
	return t;
}

// NOTE: s may not be a tempstring here
string Campaign_wordwrap(string s, float l)
{
	string t;
	string word;

	float lleft;
	float i;

	float startidx;

	startidx = 0;

	t = strzone("");

	lleft = l;
	for(i = 0; i <= strlen(s); ++i)
	{
		if(i != strlen(s) && substring(s, i, 1) != " ")
			continue;

		word = substring(s, startidx, i - startidx);
		startidx = i + 1;
		
		if(word == "+++")
		{
			t = fstrunzone(t);
			t = strzone(strcat(t, "\n\n"));
			lleft = l;
		}
		else if(!l || (strlen(word) < lleft))
		{
			t = fstrunzone(t);
			if(lleft != l)
			{
				t = strcat(t, " ");
				lleft = lleft - 1;
			}
			t = strzone(strcat(t, word));
			lleft = lleft - strlen(word);
		}
		else
		{
			t = fstrunzone(t);
			t = strzone(strcat(t, "\n", word));
			lleft = l - strlen(word);
		}
	}
	t = fstrunzone(t);
	return t;
}

