#ifdef INTERFACE
CLASS(NexuizAudioSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizAudioSettingsTab, fill, void(entity))
	ATTRIB(NexuizAudioSettingsTab, title, string, "Audio")
	ATTRIB(NexuizAudioSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizAudioSettingsTab, rows, float, 17)
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

void fillNexuizAudioSettingsTab(entity me)
{
	entity e, s, sl;

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
		makeMulti(s, "snd_csqcchannel0volume");
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
		makeMulti(s, "snd_csqcchannel6volume");
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
		makeMulti(s, "snd_playerchannel4volume snd_entchannel6volume snd_csqcchannel4volume");
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
	me.TR(me);

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
		setDependent(e, "snd_channels", 1.5, 0.5);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(0, "snd_spatialization_control", "Headphone friendly mode"));
		setDependent(e, "snd_channels", 1.5, 0.5);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Spatial voices:"));
		me.TD(me, 1, 2/3, e = makeNexuizRadioButton(1, "cl_voice_directional", "0", "None"));
		me.TD(me, 1, 2/3, e = makeNexuizRadioButton(1, "cl_voice_directional", "2", "Taunts"));
		me.TD(me, 1, 2/3, e = makeNexuizRadioButton(1, "cl_voice_directional", "1", "All"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Taunt range:"));
		setDependent(e, "cl_voice_directional", 0.5, -0.5);
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_voice_directional_taunt_attenuation"));
			e.addValue(e, "Very short", "3");
			e.addValue(e, "Short", "2");
			e.addValue(e, "Normal", "0.5");
			e.addValue(e, "Long", "0.25");
			e.addValue(e, "Full", "0.015625");
			e.configureNexuizTextSliderValues(e);
		setDependent(e, "cl_voice_directional", 0.5, -0.5);
	me.TR(me);
		sl = makeNexuizSlider(0.15, 1, 0.05, "cl_autotaunt");
			sl.valueDisplayMultiplier = 100;
			sl.valueDigits = 0;
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(0, 1, sl, "Automatic taunts"));
		if(sl.value != e.savedValue)
			e.savedValue = 0.65; // default
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0.1, "Frequency:"));
		me.TD(me, 1, 2, sl);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Time warning:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_sound_maptime_warning"));
			e.addValue(e, "None", "0");
			e.addValue(e, "1 minute", "1");
			e.addValue(e, "5 minutes", "2");
			e.addValue(e, "Both", "3");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_hitsound", "Hit indicator"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBoxEx(2, 0, "menu_sounds", "Menu sounds"));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "snd_restart; sendcvar cl_hitsound; sendcvar cl_autotaunt; sendcvar cl_voice_directional; sendcvar cl_voice_directional_taunt_attenuation", COMMANDBUTTON_APPLY));
}
#endif
