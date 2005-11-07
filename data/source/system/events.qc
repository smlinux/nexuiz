// DP/Nex menu
// system/events.qc

// debug process output functions
bool _menu_process_filtered;
void( float pMode, float pSelectState ) _Menu_Process_Debug_Filter =
{
	if( !sys_debug_process )
		_menu_process_filtered = false;
	else if( sys_debug_process_filter )
		_menu_process_filtered = (pMode & sys_debug_process_filter);
	else
		_menu_process_filtered = true;
	if( _menu_process_filtered == MENU_PROCESS_MOUSE && pSelectState == MENU_SELECT_NEVER )
		_menu_process_filtered = false;
};

#ifdef USEFUNCTIONS
void( string pText ) _Menu_Process_Debug_Print =
{
	if( _menu_process_filtered )
		print( pText );
};
#else
#define _Menu_Process_Debug_Print(pText)   if( _menu_process_filtered ) print( pText )
#endif

// process stacks

void() Menu_Process_Setup =
{
	Menu_Origin = '0 0 0';
	Menu_Clip_Position = '0 0 0';
	Menu_Clip_Size = '0 0 0';
};

void( entity pItem ) _Menu_Env_LoadClipArea
{
	Menu_Clip_Position = pItem._cache_clip_pos;
	Menu_Clip_Size = pItem._cache_clip_size;

	if( sys_debug_mgfx && _menu_process_filtered )
		print( "MGFX Loaded clip area = (", vtos( Menu_Clip_Position ), "; ", vtos( Menu_Clip_Size ), ")\n" );
};

void( entity pItem ) _Menu_Env_LoadOrigin =
{
	Menu_Origin = pItem._cache_origin;
	Menu_Cursor_Position = Cursor_Position - Menu_Origin;

	if( sys_debug_mgfx && _menu_process_filtered )
		print( "MGFX Loaded org = ", vtos( Menu_Origin ), "\n" );
};

void( entity pItem ) _Menu_Env_Reload =
{
	Menu_Origin = pItem._cache_origin;
	Menu_Cursor_Position = Cursor_Position - Menu_Origin;
	Menu_Clip_Position = pItem._cache_clip_pos;
	Menu_Clip_Size = pItem._cache_clip_size;

	if( sys_debug_mgfx && _menu_process_filtered )
		print( "MGFX Reloaded env for: org = ", vtos( Menu_Origin ), "; clip area = (", vtos( Menu_Clip_Position ), "; ", vtos( Menu_Clip_Size ), ")\n" );
};

void() _MGX_SetClipArea =
{
	if( Menu_Clip_Position == '0 0 0' && Menu_Clip_Size == '0 0 0' )
		Gfx_ResetClipArea();
	else
		Gfx_SetClipArea( Menu_Clip_Position_x, Menu_Clip_Position_y, Menu_Clip_Size_x, Menu_Clip_Size_y );
};

void( entity pItem ) _Menu_Env_SetupClipArea
{
	local vector lDelta, lPos, lSize;

	lPos = pItem.pos;
	lSize = pItem.size;
	if( lPos != '0 0 0' || lSize != '0 0 0' ) {
		if( (Menu_Clip_Position != '0 0 0' || Menu_Clip_Size != '0 0 0') ) {
			lPos = Menu_Origin + lPos;
			lDelta = Util_GetClipDelta( lPos, Menu_Clip_Position, Menu_Clip_Size );
			lPos = lPos + lDelta;
			lSize = Util_ClipRect( lPos, lSize - lDelta, Menu_Clip_Position, Menu_Clip_Size );
		}

		Menu_Clip_Position = lPos;
		Menu_Clip_Size = lSize;
	}
	pItem._cache_clip_pos = Menu_Clip_Position;
	pItem._cache_clip_size = Menu_Clip_Size;

	if( sys_debug_mgfx && _menu_process_filtered ) {
		print( "MGFX Setup clip area: (", vtos( pItem.pos ), "; ", vtos( pItem.size ) );
		print( ") clipped to (", vtos( Menu_Clip_Position ), "; ", vtos( Menu_Clip_Size ), ")\n" );
	}
};

