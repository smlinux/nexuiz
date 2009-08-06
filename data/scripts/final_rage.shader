textures/final_rage/lava
{
	qer_editorimage textures/final_rage/lava.tga
	surfaceparm lava
	surfaceparm noimpact
	cull disable
	q3map_surfacelight 1000
	{
		map textures/final_rage/lava.tga
	}
}

textures/final_rage/nodraw-lava
{
	qer_editorimage textures/final_rage/nd-lava.tga
	surfaceparm lava
	surfaceparm nodraw
	surfaceparm nolightmap
	surfaceparm nomarks
	surfaceparm trans
}

textures/final_rage/lt1
{
	qer_editorimage textures/final_rage/lt1.tga
	q3map_lightimage textures/final_rage/lt1_glow.tga
	surfaceparm nomarks
	q3map_lightsubdivide 8
	q3map_surfacelight 2000
	{
		map textures/final_rage/lt1.tga
	}
	{
		map $lightmap 
		blendfunc filter
		tcGen lightmap 
	}
}

textures/final_rage/lamp2-1
{
	qer_editorimage textures/final_rage/lamp2.tga
	q3map_clipmodel    
	q3map_forcemeta
	q3map_nonPlanar
	q3map_shadeAngle 70
	{
		map $lightmap 
		rgbGen identity
		tcGen lightmap 
	}
	{
		map textures/final_rage/lamp2.tga
		blendfunc filter
	}
}

textures/final_rage/lamp2-2
{
	qer_editorimage textures/final_rage/lamp2.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	q3map_lightsubdivide 16
	q3map_surfacelight 9000
	{
		map textures/final_rage/lamp2.tga
	}
}

textures/final_rage/gspawn1-1
{
	qer_editorimage textures/final_rage/gspawn1.tga
    
	q3map_forcemeta
	{
		map $lightmap 
		rgbGen identity
		tcGen lightmap 
	}
	{
		map textures/final_rage/gspawn1.tga
		blendfunc filter
	}
}

textures/final_rage/gspawn1-2
{
	qer_editorimage textures/final_rage/gspawn1.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	cull none
	q3map_lightsubdivide 16
	q3map_surfacelight 5000
	{
		map textures/final_rage/gspawn1.tga
		blendfunc blend
	}
}

textures/final_rage/pspawn1-1
{
	qer_editorimage textures/final_rage/pspawn1.tga
    
	q3map_forcemeta
	{
		map $lightmap 
		rgbGen identity
		tcGen lightmap 
	}
	{
		map textures/final_rage/pspawn1.tga
		blendfunc filter
	}
}

textures/final_rage/pspawn1-2
{
	qer_editorimage textures/final_rage/pspawn1.tga
	surfaceparm nolightmap
	surfaceparm nomarks
	cull none
	q3map_lightsubdivide 16
	q3map_surfacelight 5000
	{
		map textures/final_rage/pspawn1.tga
		blendfunc blend
	}
}

