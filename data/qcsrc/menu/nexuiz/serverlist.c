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
	ATTRIB(NexuizServerList, columnTypeOrigin, float, 0)
	ATTRIB(NexuizServerList, columnTypeSize, float, 0)
	ATTRIB(NexuizServerList, columnPlayersOrigin, float, 0)
	ATTRIB(NexuizServerList, columnPlayersSize, float, 0)

	ATTRIB(NexuizServerList, selectedServer, string, string_null) // to restore selected server when needed
	METHOD(NexuizServerList, setSelected, void(entity, float))
	METHOD(NexuizServerList, setSortOrder, void(entity, float, float))
	ATTRIB(NexuizServerList, filterShowEmpty, float, 1)
	ATTRIB(NexuizServerList, filterShowFull, float, 1)
	ATTRIB(NexuizServerList, filterString, string, string_null)
	ATTRIB(NexuizServerList, controlledTextbox, entity, NULL)
	ATTRIB(NexuizServerList, ipAddressBox, entity, NULL)
	ATTRIB(NexuizServerList, favoriteButton, entity, NULL)
	ATTRIB(NexuizServerList, nextRefreshTime, float, 0)
	METHOD(NexuizServerList, refreshServerList, void(entity, float)) // refresh mode: 0 = just reparametrize, 1 = send new requests, 2 = clear
	ATTRIB(NexuizServerList, needsRefresh, float, 1)
	METHOD(NexuizServerList, focusEnter, void(entity))
	METHOD(NexuizServerList, positionSortButton, void(entity, entity, float, float, string, void(entity, entity)))
	ATTRIB(NexuizServerList, sortButton1, entity, NULL)
	ATTRIB(NexuizServerList, sortButton2, entity, NULL)
	ATTRIB(NexuizServerList, sortButton3, entity, NULL)
	ATTRIB(NexuizServerList, sortButton4, entity, NULL)
	ATTRIB(NexuizServerList, sortButton5, entity, NULL)
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
void ServerList_Favorite_Click(entity btn, entity me);
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
float SLIST_FIELD_PLAYERS;
float SLIST_FIELD_QCSTATUS;
float SLIST_FIELD_ISFAVORITE;
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
	SLIST_FIELD_PLAYERS = gethostcacheindexforkey( "players" );
	SLIST_FIELD_QCSTATUS = gethostcacheindexforkey( "qcstatus" );
	SLIST_FIELD_ISFAVORITE = gethostcacheindexforkey( "isfavorite" );
}

float IsFavorite(string srv)
{
	string s;
	float o;
	s = cvar_string("net_slist_favorites");
	s = strcat(" ", s, " ");
	srv = strcat(" ", srv, " ");
	o = strstrofs(s, srv, 0);
	return (o != -1);
}