void( entity pItem ) _Menu_Env_SetupOrigin =
{
	Menu_Origin = Menu_Origin + pItem.origin + pItem.pos;
	pItem._cache_origin = Menu_Origin;

	if( sys_debug_mgfx && _menu_process_filtered )
		print( "MGFX Setup org = ", vtos( Menu_Origin ), "\n" );
};

void( entity pItem ) _Menu_ProcessRunFlag =
{
	local entity lChild;
	local bool lWasHidden;
	local float lOldRunFlag;

	_Menu_Process_Debug_Print( strcat( "R ", pItem.name, "\n" ) );

	// setup the cache and the Menu_* variables
	_Menu_Env_SetupClipArea( pItem );

	lWasHidden = Menu_HasRunFlag( pItem, RUNFLAG_HIDDEN );

	lOldRunFlag = pItem._runFlag;
	Menu_SetRunFlag( pItem );

	// AK LATE: This should speed up things a bit
	if( /*lOldRunFlag == pItem._runFlag &&*/ lWasHidden && Menu_HasRunFlag( pItem, RUNFLAG_HIDDEN ) ) {
		_Menu_Process_Debug_Print( "Aborted branching (RUNFLAG_HIDDEN)\n" );
		return;
	}

	// we adjust the origin for the children
	_Menu_Env_SetupOrigin( pItem );

	for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
			Menu_InheritRunFlag( pItem, lChild );
			_Menu_ProcessRunFlag( lChild );
			// reload the cached state
			_Menu_Env_Reload( pItem );
	}
};

void( entity pItem ) _Menu_ProcessDraw =
{
	local entity lChild;

	_Menu_Process_Debug_Print( strcat( "D ", pItem.name, " " ) );

	if( !Menu_IsVisible( pItem ) ) {
		_Menu_Process_Debug_Print( "Failed (Not visible)\n" );
		return;
	}
	_Menu_Process_Debug_Print( "\n" );

	_Menu_Env_LoadClipArea( pItem );
	_MGX_SetClipArea();

	Raise_Draw( pItem );

	_Menu_Env_LoadOrigin( pItem );
	for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
		_Menu_ProcessDraw( lChild );
		// reload old state
		_Menu_Env_Reload( pItem );
		_MGX_SetClipArea();
	}
};

void( entity pItem ) _Menu_ProcessUpdate =
{
	local entity lChild;

	_Menu_Process_Debug_Print( strcat( "U ", pItem.name, " " ) );

	if( Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWONLY ) ) {
		_Menu_Process_Debug_Print( "Failed (RUNFLAG_CHILDDRAWONLY)\n" );
		return;
	}

	_Menu_Env_LoadClipArea( pItem );
	Raise_Update( pItem );

	if( Menu_HasRunFlag( pItem, RUNFLAG_HIDDEN ) ) {
		_Menu_Process_Debug_Print( "Aborted branching (RUNFLAG_HIDDEN)\n" );
		return;
	}
	_Menu_Process_Debug_Print( "\n" );

	_Menu_Env_LoadOrigin( pItem );
	for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
		_Menu_ProcessUpdate( lChild );
		_Menu_Env_Reload( lChild );
	}
};

