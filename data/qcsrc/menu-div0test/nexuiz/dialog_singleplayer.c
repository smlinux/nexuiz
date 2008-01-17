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
void fillNexuizSingleplayerDialog(entity me)
{
	entity e;

	me.TR(me);
		me.TDempty(me, (me.columns - 2) / 2);
		me.TD(me, 2, 2, e = makeNexuizButton("Instant action!", '0 0 0'));
			//e.onClick = InstantAction_LoadMap;
			e.onClickEntity = NULL;
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 5, me.columns, me.campaignBox = makeNexuizCampaignList());

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("Start!", '0 0 0'));
			e.onClick = CampaignList_LoadMap;
			e.onClickEntity = me.campaignBox;
}
#endif
