///////////////////////////////////////////////
// Menu Source File
///////////////////////
// This file belongs to dpmod/darkplaces
// AK contains all menu functions (especially the required ones)
///////////////////////////////////////////////

void() m_init =
{
	// init graphic
	Gfx_Init();

	// init cursor
	Cursor_Init();

	Key_Init();

	// init menu
	Menu_Init();
};

// required menu functions
void( float pKey, float pAscii ) m_keydown =
{
	if(!Menu_Active)
		return;

	// actually the menu is the only system that needs to react on key events
	Menu_Key( pKey, pAscii );
};

void() m_frame =
{
	Timer_Update();

	HostCache_Update();

	// graphic frame
	Gfx_Update();

	// cursor frame
	Cursor_Update();

	// menu frame
	Menu_Frame();
};

void() m_draw =
{
	if( !Menu_Active )
		return;

	// call m_frame cause draw is the only menu function called once per frame
	m_frame();

	// now the drawing code
	Menu_Draw();

	// draw the cursor on top of the menu
	Cursor_Draw();

	// and now the gfx drawing code (for special fx)
	Gfx_Draw();
};

void() m_display =
{
	Menu_Active = true;

	// update isserver and clientstate
	gamestatus = 0;
	if(isserver())
		gamestatus = gamestatus | GAME_ISSERVER;
	if(clientstate() == CS_CONNECTED)
		gamestatus = gamestatus | GAME_CONNECTED;
	if(cvar("developer"))
		gamestatus = gamestatus | GAME_DEVELOPER;

	// let also the snd and gfx know (perhaps for sfx)
	Gfx_Display();
	Cursor_Display();
	Key_Display();

	// let the menu manager know
	Menu_PerformReinit();
};

void() m_hide =
{
	Gfx_Hide();
	Cursor_Hide();
	Key_Hide();

	// let the menu manager know
	Menu_Hide();

	Menu_Active = false;
};

void() m_toggle =
{
	Timer_Update();

	if( Menu_Active )
		m_hide();
	else
		m_display();
};

void() m_shutdown =
{
	Timer_Update();

	// shutdown menu
	Menu_Shutdown();

	// shutdown timer
	Timer_Quit();

	// shutdown key system
	Key_Quit();

	// shutdown cursor
	Cursor_Quit();

	// shutdown graphic
	Gfx_Quit();

	// make sure everything is reset
	setkeydest( KEY_GAME );
	setmousetarget( MT_CLIENT );
};