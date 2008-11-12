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
	string s, ch, ch2;
	float maxTextLen, textLen;
	float j;
	vector theOrigin, theSize, theColor;
	float theAlpha;
	float brightness;


	s = me.getPlayerList(me, i, PLAYERPARM_NAME);
	maxTextLen = strlen(draw_TextShortenToWidth(strdecolorize(s), 0.95 * me.columnNameSize / me.realFontSize_x, 0));
	brightness = cvar("r_textbrightness");
	theOrigin = me.realUpperMargin * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX ;
	theSize = me.realFontSize;
	theColor = '1 1 1';
	theAlpha = 1;

	for(j = 0; j < strlen(s); ++j)
	{
		ch = substring(s, j, 1);
		if(ch == "^")
		{
			ch2 = substring(s, j+1, 1);
			if(ch2 == "0" || stof(ch2))// digit?
			{
				switch(stof(ch2))
				{
					case 0: theColor = '0 0 0'; theAlpha = 1; break;
					case 1: theColor = '1 0 0'; theAlpha = 1; break;
					case 2: theColor = '0 1 0'; theAlpha = 1; break;
					case 3: theColor = '1 1 0'; theAlpha = 1; break;
					case 4: theColor = '0 0 1'; theAlpha = 1; break;
					case 5: theColor = '0 1 1'; theAlpha = 1; break;
					case 6: theColor = '1 0 1'; theAlpha = 1; break;
					case 7: theColor = '1 1 1'; theAlpha = 1; break;
					case 8: theColor = '1 1 1'; theAlpha = 0.5; break;
					case 9: theColor = '0.5 0.5 0.5'; theAlpha = 1; break;
				}
				theColor = theColor * (1 - brightness) + brightness * '1 1 1';
				++j;
				continue;
			}
		}

		if (textLen < maxTextLen)
		{
			draw_Text(theOrigin, ch, theSize, theColor, theAlpha, 0);
			theOrigin += eX * draw_TextWidth(ch, 0) * me.realFontSize_x;
			++textLen;
		}
		else
		{
			draw_Text(theOrigin, "...", theSize, theColor, theAlpha, 0);
			break;
		}
	}
}

#endif
