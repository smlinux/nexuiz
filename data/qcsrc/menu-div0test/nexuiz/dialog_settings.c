#ifdef INTERFACE
CLASS(NexuizSettingsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizSettingsDialog, fill, void(entity))
	ATTRIB(NexuizSettingsDialog, title, string, "Settings")
	ATTRIB(NexuizSettingsDialog, color, vector, '0.5 0.5 1')
	ATTRIB(NexuizSettingsDialog, intendedWidth, float, 0.96)
	ATTRIB(NexuizSettingsDialog, rows, float, 17)
	ATTRIB(NexuizSettingsDialog, columns, float, 6)
ENDCLASS(NexuizSettingsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizSettingsDialog(entity me)
{
	entity mc;
	mc = makeNexuizTabController(me.rows - 2);
	me.TR(me);
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Input",   makeNexuizVideoSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Video",   makeNexuizVideoSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Effects", makeNexuizEffectsSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Audio",   makeNexuizVideoSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Player",  makeNexuizPlayerSettingsTab()));
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, mc);
}
#endif
