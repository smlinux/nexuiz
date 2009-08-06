//****************************************************//
//									//
//	purplenebula-cmp1.shader for Quake III		//
//	by Amethyst7 - 03.13.2002				//
//									//
//****************************************************//

textures/amethyst7/purplenebula-cmp1/purplenebula_skybox
{
	qer_editorimage textures/amethyst7/purplenebula-cmp1/purplenebula
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm sky
	q3map_sun 1.00 0.90 1.00 50 90 90
	q3map_surfacelight 70
	skyparms env/amethyst7/purplenebula-cmp1/purplenebula - -
}

//****************************************************//
//									//
//	The rest are modified from Evil_Lair's		//
//	original shader files.					//
//									//
//****************************************************//

textures/cmp1-dm8/e8trimlight2_pur
{
	qer_editorimage textures/cmp1-dm8/e8trimlight2_pur.tga
	surfaceparm nomarks
	q3map_surfacelight 500
	{
		map textures/cmp1-dm8/e8trimlight2_pur.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/cmp1-dm8/e8tinylightpur
{
	qer_editorimage textures/cmp1-dm8/e8tinylightpur.tga
	surfaceparm nomarks
	q3map_surfacelight 520
	{
		map textures/cmp1-dm8/e8tinylightpur.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/cmp1-dm8/e8lighttrim_b_pur
{
	qer_editorimage textures/cmp1-dm8/e8lighttrim_pur.tga
	surfaceparm nomarks
	q3map_surfacelight 1000
	{
		map textures/cmp1-dm8/e8lighttrim_pur.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/cmp1-dm8/e8lighttrim_pur
{
	qer_editorimage textures/cmp1-dm8/e8lighttrim_p.tga
	surfaceparm nomarks
	q3map_surfacelight 1000
	{
		map textures/cmp1-dm8/e8lighttrim_p.tga
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}

textures/cmp1-dm8/e8circle_pur
{
	qer_editorimage textures/cmp1-dm8/e8circle_pur.tga
	surfaceparm noimpact
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm nonsolid
	surfaceparm trans
	nopicmip
	q3map_surfacelight 50
	{
		clampmap textures/cmp1-dm8/e8circle_pur.tga
		blendfunc blend
		rgbGen wave sin 0.9 0.2 0 0.5
		tcMod rotate 45
	}
}

textures/cmp1-dm8/e8clangfloor
{
	surfaceparm metalsteps
	{
		map $lightmap
		rgbGen identity
		tcGen lightmap
	}
	{
		map textures/cmp1-dm8/e8clangfloor.tga
		blendfunc filter
		rgbGen identity
	}
}

textures/cmp1-dm8/logo
{
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm pointlight
	nopicmip
	{
		map textures/cmp1-dm8/logo.tga
		blendfunc add
		rgbGen wave sin 0.9 0.2 0 0.2
	}
}

textures/cmp1-dm8/ame7jp
{
	q3map_lightimage textures/cmp1-dm8/ame7jp.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	q3map_surfacelight 150
	{
		clampmap textures/cmp1-dm8/ame7jp2.tga
		blendfunc add
		tcMod rotate 20
	}
	{
		clampmap textures/cmp1-dm8/ame7jp.tga
		blendfunc add
		tcMod rotate -400
	}
}

textures/cmp1-dm8/ame7glass
{
	qer_editorimage textures/cmp1-dm8/ame7light.tga
	surfaceparm nomarks
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/cmp1-dm8/ame7light.tga
		blendfunc add
		tcGen environment
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
}
textures/cmp1-dm8/ame7glass_reflect
{
	qer_editorimage textures/cmp1-dm8/ame7light.tga
	surfaceparm nomarks
	surfaceparm trans
	qer_trans 0.5
	{
		map textures/cmp1-dm8/ame7light.tga
		blendfunc blend
		tcGen environment
	}
	{
		map $lightmap
		blendfunc filter
		tcGen lightmap
	}
	dp_reflect 0 1 0.4 1 0.5
}
