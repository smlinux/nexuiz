#ifdef INTERFACE
CLASS(TeamSelectDialog) EXTENDS(Dialog)
	METHOD(TeamSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	ATTRIB(TeamSelectDialog, closable, float, 1)
	ATTRIB(TeamSelectDialog, title, string, "Team selection") // ;)
	ATTRIB(TeamSelectDialog, color, vector, '1 1 1')
	ATTRIB(TeamSelectDialog, intendedWidth, float, 0.6)
	ATTRIB(TeamSelectDialog, intendedHeight, float, 0.15)
	ATTRIB(TeamSelectDialog, name, string, "TeamSelect")
ENDCLASS(TeamSelectDialog)
#endif

#ifdef IMPLEMENTATION
void fillTeamSelectDialog(entity me)
{
	entity e;

	e = spawnCommandButton();
	e.configureCommandButton(e, "Auto", '0 0 0', "cmd selectteam auto; cmd join", 1);
	me.addItemSimple(me, 1, 1, 1, e);

	e = spawnCommandButton();
	e.configureCommandButton(e, "Red", '1 0 0', "cmd selectteam red; cmd join", 1);
	me.addItemSimple(me, me.lines, 1, 4, e);
	e = spawnCommandButton();
	e.configureCommandButton(e, "Blue", '0 0 1', "cmd selectteam blue; cmd join", 1);
	me.addItemSimple(me, me.lines, 2, 4, e);
	e = spawnCommandButton();
	e.configureCommandButton(e, "Yellow", '1 1 0', "cmd selectteam yellow; cmd join", 1);
	me.addItemSimple(me, me.lines, 3, 4, e);
	e = spawnCommandButton();
	e.configureCommandButton(e, "Pink", '1 0 1', "cmd selectteam pink; cmd join", 1);
	me.addItemSimple(me, me.lines, 4, 4, e);
}
#endif

// click. The C-word so you can grep for it.
