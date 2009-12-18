#ifdef INTERFACE
CLASS(NexuizMapInfoDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizMapInfoDialog, fill, void(entity))
	METHOD(NexuizMapInfoDialog, loadMapInfo, void(entity, float, entity))
	ATTRIB(NexuizMapInfoDialog, title, string, "Map Information")
	ATTRIB(NexuizMapInfoDialog, color, vector, SKINCOLOR_DIALOG_MAPINFO)
	ATTRIB(NexuizMapInfoDialog, intendedWidth, float, 0.85)
	ATTRIB(NexuizMapInfoDialog, rows, float, 9)
	ATTRIB(NexuizMapInfoDialog, columns, float, 10)

	ATTRIB(NexuizMapInfoDialog, previewImage, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, titleLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, authorLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, descriptionLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, featuresLabel, entity, NULL)

	ATTRIB(NexuizMapInfoDialog, typeDeathmatchLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeTDMLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeLMSLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeArenaLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeRuneLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeDominationLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeKeyHuntLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeCTFLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeCALabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeAssaultLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeOnslaughtLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeRaceLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeCTSLabel, entity, NULL)
	ATTRIB(NexuizMapInfoDialog, typeNexballLabel, entity, NULL)

	ATTRIB(NexuizMapInfoDialog, currentMapIndex, float, 0)
	ATTRIB(NexuizMapInfoDialog, currentMapBSPName, string, string_null)
	ATTRIB(NexuizMapInfoDialog, currentMapTitle, string, string_null)
	ATTRIB(NexuizMapInfoDialog, currentMapAuthor, string, string_null)
	ATTRIB(NexuizMapInfoDialog, currentMapDescription, string, string_null)
	ATTRIB(NexuizMapInfoDialog, currentMapPreviewImage, string, string_null)
	ATTRIB(NexuizMapInfoDialog, currentMapFeaturesText, string, string_null)
ENDCLASS(NexuizMapInfoDialog)
#endif

#ifdef IMPLEMENTATION
void loadMapInfoNexuizMapInfoDialog(entity me, float i, entity mlb)
{
	me.currentMapIndex = i;
	me.startButton.onClickEntity = mlb;
	MapInfo_Get_ByID(i);

	if(me.currentMapBSPName)
	{
		strunzone(me.currentMapBSPName);
		strunzone(me.currentMapTitle);
		strunzone(me.currentMapAuthor);
		strunzone(me.currentMapDescription);
		strunzone(me.currentMapPreviewImage);
		strunzone(me.currentMapFeaturesText);
	}
	me.currentMapBSPName = strzone(MapInfo_Map_bspname);
	me.currentMapTitle = strzone(MapInfo_Map_title);
	me.currentMapAuthor = strzone(MapInfo_Map_author);
	me.currentMapDescription = strzone(MapInfo_Map_description);
	me.currentMapFeaturesText = strzone((MapInfo_Map_supportedFeatures & MAPINFO_FEATURE_WEAPONS) ? "Full item placement" : "MinstaGib only");
	me.currentMapPreviewImage = strzone(strcat("/maps/", MapInfo_Map_bspname));

	me.frame.setText(me.frame, me.currentMapBSPName);
	me.titleLabel.setText(me.titleLabel, me.currentMapTitle);
	me.authorLabel.setText(me.authorLabel, me.currentMapAuthor);
	me.descriptionLabel.setText(me.descriptionLabel, me.currentMapDescription);
	me.featuresLabel.setText(me.featuresLabel, me.currentMapFeaturesText);
	me.previewImage.src = me.currentMapPreviewImage;

	me.typeDeathmatchLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_DEATHMATCH);
	me.typeTDMLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_TEAM_DEATHMATCH);
	me.typeLMSLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_LMS);
	me.typeArenaLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ARENA);
	me.typeDominationLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_DOMINATION);
	me.typeRuneLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_RUNEMATCH);
	me.typeKeyHuntLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_KEYHUNT);
	me.typeCTFLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_CTF);
	me.typeCALabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_CA);
	me.typeAssaultLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ASSAULT);
	me.typeOnslaughtLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_ONSLAUGHT);
	me.typeRaceLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_RACE);
	me.typeCTSLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_CTS);
	me.typeNexballLabel.disabled = !(MapInfo_Map_supportedGametypes & MAPINFO_TYPE_NEXBALL);

	MapInfo_ClearTemps();
}
void fillNexuizMapInfoDialog(entity me)
{
	entity e;
	float w, wgt;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, me.rows - 2, 3, e = makeNexuizImage(string_null, 4.0/3.0));
		me.previewImage = e;
	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
	w = me.columns - me.currentColumn;
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Title:"));
		me.TD(me, 1, w-1, e = makeNexuizTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_TITLE;
			e.allowCut = 1;
			me.titleLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Author:"));
		me.TD(me, 1, w-1, e = makeNexuizTextLabel(0, ""));
			e.colorL = SKINCOLOR_MAPLIST_AUTHOR;
			e.allowCut = 1;
			me.authorLabel = e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Features:"));
		me.TD(me, 1, w-1, e = makeNexuizTextLabel(0, ""));
			e.allowCut = 1;
			me.featuresLabel = e;
	me.TR(me);
		me.TD(me, 1, w, e = makeNexuizTextLabel(0, "Game types:"));
	me.TR(me); wgt = (w-0.2)/5;
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "DM"));
			me.typeDeathmatchLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "TDM"));
			me.typeTDMLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "LMS"));
			me.typeLMSLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Arena"));
			me.typeArenaLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Rune"));
			me.typeRuneLabel = e;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Domination"));
			me.typeDominationLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Key Hunt"));
			me.typeKeyHuntLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "CTF"));
			me.typeCTFLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "CA"));
			me.typeCALabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Assault"));
			me.typeAssaultLabel = e;
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Onslaught"));
			me.typeOnslaughtLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Race"));
			me.typeRaceLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "CTS"));
			me.typeCTSLabel = e;
		me.TD(me, 1, wgt, e = makeNexuizTextLabel(0, "Nexball"));
			me.typeNexballLabel = e;

	me.gotoRC(me, me.rows - 2, 0);
		me.TD(me, 1, me.columns, e = makeNexuizTextLabel(0.5, ""));
			e.allowCut = 1;
			me.descriptionLabel = e;

	me.gotoRC(me, me.rows - 1, 0);
		me.TDempty(me, 0.5);

		me.TD(me, 1, me.columns - 5.5, e = makeNexuizButton("Close", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns - 5.5, me.startButton = e = makeNexuizButton("Play", '0 0 0'));
			me.startButton.onClick = MapList_LoadMap;
			me.startButton.onClickEntity = NULL; // filled later
		me.TDempty(me, 0.5);
}
#endif
