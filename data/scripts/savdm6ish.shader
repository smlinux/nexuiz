textures/savdm6ish/#lava1
{
	qer_editorimage textures/savdm6ish/#lava1.jpg
	//qer_nocarve
	surfaceparm noimpact
	surfaceparm lava
	surfaceparm nolightmap
	q3map_surfacelight 3000
	cull disable
	//tessSize 256
	//deformVertexes wave 100sin 5 5 .5 0.02
	{
		map textures/savdm6ish/#lava1.jpg
		tcMod turb 0 0.2 0 0.04
	}
}

textures/savdm6ish/#teleport
{
	qer_editorimage textures/savdm6ish/#teleport.jpg
	qer_nocarve
	surfaceparm noimpact
	//surfaceparm water
	surfaceparm nolightmap
	q3map_surfacelight 1000
	cull disable
	//tessSize 256
	//deformVertexes wave 100sin 5 5 .5 0.02
	{
		map textures/savdm6ish/#teleport.jpg
		tcMod turb 0 0.2 0 0.04
	}
}

textures/savdm6ish/wall14_5
{
	q3map_lightmapSampleSize 8
	{
		map textures/savdm6ish/wall14_5.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/savdm6ish/wiz1_4
{
	q3map_lightmapSampleSize 8
	{
		map textures/savdm6ish/wiz1_4.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/savdm6ish/floor01_5
{
	q3map_lightmapSampleSize 8
	{
		map textures/savdm6ish/floor01_5.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
}
