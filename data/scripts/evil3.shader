// Original shader created by Yves Allaire,
// for Evil's Texture Set 3.
// [+] http://www.planetquake.com/hfx/
// Cleaned up and fixed by Gary Burgess.
// [+] http://www.inaeo.co.uk/cnd/
//NOTE FROM Yves: Please edit this .shader all you want, there might have some problems...
//--------------------------------------------

textures/evil_floors/mtl-wlkway
{
	surfaceparm metalsteps
	surfaceparm trans
	cull none
	nopicmip
	{
		map textures/evil_floors/mtl-wlkway.tga
		blendFunc GL_ONE GL_ZERO
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

//-------------------------------------------------

textures/evil_floors/mtl-wlkway_end
{
	surfaceparm metalsteps
	surfaceparm trans
	cull none
	nopicmip
	{
		map textures/evil_floors/mtl-wlkway_end.tga
		blendFunc GL_ONE GL_ZERO
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

//---------------------------------------------

textures/evil_floors/mtl-wlkway_mid
{
	surfaceparm metalsteps
	surfaceparm trans
	cull none
	nopicmip
	{
		map textures/evil_floors/mtl-wlkway_mid.tga
		blendFunc GL_ONE GL_ZERO
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc GL_DST_COLOR GL_ZERO
		depthFunc equal
	}
}

//------------------------------------------

textures/evil_floors/t-flr_oddtile_drty
{
	{
		map textures/evil_floors/t-flr_oddtile_drty_glow.tga
		tcMod turb 1 1 1 1
		tcmod scale 2 1
		tcmod scroll 1 2
		blendFunc GL_ONE GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil_floors/t-flr_oddtile_drty.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//-------------------------------------------------

textures/evil_floors/cemtiledrk_mhbrk
{
	{
		map textures/evil_floors/cemtiledrk_mhbrk_glow.tga
		tcMod turb 1.2 1 1.2 1
		tcmod scale 0 0
		tcmod scroll .1 .1
		blendFunc GL_ONE GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil_floors/cemtiledrk_mhbrk.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}

//-----------------------------------

textures/evil_floors/grt_offmtl
{
	surfaceparm metalsteps
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nonsolid
	cull none
	{
		map textures/evil_floors/grt_offmtl.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
		depthFunc equal
	}
}
//-------------------------------------------

textures/evil_floors/grtmtl_offt
{
	surfaceparm metalsteps
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nonsolid
	cull none
	{
		map textures/evil_floors/grtmtl_offt.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
		depthFunc equal
	}
}

//------------------------------------------

textures/evil_floors/grtmtl_offt2
{
	surfaceparm metalsteps
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nonsolid
	cull none
	{
		map textures/evil_floors/grtmtl_offt2.tga
		alphaFunc GE128
		depthWrite
		rgbGen identity
	}
	{
		map $lightmap
		rgbGen identity
		blendFunc filter
		depthFunc equal
	}
}

//----------------------------------------------

textures/evil_lights/rlight_a
{
	qer_editorimage textures/evil_lights/rlight_a.tga
	surfaceparm nomarks
	q3map_surfacelight 1500
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil_lights/rlight_a.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil_lights/rlight_a_blend.tga
		rgbGen wave sin 0.5 0.5 1 1
		blendFunc GL_ONE GL_ONE
	}
}

//--------------------------------------------

textures/evil_misc/rstbouncefan
{
	cull disable
	surfaceparm trans
	surfaceparm nolightmap
	sort 5
	{
		clampmap textures/sfx/fan3bladeb.tga
		blendFunc blend
		tcmod rotate 999
		rgbGen identity
	}
	{
		map textures/evil_misc/rstbouncefan.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen identity
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ONE_MINUS_DST_ALPHA
		rgbGen identity
	}
}