#ifdef INTERFACE
CLASS(NexuizWeaponsList) EXTENDS(NexuizListBox)
	METHOD(NexuizWeaponsList, configureNexuizWeaponsList, void(entity))
	METHOD(NexuizWeaponsList, toString, string(entity))
	ATTRIB(NexuizWeaponsList, rowsPerItem, float, 1)
	METHOD(NexuizWeaponsList, draw, void(entity))
	METHOD(NexuizWeaponsList, drawListBoxItem, void(entity, float, vector, float))
	METHOD(NexuizWeaponsList, resizeNotify, void(entity, vector, vector, vector, vector))
	METHOD(NexuizWeaponsList, keyDown, float(entity, float, float, float))
	ATTRIB(NexuizWeaponsList, realFontSize, vector, '0 0 0')
	ATTRIB(NexuizWeaponsList, realUpperMargin, float, 0)
	METHOD(NexuizWeaponsList, mouseDrag, float(entity, vector))
	ATTRIB(NexuizWeaponsList, scrollbarWidth, float, 0)
ENDCLASS(NexuizWeaponsList)
entity makeNexuizWeaponsList();
void WeaponsList_MoveUp_Click(entity btn, entity me);
void WeaponsList_MoveDown_Click(entity box, entity me);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizWeaponsList()
{
	entity me;
	me = spawnNexuizWeaponsList();
	me.configureNexuizWeaponsList(me);
	return me;
}
void configureNexuizWeaponsListNexuizWeaponsList(entity me)
{
	me.configureNexuizListBox(me);
}
void drawNexuizWeaponsList(entity me)
{
	// read in cvar?
	string s, t;
	s = cvar_string("cl_weaponpriority");
	t = fixPriorityList(s, WEP_FIRST, WEP_LAST, 1);
	if(t != s)
	{
		print("AUTOFIXED\n");
		cvar_set("cl_weaponpriority", t);
	}
	me.nItems = tokenize_sane(t);
	drawListBox(me);
}
void WeaponsList_MoveUp_Click(entity box, entity me)
{
	if(me.selectedItem > 0)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem - 1, me.selectedItem));
		me.selectedItem -= 1;
	}
}
void WeaponsList_MoveDown_Click(entity box, entity me)
{
	if(me.selectedItem < me.nItems - 1)
	{
		cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem, me.selectedItem + 1));
		me.selectedItem += 1;
	}
}
void resizeNotifyNexuizWeaponsList(entity me, vector relOrigin, vector relSize, vector absOrigin, vector absSize)
{
	resizeNotifyNexuizListBox(me, relOrigin, relSize, absOrigin, absSize);

	me.realFontSize_y = me.fontSize / (absSize_y * me.itemHeight);
	me.realFontSize_x = me.fontSize / (absSize_x * (1 - me.controlWidth));
	me.realUpperMargin = 0.5 * (1 - me.realFontSize_y);
}
float mouseDragNexuizWeaponsList(entity me, vector pos)
{
	float f, i;
	i = me.selectedItem;
	f = mouseDragListBox(me, pos);
	if(me.selectedItem != i)
		cvar_set("cl_weaponpriority", swapInPriorityList(cvar_string("cl_weaponpriority"), me.selectedItem, i));
	return f;
}
string WeaponName(float w)
{
	switch(w)
	{
		//%weaponaddpoint
		case WEP_LASER:            return "Laser";
		case WEP_SHOTGUN:          return "Shotgun";
		case WEP_UZI:              return "Machine Gun";
		case WEP_GRENADE_LAUNCHER: return "Mortar";
		case WEP_ELECTRO:          return "Electro";
		case WEP_CRYLINK:          return "Crylink";
		case WEP_NEX:              return "Nex";
		case WEP_HAGAR:            return "Hagar";
		case WEP_ROCKET_LAUNCHER:  return "Rocket Launcher";
		case WEP_PORTO:            return "Port-O-Launch";
		case WEP_MINSTANEX:        return "MinstaNex";
		default:                   return "(fix qcsrc/menu/nexuiz/weaponslist.c)";
	}
}
string toStringNexuizWeaponsList(entity me)
{
	float n, i;
	string s;
	n = tokenize_sane(cvar_string("cl_weaponpriority"));
	s = "";
	for(i = 0; i < n; ++i)
		s = strcat(s, WeaponName(stof(argv(i))), ", ");
	return substring(s, 0, strlen(s) - 2);
}
void drawListBoxItemNexuizWeaponsList(entity me, float i, vector absSize, float isSelected)
{
	if(isSelected)
		draw_Fill('0 0 0', '1 1 0', SKINCOLOR_LISTBOX_SELECTED, SKINALPHA_LISTBOX_SELECTED);
	draw_Text(me.realUpperMargin * eY, WeaponName(stof(argv(i))), me.realFontSize, '1 1 1', SKINALPHA_TEXT, 0);
}

float keyDownNexuizWeaponsList(entity me, float scan, float ascii, float shift)
{
	if(ascii == 43) // +
	{
		WeaponsList_MoveUp_Click(NULL, me);
		return 1;
	}
	else if(scan == 45) // -
	{
		WeaponsList_MoveDown_Click(NULL, me);
		return 1;
	}
	else if(keyDownListBox(me, scan, ascii, shift))
		return 1;
	return 0;
}
#endif
