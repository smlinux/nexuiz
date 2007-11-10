#ifdef INTERFACE
CLASS(NexuizInputBox) EXTENDS(InputBox)
	METHOD(NexuizInputBox, configureNexuizInputBox, void(entity, float, string))
	METHOD(NexuizInputBox, focusLeave, void(entity))
	METHOD(NexuizInputBox, setText, void(entity, string))
	ATTRIB(NexuizInputBox, fontSize, float, SKINFONTSIZE_NORMAL)
	ATTRIB(NexuizInputBox, image, string, SKINGFX_INPUTBOX)
	ATTRIB(NexuizInputBox, onChange, void(entity, entity), SUB_Null)
	ATTRIB(NexuizInputBox, onChangeEntity, entity, NULL)

	ATTRIB(NexuizInputBox, cvarName, string, string_null)
	METHOD(NexuizInputBox, loadCvars, void(entity))
	METHOD(NexuizInputBox, saveCvars, void(entity))
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
		me.loadCvars(me);
	}
	me.cursorPos = strlen(me.text);
}
void focusLeaveNexuizInputBox(entity me)
{
	if(me.cvarName)
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
	setTextInputBox(me, cvar_string(me.cvarName));
}
void saveCvarsNexuizInputBox(entity me)
{
	cvar_set(me.cvarName, me.text);
}
#endif
