//include "main.qh"

float sbar_alpha_fg;
float last_weapon;
float activeweapon;
float weapontime;
float sbar_hudselector;
float teamplay;
float myteam;

float numteams; // NOTE: This is changed in Sbar_SortFrags, so use it only AFTER that

void CSQC_common_hud(void);

void CSQC_kh_hud(void);
void CSQC_ctf_hud(void);
void PostInit(void);
void CSQC_UpdateView(void)
{
	if(!postinit)
		PostInit();
	
	sbar_alpha_fg = cvar("sbar_alpha_fg" );
	sbar_hudselector = cvar("sbar_hudselector");
	activeweapon = getstati(STAT_ACTIVEWEAPON);
	teamplay = cvar("teamplay");

	if(last_weapon != activeweapon) {
		weapontime = time;
		last_weapon = activeweapon;
	}

	// ALWAYS Clear Current Scene First
	R_ClearScene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	R_SetView(VF_DRAWWORLD, 1);
	
	// Draw the Crosshair
	R_SetView(VF_DRAWCROSSHAIR, 1);
	
	// Draw the Engine Status Bar (the default Quake HUD)
	draw_enginesbar = !cvar("sbar_usecsqc");
	R_SetView(VF_DRAWENGINESBAR, draw_enginesbar);

	// Set the console size vars
	vid_conwidth = cvar("vid_conwidth");
	vid_conheight = cvar("vid_conheight");

	// Update the mouse position
	/*
	mousepos_x = vid_conwidth;
	mousepos_y = vid_conheight;
	mousepos = mousepos*0.5 + getmousepos();
	*/

	R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);

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
	if(!draw_enginesbar)
	{
		CSQC_common_hud();
	}
	
	if(gametype == GAME_ONSLAUGHT)
	{
		//drawstring('0 0', minimapname, '8 8 0', '1 1 1', 1, 0);
		//drawsetcliparea(0,0,800,600);
		ons_view();
		//drawresetcliparea();
	}
}

void Sbar_Draw();
void CSQC_common_hud(void)
{
	// Sbar_SortFrags(); done in Sbar_Draw
	Sbar_Draw();
}

// KeyHunt HUD by victim
void CSQC_kh_hud(void)
{
	// HUD 0 has the weapons on the right hand side - temporarily shown when needed
	// HUD 1 has the weapons on the bottom - permanently

	// use the following two binds to check the icons move correctly
	// bind g "toggle sbar_flagstatus_right; echo Menu right $sbar_flagstatus_right"  // move the icons
	// bind h "toggle sbar_hudselector; echo HUD $sbar_hudselector"  // change the HUD

	float kh_keys, kh_keys_status, kh_teams_set;
	float kh_margin_x, kh_margin_y;
	string kh_carrying, kh_outline;
	vector red_pos, blue_pos, yellow_pos, pink_pos, kh_size;
	vector red, blue, yellow, pink;

	/*
	kh_keys = cvar("kh_keys");  // set in keyhunt.qc
	kh_keys_status = cvar("kh_keys_status");  // set in keyhunt.qc
	*/
	kh_keys = getstati(STAT_KH_KEYS);
	kh_keys_status = kh_keys / 256;
	kh_teams_set = cvar("_teams_available");  // set in keyhunt.qc

//	kh_margin_x = 10;
	kh_margin_y = 8;
	kh_margin_x = (cvar("sbar_flagstatus_right") * sbar_hudselector * (vid_conwidth - 66)) + 10;
	// sbar_flagstatus_right 0/1; sbar_hudselector 0/1; screen width - key width + margin

	red_pos_x = blue_pos_x = yellow_pos_x = pink_pos_x = kh_margin_x;

	red_pos_y = kh_margin_y + 120*3;
	blue_pos_y = kh_margin_y + 120*2;
	yellow_pos_y = kh_margin_y + 120;
	pink_pos_y = kh_margin_y + 0;

	red = '1 0 0';
	blue = '0 0 1';
	yellow = '1 1 0';
	pink = '1 0 1';

	kh_size = '45 116';

	kh_carrying = "gfx/sb_key_carrying";
	kh_outline = "gfx/sb_key_carrying_outline";

	// drawpic(vector position, string pic, vector size, vector rgb, float alpha, float flag)
	// vector position = '0 0';  // 'x y' 0 0 (the origin) is in the top left. X 0 - 799, Y 0 - 599

	// vector size = '0 0';  // 'x y' changes the x & y dimensions. '0 0' gives the default pic size
	// vector rgb = '0 0 0';  // 'r g b' range 0 - 1

	if (kh_keys_status & 1)  // red
		drawpic (red_pos, kh_carrying, kh_size, red, 0.2, 0);  // show 20% alpha key
	else
		drawpic (red_pos, kh_outline, kh_size, red, 0.4, 0);  // show key outline

	if (kh_keys & 1)  //red, added by victim
		drawpic (red_pos, kh_carrying, kh_size, red, 1.0, 0);  // show solid key


	if (kh_keys_status & 2)  // blue
		drawpic (blue_pos, kh_carrying, kh_size, blue, 0.2, 0);
	else
		drawpic (blue_pos, kh_outline, kh_size, blue, 0.4, 0);

	if (kh_keys & 2)
		drawpic (blue_pos, kh_carrying, kh_size, blue, 1.0, 0);


	if (kh_teams_set & 4)  // yellow and pink
	{
		if (kh_keys_status & 4)  // yellow
			drawpic (yellow_pos, kh_carrying, kh_size, yellow, 0.2, 0);
		else
			drawpic (yellow_pos, kh_outline, kh_size, yellow, 0.4, 0);

		if (kh_keys & 4)  //red, added by victim
			drawpic (yellow_pos, kh_carrying, kh_size, yellow, 1.0, 0);
	}


	if (kh_teams_set & 8)  // pink only
	{
		if (kh_keys_status & 8)  // pink
			drawpic (pink_pos, kh_carrying, kh_size, pink, 0.2, 0);
		else
			drawpic (pink_pos, kh_outline, kh_size, pink, 0.4, 0);

		if (kh_keys & 8)  //red, added by victim
			drawpic (pink_pos, kh_carrying, kh_size, pink, 1.0, 0);
	}

}
