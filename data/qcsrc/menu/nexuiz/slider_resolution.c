#ifdef INTERFACE
CLASS(NexuizResolutionSlider) EXTENDS(NexuizTextSlider)
	METHOD(NexuizResolutionSlider, configureNexuizResolutionSlider, void(entity))
	METHOD(NexuizResolutionSlider, addResolution, void(entity, float, float, float, float))
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
void addResolutionNexuizResolutionSlider(entity me, float w, float h, float cw, float ch)
{
	me.addValue(me, strzone(strcat(ftos(w), "x", ftos(h))), strzone(strcat(ftos(w), " ", ftos(h), " ", ftos(cw), " ", ftos(ch))));
	// FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
}
void configureNexuizResolutionSliderNexuizResolutionSlider(entity me)
{
	me.configureNexuizTextSlider(me, "vid_width");
	me.addResolution(me, 640, 480, 640, 480);
	me.addResolution(me, 800, 480, 800, 480);
	me.addResolution(me, 800, 600, 800, 600);
	me.addResolution(me, 1024, 600, 800, 468.75);
	me.addResolution(me, 1024, 768, 800, 600);
	me.addResolution(me, 1152, 864, 800, 600);
	me.addResolution(me, 1280, 800, 800, 500);
	me.addResolution(me, 1280, 960, 800, 600);
	me.addResolution(me, 1280, 1024, 800, 640);
	me.addResolution(me, 1440, 900, 800, 500);
	me.addResolution(me, 1600, 900, 800, 450);
	me.addResolution(me, 1600, 1200, 800, 600);
	me.addResolution(me, 1680, 1050, 800, 500);
	me.addResolution(me, 1920, 1200, 800, 500);
	me.addResolution(me, 2048, 1536, 800, 600);
	me.configureNexuizTextSliderValues(me);
}
void loadCvarsNexuizResolutionSlider(entity me)
{
	me.setValueFromIdentifier(me, strcat(cvar_string("vid_width"), " ", cvar_string("vid_height"), " ", cvar_string("vid_conwidth"), " ", cvar_string("vid_conheight")));
}
void saveCvarsNexuizResolutionSlider(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
		tokenize_console(me.getIdentifier(me));
		cvar_set("vid_width", argv(0));
		cvar_set("vid_height", argv(1));
		cvar_set("vid_conwidth", argv(2));
		cvar_set("vid_conheight", argv(3));
	}
}
#endif
