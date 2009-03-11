#ifdef INTERFACE
CLASS(NexuizModButton) EXTENDS(NexuizButton)
	METHOD(NexuizModButton, configureNexuizModButton, void(entity))
ENDCLASS(NexuizModButton)
entity makeNexuizModButton();
void NexuizModButton_Click(entity me, entity other);
#endif

#ifdef IMPLEMENTATION
entity makeNexuizModButton()
{
	entity me;
	me = spawnNexuizModButton();
	me.configureNexuizModButton(me);
	return me;
}

void NexuizModButton_Click(entity me, entity other)
{
	if (cvar_string("menu_slist_modfilter") == "havoc")
		cmd("gamedir data; menu_restart");
	else
		cmd("gamedir havoc; menu_restart");
}

void configureNexuizModButtonNexuizModButton(entity me)
{
	me.configureNexuizButton(me, "", '0 0 0');
	me.onClick = NexuizModButton_Click;
	me.onClickEntity = me;

	if (cvar_string("menu_slist_modfilter") == "havoc")
		me.text = "Switch to Nexuiz mode";
	else
		me.text = "Switch to Havoc mode";
}
#endif
