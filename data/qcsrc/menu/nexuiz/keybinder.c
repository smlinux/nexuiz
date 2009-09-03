#ifdef INTERFACE
CLASS(NexuizKeyBinder) EXTENDS(NexuizListBox)
	METHOD(NexuizKeyBinder, configureNexuizKeyBinder, void(entity))
	ATTRIB(NexuizKeyBinder, rowsPerItem, float, 1)
	METHOD(NexuizKeyBinder, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizKeyBinder, clickListBoxItem, void(entity, float, vector))
	METHOD(NexuizKeyBinder, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizKeyBinder, setSelected, void(entity, float))
	METHOD(NexuizKeyBinder, keyDown, float(entity, float, float, float))
	METHOD(NexuizKeyBinder, keyGrabbed, void(entity, float, float))

	ATTRIB(NexuizKeyBinder, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizKeyBinder, realUpperMargin, float, 0)
	ATTRIB(NexuizKeyBinder, columnFunctionOrigin, float, 0)
	ATTRIB(NexuizKeyBinder, columnFunctionSize, float, 0)
	ATTRIB(NexuizKeyBinder, columnKeysOrigin, float, 0)
	ATTRIB(NexuizKeyBinder, columnKeysSize, float, 0)

	ATTRIB(NexuizKeyBinder, lastClickedKey, float, -1)
	ATTRIB(NexuizKeyBinder, lastClickedTime, float, 0)
	ATTRIB(NexuizKeyBinder, previouslySelected, float, -1)
	ATTRIB(NexuizKeyBinder, inMouseHandler, float, 0)
	ATTRIB(NexuizKeyBinder, userbindEditButton, entity, NULL)
	ATTRIB(NexuizKeyBinder, keyGrabButton, entity, NULL)
	ATTRIB(NexuizKeyBinder, userbindEditDialog, entity, NULL)
	METHOD(NexuizKeyBinder, editUserbind, void(entity, string, string, string))
ENDCLASS(NexuizKeyBinder)
entity makeNexuizKeyBinder();
void KeyBinder_Bind_Change(entity btn, entity me);
void KeyBinder_Bind_Clear(entity btn, entity me);
void KeyBinder_Bind_Edit(entity btn, entity me);
#endif

#ifdef IMPLEMENTATION

#define MAX_KEYS_PER_FUNCTION 2
#define MAX_KEYBINDS 256
string Nexuiz_KeyBinds_Functions[MAX_KEYBINDS];
string Nexuiz_KeyBinds_Descriptions[MAX_KEYBINDS];
var float Nexuiz_KeyBinds_Count = -1;

void Nexuiz_KeyBinds_Read()
{
	float fh;
	string s;

	Nexuiz_KeyBinds_Count = 0;
	fh = fopen("keybinds.txt", FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 2)
			continue;
		Nexuiz_KeyBinds_Functions[Nexuiz_KeyBinds_Count] = strzone(argv(0));
		Nexuiz_KeyBinds_Descriptions[Nexuiz_KeyBinds_Count] = strzone(argv(1));
		++Nexuiz_KeyBinds_Count;
		if(Nexuiz_KeyBinds_Count >= MAX_KEYBINDS)
			break;
	}
	fclose(fh);
}

