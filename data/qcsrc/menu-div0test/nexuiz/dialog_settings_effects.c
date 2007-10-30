#ifdef INTERFACE
CLASS(NexuizEffectsSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizEffectsSettingsTab, fill, void(entity))
	ATTRIB(NexuizEffectsSettingsTab, title, string, "Settings")
	ATTRIB(NexuizEffectsSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizEffectsSettingsTab, rows, float, 15)
	ATTRIB(NexuizEffectsSettingsTab, columns, float, 1)
ENDCLASS(NexuizEffectsSettingsTab)
entity makeNexuizEffectsSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizEffectsSettingsTab()
{
	entity me;
	me = spawnNexuizEffectsSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizEffectsSettingsTab(entity me)
{
}
#endif
