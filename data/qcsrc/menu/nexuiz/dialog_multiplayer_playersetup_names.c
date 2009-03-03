#ifdef INTERFACE
CLASS(NexuizNamesDialog) EXTENDS(NexuizDialog)
	METHOD(NexuizNamesDialog, toString, string(entity))
	ATTRIB(NexuizNamesDialog, title, string, "Favorite Names")
	ATTRIB(NexuizNamesDialog, color, vector, SKINCOLOR_DIALOG_MUTATORS) // FIXME: replace SKINCOLOR_DIALOG_MUTATORS with something else
	ATTRIB(NexuizNamesDialog, intendedWidth, float, 0.45)
	ATTRIB(NexuizNamesDialog, rows, float, 5)
	ATTRIB(NexuizNamesDialog, columns, float, 6)
	ATTRIB(NexuizNamesDialog, refilterEntity, entity, NULL)
ENDCLASS(NexuizNamesDialog)
#endif

#ifdef IMPLEMENTATION
string toStringNexuizNamesDialog(entity me)
{
	return cvar_string("_cl_name");
}
#endif
