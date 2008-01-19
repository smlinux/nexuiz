// H.Reaper Q3Shader File V 1.5

//Multisampling & High Lightmap resolution

textures/Reaptxt/yellowgrad
{
	qer_editorimage textures/Reaptxt/yellowgrad
	surfaceparm nonsolid
	{
		map textures/Reaptxt/yellowgrad
		blendfunc add	
	}
}

textures/Reaptxt/Notext
{
	qer_editorimage textures/Reaptxt/Notext.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/Notext.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/solsjrA
{
	qer_editorimage textures/Reaptxt/solsjrA.tga
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/solsjrA.tga
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/p1sjr
{
	qer_editorimage textures/Reaptxt/p1sjr.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/p1sjr.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/frizsjr
{
	qer_editorimage textures/Reaptxt/frizsjr.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/frizsjr.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/p1chbr
{
	qer_editorimage textures/Reaptxt/p1chbr.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/p1chbr.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling, BumpMapping Lightmap Emulation & High Lightmap resolution

textures/Reaptxt/tuilestoit
{
	qer_editorimage textures/Reaptxt/tuilestoit.tga
	q3map_lightmapSampleSize 1
	q3map_normalimage textures/Reaptxt/tuilestoit_norm.tga
	{
		map textures/Reaptxt/tuilestoit.tga
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/murext
{
	qer_editorimage textures/Reaptxt/murext.tga
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/murext.tga
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling, BumpMapping Lightmap Emulation & High Lightmap resolution

textures/Reaptxt/brownstone
{
	qer_editorimage textures/Reaptxt/brownstone.jpg
	q3map_lightmapSampleSize 1
	q3map_normalImage textures/Reaptxt/brownstone_norm.jpg
	{
		map textures/Reaptxt/brownstone.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaptxt/Notext2
{
	qer_editorimage textures/Reaptxt/Notext2.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaptxt/Notext2.jpg
		rgbGen identity
	}
	{
		map textures/Reaptxt/detail.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaper_dirt/grass7
{
	qer_editorimage textures/Reaper_dirt/grass7.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaper_dirt/grass7.jpg
		rgbGen identity
	}
	{
		map textures/Reaper_dirt/grass7.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Multisampling & High Lightmap resolution

textures/Reaper_dirt/grass8
{
	qer_editorimage textures/Reaper_dirt/grass8.jpg
	q3map_lightmapSampleSize 1
	{
		map textures/Reaper_dirt/grass8.jpg
		rgbGen identity
	}
	{
		map textures/Reaper_dirt/grass8.jpg
		blendfunc gl_dst_color gl_src_color
		rgbGen identity
		tcMod scale 2 2
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}
}

//Corona Shader, texture by HipShot

textures/Reaptxt/HSglow01
{
	qer_editorimage textures/Reaptxt/HSglow01.jpg
	surfaceparm trans
	surfaceparm nonsolid
	cull disable
	surfaceparm nomarks
	surfaceparm nolightmap
	deformVertexes autosprite
	{
		clampmap textures/Reaptxt/HSglow01.jpg
		tcMod stretch sin .8 0.2 0 .2
		tcmod rotate 5
		blendFunc add
		rgbGen identity
	}
}

//EnvBox Shader, EnvBox by HipShot

textures/Reaptxt/rnorm
{
	surfaceparm noimpact
	surfaceparm nolightmap
	q3map_sunExt 1 .5 0 75 350 20 2 16
	q3map_skyLight 135 4
	qer_editorimage textures/Reaptxt/rnorm.jpg
	skyparms textures/Reaptxt/env/restnormal - -
}

//Fog Shader

textures/Reaptxt/fog_restdusk
{
	qer_editorimage textures/Reaptxt/fog_restdusk.jpg
	surfaceparm	trans
	surfaceparm	nonsolid
	surfaceparm	fog
	surfaceparm	nolightmap
	fogparms ( .177 .173 .21 ) 128
}

//Fog Shader

textures/Reaptxt/fog_restnormal
{
	qer_editorimage textures/Reaptxt/fog_restnormal.jpg
	surfaceparm	trans
	surfaceparm	nonsolid
	surfaceparm	fog
	surfaceparm	nolightmap
	fogparms ( .997 .985 .863 ) 1024
}

//Corona Shader, texture by HipShot

textures/Reaptxt/sun
{
	qer_editorimage textures/Reaptxt/sun.jpg
	cull disable
	surfaceparm nonsolid
	surfaceparm nomarks
	surfaceparm nolightmap
	deformVertexes autosprite
	{
		clampmap textures/Reaptxt/sun.jpg
		//    tcMod stretch sin .2 0.2 0 .2
		tcmod rotate 5
		blendFunc add
		rgbGen identity
	}
}

//Alpha Channel, Texture by Lud

textures/research_detail/lud_atomic.tga
{
	qer_editorimage textures/research_detail/lud_atomic.tga
	qer_trans 0.5
	cull none
	surfaceparm playerclip
	{
		map textures/research_detail/lud_atomic.tga
		blendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
		rgbGen vertex
	}
}

//Volumetric Shadow

textures/shad/shad
{
	qer_editorimage textures/shad/shad.tga
	surfaceparm alphashadow
	surfaceparm nolightmap
	surfaceparm nonsolid
	surfaceparm trans
	{
		map *default
		alphaFunc GT0
		alphagen const 0.0
	}
}

//Corona for lud_Corona.tga
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/lud_Corona
{
	qer_editorimage textures/Reaptxt/lud_Corona.tga
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/lud_Corona.jpg
		blendFunc add
		rgbGen identity
	}
}

//Corona for sun.tga by HipShot
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/sun
{
	qer_editorimage textures/Reaptxt/sun.jpg
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/sun.jpg
		blendFunc add
		rgbGen identity
	}
}

//Water for Q3texture, temp use.
//This shader is for DarkPlaces Engine - Nexuiz

textures/water/pool3d_5e
{
	qer_editorimage textures/water/pool3d_5e.jpg
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm water
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/water/pool3d_5e.jpg
		blendFunc add
		rgbGen vertex
	}
}

//Water for Q3texture, temp use.
//This shader is for DarkPlaces Engine - Nexuiz

textures/liquids/slime1
{
	qer_editorimage textures/liquids/slime1.jpg
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm slime
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/liquids/slime1.jpg
		blendFunc add
		rgbGen identity
	}
}

textures/liquids/protolava
{
	qer_editorimage textures/liquids/protolava.jpg
	qer_trans 0.5
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm lava
	deformVertexes wave 150.0 sin 2 5 0.25 0.1
	Q3map_TessSize 128
	cull none
	{
		map textures/liquids/protolava.jpg
		blendFunc add
		rgbGen identity
	}
}

//Corona for HRglow01.tga
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/HRglow01
{
	qer_editorimage textures/Reaptxt/HRglow01.tga
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/HRglow01.tga
		blendFunc add
		rgbGen identity
	}
}

//Corona for HRglow02.tga
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/HRglow02
{
	qer_editorimage textures/Reaptxt/HRglow02.tga
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/HRglow02.tga
		blendFunc add
		rgbGen identity
	}
}

//Corona for HRglow03.tga
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/HRglow03
{
	qer_editorimage textures/Reaptxt/HRglow03.tga
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/HRglow03.tga
		blendFunc add
		rgbGen identity
	}
}

//Corona for HRsun01.tga
//This shader is for DarkPlaces Engine - Nexuiz

textures/Reaptxt/HRsun01
{
	qer_editorimage textures/Reaptxt/HRsun01.tga
	surfaceparm trans
	surfaceparm nonsolid
	surfaceparm nolightmap
	deformVertexes autosprite
	cull disable
	{
		clampmap textures/Reaptxt/HRsun01.tga
		blendFunc add
		rgbGen identity
	}
}

//EnvBox Shader, EnvBox by H.Reaper

textures/Reaptxt/HRSky
{
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm sky
	surfaceparm nomarks
	q3map_sunExt 0 .7 3 10 360 80 2 16
	q3map_skyLight 50 3
	qer_editorimage textures/Reaptxt/HRSky.jpg
	skyparms env/rsky - -
}

textures/Reaptxt/HRBlackBoxSky
{
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm sky
	surfaceparm nomarks
	qer_editorimage env/blackbox/blackbox_up.jpg
	skyparms env/blackbox - -
}
