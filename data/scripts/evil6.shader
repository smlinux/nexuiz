textures/evil6_floors/e6bsegrtflr128_s
{
	qer_editorimage textures/evil6_floors/e6bsegrtflr128.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6bsegrtflr128.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6bsegrtflr256_s
{
	qer_editorimage textures/evil6_floors/e6bsegrtflr256.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6bsegrtflr256.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate_flr_b_s
{
	qer_editorimage textures/evil6_floors/e6grate_flr_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate_flr_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate_flr_s
{
	qer_editorimage textures/evil6_floors/e6grate_flr.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate_flr.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grtfloorceil_s
{
	qer_editorimage textures/evil6_floors/e6grtfloorceil.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grtfloorceil.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate2_flr_s
{
	qer_editorimage textures/evil6_floors/e6grate2_flr.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate2_flr.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate2_flr_b_s
{
	qer_editorimage textures/evil6_floors/e6grate2_flr_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate2_flr_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6launchcfloor_s
{
	qer_editorimage textures/evil6_floors/e6launchcfloor.tga
	q3map_lightimage textures/evil6_floors/e6launchcfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	{
		map textures/evil6_floors/e6launchcfloor.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6launchcfloor_glow.tga
		blendfunc add
		rgbgen wave sin .5 .8 0 1.5
	}
	{
		clampmap textures/evil6_floors/e6launchcfloor_fx.tga
		blendfunc add
		tcMod stretch sin 1.2 .9 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

textures/evil6_floors/e6launchengine_s
{
	qer_editorimage textures/evil6_floors/e6launchengine.tga
	q3map_lightimage textures/evil6_floors/e6launchengine_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	
	{
		map textures/evil6_floors/e6launchengine
		animmap 10 textures/evil6_floors/e6launchengine textures/evil6_floors/e6launchengine-1 textures/evil6_floors/e6launchengine-2 textures/evil6_floors/e6launchengine-3 textures/evil6_floors/e6launchengine-4 textures/evil6_floors/e6launchengine-5 textures/evil6_floors/e6launchengine-6 textures/evil6_floors/e6launchengine-7
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}

}

textures/evil6_floors/e6launchlfloor_s
{
	qer_editorimage textures/evil6_floors/e6launchlfloor.tga
	q3map_lightimage textures/evil6_floors/e6launchlfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	{
		map textures/evil6_floors/e6launchlfloor.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6launchlfloor_glow.tga
		blendfunc add
		rgbgen wave sin .5 .8 0 1.5
	}
	{
		clampmap textures/evil6_floors/e6launchlfloor_fx.tga
		blendfunc add
		tcMod stretch sin 1.2 .9 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

textures/evil6_floors/e6tekmtlrflr_h_full_slow
{
	qer_editorimage textures/evil6_floors/e6tekmtlrflr_h.tga
	{
		map textures/evil6_floors/e6tekmtlrflr_h.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6tekmtlrflr_h_glow.tga
		rgbgen wave sin .5 .5 0 .2
		blendfunc add
	}
}

textures/evil6_floors/e6tekmtlrflr_h_small_noisy_fast
{
	qer_editorimage textures/evil6_floors/e6tekmtlrflr_h.tga
	{
		map textures/evil6_floors/e6tekmtlrflr_h.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6tekmtlrflr_h_glow.tga
		rgbgen wave noise .9 .2 0 4
		blendfunc add
	}
}

textures/evil6_floors/e6xgratebasic_b_s
{
	qer_editorimage textures/evil6_floors/e6xgratebasic_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6xgratebasic_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6xgratebasic_s
{
	qer_editorimage textures/evil6_floors/e6xgratebasic.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6xgratebasic.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// textures/evil6_lights/

textures/evil6_lights/e6horzlight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6horzlight.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6horzlight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6horzlight_blend.tga
		blendfunc add
	}
}

// e6horzovallight.jpg with e6horzovallight_blend.jpg and
// e6mtltpnl_light_fx.jpg
// ( e6mtltpnl_light_fx.jpg scrolls up slowly (speed of 2) while
// e6mtltpnl_light_blend.jpg has the normal q3 light  shader)

textures/evil6_lights/e6horzovallight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6horzovallight.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6horzovallight.tga
	}
	{
		map textures/evil6_lights/e6horzovallight_blend.tga
		blendfunc add
	}
	{
		map $lightmap
		blendfunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
	}
}

// alpha channel:

textures/evil6_lights/e6horzovallight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6horzovallight_a.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6mtltpnl_light_fx.tga
		tcmod scroll .2 1
	}
	{
		map textures/evil6_lights/e6horzovallight_a.tga
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
	}
	{
		map textures/evil6_lights/e6horzovallight_blend.tga
		blendfunc add
	}
}

textures/evil6_lights/e6platelight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6platelight.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6platelight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6platelight_blend.tga
		blendfunc add
	}
}

// e6platelight_burnt.jpg with e6platelight_burnt_blend.jpg  (default q3 light shader)

textures/evil6_lights/e6platelight_burnt_s_nolight
{
	qer_editorimage textures/evil6_lights/e6platelight_burnt.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6platelight_burnt.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6platelight_burnt_blend.tga
		blendfunc add
	}
}

// e6tinylight.jpg with e6tinylight_blend.jpg  (default q3 light shader)

textures/evil6_lights/e6tinylight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6tinylight.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6tinylight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6tinylight_blend.tga
		blendfunc add
	}
}

// e6v_light.jpg with e6v_light_blend.jpg  (default q3 light shader)

textures/evil6_lights/e6v_light_s_nolight
{
	qer_editorimage textures/evil6_lights/e6v_light.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6v_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6v_light_blend.tga
		blendfunc add
	}
}

// e6walllight.jpg with e6walllight_blend.jpg  (default q3 light shader)

textures/evil6_lights/e6walllight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6walllight.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6walllight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6walllight_blend.tga
		blendfunc add
	}
}