void( entity pItem, float pSelectMode ) _Menu_ProcessMouse =
{
	local entity lChild;

	if( _menu_process_filtered ) {
		print( "M " );
		switch( pSelectMode ) {
			case MENU_SELECT_SELECTABLE:
				print( "S " );
				break;
			case MENU_SELECT_ALWAYS:
				print( "A " );
				break;
			case MENU_SELECT_NEVER:
				print( "N " );
				break;
		}
		print( pItem.name, " " );
	}

	if( !Menu_IsVisible( pItem ) ) {
		_Menu_Process_Debug_Print( "Failed (Not visible)\n" );
		return;
	}

	_Menu_Env_LoadClipArea( pItem );
	// check if the mouse is even in the clip area
	if( Util_InRect( Cursor_Position, Menu_Clip_Position, Menu_Clip_Size ) ||
	( Menu_Clip_Position == '0 0 0' && Menu_Clip_Size == '0 0 0' ) ) {
		pItem._runFlag = pItem._runFlag | RUNFLAG_MOUSEINAREA;

		if( !Menu_HasRunFlag( pItem, RUNFLAG_HADMOUSE ) && Menu_HasEvents( pItem ) )
			Raise_MouseEnter( pItem );
		if( pSelectMode != MENU_SELECT_NEVER && Menu_HasFlag( pItem, FLAG_SEALOFFMOUSE ) )
			Menu_ActiveItem = null_entity;
		if( ( pSelectMode == MENU_SELECT_ALWAYS ) ||
		    ( Menu_IsSelectable( pItem ) && pSelectMode == MENU_SELECT_SELECTABLE ) )
			Menu_ActiveItem = pItem;
	} else { // if the mouse isnt in the clip area, neither the children will be!
		if( Menu_HasRunFlag( pItem, RUNFLAG_HADMOUSE ) && Menu_HasEvents( pItem ) )
			Raise_MouseLeave( pItem );
		_Menu_Process_Debug_Print( "Aborted branching (Outside the clip area)\n" );
		return;
	}
	_Menu_Process_Debug_Print( "\n" );

	_Menu_Env_LoadOrigin( pItem );
	for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
		if( !Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWUPDATEONLY ) || !Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWONLY ) )
			_Menu_ProcessMouse( lChild, pSelectMode );
		else
			_Menu_ProcessMouse( lChild, MENU_SELECT_NEVER );
		_Menu_Env_Reload( pItem );
	}
};

float( float pRetValue ) _Menu_Process_Debug_Return =
{
	if( _menu_process_filtered )
		switch( pRetValue ) {
		case MENU_EVENT_NORMAL:
		case MENU_EVENT_CONTINUE:
			print( "MENU_EVENT_CONTINUE\n" );
			break;
		case MENU_EVENT_RAISEPARENT:
			print( "MENU_EVENT_RAISEPARENT\n" );
			break;
		case MENU_EVENT_PROCESSED:
			print( "MENU_EVENT_PROCESSED\n" );
			break;
		}

	return pRetValue;
};

float( entity pItem, float pKey, float pAscii ) _Menu_ProcessKey =
{
	local entity lChild;
	local float lResult;

	_Menu_Process_Debug_Print( strcat( "K ", ftos( pKey ), " ", pItem.name, " " ) );
	if( Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWUPDATEONLY ) || Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWONLY ) )
		return _Menu_Process_Debug_Return( MENU_EVENT_CONTINUE );

	_Menu_Env_LoadClipArea( pItem );

	if( Menu_ActiveItem == pItem ) {
		if( Raise_Key( pItem, pKey, pAscii ) )
			lResult = MENU_EVENT_PROCESSED;
		else
			lResult = MENU_EVENT_RAISEPARENT;

		return _Menu_Process_Debug_Return( lResult );
	}

	_Menu_Env_LoadOrigin( pItem );
	for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
		lResult = _Menu_ProcessKey( lChild, pKey, pAscii );
		_Menu_Env_Reload( pItem );

		if( lResult == MENU_EVENT_PROCESSED )
			return _Menu_Process_Debug_Return( MENU_EVENT_PROCESSED );
		else if( lResult == MENU_EVENT_RAISEPARENT )
			if( Raise_Key( pItem, pKey, pAscii ) )
				return _Menu_Process_Debug_Return( MENU_EVENT_PROCESSED );
			else
				return _Menu_Process_Debug_Return( MENU_EVENT_RAISEPARENT );
	}

	return _Menu_Process_Debug_Return( MENU_EVENT_CONTINUE );
};

float( entity pItem, float pMode, float pSelectMode, float pKey, float pAscii ) Menu_Process =
{
	local vector lSize, lPos, lOrigin;
	local float lResult;

	lSize = Menu_Clip_Size;
	lPos = Menu_Clip_Position;
	lOrigin = Menu_Origin;

	_Menu_Process_Debug_Filter( pMode, pSelectMode );

	lResult = 0;
	switch( pMode ) {
		case MENU_PROCESS_RUNFLAG:
			_Menu_ProcessRunFlag( pItem );
			break;
		case MENU_PROCESS_UPDATE:
			_Menu_ProcessUpdate( pItem );
			break;
		case MENU_PROCESS_DRAW:
			_Menu_ProcessDraw( pItem );
			break;
		case MENU_PROCESS_MOUSE:
			_Menu_ProcessMouse( pItem, pSelectMode );
			break;
		case MENU_PROCESS_KEY:
			lResult = _Menu_ProcessKey( pItem, pKey, pAscii );
			break;
	}

	Menu_Clip_Size = lSize;
	Menu_Clip_Position = lPos;
	Menu_Origin = lOrigin;
	Menu_Cursor_Position = Cursor_Position - Menu_Origin;
	if( pMode == MENU_PROCESS_DRAW )
		_MGX_SetClipArea();

	return lResult;
};

