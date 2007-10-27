#ifdef INTERFACE
void CheckBox_Click(entity me, entity other);
CLASS(CheckBox) EXTENDS(Button)
	METHOD(CheckBox, configureCheckBox, void(entity, string, float, string))
	METHOD(CheckBox, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(CheckBox, draw, void(entity))
	ATTRIB(CheckBox, checked, float, 0)
	ATTRIB(CheckBox, onClick, void(entity, entity), CheckBox_Click)
	ATTRIB(CheckBox, srcMulti, float, 0)
ENDCLASS(CheckBox)
#endif

#ifdef IMPLEMENTATION
void CheckBox_Click(entity me, entity other)
{
	me.checked = !me.checked;
}
void configureCheckBoxCheckBox(entity me, string txt, float sz, string gfx)
{
	me.configureButton(me, txt, sz, gfx);
	me.align = 0;
}
void resizeNotifyCheckBox(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.keepspaceLeft = min(0.8, absSize_y / absSize_x);
	resizeNotifyButton(me, relOrigin, relSize, absOrigin, absSize);
}
void drawCheckBox(entity me)
{
	vector cbOrigin;
	vector cbSize;

	cbOrigin = eY * (0.5 * (1 - me.realFontSize_y)) + eX * (0.5 * (me.keepspaceLeft - me.realFontSize_x));
	cbSize = me.realFontSize;
	if(me.checked)
	{
		if(me.forcePressed || me.pressed || me.clickTime > 0)
			draw_Picture(cbOrigin, strcat(me.src, "_c1"), cbSize, '1 1 1', 1);
		else if(me.focused)
			draw_Picture(cbOrigin, strcat(me.src, "_f1"), cbSize, '1 1 1', 1);
		else
			draw_Picture(cbOrigin, strcat(me.src, "_n1"), cbSize, '1 1 1', 1);
	}
	else
	{
		if(me.forcePressed || me.pressed || me.clickTime > 0)
			draw_Picture(cbOrigin, strcat(me.src, "_c0"), cbSize, '1 1 1', 1);
		else if(me.focused)
			draw_Picture(cbOrigin, strcat(me.src, "_f0"), cbSize, '1 1 1', 1);
		else
			draw_Picture(cbOrigin, strcat(me.src, "_n0"), cbSize, '1 1 1', 1);
	}
	drawLabel(me); // skip drawButton!

	if(me.clickTime > 0 && me.clickTime < frametime)
	{
		// keyboard click timer expired? Fire the event then.
		me.onClick(me, me.onClickEntity);
	}
	me.clickTime -= frametime;
}
#endif
