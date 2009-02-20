entity porto;
vector polyline[16];
float trace_dphitcontents;
float Q3SURFACEFLAG_SLICK = 2; // low friction surface
float DPCONTENTS_SOLID = 1; // blocks player movement
float DPCONTENTS_BODY = 32; // blocks player movement
float DPCONTENTS_PLAYERCLIP = 256; // blocks player movement
void Porto_Draw()
{
	vector p, dir, ang, q, nextdir;
	float idx, portal_number, portal1_idx;

	if(activeweapon != WEP_PORTO)
		return;

	dir = view_forward;

	if(angles_held_status)
	{
		makevectors(angles_held);
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
		traceline(p, p + 65536 * dir, TRUE, porto);
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			return;
		nextdir = dir - 2 * (dir * trace_plane_normal) * trace_plane_normal; // mirror dir at trace_plane_normal
		p = trace_endpos;
		polyline[idx] = p;
		++idx;
		if(idx >= 16)
			return;
		if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK || trace_dphitcontents & DPCONTENTS_PLAYERCLIP)
			continue;
		++portal_number;
		ang = vectoangles2(trace_plane_normal, dir);
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

/**
 * Checks whether the server initiated a map restart (stat_game_starttime changed)
 *
 * TODO: Use a better solution where a common shared entitiy is used that contains
 * timelimit, fraglimit and game_starttime! Requires engine changes (remove STAT_TIMELIMIT
 * and STAT_FRAGLIMIT to be auto-sent)
 */
void CheckForGamestartChange() {
	float startTime;
	startTime = getstatf(STAT_GAMESTARTTIME);
	if (previous_game_starttime != startTime) {
		if ((time + 5.0) < startTime) {
			//if connecting to server while restart was active don't always play prepareforbattle
			sound(self, CHAN_VOICE, "announcer/robotic/prepareforbattle.wav", VOL_BASEVOICE, ATTN_NONE);
		}
		if (time < startTime) {
			restartAnnouncer = spawn();
			restartAnnouncer.think = restartAnnouncer_Think;
			restartAnnouncer.nextthink = startTime - floor(startTime - time); //synchronize nextthink to startTime
		}
	}
	previous_game_starttime = startTime;
}

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
	if(getstati(STAT_ACTIVEWEAPON) == WEP_NEX) // do NOT use switchweapon here
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

	if(zoomin_effect || camera_active)
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

	if(almost_equals(current_viewzoom, 1))
		current_zoomfraction = 0;
	else if(almost_equals(current_viewzoom, 1/zoomfactor))
		current_zoomfraction = 1;
	else
		current_zoomfraction = (current_viewzoom - 1) / (1/zoomfactor - 1);

	if(zoomsensitivity < 1)
		setsensitivityscale(pow(current_viewzoom, 1 - zoomsensitivity));
	else
		setsensitivityscale(1);

	float frustumx, frustumy, fovx, fovy;
	frustumy = tan(fov * 0.00872664625997164788) * 0.75 * current_viewzoom;
	frustumx = frustumy * vid_width / vid_height / vid_pixelheight;
	fovx = atan2(frustumx, 1) / 0.00872664625997164788;
	fovy = atan2(frustumy, 1) / 0.00872664625997164788;

	return '1 0 0' * fovx + '0 1 0' * fovy;
}

void CSQC_common_hud(void);