entity makeNexuizKeyBinder()
{
	entity me;
	me = spawnNexuizKeyBinder();
	me.configureNexuizKeyBinder(me);
	return me;
}
void configureNexuizKeyBinderNexuizKeyBinder(entity me)
{
	me.configureNexuizListBox(me);
	if(Nexuiz_KeyBinds_Count < 0)
		Nexuiz_KeyBinds_Read();
	me.nItems = Nexuiz_KeyBinds_Count;
	me.setSelected(me, 0);
}
void resizeNotifyNexuizKeyBinder(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);

	me.columnFunctionOrigin = 0;
	me.columnKeysSize = me.realFontSize_x * 12;
	me.columnFunctionSize = 1 - me.columnKeysSize - 2 * me.realFontSize_x;
	me.columnKeysOrigin = me.columnFunctionOrigin + me.columnFunctionSize + me.realFontSize_x;

	if(me.userbindEditButton)
		me.userbindEditButton.disabled = (substring(Nexuiz_KeyBinds_Descriptions[me.selectedItem], 0, 1) != "$");
}
void KeyBinder_Bind_Change(entity btn, entity me)
{
	string func;

	func = Nexuiz_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	me.keyGrabButton.forcePressed = 1;
	keyGrabber = me;
}
void keyGrabbedNexuizKeyBinder(entity me, float key, float ascii)
{
	float n, j, k, nvalid;
	string func;

	me.keyGrabButton.forcePressed = 0;
	if(key == K_ESCAPE)
		return;

	func = Nexuiz_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	n = tokenize(findkeysforcommand(func)); // uses '...' strings
	nvalid = 0;
	for(j = 0; j < n; ++j)
	{
		k = stof(argv(j));
		if(k != -1)
			++nvalid;
	}
	if(nvalid >= MAX_KEYS_PER_FUNCTION)
	{
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
				localcmd("\nunbind \"", keynumtostring(k), "\"\n");
		}
	}
	localcmd("\nbind \"", keynumtostring(key), "\" \"", func, "\"\n");
}
void editUserbindNexuizKeyBinder(entity me, string theName, string theCommandPress, string theCommandRelease)
{
	string func, descr;

	if(!me.userbindEditDialog)
		return;
	
	func = Nexuiz_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;
	
	descr = Nexuiz_KeyBinds_Descriptions[me.selectedItem];
	if(substring(descr, 0, 1) != "$")
		return;
	descr = substring(descr, 1, strlen(descr) - 1);

	// Hooray! It IS a user bind!
	cvar_set(strcat(descr, "_description"), theName);
	cvar_set(strcat(descr, "_press"), theCommandPress);
	cvar_set(strcat(descr, "_release"), theCommandRelease);
}
void KeyBinder_Bind_Edit(entity btn, entity me)
{
	string func, descr;

	if(!me.userbindEditDialog)
		return;
	
	func = Nexuiz_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;
	
	descr = Nexuiz_KeyBinds_Descriptions[me.selectedItem];
	if(substring(descr, 0, 1) != "$")
		return;
	descr = substring(descr, 1, strlen(descr) - 1);

	// Hooray! It IS a user bind!
	me.userbindEditDialog.loadUserBind(me.userbindEditDialog, cvar_string(strcat(descr, "_description")), cvar_string(strcat(descr, "_press")), cvar_string(strcat(descr, "_release")));

	DialogOpenButton_Click(btn, me.userbindEditDialog);
}
void KeyBinder_Bind_Clear(entity btn, entity me)
{
	float n, j, k;
	string func;

	func = Nexuiz_KeyBinds_Functions[me.selectedItem];
	if(func == "")
		return;

	n = tokenize(findkeysforcommand(func)); // uses '...' strings
	for(j = 0; j < n; ++j)
	{
		k = stof(argv(j));
		if(k != -1)
			localcmd("\nunbind \"", keynumtostring(k), "\"\n");
	}

}
void clickListBoxItemNexuizKeyBinder(entity me, float i, vector where)
{
	if(i == me.lastClickedServer)
		if(time < me.lastClickedTime + 0.3)
		{
			// DOUBLE CLICK!
			KeyBinder_Bind_Change(NULL, me);
		}
	me.lastClickedServer = i;
	me.lastClickedTime = time;
}
void setSelectedNexuizKeyBinder(entity me, float i)
{
	// handling of "unselectable" items
	i = floor(0.5 + bound(0, i, me.nItems - 1));
	if(me.pressed == 0 || me.pressed == 1) // keyboard or scrolling - skip unselectable items
	{
		if(i > me.previouslySelected)
		{
			while((i < me.nItems - 1) && (Nexuiz_KeyBinds_Functions[i] == ""))
				++i;
		}
		while((i > 0) && (Nexuiz_KeyBinds_Functions[i] == ""))
			--i;
		while((i < me.nItems - 1) && (Nexuiz_KeyBinds_Functions[i] == ""))
			++i;
	}
	if(me.pressed == 3) // released the mouse - fall back to last valid item
	{
		if(Nexuiz_KeyBinds_Functions[i] == "")
			i = me.previouslySelected;
	}
	if(Nexuiz_KeyBinds_Functions[i] != "")
		me.previouslySelected = i;
	if(me.userbindEditButton)
		me.userbindEditButton.disabled = (substring(Nexuiz_KeyBinds_Descriptions[i], 0, 1) != "$");
	setSelectedListBox(me, i);
}
float keyDownNexuizKeyBinder(entity me, float key, float ascii, float shift)
{
	float r;
	r = 1;
	switch(key)
	{
		case K_ENTER:
		case K_SPACE:
			KeyBinder_Bind_Change(me, me);
			break;
		case K_DEL:
		case K_BACKSPACE:
			KeyBinder_Bind_Clear(me, me);
			break;
		default:
			r = keyDownListBox(me, key, ascii, shift);
			break;
	}
	return r;
}
void drawListBoxItemNexuizKeyBinder(entity me, float i, vector absSize, float isSelected)
{
	string s;
	float j, k, n;
	vector theColor;
	float theAlpha;
	string func, descr;
	float extraMargin;

	descr = Nexuiz_KeyBinds_Descriptions[i];
	func = Nexuiz_KeyBinds_Functions[i];

	if(func == "")
	{
		theAlpha = 1;
		theColor = SKINCOLOR_KEYGRABBER_TITLES;
		theAlpha = SKINALPHA_KEYGRABBER_TITLES;
		extraMargin = 0;
	}
	else
	{
		if(isSelected)
		{
			if(keyGrabber == me)
				draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_WAITING, SKINALPHA_LISTBOX_WAITING);
			else
				draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
		}
		theAlpha = SKINALPHA_KEYGRABBER_KEYS;
		theColor = SKINCOLOR_KEYGRABBER_KEYS;
		extraMargin = me.realFontSize_x * 0.5;
	}

	if(substring(descr, 0, 1) == "$")
	{
		s = substring(descr, 1, strlen(descr) - 1);
		descr = cvar_string(strcat(s, "_description"));
		if(descr == "")
			descr = s;
		if(cvar_string(strcat(s, "_press")) == "")
			if(cvar_string(strcat(s, "_release")) == "")
				theAlpha *= SKINALPHA_DISABLED;
	}

	draw_Text(me.realUpperMargin * eY + extraMargin * eX, descr, me.realFontSize, theColor, theAlpha, 0);
	if(func != "")
	{
		n = tokenize(findkeysforcommand(func)); // uses '...' strings
		s = "";
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
			{
				if(s != "")
					s = strcat(s, ", ");
				s = strcat(s, keynumtostring(k));
			}
		}
		s = draw_TextShortenToWidth(s, me.columnKeysSize, 0, me.realFontSize);
		draw_CenterText(me.realUpperMargin * eY + (me.columnKeysOrigin + 0.5 * me.columnKeysSize) * eX, s, me.realFontSize, theColor, theAlpha, 0);
	}
}
#endif
