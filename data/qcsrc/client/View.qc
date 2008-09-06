vector angles_held[24];
void Net_ReadHoldAngles()
{
	float wpn;
	vector v;
	wpn = ReadByte();
	--wpn;
	angles_held_status[wpn] = ReadByte();
	if(angles_held_status[wpn])
	{
		v_x = ReadCoord();
		v_y = ReadCoord();
		v_z = 0;
		angles_held[wpn] = v;
	}
}

entity porto;
vector polyline[16];
float Q3SURFACEFLAG_SLICK = 2; // low friction surface
void Porto_Draw()
{
	vector p, dir, ang, q, nextdir;
	float idx, portal_number, portal1_idx;

	if(activeweapon != WEP_PORTO)
		return;

	dir = view_forward;

	if(angles_held_status[WEP_PORTO-1])
	{
		makevectors(angles_held[WEP_PORTO-1]);
		dir = v_forward;
	}

	p = view_origin;

	polyline[0] = p;
	idx = 1;
	portal_number = 0;
	nextdir = dir;

	for(;;)
	{
		dir = nextdir;
		traceline(p, p + 65536 * dir, TRUE, world);
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			return;
		nextdir = dir - 2 * (dir * trace_plane_normal) * trace_plane_normal; // mirror dir at trace_plane_normal
		p = trace_endpos;
		polyline[idx] = p;
		++idx;
		if(idx >= 16)
			return;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK)
			continue;
		++portal_number;
		ang = vectoangles(trace_plane_normal, dir);
		ang_x = -ang_x;
		makevectors(ang);
		if(!CheckWireframeBox(porto, p - 48 * v_right - 48 * v_up + 16 * v_forward, 96 * v_right, 96 * v_up, 96 * v_forward))
			return;
		if(portal_number == 1)
			portal1_idx = idx;
		if(portal_number >= 2)
			break;
	}

	while(idx >= 2)
	{
		p = polyline[idx-2];
		q = polyline[idx-1];
		if(idx == 2)
			p = p - view_up * 16;
		if(idx-1 >= portal1_idx)
		{
			Draw_CylindricLine(p, q, 4, "", 1, 0, '0 0 1', 0.5, DRAWFLAG_NORMAL);
		}
		else
		{
			Draw_CylindricLine(p, q, 4, "", 1, 0, '1 0 0', 0.5, DRAWFLAG_NORMAL);
		}
		--idx;
	}
}

float DPCONTENTS_SOLID = 1; // hit a bmodel, not a bounding box
float DPCONTENTS_BODY = 32; // hit a bounding box, not a bmodel
float DPCONTENTS_PLAYERCLIP = 256; // blocks player movement
void Porto_Init()
{
	porto = spawn();
	porto.classname = "porto";
	porto.draw = Porto_Draw;
	porto.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_PLAYERCLIP;
}

float drawtime;

float tan(float x)
{ 
	return sin(x) / cos(x);
}
float atan2(float y, float x)
{
	vector v;
	v = '1 0 0' * x + '0 1 0' * y;
	v = vectoangles(v);
	return v_y * 0.01745329251994329576;
}

vector GetCurrentFov(float fov)
{
	float zoomsensitivity, zoomspeed, zoomfactor, zoomdir;

	zoomsensitivity = cvar("cl_zoomsensitivity");
	zoomfactor = cvar("cl_zoomfactor");
	if(zoomfactor < 1 || zoomfactor > 16)
		zoomfactor = 2.5;
	zoomspeed = cvar("cl_zoomspeed");
	if(zoomspeed >= 0)
		if(zoomspeed < 0.5 || zoomspeed > 16)
			zoomspeed = 3.5;

	zoomdir = button_zoom;
	if(activeweapon == WEP_NEX)
		zoomdir += button_attack2;
	if(spectatee_status > 0 || isdemo())
	{
		if(spectatorbutton_zoom)
			zoomdir = 0 + !zoomdir;
			// do not even THINK about removing this 0
			// _I_ know what I am doing
			// fteqcc does not
	}

	if(zoomdir)
		zoomin_effect = 0;

	if(zoomin_effect)
	{
		current_viewzoom = min(1, current_viewzoom + drawframetime);
	}
	else
	{
		if(zoomspeed < 0) // instant zoom
		{
			if(zoomdir)
				current_viewzoom = 1 / zoomfactor;
			else
				current_viewzoom = 1;
		}
		else
		{
			if(zoomdir)
				current_viewzoom = 1 / bound(1, 1 / current_viewzoom + drawframetime * zoomspeed * (zoomfactor - 1), zoomfactor);
			else
				current_viewzoom = bound(1 / zoomfactor, current_viewzoom + drawframetime * zoomspeed * (1 - 1 / zoomfactor), 1);
		}
	}

	if(zoomsensitivity < 1)
		setsensitivityscale(pow(current_viewzoom, 1 - zoomsensitivity));
	else
		setsensitivityscale(1);

	float frustumx, frustumy, fovx, fovy;
	frustumy = tan(fov * 0.00872664625997164788) * 0.75 * current_viewzoom;
	frustumx = frustumy * cvar("vid_width") / cvar("vid_height") / cvar("vid_pixelheight");
	fovx = atan2(frustumx, 1) / 0.00872664625997164788;
	fovy = atan2(frustumy, 1) / 0.00872664625997164788;

	return '1 0 0' * fovx + '0 1 0' * fovy;
}

