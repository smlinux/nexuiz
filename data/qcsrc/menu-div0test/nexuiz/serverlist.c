#ifdef INTERFACE
CLASS(NexuizServerList) EXTENDS(NexuizListBox)
	METHOD(NexuizServerList, configureNexuizServerList, void(entity))
	ATTRIB(NexuizServerList, rowsPerItem, float, 1)
	METHOD(NexuizServerList, draw, void(entity))
	METHOD(NexuizServerList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizServerList, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizServerList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizServerList, keyDown, float(entity, float, float, float))

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
	METHOD(NexuizServerList, setSortOrder, void(entity, float, float))
	ATTRIB(NexuizServerList, filterShowEmpty, float, 1)
	ATTRIB(NexuizServerList, filterShowFull, float, 1)
	ATTRIB(NexuizServerList, filterString, string, string_null)
	ATTRIB(NexuizServerList, nextRefreshTime, float, 0)
	METHOD(NexuizServerList, refreshServerList, void(entity, float)) // refresh mode: 0 = just reparametrize, 1 = send new requests, 2 = clear
	ATTRIB(NexuizServerList, needsRefresh, float, 1)
	METHOD(NexuizServerList, focusEnter, void(entity))
	METHOD(NexuizServerList, positionSortButton, void(entity, entity, float, float, string, void(entity, entity)))
	ATTRIB(NexuizServerList, sortButton1, entity, NULL)
	ATTRIB(NexuizServerList, sortButton2, entity, NULL)
	ATTRIB(NexuizServerList, sortButton3, entity, NULL)
	ATTRIB(NexuizServerList, sortButton4, entity, NULL)
	ATTRIB(NexuizServerList, connectButton, entity, NULL)
	ATTRIB(NexuizServerList, currentSortOrder, float, 0)
	ATTRIB(NexuizServerList, currentSortField, float, -1)
	ATTRIB(NexuizServerList, lastClickedServer, float, -1)
	ATTRIB(NexuizServerList, lastClickedTime, float, 0)
