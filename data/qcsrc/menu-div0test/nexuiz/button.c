#ifdef INTERFACE
CLASS(NexuizButton) EXTENDS(Button)
	METHOD(NexuizButton, configureNexuizButton, void(entity, string, vector))
	ATTRIB(NexuizButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizButton, image, string, SKINGFX_BUTTON)
	ATTRIB(NexuizButton, grayImage, string, SKINGFX_BUTTON_GRAY)
ENDCLASS(NexuizButton)
entity makeNexuizButton(string theText, vector theColor);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizButton(string theText, vector theColor)
{
	entity me;
	me = spawnNexuizButton();
	me.configureNexuizButton(me, theText, theColor);
	return me;
}

void configureNexuizButtonNexuizButton(entity me, string theText, vector theColor)
{
	if(theColor == '0 0 0')
	{
		me.configureButton(me, theText, me.fontSize, me.image);
	}
	else
	{
		me.configureButton(me, theText, me.fontSize, me.grayImage);
		me.color = theColor;
	}
}
#endif
