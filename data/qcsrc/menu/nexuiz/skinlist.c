#ifdef INTERFACE
CLASS(NexuizSkinList) EXTENDS(NexuizListBox)
	METHOD(NexuizSkinList, configureNexuizSkinList, void(entity))
	ATTRIB(NexuizSkinList, rowsPerItem, float, 4)
	METHOD(NexuizMapList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizSkinList, draw, void(entity))
	METHOD(NexuizSkinList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizSkinList, getSkins, void(entity))

	ATTRIB(NexuizSkinList, currentskin, string, "")
	ATTRIB(NexuizSkinList, skinlist, string, "")	
	ATTRIB(NexuizSkinList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizSkinList, columnPreviewOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnPreviewSize, float, 0)
	ATTRIB(NexuizSkinList, columnNameOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnNameSize, float, 0)
	ATTRIB(NexuizSkinList, checkMarkOrigin, vector, '0 0 0')
	ATTRIB(NexuizSkinList, checkMarkSize, vector, '0 0 0')
	ATTRIB(NexuizSkinList, realUpperMargin1, float, 0)	
	ATTRIB(NexuizSkinList, origin, vector, '0 0 0')
	ATTRIB(NexuizSkinList, itemAbsSize, vector, '0 0 0')
ENDCLASS(NexuizSkinList)

entity makeNexuizSkinList();
void setSkin(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION

entity makeNexuizSkinList()
{
	entity me;
	me = spawnNexuizSkinList();
	me.configureNexuizSkinList(me);
	return me;
}

void configureNexuizSkinListNexuizSkinList(entity me)
{
	me.configureNexuizListBox(me);
	me.getSkins(me);
	me.currentskin = strzone(cvar_string("menu_skin"));
}

void getSkinsNexuizSkinList(entity me)
{
	float glob,i;
	string s,_skinlist;
		
	glob = search_begin("gfx/menu/*/skinvalues.txt", TRUE, TRUE);
	if(glob < 0)
		return;	
	for (i=0 ; i < search_getsize(glob) ; ++i)
	{
		s=search_getfilename(glob, i);
		// s contain gfx/menu/skinname/skinvalues.txt
		if ( tokenizebyseparator(s, "/") == 4 )
			// add skinname to _skinlist, manage skinname with separates words
			_skinlist=strcat(_skinlist, "\"", argv(2), "\"", " ");			
	}

	me.nItems = i;
	me.skinlist = strzone(_skinlist);
		
	search_end(glob);		
}

void resizeNotifyNexuizSkinList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.itemAbsSize = '0 0 0';
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin1 = 0.5 * (1 - 2.5 * me.realFontSize_y);
	me.realUpperMargin2 = me.realUpperMargin1 + 1.5 * me.realFontSize_y;

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = me.itemAbsSize_y / me.itemAbsSize_x * 4 / 3;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - 2 * me.realFontSize_x;

	me.checkMarkSize = (eX * (me.itemAbsSize_y / me.itemAbsSize_x) + eY) * 0.5;
	me.checkMarkOrigin = eY + eX * (me.columnPreviewOrigin + me.columnPreviewSize) - me.checkMarkSize;
}

void drawNexuizSkinList(entity me)
{
	drawListBox(me);
}

void drawListBoxItemNexuizSkinList(entity me, float i, vector absSize, float isSelected)
{
	
	string s;
	float theAlpha;
	
	tokenize_sane(me.skinlist);	
		
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
	if( me.currentskin == argv(i) )
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_MAPLIST_INCLUDEDBG, SKINALPHA_MAPLIST_INCLUDEDBG);
		
	theAlpha = SKINALPHA_MAPLIST_INCLUDEDFG;
		
	draw_Picture(me.columnPreviewOrigin * eX, strcat("/gfx/menu/", argv(i), "/skinpreview"), me.columnPreviewSize * eX + eY, '1 1 1', theAlpha);
	
	s = draw_TextShortenToWidth(argv(i), me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_TITLE, theAlpha, 0);
	
}

void setSkin(entity btn, entity me)
{
	float i;
	
	i = me.selectedItem;
	
	if(i >= me.nItems || i < 0)
		return;
		
	tokenize_sane(me.skinlist);
	cvar_set("menu_skin", argv(i));
	localcmd("\nmenu_restart\ntogglemenu\ndefer 1 \"menu_cmd skinselect\"\n");

}
#endif
