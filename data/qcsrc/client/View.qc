// CSQC_UpdateView - Called every rendered frame on the client.  Useful for HUD drawing operations.
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
	/*
	UpdateCamera();
	R_SetView(VF_ORIGIN, self.origin);
	R_SetView(VF_ANGLES, self.angles);
	*/

	// Setup Entities to be Rendered (include all base types; normal, engine and viewmodels)
	R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	
	// Render the Scene
	R_RenderScene();

	// Draw the mouse cursor
	// NOTE: drawpic must happen after R_RenderScene for some reason
	//drawpic(mousepos, "gfx/cursor.tga", '11 14 0', '1 1 1', 1, 0);
}