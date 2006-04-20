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
		map textures/base_wall/chrome_env.tga
		tcGen environment
		tcmod scale .25 .25
	}
	{
		map textures/evil5_floor/confllrtile2pad.tga
		blendFunc blend
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/evil5_floor/contekfllr
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/contekfllr2
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr2.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/contekfllr2b
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr2b.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/contekfllr_b
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr_b.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/contekfllr_c
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr_c.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/contekfllr_single
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/contekfllr_single.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/flr_drmtlodhlz
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/flr_dkmtlodhlz.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/flr_mtlhls
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/flr_mtlhls.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_floor/flr_rstmtlhls
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil5_floor/flr_rstmtlhls.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
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

//Misc

textures/evil5_misc/pallette_top
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	cull none
	{
		map textures/evil5_misc/pallette_top.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_misc/pallette_side
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	cull none
	{
		map textures/evil5_misc/pallette_side.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

//Trims and steps (lights)

textures/evil5_trim/trim_light_drkrst
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/trim_light_drkrst.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/trim_light_drkrst_glow.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_trim/stepside_mtl4light
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/stepside_mtl4light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/stepside_mtl4light_glw.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_trim/stepside_mtllight
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/stepside_mtllight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/stepside_mtllight_blnd.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

//walls (lights)

textures/evil5_wall/crete_tblight
{
	q3map_surfacelight 100
	{
		map textures/evil5_wall/crete_tblight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_wall/crete_tblight_blend.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_misc/pallette_side
{
	surfaceparm trans
	surfaceparm alphashadow
	surfaceparm nomarks
	cull none
	{
		map textures/evil5_misc/pallette_side.tga
		alphaFunc GE128
		depthWrite
	}
	{
		map $lightmap
		blendFunc filter
		depthFunc equal
	}
}

textures/evil5_trim/trim_light_drkrst
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/trim_light_drkrst.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/trim_light_drkrst_glow.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_trim/stepside_mtl4light
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/stepside_mtl4light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/stepside_mtl4light_glw.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_trim/stepside_mtllight
{
	q3map_surfacelight 100
	{
		map textures/evil5_trim/stepside_mtllight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_trim/stepside_mtllight_blnd.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}

textures/evil5_wall/crete_tblight
{
	q3map_surfacelight 100
	{
		map textures/evil5_wall/crete_tblight.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil5_wall/crete_tblight_blend.tga
		blendFunc add
		rgbGen wave sin .5 .5 0 1
	}
}