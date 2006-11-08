void CampaignSetup(float n)
{
	localcmd("exec game_reset.cfg\n");
	localcmd("exec mutator_reset.cfg\n");
	localcmd("set g_campaign 1\n");
	localcmd("set _campaign_name \"");
		localcmd(campaign_name);
		localcmd("\"\n");
	localcmd("set _campaign_index ");
		localcmd(ftos(campaign_offset + n));
		localcmd("\n");
	localcmd(campaign_mutators[n]);
		localcmd("\n");
	localcmd("exec maps/"); // can't use strcat here in current fteqcc
		localcmd(campaign_gametype[n]);
		localcmd("_");
		localcmd(campaign_mapname[n]);
		localcmd(".mapcfg\n");
}
