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
	ATTRIB(BorderImage, realFontSize_Nexposeed, vector, '0 0 0')
	ATTRIB(BorderImage, realOrigin_Nexposeed, vector, '0 0 0')
	ATTRIB(BorderImage, isNexposeeTitleBar, float, 0)
	ATTRIB(BorderImage, zoomedOutTitleBarPosition, float, 0)
	ATTRIB(BorderImage, zoomedOutTitleBar, float, 0)
	ATTRIB(BorderImage, borderLines, float, 1)
ENDCLASS(BorderImage)
#endif

#ifdef IMPLEMENTATION
void resizeNotifyBorderImage(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.isNexposeeTitleBar = 0;
	if(me.zoomedOutTitleBar)
		if(me.parent.parent.instanceOfNexposee)
			if(me.parent.instanceOfDialog)
				if(me == me.parent.frame)
					me.isNexposeeTitleBar = 1;
	if(me.isNexposeeTitleBar)
	{
		vector scrs;
		scrs = eX * conwidth + eY * conheight;
		resizeNotifyLabel(me, relOrigin, relSize, boxToGlobal(me.parent.Nexposee_smallOrigin, '0 0 0', scrs), boxToGlobalSize(me.parent.Nexposee_smallSize, scrs));
		me.realOrigin_y = me.realFontSize_y * me.zoomedOutTitleBarPosition;
		me.realOrigin_Nexposeed = me.realOrigin;
		me.realFontSize_Nexposeed = me.realFontSize;
	}
	resizeNotifyLabel(me, relOrigin, relSize, absOrigin, absSize);
	me.borderVec = me.borderHeight / absSize_y * (eY + eX * (absSize_y / absSize_x));
	me.realOrigin_y = 0.5 * (me.borderVec_y - me.realFontSize_y);
	if(me.closeButton)
	{
		// move the close button to the right place
		me.closeButton.Container_origin = '1 0 0' * (1 - me.borderVec_x);
		me.closeButton.Container_size = me.borderVec;
		me.closeButton.color = me.color;
		me.closeButton.colorC = me.color;
		me.closeButton.colorF = me.color;
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
		draw_BorderPicture('0 0 0', me.src, '1 1 0', me.color, 1, me.borderLines * me.borderVec);
	if(me.fontSize > 0)
	{
		vector ro, rf, df;
		if(me.isNexposeeTitleBar)
		{
			// me.parent.Nexposee_animationFactor 0 (small) or 1 (full)
			// default values are for 1
			ro = me.realOrigin;
			rf = me.realFontSize;
			df = draw_fontscale;
			me.realOrigin = ro * me.parent.Nexposee_animationFactor + me.realOrigin_Nexposeed * (1 - me.parent.Nexposee_animationFactor);
			me.realFontSize = rf * me.parent.Nexposee_animationFactor + me.realFontSize_Nexposeed * (1 - me.parent.Nexposee_animationFactor);
			draw_fontscale = globalToBoxSize(boxToGlobalSize(df, me.realFontSize), rf);
		}

		drawLabel(me);

		if(me.isNexposeeTitleBar)
		{
			// me.Nexposee_animationState 0 (small) or 1 (full)
			// default values are for 1
			me.realOrigin = ro;
			me.realFontSize = rf;
			draw_fontscale = df;
		}
	}
};
#endif