// Maj: Added these strip ones

textures/evil6_lights/e6basicstrip_blue_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_blue.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_blue.tga
	}
}

textures/evil6_lights/e6basicstrip_green_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_green.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_green.tga
	}
}

textures/evil6_lights/e6basicstrip_orange_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_orange.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_orange.tga
	}
}

textures/evil6_lights/e6basicstrip_red_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_red.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_red.tga
	}
}

textures/evil6_lights/e6basicstrip_white_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_white.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_white.tga
	}
}

textures/evil6_lights/e6basicstrip_yellow_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_yellow.tga
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	{
		map textures/evil6_lights/e6basicstrip_yellow.tga
	}
}

textures/evil6_support/e6h_support_s
{
	qer_editorimage textures/evil6_support/e6h_support.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6h_support.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6holestrip_s
{
	qer_editorimage textures/evil6_support/e6holestrip.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6holestrip.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6vertgrt_supp_s_nolight
{
	qer_editorimage textures/evil6_support/e6vertgrt_supp.tga
	q3map_lightimage textures/evil6_support/e6vertgrt_supp_fx.tga
	surfaceparm nomarks
	{
		map textures/evil6_support/e6vertgrt_supp.tga
	}
	{
		map textures/evil6_support/e6vertgrt_supp_fx.tga
		tcmod scroll 0 2
		blendfunc add
	}
	{
		map textures/evil6_support/e6vertgrt_supp.tga
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
	}
}

textures/evil6_support/e6vlight_supp_s_nolight
{
	qer_editorimage textures/evil6_support/e6vlight_supp.tga
	surfaceparm nomarks
	{
		map textures/evil6_support/e6vlight_supp.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_support/e6vlight_supp_blend.tga
		blendfunc add
	}
}

textures/evil6_support/e6x_supprt_s
{
	qer_editorimage textures/evil6_support/e6x_supprt.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6x_supprt.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6xrst_supprt_s
{
	qer_editorimage textures/evil6_support/e6xrst_supprt.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6xrst_supprt.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_trims/e6btrim_light_s_nolight
{
	qer_editorimage textures/evil6_trims/e6btrim_light.tga
	surfaceparm nomarks
	{
		map textures/evil6_trims/e6btrim_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_trims/e6btrim_light_blend.tga
		blendfunc add
	}
}

textures/evil6_trims/e6metalfan_s
{
	qer_editorimage textures/evil6_trims/e6metalfan.tga
	{
		map textures/evil6_trims/e6metalfan_blade.tga
		tcmod rotate 5000
	}
	{
		map textures/evil6_trims/e6metalfan.tga
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/evil6_trims/e6strimlight_s_nolight
{
	qer_editorimage textures/evil6_trims/e6strimlight.tga
	surfaceparm nomarks
	{
		map textures/evil6_trims/e6strimlight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_trims/e6strimlight_blend.tga
		blendfunc add
	}
}

textures/evil6_trims/e6trim_bsrlight_s_nolight
{
	qer_editorimage textures/evil6_trims/e6trim_bsrlight.tga
	surfaceparm nomarks
	{
		map textures/evil6_trims/e6trim_bsrlight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_trims/e6trim_bsrlight_blend.tga
		blendfunc add
	}
}

textures/evil6_trims/e6trim_light_s_nolight
{
	qer_editorimage textures/evil6_trims/e6trim_light.tga
	surfaceparm nomarks
	{
		map textures/evil6_trims/e6trim_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_trims/e6trim_light_blend.tga
		blendfunc add
	}
}

// textures/evil6_walls/

// e6girdergrate.tga  (default grate shader)

textures/evil6_walls/e6girdergrate_s
{
	qer_editorimage textures/evil6_walls/e6girdergrate.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdergrate.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6girdergrate2b.tga  (default grate shader)

textures/evil6_walls/e6girdergrate2b_s
{
	qer_editorimage textures/evil6_walls/e6girdergrate2b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdergrate2b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6girdersupport.tga  (default grate shader)

textures/evil6_walls/e6girdersupport_s
{
	qer_editorimage textures/evil6_walls/e6girdersupport.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdersupport.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6indsdoor.tga  (default grate shader)

textures/evil6_walls/e6indsdoor_s
{
	qer_editorimage textures/evil6_walls/e6indsdoor.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6indsdoor.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6tdoor.tga with e6tdoor_fx.tga will use this shader:
// Tech door light effect

textures/evil6_walls/e6tdoor
{
	qer_editorimage textures/evil6_walls/e6tdoor.tga
	{
		map textures/evil6_walls/e6tdoor.tga
	}
	{
		map textures/evil6_walls/e6tdoor_fx.tga
		tcmod scroll -1 0
		blendFunc add
	}
	{
		map textures/evil6_walls/e6tdoor.tga
		blendFunc blend
	}
	{
		map $lightmap
		blendFunc filter
	}
}