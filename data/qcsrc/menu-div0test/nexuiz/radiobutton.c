#ifdef INTERFACE
CLASS(NexuizRadioButton) EXTENDS(RadioButton)
	METHOD(NexuizRadioButton, configureNexuizRadioButton, void(entity, float, string, string, string))
	METHOD(NexuizRadioButton, setChecked, void(entity, float))
	ATTRIB(NexuizRadioButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizRadioButton, image, string, SKINGFX_RADIOBUTTON)

	ATTRIB(NexuizRadioButton, cvarName, string, string_null)
	ATTRIB(NexuizRadioButton, cvarValue, string, string_null)
	METHOD(NexuizRadioButton, loadCvars, void(entity))
	METHOD(NexuizRadioButton, saveCvars, void(entity))
ENDCLASS(NexuizRadioButton)
entity makeNexuizRadioButton(float, string, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizRadioButton(float theGroup, string theCvar, string theValue, string theText)
{
	entity me;
	me = spawnNexuizRadioButton();
	me.configureNexuizRadioButton(me, theGroup, theCvar, theValue, theText);
	return me;
}
void configureNexuizRadioButtonNexuizRadioButton(entity me, float theGroup, string theCvar, string theValue, string theText)
{
	if(theCvar != "")
	{
		me.cvarName = theCvar;
		me.cvarValue = theValue;
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
}
void setCheckedNexuizRadioButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizRadioButton(entity me)
{
	me.checked = (cvar_string(me.cvarName) == me.cvarValue);
}
void saveCvarsNexuizRadioButton(entity me)
{
	if(me.checked)
		cvar_set(me.cvarName, me.cvarValue);
}
#endif
