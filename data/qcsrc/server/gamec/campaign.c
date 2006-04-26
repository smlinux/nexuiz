string campaign_savedlevel = "g_campaign_currentlevel"; // for multiple campaigns, make this a variable
string campaign_won = "g_campaign_won"; // set to 1 once you have won

void() CampaignInit =
{
	// do some checks
	if(cvar_string(campaign_savedlevel) == "")
		cvar_set(campaign_savedlevel, "sp/level01");
	
	if(cvar_string("_campaign_thislevel") == cvar_string(campaign_savedlevel))
	{
		cvar_set("sv_public", "0"); // just in case

		campaign_message = strzone(strcat("^7SINGLEPLAYER MODE\n\n", cvar_string("_campaign_message")));
		
		return;
	}

	// if they fail:
	cvar_set("g_campaign", "0");
}

void() CampaignFinish =
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
		string level;

		level = cvar_string("_campaign_nextlevel");

		if(level == "")
		{
			bprint("SINGLEPLAYER MODE\n\nCongratulations, you're the winner.\n");
			cvar_set(campaign_won, "1");
			cvar_set("lastlevel", "1");
		}
		else
		{
			bprint("SINGLEPLAYER MODE\n\nCongratulations, you're the winner.\nAdvancing to next level...\n");
			cvar_set("nextmap", cvar_string("_campaign_nextlevel"));
			cvar_set(campaign_savedlevel, cvar_string("_campaign_nextlevel"));
		}
	}
	else
	{
		bprint("SINGLEPLAYER MODE\n\nYou have lost the match.\nPlaying same level again...\n");
		cvar_set("nextmap", cvar_string("_campaign_thislevel")); // restart same level again
	}
}
