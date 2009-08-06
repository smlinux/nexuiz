textures/evil8_lights/e8minitrimlight
{
	qer_editorimage textures/evil8_lights/e8minitrimlight.tga
	surfaceparm nomarks
	q3map_surfacelight 1200
	{
		map textures/evil8_lights/e8minitrimlight.tga
	}
	{
		map $lightmap 
		blendfunc filter
		tcGen lightmap 
	}
}
textures/evil8_lights/e8tinylight2k
{
	qer_editorimage textures/evil8_lights/e8tinylight.tga
	q3map_lightimage textures/evil8_lights/e8tinylightcolor.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	{
		map textures/evil8_lights/e8tinylight.tga
	}
	{
		map $lightmap 
		blendfunc filter
		tcGen lightmap 
	}
}

textures/evil8_lights/e8tinylightblue2k
{
	qer_editorimage textures/evil8_lights/e8tinylightblue.tga
	q3map_lightimage textures/evil8_lights/e8tinylightbluecolor.tga
	surfaceparm nomarks
	q3map_surfacelight 2000
	{
		map textures/evil8_lights/e8tinylightblue.tga
	}
	{
		map $lightmap 
		blendfunc filter
		tcGen lightmap 
	}
}

textures/stralenex1/light_tube_green
{	 
	qer_editorimage textures/stralenex1/light_tube_green.tga
        q3map_lightimage textures/stralenex1/light_tube_green_glow.tga 
	q3map_surfacelight 1000	
	{
		map textures/stralenex1/light_tube_green.tga 
		//blendfunc add 
       	//tcmod scale 12 1  
		//rgbGen identity 

        
	}
	{
		map $lightmap
		rgbGen identity
	}
} 


textures/stralenex1/stralenex5_water
{ 
	qer_editorimage textures/stralenex1/stralenex5_water.tga
      qer_trans 0.5
	
	surfaceparm trans
	surfaceparm nonsolid
      surfaceparm water
	//deformVertexes wave <div> <func> <base> <amplitude> <phase> <freq>
	deformVertexes wave 150.0 sin 2 0.5 0 2
	Q3map_TessSize 128
	cull none

      {
		map textures/stralenex1/stralenex5_water.tga
            blendFunc add
            rgbGen identity
	}
}

textures/stralenex1/e6xrst_supprt
{
	qer_editorimage textures/stralenex1/e6xrst_supprt.tga
	surfaceparm nomarks
	surfaceparm trans
	cull none
	nopicmip
	{
		map textures/stralenex1/e6xrst_supprt.tga
		rgbGen identity
		depthWrite
		//alphaFunc GE128
		blendfunc blend
	}
	{
		map $lightmap 
		blendfunc filter
		rgbGen identity
		tcGen lightmap 
		depthFunc equal
	}
}


textures/stralenex1/strale_grey_box
{
	qer_editorimage env/strale_grey/ygrey_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/strale_grey/ygrey - -
	q3map_surfacelight 60
	q3map_lightimage textures/strale_grey/ygrey_up.tga
	q3map_sun .9 .9 1 70 65 78

}

textures/stralenex1/strale_brown_box
{
	qer_editorimage env/strale_grey/ygrey_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/strale_grey/ygrey - -
	q3map_surfacelight 100
	q3map_lightimage textures/strale_grey/ygrey_up.tga
	q3map_sun .75 .65 .6 130 255 80

}

textures/stralenex1/greennebula
{
	qer_editorimage env/stralenex5/greennebula_bk.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/stralenex5/greennebula - -
	q3map_surfacelight 80
	q3map_lightimage textures/stralenex5/stralenex5_up.tga
	q3map_sun 0.3 0.33 0.3 60 80 20
	/*q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>*/

}

textures/stralenex1/stralenex5
{
	qer_editorimage env/stralenex5/stralenex5_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/stralenex5/stralenex5 - -
	q3map_surfacelight 60
	q3map_lightimage textures/stralenex5/stralenex5_up.tga
	q3map_sun .627 .525 0.392 60 300 40
	/*q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>*/

}

textures/stralenex1/stralenex5_1
{
	qer_editorimage env/stralenex5/stralenex5_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/stralenex5/stralenex5 - -
	q3map_surfacelight 60
	q3map_lightimage textures/stralenex5/stralenex5_up.tga
	q3map_sun .627 .525 0.392 450 60 13
	/*q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>*/

}

