race/cliff
{
        qer_editorimage textures/race/cliff02.tga
	
	q3map_nonplanar
	q3map_shadeangle 120
	q3map_globalTexture
	q3map_lightmapsampleoffset 10
	q3map_alphaMod dotproduct2 ( 0 0 0.80 )
	{
		map textures/race/cliff02.tga	// Primary
		tcmod scale 2 2
		rgbGen identity
	}
	{
		map textures/race/ground.tga	// Secondary
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		tcmod scale 2 2
		rgbGen identity
		alphaGen vertex
	}
	{
		map $lightmap
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
}

textures/race/track02
{
 qer_editorimage textures/race/track02.tga
		{
		map $lightmap
		rgbGen identity
	    }

 {
	map textures/race/track02.tga
 }
}


textures/race/tunel01
{
 qer_editorimage textures/race/tunel01.tga
		{
		map $lightmap
		rgbGen identity
	    }
 {
	map textures/race/tunel01.tga
 }
}

race/clouds1
{
qer_editorimage textures/race/cloud1.tga
 {
	map textures/race/cloud1.tga
	tcMod scroll 0.03 0
	blendfunc blend
 }
}
race/clouds2
{
qer_editorimage textures/race/cloud2.tga
 {
	map textures/race/cloud2.tga
	tcMod scroll 0.021 0
	blendfunc blend
 }
}
race/clouds3
{
qer_editorimage textures/race/cloud3.tga
 {
	map textures/race/cloud3.tga
	tcMod scroll 0.011 0
	blendfunc blend
 }
}

race/arrow
{
qer_editorimage textures/race/arrow.tga
 {
	map textures/race/arrow.tga
	tcMod scroll 0 2
	blendfunc add
 }
}

textures/race/nicesky
{
	qer_editorimage env/med-troubadour-gray/med-troubadour-gray_up.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm sky
	surfaceparm nomarks
	q3map_sunExt .5 .5 .7 100 0 86 3 16
	q3map_skylight 150 3
	skyparms env/med-troubadour-gray/med-troubadour-gray - -
}