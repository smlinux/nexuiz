#ifdef INTERFACE
CLASS(NexuizSkinList) EXTENDS(NexuizListBox)
	METHOD(NexuizSkinList, configureNexuizSkinList, void(entity))
	ATTRIB(NexuizSkinList, rowsPerItem, float, 4)
	METHOD(NexuizSkinList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizSkinList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizSkinList, getSkins, void(entity))
	METHOD(NexuizSkinList, setSkin, void(entity))
	METHOD(NexuizSkinList, loadCvars, void(entity))
	METHOD(NexuizSkinList, saveCvars, void(entity))
	METHOD(NexuizSkinList, skinName, string(entity, float))
	METHOD(NexuizSkinList, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizSkinList, keyDown, float(entity, float, float, float))
	METHOD(NexuizSkinList, destroy, void(entity))

	ATTRIB(NexuizSkinList, skinlist, float, -1)
	ATTRIB(NexuizSkinList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizSkinList, columnPreviewOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnPreviewSize, float, 0)
	ATTRIB(NexuizSkinList, columnNameOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnNameSize, float, 0)
	ATTRIB(NexuizSkinList, realUpperMargin, float, 0)	
	ATTRIB(NexuizSkinList, origin, vector, '0 0 0')
	ATTRIB(NexuizSkinList, itemAbsSize, vector, '0 0 0')

	ATTRIB(NexuizSkinList, lastClickedSkin, float, -1)
	ATTRIB(NexuizSkinList, lastClickedTime, float, 0)

	ATTRIB(NexuizSkinList, name, string, "skinselector")
ENDCLASS(NexuizSkinList)

entity makeNexuizSkinList();
void SetSkin_Click(entity btn, entity me);
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
	me.loadCvars(me);
}

void loadCvarsNexuizSkinList(entity me)
{
	string s;
	float i, n;
	s = cvar_string("menu_skin");
	n = me.nItems;
	for(i = 0; i < n; ++i)
	{
		if(me.skinName(me, i) == s)
		{
			me.selectedItem = i;
			break;
		}
	}
}

void saveCvarsNexuizSkinList(entity me)
{
	cvar_set("menu_skin", me.skinName(me, me.selectedItem));
}

string skinNameNexuizSkinList(entity me, float i)
{
	string s;
	s = search_getfilename(me.skinlist, i);
	s = substring(s, 9, strlen(s) - 9 - 15);  // gfx/menu/, skinvalues.txt
	return s;
}

void getSkinsNexuizSkinList(entity me)
{
	me.skinlist = search_begin("gfx/menu/*/skinvalues.txt", TRUE, TRUE);
	me.nItems = search_getsize(me.skinlist);
}

void destroyNexuizSkinList(entity me)
{
	search_end(me.skinlist);
}

void resizeNotifyNexuizSkinList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.itemAbsSize = '0 0 0';
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = me.itemAbsSize_y / me.itemAbsSize_x * 4 / 3;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - 2 * me.realFontSize_x;
}

void drawListBoxItemNexuizSkinList(entity me, float i, vector absSize, float isSelected)
{
	string s;
	
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
	s = me.skinName(me, i);
	draw_Picture(me.columnPreviewOrigin * eX, strcat("/gfx/menu/", s, "/skinpreview"), me.columnPreviewSize * eX + eY, '1 1 1', 1);
	
	s = draw_TextShortenToWidth(s, me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

void setSkinNexuizSkinList(entity me)
{
	me.saveCvars(me);
	localcmd("\nmenu_restart\ntogglemenu\ndefer 0.1 \"menu_cmd skinselect\"\n");
}

void SetSkin_Click(entity btn, entity me)
{
	me.setSkin(me);
}

void clickListBoxItemNexuizSkinList(entity me, float i, vector where)
{
	if(i == me.lastClickedSkin)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			me.setSelected(me, i);
			me.setSkin(me);
		}
	me.lastClickedSkin = i;
	me.lastClickedTime = time;
}

float keyDownNexuizSkinList(entity me, float scan, float ascii, float shift)
{
	if(scan == K_ENTER) {
		me.setSkin(me);
		return 1;
	}
	else
		return keyDownListBox(me, scan, ascii, shift);
}
#endif
