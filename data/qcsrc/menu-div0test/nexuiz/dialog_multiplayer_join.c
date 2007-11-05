#ifdef INTERFACE
CLASS(NexuizServerListTab) EXTENDS(NexuizTab)
	METHOD(NexuizServerListTab, fill, void(entity))
	ATTRIB(NexuizServerListTab, title, string, "Settings")
	ATTRIB(NexuizServerListTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizServerListTab, rows, float, 15)
	ATTRIB(NexuizServerListTab, columns, float, 6.5)
ENDCLASS(NexuizServerListTab)
entity makeNexuizServerListTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizServerListTab()
{
	entity me;
	me = spawnNexuizServerListTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizServerListTab(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Filter:"));

	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, e = makeNexuizServerList());

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, 1, makeNexuizCommandButton("Refresh!", '0 0 0', "echo FIXME ask for servers again", 0));
		me.TD(me, 1, me.columns - 1, makeNexuizCommandButton("Join!", '0 0 0', "connect $menu_selected_server", 0));
}
#endif
