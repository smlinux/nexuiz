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
		me.TD(me, 1, 1.5, e = makeNexuizTextLabel(0, "Vertex Buffer Objects (VBOs)"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeNexuizRadioButton(1, "gl_vbo", "0", "Off"));
		me.TD(me, 1, 2.1, e = makeNexuizRadioButton(1, "gl_vbo", "1", "Vertex and Triangles"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeNexuizRadioButton(1, "gl_vbo", "2", "Vertex only"));
		me.TD(me, 1, 2.1, e = makeNexuizRadioButton(1, "gl_vbo", "3", "Vertex, some Triangles (compatible)"));
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNexuizTextLabel(0, "Texture compression"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "0", "None"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "1", "Fast"));
		me.TD(me, 1, 0.5, e = makeNexuizRadioButton(1, "gl_texturecompression", "2", "Good"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBoxEx(4, 1, "vid_samples", "Use 4x multisampling"));

	me.TR(me);
		if(cvar_type("apple_multithreadedgl") & CVAR_TYPEFLAG_ENGINE)
			me.TD(me, 1, 3, e = makeNexuizCheckBox(1, "apple_multithreadedgl", "Disable multithreaded OpenGL"));

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "gl_finish", "Wait for GPU to finish each frame"));

	me.gotoRC(me, 0, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Brightness:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.0, 0.5, 0.02, "v_brightness"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Contrast:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 3.0, 0.05, "v_contrast"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Gamma:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.5, 2.0, 0.05, "v_gamma"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Contrast boost:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(1.0, 5.0, 0.1, "v_contrastboost"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "v_glslgamma", "Use GLSL to handle color control"));
			setDependent(e, "r_glsl", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Ambient lighting:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 20.0, 1.0, "r_ambient"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Scene brightness:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.5, 2.0, 0.05, "r_hdr_scenebrightness"));

	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Depth first:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("r_depthfirst"));
			e.addValue(e, "Disabled", "0");
			e.addValue(e, "World", "1");
			e.addValue(e, "All", "2");
			e.configureNexuizTextSliderValues(e);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "vid_restart", COMMANDBUTTON_APPLY));
}
#endif
