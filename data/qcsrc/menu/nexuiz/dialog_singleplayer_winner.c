#ifdef INTERFACE
CLASS(NexuizWinnerDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizWinnerDialog, fill, void(entity))
	ATTRIB(NexuizWinnerDialog, title, string, "Winner")
	ATTRIB(NexuizWinnerDialog, color, vector, SKINCOLOR_DIALOG_SINGLEPLAYER)
	ATTRIB(NexuizWinnerDialog, intendedWidth, float, 0.32)
	ATTRIB(NexuizWinnerDialog, rows, float, 12)
	ATTRIB(NexuizWinnerDialog, columns, float, 3)
ENDCLASS(NexuizWinnerDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizWinnerDialog(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, me.rows - 2, me.columns, e = makeNexuizImage("/gfx/winner", -1));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
