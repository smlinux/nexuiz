void CampaignSetup(float n)
{
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
	MapInfo_SwitchGameType(MapInfo_Type_FromString(campaign_gametype[n]));
	MapInfo_LoadMap(campaign_mapname[n]);
}
