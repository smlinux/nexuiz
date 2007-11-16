#ifdef INTERFACE
CLASS(NexuizServerCreateTab) EXTENDS(NexuizTab)
	METHOD(NexuizServerCreateTab, fill, void(entity))
	METHOD(NexuizServerCreateTab, gameTypeChangeNotify, void(entity))
	ATTRIB(NexuizServerCreateTab, title, string, "Create")
	ATTRIB(NexuizServerCreateTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizServerCreateTab, rows, float, 22)
	ATTRIB(NexuizServerCreateTab, columns, float, 6.5)

	ATTRIB(NexuizServerCreateTab, mapListBox, entity, NULL)
	ATTRIB(NexuizServerCreateTab, sliderFraglimit, entity, NULL)
	ATTRIB(NexuizServerCreateTab, checkboxFraglimit, entity, NULL)
ENDCLASS(NexuizServerCreateTab)
entity makeNexuizServerCreateTab();
#endif

#ifdef IMPLEMENTATION

entity makeNexuizServerCreateTab()
{
	entity me;
	me = spawnNexuizServerCreateTab();
	me.configureDialog(me);
	return me;
}

void fillNexuizServerCreateTab(entity me)
{
	entity e, e0;

	me.TR(me);
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_dm", "Deathmatch"));
			e0 = e;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_tdm", "TDM"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_lms", "LMS"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_arena", "Arena"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_runematch", "Rune"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_keyhunt", "Key Hunt"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_ctf", "CTF"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_assault", "Assault"));
			if(e.checked) e0 = NULL;
		me.TD(me, 2, me.columns / 9, e = makeNexuizGametypeButton(1, "g_onslaught", "Onslaught"));
			if(e.checked) e0 = NULL;
		if(e0)
		{
			print("NO CHECK\n");
			e0.setChecked(e0, 1);
		}
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "Map list:"));
	me.TR(me);
		me.TD(me, me.rows - 6, 3, e = makeNexuizMapList());
		me.mapListBox = e;
	me.gotoXY(me, me.rows - 2, 0);
		me.TD(me, 1, 1, e = makeNexuizButton("All", '0 0 0'));
			e.onClick = MapList_All;
			e.onClickEntity = me.mapListBox;
		me.TD(me, 1, 1, e = makeNexuizButton("None", '0 0 0'));
			e.onClick = MapList_None;
			e.onClickEntity = me.mapListBox;
		me.TD(me, 1, 1, e = makeNexuizButton("Details...", '0 0 0'));

	me.gotoXY(me, 3, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "Settings:"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Time limit:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 60.0, 0.5, "timelimit_override"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Point limit:"));
			me.checkboxFraglimit = e;
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 2000.0, 5, "fraglimit_override"));
			me.sliderFraglimit = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizButton("Mutators...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.mutatorsDialog;
			main.mutatorsDialog.refilterEntity = me.mapListBox;

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("Start!", '0 0 0'));

	me.gameTypeChangeNotify(me);
}

void GameType_ConfigureSliders(entity e, entity l, string pLabel, float pMin, float pMax, float pStep, string pCvar)
{
	e.configureNexuizSlider(e, pMin, pMax, pStep, pCvar);
	l.setText(l, pLabel);
}

void gameTypeChangeNotifyNexuizServerCreateTab(entity me)
{
	// tell the map list to update
	float gt;
	entity e, l;
	gt = MapInfo_CurrentGametype();
	e = me.sliderFraglimit;
	l = me.checkboxFraglimit;
	switch(gt)
	{
		case MAPINFO_TYPE_CTF:        GameType_ConfigureSliders(e, l, "Point limit:",  50,  500, 10, "g_ctf_capture_limit");      break;
		case MAPINFO_TYPE_DOMINATION: GameType_ConfigureSliders(e, l, "Point limit:",  50,  500, 10, "g_domination_point_limit"); break;
		case MAPINFO_TYPE_KEYHUNT:    GameType_ConfigureSliders(e, l, "Point limit:", 200, 1500, 50, "g_keyhunt_point_limit");    break;
		case MAPINFO_TYPE_RUNEMATCH:  GameType_ConfigureSliders(e, l, "Point limit:",  50,  500, 10, "g_runematch_point_limit");  break;
		case MAPINFO_TYPE_LMS:        GameType_ConfigureSliders(e, l, "Lives:",         3,   50,  1, "g_lms_lives_override");     break;
		default:                      GameType_ConfigureSliders(e, l, "Frag limit:",    5,  100,  5, "fraglimit_override");       break;
	}
	me.mapListBox.refilter(me.mapListBox);
}

#endif
