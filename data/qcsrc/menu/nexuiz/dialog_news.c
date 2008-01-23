#ifdef INTERFACE
CLASS(NexuizNewsDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizNewsDialog, fill, void(entity))
	ATTRIB(NexuizNewsDialog, title, string, "News")
	ATTRIB(NexuizNewsDialog, color, vector, SKINCOLOR_DIALOG_SETTINGS)
	ATTRIB(NexuizNewsDialog, intendedWidth, float, 0.96)
	ATTRIB(NexuizNewsDialog, rows, float, 24)
	ATTRIB(NexuizNewsDialog, columns, float, 1)
ENDCLASS(NexuizNewsDialog)
#endif

#ifdef IMPLEMENTATION
void fillNexuizNewsDialog(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 24, 1, e = spawnGecko());
		e.configureBrowser( e, "http://alientrap.org/nexuiz/index.php?module=news" );
}
#endif
