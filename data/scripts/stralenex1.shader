textures/stralenex1/e6xrst_supprt
{
	qer_editorimage textures/stralenex1/e6xrst_supprt.tga
	surfaceparm nomarks
	surfaceparm trans
	cull none
	nopicmip
	{
		map textures/stralenex1/e6xrst_supprt.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap 
		blendfunc filter
		rgbGen identity
		tcGen lightmap 
		depthFunc equal
	}
}


textures/stralenex1/strale_grey_box
{
	qer_editorimage env/strale_grey/ygrey_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/strale_grey/ygrey - -
	q3map_surfacelight 60
	q3map_lightimage textures/strale_grey/ygrey_up.tga
	q3map_sun .9 .9 1 70 65 78

}

textures/stralenex1/stralenex_trimlight
{
	qer_editorimage textures/stralenex1/stralenex_trimlight.tga
	q3map_lightimage textures/stralenex1/stralenex_trimlight_glow.tga
	q3map_surfacelight 1800
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_trimlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_trimlight_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identityLighting
	}
}

textures/stralenex1/stralenex_roundlight
{
	qer_editorimage textures/stralenex1/stralenex_roundlight.tga
	q3map_lightimage textures/stralenex1/stralenex_roundlight_glow.tga
	q3map_surfacelight 4000
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_roundlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_roundlight_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .3 .1 0 0.5
	}
}