void() Menu_Frame =
{
	Sys_Debug_Frame();
	if( sys_debug_halt ) {
		return;
	}

	Menu_UpdateRunFlags();

	Menu_Process_Setup();
	// if mouse was moved, select an item
	if( Cursor_Relative != '0 0 0' ) {
		local entity lOld;

		lOld = Menu_ActiveItem;
		Menu_ProcessMouse( Menu_ActiveWindow, MENU_SELECT_SELECTABLE );

		if( !Menu_ActiveItem )
			Menu_ActiveItem = lOld;
		else if( lOld != Menu_ActiveItem ) {
			Raise_Select( lOld, false, true );
			Raise_Select( Menu_ActiveItem, true, true );
		}
	} else // just update mouseinarea
		Menu_ProcessMouse( Menu_ActiveWindow, MENU_SELECT_NEVER );

	// process the update event
	Menu_Process_Setup();
	Menu_ProcessUpdate( Menu_ActiveWindow, MENU_PROCESS_UPDATE );


	Menu_CollectGarbage( false );
}

void() Menu_Draw =
{
	if( sys_debug_halt ) {
		return;
	}
	// if Menu_ActiveWindow is visible loop though it
	if( Menu_IsVisible( Menu_ActiveWindow ) )
	{
		Menu_Process_Setup();
		Menu_ProcessDraw( Menu_ActiveWindow );
	}

	Sys_Debug_Draw();
};

void( float pKey, float pAscii) Menu_Key =
{
	if( sys_debug_halt ) {
		return;
	}

	// is a keyhook set ?
	if( Menu_KeyHook != Util_NullFunction ) {
		// call it
		Menu_KeyHook( pKey, pAscii );
		return;
	}
	// before calling the current keydown functions, process the mouse again
	// to make sure the correct item is called
	// (except mouse wheel up and down)
	// if the mouse doesnt point to an item, there wont be a reaction on the clicking
	if(K_MOUSE1 <= pKey && pKey <= K_MOUSE10) {
		local entity lOld;

		lOld = Menu_ActiveItem;
		Menu_ActiveItem = null_entity;
		Menu_ProcessMouse( Menu_ActiveWindow, MENU_SELECT_SELECTABLE );

		if( !Menu_ActiveItem ) {
			Menu_ActiveItem = lOld;
			return;
		} else if( lOld != Menu_ActiveItem ) {
			Raise_Select( lOld, false, true );
			Raise_Select( Menu_ActiveItem, true, true );
		}
	}

	// call current selected keydown function
	// if nothing is selected -> window has no items -> call window key
	if(Menu_ActiveItem == null_entity)
		Menu_Reselect( false );

	if( ( !Menu_IsSelectable( Menu_ActiveItem ) && Menu_ActiveItem != Menu_ActiveWindow ) ||
	     Menu_ProcessKey( Menu_ActiveWindow, pKey, pAscii ) != MENU_EVENT_PROCESSED )
		// If it goes really wrong:
		if( pKey == K_ESCAPE )
			if( gamestatus & GAME_DEVELOPER )
				error( " K_ESCAPE wasnt processed!\n" );
			else {
				Menu_Toggle();
				cmd( "menu_restart\n" );
			}
		else if( gamestatus & GAME_DEVELOPER ) {
			print( " Key ", ftos( pKey ), " ('" );
			print( chr( pAscii ), "') wasn't processed!\n" );
		}
};

bool() Menu_Toggle =
{
	// only let the qc toggle the menu if we are ingame or a developer
	if( gamestatus & GAME_CONNECTED || gamestatus & GAME_DEVELOPER ) {
		// then allow toggling
		m_hide();
		return true;
	} else
		return false;
};
