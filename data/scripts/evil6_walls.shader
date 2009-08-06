// textures/evil6_walls/

// e6girdergrate.tga  (default grate shader)

textures/evil6_walls/e6girdergrate_s
{
	qer_editorimage textures/evil6_walls/e6girdergrate.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdergrate.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6girdergrate2b.tga  (default grate shader)

textures/evil6_walls/e6girdergrate2b_s
{
	qer_editorimage textures/evil6_walls/e6girdergrate2b.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdergrate2b.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6girdersupport.tga  (default grate shader)

textures/evil6_walls/e6girdersupport_s
{
	qer_editorimage textures/evil6_walls/e6girdersupport.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6girdersupport.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6indsdoor.tga  (default grate shader)

textures/evil6_walls/e6indsdoor_s
{
	qer_editorimage textures/evil6_walls/e6indsdoor.tga
	surfaceparm trans
	surfaceparm nomarks
	surfaceparm metalsteps
	cull none
	{
		map textures/evil6_walls/e6indsdoor.tga
		alphafunc GE128
		depthwrite
	}
	{
		map $lightmap
		depthfunc equal
		blendfunc filter
	}
}

// e6tdoor.tga with e6tdoor_fx.tga will use this shader:
// Tech door light effect

textures/evil6_walls/e6tdoor
{
	qer_editorimage textures/evil6_walls/e6tdoor.tga
	{
		map textures/evil6_walls/e6tdoor.tga
	}
	{
		map textures/evil6_walls/e6tdoor.tga
		blendFunc blend
	}
	{
		map $lightmap
		blendFunc filter
	}
}
