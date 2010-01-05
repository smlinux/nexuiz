#ifdef INTERFACE
CLASS(NexuizAdvancedDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizAdvancedDialog, fill, void(entity))
	METHOD(NexuizAdvancedDialog, showNotify, void(entity))
	METHOD(NexuizAdvancedDialog, close, void(entity))
	ATTRIB(NexuizAdvancedDialog, title, string, "Advanced server settings")
	ATTRIB(NexuizAdvancedDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(NexuizAdvancedDialog, intendedWidth, float, 0.5)
	ATTRIB(NexuizAdvancedDialog, rows, float, 14)
	ATTRIB(NexuizAdvancedDialog, columns, float, 3)
	ATTRIB(NexuizAdvancedDialog, refilterEntity, entity, NULL)
ENDCLASS(NexuizAdvancedDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizAdvancedDialog(entity me)
{
	loadAllCvars(me);
}

void fillNexuizAdvancedDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 1.2, makeNexuizTextLabel(0, "Game settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizCheckBox(0, "sv_spectate", "Allow spectating"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Spawn shield:"));
		me.TD(me, 1, 1.7, e = makeNexuizSlider(0, 15, 0.5, "g_spawnshieldtime"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Start delay:"));
		me.TD(me, 1, 1.7, e = makeNexuizSlider(0, 30, 0.5, "g_start_delay"));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Game speed:"));
		me.TD(me, 1, 1.7, e = makeNexuizSlider(0.5, 2.0, 0.1, "slowmo"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizCheckBoxEx(2, 0, "g_antilag", "AntiLag"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1.2, makeNexuizTextLabel(0, "Teamplay settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Friendly fire scale:"));
		me.TD(me, 1, 1.7, e = makeNexuizSlider(0, 1.0, 0.05, "g_friendlyfire"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Friendly fire penalty:"));
		me.TD(me, 1, 1.7, e = makeNexuizSlider(0, 1.0, 0.05, "g_mirrordamage"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeNexuizTextLabel(0, "Teams:"));
		me.TD(me, 1, 1.7, e = makeNexuizTextSlider("g_tdm_teams_override g_domination_teams_override g_keyhunt_teams_override"));
			e.addValue(e, "Default", "0");
			e.addValue(e, "2 teams", "2");
			e.addValue(e, "3 teams", "3");
			e.addValue(e, "4 teams", "4");
			e.configureNexuizTextSliderValues(e);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void closeNexuizAdvancedDialog(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	closeDialog(me);
}
#endif
