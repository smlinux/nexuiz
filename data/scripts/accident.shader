textures/base/mgrate
{
	qer_editorimage textures/base/mgrate.tga
	surfaceparm alphashadow
	cull none
	qer_alphaFunc GE128
	{
		map textures/base/mgrate.tga
		alphaFunc GE128
		
	}
	{
		map $lightmap
		blendfunc filter
		tcgen lightmap
	}
}