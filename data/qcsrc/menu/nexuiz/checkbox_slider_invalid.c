#ifdef INTERFACE
CLASS(NexuizSliderCheckBox) EXTENDS(CheckBox)
	METHOD(NexuizSliderCheckBox, configureNexuizSliderCheckBox, void(entity, float, float, entity, string))
	METHOD(NexuizSliderCheckBox, setChecked, void(entity, float))
	METHOD(NexuizSliderCheckBox, draw, void(entity))
	ATTRIB(NexuizSliderCheckBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizSliderCheckBox, image, string, SKINGFX_CHECKBOX)

	ATTRIB(NexuizSliderCheckBox, color, vector, SKINCOLOR_CHECKBOX_N)
	ATTRIB(NexuizSliderCheckBox, colorC, vector, SKINCOLOR_CHECKBOX_C)
	ATTRIB(NexuizSliderCheckBox, colorF, vector, SKINCOLOR_CHECKBOX_F)
	ATTRIB(NexuizSliderCheckBox, colorD, vector, SKINCOLOR_CHECKBOX_D)

	ATTRIB(NexuizSliderCheckBox, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NexuizSliderCheckBox, disabledAlpha, float, SKINALPHA_DISABLED)

	ATTRIB(NexuizSliderCheckBox, controlledSlider, entity, NULL)
	ATTRIB(NexuizSliderCheckBox, offValue, float, -1)
	ATTRIB(NexuizSliderCheckBox, inverted, float, 0)
	ATTRIB(NexuizSliderCheckBox, savedValue, float, -1)
ENDCLASS(NexuizSliderCheckBox)
entity makeNexuizSliderCheckBox(float, float, entity, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizSliderCheckBox(float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	entity me;
	me = spawnNexuizSliderCheckBox();
	me.configureNexuizSliderCheckBox(me, theOffValue, isInverted, theControlledSlider, theText);
	return me;
}
void configureNexuizSliderCheckBoxNexuizSliderCheckBox(entity me, float theOffValue, float isInverted, entity theControlledSlider, string theText)
{
	me.offValue = theOffValue;
	me.inverted = isInverted;
	me.checked = (theControlledSlider.value == theOffValue);
	if(theControlledSlider.value == median(theControlledSlider.valueMin, theControlledSlider.value, theControlledSlider.valueMax))
		me.savedValue = theControlledSlider.value;
	else
		me.savedValue = theControlledSlider.valueMin; 
	me.controlledSlider = theControlledSlider;
	me.configureCheckBox(me, theText, me.fontSize, me.image);
	me.tooltip = theControlledSlider.tooltip;
}
void drawNexuizSliderCheckBox(entity me)
{
	me.checked = ((me.controlledSlider.value == me.offValue) != me.inverted);
	if(me.controlledSlider.value == median(me.controlledSlider.valueMin, me.controlledSlider.value, me.controlledSlider.valueMax))
		me.savedValue = me.controlledSlider.value;
	drawCheckBox(me);
}
void setCheckedNexuizSliderCheckBox(entity me, float val)
{
	if(me.checked == val)
		return;
	me.checked = val;
	if(val == me.inverted)
		me.controlledSlider.setValue(me.controlledSlider, median(me.controlledSlider.valueMin, me.savedValue, me.controlledSlider.valueMax));
	else
		me.controlledSlider.setValue(me.controlledSlider, me.offValue);
}

#endif
