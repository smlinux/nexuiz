textures/morphed/gelslime
{
	qer_editorimage textures/morphed/gelslime.tga
	q3map_lightimage textures/morphed/gelslime_glow.tga
	qer_trans 0.75
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 280
	Q3map_TessSize 128
	cull none
	{
		map textures/morphed/gelslime.tga
		rgbGen identity
		depthWrite
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc blend
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/morphed/gelslime_warp
{
	qer_editorimage textures/morphed/gelslime.tga
	q3map_lightimage textures/morphed/gelslime_glow.tga
	qer_trans 0.75
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 280
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/morphed/gelslime.tga
		rgbGen identity
		depthWrite
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc blend
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}


textures/morphed/gelslime_bright
{
	qer_editorimage textures/morphed/gelslime_bright.tga
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 320
	Q3map_TessSize 128
	cull none
	{
		map textures/morphed/gelslime_bright.tga
		blendFunc add
		rgbGen identity
		//tcMod turb <base> <amplitude> <phase><freq>
		tcMod turb 1 0.15 0 0.15
		tcMod scroll 0 0.2
	}
}


textures/morphed/gelslime_bright_warp
{
	qer_editorimage textures/morphed/gelslime_bright.tga
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 320
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/morphed/gelslime_bright.tga
		blendFunc add
		rgbGen identity
	}
}

