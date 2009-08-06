textures/evil6_support/e6h_support_s
{
	qer_editorimage textures/evil6_support/e6h_support.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6h_support.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6holestrip_s
{
	qer_editorimage textures/evil6_support/e6holestrip.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6holestrip.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6vertgrt_supp_s_nolight
{
	qer_editorimage textures/evil6_support/e6vertgrt_supp.tga
	q3map_lightimage textures/evil6_support/e6vertgrt_supp_fx.tga
	surfaceparm nomarks
	{
		map textures/evil6_support/e6vertgrt_supp.tga
	}
	{
		map textures/evil6_support/e6vertgrt_supp_fx.tga
		tcmod scroll 0 2
		blendfunc add
	}
	{
		map textures/evil6_support/e6vertgrt_supp.tga
		blendfunc blend
	}
	{
		map $lightmap
		blendfunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
	}
}

textures/evil6_support/e6vlight_supp_s_nolight
{
	qer_editorimage textures/evil6_support/e6vlight_supp.tga
	surfaceparm nomarks
	{
		map textures/evil6_support/e6vlight_supp.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/evil6_support/e6x_supprt_s
{
	qer_editorimage textures/evil6_support/e6x_supprt.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6x_supprt.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_support/e6xrst_supprt_s
{
	qer_editorimage textures/evil6_support/e6xrst_supprt.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_support/e6xrst_supprt.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}
