#ifdef INTERFACE
CLASS(NexuizCampaignList) EXTENDS(NexuizListBox)
	METHOD(NexuizCampaignList, configureNexuizCampaignList, void(entity))
	ATTRIB(NexuizCampaignList, rowsPerItem, float, 10)
	METHOD(NexuizCampaignList, draw, void(entity))
	METHOD(NexuizCampaignList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizCampaignList, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizCampaignList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizCampaignList, setSelected, void(entity, float))

	ATTRIB(NexuizCampaignList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizCampaignList, columnPreviewOrigin, float, 0)
	ATTRIB(NexuizCampaignList, columnPreviewSize, float, 0)
	ATTRIB(NexuizCampaignList, columnNameOrigin, float, 0)
	ATTRIB(NexuizCampaignList, columnNameSize, float, 0)
	ATTRIB(NexuizCampaignList, columnCheckMarkOrigin, float, 0)
	ATTRIB(NexuizCampaignList, columnCheckMarkSize, float, 0)
	ATTRIB(NexuizCampaignList, checkMarkOrigin, vector, '0 0 0')
	ATTRIB(NexuizCampaignList, checkMarkSize, vector, '0 0 0')
	ATTRIB(NexuizCampaignList, realUpperMargin1, float, 0)
	ATTRIB(NexuizCampaignList, realUpperMargin2, float, 0)

	ATTRIB(NexuizCampaignList, lastClickedMap, float, -1)
	ATTRIB(NexuizCampaignList, lastClickedTime, float, 0)

	ATTRIB(NexuizCampaignList, origin, vector, '0 0 0')
	ATTRIB(NexuizCampaignList, itemAbsSize, vector, '0 0 0')
	ATTRIB(NexuizCampaignList, emptyLineHeight, float, 0.5)

	ATTRIB(NexuizCampaignList, campaignIndex, float, 0)
	ATTRIB(NexuizCampaignList, cvarName, string, string_null)
	METHOD(NexuizCampaignList, loadCvars, void(entity))
	METHOD(NexuizCampaignList, saveCvars, void(entity))
