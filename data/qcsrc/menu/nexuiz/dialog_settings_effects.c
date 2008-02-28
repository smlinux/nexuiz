#ifdef INTERFACE
CLASS(NexuizEffectsSettingsTab) EXTENDS(NexuizTab)
	METHOD(NexuizEffectsSettingsTab, fill, void(entity))
	ATTRIB(NexuizEffectsSettingsTab, title, string, "Effects")
	ATTRIB(NexuizEffectsSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(NexuizEffectsSettingsTab, rows, float, 15)
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
/*
 * cl_decals 1
 * cl_nogibs 0
 * cl_particles_quality 1
 * cl_particles_snow 1
 * r_bloom 1
 * r_coronas 1
 * r_glsl_deluxemapping 1
 * r_glsl_offsetmapping 1
 * r_glsl_offsetmapping_reliefmapping 0
 * r_hdr 0
 * r_shadow_usenormalmap 1
 * r_shadow_gloss 1
 * r_shadow_realtime_dlight 1
 * r_shadow_realtime_dlight_shadows 1
 * r_shadow_realtime_world 1
 * r_shadow_realtime_world_shadows 1
 * r_depthfirst 2
 * r_showsurfaces 0
 * r_water 1
 * r_water_resolutionmultiplier 0.5
 *
 *
 * [X] cl_decals
 * [X] !cl_nogibs
 * Particles: |--v--|
 * [X] Bloom [X] HDR
 * [X] Coronas
 * [X] Deluxemapping [X] Gloss
 * [X] Offsetmapping [X] Reliefmapping
 * [X] dlights [X] normalmaps [X] shadows
 * [X] rtworld [X] shadows
 * [X] depth first world [X] depth first models (?????)
 * [X] OMGLOLWTFBBQ (showsurfaces)
 * [X] water |----------v----|
 *
 *
 */
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

	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Particle quality:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0.1, 1.0, 0.05, "cl_particles_quality"));
	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "cl_decals", "Decals"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Gibs:"));
		me.TD(me, 1, 2, e = makeNexuizTextSlider("cl_nogibs"));
			if(cvar("developer"))
				e.addValue(e, "German", "1");
			e.addValue(e, "Few", "0.75");
			e.addValue(e, "Many", "0.5");
			e.addValue(e, "Lots", "0");
			e.configureNexuizTextSliderValues(e);

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_coronas", "Coronas"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeNexuizCheckBox(0, "r_bloom", "Bloom"));
			setDependent(e, "r_hdr", 0, 0);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "r_hdr", "High Dynamic Range (HDR)"));

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "showfps", "Show frames per second"));

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
			setDependent(e, "r_glsl", 1, 1);
		me.TD(me, 1, 1.5, e = makeNexuizCheckBox(0, "r_shadow_gloss", "Gloss"));
			setDependentAND(e, "r_glsl", 1, 1, "r_glsl_deluxemapping", 1, 1);

	me.TR(me);

	me.TR(me);
		me.TD(me, 1, 2, e = makeNexuizCheckBox(0, "r_shadow_realtime_dlight", "Realtime dynamic lighting"));
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
		me.TD(me, 1, 1, e = makeNexuizTextLabel(0, "Damage kick:"));
		me.TD(me, 1, 2, e = makeNexuizSlider(0, 0.5, 0.05, "v_kicktime"));

	me.TR(me);

	me.TR(me);
		if(cvar("developer"))
			me.TD(me, 1, 3, e = makeNexuizCheckBox(0, "r_showsurfaces", "Show surfaces"));

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, makeNexuizCommandButton("Apply immediately", '0 0 0', "sendcvar cl_nogibs; r_restart", COMMANDBUTTON_APPLY));
}
/*
 * [X] depth first world [X] depth first models (?????)
 * [X] OMGLOLWTFBBQ (showsurfaces)
 *
 *
 */
#endif
