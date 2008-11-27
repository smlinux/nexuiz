#ifdef INTERFACE
CLASS(NexuizColorButton) EXTENDS(RadioButton)
	METHOD(NexuizColorButton, configureNexuizColorButton, void(entity, float, float, float))
	METHOD(NexuizColorButton, setChecked, void(entity, float))
	METHOD(NexuizColorButton, draw, void(entity))
	ATTRIB(NexuizColorButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizColorButton, image, string, SKINGFX_COLORBUTTON)
	ATTRIB(NexuizColorButton, image2, string, SKINGFX_COLORBUTTON_COLOR)

	ATTRIB(NexuizColorButton, useDownAsChecked, float, 1)

	ATTRIB(NexuizColorButton, cvarPart, float, 0)
	ATTRIB(NexuizColorButton, cvarName, string, string_null)
	ATTRIB(NexuizColorButton, cvarValueFloat, float, 0)
	METHOD(NexuizColorButton, loadCvars, void(entity))
	METHOD(NexuizColorButton, saveCvars, void(entity))
ENDCLASS(NexuizColorButton)
entity makeNexuizColorButton(float, float, float);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizColorButton(float theGroup, float theColor, float theValue)
{
	entity me;
	me = spawnNexuizColorButton();
	me.configureNexuizColorButton(me, theGroup, theColor, theValue);
	return me;
}
void configureNexuizColorButtonNexuizColorButton(entity me, float theGroup, float theColor, float theValue)
{
	me.cvarName = "_cl_color";
	me.cvarValueFloat = theValue;
	me.cvarPart = theColor;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	me.src2 = me.image2;
}
void setCheckedNexuizColorButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizColorButton(entity me)
{
	if not(me.cvarName)
		return;

	if(me.cvarPart == 1)
		me.checked = (cvar(me.cvarName) & 240) == me.cvarValueFloat * 16;
	else
		me.checked = (cvar(me.cvarName) & 15) == me.cvarValueFloat;
}
void saveCvarsNexuizColorButton(entity me)
{
	if not(me.cvarName)
		return;

	if(me.checked)
	{
		if(me.cvarPart == 1)
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 15 + me.cvarValueFloat * 16));
		else
			cvar_set(me.cvarName, ftos(cvar(me.cvarName) & 240 + me.cvarValueFloat));
	}
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void drawNexuizColorButton(entity me)
{
	me.color2 = colormapPaletteColor(me.cvarValueFloat, me.cvarPart);
	drawCheckBox(me);
}
#endif
