#ifdef INTERFACE
CLASS(NexuizUserbindEditDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizUserbindEditDialog, loadUserBind, void(entity, string, string, string))
	METHOD(NexuizUserbindEditDialog, fill, void(entity))
	ATTRIB(NexuizUserbindEditDialog, title, string, "User defined key bind")
	ATTRIB(NexuizUserbindEditDialog, color, vector, SKINCOLOR_DIALOG_USERBIND)
	ATTRIB(NexuizUserbindEditDialog, intendedWidth, float, 0.7)
	ATTRIB(NexuizUserbindEditDialog, rows, float, 4)
	ATTRIB(NexuizUserbindEditDialog, columns, float, 3)
	ATTRIB(NexuizUserbindEditDialog, keybindBox, entity, NULL)

	ATTRIB(NexuizUserbindEditDialog, nameBox, entity, NULL)
	ATTRIB(NexuizUserbindEditDialog, commandPressBox, entity, NULL)
	ATTRIB(NexuizUserbindEditDialog, commandReleaseBox, entity, NULL)
ENDCLASS(NexuizUserbindEditDialog)
#endif

#ifdef IMPLEMENTATION
void NexuizUserbindEditDialog_Save(entity btn, entity me)
{
	me.keybindBox.editUserbind(me.keybindBox, me.nameBox.text, me.commandPressBox.text, me.commandReleaseBox.text);
	Dialog_Close(btn, me);
}

void loadUserBindNexuizUserbindEditDialog(entity me, string theName, string theCommandPress, string theCommandRelease)
{
	me.nameBox.setText(me.nameBox, theName);
		me.nameBox.keyDown(me.nameBox, K_END, 0, 0);
	me.commandPressBox.setText(me.commandPressBox, theCommandPress);
		me.nameBox.keyDown(me.commandPressBox, K_END, 0, 0);
	me.commandReleaseBox.setText(me.commandReleaseBox, theCommandRelease);
		me.nameBox.keyDown(me.commandReleaseBox, K_END, 0, 0);
}

void fillNexuizUserbindEditDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Name:"));
		me.TD(me, 1, me.columns - 1, me.nameBox = makeNexuizInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Command when pressed:"));
		me.TD(me, 1, me.columns - 1, me.commandPressBox = makeNexuizInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Command when released:"));
		me.TD(me, 1, me.columns - 1, me.commandReleaseBox = makeNexuizInputBox(0, string_null));
	me.TR(me);
		me.TD(me, 1, me.columns / 2, e = makeNexuizButton("Save", '0 0 0'));
			e.onClick = NexuizUserbindEditDialog_Save;
			e.onClickEntity = me;
		me.TD(me, 1, me.columns / 2, e = makeNexuizButton("Cancel", '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}
#endif
