#ifdef INTERFACE
CLASS(Button) EXTENDS(Label)
	METHOD(Button, configureButton, void(entity, string, float, string))
	METHOD(Button, draw, void(entity))
	METHOD(Button, showNotify, void(entity))
	METHOD(Button, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Button, keyDown, float(entity, float, float, float))
	METHOD(Button, mousePress, float(entity, vector))
	METHOD(Button, mouseDrag, float(entity, vector))
	METHOD(Button, mouseRelease, float(entity, vector))
	ATTRIB(Button, onClick, void(entity, entity), SUB_Null)
	ATTRIB(Button, onClickEntity, entity, NULL)
	ATTRIB(Button, src, string, string_null)
	ATTRIB(Button, srcSuffix, string, string_null)
	ATTRIB(Button, src2, string, string_null) // is centered, same aspect, and stretched to label size
	ATTRIB(Button, srcMulti, float, 1) // 0: button square left, text right; 1: button stretched, text over it
	ATTRIB(Button, buttonLeftOfText, float, 0)
	ATTRIB(Button, focusable, float, 1)
	ATTRIB(Button, pressed, float, 0)
	ATTRIB(Button, clickTime, float, 0)
	ATTRIB(Button, disabled, float, 0)
	ATTRIB(Button, forcePressed, float, 0)
	ATTRIB(Button, color, vector, '1 1 1')

	ATTRIB(Button, origin, vector, '0 0 0')
	ATTRIB(Button, size, vector, '0 0 0')
ENDCLASS(Button)
#endif

#ifdef IMPLEMENTATION
void resizeNotifyButton(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	if(me.srcMulti)
		me.keepspaceLeft = 0;
	else
		me.keepspaceLeft = min(0.8, absSize_y / absSize_x);
	resizeNotifyLabel(me, relOrigin, relSize, absOrigin, absSize);
	me.origin = absOrigin;
	me.size = absSize;
}
void configureButtonButton(entity me, string txt, float sz, string gfx)
{
	configureLabelLabel(me, txt, sz, me.srcMulti ? 0.5 : 0);
	me.src = gfx;
}
float keyDownButton(entity me, float key, float ascii, float shift)
{
	if(key == K_ENTER || key == K_SPACE)
	{
		me.clickTime = 0.1; // delayed for effect
		return 1;
	}
	return 0;
}
float mouseDragButton(entity me, vector pos)
{
	me.pressed = 1;
	if(pos_x < 0) me.pressed = 0;
	if(pos_y < 0) me.pressed = 0;
	if(pos_x >= 1) me.pressed = 0;
	if(pos_y >= 1) me.pressed = 0;
	return 1;
}
float mousePressButton(entity me, vector pos)
{
	me.mouseDrag(me, pos); // verify coordinates
	return 1;
}
float mouseReleaseButton(entity me, vector pos)
{
	me.mouseDrag(me, pos); // verify coordinates
	if(me.pressed)
	{
		if not(me.disabled)
			me.onClick(me, me.onClickEntity);
		me.pressed = 0;
	}
	return 1;
}
void showNotifyButton(entity me)
{
	me.focusable = !me.disabled;
}
void drawButton(entity me)
{
	vector bOrigin, bSize;

	me.focusable = !me.disabled;
	if(me.disabled)
		draw_alpha *= 0.5;

	if(me.src)
	{
		if(me.srcMulti)
		{
			bOrigin = '0 0 0';
			bSize = '1 1 0';
			if(me.disabled)
				draw_ButtonPicture(bOrigin, strcat(me.src, "_d", me.srcSuffix), bSize, '1 1 1', 1);
			else if(me.forcePressed || me.pressed || me.clickTime > 0)
				draw_ButtonPicture(bOrigin, strcat(me.src, "_c", me.srcSuffix), bSize, me.color, 1);
			else if(me.focused)
				draw_ButtonPicture(bOrigin, strcat(me.src, "_f", me.srcSuffix), bSize, me.color, 1);
			else
				draw_ButtonPicture(bOrigin, strcat(me.src, "_n", me.srcSuffix), bSize, me.color, 1);
		}
		else
		{
			if(me.realFontSize_y == 0)
			{
				bOrigin = '0 0 0';
				bSize = '1 1 0';
			}
			else
			{
				bOrigin = eY * (0.5 * (1 - me.realFontSize_y)) + eX * (0.5 * (me.keepspaceLeft - me.realFontSize_x));
				bSize = me.realFontSize;
			}
			if(me.disabled)
				draw_Picture(bOrigin, strcat(me.src, "_d", me.srcSuffix), bSize, '1 1 1', 1);
			else if(me.forcePressed || me.pressed || me.clickTime > 0)
				draw_Picture(bOrigin, strcat(me.src, "_c", me.srcSuffix), bSize, me.color, 1);
			else if(me.focused)
				draw_Picture(bOrigin, strcat(me.src, "_f", me.srcSuffix), bSize, me.color, 1);
			else
				draw_Picture(bOrigin, strcat(me.src, "_n", me.srcSuffix), bSize, me.color, 1);
		}
	}
	if(me.src2)
	{
		bOrigin = me.keepspaceLeft * eX;
		bSize = eY + eX * (1 - me.keepspaceLeft);
		draw_Picture(bOrigin, me.src2, bSize, me.color, 1);
	}
	drawLabel(me);

	if(me.clickTime > 0 && me.clickTime < frametime)
	{
		// keyboard click timer expired? Fire the event then.
		if not(me.disabled)
			me.onClick(me, me.onClickEntity);
	}
	me.clickTime -= frametime;
}
#endif
