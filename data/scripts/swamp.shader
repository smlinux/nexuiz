textures/swamp/ndslime
{
	qer_editorimage textures/liquids/slime1.jpg
	qer_trans 0.5
	surfaceparm noimpact
	surfaceparm trans
	surfaceparm nonsolid
	q3map_surfacelight 15
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/liquids/slime1.jpg
		blendFunc add
		rgbGen identity
	}
}