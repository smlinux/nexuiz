#ifdef INTERFACE
CLASS(NexuizRootDialog) EXTENDS(NexuizDialog)
	// still to be customized by user
	/*
	ATTRIB(NexuizDialog, closable, float, 1)
	ATTRIB(NexuizDialog, title, string, "Form1") // ;)
	ATTRIB(NexuizDialog, color, vector, '1 0.5 1')
	ATTRIB(NexuizDialog, intendedWidth, float, 0)
	ATTRIB(NexuizDialog, rows, float, 3)
	ATTRIB(NexuizDialog, columns, float, 2)
	*/
	METHOD(NexuizRootDialog, close, void(entity))
ENDCLASS(NexuizRootDialog)
#endif

#ifdef IMPLEMENTATION
void closeNexuizRootDialog(entity me)
{
	m_goto(string_null);
}
#endif
