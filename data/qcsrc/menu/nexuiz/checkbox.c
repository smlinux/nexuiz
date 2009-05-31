#ifdef INTERFACE
CLASS(NexuizCheckBox) EXTENDS(CheckBox)
	METHOD(NexuizCheckBox, configureNexuizCheckBox, void(entity, float, float, string, string))
	METHOD(NexuizCheckBox, setChecked, void(entity, float))
	ATTRIB(NexuizCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(NexuizCheckBox, yesValue, float, 1)
	ATTRIB(NexuizCheckBox, noValue, float, 0)

	ATTRIB(NexuizCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(NexuizCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(NexuizCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(NexuizCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(NexuizCheckBox, cvarName, string, string_null)
	METHOD(NexuizCheckBox, loadCvars, void(entity))
	METHOD(NexuizCheckBox, saveCvars, void(entity))

	ATTRIB(NexuizCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NexuizCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NexuizCheckBox)
entity makeNexuizCheckBox(float, string, string);
entity makeNexuizCheckBoxEx(float, float, string, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCheckBox(float isInverted, string theCvar, string theText)
{
	float y, n;
	if(isInverted > 1)
	{
		n = isInverted - 1;
		y = -n;
	}
	else if(isInverted < -1)
	{
		n = isInverted + 1;
		y = -n;
	}
	else if(isInverted == 1)
	{
		n = 1;
		y = 0;
	}
	else
	{
		n = 0;
		y = 1;
	}
	return makeNexuizCheckBoxEx(y, n, theCvar, theText);
}
entity makeNexuizCheckBoxEx(float theYesValue, float theNoValue, string theCvar, string theText)
{
	entity me;
	me = spawnNexuizCheckBox();
	me.configureNexuizCheckBox(me, theYesValue, theNoValue, theCvar, theText);
	return me;
}
void configureNexuizCheckBoxNexuizCheckBox(entity me, float theYesValue, float theNoValue, string theCvar, string theText)
{
	me.yesValue = theYesValue;
	me.noValue = theNoValue;
	me.checked = 0;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
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
	float m, d;

	if not(me.cvarName)
		return;

	m = (me.yesValue + me.noValue) * 0.5;
	d = (cvar(me.cvarName) - m) / (me.yesValue - m);
	me.checked = (d > 0);
}
void saveCvarsNexuizCheckBox(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
		cvar_set(me.cvarName, ftos(me.yesValue));
	else
		cvar_set(me.cvarName, ftos(me.noValue));
}
#endif
