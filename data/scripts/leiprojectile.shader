models/lasertrail
{
	cull disable
	{
		map models/ltrail.tga
		blendfunc add
		rgbGen identity
	}
}

models/lasercore
{
	deformVertexes autosprite
	{
		map models/lcore.tga
		blendfunc add
		rgbGen identity
	}
}

models/plastrail
{
	cull disable
	{
		map models/ptrail.tga
		blendfunc add
		rgbGen identity
	}
}

models/plascore
{
	deformVertexes autosprite
	{
		map models/pcore.tga
		blendfunc add
		rgbGen identity
	}
}

models/bultrail
{
	cull disable
	{
		map models/bultrail.tga
		blendfunc add
		rgbGen identity
	}
}

models/bulcore
{
	deformVertexes autosprite
	{
		map models/bulcore.tga
		blendfunc add
		rgbGen identity
	}
}

models/eleccore
{
	{
		animmap 45 models/eleccore.tga models/eleccore2.tga models/eleccore3.tga models/eleccore4.tga models/eleccore5.tga models/eleccore6.tga models/eleccore7.tga models/eleccore8.tga 
		blendfunc blend
		rgbGen identity
	}
}

models/elecglass
{
	{
		map models/elecglass.tga
		blendfunc add
		rgbGen lightingDiffuse
	}
}

models/elecbeam
{
	cull disable
	{
		map models/elecbeam.tga
		blendfunc add
		rgbGen identity
		tcMod scroll -2 0
	}
}

