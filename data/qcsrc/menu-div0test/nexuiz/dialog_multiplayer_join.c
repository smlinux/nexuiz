#ifdef INTERFACE
CLASS(NexuizServerListTab) EXTENDS(NexuizTab)
	METHOD(NexuizServerListTab, fill, void(entity))
	ATTRIB(NexuizServerListTab, title, string, "Settings")
	ATTRIB(NexuizServerListTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizServerListTab, rows, float, 22)
	ATTRIB(NexuizServerListTab, columns, float, 6.5)
ENDCLASS(NexuizServerListTab)
entity makeNexuizServerListTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizTextBox()
{
	entity e;
	e = spawnInputBox();
	e.configureInputBox(e, "hello world", 3, 12, "qcsrc/menu-div0test/basebutton");
	e.keepspaceLeft = 0.1;
	e.keepspaceRight = 0.2;
	return e;
}

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
		me.TD(me, 1, 0.5, e = makeNexuizTextLabel(0, "Filter:"));
		me.TD(me, 1, me.columns - 2, e = makeNexuizTextBox());
		me.TD(me, 1, 0.75, e = makeNexuizCheckBox(0, string_null, "Empty"));
			e.checked = slist.filterShowEmpty;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowEmpty_Click;
		me.TD(me, 1, 0.75, e = makeNexuizCheckBox(0, string_null, "Full"));
			e.checked = slist.filterShowFull;
			e.onClickEntity = slist;
			e.onClick = ServerList_ShowFull_Click;

	me.TR(me);
		me.TD(me, 1, 1, slist.sortButton1 = makeNexuizButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton2 = makeNexuizButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton3 = makeNexuizButton(string_null, '0 0 0'));
		me.TD(me, 1, 1, slist.sortButton4 = makeNexuizButton(string_null, '0 0 0'));
	me.TR(me);
		me.TD(me, me.rows - 3, me.columns, slist);

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("Join!", '0 0 0'));
			e.onClick = ServerList_Connect_Click;
			e.onClickEntity = slist;
			slist.connectButton = e;
}
#endif
