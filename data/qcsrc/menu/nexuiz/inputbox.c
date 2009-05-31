#ifdef INTERFACE
CLASS(NexuizInputBox) EXTENDS(InputBox)
	METHOD(NexuizInputBox, configureNexuizInputBox, void(entity, float, string))
	METHOD(NexuizInputBox, focusLeave, void(entity))
	METHOD(NexuizInputBox, setText, void(entity, string))
	ATTRIB(NexuizInputBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizInputBox, image, string, SKINGFX_INPUTBOX)
	ATTRIB(NexuizInputBox, onChange, void(entity, entity), SUB_Null)
	ATTRIB(NexuizInputBox, onChangeEntity, entity, NULL)
	ATTRIB(NexuizInputBox, onEnter, void(entity, entity), SUB_Null)
	ATTRIB(NexuizInputBox, onEnterEntity, entity, NULL)
	ATTRIB(NexuizInputBox, marginLeft, float, SKINMARGIN_INPUTBOX_CHARS)
	ATTRIB(NexuizInputBox, marginRight, float, SKINMARGIN_INPUTBOX_CHARS)
	ATTRIB(NexuizInputBox, color, vector, SKINCOLOR_INPUTBOX_N)
	ATTRIB(NexuizInputBox, colorF, vector, SKINCOLOR_INPUTBOX_F)

	ATTRIB(NexuizInputBox, alpha, float, SKINALPHA_TEXT)

	ATTRIB(NexuizInputBox, cvarName, string, string_null)
	METHOD(NexuizInputBox, loadCvars, void(entity))
	METHOD(NexuizInputBox, saveCvars, void(entity))
	METHOD(NexuizInputBox, keyDown, float(entity, float, float, float))
ENDCLASS(NexuizInputBox)
entity makeNexuizInputBox(float, string);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizInputBox(float doEditColorCodes, string theCvar)
{
	entity me;
	me = spawnNexuizInputBox();
	me.configureNexuizInputBox(me, doEditColorCodes, theCvar);
	return me;
}
void configureNexuizInputBoxNexuizInputBox(entity me, float doEditColorCodes, string theCvar)
{
	me.configureInputBox(me, "", 0, me.fontSize, me.image);
	me.editColorCodes = doEditColorCodes;
	if(theCvar)
	{
		me.cvarName = theCvar;
		me.tooltip = getZonedTooltipForIdentifier(theCvar);
		me.loadCvars(me);
	}
	me.cursorPos = strlen(me.text);
}
void focusLeaveNexuizInputBox(entity me)
{
	me.saveCvars(me);
}
void setTextNexuizInputBox(entity me, string new)
{
	if(me.text != new)
	{
		setTextInputBox(me, new);
		me.onChange(me, me.onChangeEntity);
	}
	else
		setTextInputBox(me, new);
}
void loadCvarsNexuizInputBox(entity me)
{
	if not(me.cvarName)
		return;
	setTextInputBox(me, cvar_string(me.cvarName));
}
void saveCvarsNexuizInputBox(entity me)
{
	if not(me.cvarName)
		return;
	cvar_set(me.cvarName, me.text);
}
float keyDownNexuizInputBox(entity me, float key, float ascii, float shift)
{
	float r;
	r = 0;
	if(key == K_ENTER)
	{
		if(me.cvarName)
		{
			me.saveCvars(me);
			r = 1;
		}
		me.onEnter(me, me.onEnterEntity);
	}
	if(keyDownInputBox(me, key, ascii, shift))
		r = 1;
	return r;
}
#endif
