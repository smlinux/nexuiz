textures/toxic/toxic_slime
{
	qer_editorimage textures/liquids/slime1.tga
	surfaceparm noimpact
	surfaceparm nonsolid
	surfaceparm slime
	surfaceparm trans
	cull disable
	deformVertexes wave 150 sin 2 5 0.25 0.1
	tessSize 128
	qer_trans 0.5
	q3map_surfacelight 1200
	{
		map textures/liquids/slime1.tga
		blendfunc add
		rgbGen identity
		tcMod turb 0 0.2 0.28 0.1
	}
}

textures/toxic/toxic_sky
{
	qer_editorimage env/strale_grey/ygrey_up.tga
	q3map_lightimage textures/strale_grey/ygrey_up.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm sky
	q3map_surfacelight 150
	q3map_sun 0.75 0.65 0.6 130 255 80
	skyParms env/strale_grey/ygrey 128 -
}