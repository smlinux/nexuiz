#ifdef INTERFACE
CLASS(Dialog) EXTENDS(InputContainer)
	METHOD(Dialog, configureDialog, void(entity)) // no runtime configuration, all parameters are given in the code!
	METHOD(Dialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(Dialog, keyDown, float(entity, float, float, float))
	METHOD(Dialog, close, void(entity))
	METHOD(Dialog, addItemSimple, void(entity, float, float, float, entity))
	ATTRIB(Dialog, isTabRoot, float, 1)
	ATTRIB(Dialog, closeButton, entity, NULL)
	ATTRIB(Dialog, firstLine, float, 0)
	ATTRIB(Dialog, lineSpacing, float, 0)
	ATTRIB(Dialog, firstColumn, float, 0)
	ATTRIB(Dialog, columnWidth, float, 0)
	ATTRIB(Dialog, lineHeight, float, 0)

	// to be customized
	ATTRIB(Dialog, closable, float, 1)
	ATTRIB(Dialog, rootDialog, float, 1)
	ATTRIB(Dialog, title, string, "Form1") // ;)
	ATTRIB(Dialog, color, vector, '1 0.5 1')
	ATTRIB(Dialog, intendedWidth, float, 0.96)
	ATTRIB(Dialog, intendedHeight, float, 0.96)
	ATTRIB(Dialog, lines, float, 5)
ENDCLASS(Dialog)
#endif

#ifdef IMPLEMENTATION
void Dialog_Close(entity button, entity me)
{
	me.close(me);
}

void fillDialog(entity me)
{
}

void addItemSimpleDialog(entity me, float line, float col, float cols, entity e)
{
	me.addItem(me, e, (me.firstLine + (line - 1) * me.lineSpacing) * eY + (me.firstColumn + (col - 1) / cols * me.columnWidth) * eX, me.lineHeight * eY + me.columnWidth / cols * eX, 1);
}

void configureDialogDialog(entity me)
{
	entity frame, closebutton;
	float ch, cw;

	frame = spawnBorderImage();
	frame.configureBorderImage(frame, me.title, SKINFONTSIZE_TITLE, me.color, SKINGFX_DIALOGBORDER, SKINHEIGHT_TITLE);
	me.addItem(me, frame, '0 0 0', '1 1 0', 1);

	ch = me.intendedHeight * cvar("vid_conheight");
	cw = me.intendedWidth * cvar("vid_conwidth");

	me.firstLine = (SKINFONTSIZE_TITLE * SKINHEIGHT_TITLE + SKINMARGIN_TOP) / ch;
	me.lineSpacing = SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL_WITHSPACING / ch;
	me.lineHeight = SKINFONTSIZE_NORMAL * SKINHEIGHT_NORMAL/ ch;
	me.firstColumn = SKINMARGIN_LEFT / cw;
	me.columnWidth = 1 - 2 * SKINMARGIN_LEFT / cw;

	me.lines = (1 - SKINMARGIN_TOP / ch - me.firstLine + me.lineSpacing - me.lineHeight) / me.lineSpacing;

	me.fill(me);

	if(me.closable)
	{
		closebutton = me.closeButton = spawnButton();
		closebutton.configureButton(closebutton, "", 12, SKINGFX_CLOSEBUTTON);
		closebutton.onClick = Dialog_Close; closebutton.onClickEntity = me;
		closebutton.srcMulti = 0;
		me.addItem(me, closebutton, '0 0 0', '1 1 0', 1); // put it as LAST
	}

	frame.closeButton = closebutton;
}

void closeDialog(entity me)
{
	if(me.parent.instanceOfNexposee)
	{
		ExposeeCloseButton_Click(me, me.parent);
	}
	else if(me.parent.instanceOfModalController)
	{
		DialogCloseButton_Click(me, me);
	}
	if(me.rootDialog)
	{
		m_goto("");
	}
}

float keyDownDialog(entity me, float key, float ascii, float shift)
{
	if(me.closable)
	{
		if(key == K_ESCAPE)
		{
			me.close(me);
			return 1;
		}
	}
	return keyDownInputContainer(me, key, ascii, shift);
}
#endif
