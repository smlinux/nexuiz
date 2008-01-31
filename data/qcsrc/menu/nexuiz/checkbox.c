#ifdef INTERFACE
CLASS(NexuizCheckBox) EXTENDS(CheckBox)
	METHOD(NexuizCheckBox, configureNexuizCheckBox, void(entity, float, string, string))
	METHOD(NexuizCheckBox, setChecked, void(entity, float))
	ATTRIB(NexuizCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizCheckBox, image, string, SKINGFX_CHECKBOX)
	ATTRIB(NexuizCheckBox, inverted, float, 0)
	// can be: 0   (off =  0, on =  1)
	//         1   (off =  1, on =  0)
	//         1+a (off =  a, on = -a)
	//        -1-a (off = -a, on =  a)

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
	if(theCvar)
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
	if(me.inverted == 0)
		me.checked = cvar(me.cvarName);
	else if(me.inverted == 1)
		me.checked = !cvar(me.cvarName);
	else if(me.inverted > 1)
		me.checked = (cvar(me.cvarName) < 0);
	else if(me.inverted < -1)
		me.checked = (cvar(me.cvarName) > 0);
}
void saveCvarsNexuizCheckBox(entity me)
{
	if(me.inverted == 0)
		cvar_set(me.cvarName, me.checked ? "1" : "0");
	else if(me.inverted == 1)
		cvar_set(me.cvarName, me.checked ? "0" : "1");
	else if(me.inverted > 1)
	{
		if(me.checked)
			cvar_set(me.cvarName, ftos(-(me.inverted - 1)));
		else
			cvar_set(me.cvarName, ftos(+(me.inverted - 1)));
	}
	else if(me.inverted < -1)
	{
		if(me.checked)
			cvar_set(me.cvarName, ftos(-(me.inverted + 1)));
		else
			cvar_set(me.cvarName, ftos(+(me.inverted + 1)));
	}
}
#endif
