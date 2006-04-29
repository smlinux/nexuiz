// CampaignFileLoad(offset, n)
// - Loads campaign level data (up to n entries starting at offset)
//   into the globals
// - Returns the number of entries successfully read
float CampaignFile_Load(float offset, float n)
{
	float fh;
	float lineno;
	float entlen;
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
				if(entlen != 7)
					error("syntax error in campaign file");

				campaign_mapcfgname[campaign_entries] = strzone(argv(0));
				campaign_bots[campaign_entries] = stof(argv(1));
				campaign_botskill[campaign_entries] = stof(argv(2));
				campaign_fraglimit[campaign_entries] = stof(argv(3));
				campaign_mutators[campaign_entries] = strzone(argv(4));
				campaign_shortdesc[campaign_entries] = strzone(argv(5));
				campaign_longdesc[campaign_entries] = strzone(argv(6));
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
		strunzone(campaign_mapcfgname[i]);
		strunzone(campaign_mutators[i]);
		strunzone(campaign_shortdesc[i]);
		strunzone(campaign_longdesc[i]);
	}
	campaign_entries = 0;
}
