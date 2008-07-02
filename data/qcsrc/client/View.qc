//include "main.qh"

void CSQC_UpdateView(void)
{
	// ALWAYS Clear Current Scene First
	R_ClearScene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	R_SetView(VF_DRAWWORLD, 1);
	// Draw the Crosshair
	R_SetView(VF_DRAWCROSSHAIR, 1);
	// Draw the Engine Status Bar (the default Quake HUD)
	R_SetView(VF_DRAWENGINESBAR, 1);

	// Set the console size vars
	vid_conwidth = cvar("vid_conwidth");
	vid_conheight = cvar("vid_conheight");

	// Update the mouse position
	/*
	mousepos_x = vid_conwidth;
	mousepos_y = vid_conheight;
	mousepos = mousepos*0.5 + getmousepos();
	*/

	// Update the camera
	//UpdateCamera();
	/*self.origin_z += getstati(STAT_VIEWHEIGHT);
	R_SetView(VF_ORIGIN, self.origin);
	self.origin_z -= getstati(STAT_VIEWHEIGHT);
	R_SetView(VF_ANGLES, input_angles);*/
	
	// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
	R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);

	/* Sample for 3D polygon rendering, do it before R_RenderScene!
	   R_BeginPolygon("gfx/ctf_ic_atk.tga", 0);
	   R_PolygonVertex('-5000 -5000 5200', '0 0', '1 1 1', 1);
	   R_PolygonVertex(' 5000 -5000 5200', '1 0', '1 1 1', 1);
	   R_PolygonVertex(' 5000  5000 -5200', '1 1', '1 1 1', 1);
	   R_PolygonVertex('-5000  5000 -5200', '0 1', '1 1 1', 1);
	   R_EndPolygon();
	*/
	
	// Render the Scene
	R_RenderScene();

	// Draw the mouse cursor
	// NOTE: drawpic must happen after R_RenderScene for some reason
	//drawpic(getmousepos(), "gfx/cursor.tga", '11 14 0', '1 1 1', 1, 0);
	//drawstring('50 50', ftos(game), '10 10 0', '1 1 1', 1, 0);
	//self = edict_num(player_localnum);
	//drawstring('0 0', vtos(pmove_org), '8 8 0', '1 1 1', 1, 0);
	//drawstring('0 8', strcat("ORG: ", vtos(self.origin), " state: ", ftos(self.ctf_state), " HP: ", ftos(self.health)), '8 8 0', '1 1 1', 1, 0);
	// as long as the ctf part isn't in, this is useless
	if(menu_visible)
		menu_show();
	
	/*if(gametype == GAME_CTF)
	{
		ctf_view();
	} else */
	if(gametype == GAME_ONSLAUGHT)
	{
		//drawstring('0 0', minimapname, '8 8 0', '1 1 1', 1, 0);
		drawsetcliparea(0,0,800,600);
		ons_view();
		drawresetcliparea();
	}
}
