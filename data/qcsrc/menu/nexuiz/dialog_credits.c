#ifdef INTERFACE
CLASS(NexuizCreditsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizCreditsDialog, fill, void(entity))
	METHOD(NexuizCreditsDialog, focusEnter, void(entity))
	ATTRIB(NexuizCreditsDialog, title, string, "Credits")
	ATTRIB(NexuizCreditsDialog, color, vector, SKINCOLOR_DIALOG_CREDITS)
	ATTRIB(NexuizCreditsDialog, intendedWidth, float, SKINWIDTH_CREDITS)
	ATTRIB(NexuizCreditsDialog, rows, float, SKINROWS_CREDITS)
	ATTRIB(NexuizCreditsDialog, columns, float, 2)
	ATTRIB(NexuizCreditsDialog, creditsList, entity, NULL)
ENDCLASS(NexuizCreditsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizCreditsDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, me.rows - 1, me.columns, me.creditsList = makeNexuizCreditsList());
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeNexuizButton("OK", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
void focusEnterNexuizCreditsDialog(entity me)
{
	me.creditsList.scrolling = time + 1;
}
#endif
