textures/tznex01/stained_glass_nexlogo_blue
{
	qer_editorimage textures/tznex01/stained_glass_nexlogo_blue_qei
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	{
		map textures/tznex01/stained_glass_nexlogo_blue.tga
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

textures/tznex01/stained_glass_nexlogo_red
{
	qer_editorimage textures/tznex01/stained_glass_nexlogo_red_qei
	surfaceparm nomarks
	surfaceparm trans
	surfaceparm alphashadow
	cull none
	nopicmip
	{
		map textures/tznex01/stained_glass_nexlogo_red.tga
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