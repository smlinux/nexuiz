///////////////////////////////////////////////
// Menu Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all menu functions (especially the required ones)
///////////////////////////////////////////////

void(void) m_init =
{
	// init graphic
	gfx_init();

	// init sound
	snd_init();

	// init cursor
	cursor_init();

	// init menu
	menu_init();

	// init editor
	//editor_init();
};

// required menu functions
void(float keynr, float ascii) m_keydown =
{
	if(!menu_active)
		return;

	// let also the gfx and sound know
	gfx_keydown(keynr, ascii);
	snd_keydown(keynr, ascii);

	// actually only the menu may react on keydown messages
	menu_keydown(keynr, ascii);

	// let the editor also know
	//editor_keydown(keynr, ascii);
};

void(void) m_frame =
{
	// graphic frame
	gfx_frame();

	// sound frame
	snd_frame();

	// cursor frame
	cursor_frame();

	// menu frame
	menu_frame();

	// editor frame
	//editor_frame();
};

void(void) m_draw =
{
	if(!menu_active)
		return;

	// call m_frame cause draw is the only menu function called once per frame
	m_frame();

	// now the drawing code
	menu_draw();

	// editor drawing code
	//editor_draw();

	// draw the cursor on top of the menu
	cursor_draw();

	// and now the gfx drawing code (for special fx)
	gfx_draw();
};

void(void) m_toggle =
{
	if(!menu_active)
	{
		menu_active = true;

		// update isserver and clientstate
		gamestatus = 0;
		if(isserver())
			gamestatus = gamestatus | GAME_ISSERVER;
		if(clientstate() == CS_CONNECTED)
			gamestatus = gamestatus | GAME_CONNECTED;
		if(cvar("developer"))
			gamestatus = gamestatus | GAME_DEVELOPER;

		// redirect keyboard input
		setkeydest(KEY_MENU);
		// stop the client getting mouse coords
		setmousetarget(MT_MENU);

		// let also the snd and gfx know (perhaps for sfx)
		gfx_toggle();
		snd_toggle();

		cursor_toggle();

		// let the menu manager know
		menu_performreinit();
	} else
	{
		setkeydest(KEY_GAME);
		setmousetarget(MT_CLIENT);
		menu_active = false;
	}
};

void(void) m_shutdown =
{
	// shutdown editor
	//editor_shutdown();

	// shutdown menu
	menu_shutdown();

	// shutdown cursor
	cursor_shutdown();

	// shutdown sound
	snd_shutdown();

	// shutdown graphic
	gfx_shutdown();
};