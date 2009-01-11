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
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "shownetgraph", "Show netgraph"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "Speedmeter:"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "0", "Off"));
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "1", "in/s"));
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "2", "m/s"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "3", "km/h"));
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "4", "mph"));
		me.TD(me, 1, 2.8/3, e = makeNexuizRadioButton(1, "showspeed", "5", "knots"));
		me.TR(me);
		me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Network speed:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("_cl_rate"));
			e.addValue(e, "56k", "4000");
			e.addValue(e, "ISDN", "7000");
			e.addValue(e, "Slow ADSL", "15000");
			e.addValue(e, "Fast ADSL", "20000");
			e.addValue(e, "Broadband", "25000");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Client UDP port:"));
		me.TD(me, 1, 0.64, e = makeNexuizInputBox(0, "cl_port"));
}
#endif
