textures/e8/e8weirdfx1
{
	{
		map textures/e8/e8weirdfx1.tga
		rgbGen wave sawtooth 0 1 2 3
		tcMod turb 0 0.5 0 1
		tcMod scroll 2 0
	}
	{
		map textures/e8/e8weirdfx1.tga
		blendfunc add
		rgbGen wave noise 0 1 0 0.4
		tcMod scroll 1 2
	}
}

textures/e8/e8blueglow
{
	qer_editorimage textures/e8/e8blueglow.tga
	q3map_lightimage textures/e8/e8blueglow.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 950
	{
		map textures/e8/e8blueglow.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8blueglow.blend.tga
		blendfunc add
		//rgbGen Vertex
	}
}

textures/e8/e8alphaspawn
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	{
		map textures/e8/e8alphaspawn.tga
		blendfunc add
		rgbGen Vertex
	}
}

textures/e8/e8yarrow
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	{
		map textures/e8/e8yarrow.tga
		blendfunc add
		rgbGen Vertex
	}
}

textures/e8/e8lightblue_flicker
{
	qer_editorimage textures/e8/e8tinylightblue.tga
	surfaceparm nomarks
	q3map_surfacelight 950
	{
		map textures/e8/e8tinylightblue.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8tinylightblue.blend.tga
		blendfunc add
		rgbGen wave noise 0 1 0 0.4
	}
}

//id shader modified..

textures/e8/zap_e8
{
	qer_editorimage textures/sfx/zap_scroll.tga
//q3map_surfacelight	300
	surfaceparm	trans
	surfaceparm nomarks
	surfaceparm nolightmap
	cull none
	{
		Map textures/sfx/zap_scroll.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle .8 2 0 7
		tcMod scroll 0 1
	}
	{
		Map textures/sfx/zap_scroll.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 1.4 0 5
		tcMod scale  -1 1
		tcMod scroll 0 1
	}
	{
		Map textures/sfx/zap_scroll2.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 1.4 0 6.3
		tcMod scale  -1 1
		tcMod scroll 2 1
	}
	{
		Map textures/sfx/zap_scroll2.tga
		blendFunc GL_ONE GL_ONE
		rgbgen wave triangle 1 1.4 0 7.7
		tcMod scroll -1.3 1
	}
}
//end id shader modify

textures/e8/e8lighttrim_static
{
	qer_editorimage textures/e8/e8lighttrim.tga
	//q3map_lightimage textures/e8/e8lighttrim.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	{
		map textures/e8/e8lighttrim.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8lighttrim.blend.tga
		blendfunc add
	}
}

textures/e8/e8lighttrim_glow
{
	qer_editorimage textures/e8/e8lighttrim.tga
	//q3map_lightimage textures/e8/e8lighttrim.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	{
		map textures/e8/e8lighttrim.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8lighttrim.blend.tga
		rgbGen wave sawtooth .2 1 1 .2
		blendfunc add
	}
}

textures/e8/e8lighttrim_b_static
{
	qer_editorimage textures/e8/e8lighttrim_b.tga
	//q3map_lightimage textures/e8/e8lighttrim_b.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	{
		map textures/e8/e8lighttrim_b.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8lighttrim_b.blend.tga
		blendfunc add
		//rgbGen identity
	}
}

textures/e8/e8lighttrim_b_glow
{
	qer_editorimage textures/e8/e8lighttrim_b.tga
	//q3map_lightimage textures/e8/e8lighttrim_b.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	{
		map textures/e8/e8lighttrim_b.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8lighttrim_b.blend.tga
		rgbGen wave sawtooth .2 1 1 .2
		blendfunc add
	}
}

