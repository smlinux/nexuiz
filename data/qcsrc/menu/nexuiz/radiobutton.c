#ifdef INTERFACE
CLASS(NexuizRadioButton) EXTENDS(RadioButton)
	METHOD(NexuizRadioButton, configureNexuizRadioButton, void(entity, float, string, string, string))
	METHOD(NexuizRadioButton, draw, void(entity))
	METHOD(NexuizRadioButton, setChecked, void(entity, float))
	ATTRIB(NexuizRadioButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizRadioButton, image, string, SKINGFX_RADIOBUTTON)
	ATTRIB(NexuizRadioButton, color, vector, SKINCOLOR_RADIOBUTTON_N)
	ATTRIB(NexuizRadioButton, colorC, vector, SKINCOLOR_RADIOBUTTON_C)
	ATTRIB(NexuizRadioButton, colorF, vector, SKINCOLOR_RADIOBUTTON_F)
	ATTRIB(NexuizRadioButton, colorD, vector, SKINCOLOR_RADIOBUTTON_D)

	ATTRIB(NexuizRadioButton, cvarName, string, string_null)
	ATTRIB(NexuizRadioButton, cvarValue, string, string_null)
	ATTRIB(NexuizRadioButton, cvarOffValue, string, string_null)
	METHOD(NexuizRadioButton, loadCvars, void(entity))
	METHOD(NexuizRadioButton, saveCvars, void(entity))

	ATTRIB(NexuizRadioButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NexuizRadioButton, disabledAlpha, float, SKINALPHA_DISABLED)
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
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.cvarValue = theValue;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
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
	if(me.cvarValue)
	{
		if(me.cvarName)
			me.checked = (cvar_string(me.cvarName) == me.cvarValue);
	}
	else
	{
		if(me.cvarName)
		{
			me.checked = !!cvar(me.cvarName);
		}
		else
		{
			// this is difficult
			// this is the "generic" selection... but at this time, not
			// everything is constructed yet.
			// we need to set this later in draw()
			me.checked = 0;
		}
	}
}
void drawNexuizRadioButton(entity me)
{
	if not(me.cvarValue)
		if not(me.cvarName)
		{
			// this is the "other" option
			// always select this if none other is
			entity e;
			float found;
			found = 0;
			for(e = me.parent.firstChild; e; e = e.nextSibling)
				if(e.group == me.group)
					if(e.checked)
						found = 1;
			if(!found)
				me.setChecked(me, 1);
		}
	drawCheckBox(me);
}
void saveCvarsNexuizRadioButton(entity me)
{
	if(me.cvarValue)
	{
		if(me.cvarName)
		{
			if(me.checked)
				cvar_set(me.cvarName, me.cvarValue);
			else if(me.cvarOffValue)
				cvar_set(me.cvarName, me.cvarOffValue);
		}
	}
	else
	{
		if(me.cvarName)
		{
			cvar_set(me.cvarName, ftos(me.checked));
		}
	}
}
#endif
