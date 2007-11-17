#ifdef INTERFACE
CLASS(NexuizImage) EXTENDS(Image)
	METHOD(NexuizImage, configureNexuizImage, void(entity, string, float))
ENDCLASS(NexuizImage)
entity makeNexuizImage(string theImage, float theAspect);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizImage(string theImage, float theAspect)
{
	entity me;
	me = spawnNexuizImage();
	me.configureNexuizImage(me, theImage, theAspect);
	return me;
}
void configureNexuizImageNexuizImage(entity me, string theImage, float theAspect)
{
	me.configureImage(me, theImage);
	me.forcedAspect = theAspect;
}
#endif
