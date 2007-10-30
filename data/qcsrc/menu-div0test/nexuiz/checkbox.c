#ifdef INTERFACE
CLASS(NexuizCheckBox) EXTENDS(CheckBox)
	METHOD(NexuizCheckBox, configureNexuizCheckBox, void(entity, float, string, string))
	METHOD(NexuizCheckBox, setChecked, void(entity, float))
	ATTRIB(NexuizCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(NexuizCheckBox, inverted, float, 0)

	ATTRIB(NexuizCheckBox, cvarName, string, string_null)
	METHOD(NexuizCheckBox, loadCvars, void(entity))
	METHOD(NexuizCheckBox, saveCvars, void(entity))
ENDCLASS(NexuizCheckBox)
entity makeNexuizCheckBox(float, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCheckBox(float isInverted, string theCvar, string theText)
{
	entity me;
	me = spawnNexuizCheckBox();
	me.configureNexuizCheckBox(me, isInverted, theCvar, theText);
	return me;
}
void configureNexuizCheckBoxNexuizCheckBox(entity me, float isInverted, string theCvar, string theText)
{
	me.inverted = isInverted;
	me.checked = 0;
	if(theCvar != "")
	{
		me.cvarName = theCvar;
		me.loadCvars(me);
	}
	me.configureCheckBox(me, theText, me.fontSize, me.image);
}
void setCheckedNexuizCheckBox(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizCheckBox(entity me)
{
	me.checked = me.inverted - !!cvar(me.cvarName);
}
void saveCvarsNexuizCheckBox(entity me)
{
	cvar_set(me.cvarName, ftos(fabs(me.inverted - me.checked)));
}
#endif
