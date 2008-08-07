#ifdef INTERFACE
CLASS(Label) EXTENDS(Item)
	METHOD(Label, configureLabel, void(entity, string, float, float))
	METHOD(Label, draw, void(entity))
	METHOD(Label, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(Label, setText, void(entity, string))
	METHOD(Label, toString, string(entity))
	ATTRIB(Label, text, string, string_null)
	ATTRIB(Label, fontSize, float, 8)
	ATTRIB(Label, align, float, 0.5)
	ATTRIB(Label, allowCut, float, 0)
	ATTRIB(Label, keepspaceLeft, float, 0) // for use by subclasses (radiobuttons for example)
	ATTRIB(Label, keepspaceRight, float, 0)
	ATTRIB(Label, marginLeft, float, 0) // alternate way to specify keepspace* (in characters from the font)
	ATTRIB(Label, marginRight, float, 0)
	ATTRIB(Label, realFontSize, vector, '0 0 0')
	ATTRIB(Label, realOrigin, vector, '0 0 0')
	ATTRIB(Label, alpha, float, 0.7)
	ATTRIB(Label, colorL, vector, '1 1 1')
	ATTRIB(Label, disabled, float, 0)
	ATTRIB(Label, disabledAlpha, float, 0.3)
	ATTRIB(Label, textEntity, entity, NULL)
ENDCLASS(Label)
#endif

#ifdef IMPLEMENTATION
string toStringLabel(entity me)
{
	return me.text;
}
void setTextLabel(entity me, string txt)
{
	me.text = txt;
	me.realOrigin_x = me.align * (1 - me.keepspaceLeft - me.keepspaceRight - min(me.realFontSize_x * draw_TextWidth(me.text, 0), (1 - me.keepspaceLeft - me.keepspaceRight))) + me.keepspaceLeft;
}
void resizeNotifyLabel(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	// absSize_y is height of label
	me.realFontSize_y = me.fontSize / absSize_y;
	me.realFontSize_x = me.fontSize / absSize_x;
	if(me.marginLeft)
		me.keepspaceLeft = me.marginLeft * me.realFontSize_x;
	if(me.marginRight)
		me.keepspaceRight = me.marginRight * me.realFontSize_x;
	me.realOrigin_x = me.align * (1 - me.keepspaceLeft - me.keepspaceRight - min(me.realFontSize_x * draw_TextWidth(me.text, 0), (1 - me.keepspaceLeft - me.keepspaceRight))) + me.keepspaceLeft;
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
	string t;
	if(me.disabled)
		draw_alpha *= me.disabledAlpha;

	if(me.textEntity)
	{
		t = me.textEntity.toString(me.textEntity);
		me.realOrigin_x = me.align * (1 - me.keepspaceLeft - me.keepspaceRight - min(me.realFontSize_x * draw_TextWidth(t, 0), (1 - me.keepspaceLeft - me.keepspaceRight))) + me.keepspaceLeft;
	}
	else
		t = me.text;
	
	if(me.fontSize)
		if(t)
		{
			if(me.allowCut)
				draw_Text(me.realOrigin, draw_TextShortenToWidth(t, (1 - me.keepspaceLeft - me.keepspaceRight) / me.realFontSize_x, 0), me.realFontSize, me.colorL, me.alpha, 0);
			else
				draw_Text(me.realOrigin, t, me.realFontSize, me.colorL, me.alpha, 0);
		}
}
#endif
