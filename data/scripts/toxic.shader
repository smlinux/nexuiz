textures/toxic/toxic_sky
{
	qer_editorimage env/green_dark/green_dark_lf.tga
	q3map_lightimage env/green_dark/green_dark_lf.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm sky
	q3map_surfacelight 200
	q3map_sun 0.55 0.55 0.55 100 215 40
	skyParms env/green_dark/green_dark 128 -
}

textures/toxic/toxic_grate
{
	qer_editorimage textures/kaznexctf2/grate.tga
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	nomipmaps
	{
		map textures/kaznexctf2/grate.tga
		//depthWrite
		//alphaFunc GT0
		blendFunc blend
		rgbgen vertex
	}
}

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
		tcMod turb 0 0.2 0 0.04
	}
}

textures/toxic/toxic_slime_tube
{
	qer_editorimage textures/liquids/slime1.tga
	surfaceparm noimpact
	surfaceparm nonsolid
	surfaceparm slime
	surfaceparm trans
	cull disable
	//deformVertexes wave 150 sin 2 5 0.25 0.1
	tessSize 128
	qer_trans 0.5
	q3map_surfacelight 1200
	{
		map textures/liquids/slime1.tga
		blendfunc add
		rgbGen identity
		tcMod scroll 0 0.2
	}
}
