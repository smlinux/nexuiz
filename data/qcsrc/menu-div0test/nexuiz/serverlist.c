#ifdef INTERFACE
CLASS(NexuizServerList) EXTENDS(NexuizListBox)
	METHOD(NexuizServerList, configureNexuizServerList, void(entity))
	ATTRIB(NexuizServerList, rowsPerItem, float, 1)
	METHOD(NexuizServerList, draw, void(entity))
	METHOD(NexuizServerList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizServerList, resizeNotify, void(entity, vector, vector, vector, vector))

	ATTRIB(NexuizServerList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizServerList, realUpperMargin, float, 0)
	ATTRIB(NexuizServerList, columnPingOrigin, float, 0)
	ATTRIB(NexuizServerList, columnPingSize, float, 0)
	ATTRIB(NexuizServerList, columnNameOrigin, float, 0)
	ATTRIB(NexuizServerList, columnNameSize, float, 0)
	ATTRIB(NexuizServerList, columnMapOrigin, float, 0)
	ATTRIB(NexuizServerList, columnMapSize, float, 0)
	ATTRIB(NexuizServerList, columnPlayersOrigin, float, 0)
	ATTRIB(NexuizServerList, columnPlayersSize, float, 0)

	ATTRIB(NexuizServerList, selectedServer, string, string_null) // to restore selected server when needed
	METHOD(NexuizServerList, setSelected, void(entity, float))
ENDCLASS(NexuizServerList)
entity makeNexuizServerList();
#endif

#ifdef IMPLEMENTATION
float SLIST_FIELD_CNAME;
float SLIST_FIELD_PING;
float SLIST_FIELD_GAME;
float SLIST_FIELD_MOD;
float SLIST_FIELD_MAP;
float SLIST_FIELD_NAME;
float SLIST_FIELD_MAXPLAYERS;
float SLIST_FIELD_NUMPLAYERS;
float SLIST_FIELD_NUMHUMANS;
float SLIST_FIELD_NUMBOTS;
float SLIST_FIELD_PROTOCOL;
void ServerList_UpdateFieldIDs()
{
	SLIST_FIELD_CNAME = gethostcacheindexforkey( "cname" );
	SLIST_FIELD_PING = gethostcacheindexforkey( "ping" );
	SLIST_FIELD_GAME = gethostcacheindexforkey( "game" );
	SLIST_FIELD_MOD = gethostcacheindexforkey( "mod" );
	SLIST_FIELD_MAP = gethostcacheindexforkey( "map" );
	SLIST_FIELD_NAME = gethostcacheindexforkey( "name" );
	SLIST_FIELD_MAXPLAYERS = gethostcacheindexforkey( "maxplayers" );
	SLIST_FIELD_NUMPLAYERS = gethostcacheindexforkey( "numplayers" );
	SLIST_FIELD_NUMHUMANS = gethostcacheindexforkey( "numhumans" );
	SLIST_FIELD_NUMBOTS = gethostcacheindexforkey( "numbots" );
	SLIST_FIELD_PROTOCOL = gethostcacheindexforkey( "protocol" );
}

entity makeNexuizServerList()
{
	entity me;
	me = spawnNexuizServerList();
	me.configureNexuizServerList(me);
	return me;
}
void configureNexuizServerListNexuizServerList(entity me)
{
	me.configureNexuizListBox(me);

	ServerList_UpdateFieldIDs();
	resethostcachemasks();
	refreshhostcache();

	me.nItems = 0;
}
void setSelectedNexuizServerList(entity me, float i)
{
	float save;
	save = me.selectedItem;
	setSelectedListBox(me, i);
	/*
	if(me.selectedItem == save)
		return;
	*/
	if(me.nItems == 0)
		return;
	if(gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT) != me.nItems)
		return; // sorry, it would be wrong
	if(me.selectedServer)
		strunzone(me.selectedServer);
	me.selectedServer = strzone(gethostcachestring(SLIST_FIELD_CNAME, me.selectedItem));
}
void drawNexuizServerList(entity me)
{
	float i;
	me.nItems = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	for(i = 0; i < me.nItems; ++i)
	{
		if(gethostcachestring(SLIST_FIELD_CNAME, i) == me.selectedServer)
		{
			me.selectedItem = i;
			break;
		}
	}
	drawListBox(me);
}
void resizeNotifyNexuizServerList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnPingOrigin = 0;
	me.columnPingSize = me.realFontSize_x * 4;
	me.columnMapSize = me.realFontSize_x * 12;
	me.columnPlayersSize = me.realFontSize_x * 6;
	me.columnNameSize = 1 - me.columnPlayersSize - me.columnMapSize - me.columnPingSize - 3 * me.realFontSize_x;
	me.columnNameOrigin = me.columnPingOrigin + me.columnPingSize + me.realFontSize_x;
	me.columnMapOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;
	me.columnPlayersOrigin = me.columnMapOrigin + me.columnMapSize + me.realFontSize_x;
}
void drawListBoxItemNexuizServerList(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Server name, Map name, NP, TP, MP
	string s;
	float p;
	vector theColor;
	float theAlpha;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', '0 0 1', 0.5);

	if(gethostcachenumber(SLIST_FIELD_NUMPLAYERS, i) >= gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i))
		theAlpha = 0.2;
	else if(!gethostcachenumber(SLIST_FIELD_NUMHUMANS, i))
		theAlpha = 0.5;
	else
		theAlpha = 1;
	
	p = gethostcachenumber(SLIST_FIELD_PING, i);
	if(p < 50)
		theColor = eX * (p / 50) + eY;
	else if(p < 150)
		theColor = eX + eY * ((150 - p) / 100);
	else if(p < 650)
	{
		theColor = eX;
		theAlpha *= (650 - p) / 500;
	}
	
	s = ftos(p);
	draw_Text(me.realUpperMargin * eY + (me.columnPingSize - draw_TextWidth(s) * me.realFontSize_x) * eX, s, me.realFontSize, theColor, theAlpha);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_NAME, i), me.columnNameSize / me.realFontSize_x);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_MAP, i), me.columnMapSize / me.realFontSize_x);
	draw_Text(me.realUpperMargin * eY + (me.columnMapOrigin + (me.columnMapSize - draw_TextWidth(s) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha);
	s = strcat(ftos(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i)), "/", ftos(gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i)));
	draw_Text(me.realUpperMargin * eY + (me.columnPlayersOrigin + (me.columnPlayersSize - draw_TextWidth(s) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha);
}
#endif
