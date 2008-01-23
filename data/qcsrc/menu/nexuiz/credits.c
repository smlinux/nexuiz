#ifdef INTERFACE
CLASS(NexuizCreditsList) EXTENDS(NexuizListBox)
	METHOD(NexuizCreditsList, configureNexuizCreditsList, void(entity))
	ATTRIB(NexuizCreditsList, rowsPerItem, float, 1)
	METHOD(NexuizCreditsList, draw, void(entity))
	METHOD(NexuizCreditsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizCreditsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizCreditsList, keyDown, float(entity, float, float, float))

	ATTRIB(NexuizCreditsList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizCreditsList, realUpperMargin, float, 0)
	ATTRIB(NexuizCreditsList, bufferIndex, float, 0)
	ATTRIB(NexuizCreditsList, scrolling, float, 0)
ENDCLASS(NexuizCreditsList)
entity makeNexuizCreditsList();
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
float SLIST_FIELD_FREESLOTS;
void CreditsList_UpdateFieldIDs()
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
	SLIST_FIELD_FREESLOTS = gethostcacheindexforkey( "freeslots" );
}

entity makeNexuizCreditsList()
{
	entity me;
	me = spawnNexuizCreditsList();
	me.configureNexuizCreditsList(me);
	return me;
}
void configureNexuizCreditsListNexuizCreditsList(entity me)
{
	me.configureNexuizListBox(me);
	// load the file
	me.bufferIndex = buf_load("nexuiz-credits.txt");
	me.nItems = buf_getsize(me.bufferIndex);
}
void drawNexuizCreditsList(entity me)
{
	float i;
	if(me.scrolling && time > me.scrolling)
	{
		me.scrollPos = min(me.scrollPos + frametime * me.itemHeight, me.nItems * me.itemHeight - 1);
		i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
		i = max(i, ceil(me.scrollPos / me.itemHeight));
		me.setSelected(me, i);
	}
	drawListBox(me);
}
void resizeNotifyNexuizCreditsList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
void drawListBoxItemNexuizCreditsList(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Credits name, Map name, NP, TP, MP
	string s;
	float theAlpha;
	vector theColor;

	s = bufstr_get(me.bufferIndex, i);

	if(substring(s, 0, 2) == "**")
	{
		s = substring(s, 2, strlen(s) - 2);
		theColor = SKINCOLOR_CREDITS_TITLE;
		theAlpha = SKINALPHA_CREDITS_TITLE;
	}
	else if(substring(s, 0, 1) == "*")
	{
		s = substring(s, 1, strlen(s) - 1);
		theColor = SKINCOLOR_CREDITS_FUNCTION;
		theAlpha = SKINALPHA_CREDITS_FUNCTION;
	}
	else
	{
		theColor = SKINCOLOR_CREDITS_PERSON;
		theAlpha = SKINALPHA_CREDITS_PERSON;
	}

	draw_CenterText(me.realUpperMargin * eY + 0.5 * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float keyDownNexuizCreditsList(entity me, float scan, float ascii, float shift)
{
	float i;
	me.dragScrollTimer = 0;
	me.scrolling = 0;

	if(scan == K_PGUP)
		me.scrollPos = max(me.scrollPos - 0.5, 0);
	else if(scan == K_PGDN)
		me.scrollPos = min(me.scrollPos + 0.5, me.nItems * me.itemHeight - 1);
	else if(scan == K_UPARROW)
		me.scrollPos = max(me.scrollPos - me.itemHeight, 0);
	else if(scan == K_DOWNARROW)
		me.scrollPos = min(me.scrollPos + me.itemHeight, me.nItems * me.itemHeight - 1);
	else
		return keyDownListBox(me, scan, ascii, shift);

	i = min(me.selectedItem, floor((me.scrollPos + 1) / me.itemHeight - 1));
	i = max(i, ceil(me.scrollPos / me.itemHeight));
	me.setSelected(me, i);

	return 1;
}
#endif
