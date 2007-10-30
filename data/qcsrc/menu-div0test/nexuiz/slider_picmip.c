#ifdef INTERFACE
CLASS(NexuizPicmipSlider) EXTENDS(NexuizSlider)
	METHOD(NexuizPicmipSlider, valueToText, string(entity, float))
	METHOD(NexuizPicmipSlider, configureNexuizPicmipSlider, void(entity))
ENDCLASS(NexuizPicmipSlider)
entity makeNexuizPicmipSlider();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizPicmipSlider()
{
	entity me;
	me = spawnNexuizPicmipSlider();
	me.configureNexuizPicmipSlider(me);
	return me;
}
string valueToTextNexuizPicmipSlider(entity me, float theValue)
{
	switch(floor(theValue + 0.5))
	{
		case 0:  return "best";
		case 1:  return "good";
		case 2:  return "medium";
		case 3:  return "low";
		case 4:  return "none";
		default: return "custom";
	}
}
void configureNexuizPicmipSliderNexuizPicmipSlider(entity me)
{
	me.configureNexuizSlider(me, 4, 0, -1, "gl_picmip");
}
#endif
