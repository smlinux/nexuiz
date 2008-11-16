#ifdef INTERFACE
CLASS(NexuizPlayerList) EXTENDS(NexuizListBox)
	ATTRIB(NexuizPlayerList, rowsPerItem, float, 1)
	METHOD(NexuizPlayerList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizPlayerList, drawListBoxItem, void(entity, float, vector, float))
	ATTRIB(NexuizPlayerList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizPlayerList, columnNameOrigin, float, 0)
	ATTRIB(NexuizPlayerList, columnNameSize, float, 0)
	ATTRIB(NexuizPlayerList, realUpperMargin, float, 0)
	ATTRIB(NexuizPlayerList, origin, vector, '0 0 0')
	ATTRIB(NexuizPlayerList, itemAbsSize, vector, '0 0 0')
	METHOD(NexuizPlayerList, setPlayerList, void(entity, string))
	METHOD(NexuizPlayerList, getPlayerList, string(entity, float, float))
	ATTRIB(NexuizPlayerList, playerList, float, -1)
ENDCLASS(NexuizPlayerList)
entity makeNexuizPlayerList();
#endif

#ifdef IMPLEMENTATION

#define PLAYERPARM_SCORE 0
#define PLAYERPARM_PING 1
#define PLAYERPARM_NAME 2
#define PLAYERPARM_COUNT 3

entity makeNexuizPlayerList()
{
	entity me;
	me = spawnNexuizPlayerList();
	me.configureNexuizListBox(me);
	return me;
}

void setPlayerListNexuizPlayerList(entity me, string plist)
{
	dprint(plist,"------------\n");

	float buf,i;
	string s;

	buf = buf_create();
	me.nItems = tokenizebyseparator(plist, "\n");
	for(i = 0; i < me.nItems; ++i)
	{
		bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME, argv(i)); // -666 100 "^4Nex ^2Player"
	}

	for(i = 0; i < me.nItems; ++i)
	{
		s = bufstr_get(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME);
		tokenize_sane(s);
		bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_SCORE, argv(0)); // -666
		bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_PING,  argv(1)); // 100
		bufstr_set(buf, i * PLAYERPARM_COUNT + PLAYERPARM_NAME,  argv(2)); // ^4Nex ^2Player
	}
	me.playerList = buf;
}

string getPlayerListNexuizPlayerList(entity me, float i, float key)
{
	return bufstr_get(me.playerList, i * PLAYERPARM_COUNT + key);
}

void resizeNotifyNexuizPlayerList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.itemAbsSize = '0 0 0';
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnNameOrigin = me.realFontSize_x;
	me.columnNameSize = 1 - 2 * me.realFontSize_x;
}

void drawListBoxItemNexuizPlayerList(entity me, float i, vector absSize, float isSelected)
{
	string s;

	s = me.getPlayerList(me, i, PLAYERPARM_NAME);

	s = draw_TextShortenToWidth(s, me.columnNameSize / me.realFontSize_x, 1);
	draw_Text(me.realUpperMargin2 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 1) * me.realFontSize_x)) * eX, s, me.realFontSize, SKINCOLOR_MAPLIST_AUTHOR, 1, 1);
}

#endif
