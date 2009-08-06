// Maj Notes
// =========
// Changes:
// * Indentation fixed
// * rgbgen identity's that weren't needed were removed
// * For all alphafunc'd shaders:
//   o Added surfaceparm trans, alphashadow and nomarks
//   o Removed blendfunc's that weren't needed because they were in the same stage as a alphafunc
//   o Changed alphafunc GT0's to GE128 - GT0 didn't look right
// * Changed all GL_ONE_MINUS_SRC_ALPHA GL_SRC_ALPHA's to blend (they do the same thing)
// * Changed all GL_DST_COLOR GL_ZERO's to filter (they do the same thing)
// * Duplicate of textures/evil_floor/flr_drmtlodhlz renamed to flr_mtlhls
// * Changed textures/evil_floor/tekconfllr_fx to use alphafunc rather then alpha blending
// * Removed unnecessary blendfunc blend's from first stage of all lights
// * Changed a flr_drmtlodhlz.tga to flr_dkmtlodhlz.tga (was drm instead of dkm)

//floors

textures/evil5_floor/confllrtile2pad
{
	{
		map textures/evil5_floor/confllrtile2pad.tga
		blendFunc blend
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/evil5_floor/tekconfllr_fx
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	cull none
	{
		map textures/evil5_floor/tekconfllr_fx.tga
		tcmod scroll 0 .9
		alphafunc GE128
		depthwrite
	}
	{
		map textures/evil5_floor/tekconfllr.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		blendfunc filter
		depthfunc equal
	}
}
