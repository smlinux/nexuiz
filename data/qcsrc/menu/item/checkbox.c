#ifdef INTERFACE
void CheckBox_Click(entity me, entity other);
CLASS(CheckBox) EXTENDS(Button)
	METHOD(CheckBox, configureCheckBox, void(entity, string, float, string))
	METHOD(CheckBox, draw, void(entity))
	METHOD(CheckBox, toString, string(entity))
	METHOD(CheckBox, setChecked, void(entity, float))
	ATTRIB(CheckBox, useDownAsChecked, float, 0)
	ATTRIB(CheckBox, checked, float, 0)
	ATTRIB(CheckBox, onClick, void(entity, entity), CheckBox_Click)
	ATTRIB(CheckBox, srcMulti, float, 0)
	ATTRIB(CheckBox, disabled, float, 0)
ENDCLASS(CheckBox)
#endif

#ifdef IMPLEMENTATION
void setCheckedCheckBox(entity me, float val)
{
	me.checked = val;
}
void CheckBox_Click(entity me, entity other)
{
	me.setChecked(me, !me.checked);
}
string toStringCheckBox(entity me)
{
	return strcat(toStringLabel(me), ", ", me.checked ? "checked" : "unchecked");
}
void configureCheckBoxCheckBox(entity me, string txt, float sz, string gfx)
{
	me.configureButton(me, txt, sz, gfx);
	me.align = 0;
}
void drawCheckBox(entity me)
{
	float s;
	s = me.pressed;
	if(me.useDownAsChecked)
	{
		me.srcSuffix = string_null;
		me.forcePressed = me.checked;
	}
	else
		me.srcSuffix = (me.checked ? "1" : "0");
	drawButton(me);
	me.pressed = s;
}
#endif
