#ifdef INTERFACE
CLASS(NexuizBigCommandButton) EXTENDS(NexuizCommandButton)
	METHOD(NexuizBigCommandButton, configureNexuizBigCommandButton, void(entity, string, vector, string, float))
	ATTRIB(NexuizBigCommandButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NexuizBigCommandButton, grayImage, string, SKINGFX_BUTTON_BIG_GRAY)
ENDCLASS(NexuizCommandButton)
entity makeNexuizBigCommandButton(string theText, vector theColor, string theCommand, float closesMenu);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizBigCommandButton(string theText, vector theColor, string theCommand, float theFlags)
{
	entity me;
	me = spawnNexuizBigCommandButton();
	me.configureNexuizBigCommandButton(me, theText, theColor, theCommand, theFlags);
	return me;
}

void configureNexuizBigCommandButtonNexuizBigCommandButton(entity me, string theText, vector theColor, string theCommand, float theFlags)
{
	me.configureNexuizCommandButton(me, theText, theColor, theCommand, theFlags);
}
#endif
