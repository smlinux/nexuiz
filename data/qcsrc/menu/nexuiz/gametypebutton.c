#ifdef INTERFACE
CLASS(NexuizGametypeButton) EXTENDS(RadioButton)
	METHOD(NexuizGametypeButton, configureNexuizGametypeButton, void(entity, float, string, string))
	METHOD(NexuizGametypeButton, setChecked, void(entity, float))
	ATTRIB(NexuizGametypeButton, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizGametypeButton, image, string, SKINGFX_BUTTON_BIG)
	ATTRIB(NexuizGametypeButton, color, vector, SKINCOLOR_BUTTON_N)
	ATTRIB(NexuizGametypeButton, colorC, vector, SKINCOLOR_BUTTON_C)
	ATTRIB(NexuizGametypeButton, colorF, vector, SKINCOLOR_BUTTON_F)
	ATTRIB(NexuizGametypeButton, colorD, vector, SKINCOLOR_BUTTON_D)
	ATTRIB(NexuizGametypeButton, srcMulti, float, 1)
	ATTRIB(NexuizGametypeButton, useDownAsChecked, float, 1)

	ATTRIB(NexuizGametypeButton, cvarName, string, string_null)
	METHOD(NexuizGametypeButton, loadCvars, void(entity))
	METHOD(NexuizGametypeButton, saveCvars, void(entity))

	ATTRIB(NexuizGametypeButton, alpha, float, SKINALPHA_TEXT)
	ATTRIB(NexuizGametypeButton, disabledAlpha, float, SKINALPHA_DISABLED)
ENDCLASS(NexuizGametypeButton)
entity makeNexuizGametypeButton(float, string, string);
#endif

#ifdef IMPLEMENTATION
void GameTypeButton_Click(entity me, entity other);
entity makeNexuizGametypeButton(float theGroup, string theCvar, string theText)
{
	entity me;
	me = spawnNexuizGametypeButton();
	me.configureNexuizGametypeButton(me, theGroup, theCvar, theText);
	return me;
}
void configureNexuizGametypeButtonNexuizGametypeButton(entity me, float theGroup, string theCvar, string theText)
{
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.configureRadioButton(me, theText, me.fontSize, me.image, theGroup, 0);
	me.align = 0.5;
	me.onClick = GameTypeButton_Click;
	me.onClickEntity = NULL;
}
void setCheckedNexuizGametypeButton(entity me, float val)
{
	if(val != me.checked)
	{
		me.checked = val;
		me.saveCvars(me);
	}
}
void loadCvarsNexuizGametypeButton(entity me)
{
	if not(me.cvarName)
		return;

	me.checked = cvar(me.cvarName);
}
void saveCvarsNexuizGametypeButton(entity me)
{
	if not(me.cvarName)
		return;

	cvar_set(me.cvarName, ftos(me.checked));
}
void GameTypeButton_Click(entity me, entity other)
{
	RadioButton_Click(me, other);
	me.parent.gameTypeChangeNotify(me.parent);
}
#endif
