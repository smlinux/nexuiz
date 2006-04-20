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
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
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
	qer_editorimage textures/evil_basewall/mtl_gray.jpg
	qer_trans 0.5
	cull none
	surfaceparm trans
	{
		map textures/evil_basewall/mtl_gray.jpg
		blendFunc add
		rgbGen identity
	}
}