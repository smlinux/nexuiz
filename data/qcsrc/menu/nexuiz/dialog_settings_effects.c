#ifdef INTERFACE
CLASS(NexuizEffectsSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizEffectsSettingsTab, fill, void(entity))
	ATTRIB(NexuizEffectsSettingsTab, title, string, "Effects")
	ATTRIB(NexuizEffectsSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizEffectsSettingsTab, rows, float, 17)
	ATTRIB(NexuizEffectsSettingsTab, columns, float, 6.5)
ENDCLASS(NexuizEffectsSettingsTab)
entity makeNexuizEffectsSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeNexuizEffectsSettingsTab()
{
	entity me;
	me = spawnNexuizEffectsSettingsTab();
	me.configureDialog(me);
	return me;
}

void fillNexuizEffectsSettingsTab(entity me)
{
	entity e;
	float n;
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Quality preset:"));
		n = 6 + !!cvar("developer");
		if(cvar("developer"))
			me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("OMG!", '1 0 1', "exec omg.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("Low", '0 0 0', "exec low.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("Medium", '0 0 0', "exec med.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("Normal", '0 0 0', "exec normal.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("High", '0 0 0', "exec high.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("Ultra", '0 0 0', "exec ultra.cfg", 0));
		me.TD(me, 1, 5.5 / n, e = makeNexuizCommandButton("Ultimate", '0 0 0', "exec ultimate.cfg", 0));

	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Geometry quality:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("r_subdivisions_tolerance"));
			e.addValue(e, "Lowest", "16");
			e.addValue(e, "Low", "8");
			e.addValue(e, "Normal", "4");
			e.addValue(e, "Good", "3");
			e.addValue(e, "Best", "2");
			e.addValue(e, "Insane", "1");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Texture quality:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("gl_picmip"));
			if(cvar("developer"))
				e.addValue(e, "Leet", "1337");
			e.addValue(e, "Lowest", "4");
			e.addValue(e, "Low", "3");
			e.addValue(e, "Normal", "2");
			e.addValue(e, "Good", "1");
			e.addValue(e, "Best", "0");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(1, "r_picmipworld", "Reduce model texture quality only"));
			setDependent(e, "gl_picmip", 0.5, -0.5);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(1, "mod_q3bsp_nolightmaps", "Use lightmaps"));

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Particle quality:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.1, 1.0, 0.05, "cl_particles_quality"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Particle distance:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(500, 2000, 100, "r_drawparticles_drawdistance"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_decals", "Decals"));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Distance:"));
			setDependent(e, "cl_decals", 1, 1);
		me.TD(me, 1, 2, e = makeNexuizSlider(200, 500, 20, "r_drawdecals_drawdistance"));
			setDependent(e, "cl_decals", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
	    me.TD(me, 1, 0.8, e = makeNexuizTextLabel(0, "Time:"));
	        setDependent(e, "cl_decals", 1, 1);
	    me.TD(me, 1, 2, e = makeNexuizSlider(1, 20, 1, "cl_decals_time"));
	        setDependent(e, "cl_decals", 1, 1);

	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_gentle", "Disable gore effects"));

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Gibs:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_nogibs"));
			e.addValue(e, "None", "1");
			e.addValue(e, "Few", "0.75");
			e.addValue(e, "Many", "0.5");
			e.addValue(e, "Lots", "0");
			e.configureNexuizTextSliderValues(e);

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Damage kick:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 0.5, 0.05, "v_kicktime"));

	me.gotoRC(me, 2, 3.5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Anisotropy:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("gl_texture_anisotropy"));
			e.addValue(e, "1x", "1");
			e.addValue(e, "2x", "2");
			e.addValue(e, "4x", "4");
			e.addValue(e, "8x", "8");
			e.addValue(e, "16x", "16");
			e.configureNexuizTextSliderValues(e);
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNexuizCheckBox(0, "r_glsl_deluxemapping", "Deluxe mapping"));
			setDependentAND(e, "r_glsl", 1, 1, "mod_q3bsp_nolightmaps", 0, 0);
		me.TD(me, 1, 1.5, e = makeNexuizCheckBox(0, "r_shadow_gloss", "Gloss"));
			setDependentAND3(e, "r_glsl", 1, 1, "r_glsl_deluxemapping", 1, 2, "mod_q3bsp_nolightmaps", 0, 0);

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizRadioButton(1, string_null, string_null, "No dynamic lighting"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizRadioButton(1, "gl_flashblend", string_null, "Flash blend approximation"));
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizRadioButton(1, "r_shadow_realtime_dlight", string_null, "Realtime dynamic lighting"));
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "r_shadow_realtime_dlight_shadows", "Shadows"));
			setDependent(e, "r_shadow_realtime_dlight", 1, 1);
	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "r_shadow_realtime_world", "Realtime world lighting"));
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "r_shadow_realtime_world_shadows", "Shadows"));
			setDependent(e, "r_shadow_realtime_world", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeNexuizCheckBox(0, "r_shadow_usenormalmap", "Use normal maps"));
			setDependentOR(e, "r_shadow_realtime_dlight", 1, 1, "r_shadow_realtime_world", 1, 1);

	me.TR(me);
		if(cvar("developer"))
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_showsurfaces", "Show surfaces"));
				e.yesValue = 3;

	me.TR(me);
		me.TD(me, 1, 1.5, e = makeNexuizCheckBox(0, "r_glsl_offsetmapping", "Offset mapping"));
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 1.5, e = makeNexuizCheckBox(0, "r_glsl_offsetmapping_reliefmapping", "Relief mapping"));
			setDependentAND(e, "r_glsl", 1, 1, "r_glsl_offsetmapping", 1, 1);
	
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "r_water", "Reflections"));
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 2, e = makeNexuizTextSlider("r_water_resolutionmultiplier"));
			e.addValue(e, "Blurred", "0.25");
			e.addValue(e, "Good", "0.5");
			e.addValue(e, "Sharp", "1");
			e.addValue(e, "Insane", "2");
			e.configureNexuizTextSliderValues(e);
			setDependentAND(e, "r_glsl", 1, 1, "r_water", 1, 1);
	
	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_coronas", "Coronas"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "r_bloom", "Bloom"));
			setDependent(e, "r_hdr", 0, 0);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "r_hdr", "High Dynamic Range (HDR)"));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "r_restart", COMMANDBUTTON_APPLY));
}
#endif
