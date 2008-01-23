#ifdef INTERFACE
CLASS(NexuizSingleplayerDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizSingleplayerDialog, fill, void(entity))
	ATTRIB(NexuizSingleplayerDialog, title, string, "Singleplayer")
	ATTRIB(NexuizSingleplayerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(NexuizSingleplayerDialog, intendedWidth, float, 0.80)
	ATTRIB(NexuizSingleplayerDialog, rows, float, 24)
	ATTRIB(NexuizSingleplayerDialog, columns, float, 5)
	ATTRIB(NexuizSingleplayerDialog, campaignBox, entity, NULL)
ENDCLASS(NexuizSingleplayerDialog)
#endif

#ifdef IMPLEMENTATION

void InstantAction_LoadMap(entity btn, entity dummy)
{
	float glob, i, n, fh;
	string s;
	glob = search_begin("maps/*.instantaction", TRUE, TRUE);
	if(glob < 0)
		return;
	i = ceil(random() * search_getsize(glob)) - 1;
	fh = fopen(search_getfilename(glob, i), FILE_READ);
	search_end(glob);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(substring(s, 0, 4) == "set ")
			s = substring(s, 4, strlen(s) - 4);
		n = tokenize(s);
		if(argv(0) == "bot_number")
			cvar_set("bot_number", argv(1));
		else if(argv(0) == "skill")
			cvar_set("skill", argv(1));
		else if(argv(0) == "timelimit")
			cvar_set("timelimit_override", argv(1));
		else if(argv(0) == "fraglimit")
			cvar_set("fraglimit_override", argv(1));
		else if(argv(0) == "changelevel")
		{
			fclose(fh);
			MapInfo_SwitchGameType(MAPINFO_TYPE_DEATHMATCH);
			MapInfo_LoadMap(argv(1));
			cvar_set("lastlevel", "1");
			return;
		}
	}
	fclose(fh);
}

void fillNexuizSingleplayerDialog(entity me)
{
	entity e;

	me.TR(me);
		me.TDempty(me, (me.columns - 2) / 2);
		me.TD(me, 2, 2, e = makeNexuizButton("Instant action!", '0 0 0'));
			e.onClick = InstantAction_LoadMap;
			e.onClickEntity = NULL;
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 5, me.columns, me.campaignBox = makeNexuizCampaignList());

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("Start!", '0 0 0'));
			e.onClick = CampaignList_LoadMap;
			e.onClickEntity = me.campaignBox;
}
#endif
