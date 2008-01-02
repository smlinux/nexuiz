///////////////////////////////////////////////
// Menu Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all menu functions (especially the required ones)
///////////////////////////////////////////////

float mouseButtonsPressed;
vector menuMousePos;
float menuShiftState;
float menuPrevTime;
float menuAlpha;
float menuLogoAlpha;
float prevMenuAlpha;
float menuLoadedMaplist;
float menuNotTheFirstFrame;

void SUB_Null() { };

void() m_init =
{
	dprint_load();
}

void() m_init_delayed =
{
	float fh;
	string s;

	dprint_load();

	menuLoadedMaplist = 0;
	MapInfo_Enumerate();
	if(!MapInfo_FilterGametype(MAPINFO_TYPE_ALL, 0, 1))
		return;
	menuLoadedMaplist = 1;

	GameCommand_Init();

	draw_currentSkin = strcat("gfx/menu/", cvar_string("menu_skin"));
	fh = fopen(strcat(draw_currentSkin, "/skinvalues.txt"), FILE_READ);
	if(fh < 0)
	{
		draw_currentSkin = "gfx/menu/default";
		fh = fopen(strcat(draw_currentSkin, "/skinvalues.txt"), FILE_READ);
	}
	draw_currentSkin = strzone(draw_currentSkin);
	while((s = fgets(fh)))
		if(tokenize(s) == 2)
			Skin_ApplySetting(argv(0), argv(1));
	fclose(fh);

	draw_setMousePointer("cursor");

	main = spawnMainWindow(); main.configureMainWindow(main);
	draw_reset();
	main.resizeNotify(main, draw_shift, draw_scale, draw_shift, draw_scale);
	main.focused = 1;
	menuShiftState = 0;

	if(Menu_Active)
		m_display(); // delayed menu display
};

void(float key, float ascii) m_keyup =
{
	if(!menuLoadedMaplist)
		return;
	if(!Menu_Active)
		return;
	draw_reset();
	main.keyUp(main, key, ascii, menuShiftState);
	if(key >= K_MOUSE1 && key <= K_MOUSE3)
	{
		--mouseButtonsPressed;
		if(!mouseButtonsPressed)
			main.mouseRelease(main, menuMousePos);
		if(mouseButtonsPressed < 0)
		{
			mouseButtonsPressed = 0;
			print("Warning: released an already released button\n");
		}
	}
	if(key == K_ALT) menuShiftState -= (menuShiftState & S_ALT);
	if(key == K_CTRL) menuShiftState -= (menuShiftState & S_CTRL);
	if(key == K_SHIFT) menuShiftState -= (menuShiftState & S_SHIFT);
};

void(float key, float ascii) m_keydown =
{
	if(!menuLoadedMaplist)
		return;
	if(!Menu_Active)
		return;
	if(keyGrabber)
	{
		entity e;
		e = keyGrabber;
		keyGrabber = NULL;
		e.keyGrabbed(e, key, ascii);
	}
	else
	{
		draw_reset();
		if(!main.keyDown(main, key, ascii, menuShiftState))
			if(key == K_ESCAPE)
				if(gamestatus & (GAME_ISSERVER | GAME_CONNECTED)) // don't back out to console only
					m_hide(); // disable menu on unhandled ESC
		if(key >= K_MOUSE1 && key <= K_MOUSE3)
			if(!mouseButtonsPressed)
				main.mousePress(main, menuMousePos);
	}
	if(key >= K_MOUSE1 && key <= K_MOUSE3)
	{
		++mouseButtonsPressed;
		if(mouseButtonsPressed > 10)
		{
			mouseButtonsPressed = 10;
			print("Warning: pressed an already pressed button\n");
		}
	}
	if(key == K_ALT) menuShiftState |= S_ALT;
	if(key == K_CTRL) menuShiftState |= S_CTRL;
	if(key == K_SHIFT) menuShiftState |= S_SHIFT;
};

