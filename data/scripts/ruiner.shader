textures/skies/green_storm
{
	qer_editorimage env/green_storm/green_storm_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/green_storm/green_storm - -
	q3map_surfacelight 60
	q3map_lightimage textures/green_storm/green_storm_up.tga
	q3map_sun 0.168 0.305 0.28 100 225 36
	/*q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>*/

}

textures/evil3_support/mtlsupgrt2_light
{
	qer_editorimage textures/evil3_support/mtlsupgrt2_light.tga
	q3map_lightimage textures/evil3_support/mtlsupgrt2_light_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 500
	{
		map textures/evil3_support/mtlsupgrt2_light.tga
	}
	{
		map $lightmap 
		blendfunc filter
		tcGen lightmap 
	}
	{
		map textures/evil3_support/mtlsupgrt2_light_glow.tga
		blendfunc add
	}
}

textures/liquids/ruiner_water1
{
	qer_editorimage textures/water/ruiner_water.jpg
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/water/ruiner_water.jpg
		blendFunc add
		rgbGen identity
	}
}

textures/liquids/ruiner_water2
{
	qer_editorimage textures/water/ruiner_water.jpg
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 200.0 sin 2 10 0.5 0.2
	Q3map_TessSize 64
	cull none
	{
		map textures/water/ruiner_water.jpg
		blendFunc add
		rgbGen identity
	}
}