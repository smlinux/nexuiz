#ifdef INTERFACE
CLASS(NexuizModButton) EXTENDS(NexuizButton)
	METHOD(NexuizModButton, configureNexuizModButton, void(entity, string))
	ATTRIB(NexuizModButton, destination, string, string_null)
ENDCLASS(NexuizModButton)
entity makeNexuizModButton(string menu);
void NexuizModButton_Click(entity me, entity other);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizModButton(string menu)
{
	entity me;
	me = spawnNexuizModButton();
	me.configureNexuizModButton(me, menu);
	return me;
}

void NexuizModButton_Click(entity me, entity other)
{
	string thecmd;
	thecmd = strcat("\ndisconnect\nmenu_restart");

	if (me.destination != "")
		thecmd = strcat(thecmd, "\ntogglemenu\ndefer 0.1 \"menu_cmd directmenu ", me.destination,"\"\n");

	if (cvar_string("menu_slist_modfilter") == "havoc")
		thecmd = strcat("\ngamedir data", thecmd);
	else
		thecmd = strcat("\ngamedir havoc", thecmd);
	cmd(thecmd);
}

void configureNexuizModButtonNexuizModButton(entity me, string menu)
{
	me.configureNexuizButton(me, "", '0 0 0');
	me.onClick = NexuizModButton_Click;
	me.onClickEntity = me;
	me.destination = menu;

	if (cvar_string("menu_slist_modfilter") == "havoc")
		me.text = "Switch to Nexuiz mode";
	else
		me.text = "Switch to Havoc mode";
}
#endif