void CSQC_common_hud(void);

void CSQC_kh_hud(void);
void CSQC_ctf_hud(void);
void PostInit(void);
float Sbar_WouldDrawScoreboard ();
float zoomscript_caught;
void CSQC_UpdateView(void)
{
	entity e;
	float fov;

	drawframetime = max(0.000001, time - drawtime);
	drawtime = time;

	// watch for gametype changes here...
	// in ParseStuffCMD the cmd isn't executed yet :/
	// might even be better to add the gametype to TE_CSQC_INIT...?
	if(!postinit)
		PostInit();

	fov = cvar("fov");
	if(button_zoom || fov <= 59.5)
	{
		if(!zoomscript_caught)
		{
			localcmd("+button4\n");
			zoomscript_caught = 1;
			ignore_plus_zoom += 1;
		}
	}
	else
	{
		if(zoomscript_caught)
		{
			localcmd("-button4\n");
			zoomscript_caught = 0;
			ignore_minus_zoom += 1;
		}
	}
	
	sbar_alpha_fg = cvar("sbar_alpha_fg" );
	sbar_hudselector = cvar("sbar_hudselector");
	activeweapon = getstati(STAT_SWITCHWEAPON);
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

	R_SetView(VF_FOV, GetCurrentFov(fov));
	
	// Draw the Crosshair
	R_SetView(VF_DRAWCROSSHAIR, !Sbar_WouldDrawScoreboard());
	
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
	
	view_origin = pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT);
	view_angles = input_angles;
	makevectors(view_angles);
	view_forward = v_forward;
	view_right = v_right;
	view_up = v_up;
	
	e = self;
	for(self = world; (self = nextent(self)); )
		if(self.draw)
			self.draw();
	self = e;
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
	float kh_margin_x, kh_margin_y, kh_key_box;
	string kh_carrying, kh_outline;
	vector red_pos, blue_pos, yellow_pos, pink_pos, kh_size;
	vector red, blue, yellow, pink;

	kh_keys = getstati(STAT_KH_KEYS);
	kh_keys_status = kh_keys / 256;
	kh_teams_set = cvar("_teams_available");  // set in keyhunt.qc

	kh_margin_y = 8;
	kh_margin_x = (cvar("sbar_flagstatus_right") * sbar_hudselector * (vid_conwidth - 67)) + 10;
//	sbar_flagstatus_right 0/1; sbar_hudselector 0/1; screen width - key width + margin

	red_pos_x = blue_pos_x = yellow_pos_x = pink_pos_x = kh_margin_x;

	kh_key_box = 120;

	pink_pos_y = kh_margin_y + 0;  // top
	yellow_pos_y = kh_margin_y + kh_key_box;
	blue_pos_y = kh_margin_y + kh_key_box * 2;
	red_pos_y = kh_margin_y + kh_key_box * 3;  //bottom

	red = '1 0 0';
	blue = '0 0 1';
	yellow = '1 1 0';
	pink = '1 0 1';

	kh_size = '0 0 0';  // don't resize the image

	kh_carrying = "gfx/sb_kh_full";
	kh_outline = "gfx/sb_kh_outline";

// 	drawpic(vector position, string pic, vector size, vector rgb, float alpha, float flag)
// 	vector position = '0 0';  // 'x y' 0 0 (the origin) is the top left. X 0 - 799, Y 0 - 599

// 	vector size = '0 0';  // 'x y' changes the x & y dimensions. '0 0' gives the default pic size
// 	vector rgb = '0 0 0';  // 'r g b' range 0 - 1

	if (kh_keys_status & 1)  // red
		drawpic (red_pos, kh_carrying, kh_size, red, 0.2, 0);  // show 20% alpha key
	else
		drawpic (red_pos, kh_outline, kh_size, red, 0.4, 0);  // show key outline 40% alpha

	if (kh_keys & 1)
		drawpic (red_pos, kh_carrying, kh_size, red, 1.0, 0);  // show solid key 100% alpha


	if (kh_keys_status & 2)  // blue
		drawpic (blue_pos, kh_carrying, kh_size, blue, 0.2, 0);
	else
		drawpic (blue_pos, kh_outline, kh_size, blue, 0.4, 0);

	if (kh_keys & 2)
		drawpic (blue_pos, kh_carrying, kh_size, blue, 1.0, 0);


	if (kh_teams_set & 4)  // yellow
	{
		if (kh_keys_status & 4)
			drawpic (yellow_pos, kh_carrying, kh_size, yellow, 0.2, 0);
		else
			drawpic (yellow_pos, kh_outline, kh_size, yellow, 0.4, 0);

		if (kh_keys & 4)
			drawpic (yellow_pos, kh_carrying, kh_size, yellow, 1.0, 0);
	}


	if (kh_teams_set & 8)  // pink
	{
		if (kh_keys_status & 8)
			drawpic (pink_pos, kh_carrying, kh_size, pink, 0.2, 0);
		else
			drawpic (pink_pos, kh_outline, kh_size, pink, 0.4, 0);

		if (kh_keys & 8)
			drawpic (pink_pos, kh_carrying, kh_size, pink, 1.0, 0);
	}

}
