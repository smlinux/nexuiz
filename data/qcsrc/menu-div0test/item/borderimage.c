#ifdef INTERFACE
CLASS(BorderImage) EXTENDS(Label)
	METHOD(BorderImage, configureBorderImage, void(entity, string, float, vector, string, float))
	METHOD(BorderImage, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(BorderImage, draw, void(entity))
	ATTRIB(BorderImage, src, string, string_null)
	ATTRIB(BorderImage, borderHeight, float, 0)
	ATTRIB(BorderImage, borderVec, vector, '0 0 0')
	ATTRIB(BorderImage, color, vector, '1 1 1')
	ATTRIB(BorderImage, closeButton, entity, NULL)
ENDCLASS(BorderImage)
#endif

#ifdef IMPLEMENTATION
void resizeNotifyBorderImage(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyLabel(me, relOrigin, relSize, absOrigin, absSize);
	me.borderVec = me.borderHeight / absSize_y * (eY + eX * (absSize_y / absSize_x));
	me.realOrigin_y = 0.5 * (me.borderVec_y - me.realFontSize_y);
	if(me.closeButton)
	{
		// move the close button to the right place
		me.closeButton.Container_origin = '1 0 0' * (1 - me.borderVec_x);
		me.closeButton.Container_size = me.borderVec;
		me.closeButton.color = me.color;
	}
}
void configureBorderImageBorderImage(entity me, string theTitle, float sz, vector theColor, string path, float theBorderHeight)
{
	me.configureLabel(me, theTitle, sz, 0.5);
	me.src = path;
	me.color = theColor;
	me.borderHeight = theBorderHeight;
}
void drawBorderImage(entity me)
{
	//print(vtos(me.borderVec), "\n");
	if(me.src)
		draw_BorderPicture('0 0 0', me.src, '1 1 0', me.color, 1, me.borderVec);
	if(me.fontSize > 0)
		drawLabel(me);
};
#endif
