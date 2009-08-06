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


textures/evil4_metals/mtlbrushed
{
	qer_editorimage textures/evil4_metals/mtlbrushed.tga

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


textures/evil4_metals/mtltekfloor
{
	q3map_surfacelight 100
	q3map_lightimage textures/evil4_metal/mtltekfloor_fx.tga

	{
		map textures/evil4_metals/mtltekfloor.tga
	}

	{
		map $lightmap
		blendfunc gl_dst_color gl_zero
		rgbGen identity
	}
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
}

textures/evil4_lights/s_bluelight
{
	q3map_surfacelight 1000
	q3map_lightimage textures/evil4_lights/s_bluelight.tga
	{
		map textures/evil4_lights/s_bluelight.tga
		rgbGen identity
	}	
	{
		map $lightmap
		rgbGen identity
		blendfuns filter
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

//snow
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
}




//tech window with transparency

textures/evil4_techwalls/tech_window
{
	cull twosided

	{
		map textures/evil4_techwalls/tech_window.tga
		blendFunc blend
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
// This is the dirty version of the evil_techwalls...
// I added d_ to the filenames.
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
		map textures/evil4_d_techwalls/d_tech_wall_dlight.tga
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
	}
}

textures/evil4_d_techwalls/d_tech_window
{
	cull twosided
	{
		map textures/evil4_d_techwalls/d_tech_window.tga
		blendFunc blend
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
