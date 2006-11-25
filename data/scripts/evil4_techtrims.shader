// tech floors

textures/evil4_techfloors/tfloor3_huge
{
	cull none
	{
		map textures/evil4_techfloors/tfloor3_huge.tga
		tcMod scale 2.0 2.0
		blendFunc GL_ONE GL_ZERO
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
		rgbGen identity
	}
}

textures/evil4_techfloors/tfloor_rndholes
{
	{
		map textures/evil4_techfloors/tfloor_rndholes.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_techfloors/tfloor_rndholes_drty
{
	{
		map textures/evil4_techfloors/tfloor_rndholes_drty.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//********************************************
//********************************************
//********************************************
//**************evil metals section**************
//********************************************
//********************************************
//********************************************

textures/evil4_metals/mtlsportal
{
	cull disable
	surfaceparm nomarks
	surfaceparm trans
	sort additive
	{
		clampmap textures/evil4_metals/mtlsportal_fx1.tga
		blendFunc add
		tcmod rotate -100
		rgbGen identity
	}
	{
		clampmap textures/evil4_metals/mtlsportal_fx2.tga
		blendFunc add
		tcmod rotate 100
		rgbGen identity
	}
	{
		clampmap textures/evil4_metals/mtlsportal_fx3.tga
		blendFunc add
		tcmod rotate 10
		rgbGen identity
	}
	{
		clampmap textures/evil4_metals/mtlsportal.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

textures/evil4_metals/flrgrate
{
	{
		map textures/evil4_metals/flrgrate.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_metals/mtlflrslots
{
	{
		map textures/evil4_metals/mtlflrslots.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_metals/drkmtl_grlpltmech
{
	{
		map textures/evil4_metals/drkmtl_grlpltmech.tga
		//blendfunc blend
		rgbGen identity
	}
	{
		map textures/evil4_metals/drkmtl_grlpltmech_fx2.tga
		blendfunc add
		tcmod scroll 0 -3
	}
	{
		map textures/evil4_metals/drkmtl_grlpltmech_fx.tga
		blendfunc add
		tcmod scroll 0 1.6
	}
	{
		map textures/evil4_metals/drkmtl_grlpltmech_fx.tga
		blendfunc add
		tcmod scroll 0 -5
	}
	{
		map textures/evil4_metals/drkmtl_grlpltmech_fx.tga
		blendfunc add
		rgbgen wave sin 1.1 .1 1 1
		tcmod scroll 0  2.8
	}
	{
		map textures/evil4_metals/drkmtl_grlpltmech.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendfunc filter
	}
}

textures/evil4_metals/mtlbrushed
{
	qer_editorimage textures/evil4_metals/mtlbrushed.tga
	{
		map textures/evil4_metals/mtlbrushed_env.tga
		tcGen environment
		rgbGen identity
	}
	{
		map textures/evil4_metals/mtlbrushed.tga
		blendFunc gl_dst_color gl_zero
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA
		rgbGen identity
	}
}

textures/evil4_metals/eshinytin
{
	qer_editorimage textures/evil4_metals/eshinytin.tga
	{
		map textures/effects/tinfx.jpg
		tcGen environment
		rgbGen identity
		tcmod scale 0.55 1
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
	{
		map textures/evil4_metals/eshinytin.tga
		blendFunc GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_metals/mtlpanel_wrnstripe_ow2
{
	{
		map textures/evil4_metals/mtlpnl_wrnstrpow2_glow.tga
		rgbGen wave sin 0.5 0.5 0 1
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_metals/mtlpnl_wrnstrpow2_glow.tga
		//rgbGen wave sin 0.5 0.5 0 1
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_metals/mtlpanel_wrnstripe_ow2.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_metals/mtltekfloor
{
	q3map_surfacelight 100
	q3map_lightimage textures/evil4_metal/mtltekfloor_fx.tga
//	{
//		map textures/base_wall/chrome_env.tga
//		rgbGen identity
//		tcGen environment
//		tcmod scale .25 .25
//	}
	{
		map textures/evil4_metals/mtltekfloor.tga
//		blendFunc GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA
//		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_zero
		rgbGen identity
	}
//	{
//		map textures/evil4_metals/mtltekfloor_fx.tga
//		blendFunc GL_ONE GL_ONE
//		rgbGen wave sin 0.5 0.5 0 .2
//	}
//	{
//		map textures/evil4_metals/mtltekfloor_fx2.tga
//		blendFunc GL_ONE GL_ONE
//		//rgbGen wave sin 0.5 0.5 0 .2
//	}
}

textures/evil4_metals/wrnjumppad
{
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_metals/wrnjumppad.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_metals/wrnjumppad_glow.tga
		rgbGen wave sin 0.5 0.5 1 1
		blendfunc GL_ONE GL_ONE
	}
}

//********************************************
//********************************************
//********************************************
//**************evil wall section****************
//********************************************
//********************************************
//********************************************

textures/evil4_wall/tekwallmulti2
{
	{
		map textures/base_wall/chrome_env.tga
		rgbGen identity
		tcGen environment
		tcmod scale .25 .25
	}
	{
		map textures/evil4_wall/tekwallmulti2.tga
		blendFunc GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_zero
		rgbGen identity
	}
}

//********************************************
//********************************************
//********************************************
//**************evil lights section***************
//********************************************
//********************************************
//********************************************

textures/evil4_lights/steplight
{
	surfaceparm nomarks
	q3map_surfacelight 1000
	//light1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/steplight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/steplight_glow.tga
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/drkmtlsupport_light
{
	surfaceparm nomarks
	q3map_surfacelight 1000
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/drkmtlsupport_light.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/drkmtlsupport_light_glow.tga
		rgbGen wave sin 0.5 0.5 1 .5
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/s_light
{
	qer_editorimage textures/evil4_lights/s_light.jpg
	surfaceparm nomarks
	q3map_surfacelight 2500
	{
		map textures/evil4_lights/s_light.jpg
		//blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
/*	{
		map textures/evil4_lights/s_light_blend.jpg
		rgbGen wave sin 0.5 0.5 1 1
		blendFunc GL_ONE GL_ONE
	}*/
	{
		map $lightmap
		rgbGen identity
		blendFunc Filter
	}
}

textures/evil4_lights/t_mtllight
{
	surfaceparm nomarks
	q3map_surfacelight 1000
	//light1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/t_mtllight.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/t_mtllight_blend.jpg
		//rgbGen wave sin 0.5 0.5 1 1
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/mtl_lightsmll
{
	surfaceparm nomarks
	q3map_surfacelight 1000
	//light1
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/mtl_lightsmll.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/mtl_lightsmll_blend.jpg
		rgbGen wave sin 0.5 0.5 1 1
		blendfunc GL_ONE GL_ONE
	}
}

//double glowing effect light strips

textures/evil4_lights/l_light_b
{
	q3map_surfacelight 5000
	q3map_lightimage textures/evil4_lights/l_light_b.jpg
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_b.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_b_blend.jpg
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_lights/l_light_b_blend.jpg
		rgbGen wave sin 6 2 1 2
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/l_light_g
{
	q3map_surfacelight 5000
	q3map_lightimage textures/evil4_lights/l_light_g.jpg
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_g.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_g_blend.jpg
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_lights/l_light_g_blend.jpg
		rgbGen wave sin 6 2 1 2
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/l_light_r
{
	q3map_surfacelight 5000
	q3map_lightimage textures/evil4_lights/l_light_r.jpg
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_r.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_r_blend.jpg
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_lights/l_light_r_blend.jpg
		rgbGen wave sin 6 2 1 2
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/l_light_w
{
	q3map_surfacelight 5000
	q3map_lightimage textures/evil4_lights/l_light_w.jpg
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_w.jpg
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_lights/l_light_w_blend.jpg
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_lights/l_light_w_blend.jpg
		rgbGen wave sin 6 2 1 2
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_lights/mtl_l1
{
	q3map_surfacelight 1000
	q3map_lightimage textures/evil4_lights/mtl_l1.tga
	// LordHavoc: replaced most of this shader
	{
		map textures/evil4_lights/mtl_l1.tga
	}
	{
		map $lightmap
		rgbGen identity
		blendfunc filter
	}
	{
		map textures/evil4_lights/mtl_l1_glow.tga
		blendfunc add
	}
	// LordHavoc: original shader
	//{
	//	map textures/evil4_lights/mtl_l1_fx.tga
	//	//blendfunc add
	//	tcmod scale 12 1
	//	rgbGen identity
	//	tcMod scroll 0 1
	//}
	//{
	//	map textures/evil4_lights/mtl_l1_fx.tga
	//	blendfunc add
	//	//tcmod scale 25 1
	//	rgbGen identity
	//	tcMod scroll 1 0
	//}
	//{
	//	map textures/evil4_lights/mtl_l1.tga
	//	blendfunc blend
	//	rgbGen identity
	//}
	//{
	//	map textures/evil4_lights/mtl_l1_glow.tga
	//	blendfunc add
	//	tcmod scale 1 1
	//}
	//{
	//	map $lightmap
	//	rgbGen identity
	//	blendfunc filter
	//}
}

//border light

textures/evil4_lights/trimtl_grlbtm_light
{
	q3map_surfacelight 5000
	q3map_lightimage textures/evil4_lights/trimtl_grlbtm_light_blnd.tga
	qer_editorimage textures/evil4_lights/trimtl_grlbtm_light.tga
	{
		map textures/evil4_lights/trimtl_grlbtm_light.tga
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendfunc gl_dst_color gl_zero
	}
	{
		map textures/evil4_lights/trimtl_grlbtm_light_blnd.tga
		blendfunc gl_one gl_one
		rgbgen wave sin 1 .1 0 1
	}
}

textures/evil4_lights/s_bluelight
{
	q3map_surfacelight 1000
	q3map_lightimage textures/evil4_lights/s_bluelight.tga
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_lights/s_bluelight.tga
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
	}
	{
		map textures/evil4_lights/s_bluelight_glow.tga
		rgbGen wave sin 0.5 0.5 0 .2
		blendfunc add
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

//********************************************
//********************************************
//********************************************
//**************evil fx section******************
//********************************************
//********************************************
//********************************************

// portal

textures/evil4_fx/mtlportal_fx
{
	qer_editorimage textures/evil4_fx/mtlportal.tga
	cull disable
	surfaceparm nomarks
	surfaceparm trans
	sort additive
	{
		clampmap textures/evil4_fx/mtlportal_fx1.tga
		blendFunc add
		tcmod rotate -100
		rgbGen identity
	}
	{
		clampmap textures/evil4_fx/mtlportal_fx2.tga
		blendFunc add
		tcmod rotate 100
		rgbGen identity
	}
	{
		clampmap textures/evil4_fx/mtlportal.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

//matrixy transparent display images

textures/evil4_fx/mat1
{
	{
		map textures/evil4_fx/mat1.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identity
		rgbGen wave sin 0.5 0.5 0 0.7
	}
	{
		map textures/evil4_fx/mat2.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identity
		rgbGen wave sin 0.5 0.5 0 .2
	}
	{
		map textures/evil4_fx/mat3.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identity
		tcMod scroll 0 -.1
	}
	{
		map textures/evil4_fx/mat4.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identity
		tcMod scroll 0 2
	}
	{
		map $lightmap
		rgbGen identity
		blendfunc GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA
	}
}

textures/evil4_fx/b_ray
{
	q3map_surfacelight 200
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm nolightmap
	q3map_lightimage textures/evil4_fx/b_ray.tga
	cull none
	{
		map textures/evil4_fx/b_ray.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 9 1 1
		tcMod scale  0 0
		tcMod scroll 1 0
	}
	{
		map textures/evil4_fx/b_ray.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 1 1 1
		tcMod scale  1 1
		tcMod scroll 1 0
	}
}

//effect2

textures/evil4_fx/b_rayc
{
	q3map_surfacelight 200
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm nolightmap
	q3map_lightimage textures/evil4_fx/b_rayc.tga
	cull none
	{
		map textures/evil4_fx/b_rayc.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 9 1 1
		tcMod scale  0 0
		tcMod scroll 2 0
	}
	{
		map textures/evil4_fx/b_rayc.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 1 1 1
		tcMod scale  1 1
		tcMod scroll 2 0
	}
}

//snow

textures/evil4_fx/esnow
{
	q3map_surfacelight 100
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm nolightmap
	q3map_lightimage textures/evil4fx/esnow.tga
	cull none
	{
		map textures/evil4_fx/esnow.tga
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0 -0.9
	}
	{
		map textures/evil4_fx/esnow3.tga
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0 -0.7
	}
	{
		map textures/evil4_fx/esnow2.tga
		blendFunc GL_ONE GL_ONE
		tcMod scroll 0 -0.5
	}
	{
		map textures/evil4_fx/esnow2.tga
		blendFunc GL_ONE GL_ONE
		tcMod scale  2 2
		tcMod scroll 0 -3
	}
}

//weirdo waterfall’ish effect

textures/evil4_fx/e_waterfall
{
	q3map_surfacelight 2
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm nolightmap
	q3map_lightimage textures/evil4_fx/e_waterfall.tga
	cull none
	{
		map textures/evil4_fx/e_waterfall.tga
		tcGen environment
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 2 1 1 5
		tcMod scale  5 5
		tcMod scroll 0 -1
	}
	{
		map textures/evil4_fx/e_waterfall.tga
		tcGen environment
		tcmod scale 1 1
		tcmod scroll 1 -1
		blendFunc GL_ONE GL_ONE
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_fx/teleprtr
{
	cull disable
	surfaceparm nomarks
	surfaceparm trans
	sort additive
	{
		clampmap textures/evil4_fx/teleprtr_fx3.tga
		blendFunc add
		tcmod rotate -267
		rgbGen identity
	}
	{
		clampmap textures/evil4_fx/teleprtr_fx1.tga
		blendFunc add
		tcmod rotate 155
		rgbGen identity
	}
	{
		clampmap textures/evil4_fx/teleprtr_fx2.tga
		blendFunc add
		tcmod rotate -100
		rgbGen identity
	}
	{
		clampmap textures/evil4_fx/teleprtr.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

//********************************************
//********************************************
//********************************************
//**************evil tech wall section************
//********************************************
//********************************************
//********************************************

textures/evil4_techwalls/tech_dw2
{
	{
		map textures/evil4_techwalls/tech_dw2.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_techwalls/tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_techwalls/tech_dw2g
{
	{
		map textures/evil4_techwalls/tech_dw2g.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_techwalls/tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_techwalls/tech_dw2gb
{
	{
		map textures/evil4_techwalls/tech_dw2gb.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_techwalls/tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_techwalls/tech_wall_dlight
{
	surfaceparm nomarks
	q3map_surfacelight 5000
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_techwalls/tech_wall_dlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_techwalls/tech_wall_dlight_glw.tga
		rgbGen wave sin 0.5 0.5 1 1
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_techwalls/tech_dwteky
{
	{
		map textures/evil4_techwalls/tech_dwteky_glow.tga
		tcmod turb 0 3 5 8
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_techwalls/tech_dwteky_glow.tga
		blendFunc GL_ONE GL_ONE
		tcmod turb 0 1 1 1
	}
	{
		map textures/evil4_techwalls/tech_dwteky.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_techwalls/tech_drkwll_pnltek
{
	{
		map textures/evil4_techwalls/tech_drkwll_pnltek_glow.tga
		tcmod turb 0 1 1 9
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_techwalls/tech_drkwll_pnltek.tga
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_techwalls/tech_drkwll_pnltek.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//tech window with a chrome-like appearance,
//uncomment to use and comment the next one
//textures/evil4_techwalls/tech_window
//{
//{
//             map textures/effects/tinfx.tga
//                tcGen environment
//                rgbGen identity
//	}
//        {
//		map textures/evil4_techwalls/tech_window.tga
//      blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
//		rgbGen identity
//	}
//        {
//		map $lightmap
//                blendFunc gl_dst_color gl_zero
//		rgbGen identity
//	}
//}

//tech window with transparency

textures/evil4_techwalls/tech_window
{
	cull twosided
	{
		map textures/evil4_techwalls/tech_windowmask.tga
		tcGen environment
		tcMod turb 0 0.01 0 0.01
		tcmod scroll .0 .0
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_techwalls/tech_window.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_techwalls/drkmtl_lightboard
{
	{
		map textures/evil4_techwalls/drkmtl_lightboard_glow.tga
		blendFunc GL_ONE GL_ONE
		rgbGen wave sin 0.5 0.5 0 .3
	}
	{
		map textures/evil4_techwalls/drkmtl_lightboard_glow.tga
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_techwalls/drkmtl_lightboard.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_techwalls/drkmtl_dpanelwrnb2
{
	{
		map textures/evil_techwalls/drkmtl_dpanelwrnb2.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//********************************************
//********************************************
//********************************************
//********************************************
//********************************************
// techwall section II
// This is the “dirty” version of the evil_techwalls...
// I added “d_” to the filenames.
//********************************************
//********************************************
//********************************************
//********************************************
//********************************************

textures/evil4_d_techwalls/d_tech_dw2
{
	{
		map textures/evil4_d_techwalls/d_tech_dw2.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_d_techwalls/d_tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_d_techwalls/d_tech_dw2g
{
	{
		map textures/evil4_d_techwalls/d_tech_dw2g.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_d_techwalls/d_tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_d_techwalls/d_tech_dw2gb
{
	{
		map textures/evil4_d_techwalls/d_tech_dw2gb.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/evil4_d_techwalls/d_tech_dw2_fx.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 3
	}
}

textures/evil4_d_techwalls/d_tech_wall_dlight
{
	surfaceparm nomarks
	q3map_surfacelight 5000
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil4_d_techwalls/d_tech_wall_dlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil4_d_techwalls/d_tech_wall_dlight_glw.tga
		rgbGen wave sin 0.5 0.5 1 1
		blendfunc GL_ONE GL_ONE
	}
}

textures/evil4_d_techwalls/d_tech_dwteky
{
	{
		map textures/evil4_d_techwalls/d_tech_dwteky_glow.tga
		tcmod turb 0 3 5 8
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_d_techwalls/d_tech_dwteky_glow.tga
		blendFunc GL_ONE GL_ONE
		tcmod turb 0 1 1 1
	}
	{
		map textures/evil4_d_techwalls/d_tech_dwteky.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_d_techwalls/d_tech_drkwll_pnltek
{
	{
		map textures/evil4_d_techwalls/d_tech_drkwll_pnltek_glow.tga
		tcmod turb 0 1 1 9
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_d_techwalls/d_tech_drkwll_pnltek.tga
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_d_techwalls/d_tech_drkwll_pnltek.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//tech window with a chrome-like appearance,
//uncomment to use and comment the next one
//textures/evil4_d_techwalls/tech_window
//{
//{
//             map textures/effects/tinfx.tga
//                tcGen environment
//                rgbGen identity
//	}
//        {
//		map textures/evil4_d_techwalls/d_tech_window.tga
//      blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
//		rgbGen identity
//	}
//        {
//		map $lightmap
//                blendFunc gl_dst_color gl_zero
//		rgbGen identity
//	}
//}

//tech window with transparency

textures/evil4_d_techwalls/d_tech_window
{
	cull twosided
	{
		map textures/evil4_d_techwalls/d_tech_windowmask.tga
		tcGen environment
		tcMod turb 0 0.01 0 0.01
		tcmod scroll .0 .0
		blendfunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_d_techwalls/d_tech_window.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_d_techwalls/d_drkmtl_lightboard
{
	{
		map textures/evil4_d_techwalls/d_drkmtl_lightboard_glow.tga
		blendFunc GL_ONE GL_ONE
		rgbGen wave sin 0.5 0.5 0 .3
	}
	{
		map textures/evil4_d_techwalls/d_drkmtl_lightboard_glow.tga
		blendFunc GL_ONE GL_ONE
	}
	{
		map textures/evil4_d_techwalls/d_drkmtl_lightboard.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

textures/evil4_d_techwalls/d_drkmtl_dpanelwrnb2
{
	{
		map textures/evil4_d_techwalls/d_drkmtl_dpanelwrnb2.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}
