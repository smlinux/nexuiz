#ifdef INTERFACE
CLASS(NexuizTab) EXTENDS(Tab)
	// still to be customized by user
	/*
	ATTRIB(NexuizTab, intendedWidth, float, 0)
	ATTRIB(NexuizTab, rows, float, 3)
	ATTRIB(NexuizTab, columns, float, 2)
	*/

	ATTRIB(NexuizTab, marginTop, float, 0) // pixels
	ATTRIB(NexuizTab, marginBottom, float, 0) // pixels
	ATTRIB(NexuizTab, marginLeft, float, 0) // pixels
	ATTRIB(NexuizTab, marginRight, float, 0) // pixels
	ATTRIB(NexuizTab, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(NexuizTab, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(NexuizTab, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(NexuizTab, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels

	ATTRIB(NexuizTab, backgroundImage, string, "")
ENDCLASS(NexuizTab)
#endif

#ifdef IMPLEMENTATION
#endif
