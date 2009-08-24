textures/stormkeep/eX_light_u201
{
	qer_EditorImage	textures/eX/eX_light_u201.tga
	q3map_surfacelight 1500
	{
		map textures/eX/eX_light_u201
	}
	{
		map $lightmap
	}
}

textures/stormkeep/rlight
{
	qer_EditorImage	textures/aggressor/rlight.tga
	q3map_surfacelight 4500
	{
		map textures/aggressor/rlight
	}
	{
		map $lightmap
	}
}

textures/stormkeep/lava
{
	qer_editorimage textures/stormkeep/lava.tga
	surfaceparm lava
	surfaceparm noimpact
	surfaceparm trans
	cull disable
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	q3map_surfacelight 1000
	{
		map textures/stormkeep/lava.tga
		blendfunc add
	}
}

textures/stormkeep/lava_flow
{
	qer_editorimage textures/stormkeep/lava.tga
	surfaceparm lava
	surfaceparm noimpact
	surfaceparm trans
	cull disable
	q3map_surfacelight 1000
	{
		map textures/stormkeep/lava.tga
		blendfunc add
		tcMod scroll 0 -0.25
	}
}

