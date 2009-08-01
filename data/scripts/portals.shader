portals_red_vortex
{
	cull none
	deformVertexes wave 100 sin 1.5 0.6 0 1.5
	{
		map textures/portals/portals_red_vortex.tga
		tcMod rotate 10
		blendfunc blend
	}
}

portals_blue_vortex
{
	cull none
	deformVertexes wave 100 sin 1.5 0.6 0 1.5
	{
		map textures/portals/portals_blue_vortex.tga
		tcMod rotate 10
		blendfunc blend
	}
}

portals_inactive_vortex
{
	cull none
	deformVertexes wave 100 sin 1.5 0.6 0 1.5
	{
		map textures/portals/portals_inactive_vortex.tga
		tcMod rotate 10
		blendfunc blend
	}
}

textures/portals/portals_red
{
	surfaceparm nonsolid
	{
		map textures/portals/portals_red.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/portals/portals_blue
{
	surfaceparm nonsolid
	{
		map textures/portals/portals_blue.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
}

textures/portals/portals_inactive
{
	surfaceparm nonsolid
	{
		map textures/portals/portals_inactive.tga
	}
	{
		map $lightmap
		blendfunc filter
	}
}
