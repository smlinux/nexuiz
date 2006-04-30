void Campaign_Init()
{
	CampaignFile_Load(0, CAMPAIGN_MAX_ENTRIES);
}

void Campaign_Shutdown()
{
	CampaignFile_Unload();
}

void Campaign_DumpLevels()
{
	float i;
	float imax;
	imax = cvar("g_campaign_index") - campaign_offset;
	if(imax >= campaign_entries)
		imax = campaign_entries - 1;
	for(i = 0; i <= imax; ++i)
	{
		print("Level ");
		print(ftos(i + campaign_offset));
		print(": ");
		print(campaign_mapcfgname[i]);
		print(" - ");
		print(campaign_shortdesc[i]);
		print("\n");
	}
	print("\n");
}

void Campaign_JumpLevel(float n)
{
	float current;
	// 1. current level?
	current = cvar("g_campaign_index");
	if(n > current)
		n = current;
	if(n < 0)
		n = current;
	
	n = n - campaign_offset;
	if(n >= 0 && n < campaign_entries)
		CampaignSetup(n);
}