textures/stralenex1/stralenex5_2
{
	qer_editorimage env/stralenex5/stralenex5_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/stralenex5/stralenex5 - -
	q3map_surfacelight 180
	q3map_lightimage textures/stralenex5/stralenex5_up.tga
	q3map_sun .627 .525 0.392 450 60 13
	/*q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>*/

}

//copied from harlequin-sky.shader
textures/harlequin_sky/strale_jf-nebula_sky
{
	qer_editorimage textures/harlequin_sky/nebula_qer1.tga
	surfaceparm sky
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	
	skyparms textures/harlequin_sky/env/nebular - -
	q3map_surfacelight 45
// note: Change the surfacelight value if you want more ambient light from the sky.
	q3map_sun 0.88 .71 .71 80 0 90
// note: Change the fourth value (80) if you want a brighter or dimmer sun
	
}

textures/stralenex1/stralenex_trimlight
{
	qer_editorimage textures/stralenex1/stralenex_trimlight.tga
	q3map_lightimage textures/stralenex1/stralenex_trimlight_glow.tga
	q3map_surfacelight 1800
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_trimlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_trimlight_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identityLighting
	}
}

textures/stralenex1/stralenex_roundlight
{
	qer_editorimage textures/stralenex1/stralenex_roundlight.tga
	q3map_lightimage textures/stralenex1/stralenex_roundlight_glow.tga
	q3map_surfacelight 4000
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_roundlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/stralenex1/stralenex_roundlight_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen wave sin .3 .1 0 0.5
	}
}

textures/evil8_lights/e8trimlight
{
	qer_editorimage textures/evil8_lights/e8trimlight.tga
	q3map_lightimage textures/evil8_lights/e8trimlight_glow.tga
	q3map_surfacelight 2000
	surfaceparm nomarks
	{
		map $lightmap
		rgbGen identity
	}
	{
		map textures/evil8_lights/e8trimlight.tga
		blendFunc GL_DST_COLOR GL_ZERO
		rgbGen identity
	}
	{
		map textures/evil8_lights/e8trimlight_glow.tga
		blendfunc GL_ONE GL_ONE
		rgbGen identityLighting
	}
}

textures/stralenex1/slimepit_ad-1
{
	qer_editorimage textures/stralenex1/slimepit_ad.tga
	q3map_lightimage textures/stralenex1/slimepit_ad_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/stralenex1/slimepit_ad-1.tga
		animmap 1 textures/stralenex1/slimepit_ad textures/stralenex1/slimepit_ad textures/stralenex1/slimepit_ad-1 textures/stralenex1/slimepit_ad-1 textures/stralenex1/slimepit_ad-2 textures/stralenex1/slimepit_ad-2 textures/stralenex1/slimepit_ad-3 textures/stralenex1/slimepit_ad-3 textures/stralenex1/slimepit_ad-4 textures/stralenex1/slimepit_ad-4 textures/stralenex1/slimepit_ad-5 textures/stralenex1/slimepit_ad-5 textures/stralenex1/slimepit_ad-6 textures/stralenex1/slimepit_ad-6 textures/stralenex1/slimepit_ad-7 textures/stralenex1/slimepit_ad-7 textures/stralenex1/slimepit_ad-8 textures/stralenex1/slimepit_ad-8 textures/stralenex1/slimepit_ad-9 textures/stralenex1/slimepit_ad-9 textures/stralenex1/slimepit_ad-10 textures/stralenex1/slimepit_ad-11 textures/stralenex1/slimepit_ad-10 textures/stralenex1/slimepit_ad-11 textures/stralenex1/slimepit_ad-10 textures/stralenex1/slimepit_ad-11 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/stralenex1/slime_rev
{
	qer_editorimage textures/stralenex1/slime_rev.tga
	q3map_lightimage textures/stralenex1/slime_rev_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/stralenex1/slime_rev.tga
		animmap 1 textures/stralenex1/slime_rev textures/stralenex1/slime_rev textures/stralenex1/slime_rev-1 textures/stralenex1/slime_rev-1 textures/stralenex1/slime_rev-2 textures/stralenex1/slime_rev-2 textures/stralenex1/slime_rev-3 textures/stralenex1/slime_rev-3
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}