ENDCLASS(NexuizServerList)
entity makeNexuizServerList();
void ServerList_Connect_Click(entity btn, entity me);
void ServerList_ShowEmpty_Click(entity box, entity me);
void ServerList_ShowFull_Click(entity box, entity me);
void ServerList_Filter_Change(entity box, entity me);
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
	SLIST_FIELD_FREESLOTS = gethostcacheindexforkey( "freeslots" );
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
void refreshServerListNexuizServerList(entity me, float mode)
{
	// 0: just reparametrize
	// 1: also ask for new servers
	// 2: clear
	//print("refresh of type ", ftos(mode), "\n");
	/* if(mode == 2) // borken
	{
		// clear list
		localcmd("net_slist\n");
		me.needsRefresh = 1; // net_slist kills sort order, so we need to restore it later
	}
	else */
	{
		float m;
		m = SLIST_MASK_AND;
		resethostcachemasks();
		if(!me.filterShowFull)
			sethostcachemasknumber(m++, SLIST_FIELD_FREESLOTS, 1, SLIST_TEST_GREATEREQUAL);
		if(!me.filterShowEmpty)
			sethostcachemasknumber(m++, SLIST_FIELD_NUMHUMANS, 1, SLIST_TEST_GREATEREQUAL);
		m = SLIST_MASK_OR;
		if(me.filterString)
		{
			sethostcachemaskstring(m++, SLIST_FIELD_NAME, me.filterString, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(m++, SLIST_FIELD_MAP, me.filterString, SLIST_TEST_CONTAINS);
		}
		sethostcachesort(me.currentSortField, me.currentSortOrder < 0);
		resorthostcache();
		if(mode >= 1)
			refreshhostcache();
	}
}
void focusEnterNexuizServerList(entity me)
{
	if(time < me.nextRefreshTime)
	{
		//print("sorry, no refresh yet\n");
		return;
	}
	me.nextRefreshTime = time + 10;
	me.refreshServerList(me, 1);
}
void drawNexuizServerList(entity me)
{
	float i, found;

	if(me.currentSortField == -1)
	{
		me.setSortOrder(me, SLIST_FIELD_PING, +1);
		me.refreshServerList(me, 2);
	}
	else if(me.needsRefresh == 1)
	{
		me.needsRefresh = 2; // delay by one frame to make sure "slist" has been executed
	}
	else if(me.needsRefresh == 2)
	{
		me.needsRefresh = 0;
		me.refreshServerList(me, 0);
	}

	me.nItems = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	me.connectButton.disabled = (me.nItems == 0);

	found = 0;
	if(me.selectedServer)
	{
		for(i = 0; i < me.nItems; ++i)
			if(gethostcachestring(SLIST_FIELD_CNAME, i) == me.selectedServer)
			{
				if(i != me.selectedItem)
				{
					me.lastClickedServer = -1;
					me.selectedItem = i;
				}
				found = 1;
				break;
			}
	}
	if(!found)
		if(me.nItems > 0)
		{
			if(me.selectedItem >= me.nItems)
				me.selectedItem = me.nItems - 1;
			if(me.selectedServer)
				strunzone(me.selectedServer);
			me.selectedServer = strzone(gethostcachestring(SLIST_FIELD_CNAME, me.selectedItem));
		}

	drawListBox(me);
}
void ServerList_PingSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_PING, +1);
}
void ServerList_NameSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_NAME, -1); // why?
}
void ServerList_MapSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_MAP, -1); // why?
}
void ServerList_PlayerSort_Click(entity btn, entity me)
{
	me.setSortOrder(me, SLIST_FIELD_NUMHUMANS, -1);
}
void ServerList_Filter_Change(entity box, entity me)
{
	if(me.filterString)
		strunzone(me.filterString);
	if(box.text != "")
		me.filterString = strzone(box.text);
	else
		me.filterString = string_null;
	me.refreshServerList(me, 0);
}
void ServerList_ShowEmpty_Click(entity box, entity me)
{
	box.checked = me.filterShowEmpty = !me.filterShowEmpty;
	me.refreshServerList(me, 0);
}
void ServerList_ShowFull_Click(entity box, entity me)
{
	box.checked = me.filterShowFull = !me.filterShowFull;
	me.refreshServerList(me, 0);
}
void setSortOrderNexuizServerList(entity me, float field, float direction)
{
	if(me.currentSortField == field)
		direction = -me.currentSortOrder;
	me.currentSortOrder = direction;
	me.currentSortField = field;
	me.sortButton1.forcePressed = (field == SLIST_FIELD_PING);
	me.sortButton2.forcePressed = (field == SLIST_FIELD_NAME);
	me.sortButton3.forcePressed = (field == SLIST_FIELD_MAP);
	me.sortButton4.forcePressed = (field == SLIST_FIELD_NUMHUMANS);
	me.selectedItem = 0;
	if(me.selectedServer)
		strunzone(me.selectedServer);
	me.selectedServer = string_null;
	me.refreshServerList(me, 0);
}
void positionSortButtonNexuizServerList(entity me, entity btn, float theOrigin, float theSize, string theTitle, void(entity, entity) theFunc)
{
	vector originInLBSpace, sizeInLBSpace;
	originInLBSpace = eY * (-me.itemHeight);
	sizeInLBSpace = eY * me.itemHeight + eX * (1 - me.controlWidth);

	vector originInDialogSpace, sizeInDialogSpace;
	originInDialogSpace = boxToGlobal(originInLBSpace, me.Container_origin, me.Container_size);
	sizeInDialogSpace = boxToGlobalSize(sizeInLBSpace, me.Container_size);

	btn.Container_origin_x = originInDialogSpace_x + sizeInDialogSpace_x * theOrigin;
	btn.Container_size_x   =                         sizeInDialogSpace_x * theSize;
	btn.setText(btn, theTitle);
	btn.onClick = theFunc;
	btn.onClickEntity = me;
	btn.resized = 1;
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

	me.positionSortButton(me, me.sortButton1, me.columnPingOrigin, me.columnPingSize, "Ping", ServerList_PingSort_Click);
	me.positionSortButton(me, me.sortButton2, me.columnNameOrigin, me.columnNameSize, "Host name", ServerList_NameSort_Click);
	me.positionSortButton(me, me.sortButton3, me.columnMapOrigin, me.columnMapSize, "Map", ServerList_MapSort_Click);
	me.positionSortButton(me, me.sortButton4, me.columnPlayersOrigin, me.columnPlayersSize, "Players", ServerList_PlayerSort_Click);

	float f;
	f = me.currentSortField;
	if(f >= 0)
	{
		me.currentSortField = -1;
		me.setSortOrder(me, f, me.currentSortOrder); // force resetting the sort order
	}
}
void ServerList_Connect_Click(entity btn, entity me)
{
	if(me.nItems > 0)
		localcmd("connect ", me.selectedServer, "\n");
}
void clickListBoxItemNexuizServerList(entity me, float i, vector where)
{
	if(i == me.lastClickedServer)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			ServerList_Connect_Click(NULL, me);
		}
	me.lastClickedServer = i;
	me.lastClickedTime = time;
}
void drawListBoxItemNexuizServerList(entity me, float i, vector absSize, float isSelected)
{
	// layout: Ping, Server name, Map name, NP, TP, MP
	string s;
	float p;
	vector theColor;
	float theAlpha;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);

	if(gethostcachenumber(SLIST_FIELD_NUMPLAYERS, i) >= gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i))
		theAlpha = SKINALPHA_SERVERLIST_FULL;
	else if not(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i))
		theAlpha = SKINALPHA_SERVERLIST_EMPTY;
	else
		theAlpha = 1;
	
	p = gethostcachenumber(SLIST_FIELD_PING, i);
	if(p < 50)
		theColor = SKINCOLOR_SERVERLIST_LOWPING + (SKINCOLOR_SERVERLIST_MEDPING - SKINCOLOR_SERVERLIST_LOWPING) * (p / 50);
	else if(p < 150)
		theColor = SKINCOLOR_SERVERLIST_MEDPING + (SKINCOLOR_SERVERLIST_HIGHPING - SKINCOLOR_SERVERLIST_MEDPING) * ((p - 50) / 100);
	else if(p < 650)
	{
		theColor = SKINCOLOR_SERVERLIST_HIGHPING;
		theAlpha *= 1 + (SKINALPHA_SERVERLIST_HIGHPING - 1) * ((p - 150) / 500);
	}
	else
	{
		theColor = eX;
		theAlpha *= SKINALPHA_SERVERLIST_HIGHPING;
	}
	
	s = ftos(p);
	draw_Text(me.realUpperMargin * eY + (me.columnPingSize - draw_TextWidth(s, 0) * me.realFontSize_x) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_NAME, i), me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_MAP, i), me.columnMapSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + (me.columnMapOrigin + (me.columnMapSize - draw_TextWidth(s, 0) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = strcat(ftos(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i)), "/", ftos(gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i)));
	draw_Text(me.realUpperMargin * eY + (me.columnPlayersOrigin + (me.columnPlayersSize - draw_TextWidth(s, 0) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float keyDownNexuizServerList(entity me, float scan, float ascii, float shift)
{
	if(scan == K_ENTER || scan == K_SPACE)
		ServerList_Connect_Click(NULL, me);
	else
		return keyDownListBox(me, scan, ascii, shift);
	return 1;
}
#endif
