//Water for Q3texture, temp use.
//This shader is for DarkPlaces Engine - Nexuiz

textures/sav-liquids/slime1
{
	qer_editorimage textures/liquids/slime1.jpg
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	q3map_surfacelight 250
	//deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/liquids/slime1.jpg
		blendFunc add
		rgbGen identity
	}
}


textures/sav-liquids/glass_tube
{
	qer_editorimage textures/dsi/dsiglass2.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5

	{
		map textures/dsi/dsiglass2.tga
		blendfunc add
		//rgbGen vertex
		tcgen environment
		tcmod scale 4 4
	}	
}
