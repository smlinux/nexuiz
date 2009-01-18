#ifdef INTERFACE
CLASS(NexuizSettingsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizSettingsDialog, fill, void(entity))
	ATTRIB(NexuizSettingsDialog, title, string, "Settings")
	ATTRIB(NexuizSettingsDialog, color, vector, SKINCOLOR_DIALOG_SETTINGS)
	ATTRIB(NexuizSettingsDialog, intendedWidth, float, 0.96)
	ATTRIB(NexuizSettingsDialog, rows, float, 19)
	ATTRIB(NexuizSettingsDialog, columns, float, 6)
ENDCLASS(NexuizSettingsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizSettingsDialog(entity me)
{
	entity mc;
	mc = makeNexuizTabController(me.rows - 2);
	me.TR(me);
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Input",   makeNexuizInputSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Video",   makeNexuizVideoSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Effects", makeNexuizEffectsSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Audio",   makeNexuizAudioSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Network", makeNexuizNetworkSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Misc",    makeNexuizMiscSettingsTab()));
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, mc);
}
#endif
