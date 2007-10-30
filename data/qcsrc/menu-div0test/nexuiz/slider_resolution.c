#ifdef INTERFACE
CLASS(NexuizResolutionSlider) EXTENDS(NexuizSlider)
	METHOD(NexuizResolutionSlider, valueToText, string(entity, float))
	METHOD(NexuizResolutionSlider, configureNexuizResolutionSlider, void(entity))
	ATTRIB(NexuizResolutionSlider, resolutions, string, 
		" 640  480 "
		" 800  600 "
		" 960  600 "
		"1024  768 "
		"1152  864 "
		"1280  800 "
		"1280  960 "
		"1280 1024 "
		"1440  900 "
		"1600  900 "
		"1600 1200 "
		"1680 1050 "
		"1920 1200 "
		"2048 1536 "
	)
ENDCLASS(NexuizResolutionSlider)
entity makeNexuizResolutionSlider();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizResolutionSlider()
{
	entity me;
	me = spawnNexuizResolutionSlider();
	me.configureNexuizResolutionSlider(me);
	return me;
}
string valueToTextNexuizResolutionSlider(entity me, float theValue)
{
	string r;
	float w, h;
	r = substring(me.resolutions, (theValue - 1) * 10, 10);
	w = stof(substring(r, 0, 5));
	h = stof(substring(r, 5, 10));
	return strcat(ftos(w), "x", ftos(h));
}
void configureNexuizResolutionSliderNexuizResolutionSlider(entity me)
{
	me.configureNexuizSlider(me, 1, strlen(me.resolutions) / 10, 1, "vid_width");
}
#endif
