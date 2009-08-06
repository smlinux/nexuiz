textures/terrain_dotproduct2projected/leafs01-rock02
{
	qer_editorimage textures/terrain_dotproduct2projected/leafs01-rock02
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 95

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0 0 0.95 )

	{
		map textures/terrain_data/rock02.tga	// Primary
	}

	{
		map textures/terrain_data/leafs01.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/mudground01_rock01	
{
	qer_editorimage textures/terrain_dotproduct2projected/mudground01_rock01
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 60

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0 0 0.95 )

	{
		map textures/terrain_data/rock01.tga	// Primary
	}

	{
		map textures/terrain_data/mudground01.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/mudground02-rock06
{
	qer_editorimage textures/terrain_dotproduct2projected/mudground02-rock06
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 66

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0 0 0.95 )

	{
		map textures/terrain_data/rock06.tga	// Primary
	}

	{
		map textures/terrain_data/mudground02.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/sand-rock07
{
	qer_editorimage textures/terrain_dotproduct2projected/sand-rock07
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 90

	surfaceparm dust
	
	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0 0 0.8 )

	{
		map textures/terrain_data/rock07.tga	// Primary
	}

	{
		map textures/terrain_data/sand.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/snow-rock05
{
	qer_editorimage textures/terrain_dotproduct2projected/snow-rock05
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 75

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0 0 0.8 )

	{
		map textures/terrain_data/rock05.tga	// Primary
	}

	{
		map textures/terrain_data/snow01.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/mossrock02-mudground04
{
	qer_editorimage textures/terrain_dotproduct2projected/mossrock02-mudground04
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 90

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0.2 0.5 0.9 )

	{
		map textures/terrain_data/mudground04.tga	// Primary
	}

	{
		map textures/terrain_data/mossrock02.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}

textures/terrain_dotproduct2projected/grass01-rock05
{
	qer_editorimage textures/terrain_dotproduct2projected/grass01-rock05
	
	q3map_lightmapSampleOffset 8
	q3map_globalTexture
	q3map_nonplanar
	q3map_shadeangle 90

	surfaceparm dust

	q3map_tcGen ivector ( 512 0 0 ) ( 0 512 0 )
	q3map_alphaMod dotproduct2 ( 0.0 0.0 0.9 )

	{
		map textures/terrain_data/rock05.tga	// Primary
	}

	{
		map textures/terrain_data/grass01.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA		
		alphaGen vertex
	}

	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
	}
}
