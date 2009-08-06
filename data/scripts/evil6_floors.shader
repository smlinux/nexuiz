textures/evil6_floors/e6bsegrtflr128_s
{
	qer_editorimage textures/evil6_floors/e6bsegrtflr128.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6bsegrtflr128.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6bsegrtflr256_s
{
	qer_editorimage textures/evil6_floors/e6bsegrtflr256.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6bsegrtflr256.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate_flr_b_s
{
	qer_editorimage textures/evil6_floors/e6grate_flr_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate_flr_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate_flr_s
{
	qer_editorimage textures/evil6_floors/e6grate_flr.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate_flr.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grtfloorceil_s
{
	qer_editorimage textures/evil6_floors/e6grtfloorceil.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grtfloorceil.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate2_flr_s
{
	qer_editorimage textures/evil6_floors/e6grate2_flr.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate2_flr.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6grate2_flr_b_s
{
	qer_editorimage textures/evil6_floors/e6grate2_flr_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6grate2_flr_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6launchcfloor
{
	q3map_lightimage textures/evil6_floors/e6launchcfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	
	{
		map textures/evil6_floors/e6launchcfloor
		animmap 10 textures/evil6_floors/e6launchcfloor textures/evil6_floors/e6launchcfloor-1 textures/evil6_floors/e6launchcfloor-2 textures/evil6_floors/e6launchcfloor-3 textures/evil6_floors/e6launchcfloor-4 textures/evil6_floors/e6launchcfloor-5 textures/evil6_floors/e6launchcfloor-6 textures/evil6_floors/e6launchcfloor-7
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}

}

textures/evil6_floors/e6launchcfloor_s
{
	qer_editorimage textures/evil6_floors/e6launchcfloor.tga
	q3map_lightimage textures/evil6_floors/e6launchcfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	{
		map textures/evil6_floors/e6launchcfloor.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6launchcfloor_glow.tga
		blendfunc add
		rgbgen wave sin .5 .8 0 1.5
	}
	{
		clampmap textures/evil6_floors/e6launchcfloor_fx.tga
		blendfunc add
		tcMod stretch sin 1.2 .9 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

textures/evil6_floors/e6launchengine_s
{
	qer_editorimage textures/evil6_floors/e6launchengine.tga
	q3map_lightimage textures/evil6_floors/e6launchengine_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	
	{
		map textures/evil6_floors/e6launchengine
		animmap 10 textures/evil6_floors/e6launchengine textures/evil6_floors/e6launchengine-1 textures/evil6_floors/e6launchengine-2 textures/evil6_floors/e6launchengine-3 textures/evil6_floors/e6launchengine-4 textures/evil6_floors/e6launchengine-5 textures/evil6_floors/e6launchengine-6 textures/evil6_floors/e6launchengine-7
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}

}

textures/evil6_floors/e6launchengine
{
	qer_editorimage textures/evil6_floors/e6launchengine.tga
	q3map_lightimage textures/evil6_floors/e6launchengine_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	
	{
		map textures/evil6_floors/e6launchengine
		animmap 10 textures/evil6_floors/e6launchengine textures/evil6_floors/e6launchengine-1 textures/evil6_floors/e6launchengine-2 textures/evil6_floors/e6launchengine-3 textures/evil6_floors/e6launchengine-4 textures/evil6_floors/e6launchengine-5 textures/evil6_floors/e6launchengine-6 textures/evil6_floors/e6launchengine-7
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}

}

textures/evil6_floors/e6launchlfloor_s
{
	qer_editorimage textures/evil6_floors/e6launchlfloor.tga
	q3map_lightimage textures/evil6_floors/e6launchlfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	{
		map textures/evil6_floors/e6launchlfloor.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6launchlfloor_glow.tga
		blendfunc add
		rgbgen wave sin .5 .8 0 1.5
	}
	{
		clampmap textures/evil6_floors/e6launchlfloor_fx.tga
		blendfunc add
		tcMod stretch sin 1.2 .9 0 1.5
		rgbGen wave square .5 .5 .25 1.5
	}
}

textures/evil6_floors/e6launchlfloor
{
	qer_editorimage textures/evil6_floors/e6launchlfloor.tga
	q3map_lightimage textures/evil6_floors/e6launchlfloor_glow.tga
	q3map_surfacelight 400
	surfaceparm nomarks
	
	{
		map textures/evil6_floors/e6launchlfloor
		animmap 10 textures/evil6_floors/e6launchlfloor textures/evil6_floors/e6launchlfloor-1 textures/evil6_floors/e6launchlfloor-2 textures/evil6_floors/e6launchlfloor-3 textures/evil6_floors/e6launchlfloor-4 textures/evil6_floors/e6launchlfloor-5 textures/evil6_floors/e6launchlfloor-6 textures/evil6_floors/e6launchlfloor-7
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}

}

textures/evil6_floors/e6tekmtlrflr_h_full_slow
{
	qer_editorimage textures/evil6_floors/e6tekmtlrflr_h.tga
	{
		map textures/evil6_floors/e6tekmtlrflr_h.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6tekmtlrflr_h_glow.tga
		rgbgen wave sin .5 .5 0 .2
		blendfunc add
	}
}

textures/evil6_floors/e6tekmtlrflr_h_small_noisy_fast
{
	qer_editorimage textures/evil6_floors/e6tekmtlrflr_h.tga
	{
		map textures/evil6_floors/e6tekmtlrflr_h.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_floors/e6tekmtlrflr_h_glow.tga
		rgbgen wave noise .9 .2 0 4
		blendfunc add
	}
}

textures/evil6_floors/e6xgratebasic_b_s
{
	qer_editorimage textures/evil6_floors/e6xgratebasic_b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6xgratebasic_b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

textures/evil6_floors/e6xgratebasic_s
{
	qer_editorimage textures/evil6_floors/e6xgratebasic.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_floors/e6xgratebasic.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}