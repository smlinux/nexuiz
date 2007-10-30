#ifdef INTERFACE
CLASS(NexuizTextLabel) EXTENDS(Label)
	METHOD(NexuizTextLabel, configureNexuizTextLabel, void(entity, float, string))
	ATTRIB(NexuizTextLabel, fontSize, float, SKINFONTSIZE_NORMAL)
ENDCLASS(NexuizTextLabel)
entity makeNexuizTextLabel(float theAlign, string theText);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizTextLabel(float theAlign, string theText)
{
	entity me;
	me = spawnNexuizTextLabel();
	me.configureNexuizTextLabel(me, theAlign, theText);
	return me;
}
void configureNexuizTextLabelNexuizTextLabel(entity me, float theAlign, string theText)
{
	me.configureLabel(me, theText, me.fontSize, theAlign);
}
#endif
