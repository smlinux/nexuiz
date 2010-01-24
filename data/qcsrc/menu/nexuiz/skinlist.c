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
	METHOD(NexuizSkinList, skinParameter, string(entity, float, float))
	METHOD(NexuizSkinList, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizSkinList, keyDown, float(entity, float, float, float))
	METHOD(NexuizSkinList, destroy, void(entity))

	ATTRIB(NexuizSkinList, skinlist, float, -1)
	ATTRIB(NexuizSkinList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizSkinList, columnPreviewOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnPreviewSize, float, 0)
	ATTRIB(NexuizSkinList, columnNameOrigin, float, 0)
	ATTRIB(NexuizSkinList, columnNameSize, float, 0)
	ATTRIB(NexuizSkinList, realUpperMargin1, float, 0)
	ATTRIB(NexuizSkinList, realUpperMargin2, float, 0)
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

#define SKINPARM_NAME 0
#define SKINPARM_TITLE 1
#define SKINPARM_AUTHOR 2
#define SKINPARM_PREVIEW 3
#define SKINPARM_COUNT 4

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
		if(me.skinParameter(me, i, SKINPARM_NAME) == s)
		{
			me.selectedItem = i;
			break;
		}
	}
}

void saveCvarsNexuizSkinList(entity me)
{
	cvar_set("menu_skin", me.skinParameter(me, me.selectedItem, SKINPARM_NAME));
}

string skinParameterNexuizSkinList(entity me, float i, float key)
{
	return bufstr_get(me.skinlist, i * SKINPARM_COUNT + key);
}

void getSkinsNexuizSkinList(entity me)
{
	float glob, buf, i, n, fh;
	string s;

	buf = buf_create();
	glob = search_begin("gfx/menu/*/skinvalues.txt", TRUE, TRUE);
	if(glob < 0)
	{
		me.skinlist = buf;
		me.nItems = 0;
		return;
	}

	n = search_getsize(glob);
	for(i = 0; i < n; ++i)
	{
		s = search_getfilename(glob, i);
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_NAME, substring(s, 9, strlen(s) - 24)); // the * part
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_TITLE, "<TITLE>");
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_AUTHOR, "<AUTHOR>");
		bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_PREVIEW, strcat("/gfx/menu/", substring(s, 9, strlen(s) - 24), "/skinpreview"));
		fh = fopen(s, FILE_READ);
		if(fh < 0)
		{
			print("Warning: can't open skinvalues.txt file\n");
			continue;
		}
		while((s = fgets(fh)))
		{
			// these two are handled by skinlist.qc
			if(substring(s, 0, 6) == "title ")
				bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_TITLE, substring(s, 6, strlen(s) - 6));
			else if(substring(s, 0, 7) == "author ")
				bufstr_set(buf, i * SKINPARM_COUNT + SKINPARM_AUTHOR, substring(s, 7, strlen(s) - 7));
		}
		fclose(fh);
	}

	search_end(glob);

	me.skinlist = buf;
	me.nItems = n;
}

void destroyNexuizSkinList(entity me)
{
	buf_del(me.skinlist);
}

void resizeNotifyNexuizSkinList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
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
}

void drawListBoxItemNexuizSkinList(entity me, float i, vector absSize, float isSelected)
{
	string s;
	
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		
	s = me.skinParameter(me, i, SKINPARM_PREVIEW);
	draw_Picture(me.columnPreviewOrigin * eX, s, me.columnPreviewSize * eX + eY, '1 1 1', 1);
	
	s = me.skinParameter(me, i, SKINPARM_NAME);
	s = strcat(s, ": ", me.skinParameter(me, i, SKINPARM_TITLE));
	s = draw_TextShortenToWidth(s, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_SKINLIST_TITLE, SKINALPHA_TEXT, 0);

	s = me.skinParameter(me, i, SKINPARM_AUTHOR);
	s = draw_TextShortenToWidth(s, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 1.00 * (me.columnNameSize - draw_TextWidth(s, 0, me.realFontSize))) * eX, s, me.realFontSize, SKINCOLOR_SKINLIST_AUTHOR, SKINALPHA_TEXT, 0);
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
