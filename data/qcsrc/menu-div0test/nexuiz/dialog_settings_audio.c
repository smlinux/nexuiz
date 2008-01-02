#ifdef INTERFACE
CLASS(NexuizAudioSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizAudioSettingsTab, fill, void(entity))
	ATTRIB(NexuizAudioSettingsTab, title, string, "Settings")
	ATTRIB(NexuizAudioSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizAudioSettingsTab, rows, float, 15)
	ATTRIB(NexuizAudioSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizAudioSettingsTab)
entity makeNexuizAudioSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizAudioSettingsTab()
{
	entity me;
	me = spawnNexuizAudioSettingsTab();
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
void fillNexuizAudioSettingsTab(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Music Volume:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.02, "bgmvolume"));
			e.valueDisplayMultiplier = 100;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Game Volume:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.02, "volume"));
			e.valueDisplayMultiplier = 100;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Ambient Volume:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.02, "snd_staticvolume"));
			e.valueDisplayMultiplier = 100;

	me.gotoXY(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
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
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(1, "snd_swapstereo", "Swap Stereo"));
	me.TR(me);
		if(checkextension("DP_GECKO_SUPPORT"))
		{
			me.TD(me, 10, 15, e = spawnGecko() );
			e.configureBrowser( e, "www.google.de" );
		}
	me.TR(me);

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "snd_restart", COMMANDBUTTON_APPLY));
}
#endif
