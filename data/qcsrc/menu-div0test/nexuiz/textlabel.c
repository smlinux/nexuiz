#ifdef INTERFACE
CLASS(NexuizTextLabel) EXTENDS(Label)
	METHOD(NexuizTextLabel, configureNexuizTextLabel, void(entity, float, string))
	METHOD(NexuizTextLabel, draw, void(entity))
	ATTRIB(NexuizTextLabel, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizTextLabel, disabled, float, 0)
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
void drawNexuizTextLabel(entity me)
{
	if(me.disabled)
		draw_alpha *= 0.5;
	drawLabel(me);
}
#endif