void CSQC_kh_hud(void);
void CSQC_ctf_hud(void);
void PostInit(void);
void CSQC_Demo_Camera();
float Sbar_WouldDrawScoreboard ();
float zoomscript_caught;
float view_set;
float camera_mode;
void CSQC_UpdateView(float w, float h)
{
	entity e;
	float fov;
	float f;
	vector v1, v2;

	dprint_load();
	WaypointSprite_Load();

	ticrate = getstatf(STAT_SYS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);

	// Render the Scene
	if(!intermission || !view_set)
	{
		view_origin = pmove_org + '0 0 1' * getstati(STAT_VIEWHEIGHT);
		view_angles = input_angles;
		makevectors(view_angles);
		view_forward = v_forward;
		view_right = v_right;
		view_up = v_up;
		view_set = 1;
	}

	f = floor(cvar("v_flipped"));
	cvar_set("v_flipped", ftos(!f));
	v1 = cs_unproject('-100 -100 1000');
	cvar_set("v_flipped", ftos(f));
	v2 = cs_unproject('-100 -100 1000');

	if(v1 == v2)
	{
		// non-supporting engine
		vid_width = cvar("vid_width");
		vid_height = cvar("vid_height");
	}
	else
	{
		// supporting engine
		vid_width = w;
		vid_height = h;
	}

#ifdef BLURTEST
	if(time > blurtest_time0 && time < blurtest_time1)
	{
		float r, t;

		t = (time - blurtest_time0) / (blurtest_time1 - blurtest_time0);
		r = t * blurtest_radius;
		f = 1 / pow(t, blurtest_power) - 1;

		cvar_set("r_glsl_postprocess", "1");
		cvar_set("r_glsl_postprocess_uservec1", strcat(ftos(r), " ", ftos(f), " 0 0"));
	}
	else
	{
		cvar_set("r_glsl_postprocess", "0");
		cvar_set("r_glsl_postprocess_uservec1", "0 0 0 0");
	}
#endif

	Fog_Force();

	drawframetime = max(0.000001, time - drawtime);
	drawtime = time;

	// watch for gametype changes here...
	// in ParseStuffCMD the cmd isn't executed yet :/
	// might even be better to add the gametype to TE_CSQC_INIT...?
	if(!postinit)
		PostInit();
	
	CheckForGamestartChange();

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
	ColorTranslateMode = cvar("cl_stripcolorcodes");
	activeweapon = getstati(STAT_SWITCHWEAPON);
	f = cvar("teamplay");
	if(f != teamplay)
	{
		teamplay = f;
		Sbar_InitScores();
	}

	if(last_weapon != activeweapon) {
		weapontime = time;
		last_weapon = activeweapon;
	}

	// ALWAYS Clear Current Scene First
	R_ClearScene();

	// Assign Standard Viewflags
	// Draw the World (and sky)
	R_SetView(VF_DRAWWORLD, 1);

	// Set the console size vars
	vid_conwidth = cvar("vid_conwidth");
	vid_conheight = cvar("vid_conheight");
	vid_pixelheight = cvar("vid_pixelheight");

	R_SetView(VF_FOV, GetCurrentFov(fov));

	// Camera for demo playback
	if(camera_active)
	{
		if(cvar("camera_enable"))
			CSQC_Demo_Camera();
		else
		{
			cvar_set("chase_active", ftos(chase_active_backup));
			cvar_set("cl_demo_mousegrab", "0");
			camera_active = FALSE;
		}
	}
#ifdef CAMERATEST
	else if(cvar("camera_enable"))
#else
	else if(cvar("camera_enable") && isdemo())
#endif
	{
		// Enable required Darkplaces cvars
		chase_active_backup = cvar("chase_active");
		cvar_set("chase_active", "2");		
		cvar_set("cl_demo_mousegrab", "1");
		camera_active = TRUE;
		camera_mode = FALSE;
	}
	
	// Draw the Crosshair
	float scoreboard_active;
	scoreboard_active = Sbar_WouldDrawScoreboard();
	R_SetView(VF_DRAWCROSSHAIR, 0); //Make sure engine crosshairs are always hidden
	
	// Draw the Engine Status Bar (the default Quake HUD)
	R_SetView(VF_DRAWENGINESBAR, 0);

	// fetch this one only once per frame
	sbar_showbinds = cvar("sbar_showbinds");
	sbar_showbinds_limit = cvar("sbar_showbinds_limit");

	// Update the mouse position
	/*
	mousepos_x = vid_conwidth;
	mousepos_y = vid_conheight;
	mousepos = mousepos*0.5 + getmousepos();
	*/

	R_AddEntities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);

	e = self;
	for(self = world; (self = nextent(self)); )
		if(self.draw)
			self.draw();
	self = e;
	R_RenderScene();

	// now switch to 2D drawing mode by calling a 2D drawing function
	// then polygon drawing will draw as 2D stuff, and NOT get queued until the
	// next R_RenderScene call
	drawstring('0 0 0', "", '1 1 0', '1 1 1', 0, 0);

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

	// draw 2D entities
	e = self;
	for(self = world; (self = nextent(self)); )
		if(self.draw2d)
			self.draw2d();
	self = e;
	
	// draw radar
	if(teamplay || cvar("cl_teamradar") == 2)
	{
		if((cvar_string("cl_teamradar") != "0" && !scoreboard_active) || ons_showmap)
			teamradar_view();
	}

	if (cvar("cl_showpressedkeys")) // draw pressed keys when spectating and playing
	{
		if(spectatee_status > 0 || cvar("cl_showpressedkeys") >= 2)
			Sbar_DrawPressedKeys();
	}

	// draw sbar
	if(cvar("r_letterbox") == 0)
	if(cvar("viewsize") < 120)
		CSQC_common_hud();

	// crosshair goes VERY LAST
	if(!scoreboard_active && !ons_showmap) {
		string wcross_style;
		wcross_style = cvar_string("crosshair");

		if (wcross_style != "0") {
			vector wcross_color, wcross_size;
			string wcross_wep, wcross_name;
			float wcross_alpha, wcross_sizefloat;

			wcross_color_x = cvar("crosshair_color_red");
			wcross_color_y = cvar("crosshair_color_green");
			wcross_color_z = cvar("crosshair_color_blue");
			wcross_alpha = cvar("crosshair_color_alpha");
			wcross_sizefloat = cvar("crosshair_size");
			if (cvar("crosshair_per_weapon")) {
				e = get_weaponinfo(activeweapon);
				if (e && e.netname != "")
				{
					wcross_wep = e.netname;
					wcross_style = cvar_string(strcat("crosshair_", wcross_wep));
					if(wcross_style == "")
						wcross_style = e.netname;

					if(!cvar("crosshair_color_override"))
					{
						wcross_color_x = cvar(strcat("crosshair_", wcross_wep, "_color_red"));
						wcross_color_y = cvar(strcat("crosshair_", wcross_wep, "_color_green"));
						wcross_color_z = cvar(strcat("crosshair_", wcross_wep, "_color_blue"));
					}

					wcross_alpha *= cvar(strcat("crosshair_", wcross_wep, "_color_alpha"));
					wcross_sizefloat *= cvar(strcat("crosshair_", wcross_wep, "_size"));
				}
			}

			wcross_name = strcat("gfx/crosshair", wcross_style);
		
			wcross_size = drawgetimagesize(wcross_name);
			wcross_size_x *= wcross_sizefloat;
			wcross_size_y *= wcross_sizefloat;

			drawpic('0.5 0 0' * (vid_conwidth - wcross_size_x) + '0 0.5 0' * (vid_conheight - wcross_size_y), wcross_name, wcross_size, wcross_color, wcross_alpha, DRAWFLAG_NORMAL);
		}
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

// following vectors must be global to allow seamless switching between camera modes
vector camera_offset, current_camera_offset, mouse_angles, current_angles, current_origin, camera_position, current_position;
void CSQC_Demo_Camera()
{
	float speed, attenuation, dimensions;
	vector tmp, delta;

	if( cvar("camera_reset") || !camera_mode )
	{
		camera_offset = '0 0 0';
		current_angles = '0 0 0';
		camera_direction = '0 0 0';
		camera_offset_z += 30;
		camera_offset_x += 30 * -cos(current_angles_y * DEG2RAD);
		camera_offset_y += 30 * -sin(current_angles_y * DEG2RAD);
		current_origin = view_origin;
		current_camera_offset  = camera_offset;
		cvar_set("camera_reset", "0");
		camera_mode = CAMERA_CHASE;
	}

	// Camera angles
	if( camera_roll )
		mouse_angles_z += camera_roll * cvar("camera_speed_roll");

	if(cvar("camera_look_player"))
	{
		local vector dir;
		local float n;

		dir = normalize(view_origin - current_position);
		n = mouse_angles_z;
		mouse_angles = vectoangles(dir);
		mouse_angles_x = mouse_angles_x * -1;
		mouse_angles_z = n;
	}
	else
	{
		tmp = getmousepos() * 0.1;
		if(vlen(tmp)>cvar("camera_mouse_treshold"))
		{
			mouse_angles_x += tmp_y * cos(mouse_angles_z * DEG2RAD) + (tmp_x * sin(mouse_angles_z * DEG2RAD));
			mouse_angles_y -= tmp_x * cos(mouse_angles_z * DEG2RAD) + (tmp_y * -sin(mouse_angles_z * DEG2RAD));
		}
	}

	while (mouse_angles_x < -180) mouse_angles_x = mouse_angles_x + 360;
	while (mouse_angles_x > 180) mouse_angles_x = mouse_angles_x - 360;
	while (mouse_angles_y < -180) mouse_angles_y = mouse_angles_y + 360;
	while (mouse_angles_y > 180) mouse_angles_y = mouse_angles_y - 360;

	// Fix difference when angles don't have the same sign
	delta = '0 0 0';
	if(mouse_angles_y < -60 && current_angles_y > 60)
		delta = '0 360 0';
	if(mouse_angles_y > 60 && current_angles_y < -60)
		delta = '0 -360 0';

	if(cvar("camera_look_player"))
		attenuation = cvar("camera_look_attenuation");
	else
		attenuation = cvar("camera_speed_attenuation");

	attenuation = 1 / max(1, attenuation);
	current_angles += (mouse_angles - current_angles + delta) * attenuation;

	while (current_angles_x < -180) current_angles_x = current_angles_x + 360;
	while (current_angles_x > 180) current_angles_x = current_angles_x - 360;
	while (current_angles_y < -180) current_angles_y = current_angles_y + 360;
	while (current_angles_y > 180) current_angles_y = current_angles_y - 360;

	// Camera position
	tmp = '0 0 0';
	dimensions = 0;

	if( camera_direction_x )
	{
		tmp_x = camera_direction_x * cos(current_angles_y * DEG2RAD);
		tmp_y = camera_direction_x * sin(current_angles_y * DEG2RAD);
		if( cvar("camera_forward_follows") && !cvar("camera_look_player") )
			tmp_z = camera_direction_x * -sin(current_angles_x * DEG2RAD);
		++dimensions;
	}

	if( camera_direction_y )
	{
		tmp_x += camera_direction_y * -sin(current_angles_y * DEG2RAD);
		tmp_y += camera_direction_y * cos(current_angles_y * DEG2RAD) * cos(current_angles_z * DEG2RAD);
		tmp_z += camera_direction_y * sin(current_angles_z * DEG2RAD);
		++dimensions;
	}

	if( camera_direction_z )
	{
		tmp_z += camera_direction_z * cos(current_angles_z * DEG2RAD);
		++dimensions;
	}

	if(cvar("camera_free"))
		speed = cvar("camera_speed_free");
	else
		speed = cvar("camera_speed_chase");

	if(dimensions)
	{
		speed = speed * sqrt(1 / dimensions);
		camera_offset += tmp * speed;
	}

	current_camera_offset += (camera_offset - current_camera_offset) * attenuation;

	// Camera modes
	if( cvar("camera_free") )
	{
		if ( camera_mode == CAMERA_CHASE )
		{
			current_camera_offset = current_origin + current_camera_offset;
			camera_offset = current_origin + camera_offset;
		}

		camera_mode = CAMERA_FREE;
		current_position = current_camera_offset;
	}
	else
	{
		if ( camera_mode == CAMERA_FREE )
		{
			current_origin = view_origin;
			camera_offset = camera_offset - current_origin;
			current_camera_offset = current_camera_offset - current_origin;
		}

		camera_mode = CAMERA_CHASE;

		if(cvar("camera_chase_smoothly"))
			current_origin += (view_origin - current_origin) * attenuation;
		else
			current_origin = view_origin;

		current_position = current_origin + current_camera_offset;
	}

	R_SetView(VF_ANGLES, current_angles);
	R_SetView(VF_ORIGIN, current_position);
}
