#ifdef INTERFACE
CLASS(NexuizBigButton) EXTENDS(NexuizButton)
	METHOD(NexuizBigButton, configureNexuizBigButton, void(entity, string, vector))
	ATTRIB(NexuizBigButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NexuizBigButton, grayImage, string, SKINGFX_BUTTON_BIG_GRAY)
ENDCLASS(NexuizButton)
entity makeNexuizButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizBigButton(string theText, vector theColor)
{
	entity me;
	me = spawnNexuizBigButton();
	me.configureNexuizBigButton(me, theText, theColor);
	return me;
}

void configureNexuizBigButtonNexuizBigButton(entity me, string theText, vector theColor)
{
	me.configureNexuizButton(me, theText, theColor);
}
#endif
