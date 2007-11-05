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
	entity e, slist;

	slist  = makeNexuizServerList();

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Filter:"));

	me.TR(me);
		me.TD(me, 1, 1, slist.sortButton1 = makeNexuizButton("", '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton2 = makeNexuizButton("", '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton3 = makeNexuizButton("", '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton4 = makeNexuizButton("", '0 0 0'));
	me.TR(me);
		me.TD(me, me.rows - 3, me.columns, slist);

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, 1, e = makeNexuizButton("Refresh!", '0 0 0'));
			e.onClick = ServerList_Refresh_Click;
			e.onClickEntity = slist;
		me.TD(me, 1, me.columns - 1, e = makeNexuizButton("Join!", '0 0 0'));
			e.onClick = ServerList_Connect_Click;
			e.onClickEntity = slist;
			slist.connectButton = e;
}
#endif
