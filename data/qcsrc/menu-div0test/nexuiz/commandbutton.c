#ifndef COMMANDBUTTON_CLOSE
# define COMMANDBUTTON_CLOSE 1
# define COMMANDBUTTON_APPLY 2
//# define COMMANDBUTTON_REVERT 4
#endif

#ifdef INTERFACE
CLASS(NexuizCommandButton) EXTENDS(NexuizButton)
	METHOD(NexuizCommandButton, configureNexuizCommandButton, void(entity, string, vector, string, float))
	ATTRIB(NexuizCommandButton, onClickCommand, string, string_null)
	ATTRIB(NexuizCommandButton, flags, float, 0)
ENDCLASS(NexuizCommandButton)
entity makeNexuizCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCommandButton(string theText, vector theColor, string theCommand, float theFlags)
{
	entity me;
	me = spawnNexuizCommandButton();
	me.configureNexuizCommandButton(me, theText, theColor, theCommand, theFlags);
	return me;
}

void NexuizCommandButton_Click(entity me, entity other)
{
	//if(me.flags & COMMANDBUTTON_APPLY)
	//	saveAllCvars(me.parent);
	cmd("\n", me.onClickCommand, "\n");
	//if(me.flags & COMMANDBUTTON_REVERT)
	//	loadAllCvars(me.parent);
	if(me.flags & COMMANDBUTTON_CLOSE)
		m_goto(string_null);
}

void configureNexuizCommandButtonNexuizCommandButton(entity me, string theText, vector theColor, string theCommand, float theFlags)
{
	me.configureNexuizButton(me, theText, theColor);
	me.onClickCommand = theCommand;
	me.flags = theFlags;
	me.onClick = NexuizCommandButton_Click;
	me.onClickEntity = me;
}
#endif
