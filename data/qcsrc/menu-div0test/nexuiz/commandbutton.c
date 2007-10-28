#ifdef INTERFACE
CLASS(CommandButton) EXTENDS(NexuizButton)
	METHOD(CommandButton, configureCommandButton, void(entity, string, vector, string, float))
	ATTRIB(CommandButton, onClickCommand, string, "")
	ATTRIB(CommandButton, closes, float, 0)
ENDCLASS(CommandButton)
entity makeCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeCommandButton(string theText, vector theColor, string theCommand, float closesMenu)
{
	entity me;
	me = spawnCommandButton();
	me.configureCommandButton(me, theText, theColor, theCommand, closesMenu);
	return me;
}

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
	me.configureNexuizButton(me, theText, theColor);
	me.onClickCommand = theCommand;
	me.closes = closesMenu;
	me.onClick = CommandButton_Click;
	me.onClickEntity = me;
}
#endif