void ToggleFavorite(string srv)
{
	string s;
	float o;
	s = cvar_string("net_slist_favorites");
	o = strstrofs(strcat(" ", s, " "), strcat(" ", srv, " "), 0);
	if(o == -1)
	{
		cvar_set("net_slist_favorites", strcat(s, " ", srv));
	}
	else
	{
		cvar_set("net_slist_favorites", strcat(
					substring(s, 0, o - 1), substring(s, o + strlen(srv), strlen(s) - o - strlen(srv))
					));
	}
	resorthostcache();
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

	me.ipAddressBox.setText(me.ipAddressBox, me.selectedServer);
	me.ipAddressBox.cursorPos = strlen(me.selectedServer);
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
		float m, o;
		string s, typestr;
		s = me.filterString;

		m = strstrofs(s, ":", 0);
		if(m >= 0)
		{
			typestr = substring(s, 0, m);
			s = substring(s, m + 1, strlen(s) - m - 1);
			while(substring(s, 0, 1) == " ")
				s = substring(s, 1, strlen(s) - 1);
		}
		else
			typestr = "";

		m = SLIST_MASK_AND - 1;
		resethostcachemasks();
		if(!me.filterShowFull)
			sethostcachemasknumber(++m, SLIST_FIELD_FREESLOTS, 1, SLIST_TEST_GREATEREQUAL);
		if(!me.filterShowEmpty)
			sethostcachemasknumber(++m, SLIST_FIELD_NUMHUMANS, 1, SLIST_TEST_GREATEREQUAL);
		if(typestr != "")
			sethostcachemaskstring(++m, SLIST_FIELD_QCSTATUS, strcat(typestr, ":"), SLIST_TEST_STARTSWITH);
		m = SLIST_MASK_OR - 1;
		if(s != "")
		{
			sethostcachemaskstring(++m, SLIST_FIELD_NAME, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_MAP, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_PLAYERS, s, SLIST_TEST_CONTAINS);
			sethostcachemaskstring(++m, SLIST_FIELD_QCSTATUS, strcat(s, ":"), SLIST_TEST_STARTSWITH);
		}
		o = 2; // favorites first
		if(me.currentSortOrder < 0)
			o |= 1; // descending
		sethostcachesort(me.currentSortField, o);
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
	float i, found, owned;

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

	owned = (me.selectedServer == me.ipAddressBox.text);

	me.nItems = gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);

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

	if(owned)
	{
		me.ipAddressBox.setText(me.ipAddressBox, me.selectedServer);
		me.ipAddressBox.cursorPos = strlen(me.selectedServer);
	}

	if(IsFavorite(me.ipAddressBox.text))
		me.favoriteButton.setText(me.favoriteButton, "Remove");
	else
		me.favoriteButton.setText(me.favoriteButton, "Bookmark");

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
void ServerList_TypeSort_Click(entity btn, entity me)
{
	string s, t;
	float i, m;
	s = me.filterString;
	m = strstrofs(s, ":", 0);
	if(m >= 0)
	{
		s = substring(s, 0, m);
		while(substring(s, m+1, 1) == " ") // skip spaces
			++m;
	}
	else
		s = "";

	for(i = 1; ; ++i) // 20 modes ought to be enough for anyone
	{
		t = GametypeNameFromType(i);
		if(i > 1)
			if(t == GametypeNameFromType(0)) // it repeats (default case)
			{
				// no type was found
				// choose the first one
				s = t;
				break;
			}
		if(s == GametypeNameFromType(i))
		{
			// the type was found
			// choose the next one
			s = GametypeNameFromType(i + 1);
			if(s == GametypeNameFromType(0))
				s = "";
			break;
		}
	}

	if(s != "")
		s = strcat(s, ":");
	s = strcat(s, substring(me.filterString, m+1, strlen(me.filterString) - m - 1));

	me.controlledTextbox.setText(me.controlledTextbox, s);
	me.controlledTextbox.keyDown(me.controlledTextbox, K_END, 0, 0);
	me.controlledTextbox.keyUp(me.controlledTextbox, K_END, 0, 0);
	//ServerList_Filter_Change(me.controlledTextbox, me);
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

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
}
void ServerList_ShowEmpty_Click(entity box, entity me)
{
	box.setChecked(box, me.filterShowEmpty = !me.filterShowEmpty);
	me.refreshServerList(me, 0);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
}
void ServerList_ShowFull_Click(entity box, entity me)
{
	box.setChecked(box, me.filterShowFull = !me.filterShowFull);
	me.refreshServerList(me, 0);

	me.ipAddressBox.setText(me.ipAddressBox, "");
	me.ipAddressBox.cursorPos = 0;
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
	me.sortButton4.forcePressed = 0;
	me.sortButton5.forcePressed = (field == SLIST_FIELD_NUMHUMANS);
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
	me.columnTypeSize = me.realFontSize_x * 4;
	me.columnPlayersSize = me.realFontSize_x * 6;
	me.columnNameSize = 1 - me.columnPlayersSize - me.columnMapSize - me.columnPingSize - me.columnTypeSize - 4 * me.realFontSize_x;
	me.columnNameOrigin = me.columnPingOrigin + me.columnPingSize + me.realFontSize_x;
	me.columnMapOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;
	me.columnTypeOrigin = me.columnMapOrigin + me.columnMapSize + me.realFontSize_x;
	me.columnPlayersOrigin = me.columnTypeOrigin + me.columnTypeSize + me.realFontSize_x;

	me.positionSortButton(me, me.sortButton1, me.columnPingOrigin, me.columnPingSize, "Ping", ServerList_PingSort_Click);
	me.positionSortButton(me, me.sortButton2, me.columnNameOrigin, me.columnNameSize, "Host name", ServerList_NameSort_Click);
	me.positionSortButton(me, me.sortButton3, me.columnMapOrigin, me.columnMapSize, "Map", ServerList_MapSort_Click);
	me.positionSortButton(me, me.sortButton4, me.columnTypeOrigin, me.columnTypeSize, "Type", ServerList_TypeSort_Click);
	me.positionSortButton(me, me.sortButton5, me.columnPlayersOrigin, me.columnPlayersSize, "Players", ServerList_PlayerSort_Click);

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
	localcmd("connect ", me.ipAddressBox.text, "\n");
}
void ServerList_Favorite_Click(entity btn, entity me)
{
	string ipstr;
	ipstr = netaddress_resolve(me.ipAddressBox.text, 26000);
	if(ipstr != "")
	{
		me.ipAddressBox.setText(me.ipAddressBox, ipstr);
		me.ipAddressBox.cursorPos = strlen(ipstr);
		ToggleFavorite(ipstr);
	}
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
#define PING_LOW 75
#define PING_MED 200
#define PING_HIGH 500
	if(p < PING_LOW)
		theColor = SKINCOLOR_SERVERLIST_LOWPING + (SKINCOLOR_SERVERLIST_MEDPING - SKINCOLOR_SERVERLIST_LOWPING) * (p / PING_LOW);
	else if(p < PING_MED)
		theColor = SKINCOLOR_SERVERLIST_MEDPING + (SKINCOLOR_SERVERLIST_HIGHPING - SKINCOLOR_SERVERLIST_MEDPING) * ((p - PING_LOW) / (PING_MED - PING_LOW));
	else if(p < PING_HIGH)
	{
		theColor = SKINCOLOR_SERVERLIST_HIGHPING;
		theAlpha *= 1 + (SKINALPHA_SERVERLIST_HIGHPING - 1) * ((p - PING_MED) / (PING_HIGH - PING_MED));
	}
	else
	{
		theColor = eX;
		theAlpha *= SKINALPHA_SERVERLIST_HIGHPING;
	}

	if(gethostcachenumber(SLIST_FIELD_ISFAVORITE, i))
	{
		theColor = theColor * (1 - SKINALPHA_SERVERLIST_FAVORITE) + SKINCOLOR_SERVERLIST_FAVORITE * SKINALPHA_SERVERLIST_FAVORITE;
		theAlpha = theAlpha * (1 - SKINALPHA_SERVERLIST_FAVORITE) + SKINALPHA_SERVERLIST_FAVORITE;
	}

	s = ftos(p);
	draw_Text(me.realUpperMargin * eY + (me.columnPingSize - draw_TextWidth(s, 0) * me.realFontSize_x) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_NAME, i), me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(gethostcachestring(SLIST_FIELD_MAP, i), me.columnMapSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + (me.columnMapOrigin + (me.columnMapSize - draw_TextWidth(s, 0) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = gethostcachestring(SLIST_FIELD_QCSTATUS, i);
	p = strstrofs(s, ":", 0);
	if(p >= 0)
		s = substring(s, 0, p);
	else
		s = "";
	s = draw_TextShortenToWidth(s, me.columnMapSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin * eY + (me.columnTypeOrigin + (me.columnTypeSize - draw_TextWidth(s, 0) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = strcat(ftos(gethostcachenumber(SLIST_FIELD_NUMHUMANS, i)), "/", ftos(gethostcachenumber(SLIST_FIELD_MAXPLAYERS, i)));
	draw_Text(me.realUpperMargin * eY + (me.columnPlayersOrigin + (me.columnPlayersSize - draw_TextWidth(s, 0) * me.realFontSize_x) * 0.5) * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float keyDownNexuizServerList(entity me, float scan, float ascii, float shift)
{
	float i;

	if(scan == K_ENTER)
	{
		ServerList_Connect_Click(NULL, me);
		return 1;
	}
	else if(scan == K_INS)
	{
		i = me.selectedItem;
		if(i < me.nItems)
			ToggleFavorite(me.selectedServer);
	}
	else if(keyDownListBox(me, scan, ascii, shift))
		return 1;
	else if(!me.controlledTextbox)
		return 0;
	else
		return me.controlledTextbox.keyDown(me.controlledTextbox, scan, ascii, shift);
}
#endif