void() m_draw =
{
	float t;
	float realFrametime;

	if(!menuNotTheFirstFrame)
	{
		menuNotTheFirstFrame = 1;
		if(Menu_Active)
		if(!cvar("menu_video_played"))
		{
			localcmd("set menu_video_played 1; cd loop 1; play sound/announcer/male/welcome.ogg\n");
			menuLogoAlpha = -0.8; // no idea why, but when I start this at zero, it jumps instead of fading
		}
	}
	if(!menuLoadedMaplist)
	{
		// TODO draw an info image about this situation
		m_init_delayed();
		return;
	}
	t = gettime();
	realFrametime = frametime = min(0.2, t - menuPrevTime);
	menuPrevTime = t;
	time += frametime;

	if(Menu_Active)
	{
		if(getmousetarget() == MT_MENU && (getkeydest() == KEY_MENU || getkeydest() == KEY_MENU_GRABBED))
			setkeydest(keyGrabber ? KEY_MENU_GRABBED : KEY_MENU);
		else
			m_hide();
	}

	if(cvar("cl_capturevideo"))
		frametime = 1 / cvar("cl_capturevideo_fps"); // make capturevideo work smoothly

	dprint_load();
	gamestatus = 0;
	if(isserver())
		gamestatus = gamestatus | GAME_ISSERVER;
	if(clientstate() == CS_CONNECTED)
		gamestatus = gamestatus | GAME_CONNECTED;
	if(cvar("developer"))
		gamestatus = gamestatus | GAME_DEVELOPER;

	prevMenuAlpha = menuAlpha;
	if(Menu_Active)
	{
		if(menuAlpha == 0 && menuLogoAlpha < 2)
		{
			menuLogoAlpha = menuLogoAlpha + frametime * 2;
		}
		else
		{
			menuAlpha = min(1, menuAlpha + frametime * 5);
			menuLogoAlpha = 2;
		}
	}
	else
	{
		menuAlpha = max(0, menuAlpha - frametime * 5);
		menuLogoAlpha = 2;
	}

	draw_reset();

	if(!(gamestatus & (GAME_CONNECTED | GAME_ISSERVER)))
	{
		vector sz;
		vector isz;
		sz = draw_PictureSize(SKINGFX_BACKGROUND);
		// keep aspect of image
		if(sz_x * draw_scale_y >= sz_y * draw_scale_x)
		{
			// that is, sz_x/sz_y >= draw_scale_x/draw_scale_y
			// match up the height
			isz_y = 1;
			isz_x = isz_y * (sz_x / sz_y) * (draw_scale_y / draw_scale_x);
		}
		else
		{
			// that is, sz_x/sz_y <= draw_scale_x/draw_scale_y
			// match up the width
			isz_x = 1;
			isz_y = isz_x * (sz_y / sz_x) * (draw_scale_x / draw_scale_y);
		}
		draw_Picture('0.5 0.5 0' - 0.5 * isz, SKINGFX_BACKGROUND, isz, '1 1 1', bound(0, menuLogoAlpha, 1));
	}

	if(menuAlpha <= 0)
	{
		if(prevMenuAlpha > 0)
			main.initializeDialog(main, main.firstChild);
		return;
	}

	draw_alpha *= menuAlpha;

	if(frametime > 0)
	{
		vector dMouse;
		dMouse = getmousepos();
		dMouse *= frametime / realFrametime; // for capturevideo
		if(dMouse != '0 0 0')
		{
			dMouse = globalToBoxSize(dMouse, draw_scale);
			menuMousePos += dMouse * 1; // TODO use a cvar here
			menuMousePos_x = bound(0, menuMousePos_x, 1);
			menuMousePos_y = bound(0, menuMousePos_y, 1);
			if(mouseButtonsPressed)
				main.mouseDrag(main, menuMousePos);
			else
				main.mouseMove(main, menuMousePos);
		}
	}
	main.draw(main);
	draw_drawMousePointer(menuMousePos);

	frametime = 0;
};

void() m_display =
{
	Menu_Active = true;
	setkeydest(KEY_MENU);
	setmousetarget(MT_MENU);

	if(!menuLoadedMaplist)
		return;

	if(mouseButtonsPressed)
		main.mouseRelease(main, menuMousePos);
	mouseButtonsPressed = 0;

	main.focusEnter(main);
	main.showNotify(main);
};

void() m_hide =
{
	Menu_Active = false;
	setkeydest(KEY_GAME);
	setmousetarget(MT_CLIENT);

	if(!menuLoadedMaplist)
		return;

	main.focusLeave(main);
	main.hideNotify(main);
};

void() m_toggle =
{
	if(Menu_Active)
		m_hide();
	else
		m_display();
};

void() m_shutdown =
{
	m_hide();
};

void(string itemname) m_goto =
{
	entity e;
	if(!menuLoadedMaplist)
		return;
	if(itemname == "") // this can be called by GameCommand
	{
		if(gamestatus & (GAME_ISSERVER | GAME_CONNECTED))
			m_hide();
		else
		{
			main.initializeDialog(main, main.firstChild);
			m_display();
		}
	}
	else
	{
		e = findstring(NULL, name, itemname);
		if(e && e.parent == main)
		{
			m_hide();
			main.initializeDialog(main, e);
			m_display();
		}
	}
}