ENDCLASS(NexuizCampaignList)
entity makeNexuizCampaignList();
void CampaignList_LoadMap(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
string campaign_longdesc_wrapped[CAMPAIGN_MAX_ENTRIES];

void rewrapCampaign(float w, float l0, float emptyheight)
{
	float i, j;
	float n, take, cantake, l;
	string r, s;
	for(i = 0; i < campaign_entries; ++i)
	{
		l = l0;
		if(campaign_longdesc_wrapped[i])
			strunzone(campaign_longdesc_wrapped[i]);
		n = tokenizebyseparator(campaign_longdesc[i], "\n");
		r = "";
		for(j = 0; j < n; ++j)
		{
			s = argv(j);
			if(s == "")
			{
				l -= emptyheight;
				r = strcat(r, "\n");
				continue;
			}
			for(;;)
			{
				cantake = draw_TextLengthUpToWidth(s, w, 0);
				if(cantake > 0 && cantake < strlen(s))
				{
					take = cantake - 1;
					while(take > 0 && substring(s, take, 1) != " ")
						--take;
					if(take == 0)
					{
						if(--l < 0) goto toolong;
						r = strcat(r, substring(s, 0, cantake), "\n");
						s = substring(s, cantake, strlen(s) - cantake);
					}
					else
					{
						if(--l < 0) goto toolong;
						r = strcat(r, substring(s, 0, take), "\n");
						s = substring(s, take + 1, strlen(s) - take);
					}
				}
				else
				{
					if(--l < 0) goto toolong;
					r = strcat(r, s, "\n");
					break;
				}
			}
		}
		goto nottoolong;
:toolong
		while(substring(r, strlen(r) - 1, 1) == "\n")
			r = substring(r, 0, strlen(r) - 1);
		r = strcat(r, "...\n");
:nottoolong
		campaign_longdesc_wrapped[i] = strzone(substring(r, 0, strlen(r) - 1));
	}
}

entity makeNexuizCampaignList()
{
	entity me;
	me = spawnNexuizCampaignList();
	me.configureNexuizCampaignList(me);
	return me;
}
void configureNexuizCampaignListNexuizCampaignList(entity me)
{
	me.configureNexuizListBox(me);
	me.loadCvars(me);
}

void loadCvarsNexuizCampaignList(entity me)
{
	// read campaign cvars
	if(campaign_name)
		strunzone(campaign_name);
	if(me.cvarName)
		strunzone(me.cvarName);
	campaign_name = strzone(cvar_string("g_campaign_name"));
	me.cvarName = strzone(strcat("g_campaign", campaign_name, "_index"));
	CampaignFile_Load(0, CAMPAIGN_MAX_ENTRIES);
	me.campaignIndex = bound(0, cvar(me.cvarName), campaign_entries);
	cvar_set(me.cvarName, ftos(me.campaignIndex));
	if(me.columnNameSize)
		rewrapCampaign(me.columnNameSize / me.realFontSize_x, me.rowsPerItem - 3, me.emptyLineHeight);
	me.nItems = min(me.campaignIndex + 2, campaign_entries);
	me.selectedItem = min(me.campaignIndex, me.nItems - 1);
	me.scrollPos = me.nItems * me.itemHeight - 1;
}

void saveCvarsNexuizCampaignList(entity me)
{
	// write campaign cvars
	cvar_set("g_campaign_name", campaign_name);
	// cvar_set(me.cvarName, ftos(me.campaignIndex)); // NOTE: only server QC does that!
}

void drawNexuizCampaignList(entity me)
{
	if(cvar(me.cvarName) != me.campaignIndex || cvar_string("g_campaign_name") != campaign_name)
		me.loadCvars(me);
	drawListBox(me);
}

void resizeNotifyNexuizCampaignList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	me.origin = absOrigin;
	me.itemAbsSize = '0 0 0';
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (me.itemAbsSize_y = (absSize_y * me.itemHeight));
	me.realFontSize_x = me.fontSize / (me.itemAbsSize_x = (absSize_x * (1 - me.controlWidth)));
	me.realUpperMargin1 = 0.5 * me.realFontSize_y;
	me.realUpperMargin2 = me.realUpperMargin1 + 2 * me.realFontSize_y;

	me.checkMarkSize = (eX * (me.itemAbsSize_y / me.itemAbsSize_x) + eY) * 0.5;

	me.columnPreviewOrigin = 0;
	me.columnPreviewSize = me.itemAbsSize_y / me.itemAbsSize_x * 4 / 3;
	me.columnCheckMarkSize = me.checkMarkSize_x;
	me.columnNameSize = 1 - me.columnPreviewSize - me.columnCheckMarkSize - 4 * me.realFontSize_x;
	me.columnNameOrigin = me.columnPreviewOrigin + me.columnPreviewSize + me.realFontSize_x;
	me.columnCheckMarkOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x * 2;

	me.checkMarkOrigin = eY + eX * (me.columnCheckMarkOrigin + me.columnCheckMarkSize) - me.checkMarkSize;

	rewrapCampaign(me.columnNameSize / me.realFontSize_x, me.rowsPerItem - 3, me.emptyLineHeight);
}
void clickListBoxItemNexuizCampaignList(entity me, float i, vector where)
{
	if(i == me.lastClickedMap)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			// start game
			CampaignList_LoadMap(me, me);
			return;
		}
	me.lastClickedMap = i;
	me.lastClickedTime = time;
}
void drawListBoxItemNexuizCampaignList(entity me, float i, vector absSize, float isSelected)
{
	string s;
	float p;
	vector theColor;
	float theAlpha;
	float done;
	float j, n;
	vector o;

	if(i < me.campaignIndex)
	{
		theAlpha = 1;
		theColor = '1 1 1';
	}
	else if(i == me.campaignIndex)
	{
		theAlpha = 1;
		theColor = '1 1 0';
	}
	else
	{
		theAlpha = 0.2;
		theColor = '1 1 1';
	}

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', '0 0 1', 0.5);

	s = ftos(p);
	draw_Picture(me.columnPreviewOrigin * eX, strcat("/maps/", campaign_mapname[i]), me.columnPreviewSize * eX + eY, '1 1 1', theAlpha);
	if(i < me.campaignIndex)
		draw_Picture(me.checkMarkOrigin, "checkmark", me.checkMarkSize, '1 1 1', 1);
	if(i <= me.campaignIndex)
		s = campaign_shortdesc[i]; // fteqcc sucks
	else
		s = "???";
	s = draw_TextShortenToWidth(strcat("Level ", ftos(i + 1), ": ", s), me.columnNameSize / me.realFontSize_x, 0);
	draw_Text(me.realUpperMargin1 * eY + (me.columnNameOrigin + 0.00 * (me.columnNameSize - draw_TextWidth(s, 0) * me.realFontSize_x)) * eX, s, me.realFontSize, theColor, theAlpha, 0);

	if(i <= me.campaignIndex)
	{
		s = campaign_longdesc_wrapped[i];
		n = tokenizebyseparator(s, "\n");
		o = me.realUpperMargin2 * eY + me.columnNameOrigin * eX;
		for(j = 0; j < n; ++j)
			if(argv(j) != "")
			{
				draw_Text(o, argv(j), me.realFontSize, theColor, theAlpha * 0.7, 0);
				o_y += me.realFontSize_y;
			}
			else
				o_y += me.realFontSize_y * me.emptyLineHeight;
	}
}
void CampaignList_LoadMap(entity btn, entity me)
{
	if(me.selectedItem >= me.nItems || me.selectedItem < 0)
		return;
	CampaignSetup(me.selectedItem);
}

void setSelectedNexuizCampaignList(entity me, float i)
{
	// prevent too late items from being played
	setSelectedListBox(me, min(i, me.campaignIndex));
}
#endif
