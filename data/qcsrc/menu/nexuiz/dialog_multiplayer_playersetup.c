#ifdef INTERFACE
CLASS(NexuizPlayerSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizPlayerSettingsTab, fill, void(entity))
	METHOD(NexuizPlayerSettingsTab, draw, void(entity))
	ATTRIB(NexuizPlayerSettingsTab, title, string, "Player Setup")
	ATTRIB(NexuizPlayerSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizPlayerSettingsTab, rows, float, 22)
	ATTRIB(NexuizPlayerSettingsTab, columns, float, 6.5)
	ATTRIB(NexuizPlayerSettingsTab, playerNameLabel, entity, NULL)
	ATTRIB(NexuizPlayerSettingsTab, playerNameLabelAlpha, float, 0)
ENDCLASS(NexuizPlayerSettingsTab)
entity makeNexuizPlayerSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizPlayerSettingsTab()
{
	entity me;
	me = spawnNexuizPlayerSettingsTab();
	me.configureDialog(me);
	return me;
}
void drawNexuizPlayerSettingsTab(entity me)
{
	if(cvar_string("_cl_name") == "Player")
		me.playerNameLabel.alpha = ((mod(time * 2, 2) < 1) ? 1 : 0);
	else
		me.playerNameLabel.alpha = me.playerNameLabelAlpha;
	drawContainer(me);
}
void fillNexuizPlayerSettingsTab(entity me)
{
	entity e, pms, sl, e0, label, e0, box;
	float i, n;

	me.TR(me);
		me.TD(me, 1, 0.5, me.playerNameLabel = makeNexuizTextLabel(0, "Name:"));
			me.playerNameLabelAlpha = me.playerNameLabel.alpha;
		me.TD(me, 1, 2.5, label = makeNexuizTextLabel(0, string_null));
			label.allowCut = 1;
			label.allowColors = 1;
			label.alpha = 1;
	me.TR(me);
		me.TD(me, 1, 3.0, box = makeNexuizInputBox(1, "_cl_name"));
			box.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
			box.maxLength = 63;
			label.textEntity = box;
	me.TR(me);
		me.TD(me, 5, 1, e = makeNexuizColorpicker(box));
		me.TD(me, 5, 2, e = makeNexuizCharmap(box));
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		pms = makeNexuizPlayerModelSelector();
		me.TDempty(me, 0.6);
		me.TD(me, 1, 0.3, e = makeNexuizButton("<<", '0 0 0'));
			e.onClick = PlayerModelSelector_Prev_Click;
			e.onClickEntity = pms;
		me.TD(me, me.rows - me.currentRow - 1, 1.8, pms);
		me.TD(me, 1, 0.3, e = makeNexuizButton(">>", '0 0 0'));
			e.onClick = PlayerModelSelector_Next_Click;
			e.onClickEntity = pms;
	me.gotoRC(me, 8, 0.0);
		me.TD(me, 1, 0.4, e = makeNexuizTextLabel(1, "Model:"));
	me.gotoRC(me, 9, 0.1); me.setFirstColumn(me, me.currentColumn);
		n = 16 - !cvar("developer");
		for(i = 0; i < n; ++i)
		{
			me.gotoRC(me, 8 + i * 0.75, 0.1);
			me.TR(me);
				me.TDNoMargin(me, 1, (2 / n) + 0.05, e = makeNexuizColorButton(1, 0, i), '1 0 0');
		}
	me.gotoRC(me, 9, 0.3); me.setFirstColumn(me, me.currentColumn);
		for(i = 0; i < n; ++i)
		{
			me.gotoRC(me, 8 + i * 0.75, 0.4);
			me.TR(me);
				me.TDNoMargin(me, 1, (2 / n) + 0.05, e = makeNexuizColorButton(2, 1, i), '1 0 0');
		}

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Field of View:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(60, 130, 1, "fov"));
	me.TR(me);
		sl = makeNexuizSlider(0.45, 0.75, 0.01, "cl_bobcycle");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(0, 1, sl, "View bobbing:"));
		me.TD(me, 1, 2, sl);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Zoom Factor:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(2, 16, 0.5, "cl_zoomfactor"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Zoom Sens.:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "cl_zoomsensitivity"));
	me.TR(me);
		sl = makeNexuizSlider(1, 8, 0.5, "cl_zoomspeed");
		me.TD(me, 1, 1, e = makeNexuizSliderCheckBox(-1, 1, sl, "Zoom speed:"));
		me.TD(me, 1, 2, sl);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNexuizButton("Weapon settings...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.weaponsDialog;
		me.TD(me, 1, 1.5, e0 = makeNexuizTextLabel(0, string_null));
			e0.textEntity = main.weaponsDialog;
			e0.allowCut = 1;
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "crosshair_per_weapon", "Per weapon crosshairs"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(1, "crosshair_color_override", "Per weapon crosshair colors"));
		setDependent(e, "crosshair_per_weapon", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair:"));
		for(i = 1; i <= 10; ++i) {
			me.TDNoMargin(me, 1, 2 / 10, e = makeNexuizCrosshairButton(3, i), '0 0 0');
			setDependent(e, "crosshair_per_weapon", 0, 0);
		}
	me.TR(me);
		me.TDempty(me, 1);
		for(i = 11; i <= 20; ++i) {
			me.TDNoMargin(me, 1, 2 / 10, e = makeNexuizCrosshairButton(3, i), '0 0 0');
			setDependent(e, "crosshair_per_weapon", 0, 0);
		}
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Size:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.40, 2, 0.05, "crosshair_size"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Alpha:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_alpha"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Red:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_red"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Green:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_green"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Blue:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_blue"));
		setDependentOR(e, "crosshair_per_weapon", 0, 0, "crosshair_color_override", 1, 1);
	me.TR(me);
	/*
	 * not supported by the current csqc code
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "HUD size:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("viewsize"));
			e.addValue(e, "None", "120");
			e.addValue(e, "Reduced", "110");
			e.addValue(e, "Full", "100");
			e.configureNexuizTextSliderValues(e);
	*/
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(1, "sbar_hudselector", "Use old-style HUD layout"));
			setDependent(e, "viewsize", 0, 110);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 2, e = makeNexuizButton("Radar & Waypoints...", '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.radarDialog;
		me.TDempty(me, 0.5);
	me.TR(me);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "color -1 -1;name \"$_cl_name\";sendcvar cl_weaponpriority;sendcvar cl_zoomfactor;sendcvar cl_zoomspeed;sendcvar cl_autoswitch;sendcvar cl_shownames", COMMANDBUTTON_APPLY));
}
#endif