textures/e8/e8jumpspawn02
{
	surfaceparm metalsteps
	q3map_lightimage textures/e8/e8jumpspawn02_fx.tga
	q3map_surfacelight 100
	{
		map textures/e8/e8jumpspawn02_fx.tga
		rgbGen identity
		tcMod rotate 760
	}
	{
		map textures/e8/e8jumpspawn02.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/e8jumpspawn02b
{
	q3map_lightimage textures/e8/e8jumpspawn02b_glow.tga
	surfaceparm metalsteps
	q3map_surfacelight 100
	
	{
		map textures/e8/e8jumpspawn02b
		animmap 10 textures/e8/e8jumpspawn02b textures/e8/e8jumpspawn02b-1 textures/e8/e8jumpspawn02b-2 textures/e8/e8jumpspawn02b-3 textures/e8/e8jumpspawn02b-4 textures/e8/e8jumpspawn02b-5 textures/e8/e8jumpspawn02b-6
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}
}

textures/e8/e8jumpspawn02c
{
	q3map_lightimage textures/e8/e8jumpspawn02c_glow.tga
	surfaceparm metalsteps
	q3map_surfacelight 100
	
	{
		map textures/e8/e8jumpspawn02c
		animmap 10 textures/e8/e8jumpspawn02c textures/e8/e8jumpspawn02c-1 textures/e8/e8jumpspawn02c-2 textures/e8/e8jumpspawn02c-3 textures/e8/e8jumpspawn02c-4 textures/e8/e8jumpspawn02c-5 textures/e8/e8jumpspawn02c-6
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}
}

textures/e8/e8jumpspawn02d
{
	surfaceparm metalsteps
	q3map_lightimage textures/e8/e8jumpspawn02_fx.tga
	q3map_surfacelight 100
	{
		map textures/e8/e8jumpspawn02_fx.tga
		rgbGen identity
		tcMod rotate 760
	}
	{
		map textures/e8/e8jumpspawn02d.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/e8_launchpad1
{
	surfaceparm metalsteps
	q3map_lightimage textures/e8/e8_launchpad1.blend.tga
	q3map_surfacelight 100
	{
		map textures/e8/e8_launchpad1_fx.tga
		rgbGen identity
		tcMod scroll 0 3
	}
	{
		map textures/e8/e8_launchpad1.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map textures/e8/e8_launchpad1.blend.tga
		blendfunc add
		rgbGen wave triangle 0.2 2 1 2
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/e8red_dcl
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	{
		map textures/e8/e8red_dcl.tga
		blendfunc add
		rgbGen Vertex
	}
}

textures/e8/e8blue_dcl
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	{
		map textures/e8/e8blue_dcl.tga
		blendfunc add
		rgbGen Vertex
	}
}

textures/e8/e8xgirder
{
	surfaceparm alphashadow
	surfaceparm metalsteps
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	nopicmip
	{
		map textures/e8/e8xgirder.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8xgirder_small
{
	cull disable
	{
		map textures/e8/e8xgirder_small.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8xgirder_small2
{
	cull disable
	{
		map textures/e8/e8xgirder_small2.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8mtltrim2
{
	surfaceparm alphashadow
	surfaceparm metalsteps
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8mtltrim2.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8wrntrim2
{
	surfaceparm alphashadow
	surfaceparm metalsteps
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8wrntrim2.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8mtltrim2
{
	surfaceparm alphashadow
	surfaceparm metalsteps
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8mtltrim2.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8bgrate01
{
	surfaceparm alphashadow
	surfaceparm metalsteps
	//surfaceparm trans
	//cull disable
	cull none
	{
		map textures/e8/e8bgrate01.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8rail
{
	surfaceparm alphashadow
	cull disable
	nomipmaps
	{
		map textures/e8/e8rail.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8rail2
{
	surfaceparm alphashadow
	cull disable
	nomipmaps
	{
		map textures/e8/e8rail2.tga
		rgbGen identity
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8icon_red
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8icon_red.tga
		blendfunc add
		rgbGen wave triangle 0.2 0.5 0 0.2
	}
}

textures/e8/e8icon_blue
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8icon_blue.tga
		blendfunc add
		rgbGen wave triangle 0.2 0.5 0 0.2
	}
}

textures/e8/e8scuffs1
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	qer_trans 0.4
	{
		map textures/e8/e8scuffs1.tga
		blendfunc blend
		rgbGen Vertex
		depthWrite
	}
}

textures/e8/e8circle_red
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	{
		map textures/e8/e8circle_red.tga
		blendfunc add
		rgbGen identity
	}
}

textures/e8/e8circle_blue
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	{
		map textures/e8/e8circle_blue.tga
		blendfunc add
		rgbGen identity
	}
}

textures/e8/e8circle_red_fade
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8circle_red_fade.tga
		blendfunc add
		rgbGen wave triangle 0.2 0.5 0 0.5
	}
}

textures/e8/e8circle_blue_fade
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	{
		map textures/e8/e8circle_blue_fade.tga
		blendfunc add
		rgbGen wave triangle 0.2 0.5 0 0.5
	}
}

textures/e8/e8flag_red
{
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	deformVertexes wave 30 sin 0 3 0 0.2
	deformVertexes wave 100 sin 0 3 0 0.7
	tessSize 64
	{
		map textures/e8/e8flag_red.tga
		rgbGen Vertex
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8flag_blue
{
	surfaceparm alphashadow
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	deformVertexes wave 30 sin 0 3 0 0.2
	deformVertexes wave 100 sin 0 3 0 0.7
	tessSize 64
	{
		map textures/e8/e8flag_blue.tga
		rgbGen Vertex
		depthWrite
		alphaFunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/e8/e8spawn01b
{
	{
		map textures/sfx/proto_zzztblu2.tga
		rgbGen identity
		tcMod turb 0 0.5 0 9.6
		tcMod scale 2 2
		tcMod scroll 9 5
	}
	{
		map textures/e8/e8spawn01b.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/e8trim_bluefx
{
	q3map_lightimage textures/e8/e8trimfx_b.tga
	q3map_surfacelight 100
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/e8/e8trim_bluefx.tga
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/e8/e8trimfx_b.tga
		blendfunc add
		tcMod scroll -2 0
	}
}

textures/e8/e8trim_redfx
{
	q3map_lightimage textures/e8/e8trimfx_r.tga
	q3map_surfacelight 100
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/e8/e8trim_redfx.tga
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/e8/e8trimfx_r.tga
		blendfunc add
		tcMod scroll -2 0
	}
}

textures/e8/e8evilspacetxt
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	{
		map textures/e8/e8evilspacetxt.tga
		blendfunc add
		rgbGen Vertex
	}
}

textures/e8/e8tinylight
{
	qer_editorimage textures/e8/e8tinylight.tga
	q3map_lightimage textures/e8/e8tinylight.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 950
	{
		map textures/e8/e8tinylight.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8tinylight.blend.tga
		blendfunc add
	}
}

textures/e8/e8tinylightblue
{
	qer_editorimage textures/e8/e8tinylightblue.tga
	//q3map_lightimage textures/e8/e8tinylightblue.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 950
	{
		map textures/e8/e8tinylightblue.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8tinylightblue.blend.tga
		blendfunc add
	}
}

textures/e8/e8beam
{
	qer_editorimage textures/e8/e8beam.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm nonsolid
	surfaceparm trans
	cull disable
	qer_trans 0.6
	{
		map textures/e8/e8beam.tga
		blendfunc add
		tcMod scroll 0.3 0
	}
}

textures/e8/e8beam_blue
{
	qer_editorimage textures/e8/e8beam_blue.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm nonsolid
	surfaceparm trans
	cull disable
	qer_trans 0.6
	{
		map textures/e8/e8beam_blue.tga
		blendfunc add
		tcMod scroll 0.3 0
	}
}

textures/e8/e8metal03c_shiney
{
	qer_editorimage textures/e8/e8metal03c.tga
	{
		map textures/effects/tinfx.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/e8/e8metal03c.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/ctf_e8stars
{
	qer_editorimage textures/e8/e8stars.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 10
	q3map_sun 1 0.98 0.9 15 0 90
	skyParms textures/e8/env/e8 - -
}

textures/e8/dm_e8stars
{
	qer_editorimage textures/e8/e8stars.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 30
	q3map_sun 1 0.98 0.9 55 0 90
	skyParms textures/e8/env/e8 - -
}

textures/e8/dm_e8stars2
{
	qer_editorimage textures/e8/e8stars.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_surfacelight 70
	q3map_sun 1 0.98 0.9 100 0 90
	skyParms textures/e8/env/e8 - -
}

textures/e8/e8metal_blue_shiney
{
	qer_editorimage textures/e8/e8metal_blue.tga
	{
		map textures/effects/tinfx.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/e8/e8metal_blue.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

textures/e8/e8metal_red_shiney
{
	qer_editorimage textures/e8/e8metal_red.tga
	{
		map textures/effects/tinfx.tga
		rgbGen identity
		tcGen environment
	}
	{
		map textures/e8/e8metal_red.tga
		blendfunc blend
		rgbGen identity
	}
	{
		map $lightmap
		blendfunc gl_dst_color gl_one_minus_dst_alpha
		rgbGen identity
		tcGen lightmap
	}
}

//broken shader D:

textures/e8/e8trimlight
{
	q3map_lightimage textures/e8/e8trimlight_fx.tga
	q3map_surfacelight 100
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/e8/e8trimlight.tga
		blendfunc filter
		rgbGen identity
	}
	{
		map textures/e8/e8trimlight_fx.tga
		blendfunc add
		tcMod scroll -2 0
	}
}

textures/e8/e8trimlight2
{
	qer_editorimage textures/e8/e8trimlight2.tga
	//q3map_lightimage textures/e8/e8trimlight2.blend.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	{
		map textures/e8/e8trimlight2.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	{
		map textures/e8/e8trimlight2.blend.tga
		//rgbGen wave sawtooth .2 1 1 .2
		blendfunc add
		tcMod scroll -0.7 0
	}
}