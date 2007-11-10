#ifdef INTERFACE
CLASS(Image) EXTENDS(Item)
	METHOD(Image, configureImage, void(entity, string))
	METHOD(Image, draw, void(entity))
	METHOD(Image, toString, string(entity))
	ATTRIB(Image, src, string, string_null)
	ATTRIB(Image, color, vector, '1 1 1')
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
	draw_Picture('0 0 0', me.src, '1 1 0', me.color, 1);
};
#endif
