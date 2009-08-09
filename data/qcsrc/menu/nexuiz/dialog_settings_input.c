#ifdef INTERFACE
CLASS(NexuizInputSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizInputSettingsTab, fill, void(entity))
	ATTRIB(NexuizInputSettingsTab, title, string, "Input")
	ATTRIB(NexuizInputSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizInputSettingsTab, rows, float, 17)
	ATTRIB(NexuizInputSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizInputSettingsTab)
entity makeNexuizInputSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizInputSettingsTab()
{
	entity me;
	me = spawnNexuizInputSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizInputSettingsTab(entity me)
{
	entity e;
	entity kb;

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizTextLabel(0, "Key bindings:"));
	me.TR(me);
		me.TD(me, me.rows - 2, 3, kb = makeNexuizKeyBinder());
	me.gotoRC(me, me.rows - 1, 0);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizButton("Change key...", '0 0 0'));
			e.onClick = KeyBinder_Bind_Change;
			e.onClickEntity = kb;
			kb.keyGrabButton = e;
		me.TD(me, 1, 1, e = makeNexuizButton("Edit...", '0 0 0'));
			e.onClick = KeyBinder_Bind_Edit;
			e.onClickEntity = kb;
			kb.userbindEditButton = e;
			kb.userbindEditDialog = main.userbindEditDialog;
			main.userbindEditDialog.keybindBox = kb;
		me.TD(me, 1, 1, e = makeNexuizButton("Clear", '0 0 0'));
			e.onClick = KeyBinder_Bind_Clear;
			e.onClickEntity = kb;

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Sensitivity:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1, 32, 0.2, "sensitivity"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "UI mouse speed:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.2, 4.0, 0.1, "menu_mouse_speed"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "m_filter", "Mouse filter"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(1.022, "m_pitch", "Invert mouse"));
	me.TR(me);
		if(cvar_type("joy_enable") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "joy_enable", "Use joystick input"));
		else if(cvar_type("joystick") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "joystick", "Use joystick input"));
	me.TR(me);
		if(cvar_type("vid_dgamouse") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "vid_dgamouse", "Turn off OS mouse acceleration"));
		else if(cvar_type("apple_mouse_noaccel") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "apple_mouse_noaccel", "Turn off OS mouse acceleration"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "con_closeontoggleconsole", "\"enter console\" also closes"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Show binds:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("sbar_showbinds"));
			e.addValue(e, "Actions", "0");
			e.addValue(e, "Bound keys", "1");
			e.addValue(e, "Both", "2");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBoxEx(2, 0, "cl_showpressedkeys", "Show pressed keys"));
}
#endif
