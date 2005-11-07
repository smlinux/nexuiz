// textures/evil6_lights/

textures/evil6_lights/e6horzlight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6horzlight.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6horzlight.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6horzlight_blend.jpg
		blendfunc add
	}
}

// e6horzovallight.jpg with e6horzovallight_blend.jpg and
// e6mtltpnl_light_fx.jpg  
// ( e6mtltpnl_light_fx.jpg scrolls up slowly (speed of 2) while
// e6mtltpnl_light_blend.jpg has the normal q3 light  shader)
// 
// 
textures/evil6_lights/e6horzovallight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6horzovallight.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6horzovallight.jpg
	}
	{
		map textures/evil6_lights/e6horzovallight_blend.jpg
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
qer_editorimage textures/evil6_lights/e6horzovallight_a.jpg
//q3map_surfacelight ?
surfaceparm nomarks
	
{
map textures/evil6_lights/e6mtltpnl_light_fx.jpg
tcmod scroll .2 1 
	}
	{
		map textures/evil6_lights/e6horzovallight_a.jpg
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
	}
	{
		map textures/evil6_lights/e6horzovallight_blend.jpg
		blendfunc add
	}
}


textures/evil6_lights/e6platelight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6platelight.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6platelight.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6platelight_blend.jpg
		blendfunc add
	}
}

// e6platelight_burnt.jpg with e6platelight_burnt_blend.jpg  (default q3 light shader)
textures/evil6_lights/e6platelight_burnt_s_nolight
{
	qer_editorimage textures/evil6_lights/e6platelight_burnt.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6platelight_burnt.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6platelight_burnt_blend.jpg
		blendfunc add
	}
}

// e6tinylight.jpg with e6tinylight_blend.jpg  (default q3 light shader)
textures/evil6_lights/e6tinylight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6tinylight.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6tinylight.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6tinylight_blend.jpg
		blendfunc add
	}
}

// e6v_light.jpg with e6v_light_blend.jpg  (default q3 light shader)
textures/evil6_lights/e6v_light_s_nolight
{
	qer_editorimage textures/evil6_lights/e6v_light.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6v_light.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6v_light_blend.jpg
		blendfunc add
	}
}

// e6walllight.jpg with e6walllight_blend.jpg  (default q3 light shader)
textures/evil6_lights/e6walllight_s_nolight
{
	qer_editorimage textures/evil6_lights/e6walllight.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	
	{
		map textures/evil6_lights/e6walllight.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6walllight_blend.jpg
		blendfunc add
	}
}

// Maj: Added these strip ones

textures/evil6_lights/e6basicstrip_blue_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_blue.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_blue.jpg
	}
}

textures/evil6_lights/e6basicstrip_green_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_green.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_green.jpg
	}
	{
		map textures/evil6_lights/e6basicstrip_green.jpg
		blendfunc add
		rgbGen identity
	}
	{
		map textures/evil6_lights/e6basicstrip_green.jpg
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap 
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap 
	}
}

textures/evil6_lights/e6basicstrip_orange_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_orange.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_orange.jpg
	}
}

textures/evil6_lights/e6basicstrip_red_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_red.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_red.jpg
	}
}

textures/evil6_lights/e6basicstrip_white_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_white.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_white.jpg
	}
}

textures/evil6_lights/e6basicstrip_yellow_s_nolight
{
	qer_editorimage textures/evil6_lights/e6basicstrip_yellow.jpg
	//q3map_surfacelight ?
	surfaceparm nomarks
	surfaceparm nolightmap
	
	{
		map textures/evil6_lights/e6basicstrip_yellow.jpg
	}
}


