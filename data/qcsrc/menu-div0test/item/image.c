#ifdef INTERFACE
CLASS(Image) EXTENDS(Item)
	METHOD(Image, configureImage, void(entity, string))
	METHOD(Image, draw, void(entity))
	METHOD(Image, toString, string(entity))
	ATTRIB(Image, src, string, string_null)
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
	draw_Picture('0 0 0', me.src, '1 1 0', '1 1 1', 1);
};
#endif
