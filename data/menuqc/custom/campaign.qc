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
		print(campaign_gametype[i]);
		print("_");
		print(campaign_mapname[i]);
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

float campaign_index;

void() Nex_Action_Campaign_Start =
{
	Campaign_JumpLevel(campaign_index);

	// force the menu to hide
	m_hide();
};

void() Nex_Action_Campaign_Update =
{
	local entity lItem;
	local string longdesc;
	lItem = Menu_GetItem( "ShortDescription" );
	String_EntitySet( lItem, text, campaign_shortdesc[campaign_index] );

	lItem = Menu_GetItem( "LongDescription" );
	longdesc = Campaign_wordwrap(campaign_longdesc[campaign_index], lItem.wrap);
	String_EntitySet( lItem, text, longdesc );

	lItem = Menu_GetItem( "Picture" );
	String_EntitySet( lItem, picture, strcat("maps/",campaign_mapname[campaign_index], ".jpg") );
};

void() Nex_Action_Campaign_Init =
{
	campaign_index = cvar("g_campaign_index");

	Nex_Action_Campaign_Update();
};

void() Nex_Action_Campaign_Prev =
{
	if (campaign_index <= 0) {
		campaign_index = min(campaign_entries, cvar("g_campaign_index"));
	} else {
		campaign_index -= 1;
	}

	Nex_Action_Campaign_Update();
};

void() Nex_Action_Campaign_Next =
{
	if (campaign_index >= min(campaign_entries, cvar("g_campaign_index"))) {
		campaign_index = 0;
	} else {
		campaign_index += 1;
	}

	Nex_Action_Campaign_Update();
};

