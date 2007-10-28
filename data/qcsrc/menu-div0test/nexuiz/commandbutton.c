#ifdef INTERFACE
CLASS(NexuizCommandButton) EXTENDS(NexuizButton)
	METHOD(NexuizCommandButton, configureNexuizCommandButton, void(entity, string, vector, string, float))
	ATTRIB(NexuizCommandButton, onClickCommand, string, "")
	ATTRIB(NexuizCommandButton, closes, float, 0)
ENDCLASS(NexuizCommandButton)
entity makeNexuizCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCommandButton(string theText, vector theColor, string theCommand, float closesMenu)
{
	entity me;
	me = spawnNexuizCommandButton();
	me.configureNexuizCommandButton(me, theText, theColor, theCommand, closesMenu);
	return me;
}

void NexuizCommandButton_Click(entity me, entity other)
{
	cmd("\n", me.onClickCommand, "\n");
	if(me.closes)
	{
		m_goto("");
	}
}

void configureNexuizCommandButtonNexuizCommandButton(entity me, string theText, vector theColor, string theCommand, float closesMenu)
{
	me.configureNexuizButton(me, theText, theColor);
	me.onClickCommand = theCommand;
	me.closes = closesMenu;
	me.onClick = NexuizCommandButton_Click;
	me.onClickEntity = me;
}
#endif
