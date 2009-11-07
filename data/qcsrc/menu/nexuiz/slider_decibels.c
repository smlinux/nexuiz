#ifdef INTERFACE
CLASS(NexuizDecibelsSlider) EXTENDS(NexuizSlider)
	METHOD(NexuizDecibelsSlider, loadCvars, void(entity))
	METHOD(NexuizDecibelsSlider, saveCvars, void(entity))
	METHOD(NexuizDecibelsSlider, valueToText, string(entity, float))
ENDCLASS(NexuizDecibelsSlider)
entity makeNexuizDecibelsSlider(float, float, float, string);
#endif

#ifdef IMPLEMENTATION

entity makeNexuizDecibelsSlider(float theValueMin, float theValueMax, float theValueStep, string theCvar)
{
	entity me;
	me = spawnNexuizDecibelsSlider();
	me.configureNexuizSlider(me, theValueMin, theValueMax, theValueStep, theCvar);
	return me;
}
void loadCvarsNexuizDecibelsSlider(entity me)
{
	float v;

	if not(me.cvarName)
		return;

	v = cvar(me.cvarName);
	if(v >= 0.98)
		me.value = 0;
	else if(v < 0.0005)
		me.value = -1000000;
	else
		me.value = 0.1 * floor(0.5 + 10.0 * log10(cvar(me.cvarName)) * 10);
}
void saveCvarsNexuizDecibelsSlider(entity me)
{
	if not(me.cvarName)
		return;

	if(me.value >= -0.1)
		cvar_set(me.cvarName, "1");
	if(me.value < -33)
		cvar_set(me.cvarName, "0");
	else
		cvar_set(me.cvarName, ftos(pow(10, me.value / 10)));
}

string valueToTextNexuizDecibelsSlider(entity me, float v)
{
	if(v < -33)
		return "OFF";
	else if(v >= -0.1)
		return "MAX";
	return strcat(valueToTextSlider(me, v), " dB");
}

#endif
