#ifdef INTERFACE
CLASS(NexuizMiscSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizMiscSettingsTab, fill, void(entity))
	ATTRIB(NexuizMiscSettingsTab, title, string, "Misc")
	ATTRIB(NexuizMiscSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizMiscSettingsTab, rows, float, 17)
	ATTRIB(NexuizMiscSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizMiscSettingsTab)
entity makeNexuizMiscSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizMiscSettingsTab()
{
	entity me;
	me = spawnNexuizMiscSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizMiscSettingsTab(entity me)
{
	entity e;
	entity sk;

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "Menu skins:"));
	me.TR(me);
		me.TD(me, me.rows - 2, 3, sk = makeNexuizSkinList());
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, 3, e = makeNexuizButton("Apply immediately", '0 0 0'));
			e.onClick = SetSkin_Click;
			e.onClickEntity = sk;

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showtime", "Show current time"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showdate", "Show current date"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showfps", "Show frames per second"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_showspeed", "Speedometer"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "0", "qu/s (hidden)"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "1", "qu/s"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "2", "m/s"));
			setDependent(e, "cl_showspeed", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "3", "km/h"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "4", "mph"));
			setDependent(e, "cl_showspeed", 1, 1);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "cl_showspeed_unit", "5", "knots"));
			setDependent(e, "cl_showspeed", 1, 1);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_showacceleration", "Show accelerometer"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/2, e = makeNexuizTextLabel(0, "Accelerometer scale:"));
			setDependent(e, "cl_showacceleration", 1, 1);
		me.TD(me, 1, 2.8/2, e = makeNexuizSlider(1, 10, 0.5, "cl_showacceleration_scale"));
			setDependent(e, "cl_showacceleration", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(0, "host_sleep", "Minimize input latency"));
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeNexuizButton("Advanced settings...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.cvarsDialog;
		me.TDempty(me, 0.5);
}
#endif
