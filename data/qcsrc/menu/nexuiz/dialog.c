#ifdef INTERFACE
CLASS(NexuizDialog) EXTENDS(Dialog)
	// still to be customized by user
	/*
	ATTRIB(NexuizDialog, closable, float, 1)
	ATTRIB(NexuizDialog, title, string, "Form1") // ;)
	ATTRIB(NexuizDialog, color, vector, '1 0.5 1')
	ATTRIB(NexuizDialog, intendedWidth, float, 0)
	ATTRIB(NexuizDialog, rows, float, 3)
	ATTRIB(NexuizDialog, columns, float, 2)
	*/
	ATTRIB(NexuizDialog, marginTop, float, SKINMARGIN_TOP) // pixels
	ATTRIB(NexuizDialog, marginBottom, float, SKINMARGIN_BOTTOM) // pixels
	ATTRIB(NexuizDialog, marginLeft, float, SKINMARGIN_LEFT) // pixels
	ATTRIB(NexuizDialog, marginRight, float, SKINMARGIN_RIGHT) // pixels
	ATTRIB(NexuizDialog, columnSpacing, float, SKINMARGIN_COLUMNS) // pixels
	ATTRIB(NexuizDialog, rowSpacing, float, SKINMARGIN_ROWS) // pixels
	ATTRIB(NexuizDialog, rowHeight, float, SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL) // pixels
	ATTRIB(NexuizDialog, titleHeight, float, SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE) // pixels
	ATTRIB(NexuizDialog, titleFontSize, float, SKINFONTSIZE_TITLE) // pixels

	ATTRIB(NexuizDialog, backgroundImage, string, SKINGFX_DIALOGBORDER)
	ATTRIB(NexuizDialog, borderLines, float, SKINHEIGHT_DIALOGBORDER)
	ATTRIB(NexuizDialog, closeButtonImage, string, SKINGFX_CLOSEBUTTON)
	ATTRIB(NexuizDialog, zoomedOutTitleBarPosition, float, SKINHEIGHT_ZOOMEDTITLE * 0.5 - 0.5)
	ATTRIB(NexuizDialog, zoomedOutTitleBar, float, SKINHEIGHT_ZOOMEDTITLE != 0)

	ATTRIB(NexuizDialog, alpha, float, SKINALPHA_TEXT)

	METHOD(NexuizDialog, configureDialog, void(entity))
ENDCLASS(NexuizDialog)
entity currentDialog;
#endif

#ifdef IMPLEMENTATION
void configureDialogNexuizDialog(entity me)
{
	currentDialog = me;
	configureDialogDialog(me);
	me.tooltip = getZonedTooltipForIdentifier(me.classname);
}
#endif
