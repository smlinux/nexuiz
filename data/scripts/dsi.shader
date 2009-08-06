textures/dsi/weapspawn01
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	nopicmip
	{
		clampmap textures/dsi/weapspawn01.tga
		blendfunc add
		rgbGen Vertex
		tcMod rotate 45
	}
}

textures/dsi/dsiglass
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

textures/dsi/cmp1_logo
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	nopicmip
	{
		map textures/dsi/cmp1_logo.tga
		blendfunc add
		rgbGen Vertex
	}
}
