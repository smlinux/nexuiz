#ifdef INTERFACE
CLASS(NexuizDemoBrowserTab) EXTENDS(NexuizTab)
	METHOD(NexuizDemoBrowserTab, fill, void(entity))
	ATTRIB(NexuizDemoBrowserTab, title, string, "Demo")
	ATTRIB(NexuizDemoBrowserTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizDemoBrowserTab, rows, float, 22)
	ATTRIB(NexuizDemoBrowserTab, columns, float, 6.5)
	ATTRIB(NexuizDemoBrowserTab, name, string, "DemoBroswer")	
ENDCLASS(NexuizDemoBrowserTab)
entity makeNexuizDemoBrowserTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizDemoBrowserTab()
{
	entity me;
	me = spawnNexuizDemoBrowserTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizDemoBrowserTab(entity me)
{
	entity e;
	entity btn;
	entity dlist;

	me.TR(me);
		me.TD(me, 1, me.columns, e = makeNexuizCheckBox(0, "cl_autodemo", "Record demos while playing"));
	me.TR(me);
	dlist = makeNexuizDemoList();
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeNexuizTextLabel(0, "Filter:"));
		me.TD(me, 1, 0.5, btn = makeNexuizButton("Clear", '0 0 0'));
			btn.onClick = InputBox_Clear_Click;
		me.TD(me, 1, me.columns - 1, e = makeNexuizInputBox(0, string_null));
			e.onChange = DemoList_Filter_Change;
			e.onChangeEntity = dlist;
			btn.onClickEntity = e;
			dlist.controlledTextbox = e;
	me.TR(me);
		me.TD(me, me.rows - 4, me.columns, dlist);
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns / 2, e = makeNexuizButton("Timedemo", '0 0 0'));
			e.onClick = TimeDemo_Click;
			e.onClickEntity = dlist;
		me.TD(me, 1, me.columns / 2, e = makeNexuizButton("Play", '0 0 0'));
			e.onClick = StartDemo_Click;
			e.onClickEntity = dlist;
}
#endif
