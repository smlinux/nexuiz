#ifdef INTERFACE
CLASS(NexuizSlider) EXTENDS(Slider)
	METHOD(NexuizSlider, configureNexuizSlider, void(entity, float, float, float, string))
	ATTRIB(NexuizSlider, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizSlider, valueSpace, float, SKINWIDTH_SLIDERTEXT)
	ATTRIB(NexuizSlider, image, string, SKINGFX_SLIDER)

	ATTRIB(NexuizSlider, cvarName, string, string_null)
	METHOD(NexuizSlider, loadCvars, void(entity))
	METHOD(NexuizSlider, saveCvars, void(entity))
ENDCLASS(NexuizSlider)
entity makeNexuizSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizSlider(float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	entity me;
	me = spawnNexuizSlider();
	me.configureNexuizSlider(me, theValueMin, theValueMax, theValueStep, theCvar);
	return me;
}
void configureNexuizSliderNexuizSlider(entity me, float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	float v, vk, vp;
	v = theValueMin;
	if(theCvar != "")
	{
		me.cvarName = theCvar;
		me.loadCvars(me);
	}
	vk = theValueStep;
	vp = theValueStep * 10;
	while(vp < (theValueMax - theValueMin) / 40)
		vp *= 10;
	me.configureSliderVisuals(me, me.fontSize, me.valueSpace, me.image);
	me.configureSliderValues(me, theValueMin, v, theValueMax, theValueStep, vk, vp);
}
void loadCvarsNexuizSlider(entity me)
{
	me.value = cvar(me.cvarName);
}
void saveCvarsNexuizSlider(entity me)
{
	cvar_set(me.cvarName, ftos(me.value));
}
#endif
