#ifdef INTERFACE
CLASS(NexuizRadarDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizRadarDialog, toString, string(entity))
	METHOD(NexuizRadarDialog, fill, void(entity))
	METHOD(NexuizRadarDialog, showNotify, void(entity))
	ATTRIB(NexuizRadarDialog, title, string, "Radar, HUD & Waypoints")
	ATTRIB(NexuizRadarDialog, color, vector, SKINCOLOR_DIALOG_RADAR)
	ATTRIB(NexuizRadarDialog, intendedWidth, float, 0.7)
	ATTRIB(NexuizRadarDialog, rows, float, 19)
	ATTRIB(NexuizRadarDialog, columns, float, 4)
ENDCLASS(NexuizRadarDialog)
#endif

#ifdef IMPLEMENTATION
void showNotifyNexuizRadarDialog(entity me)
{
        loadAllCvars(me);
}
string toStringNexuizRadarDialog(entity me)
{
	return "XXX";
}
void fillNexuizRadarDialog(entity me)
{
	entity e, sl;
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Radar settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Position:"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "0 0", "Top left"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "0.5 0", "Top middle"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "1 0", "Top right"));
	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "0 0.5", "Middle left"));
		me.TDempty(me, 1);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "1 0.5", "Middle right"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Size:"));
		me.TD(me, 1, 3, e = makeNexuizTextSlider("cl_teamradar_size"));
			e.addValue(e, "96x96", "96 96");
			e.addValue(e, "128x96", "128 96");
			e.addValue(e, "128x128", "128 128");
			e.addValue(e, "192x144", "192 144");
			e.addValue(e, "192x192", "192 192");
			e.addValue(e, "256x192", "256 192");
			e.addValue(e, "256x256", "256 256");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		sl = makeNexuizSlider(0.20, 1, 0.01, "cl_teamradar_background_alpha");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1, 1, sl, "Background:"));
		me.TD(me, 1, 3, sl);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "HUD settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizCheckBoxEx(100, 110, "viewsize", "Background:"));
		me.TD(me, 1, 3, e = makeNexuizSlider(0, 1, 0.01, "sbar_alpha_bg"));
			setDependent(e, "viewsize", 0, 100);
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Default red:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0, 1, 0.01, "sbar_color_bg_r"));
				setDependent(e, "viewsize", 0, 100);
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Default green:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0, 1, 0.01, "sbar_color_bg_g"));
				setDependent(e, "viewsize", 0, 100);
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Default blue:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0, 1, 0.01, "sbar_color_bg_b"));
				setDependent(e, "viewsize", 0, 100);
		me.TR(me);
			me.TDempty(me, 0.2);
			me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Team color:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0.1, 1, 0.01, "sbar_color_bg_team"));
				setDependent(e, "viewsize", 0, 100);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Waypoint settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeNexuizCheckBox(1, "cl_hidewaypoints", "Show base waypoints"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Waypoint scale:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0.5, 1.5, 0.01, "g_waypointsprite_scale"));
				setDependent(e, "cl_hidewaypoints", 0, 0);
	me.TR(me);
 		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Waypoint alpha:"));
			me.TD(me, 1, 3, e = makeNexuizSlider(0.1, 1, 0.01, "g_waypointsprite_alpha"));
				setDependent(e, "cl_hidewaypoints", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Show names:"));
		me.TD(me, 1, 3, e = makeNexuizTextSlider("cl_shownames"));
			e.addValue(e, "Never", "0");
			e.addValue(e, "Teammates", "1");
			e.addValue(e, "All players", "2");
			e.configureNexuizTextSliderValues(e);
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

#endif
