#ifdef INTERFACE
CLASS(NexuizPlayerSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizPlayerSettingsTab, fill, void(entity))
	ATTRIB(NexuizPlayerSettingsTab, title, string, "Player setup")
	ATTRIB(NexuizPlayerSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizPlayerSettingsTab, rows, float, 22)
	ATTRIB(NexuizPlayerSettingsTab, columns, float, 6.5)
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
void fillNexuizPlayerSettingsTab(entity me)
{
	entity e, pms;
	float i, n;

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Player Name:"));
		me.TD(me, 1, 2, e = makeNexuizInputBox(1, "_cl_name"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Shirt Color:"));
		n = 16 - !cvar("developer");
		for(i = 0; i < n; ++i)
			me.TDNoMargin(me, 1, 2 / n, e = makeNexuizColorButton(1, 0, i), '1 0 0');
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Pants Color:"));
		for(i = 0; i < n; ++i)
			me.TDNoMargin(me, 1, 2 / n, e = makeNexuizColorButton(2, 1, i), '1 0 0');
	me.TR(me);
		pms = makeNexuizPlayerModelSelector();
		me.TD(me, 1, 0.5, e = makeNexuizButton("<<", '0 0 0'));
			e.onClick = PlayerModelSelector_Prev_Click;
			e.onClickEntity = pms;
		me.TD(me, me.rows - me.currentRow - 1, 2.5, pms);
		me.TD(me, 1, 0.5, e = makeNexuizButton(">>", '0 0 0'));
			e.onClick = PlayerModelSelector_Next_Click;
			e.onClickEntity = pms;

	me.gotoXY(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Field of View:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(90, 130, 1, "fov"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Zoom Factor:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(2, 10, 1, "cl_zoomfactor"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Zoom Speed:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(-1, 5, 1, "cl_zoomspeed"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair:"));
		n = 10;
		for(i = 1; i <= n; ++i)
			me.TDNoMargin(me, 1, 2 / n, e = makeNexuizCrosshairButton(3, i), '0 0 0');
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Size:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.10, 1, 0.05, "crosshair_size"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Alpha:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_alpha"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Color Red:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_red"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Color Green:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_green"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Color Blue:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_blue"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Hud Style:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("sbar_hudselector"));
			e.addValue(e, "Old", "0");
			e.addValue(e, "New", "1");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Hud Size:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("viewsize"));
			e.addValue(e, "Disabled", "120");
			e.addValue(e, "Simple", "110");
			e.addValue(e, "Full", "100");
			e.configureNexuizTextSliderValues(e);

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "color -1 -1;name $_cl_name", COMMANDBUTTON_APPLY));
}
#endif
