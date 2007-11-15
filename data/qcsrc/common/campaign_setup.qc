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
#ifdef MAPINFO
	cvar_set("g_tdm",        (campaign_gametype[n] == "tdm")   ? "0" : "1");
	cvar_set("g_domination", (campaign_gametype[n] == "dom")   ? "0" : "1");
	cvar_set("g_ctf",        (campaign_gametype[n] == "ctf")   ? "0" : "1");
	cvar_set("g_runematch",  (campaign_gametype[n] == "rune")  ? "0" : "1");
	cvar_set("g_lms",        (campaign_gametype[n] == "lms")   ? "0" : "1");
	cvar_set("g_arena",      (campaign_gametype[n] == "arena") ? "0" : "1");
	cvar_set("g_keyhunt",    (campaign_gametype[n] == "kh")    ? "0" : "1");
	cvar_set("g_assault",    (campaign_gametype[n] == "as")    ? "0" : "1");
	cvar_set("g_onslaught",  (campaign_gametype[n] == "ons")   ? "0" : "1");
	MapInfo_LoadMap(campaign_mapname[n]);
#else
	localcmd("exec maps/"); // can't use strcat here in current fteqcc
		localcmd(campaign_gametype[n]);
		localcmd("_");
		localcmd(campaign_mapname[n]);
		localcmd(".mapcfg\n");
#endif
}
