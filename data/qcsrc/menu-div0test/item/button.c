#ifdef INTERFACE
CLASS(Button) EXTENDS(Label)
	METHOD(Button, configureButton, void(entity, string, float, string))
	METHOD(Button, draw, void(entity))
	METHOD(Button, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Button, keyDown, float(entity, float, float, float))
	METHOD(Button, mousePress, float(entity, vector))
	METHOD(Button, mouseDrag, float(entity, vector))
	METHOD(Button, mouseRelease, float(entity, vector))
	ATTRIB(Button, onClick, void(entity, entity), SUB_Null)
	ATTRIB(Button, onClickEntity, entity, NULL)
	ATTRIB(Button, src, string, "")
	ATTRIB(Button, srcMulti, float, 1)
	ATTRIB(Button, focusable, float, 1)
	ATTRIB(Button, pressed, float, 0)
	ATTRIB(Button, clickTime, float, 0)
	ATTRIB(Button, forcePressed, float, 0)
	ATTRIB(Button, color, vector, '1 1 1')

	ATTRIB(Button, origin, vector, '0 0 0')
	ATTRIB(Button, size, vector, '0 0 0')
ENDCLASS(Button)
#endif

#ifdef IMPLEMENTATION
void resizeNotifyButton(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyLabel(me, relOrigin, relSize, absOrigin, absSize);
	me.origin = absOrigin;
	me.size = absSize;
}
void configureButtonButton(entity me, string txt, float sz, string gfx)
{
	configureLabelLabel(me, txt, sz, 0.5);
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
		me.onClick(me, me.onClickEntity);
		me.pressed = 0;
	}
	return 1;
}
void drawButton(entity me)
{
	if(me.srcMulti)
	{
		if(me.forcePressed || me.pressed || me.clickTime > 0)
			draw_ButtonPicture('0 0 0', strcat(me.src, "_c"), '1 1 0', me.color, 1);
		else if(me.focused)
			draw_ButtonPicture('0 0 0', strcat(me.src, "_f"), '1 1 0', me.color, 1);
		else
			draw_ButtonPicture('0 0 0', strcat(me.src, "_n"), '1 1 0', me.color, 1);
	}
	else
	{
		if(me.forcePressed || me.pressed || me.clickTime > 0)
			draw_Picture('0 0 0', strcat(me.src, "_c"), '1 1 0', me.color, 1);
		else if(me.focused)
			draw_Picture('0 0 0', strcat(me.src, "_f"), '1 1 0', me.color, 1);
		else
			draw_Picture('0 0 0', strcat(me.src, "_n"), '1 1 0', me.color, 1);
	}
	drawLabel(me);

	if(me.clickTime > 0 && me.clickTime < frametime)
	{
		// keyboard click timer expired? Fire the event then.
		me.onClick(me, me.onClickEntity);
	}
	me.clickTime -= frametime;
}
#endif
