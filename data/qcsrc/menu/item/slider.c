// Note:
//   to use this, you FIRST call configureSliderVisuals, then configureSliderValues
#ifdef INTERFACE
CLASS(Slider) EXTENDS(Label)
	METHOD(Slider, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Slider, configureSliderVisuals, void(entity, float, float, float, string))
	METHOD(Slider, configureSliderValues, void(entity, float, float, float, float, float, float))
	METHOD(Slider, draw, void(entity))
	METHOD(Slider, keyDown, float(entity, float, float, float))
	METHOD(Slider, mousePress, float(entity, vector))
	METHOD(Slider, mouseDrag, float(entity, vector))
	METHOD(Slider, mouseRelease, float(entity, vector))
	METHOD(Slider, valueToText, string(entity, float))
	METHOD(Slider, toString, string(entity))
	METHOD(Slider, setValue, void(entity, float))
	METHOD(Slider, showNotify, void(entity))
	ATTRIB(Slider, src, string, string_null)
	ATTRIB(Slider, focusable, float, 1)
	ATTRIB(Slider, value, float, 0)
	ATTRIB(Slider, valueMin, float, 0)
	ATTRIB(Slider, valueMax, float, 0)
	ATTRIB(Slider, valueStep, float, 0)
	ATTRIB(Slider, valueDigits, float, 0)
	ATTRIB(Slider, valueKeyStep, float, 0)
	ATTRIB(Slider, valuePageStep, float, 0)
	ATTRIB(Slider, valueDisplayMultiplier, float, 1.0)
	ATTRIB(Slider, textSpace, float, 0)
	ATTRIB(Slider, controlWidth, float, 0)
	ATTRIB(Slider, pressed, float, 0)
	ATTRIB(Slider, pressOffset, float, 0)
	ATTRIB(Slider, previousValue, float, 0)
	ATTRIB(Slider, tolerance, vector, '0 0 0')
	ATTRIB(Slider, disabled, float, 0)
	ATTRIB(Slider, color, vector, '1 1 1')
	ATTRIB(Slider, color2, vector, '1 1 1')
	ATTRIB(Slider, colorD, vector, '1 1 1')
	ATTRIB(Slider, colorC, vector, '1 1 1')
	ATTRIB(Slider, colorF, vector, '1 1 1')
	ATTRIB(Slider, disabledAlpha, float, 0.3)
ENDCLASS(Slider)
#endif

