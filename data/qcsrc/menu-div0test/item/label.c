#ifdef INTERFACE
CLASS(Label) EXTENDS(Item)
	METHOD(Label, configureLabel, void(entity, string, float, float))
	METHOD(Label, draw, void(entity))
	METHOD(Label, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Label, setText, void(entity, string))
	ATTRIB(Label, text, string, "Big Red Button")
	ATTRIB(Label, fontSize, float, 8)
	ATTRIB(Label, align, float, 0.5)
	ATTRIB(Label, keepspaceLeft, float, 0) // for use by subclasses (radiobuttons for example)
	ATTRIB(Label, keepspaceRight, float, 0)
	ATTRIB(Label, realFontSize, vector, '0 0 0')
	ATTRIB(Label, realOrigin, vector, '0 0 0')
ENDCLASS(Label)
#endif

#ifdef IMPLEMENTATION
void setTextLabel(entity me, string txt)
{
	me.text = txt;
	me.realOrigin_x = me.align * (1 - me.realFontSize_x * draw_TextWidth(me.text));
}
void resizeNotifyLabel(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	// absSize_y is height of label
	me.realFontSize_y = me.fontSize / absSize_y;
	me.realFontSize_x = me.fontSize / absSize_x;
	me.realOrigin_x = me.align * (1 - me.keepspaceLeft - me.keepspaceRight - me.realFontSize_x * draw_TextWidth(me.text)) + me.keepspaceLeft;
	me.realOrigin_y = 0.5 * (1 - me.realFontSize_y);
}
void configureLabelLabel(entity me, string txt, float sz, float algn)
{
	me.fontSize = sz;
	me.align = algn;
	me.setText(me, txt);
}
void drawLabel(entity me)
{
	draw_Text(me.realOrigin, me.text, me.realFontSize, '0 0 0', 1);
}
#endif
