textures/aggressor/mlight
{
	qer_editorimage textures/aggressor/mlight.tga
	surfaceparm nomarks
	q3map_surfacelight 1500
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/aggressor/mlight.tga
		blendfunc filter
		rgbGen identity
	}
}

textures/aggressor/eX_floor_mtl_grate_01
{
	qer_EditorImage		textures/eX/eX_floor_mtl_grate_01.tga
	{
		map textures/eX/eX_floor_mtl_grate_01
	}
	{
		map $lightmap
	}	
}
