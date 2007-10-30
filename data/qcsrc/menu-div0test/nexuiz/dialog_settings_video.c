#ifdef INTERFACE
CLASS(NexuizVideoSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizVideoSettingsTab, fill, void(entity))
	ATTRIB(NexuizVideoSettingsTab, title, string, "Settings")
	ATTRIB(NexuizVideoSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizVideoSettingsTab, rows, float, 15)
	ATTRIB(NexuizVideoSettingsTab, columns, float, 7)
ENDCLASS(NexuizVideoSettingsTab)
entity makeNexuizVideoSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizVideoSettingsTab()
{
	entity me;
	me = spawnNexuizVideoSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizVideoSettingsTab(entity me)
{
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Resolution:"));
		me.TD(me, 1, 2, makeNexuizResolutionSlider());
	me.TR(me);
		me.TD(me, 1, 3, makeNexuizCheckBox(0, "vid_fullscreen", "Full screen"));
	me.TR(me);
		me.TD(me, 1, 3, makeNexuizCheckBox(0, "vid_vsync", "Vertical synchronization"));

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply now", '0 0 0', "vid_restart", 0));
}
#endif
