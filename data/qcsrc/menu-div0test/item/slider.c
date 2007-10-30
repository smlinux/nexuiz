#ifdef INTERFACE
CLASS(Slider) EXTENDS(Label)
	METHOD(Slider, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Slider, configureSliderVisuals, void(entity, float, float, string))
	METHOD(Slider, configureSliderValues, void(entity, float, float, float, float, float, float))
	METHOD(Slider, draw, void(entity))
	METHOD(Slider, keyDown, float(entity, float, float, float))
	METHOD(Slider, mousePress, float(entity, vector))
	METHOD(Slider, mouseDrag, float(entity, vector))
	METHOD(Slider, mouseRelease, float(entity, vector))
	METHOD(Slider, valueToText, string(entity, float))
	METHOD(Slider, toString, string(entity))
	ATTRIB(Slider, src, string, "")
	ATTRIB(Slider, focusable, float, 1)
	ATTRIB(Slider, value, float, 0)
	ATTRIB(Slider, valueMin, float, 0)
	ATTRIB(Slider, valueMax, float, 0)
	ATTRIB(Slider, valueStep, float, 0)
	ATTRIB(Slider, valueKeyStep, float, 0)
	ATTRIB(Slider, valuePageStep, float, 0)
	ATTRIB(Slider, valueSpace, float, 0)
	ATTRIB(Slider, controlWidth, float, 0)
	ATTRIB(Slider, pressed, float, 0)
	ATTRIB(Slider, pressOffset, float, 0)
	ATTRIB(Slider, previousValue, float, 0)
ENDCLASS(Slider)
#endif

#ifdef IMPLEMENTATION
string toStringSlider(entity me)
{
	return strcat(ftos(me.value), " (", me.valueToText(me, me.value), ")");
}
void resizeNotifySlider(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyLabel(me, relOrigin, relSize, absOrigin, absSize);
	me.controlWidth = absSize_y / absSize_x;
}
string valueToTextSlider(entity me, float val)
{
	return ftos(val);
}
void configureSliderVisualsSlider(entity me, float sz, float theValueSpace, string gfx)
{
	configureLabelLabel(me, "", sz, 1);
	me.valueSpace = theValueSpace;
	me.src = gfx;
}
void configureSliderValuesSlider(entity me, float theValueMin, float theValue, float theValueMax, float theValueStep, float theValueKeyStep, float theValuePageStep)
{
	me.value = theValue;
	me.valueStep = theValueStep;
	me.valueMin = theValueMin;
	me.valueMax = theValueMax;
	me.valueKeyStep = theValueKeyStep;
	me.valuePageStep = theValuePageStep;
}
float keyDownSlider(entity me, float key, float ascii, float shift)
{
	if(key == K_LEFTARROW)
	{
		me.value = bound(me.valueMin, me.value - me.valueKeyStep, me.valueMax);
		return 1;
	}
	if(key == K_RIGHTARROW)
	{
		me.value = bound(me.valueMin, me.value + me.valueKeyStep, me.valueMax);
		return 1;
	}
	if(key == K_PGUP)
	{
		me.value = bound(me.valueMin, me.value - me.valuePageStep, me.valueMax);
		return 1;
	}
	if(key == K_PGDN)
	{
		me.value = bound(me.valueMin, me.value + me.valuePageStep, me.valueMax);
		return 1;
	}
	// TODO more keys
	return 0;
}
float mouseDragSlider(entity me, vector pos)
{
	float hit;
	if(me.pressed)
	{
		hit = 1;
		if(pos_x < 0) hit = 0;
		if(pos_y < 0) hit = 0;
		if(pos_x >= 1 - me.valueSpace) hit = 0;
		if(pos_y >= 1) hit = 0;
		if(hit)
		{
			me.value = bound(0, (pos_x - me.pressOffset - 0.5 * me.controlWidth) / (1 - me.valueSpace - me.controlWidth), 1) * (me.valueMax - me.valueMin) + me.valueMin;
			if(me.valueStep)
				me.value = floor(0.5 + me.value / me.valueStep) * me.valueStep;
		}
		else
			me.value = me.previousValue;
	}
	return 1;
}
float mousePressSlider(entity me, vector pos)
{
	float controlCenter;
	if(pos_x < 0) return 0;
	if(pos_y < 0) return 0;
	if(pos_x >= 1 - me.valueSpace) return 0;
	if(pos_y < 0) return 0;
	controlCenter = (me.value - me.valueMin) / (me.valueMax - me.valueMin) * (1 - me.valueSpace - me.controlWidth) + 0.5 * me.controlWidth;
	if(fabs(pos_x - controlCenter) <= 0.5 * me.controlWidth)
	{
		me.pressed = 1;
		me.pressOffset = pos_x - controlCenter;
		me.previousValue = me.value;
		me.mouseDrag(me, pos);
	}
	else
	{
		if(pos_x < controlCenter)
			me.keyDown(me, K_PGUP, 0, 0);
		else
			me.keyDown(me, K_PGDN, 0, 0);
	}
	return 1;
}
float mouseReleaseSlider(entity me, vector pos)
{
	me.pressed = 0;
	return 1;
}
void drawSlider(entity me)
{
	float controlLeft;
	draw_ButtonPicture('0 0 0', strcat(me.src, "_s"), eX * (1 - me.valueSpace) + eY, '1 1 1', 1);
	if(me.value >= me.valueMin && me.value <= me.valueMax)
	{
		controlLeft = (me.value - me.valueMin) / (me.valueMax - me.valueMin) * (1 - me.valueSpace - me.controlWidth);
		if(me.pressed)
			draw_Picture(eX * controlLeft, strcat(me.src, "_c"), eX * me.controlWidth + eY, '1 1 1', 1);
		else if(me.focused)
			draw_Picture(eX * controlLeft, strcat(me.src, "_f"), eX * me.controlWidth + eY, '1 1 1', 1);
		else
			draw_Picture(eX * controlLeft, strcat(me.src, "_n"), eX * me.controlWidth + eY, '1 1 1', 1);
	}
	me.setText(me, me.valueToText(me, me.value));
	drawLabel(me);
	me.text = ""; // TEMPSTRING!
}
#endif
