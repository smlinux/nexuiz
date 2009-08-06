
//Water for Q3texture, temp use.
//This shader is for DarkPlaces Engine - Nexuiz

textures/liquids/clear_ripple3
{
	qer_editorimage textures/water/pool3d_5e.jpg
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/water/pool3d_5e.jpg
		blendFunc add
		rgbGen vertex
	}
}
