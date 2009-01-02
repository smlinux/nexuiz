hlac_plasma
{
 {
	map textures/hlac_plasma.tga
	tcMod scroll 22.5 0.2
	tcmod scale 0.01 0.01
 }
}

hlac_metal
{
        cull none
        {
                map textures/hlac_metal.tga
                rgbgen vertex
        }
}
hlac_glass
{
	qer_editorimage textures/hlac_glass.tga
	surfaceparm trans
	cull disable
	qer_trans 0.5
	{
		map textures/hlac_glass.tga
		blendfunc add
		//rgbGen vertex
		tcgen environment
		tcmod scale 4 4
	}	
}
hlac_bullet
{
	cull disable
	deformVertexes autosprite
	{
		map models/hlac_bullet.tga
		blendfunc add
	}	
}
