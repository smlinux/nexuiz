#ifdef INTERFACE
CLASS(Image) EXTENDS(Item)
	METHOD(Image, configureImage, void(entity, string))
	METHOD(Image, draw, void(entity))
	METHOD(Image, toString, string(entity))
	METHOD(Image, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(Image, src, string, string_null)
	ATTRIB(Image, color, vector, '1 1 1')
	ATTRIB(Image, forcedAspect, float, 0)
	ATTRIB(Image, imgOrigin, vector, '0 0 0')
	ATTRIB(Image, imgSize, vector, '0 0 0')
ENDCLASS(Image)
#endif

#ifdef IMPLEMENTATION
string toStringImage(entity me)
{
	return me.src;
}
void configureImageImage(entity me, string path)
{
	me.src = path;
}
void drawImage(entity me)
{
	draw_Picture(me.imgOrigin, me.src, me.imgSize, me.color, 1);
}
void resizeNotifyImage(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyItem(me, relOrigin, relSize, absOrigin, absSize);
	if(me.forcedAspect == 0)
	{
		me.imgOrigin = '0 0 0';
		me.imgSize = '1 1 0';
	}
	else
	{
		if(absSize_x > me.forcedAspect * absSize_y)
		{
			// x too large, so center x-wise
			me.imgSize = eY + eX * (absSize_y * me.forcedAspect / absSize_x);
		}
		else
		{
			// y too large, so center y-wise
			me.imgSize = eX + eY * (absSize_x / (me.forcedAspect * absSize_y));
		}
		me.imgOrigin = '0.5 0.5 0' - 0.5 * me.imgSize;
	}
}
#endif
