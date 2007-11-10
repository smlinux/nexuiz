#ifdef INTERFACE
CLASS(NexuizMultiplayerDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizMultiplayerDialog, fill, void(entity))
	ATTRIB(NexuizMultiplayerDialog, title, string, "Multiplayer")
	ATTRIB(NexuizMultiplayerDialog, color, vector, SKINCOLOR_DIALOG_MULTIPLAYER)
	ATTRIB(NexuizMultiplayerDialog, intendedWidth, float, 0.96)
	ATTRIB(NexuizMultiplayerDialog, rows, float, 24)
	ATTRIB(NexuizMultiplayerDialog, columns, float, 6)
ENDCLASS(NexuizMultiplayerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizMultiplayerDialog(entity me)
{
	entity mc;
	mc = makeNexuizTabController(me.rows - 2);
	me.TR(me);
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Serverlist",  makeNexuizServerListTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Player Setup",  makeNexuizPlayerSettingsTab()));
		me.TD(me, 1, 1, mc.makeTabButton(mc, "Server Setup",  makeNexuizPlayerSettingsTab()));
	me.TR(me);
	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, mc);
}
#endif
