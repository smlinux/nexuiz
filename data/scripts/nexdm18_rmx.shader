textures/skies/nex18_rmx
{
	qer_editorimage env/stralenex5/b_sky_up.tga
	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky
	skyparms env/stralenex5/b_sky - -
	q3map_surfacelight 100
	q3map_lightimage textures/stralenex5/b_sky_up.tga
	q3map_sun .69 .75 .97 160 0 90
}

textures/stralenex1/stralenex5_fakesky
{
	qer_editorimage textures/stralenex1/stralenex5_fakesky.tga
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	//	<div><func><base><amplitude><phase><freq>
	//deformVertexes wave 8000.0 sin 64 1000 0 5
	Q3map_TessSize 128
	cull none
	{
		map textures/stralenex1/stralenex5_fakesky.tga
		blendFunc add
		rgbGen identity
	}
}
