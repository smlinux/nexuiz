// campaign cvars:
//   _campaign_index: index of CURRENT map
//   g_campaign_index: index of current LAST map (saved)
//   g_campaign_skill: bot skill offset

float campaign_level;
float campaign_won;

void(string s) CampaignBailout =
{
	cvar_set("g_campaign", "0");
	bprint(strcat("campaign initialization failed: ", s, "\n"));
	//error(strcat("campaign initialization failed: ", s, "\n"));
	return;
}

void() CampaignPreInit =
{
	float baseskill;
	string title;
	campaign_level = cvar("_campaign_index");
	CampaignFile_Load(campaign_level, 2);
	if(campaign_entries < 1)
		return CampaignBailout("unknown map");
	cvar_set("bot_number", ftos(campaign_bots[0]));

	baseskill = cvar("g_campaign_skill");
	baseskill = baseskill + campaign_botskill[0];
	if(baseskill < 0)
		baseskill = 0;
	cvar_set("skill", ftos(baseskill));

	cvar_set("sv_public", "0");
	cvar_set("pausable", "1");

	title = campaign_shortdesc[0];
	title = strzone(strcat("Level ", ftos(campaign_level + 1), ": ", title));
	campaign_message = strzone(strcat("\n\n\n\n\n\n\n\n\n\n^1\n", title, "\n^3\n", Campaign_wordwrap(campaign_longdesc[0], 50), "\n\n^1press jump to enter the game"));
	strunzone(title);
}

string GetMapname();
void() CampaignPostInit =
{
	// now some sanity checks
	string thismapname, wantedmapname;
	thismapname = GetMapname();
	wantedmapname = campaign_gametype[0];
	wantedmapname = strcat(wantedmapname, "_", campaign_mapname[0]);
	if(wantedmapname != thismapname)
		return CampaignBailout(strcat("wrong map: ", wantedmapname, " != ", thismapname));
	cvar_set("fraglimit", ftos(campaign_fraglimit[0]));
	cvar_set("timelimit", "0");
}

void() CampaignPreIntermission =
{
	entity head;
	float won;
	float lost;

	won = 0;
	
	head = findchain(classname, "player");
	while(head)
	{
		if(clienttype(head) == CLIENTTYPE_REAL)
		{
			if(head.winning)
				won = won + 1;
			else
				lost = lost + 1;
		}
		head = head.chain;
	}

	if(won == 1 && lost == 0)
	{
		campaign_won = 1;
		bprint("The current level has been WON.\n");
		// sound!
	}
	else
	{
		campaign_won = 0;
		bprint("The current level has been LOST.\n");
		// sound!
	}

	if(campaign_won)
	{
		if(campaign_level == cvar("g_campaign_index"))
		{
			// advance level
			localcmd("set g_campaign_index ");
			localcmd(ftos(campaign_level + 1));
			localcmd("\n");
		}
		if(campaign_entries < 2)
		{
			localcmd("set g_campaign_index 0\n");
			localcmd("set g_campaign_won 1\n");
		}
	}
}

void() CampaignPostIntermission =
{
	// NOTE: campaign_won is 0 or 1, that is, points to the next level

	if(campaign_won && campaign_entries < 2)
	{
		// last map won!
		localcmd("togglemenu\n");
		CampaignFile_Unload();
		return;
	}

	CampaignSetup(campaign_won);
	CampaignFile_Unload();
	strunzone(campaign_message);
}



void(float n) CampaignLevelWarp =
{
	if(!cvar("sv_cheats"))
		return;
	CampaignFile_Unload();
	CampaignFile_Load(n, 1);
	if(campaign_entries)
		CampaignSetup(0);
	else
		error("Sorry, cheater. You are NOT WELCOME.");
	CampaignFile_Unload();
}
