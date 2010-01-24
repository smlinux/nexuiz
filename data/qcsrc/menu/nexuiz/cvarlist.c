#ifdef INTERFACE
CLASS(NexuizCvarList) EXTENDS(NexuizListBox)
	METHOD(NexuizCvarList, configureNexuizCvarList, void(entity))
	ATTRIB(NexuizCvarList, rowsPerItem, float, 1)
	METHOD(NexuizCvarList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizCvarList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizCvarList, keyDown, float(entity, float, float, float))

	METHOD(NexuizCvarList, destroy, void(entity))

	ATTRIB(NexuizCvarList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizCvarList, realUpperMargin, float, 0)
	ATTRIB(NexuizCvarList, columnNameOrigin, float, 0)
	ATTRIB(NexuizCvarList, columnNameSize, float, 0)
	ATTRIB(NexuizCvarList, columnValueOrigin, float, 0)
	ATTRIB(NexuizCvarList, columnValueSize, float, 0)

	METHOD(NexuizCvarList, setSelected, void(entity, float))
	ATTRIB(NexuizCvarList, controlledTextbox, entity, NULL)
	ATTRIB(NexuizCvarList, cvarNameBox, entity, NULL)
	ATTRIB(NexuizCvarList, cvarDescriptionBox, entity, NULL)
	ATTRIB(NexuizCvarList, cvarTypeBox, entity, NULL)
	ATTRIB(NexuizCvarList, cvarValueBox, entity, NULL)
	ATTRIB(NexuizCvarList, cvarDefaultBox, entity, NULL)

	ATTRIB(NexuizCvarList, handle, float, -1)
	ATTRIB(NexuizCvarList, cvarName, string, string_null)
	ATTRIB(NexuizCvarList, cvarDescription, string, string_null)
	ATTRIB(NexuizCvarList, cvarType, string, string_null)
	ATTRIB(NexuizCvarList, cvarDefault, string, string_null)
ENDCLASS(NexuizCvarList)
entity makeNexuizCvarList();
void CvarList_Filter_Change(entity box, entity me);
void CvarList_Value_Change(entity box, entity me);
void CvarList_Revert_Click(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizCvarList()
{
	entity me;
	me = spawnNexuizCvarList();
	me.configureNexuizCvarList(me);
	return me;
}
void configureNexuizCvarListNexuizCvarList(entity me)
{
	me.configureNexuizListBox(me);

	me.handle = buf_create();
	buf_cvarlist(me.handle, "", "_");
	me.nItems = buf_getsize(me.handle);
}
void destroyNexuizCvarList(entity me)
{
	buf_del(me.handle);
}
void setSelectedNexuizCvarList(entity me, float i)
{
	string s;

	setSelectedListBox(me, i);
	if(me.nItems == 0)
		return;
	
	if(me.cvarName)
		strunzone(me.cvarName);
	if(me.cvarDescription)
		strunzone(me.cvarDescription);
	if(me.cvarType)
		strunzone(me.cvarType);
	if(me.cvarDefault)
		strunzone(me.cvarDefault);
	me.cvarName = strzone(bufstr_get(me.handle, me.selectedItem));
	me.cvarDescription = strzone(cvar_description(me.cvarName));
	me.cvarDefault = strzone(cvar_defstring(me.cvarName));

	float t;
	t = cvar_type(me.cvarName);
	me.cvarType = "";
	if(t & CVAR_TYPEFLAG_SAVED)
		me.cvarType = strcat(me.cvarType, ", will be saved to config.cfg");
	else
		me.cvarType = strcat(me.cvarType, ", will not be saved");
	if(t & CVAR_TYPEFLAG_PRIVATE)
		me.cvarType = strcat(me.cvarType, ", private");
	if(t & CVAR_TYPEFLAG_ENGINE)
		me.cvarType = strcat(me.cvarType, ", engine setting");
	if(t & CVAR_TYPEFLAG_READONLY)
		me.cvarType = strcat(me.cvarType, ", read only");
	me.cvarType = strzone(substring(me.cvarType, 2, strlen(me.cvarType) - 2));

	me.cvarNameBox.setText(me.cvarNameBox, me.cvarName);
	me.cvarDescriptionBox.setText(me.cvarDescriptionBox, me.cvarDescription);
	me.cvarTypeBox.setText(me.cvarTypeBox, me.cvarType);
	me.cvarDefaultBox.setText(me.cvarDefaultBox, me.cvarDefault);

	// this one can handle tempstrings
	s = cvar_string(me.cvarName);
	me.cvarValueBox.setText(me.cvarValueBox, s);
	me.cvarValueBox.cursorPos = strlen(s);
}
void CvarList_Filter_Change(entity box, entity me)
{
	buf_cvarlist(me.handle, box.text, "_");
	me.nItems = buf_getsize(me.handle);

	me.setSelected(me, 0);
}
void resizeNotifyNexuizCvarList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnNameOrigin = 0;
	me.columnValueSize = me.realFontSize_x * 20;
	me.columnNameSize = 1 - me.columnValueSize - me.realFontSize_x;
	me.columnValueOrigin = me.columnNameOrigin + me.columnNameSize + me.realFontSize_x;

	me.setSelected(me, me.selectedItem);
}
void drawListBoxItemNexuizCvarList(entity me, float i, vector absSize, float isSelected)
{
	string k, v, d;
	float t;

	vector theColor;
	float theAlpha;

	string s;

	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	
	k = bufstr_get(me.handle, i);

	v = cvar_string(k);
	d = cvar_defstring(k);
	t = cvar_type(k);
	if(t & CVAR_TYPEFLAG_SAVED)
		theAlpha = SKINALPHA_CVARLIST_SAVED;
	else
		theAlpha = SKINALPHA_CVARLIST_TEMPORARY;
	if(v == d)
		theColor = SKINCOLOR_CVARLIST_UNCHANGED;
	else
		theColor = SKINCOLOR_CVARLIST_CHANGED;

	s = draw_TextShortenToWidth(k, me.columnNameSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + me.columnNameOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
	s = draw_TextShortenToWidth(v, me.columnValueSize, 0, me.realFontSize);
	draw_Text(me.realUpperMargin * eY + me.columnValueOrigin * eX, s, me.realFontSize, theColor, theAlpha, 0);
}

float keyDownNexuizCvarList(entity me, float scan, float ascii, float shift)
{
	if(keyDownListBox(me, scan, ascii, shift))
		return 1;
	else if(!me.controlledTextbox)
		return 0;
	else
		return me.controlledTextbox.keyDown(me.controlledTextbox, scan, ascii, shift);
}

void CvarList_Value_Change(entity box, entity me)
{
	cvar_set(me.cvarNameBox.text, box.text);
}

void CvarList_Revert_Click(entity btn, entity me)
{
	me.cvarValueBox.setText(me.cvarValueBox, me.cvarDefault);
	me.cvarValueBox.cursorPos = strlen(me.cvarDefault);
}
#endif
