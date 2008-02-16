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
	entity e, pms, sl;
	float i, n;

	me.TR(me);
		me.TD(me, 1, 1, me.playerNameLabel = makeNexuizTextLabel(0, "Player Name:"));
			me.playerNameLabelAlpha = me.playerNameLabel.alpha;
		me.TD(me, 1, 2, e = makeNexuizInputBox(1, "_cl_name"));
			e.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
	me.TR(me);
		me.TDempty(me, 1);
		me.TD(me, 5, 2, e = makeNexuizCharmap(e));
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
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
		me.TD(me, 1, 0.3, e = makeNexuizButton("<<", '0 0 0'));
			e.onClick = PlayerModelSelector_Prev_Click;
			e.onClickEntity = pms;
		me.TD(me, me.rows - me.currentRow - 1, 2.4, pms);
		me.TD(me, 1, 0.3, e = makeNexuizButton(">>", '0 0 0'));
			e.onClick = PlayerModelSelector_Next_Click;
			e.onClickEntity = pms;

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Field of View:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(60, 130, 1, "fov"));
	me.TR(me);

		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Zoom Factor:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(2, 16, 0.5, "cl_zoomfactor"));
	me.TR(me);
		sl = makeNexuizSlider(1, 8, 0.5, "cl_zoomspeed");
		me.TD(me, 1, 2.8, e = makeNexuizSliderCheckBox(-1, 1, sl, "Zoom speed:"));
		me.TD(me, 1, 2, sl);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_autoswitch", "Auto switch weapons on pickup"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair:"));
		n = 10;
		for(i = 1; i <= n; ++i)
			me.TDNoMargin(me, 1, 2 / n, e = makeNexuizCrosshairButton(3, i), '0 0 0');
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Size:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.40, 2, 0.05, "crosshair_size"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Alpha:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_alpha"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Red:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_red"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Green:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_green"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Crosshair Blue:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 1, 0.01, "crosshair_color_blue"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "HUD size:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("viewsize"));
			e.addValue(e, "None", "120");
			e.addValue(e, "Reduced", "110");
			e.addValue(e, "Full", "100");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(1, "sbar_hudselector", "Use alternate HUD layout"));
			setDependent(e, "viewsize", 0, 110);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Show names:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_shownames"));
			e.addValue(e, "Never", "0");
			e.addValue(e, "Team games", "1");
			e.addValue(e, "Always", "2");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Show waypoints:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_hidewaypoints"));
			e.addValue(e, "Players", "1");
			e.addValue(e, "All", "0");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Network speed:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("_cl_rate"));
			e.addValue(e, "56k", "4000");
			e.addValue(e, "ISDN", "7000");
			e.addValue(e, "Slow ADSL", "15000");
			e.addValue(e, "Fast ADSL", "20000");
			e.addValue(e, "Broadband", "25000");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Client UDP port:"));
		me.TD(me, 1, 0.5, e = makeNexuizInputBox(0, "cl_port"));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "color -1 -1;name $_cl_name;sendcvar cl_zoomfactor;sendcvar cl_zoomspeed;sendcvar cl_autoswitch;rate $_cl_rate", COMMANDBUTTON_APPLY));
}
#endif
