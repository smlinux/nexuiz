// campaign cvars:
//   _campaign_index: index of CURRENT map
//   g_campaign_index: index of current LAST map (saved)
//   g_campaign_skill: bot skill offset

float campaign_level;
float campaign_won;

void(string s) CampaignBailout =
{
	//bprint(strcat("campaign initialization failed: ", s, "\n"));
	cvar_set("g_campaign", "0");
	error(strcat("campaign initialization failed: ", s, "\n"));
	return;
}

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
			t = strzone(strcat(t, "\n"));
			lleft = l;
		}
		else if(strlen(word) < lleft)
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
	cvar_set("skill", ftos(campaign_botskill[0] + baseskill));

	title = campaign_shortdesc[0];
	campaign_message = strzone(strcat("\n\n\n\n\n\n\n\n\n\n^1\n", title, "\n^3\n", Campaign_wordwrap(campaign_longdesc[0], 50)));
}

string GetMapname();
void() CampaignPostInit =
{
	// now some sanity checks
	string thismapname;
	thismapname = GetMapname();
	if(campaign_mapcfgname[0] != thismapname)
		return CampaignBailout(strcat("wrong map: ", campaign_mapcfgname[0], " != ", thismapname));
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
