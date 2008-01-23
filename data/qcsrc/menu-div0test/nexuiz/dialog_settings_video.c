#ifdef INTERFACE
CLASS(NexuizVideoSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizVideoSettingsTab, fill, void(entity))
	ATTRIB(NexuizVideoSettingsTab, title, string, "Video")
	ATTRIB(NexuizVideoSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizVideoSettingsTab, rows, float, 15)
	ATTRIB(NexuizVideoSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizVideoSettingsTab)
entity makeNexuizVideoSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizVideoSettingsTab()
{
	entity me;
	me = spawnNexuizVideoSettingsTab();
	me.configureDialog(me);
	return me;
}
void fillNexuizVideoSettingsTab(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Resolution:"));
		me.TD(me, 1, 2, e = makeNexuizResolutionSlider());
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Color depth:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(16, 32, 16, "vid_bitsperpixel"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "vid_fullscreen", "Full screen"));
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "vid_vsync", "Vertical synchronization"));

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_glsl", "Use OpenGL 2.0 shaders (GLSL)"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "gl_vbo", "Use Vertex Buffer Objects (VBO)"));
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNexuizTextLabel(0, "Texture compression"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "0", "None"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "1", "Fast"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "2", "Good"));

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Depth first:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("r_depthfirst"));
			e.addValue(e, "Disabled", "0");
			e.addValue(e, "World", "1");
			e.addValue(e, "All", "2");
			e.configureNexuizTextSliderValues(e);

	me.TR(me);
		if(cvar_defstring("apple_multithreadedgl") != "") // FIXME can this check against string_null too?
			me.TD(me, 1, 3, e = makeNexuizCheckBox(1, "apple_multithreadedgl", "Disable multithreaded OpenGL"));

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "gl_finish", "Wait for GPU to finish each frame"));

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showfps", "Show frames per second"));

	me.gotoXY(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Brightness:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.0, 0.5, 0.02, "v_brightness"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Contrast:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 3.0, 0.05, "v_contrast"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "v_hwgamma", "HW Gamma:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.5, 2.0, 0.05, "v_gamma"));
			setDependent(e, "v_hwgamma", 1, 1);
	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Ambient lighting:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 20.0, 1.0, "r_ambient"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Scene brightness:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.5, 2.0, 0.05, "r_hdr_scenebrightness"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Contrast boost:"));
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 5.0, 0.1, "r_glsl_contrastboost"));
			setDependent(e, "r_glsl", 1, 1);

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "vid_restart", COMMANDBUTTON_APPLY));
}
#endif
