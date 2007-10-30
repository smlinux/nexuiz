#ifdef INTERFACE
CLASS(NexuizVideoSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizVideoSettingsTab, fill, void(entity))
	ATTRIB(NexuizVideoSettingsTab, title, string, "Settings")
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
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Resolution:"));
		me.TD(me, 1, 2, makeNexuizResolutionSlider());
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Color depth:"));
		me.TD(me, 1, 2, makeNexuizSlider(16, 32, 16, "vid_bitsperpixel"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizCheckBox(0, "vid_fullscreen", "Full screen"));
		me.TD(me, 1, 2, makeNexuizCheckBox(0, "vid_vsync", "Vertical synchronization"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Anisotropy:"));
		me.TD(me, 1, 0.4, makeNexuizRadioButton(1, "gl_texture_anisotropy", "1", "Off"));
		me.TD(me, 1, 0.4, makeNexuizRadioButton(1, "gl_texture_anisotropy", "2", "2x"));
		me.TD(me, 1, 0.4, makeNexuizRadioButton(1, "gl_texture_anisotropy", "4", "4x"));
		me.TD(me, 1, 0.4, makeNexuizRadioButton(1, "gl_texture_anisotropy", "8", "8x"));
		me.TD(me, 1, 0.4, makeNexuizRadioButton(1, "gl_texture_anisotropy", "16", "16x"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Texture quality:"));
		me.TD(me, 1, 2, makeNexuizPicmipSlider());
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, makeNexuizCheckBox(1, "r_picmipworld", "Reduce model texture quality only"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, makeNexuizCheckBox(0, "r_glsl", "Use OpenGL 2.0 shaders (GLSL)"));
	me.TR(me);
		me.TD(me, 1, 3, makeNexuizCheckBox(0, "gl_vbo", "Use Vertex Buffer Objects (VBO)"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, makeNexuizCheckBox(0, "showfps", "Show frames per second"));

	me.gotoXY(me, -1, 0);
	me.setFirstColumn(me, 3.5);
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Brightness:"));
		me.TD(me, 1, 2, makeNexuizSlider(0.0, 0.5, 0.02, "v_brightness"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Contrast:"));
		me.TD(me, 1, 2, makeNexuizSlider(1.0, 3.0, 0.05, "v_contrast"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizCheckBox(0, "v_hwgamma", "HW Gamma:"));
		me.TD(me, 1, 2, makeNexuizSlider(0.5, 2.0, 0.05, "v_gamma"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Ambient lighting:"));
		me.TD(me, 1, 2, makeNexuizSlider(0, 20.0, 1.0, "r_ambient"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Scene brightness:"));
		me.TD(me, 1, 2, makeNexuizSlider(0.5, 2.0, 0.05, "r_hdr_scenebrightness"));
	me.TR(me);
		me.TD(me, 1, 1, makeNexuizTextLabel(0, "Contrast boost:"));
		me.TD(me, 1, 2, makeNexuizSlider(1.0, 5.0, 0.1, "r_glsl_contrastboost"));

	me.gotoXY(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "vid_restart", COMMANDBUTTON_APPLY));
}
#endif
