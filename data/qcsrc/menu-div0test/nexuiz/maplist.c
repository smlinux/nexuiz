#ifdef INTERFACE
CLASS(NexuizMapList) EXTENDS(NexuizListBox)
	METHOD(NexuizMapList, configureNexuizMapList, void(entity))
	ATTRIB(NexuizMapList, rowsPerItem, float, 4)
	METHOD(NexuizMapList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizMapList, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizMapList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizMapList, refilter, void(entity))

	ATTRIB(NexuizMapList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizMapList, columnPreviewOrigin, float, 0)
	ATTRIB(NexuizMapList, columnPreviewSize, float, 0)
	ATTRIB(NexuizMapList, columnNameOrigin, float, 0)
	ATTRIB(NexuizMapList, columnNameSize, float, 0)
	ATTRIB(NexuizMapList, checkMarkOrigin, vector, '0 0 0')
	ATTRIB(NexuizMapList, checkMarkSize, vector, '0 0 0')
	ATTRIB(NexuizMapList, realUpperMargin1, float, 0)
	ATTRIB(NexuizMapList, realUpperMargin2, float, 0)

	ATTRIB(NexuizMapList, lastClickedMap, float, -1)
	ATTRIB(NexuizMapList, lastClickedTime, float, 0)

	ATTRIB(NexuizMapList, g_maplistCache, string, string_null)
	METHOD(NexuizMapList, g_maplistCacheToggle, void(entity, float))
	METHOD(NexuizMapList, g_maplistCacheQuery, float(entity, float))
ENDCLASS(NexuizMapList)
entity makeNexuizMapList();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizMapList()
{
	entity me;
	me = spawnNexuizMapList();
	me.configureNexuizMapList(me);
	return me;
}
void configureNexuizMapListNexuizMapList(entity me)
{
	me.configureNexuizListBox(me);
	me.refilter(me);
}

float g_maplistCacheQueryNexuizMapList(entity me, float i)
{
	return stof(substring(me.g_maplistCache, i, 1));
}
void g_maplistCacheToggleNexuizMapList(entity me, float i)
{
	string a, b, c, s;
	s = me.g_maplistCache;
	if not(s)
		return;
	b = substring(s, i, 1);
	if(b == "0")
		b = "1";
	else if(b == "1")
		b = "0";
	else
		return; // nothing happens
	a = substring(s, 0, i);
	c = substring(s, i+1, strlen(s) - (i+1));
	strunzone(s);
	me.g_maplistCache = strzone(strcat(a, b, c));
}

void resizeNotifyNexuizMapList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	vector itemAbsSize;
	itemAbsSize = '0 0 0';

	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin1 = 0.5 * (1 - 2.5 * me.realFontSize_y);
	me.realUpperMargin2 = me.realUpperMargin1 + 1.5 * me.realFontSize_y;

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = itemAbsSize_y / itemAbsSize_x * 4 / 3;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - 2 * me.realFontSize_x;

	me.checkMarkSize = (eX * (itemAbsSize_y / itemAbsSize_x) + eY) * 0.5;
	me.checkMarkOrigin = eY + eX * (me.columnPreviewOrigin + me.columnPreviewSize) - me.checkMarkSize;
}
void clickListBoxItemNexuizMapList(entity me, float i, vector where)
{
	if(i == me.lastClickedMap)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			// insert/remove into/from maplist
			me.g_maplistCacheToggle(me, i);
			// TODO also update the actual cvar
		}
	me.lastClickedMap = i;
	me.lastClickedTime = time;
}
void drawListBoxItemNexuizMapList(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Map name, Map name, NP, TP, MP
	string s;
	float p;
	vector theColor;
	float theAlpha;
	float included;

	theColor = '1 1 1';

	if(!MapInfo_Get_ByID(i))
		return;

	included = me.g_maplistCacheQuery(me, i);
	if(included)
		theAlpha = 1;
	else
		theAlpha = 0.4;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', '0 0 1', 0.5);
	else if(included)
		draw_Fill('0 0 0', '1 1 0', '0 0 0', 0.5);

	s = ftos(p);
	draw_Picture(me.columnPreviewOrigin * eX, strcat("/maps/", MapInfo_Map_bspname), me.columnPreviewSize * eX + eY, '1 1 1', theAlpha);
	if(included)
		draw_Picture(me.checkMarkOrigin, "checkmark", me.checkMarkSize, '1 1 1', 1);
	s = draw_TextShortenToWidth(strcat(MapInfo_Map_bspname, ": ", MapInfo_Map_title), me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_TITLE, theAlpha, 0);
	s = draw_TextShortenToWidth(MapInfo_Map_author, me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 1.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_AUTHOR, theAlpha, 0);
}

void refilterNexuizMapList(entity me)
{
	float i, j, n;
	string s;
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures());
	me.nItems = MapInfo_count;
	if(me.g_maplistCache)
		strunzone(me.g_maplistCache);
	s = "0";
	for(i = 1; i < MapInfo_count; i *= 2)
		s = strcat(s, s);
	n = tokenize(cvar_string("g_maplist"));
	for(i = 0; i < n; ++i)
	{
		j = MapInfo_FindName(argv(i));
		if(j >= 0)
			s = strcat(
				substring(s, 0, j),
				"1",
				substring(s, j+1, MapInfo_count - (j+1))
			);
	}
	me.g_maplistCache = strzone(s);
}
#endif
