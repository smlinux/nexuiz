#ifdef INTERFACE
CLASS(NexuizMiscSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizMiscSettingsTab, fill, void(entity))
	ATTRIB(NexuizMiscSettingsTab, title, string, "Settings")
	ATTRIB(NexuizMiscSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizMiscSettingsTab, rows, float, 15)
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
entity makeNexuizDemoListbox()
{
	entity me;
	me = spawnListBox();
	me.configureListBox(me, 16, 0.1);
	return me;
}
void fillNexuizMiscSettingsTab(entity me)
{
	entity e, s;

	me.TR(me);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "bgmvolume");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Music:"));
		me.TD(me, 1, 2, s);
	me.TR(me);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "volume");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Game:"));
		me.TD(me, 1, 2, s);
	me.TR(me);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_staticvolume");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Ambient:"));
		me.TD(me, 1, 2, s);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Frequency:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("snd_speed"));
			e.addValue(e, "8 kHz", "8000");
			e.addValue(e, "11.025 kHz", "11025");
			e.addValue(e, "16 kHz", "16000");
			e.addValue(e, "22.05 kHz", "22050");
			e.addValue(e, "24 kHz", "24000");
			e.addValue(e, "32 kHz", "32000");
			e.addValue(e, "44.1 kHz", "44100");
			e.addValue(e, "48 kHz", "48000");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Channels:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1, 8, 1, "snd_channels"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(0, "snd_swapstereo", "Swap Stereo"));

	me.gotoXY(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_autodemo", "Demo recording"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showtime", "Show current time"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showdate", "Show current date"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showfps", "Show frames per second"));
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

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "snd_restart", COMMANDBUTTON_APPLY));
}
#endif
