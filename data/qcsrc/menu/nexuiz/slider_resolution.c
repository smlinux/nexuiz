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
	float f;
	f = max(cw / w, ch / h);
	if(f > 1)
	{
		cw = rint(cw / f);
		ch = rint(ch / f);
	}
	me.addValue(me, strzone(strcat(ftos(w), "x", ftos(h))), strzone(strcat(ftos(w), " ", ftos(h), " ", ftos(cw), " ", ftos(ch))));
	// FIXME (in case you ever want to dynamically instantiate this): THIS IS NEVER FREED
}
void configureNexuizResolutionSliderNexuizResolutionSlider(entity me)
{
	float i;
	vector r0, r, c;

	me.configureNexuizTextSlider(me, "vid_width");

	c = '0 0 0';
	r0 = '0 0 0';
	for(i = 0;; ++i)
	{
		r = getresolution(i);
		if(r_x == 0 && r_y == 0)
			break;
		if(r == r0)
			continue;
		r0 = r;
		if(r_x < 640 || r_y < 400)
			continue;
		c_x = 800;
		c_y = rint(c_x * r_y / r_x);
		if(c_y >= 600)
		{
			me.addResolution(me, r_x, r_y, c_x, c_y);
			continue;
		}
		c_y = 600;
		c_x = rint(c_y * r_x / r_y);
		me.addResolution(me, r_x, r_y, c_x, c_y);
	}

	me.configureNexuizTextSliderValues(me);
}
void loadCvarsNexuizResolutionSlider(entity me)
{
	me.setValueFromIdentifier(me, strcat(cvar_string("vid_width"), " ", cvar_string("vid_height"), " ", cvar_string("menu_vid_conwidth"), " ", cvar_string("menu_vid_conheight")));
}
void saveCvarsNexuizResolutionSlider(entity me)
{
	if(me.value >= 0 || me.value < me.nValues)
	{
		tokenize_console(me.getIdentifier(me));
		cvar_set("vid_width", argv(0));
		cvar_set("vid_height", argv(1));
		cvar_set("menu_vid_conwidth", argv(2));
		cvar_set("menu_vid_conheight", argv(3));
	}
}
#endif
