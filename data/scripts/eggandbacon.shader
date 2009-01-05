textures/eggandbacon/eggandbacon_sky
{
	qer_editorimage env/stralenex8/darkblue_up.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_sun 1 .98 .9 10 0 90
	skyparms env/stralenex8/darkblue - -
}

textures/eggandbacon/upsign
{
	qer_editorimage textures/eggandbacon/upsign.tga
	surfaceparm nonsolid
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/eggandbacon/upsign.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/eggandbacon/light_bottom
{
	qer_editorimage textures/evil6_lights/e6v_light.tga
	surfaceparm nonsolid
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil6_lights/e6v_light.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/eggandbacon/light_side
{
	qer_editorimage textures/eggandbacon/black.tga
	surfaceparm nonsolid
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/eggandbacon/black.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}
