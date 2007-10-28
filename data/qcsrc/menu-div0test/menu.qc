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
float prevMenuAlpha;

void SUB_Null() { };

void() m_init =
{
	dprint_load();
	GameCommand_Init();
	
	draw_setMousePointer("gfx/cursor");

	main = spawnMainWindow(); main.configureMainWindow(main);
	draw_reset();
	main.resizeNotify(main, draw_shift, draw_scale, draw_shift, draw_scale);
	main.focused = 1;
	menuShiftState = 0;
};

void(float key, float ascii) m_keyup =
{
	if(!Menu_Active)
		return;
	draw_reset();
	main.keyUp(main, key, ascii, menuShiftState);
	if(key >= K_MOUSE1 && key <= K_MOUSE10)
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
		if(key >= K_MOUSE1 && key <= K_MOUSE10)
			if(!mouseButtonsPressed)
				main.mousePress(main, menuMousePos);
	}
	if(key >= K_MOUSE1 && key <= K_MOUSE10)
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
	t = gettime();
	realFrametime = frametime = min(0.2, t - menuPrevTime);
	menuPrevTime = t;

	if(Menu_Active)
		if(getkeydest() != KEY_MENU || getmousetarget() != MT_MENU)
			m_hide();

	if(cvar("cl_capturevideo"))
		frametime = 1 / cvar("cl_capturevideo_fps"); // make capturevideo work smoothly

	prevMenuAlpha = menuAlpha;
	if(Menu_Active)
		menuAlpha = min(1, menuAlpha + frametime * 5);
	else
		menuAlpha = max(0, menuAlpha - frametime * 5);

	if(menuAlpha <= 0)
	{
		if(prevMenuAlpha > 0)
			main.initializeDialog(main, main.firstChild);
		return;
	}

	dprint_load();
	gamestatus = 0;
	if(isserver())
		gamestatus = gamestatus | GAME_ISSERVER;
	if(clientstate() == CS_CONNECTED)
		gamestatus = gamestatus | GAME_CONNECTED;
	if(cvar("developer"))
		gamestatus = gamestatus | GAME_DEVELOPER;

	draw_reset();
	draw_alpha *= menuAlpha;

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
	main.draw(main);
	draw_drawMousePointer(menuMousePos);
};

void() m_display =
{
	Menu_Active = true;
	setkeydest(KEY_MENU);
	setmousetarget(MT_MENU);

	main.focusEnter(main);
};

void() m_hide =
{
	Menu_Active = false;
	setkeydest(KEY_GAME);
	setmousetarget(MT_CLIENT);

	main.focusLeave(main);
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
	if(itemname == "")
	{
		m_hide();
	}
	else
	{
		e = findstring(NULL, name, itemname);
		if(e && e.parent == main)
		{
			main.initializeDialog(main, e);
			m_display();
		}
	}
}
