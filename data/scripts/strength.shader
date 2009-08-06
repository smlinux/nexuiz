//modified texture textures/evil6_lights/36walllight_s_nolight

textures/skies/strength-sky
{
	qer_editorimage env/strength-sky/strength_up.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/strength-sky/strength - -
	q3map_surfacelight 50
	q3map_lightimage textures/strength/strength_up.tga
	//q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>
	q3map_sun 1 .9 0.84 400 300 65

}

textures/skies/desert
{
	qer_editorimage env/desert/desert_rt.tga

	surfaceparm nolightmap
	surfaceparm noimpact
	surfaceparm nomarks
	surfaceparm sky

	skyparms env/desert/desert - -
	q3map_surfacelight 50
	q3map_lightimage textures/desert/desert_up.tga
	//q3map_sun <red> <green> <blue> <intensity> <degrees> <elevation>
	q3map_sun 1 .92 0.88 400 300 65

}

textures/strength/light_slots-1
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-2
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-3
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-4
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-5
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-6
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-7
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-8
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 textures/strength/light_slots-2 

	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-9
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots textures/strength/light_slots-1 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light_slots-10
{
	qer_editorimage textures/strength/light_slots.tga
	q3map_lightimage textures/strength/light_slots_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light_slots.tga
		animmap 10 textures/strength/light_slots-1 textures/strength/light_slots-2 textures/strength/light_slots-3 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots-4 textures/strength/light_slots 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light-liney-1
{
	qer_editorimage textures/strength/light-lineya.tga
	q3map_lightimage textures/strength/light-liney_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light-liney.tga
		animmap 10 textures/strength/light-liney-3 textures/strength/light-liney-4 textures/strength/light-liney-5 textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney-1 textures/strength/light-liney-2 
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

//modified texture/evil8_lights/e8btrimlight

textures/strength/light-liney-2
{
	qer_editorimage textures/strength/light-lineya.tga
	q3map_lightimage textures/strength/light-liney_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light-liney.tga
		animmap 10 textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney-1 textures/strength/light-liney-2 textures/strength/light-liney-3 textures/strength/light-liney-4 textures/strength/light-liney-5
 	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/light-liney-3
{
	qer_editorimage textures/strength/light-lineya.tga
	q3map_lightimage textures/strength/light-liney_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 400
	
	{
		map textures/strength/light-liney.tga
		animmap 10 textures/strength/light-liney textures/strength/light-liney-1 textures/strength/light-liney-2 textures/strength/light-liney-3 textures/strength/light-liney-4 textures/strength/light-liney-5 textures/strength/light-liney textures/strength/light-liney textures/strength/light-liney
 	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}

textures/strength/eX_cretefloor_01glow
{
	qer_editorimage textures/strength/eX_cretefloor_01glow.tga
	q3map_lightimage textures/strength/eX_cretefloor_01glow_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 200
	
	{
		map textures/strength/eX_cretefloor_01glow.tga
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
	}

}


textures/strength/whitelight
{
	qer_editorimage textures/eX/eX_light_u201.tga
	q3map_surfacelight 1750
	surfaceparm nomarks
	{
		map textures/eX/eX_light_u201.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/eX/eX_light_u201_glow.tga
		blendfunc add
	}
}

textures/strength/strength_ylight
{
	qer_editorimage textures/strength/strength_ylight.tga
	q3map_lightimage textures/strength/strength_ylight_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 900
	{
		map textures/strength/strength_ylight.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/strength/strength_yglow
{
	qer_editorimage textures/strength/strength_ylight_glow.tga
	q3map_lightimage textures/strength/strength_ylight_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 10
	{
		map textures/strength/strength_ylight_glow.tga
	}
	{
		map $lightmap
		blendfunc add
		tcGen lightmap
	}
}

textures/strength/strength_rlight
{
	qer_editorimage textures/strength/strength_rlight.tga
	q3map_lightimage textures/strength/strength_rlight_glow.tga
	surfaceparm nomarks
	q3map_surfacelight 900
	{
		map textures/strength/strength_rlight.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/strength/strength_jp
{
	q3map_lightimage textures/strength/strength_jp_glow.tga
	surfaceparm metalsteps
	q3map_surfacelight 400
	
	{
		map textures/strength/strength_jp
		animmap 10 textures/strength/strength_jp textures/strength/strength_jp-1 textures/strength/strength_jp-2 textures/strength/strength_jp-3 textures/strength/strength_jp-4 textures/strength/strength_jp-5 textures/strength/strength_jp-6
	}
	{
		map $lightmap
		tcGen lightmap
		blendfunc filter
	}
}

textures/strength/e8circle_yellow
{
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	{
		map textures/strength/e8circle_yellow.tga
		blendfunc add
		rgbGen identity
	}
}

textures/strength/e8beam_yellow
{
	qer_editorimage textures/strength/e8beam_yellow.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm nonsolid
	surfaceparm trans
	cull disable
	qer_trans 0.6
	{
		map textures/strength/e8beam_yellow.tga
		blendfunc add
		tcMod scroll 0.3 0
	}
}

textures/strength/e6redmtl_light
{
	qer_editorimage textures/strength/e6redmtl_light.tga
	q3map_lightimage textures/strength/e6redmtl_light_glow.tga
	q3map_surfacelight 800
	surfaceparm nomarks
	{
		map textures/strength/e6redmtl_light.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/strength/e6redmtl_light_glow.tga
		blendfunc add
	}
}

textures/strength/sand
{
	q3map_nonplanar
	q3map_shadeAngle 75
	{
		map textures/strength/sand
		rgbGen vertex
	}
}

//can be removed if added

textures/evil6_walls/e6girdergrate2b-trans
{
	qer_editorimage textures/evil6_walls/e6girdergrate2b-trans.tga
	surfaceparm alphashadow
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull disable
	nopicmip
	{
		map textures/evil6_walls/e6girdergrate2b-trans.tga
		rgbGen identity
		depthWrite
		alphafunc GE128
	}
	{
		map $lightmap
		blendfunc filter
		rgbGen identity
		tcGen lightmap
		depthFunc equal
	}
}

textures/evil6_lights/e6v_light_s_2k
{
	qer_editorimage textures/evil6_lights/e6v_light.jpg
	q3map_surfacelight 2000
	surfaceparm nomarks
	{
		map textures/evil6_lights/e6v_light.jpg
	}
	{
		map $lightmap
		blendfunc filter
	}
	{
		map textures/evil6_lights/e6v_light_glow.jpg
		blendfunc add
	}
}