#ifdef IMPLEMENTATION
void setValueSlider(entity me, float val)
{
	me.value = val;
}
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
	if(almost_in_bounds(me.valueMin, val, me.valueMax))
		return ftos_decimals(val * me.valueDisplayMultiplier, me.valueDigits);
	return "";
}
void configureSliderVisualsSlider(entity me, float sz, float theAlign, float theTextSpace, string gfx)
{
	configureLabelLabel(me, string_null, sz, theAlign);
	me.textSpace = theTextSpace;
	me.keepspaceLeft = (theTextSpace == 0) ? 0 : (1 - theTextSpace);
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
	me.valueDigits = 3;
	if(fabs(floor(me.valueStep * 100 + 0.5) - (me.valueStep * 100)) < 0.01) // about a whole number of 100ths
		me.valueDigits = 2;
	if(fabs(floor(me.valueStep * 10 + 0.5) - (me.valueStep * 10)) < 0.01) // about a whole number of 10ths
		me.valueDigits = 1;
	if(fabs(floor(me.valueStep * 1 + 0.5) - (me.valueStep * 1)) < 0.01) // about a whole number
		me.valueDigits = 0;
}
float keyDownSlider(entity me, float key, float ascii, float shift)
{
	float inRange;
	if(me.disabled)
		return 0;
	inRange = (almost_in_bounds(me.valueMin, me.value, me.valueMax));
	if(key == K_LEFTARROW)
	{
		if(inRange)
			me.setValue(me, median(me.valueMin, me.value - me.valueKeyStep, me.valueMax));
		else
			me.setValue(me, me.valueMax);
		return 1;
	}
	if(key == K_RIGHTARROW)
	{
		if(inRange)
			me.setValue(me, median(me.valueMin, me.value + me.valueKeyStep, me.valueMax));
		else
			me.setValue(me, me.valueMin);
		return 1;
	}
	if(key == K_PGUP)
	{
		if(inRange)
			me.setValue(me, median(me.valueMin, me.value - me.valuePageStep, me.valueMax));
		else
			me.setValue(me, me.valueMax);
		return 1;
	}
	if(key == K_PGDN)
	{
		if(inRange)
			me.setValue(me, median(me.valueMin, me.value + me.valuePageStep, me.valueMax));
		else
			me.setValue(me, me.valueMin);
		return 1;
	}
	if(key == K_HOME)
	{
		me.setValue(me, me.valueMin);
		return 1;
	}
	if(key == K_END)
	{
		me.setValue(me, me.valueMax);
		return 1;
	}
	// TODO more keys
	return 0;
}
float mouseDragSlider(entity me, vector pos)
{
	float hit;
	float v;
	if(me.disabled)
		return 0;
	if(me.pressed)
	{
		hit = 1;
		if(pos_x < 0 - me.tolerance_x) hit = 0;
		if(pos_y < 0 - me.tolerance_y) hit = 0;
		if(pos_x >= 1 - me.textSpace + me.tolerance_x) hit = 0;
		if(pos_y >= 1 + me.tolerance_y) hit = 0;
		if(hit)
		{
			v = median(0, (pos_x - me.pressOffset - 0.5 * me.controlWidth) / (1 - me.textSpace - me.controlWidth), 1) * (me.valueMax - me.valueMin) + me.valueMin;
			if(me.valueStep)
				v = floor(0.5 + v / me.valueStep) * me.valueStep;
			me.setValue(me, v);
		}
		else
			me.setValue(me, me.previousValue);
	}
	return 1;
}
float mousePressSlider(entity me, vector pos)
{
	float controlCenter;
	if(me.disabled)
		return 0;
	if(pos_x < 0) return 0;
	if(pos_y < 0) return 0;
	if(pos_x >= 1 - me.textSpace) return 0;
	if(pos_y >= 1) return 0;
	controlCenter = (me.value - me.valueMin) / (me.valueMax - me.valueMin) * (1 - me.textSpace - me.controlWidth) + 0.5 * me.controlWidth;
	if(fabs(pos_x - controlCenter) <= 0.5 * me.controlWidth)
	{
		me.pressed = 1;
		me.pressOffset = pos_x - controlCenter;
		me.previousValue = me.value;
		//me.mouseDrag(me, pos);
	}
	else
	{
		float clickValue, pageValue, inRange;
		clickValue = median(0, (pos_x - me.pressOffset - 0.5 * me.controlWidth) / (1 - me.textSpace - me.controlWidth), 1) * (me.valueMax - me.valueMin) + me.valueMin;
		inRange = (almost_in_bounds(me.valueMin, me.value, me.valueMax));
		if(pos_x < controlCenter)
		{
			pageValue = me.value - me.valuePageStep;
			if(me.valueStep)
				clickValue = floor(clickValue / me.valueStep) * me.valueStep;
			pageValue = max(pageValue, clickValue);
			if(inRange)
				me.setValue(me, median(me.valueMin, pageValue, me.valueMax));
			else
				me.setValue(me, me.valueMax);
		}
		else
		{
			pageValue = me.value + me.valuePageStep;
			if(me.valueStep)
				clickValue = ceil(clickValue / me.valueStep) * me.valueStep;
			pageValue = min(pageValue, clickValue);
			if(inRange)
				me.setValue(me, median(me.valueMin, pageValue, me.valueMax));
			else
				me.setValue(me, me.valueMax);
		}
		if(pageValue == clickValue)
		{
			controlCenter = (me.value - me.valueMin) / (me.valueMax - me.valueMin) * (1 - me.textSpace - me.controlWidth) + 0.5 * me.controlWidth;
			me.pressed = 1;
			me.pressOffset = pos_x - controlCenter;
			me.previousValue = me.value;
			//me.mouseDrag(me, pos);
		}
	}
	if(cvar("menu_sounds"))
		localsound("sound/misc/menu2.wav");
	return 1;
}
float mouseReleaseSlider(entity me, vector pos)
{
	me.pressed = 0;
	if(me.disabled)
		return 0;
	return 1;
}
void showNotifySlider(entity me)
{
	me.focusable = !me.disabled;
}
void drawSlider(entity me)
{
	float controlLeft;
	float save;
	me.focusable = !me.disabled;
	save = draw_alpha;
	if(me.disabled)
		draw_alpha *= me.disabledAlpha;
	draw_ButtonPicture('0 0 0', strcat(me.src, "_s"), eX * (1 - me.textSpace) + eY, me.color2, 1);
	if(almost_in_bounds(me.valueMin, me.value, me.valueMax))
	{
		controlLeft = (me.value - me.valueMin) / (me.valueMax - me.valueMin) * (1 - me.textSpace - me.controlWidth);
		if(me.disabled)
			draw_Picture(eX * controlLeft, strcat(me.src, "_d"), eX * me.controlWidth + eY, me.colorD, 1);
		else if(me.pressed)
			draw_Picture(eX * controlLeft, strcat(me.src, "_c"), eX * me.controlWidth + eY, me.colorC, 1);
		else if(me.focused)
			draw_Picture(eX * controlLeft, strcat(me.src, "_f"), eX * me.controlWidth + eY, me.colorF, 1);
		else
			draw_Picture(eX * controlLeft, strcat(me.src, "_n"), eX * me.controlWidth + eY, me.color, 1);
	}
	me.setText(me, me.valueToText(me, me.value));
	draw_alpha = save;
	drawLabel(me);
	me.text = string_null; // TEMPSTRING!
}
#endif