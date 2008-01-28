// reflective water by Urre and Zombie

textures/water/water0
{
	qer_editorimage textures/water/water0.tga
	qer_trans 20
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	surfaceparm nolightmap
	q3map_globaltexture
	{
		map textures/water/water0.tga
		tcMod scroll 0.07 0.07
		tcmod scale 1.2 0.7
		blendfunc blend
	}
	dp_water 0.1 0.8  3 3  1 1 1  1 1 1  0.125
}

textures/water/water1
{
	qer_editorimage textures/water/water1.tga
	qer_trans 20
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	surfaceparm nolightmap
	q3map_globaltexture
	{
		map textures/water/water1.tga
		tcMod scroll 0.07 0.07
		tcmod scale 1.2 0.7
		blendfunc blend
	}
	dp_water 0.1 0.8  3 3  1 1 1  1 1 1  0.125
}

textures/water/water2
{
	qer_editorimage textures/water/water2.tga
	qer_trans 20
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	surfaceparm nolightmap
	q3map_globaltexture
	{
		map textures/water/water2.tga
		tcMod scroll 0.07 0.07
		tcmod scale 1.2 0.7
		blendfunc blend
	}
	dp_water 0.1 0.8  3 3  1 1 1  1 1 1  0.125
}

textures/water/slime1
{
	qer_editorimage textures/water/slime1.tga
	qer_trans 20
	surfaceparm lightfilter
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	surfaceparm nolightmap
	q3map_globaltexture
	{
		map textures/water/slime1.tga
		tcMod scroll 0.1 0.2
		tcMod turb .1 .1 0 .01
		tcmod scale .1 .1
		tcMod stretch sin 1 0.05 0.2 .0015
		tcmod rotate 0.5
	}
	dp_reflect 3  1 1 1 0.5
}

textures/water/slime2
{
	qer_editorimage textures/water/slime2.tga
	qer_trans 20
	surfaceparm lightfilter
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm water
	surfaceparm nolightmap
	q3map_globaltexture
	{
		map textures/water/slime2.tga
		tcMod scroll 0.1 0.2
		tcMod turb .1 .1 0 .01
		tcmod scale .1 .1
		tcMod stretch sin 1 0.05 0.2 .0015
		tcmod rotate 0.5
		blendfunc blend
	}
	dp_reflect 3  1 1 1 0.5
}
