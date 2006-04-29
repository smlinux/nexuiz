void CampaignSetup(float n)
{
	localcmd("exec game_reset.cfg\n");
	localcmd("exec mutator_reset.cfg\n");
	localcmd("set g_campaign 1\n");
	localcmd(strcat("set _campaign_index ", ftos(campaign_offset + n), "\n"));
	localcmd(strcat(campaign_mutators[n], "\n"));
	localcmd(strcat("exec maps/", campaign_mapcfgname[n], ".mapcfg\n"));
}
