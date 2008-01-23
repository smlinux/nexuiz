#ifdef INTERFACE
CLASS(NexuizCrosshairButton) EXTENDS(RadioButton)
	METHOD(NexuizCrosshairButton, configureNexuizCrosshairButton, void(entity, float, float))
	METHOD(NexuizCrosshairButton, setChecked, void(entity, float))
	METHOD(NexuizCrosshairButton, draw, void(entity))
	ATTRIB(NexuizCrosshairButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizCrosshairButton, image, string, SKINGFX_CROSSHAIRBUTTON)

	ATTRIB(NexuizCrosshairButton, useDownAsChecked, float, 1)

	ATTRIB(NexuizCrosshairButton, cvarName, string, string_null)
	ATTRIB(NexuizCrosshairButton, cvarValueFloat, float, 0)
	METHOD(NexuizCrosshairButton, loadCvars, void(entity))
	METHOD(NexuizCrosshairButton, saveCvars, void(entity))

	ATTRIB(NexuizCrosshairButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NexuizCrosshairButton)
entity makeNexuizCrosshairButton(float, float);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCrosshairButton(float theGroup, float theCrosshair)
{
	entity me;
	me = spawnNexuizCrosshairButton();
	me.configureNexuizCrosshairButton(me, theGroup, theCrosshair);
	return me;
}
void configureNexuizCrosshairButtonNexuizCrosshairButton(entity me, float theGroup, float theCrosshair)
{
	me.cvarName = "crosshair";
	me.cvarValueFloat = theCrosshair;
	me.loadCvars(me);
	me.configureRadioButton(me, string_null, me.fontSize, me.image, theGroup, 0);
	me.srcMulti = 1;
	me.src2 = strzone(strcat("/gfx/crosshair", ftos(me.cvarValueFloat)));
}
void setCheckedNexuizCrosshairButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizCrosshairButton(entity me)
{
	me.checked = (cvar(me.cvarName) == me.cvarValueFloat);
}
void saveCvarsNexuizCrosshairButton(entity me)
{
	if(me.checked)
		cvar_set(me.cvarName, ftos(me.cvarValueFloat));
	// TODO on an apply button, read _cl_color and execute the color command for it
}
void drawNexuizCrosshairButton(entity me)
{
	me.color2 = eX * cvar("crosshair_color_red") + eY * cvar("crosshair_color_green") + eZ * cvar("crosshair_color_blue");
	me.alpha2 = cvar("crosshair_color_alpha");
	me.src2scale = min((draw_PictureSize(me.src2) * eY * cvar("crosshair_size")) / me.size_y, (draw_PictureSize(me.src2) * eX * cvar("crosshair_size")) / me.size_x, 0.8);
	if(!me.checked && !me.focused)
	{
		me.alpha2 *= me.disabledAlpha;
		me.color2 = '1 1 1';
	}
	drawCheckBox(me);
}
#endif
