#ifdef INTERFACE
CLASS(Image) EXTENDS(Item)
	METHOD(Image, configureImage, void(entity, string))
	METHOD(Image, draw, void(entity))
	ATTRIB(Image, src, string, "")
ENDCLASS(Image)
#endif

#ifdef IMPLEMENTATION
void configureImageImage(entity me, string path)
{
	me.src = path;
}
void drawImage(entity me)
{
	draw_Picture('0 0 0', me.src, '1 1 0', '1 1 1', 1);
};
#endif
