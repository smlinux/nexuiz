textures/kaznexctf2/small_blue
{
	qer_editorimage textures/kaznexctf2/small_blue.tga
	q3map_lightimage textures/kaznexctf2/small_blue_glow.tga
	q3map_surfacelight 500
	q3map_lightsubdivide 128
	surfaceparm nomarks
	{
		map textures/kaznexctf2/small_blue.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/small_blue_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/small_red
{
	qer_editorimage textures/kaznexctf2/small_red.tga
	q3map_lightimage textures/kaznexctf2/small_red_glow.tga
	q3map_surfacelight 500
	q3map_lightsubdivide 128
	surfaceparm nomarks
	{
		map textures/kaznexctf2/small_red.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/small_red_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/large_blue
{
	qer_editorimage textures/kaznexctf2/large_blue.tga
	q3map_lightimage textures/kaznexctf2/large_blue_glow.tga
	q3map_surfacelight 500
	q3map_lightsubdivide 128
	surfaceparm nomarks
	{
		map textures/kaznexctf2/large_blue.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/large_blue_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/large_red
{
	qer_editorimage textures/kaznexctf2/large_red.tga
	q3map_lightimage textures/kaznexctf2/large_red_glow.tga
	q3map_surfacelight 500
	q3map_lightsubdivide 128
	surfaceparm nomarks
	{
		map textures/kaznexctf2/large_red.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/large_red_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/long_light
{
	qer_editorimage textures/kaznexctf2/long_light.tga
	q3map_lightimage textures/kaznexctf2/long_light_glow.tga
	q3map_surfacelight 1500
	surfaceparm nomarks
	{
		map textures/kaznexctf2/long_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/long_light_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/small_light
{
	qer_editorimage textures/kaznexctf2/small_light.tga
	q3map_lightimage textures/kaznexctf2/small_light_glow.tga
	q3map_surfacelight 1500
	surfaceparm nomarks
	{
		map textures/kaznexctf2/small_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/kaznexctf2/small_light_glow.tga
		blendfunc add
	}
}

textures/kaznexctf2/grate
{
	qer_editorimage textures/kaznexctf2/grate.tga
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	{
		map textures/kaznexctf2/grate.tga
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

textures/kaznexctf2/grate2
{
	qer_editorimage textures/kaznexctf2/grate2.tga
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	{
		map textures/kaznexctf2/grate2.tga
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

textures/kaznexctf2/grate3
{
	qer_editorimage textures/kaznexctf2/grate3.tga
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	nomipmaps
	{
		map textures/kaznexctf2/grate3.tga
		//depthWrite
		alphaFunc GT0
		rgbgen vertex
	}
}
