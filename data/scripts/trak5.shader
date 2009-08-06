textures/trak5/glass
{
	qer_editorimage textures/trak5/glass.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5

	{
		map textures/trak5/glass.tga
		blendfunc add
		//rgbGen vertex
		tcgen environment
		tcmod scale 4 4
	}	
}
