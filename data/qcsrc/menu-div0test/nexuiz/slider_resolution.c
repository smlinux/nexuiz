#ifdef INTERFACE
CLASS(NexuizResolutionSlider) EXTENDS(NexuizTextSlider)
	METHOD(NexuizResolutionSlider, configureNexuizResolutionSlider, void(entity))
	METHOD(NexuizResolutionSlider, addResolution, void(entity, float, float))
	METHOD(NexuizResolutionSlider, loadCvars, void(entity))
	METHOD(NexuizResolutionSlider, saveCvars, void(entity))
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
void addResolutionNexuizResolutionSlider(entity me, float w, float h)
{
	me.addValue(me, strzone(strcat(ftos(w), "x", ftos(h))), strzone(strcat(ftos(w), " ", ftos(h))));
	// FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
}
void configureNexuizResolutionSliderNexuizResolutionSlider(entity me)
{
	me.configureNexuizTextSlider(me, "vid_width");
	me.addResolution(me, 640, 480);
	me.addResolution(me, 800, 600);
	me.addResolution(me, 1024, 768);
	me.addResolution(me, 1152, 864);
	me.addResolution(me, 1280, 800);
	me.addResolution(me, 1280, 960);
	me.addResolution(me, 1280, 1024);
	me.addResolution(me, 1440, 900);
	me.addResolution(me, 1600, 900);
	me.addResolution(me, 1600, 1200);
	me.addResolution(me, 1680, 1050);
	me.addResolution(me, 1920, 1200);
	me.addResolution(me, 2048, 1536);
	me.configureNexuizTextSliderValues(me);
}
void loadCvarsNexuizResolutionSlider(entity me)
{
	me.setValueFromIdentifier(me, strcat(cvar_string("vid_width"), " ", cvar_string("vid_height")));
}
void saveCvarsNexuizResolutionSlider(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
		tokenize(me.getIdentifier(me));
		cvar_set("vid_width", argv(0));
		cvar_set("vid_height", argv(1));
	}
}
#endif
