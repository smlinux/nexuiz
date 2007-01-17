string campaign_index_var;

void Campaign_Init()
{
	campaign_name = strzone(cvar_string("g_campaign_name"));
	campaign_index_var = strzone(strcat("g_campaign", campaign_name, "_index"));
	CampaignFile_Load(0, CAMPAIGN_MAX_ENTRIES);
}

void Campaign_Shutdown()
{
	CampaignFile_Unload();
	strunzone(campaign_index_var);
	strunzone(campaign_name);
	campaign_name = "";
}

void Campaign_DumpLevels()
{
	float i;
	float imax;
	imax = cvar(campaign_index_var) - campaign_offset;
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
	current = cvar(campaign_index_var);
	if(n > current)
		n = current;
	if(n < 0)
		n = current;

	n = n - campaign_offset;
	if(n >= 0 && n < campaign_entries)
		CampaignSetup(n);
}

float campaign_entry_index;

void() Nex_Action_Campaign_Start =
{
	Campaign_JumpLevel(campaign_entry_index);

	// force the menu to hide
	m_hide();
};

void() Nex_Action_Campaign_Update =
{
	local entity item;
	local string desc;
	local float handle;
	local string line;

	handle = fopen(strcat("maps/campaign", campaign_name, ".txt"), FILE_READ);
	if(handle >= 0) {
		while ((line = fgets(handle))) {
			if(substring(line, 0, 12) == "\"//campaign:") {
				desc = substring(line, 12, (strlen(line) - (12 + 1)));
				break;
			} else {
				continue;
			}
		}
	}
	fclose(handle);

	item = Menu_GetItem("ShortDescriptionCampaign");
	desc = strcat("Campaign: ", desc);
	String_EntitySet(item, text, desc);

	item = Menu_GetItem("ShortDescriptionEntry");
	desc = campaign_shortdesc[campaign_entry_index];
	desc = strcat("Level ", ftos(campaign_entry_index + 1), ": ", desc);
	String_EntitySet(item, text, desc);

	item = Menu_GetItem("LongDescriptionEntry");
	desc = wordwrap(campaign_longdesc[campaign_entry_index], item.wrap - 1);
	String_EntitySet(item, text, desc);

	item = Menu_GetItem("PictureEntry");
	String_EntitySet(item, picture, strcat("maps/",campaign_mapname[campaign_entry_index], ".jpg"));
};

void(float index) Nex_Action_Campaign_Find_Entry =
{
	campaign_entry_index+=index;
	if (campaign_entry_index < 0) campaign_entry_index = min((campaign_entries - 1), cvar(campaign_index_var));
	if (campaign_entry_index > min((campaign_entries - 1), cvar(campaign_index_var))) campaign_entry_index = 0;
}

void() Nex_Action_Campaign_Prev_Entry =
{
	Nex_Action_Campaign_Find_Entry(-1);
	Nex_Action_Campaign_Update();
};

void() Nex_Action_Campaign_Next_Entry =
{
	Nex_Action_Campaign_Find_Entry(1);
	Nex_Action_Campaign_Update();
};

void() Nex_Action_Campaign_Init =
{
	Campaign_Init();

	campaign_entry_index = cvar(campaign_index_var);
	Nex_Action_Campaign_Find_Entry(0); // set campaign_index_var back into range if too high or low

	Nex_Action_Campaign_Update();
};

void(float index) Nex_Action_Campaign_Find_Campaign =
{
	local float handle;
	local float count;
	float i;
	local string filename;
	handle = search_begin("maps/campaign*.txt", true, true);
	if(handle >= 0) {
		count = search_getsize(handle);
		for (i = 0; i < count; i++) {
			filename = search_getfilename(handle, i);
			if (filename == strcat("maps/campaign", campaign_name, ".txt")) {
				index+=i;
				if (index < 0) index = (count - 1);
				if (index > (count - 1)) index = 0;
				filename = search_getfilename(handle, index);
				break;
			}
		}
		count = strlen(filename);
		cvar_set("g_campaign_name", substring(filename, 13, (count - (13 + 4))));
	}
	search_end(handle);
	Nex_Action_Campaign_Init();
}

void() Nex_Action_Campaign_Prev_Campaign =
{
	Nex_Action_Campaign_Find_Campaign(-1);
	Nex_Action_Campaign_Update();
};

void() Nex_Action_Campaign_Next_Campaign =
{
	Nex_Action_Campaign_Find_Campaign(1);
	Nex_Action_Campaign_Update();
};
