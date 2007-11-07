#ifdef INTERFACE
CLASS(NexuizTextSlider) EXTENDS(TextSlider)
	METHOD(NexuizTextSlider, configureNexuizTextSlider, void(entity, string))
	METHOD(NexuizTextSlider, setValue, void(entity, float))
	METHOD(NexuizTextSlider, configureNexuizTextSliderValues, void(entity))
	ATTRIB(NexuizTextSlider, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizTextSlider, valueSpace, float, SKINWIDTH_SLIDERTEXT)
	ATTRIB(NexuizTextSlider, image, string, SKINGFX_SLIDER)
	ATTRIB(NexuizSlider, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(NexuizTextSlider, align, float, 0.5)

	ATTRIB(NexuizTextSlider, cvarName, string, string_null)
	METHOD(NexuizTextSlider, loadCvars, void(entity))
	METHOD(NexuizTextSlider, saveCvars, void(entity))
ENDCLASS(NexuizTextSlider)
entity makeNexuizTextSlider(string); // note: you still need to call addValue and configureNexuizTextSliderValues!
#endif

#ifdef IMPLEMENTATION
entity makeNexuizTextSlider(string theCvar)
{
	entity me;
	me = spawnNexuizTextSlider();
	me.configureNexuizTextSlider(me, theCvar);
	return me;
}
void configureNexuizTextSliderNexuizTextSlider(entity me, string theCvar)
{
	me.configureSliderVisuals(me, me.fontSize, me.align, me.valueSpace, me.image);
	if(theCvar)
		me.cvarName = theCvar;
		// don't load it yet
}
void setValueNexuizTextSlider(entity me, float val)
{
	if(val != me.value)
	{
		me.value = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizTextSlider(entity me)
{
	me.setValueFromIdentifier(me, cvar_string(me.cvarName));
}
void saveCvarsNexuizTextSlider(entity me)
{
	if(me.value >= 0 && me.value < me.nValues)
		cvar_set(me.cvarName, me.getIdentifier(me));
}
void configureNexuizTextSliderValuesNexuizTextSlider(entity me)
{
	me.configureTextSliderValues(me, string_null);
	me.loadCvars(me);
}
#endif
