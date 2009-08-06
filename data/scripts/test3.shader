
textures/test3/terrain_0
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5
	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_surfaceModel models/grass02.md3 24 0.025 1.5 3 1 122 1
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/grass2.tga
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_1
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5
	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/ground2.tga

	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_2
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5
	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/rock02b.tga

	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_3
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/ground4.tga

	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_4
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/sand01.tga

	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	{
		map textures/terraintex/rock_b.tga

	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_0to1
{
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
	q3map_nonplanar
	q3map_globalTexture
	q3map_surfaceModel models/grass02.md3 38 0.025 1 2 1 122 1
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/grass2.tga

	}
	{
		map textures/terraintex/ground2.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_0to2
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/grass2.tga

	}
	{
		map textures/terraintex/rock02b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_0to3
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/grass2.tga

	}
	{
		map textures/terraintex/ground4.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_0to4
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/grass2.tga
	}
	{
		map textures/terraintex/sand01.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_0to5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/grass2.tga
	}
	{
		map textures/terraintex/rock_b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_1to2
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground2.tga
	}
	{
		map textures/terraintex/rock02b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_1to3
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground2.tga
	}
	{
		map textures/terraintex/ground4.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_1to4
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground2.tga
	}
	{
		map textures/terraintex/sand01.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_1to5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground2.tga
	}
	{
		map textures/terraintex/rock_b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_2to3
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/rock02b.tga
	}
	{
		map textures/terraintex/ground4.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_2to4
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/rock02b.tga
	}
	{
		map textures/terraintex/sand01.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_2to5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/rock02b.tga
	}
	{
		map textures/terraintex/rock_b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_3to4
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground4.tga
	}
	{
		map textures/terraintex/sand01.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_3to5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/ground4.tga
	}
	{
		map textures/terraintex/rock_b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

textures/test3/terrain_4to5
{
	q3map_nonplanar
	q3map_globalTexture
	q3map_shadeangle 179
	q3map_lightmapsamplesize 32
	q3map_lightmapaxis z
	q3map_lightmapBrightness 0.5

	q3map_lightmapsampleoffset 8.0
//	q3map_texturesize 512 512
	q3map_tcGen ivector ( 384 0 0 ) ( 0 384 0 )
	
	{
		map textures/terraintex/sand01.tga
	}
	{
		map textures/terraintex/rock_b.tga
		alphaGen vertex
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		tcGen lightmap
		//rgbGen identity
	}
}

//textures/test3/terrain.vertex
//{
//	{
//		map textures/terraintex/grass2.tga
//		rgbGen vertex
//	}
//}