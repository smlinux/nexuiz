#ifdef INTERFACE
CLASS(NexuizListBox) EXTENDS(ListBox)
	METHOD(NexuizListBox, configureNexuizListBox, void(entity))
	ATTRIB(NexuizListBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizListBox, scrollbarWidth, float, SKINWIDTH_SCROLLBAR)
	ATTRIB(NexuizListBox, src, string, SKINGFX_SCROLLBAR)
	ATTRIB(NexuizListBox, tolerance, vector, SKINTOLERANCE_SLIDER)
	ATTRIB(NexuizListBox, rowsPerItem, float, 1)
	METHOD(NexuizListBox, resizeNotify, void(entity, vector, vector, vector, vector))
	ATTRIB(NexuizListBox, color, vector, SKINCOLOR_SCROLLBAR_N)
	ATTRIB(NexuizListBox, colorF, vector, SKINCOLOR_SCROLLBAR_F)
	ATTRIB(NexuizListBox, color2, vector, SKINCOLOR_SCROLLBAR_S)
	ATTRIB(NexuizListBox, colorC, vector, SKINCOLOR_SCROLLBAR_C)
	ATTRIB(NexuizListBox, colorBG, vector, SKINCOLOR_LISTBOX_BACKGROUND)
	ATTRIB(NexuizListBox, alphaBG, float, SKINALPHA_LISTBOX_BACKGROUND)
ENDCLASS(NexuizListBox)
entity makeNexuizListBox();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizListBox()
{
	entity me;
	me = spawnNexuizListBox();
	me.configureNexuizListBox(me);
	return me;
}
void configureNexuizListBoxNexuizListBox(entity me)
{
	me.configureListBox(me, me.scrollbarWidth, 1); // item height gets set up later
}
void resizeNotifyNexuizListBox(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.itemHeight = me.rowsPerItem * me.fontSize / absSize_y;
	resizeNotifyListBox(me, relOrigin, relSize, absOrigin, absSize);
}
#endif
