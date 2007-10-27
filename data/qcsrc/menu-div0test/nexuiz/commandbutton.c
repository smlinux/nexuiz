#ifdef INTERFACE
CLASS(CommandButton) EXTENDS(Button)
	METHOD(CommandButton, configureCommandButton, void(entity, string, vector, string, float))
	ATTRIB(CommandButton, onClickCommand, string, "")
	ATTRIB(CommandButton, closes, float, 0)
ENDCLASS(CommandButton)
#endif

#ifdef IMPLEMENTATION
void CommandButton_Click(entity me, entity other)
{
	cmd("\n", me.onClickCommand, "\n");
	if(me.closes)
	{
		m_goto("");
	}
}

void configureCommandButtonCommandButton(entity me, string theText, vector theColor, string theCommand, float closesMenu)
{
	if(theColor == '0 0 0')
	{
		me.configureButton(me, theText, SKINFONTSIZE_NORMAL, SKINGFX_BUTTON);
	}
	else
	{
		me.configureButton(me, theText, SKINFONTSIZE_NORMAL, SKINGFX_BUTTON_GRAY);
		me.color = theColor;
	}
	me.onClickCommand = theCommand;
	me.closes = closesMenu;
	me.onClick = CommandButton_Click;
	me.onClickEntity = me;
}
#endif
