#ifdef INTERFACE
CLASS(NexuizTabController) EXTENDS(ModalController)
	METHOD(NexuizTabController, configureNexuizTabController, void(entity, float))
	METHOD(NexuizTabController, makeTabButton, entity(entity, string, entity))
	ATTRIB(NexuizTabController, rows, float, 0)
	ATTRIB(NexuizTabController, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizTabController, image, string, SKINGFX_BUTTON)
ENDCLASS(NexuizTabController)
entity makeNexuizTabController(float theRows);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizTabController(float theRows)
{
	entity me;
	me = spawnNexuizTabController();
	me.configureNexuizTabController(me, theRows);
	return me;
}
void configureNexuizTabControllerNexuizTabController(entity me, float theRows)
{
	me.rows = theRows;
}
entity makeTabButtonNexuizTabController(entity me, string theTitle, entity tab)
{
	entity b;
	if(me.rows != tab.rows)
		error("Tab dialog height mismatch!");
	b = makeNexuizButton(theTitle, '0 0 0');
		me.addTab(me, tab, b);
	// TODO make this real tab buttons (with color parameters, and different gfx)
	return b;
}
#endif
