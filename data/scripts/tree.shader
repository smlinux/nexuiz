
leaves2
{
	qer_editorimage textures/leaves2.tga
	qer_trans 0.6
	deformVertexes autosprite
	surfaceparm trans
//	surfaceparm nolightmap
	surfaceparm alphashadow
	q3map_vertexScale 1
	deformVertexes wave 128 sin 0 1 0 0.4 
	{
		map textures/leaves2.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

textures/morph/leaves3
{
cull none
	qer_editorimage textures/leaves6.tga
	qer_trans 0.6
	surfaceparm trans
//	surfaceparm nolightmap
	surfaceparm alphashadow
	deformVertexes autosprite
	q3map_vertexScale 1
	deformVertexes wave 128 sin 0 1 0 0.4 
	{
		map textures/leaves6.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

grass01
{
cull none
	qer_editorimage textures/grass.tga
	qer_trans 0.2
	deformVertexes autosprite
	surfaceparm nolightmap
	q3map_vertexScale 1
	surfaceparm trans
	deformVertexes wave 128 sin 0 1 0 0.2
	{
		map textures/grass.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

grass02
{
	distancecull 256 1024 0.4
	cull none
	qer_editorimage textures/grass2.tga
	qer_trans 0.2
	surfaceparm nolightmap
	surfaceparm trans
	q3map_vertexScale 1
	deformVertexes autosprite
	deformVertexes wave 128 sin 0 1 0 0.1 
	{
		map textures/grass2.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

leaves4
{
cull none
	qer_editorimage textures/leaves7.tga
	qer_trans 0.6
	deformVertexes autosprite
	surfaceparm nolightmap
	surfaceparm trans
	q3map_vertexScale 1
	deformVertexes wave 128 sin 0 1 0 0.5
	{
		map textures/leaves7.tga
		alphaFunc GT0
		rgbGen vertex
	}
}

grass03
{
cull none
	qer_editorimage textures/grass03.tga
	qer_trans 0.8
	surfaceparm trans
	surfaceparm nolightmap
	q3map_vertexScale 1
	deformVertexes wave 128 sin 0 1 0 0.1 
	{
		map textures/grass03.tga
		rgbGen vertex
	}
}

textures/morphed/skyhigh
{
	qer_editorimage env/med-troubadour-gray/med-troubadour-gray_up.tga
	q3map_noTJunc
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm sky
	surfaceparm nomarks
	q3map_lightmapFilterRadius 0 8
	q3map_sunExt 0.5 0.5 0.7 500 55 70 3 8
	q3map_skylight 170 3
	skyparms env/med-troubadour-gray/med-troubadour-gray - -
}

textures/morphed/flagred
	{
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm trans
	cull none
	tessSize 64
	deformVertexes wave 194 sin 0 3 0 .4
	{
	map textures/morphed/flagred.tga
	rgbGen vertex
	}
	}
textures/morphed/flagblue
	{
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm trans
	cull none
	tessSize 64
	deformVertexes wave 194 sin 0 3 0 .4
	{
	map textures/morphed/flagblue.tga
	rgbGen vertex
	}
	}

e8teamcolor
	{
	qer_editorimage textures/morphed/e8support02c_shirt.jpg
	map textures/morphed/e8support02c.tga
		{
		map $lightmap
		rgbGen identity
		}
	}
	
thrust
{
	{
		surfaceparam nolightmap
		surfaceparam pointlight
		map textures/thrust.tga
		tcMod scroll 0 5
	}
}

