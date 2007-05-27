textures/liquids/dsiwater_ripple
{
	qer_editorimage textures/liquids/pool3d_3c.tga
	qer_trans .5
	q3map_globaltexture
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	cull disable
	deformVertexes wave 64 sin .5 .5 0 .5
	{
		map textures/liquids/pool3d_5c.tga
		blendFunc GL_dst_color GL_one
		rgbgen identity
		tcmod scale .5 .5
		tcmod transform 1.5 0 1.5 1 1 2
		tcmod scroll -.05 .001
	}
	{
		map textures/liquids/pool3d_6c.tga
		blendFunc GL_dst_color GL_one
		rgbgen identity
		tcmod scale .5 .5
		tcmod transform 0 1.5 1 1.5 2 1
		tcmod scroll .025 -.001
	}
	{
		map textures/liquids/pool3d_3c.tga
		blendFunc GL_dst_color GL_one
		rgbgen identity
		tcmod scale .25 .5
		tcmod scroll .001 .025
	}
	{
		map $lightmap
		blendFunc GL_dst_color GL_zero
		rgbgen identity
	}
}

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
	{
		map textures/dsi/weapspawn01.blend.tga
		blendfunc add
		rgbGen Vertex
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
