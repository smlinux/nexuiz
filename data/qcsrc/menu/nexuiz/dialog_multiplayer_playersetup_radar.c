#ifdef INTERFACE
CLASS(NexuizRadarDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizRadarDialog, toString, string(entity))
	METHOD(NexuizRadarDialog, fill, void(entity))
	METHOD(NexuizRadarDialog, showNotify, void(entity))
	ATTRIB(NexuizRadarDialog, title, string, "Radar & Waypoints")
	ATTRIB(NexuizRadarDialog, color, vector, SKINCOLOR_DIALOG_RADAR)
	ATTRIB(NexuizRadarDialog, intendedWidth, float, 0.7)
	ATTRIB(NexuizRadarDialog, rows, float, 18)
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
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "0.5 0", "Middle left"));
		me.TDempty(me, 1);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_position", "0.5 1", "Middle right"));
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
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Zoom:"));
		me.TD(me, 1, 1.5, e = makeNexuizRadioButton(1, "cl_teamradar_zoommode", "0", "Zoom key zooms out"));
		me.TD(me, 1, 1.5, e = makeNexuizRadioButton(1, "cl_teamradar_zoommode", "1", "Zoom key zooms in"));
	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 1, 1.5, e = makeNexuizRadioButton(1, "cl_teamradar_zoommode", "2", "Always zoomed in"));
		me.TD(me, 1, 1.5, e = makeNexuizRadioButton(1, "cl_teamradar_zoommode", "3", "Always zoomed out"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Zoomed scale:"));
			setDependent(e, "cl_teamradar_zoommode", 0, 2);
		me.TD(me, 1, 3, e = makeNexuizTextSlider("cl_teamradar_scale"));
			e.addValue(e, "1:2048", "2048");
			e.addValue(e, "1:3072", "3072");
			e.addValue(e, "1:4096", "4096");
			e.addValue(e, "1:6144", "6144");
			e.addValue(e, "1:8192", "8192");
			e.configureNexuizTextSliderValues(e);
			setDependent(e, "cl_teamradar_zoommode", 0, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeNexuizTextLabel(0, "Rotation (UP direction):"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_rotation", "4", "North"));
		me.TDempty(me, 1);
	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_rotation", "1", "West"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_rotation", "0", "Forward"));
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_rotation", "3", "East"));
	me.TR(me);
		me.TDempty(me, 2);
		me.TD(me, 1, 1, e = makeNexuizRadioButton(1, "cl_teamradar_rotation", "2", "South"));
		me.TDempty(me, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Foreground:"));
		me.TD(me, 1, 3, makeNexuizSlider(0.1, 1.0, 0.01, "cl_teamradar_foreground_alpha"));
	me.TR(me);
		me.TDempty(me, 0.2);
		sl = makeNexuizSlider(0.1, 1.0, 0.01, "cl_teamradar_background_alpha");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1, 1, sl, "Background:"));
		me.TD(me, 1, 3, sl);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 4, makeNexuizTextLabel(0, "Waypoint settings:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Show names:"));
		me.TD(me, 1, 3, e = makeNexuizTextSlider("cl_shownames"));
			e.addValue(e, "Never", "0");
			e.addValue(e, "Team games", "1");
			e.addValue(e, "Always", "2");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 3.8, e = makeNexuizCheckBox(1, "cl_hidewaypoints", "Show base waypoints"));
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

#endif
