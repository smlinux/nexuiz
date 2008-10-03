#ifdef INTERFACE
CLASS(NexuizMiscSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizMiscSettingsTab, fill, void(entity))
	ATTRIB(NexuizMiscSettingsTab, title, string, "Misc")
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
	me.TR(me);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "volume");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Master:"));
		me.TD(me, 1, 2, s);
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_staticvolume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Ambient:"));
		makeMulti(s, "snd_entchannel2volume");
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_worldchannel0volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Info:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_entchannel3volume");
		makeMulti(s, "snd_playerchannel0volume snd_playerchannel3volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Items:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_playerchannel6volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Pain:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_playerchannel7volume");
		makeMulti(s, "snd_entchannel7volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Player:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_entchannel4volume");
		makeMulti(s, "snd_playerchannel4volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Shots:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_playerchannel2volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Voice:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeNexuizDecibelsSlider(-20, 0, 0.5, "snd_playerchannel1volume");
		makeMulti(s, "snd_playerchannel5volume snd_entchannel1volume snd_entchannel5volume");
		me.TD(me, 1, 0.8, e = makeNexuizSliderCheckBox(-1000000, 1, s, "Weapons:"));
		me.TD(me, 1, 2, s);
		setDependentStringNotEqual(e, "volume", "0");
		setDependentStringNotEqual(s, "volume", "0");

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
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
		me.TD(me, 1, 2, e = makeNexuizTextSlider("snd_channels"));
			e.addValue(e, "Mono", "1");
			e.addValue(e, "Stereo", "2");
			e.addValue(e, "2.1", "3");
			e.addValue(e, "3.1", "4");
			e.addValue(e, "4.1", "5");
			e.addValue(e, "5.1", "6");
			e.addValue(e, "6.1", "7");
			e.addValue(e, "7.1", "8");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(0, "snd_swapstereo", "Swap Stereo"));
	me.TR(me);
	me.TR(me);
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

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "snd_restart", COMMANDBUTTON_APPLY));
}
#endif
