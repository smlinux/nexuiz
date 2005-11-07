// DP/Nex menu
// system/events.qc

// process stacks

void() Menu_Process_Setup =
{

	Menu_Origin = '0 0 0';
	Menu_Clip_Position = '0 0 0';
	Menu_Clip_Size = '0 0 0';

	Gfx_ResetClipArea();
}

void( vector pOrigin ) _Menu_Origin_Push =
{
	Menu_Origin = Menu_OrgToMen( pOrigin );

	if( _menu_process_filtered ) {
		print( "MGFX Pushed origin: ", vtos( pOrigin ), " Absolute ", vtos( Menu_Origin ), "\n" );
		//print( "MGFX Pushed origin: ", vtos( pOrigin ), " Absolute " );
		//print( vtos( Menu_Origin ), "\n" );
	}

	Menu_Cursor_Position = Cursor_Position - Menu_Origin;
};

void( vector pOldOrigin ) _Menu_Origin_Pop =
{
	Menu_Origin = pOldOrigin;

	if( _menu_process_filtered )
		print( "MGFX Popped origin for origin: ", vtos( Menu_Origin ), "\n" );

	Menu_Cursor_Position = Cursor_Position - Menu_Origin;
};

void( vector pPos, vector pSize ) _Menu_Clip_Push =
{
	local vector lDelta;

	if( pPos != '0 0 0' || pSize != '0 0 0' ) {
		if( (Menu_Clip_Position != '0 0 0' || Menu_Clip_Size != '0 0 0') ) {
			pPos = Menu_OrgToMen( pPos );
			lDelta = Util_GetClipDelta( pPos, Menu_Clip_Position, Menu_Clip_Size );
			pPos = pPos + lDelta;
			pSize = Util_ClipRect( pPos, pSize - lDelta, Menu_Clip_Position, Menu_Clip_Size );
		}

		Menu_Clip_Position = pPos;
		Menu_Clip_Size = pSize;
		Gfx_SetClipArea( Menu_Clip_Position_x, Menu_Clip_Position_y, Menu_Clip_Size_x, Menu_Clip_Size_y );
	}

	if( _menu_process_filtered ) {
		print( "MGFX Pushed clipper: ", vtos( pPos ), " " );
		print( vtos( pSize ) );
		print( " Clipped to: ", vtos( Menu_Clip_Position ), " " );
		print( vtos( Menu_Clip_Size),"\n" );
	}
};

void( vector pOldPos, vector pOldSize ) _Menu_Clip_Pop =
{
	Menu_Clip_Position = pOldPos;
	Menu_Clip_Size = pOldSize;

	if( sys_debug_mgfx ) {
		print( "MGFX Popped clipper for clip area: ", vtos( Menu_Clip_Position ), " " );
		print( vtos( Menu_Clip_Size ), "\n" );
	}

	if( Menu_Clip_Position == '0 0 0' && Menu_Clip_Size == '0 0 0' )
		Gfx_ResetClipArea();
	else
		Gfx_SetClipArea( Menu_Clip_Position_x, Menu_Clip_Position_y, Menu_Clip_Size_x, Menu_Clip_Size_y );
};

// debug process functions
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

void( string pText ) _Menu_Process_Debug_Print =
{
	if( _menu_process_filtered )
		print( pText );
};

void( entity pItem, float pMode, float pSelectState, float pKey, float pAscii ) _Menu_Process_Debug_Header =
{
	if( sys_debug_process && _menu_process_filtered ) {
		switch( pMode ) {
		case MENU_PROCESS_RUNFLAG:
			print( "R " );
			break;
		case MENU_PROCESS_UPDATE:
			print( "U " );
			break;
		case MENU_PROCESS_DRAW:
			print( "D " );
			break;
		case MENU_PROCESS_MOUSE:
			print( "M " );
			switch( pSelectState ) {
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
			break;
		case MENU_PROCESS_KEY:
			print( "K " );
			print( ftos( pKey ), " " );
			break;
		default:
			print( "~ " );
		}
		print( pItem.name, " " );
	}
};

void( float pRetValue ) _Menu_Process_Debug_Return =
{
	if( sys_debug_process && _menu_process_filtered )
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
};

// main process functions
float( entity pItem, float pMode, float pSelectState, float pKey, float pAscii ) Menu_Process =
{
	local entity lChild;
	local bool lContinue;
	local float lResult;
	// the new clip and origin stack
	local vector lOldOrigin, lOldClipPos, lOldClipSize;

	// set the debug filter
	_Menu_Process_Debug_Filter( pMode, pSelectState );

	_Menu_Process_Debug_Header( pItem, pMode, pSelectState, pKey, pAscii );

	// adjust the clip area
	lOldClipPos = Menu_Clip_Position;
	lOldClipSize = Menu_Clip_Size;
	_Menu_Clip_Push( pItem.pos, pItem.size );

	// test if its necessary to do anything
	lContinue = false;
	lResult = MENU_EVENT_NORMAL;
	switch( pMode ) {
	case MENU_PROCESS_RUNFLAG:
		lContinue = true;
		break;
	case MENU_PROCESS_MOUSE:
		if( !Menu_IsVisible( pItem ) )
			break;
		lContinue = true;
		break;
	case MENU_PROCESS_DRAW:
		if( !Menu_IsVisible( pItem ) )
			break;
		lContinue = true;
		break;
	case MENU_PROCESS_UPDATE:
		if( Menu_HasRunFlag( pItem, RUNFLAG_CHILDDRAWONLY ) )
			break;
		lContinue = true;
		break;
	case MENU_PROCESS_KEY:
		if( !Menu_HasEvents( pItem ) )
			break;
		lContinue = true;
		break;
	default:
		error( "Bad pMode in Menu_Processs!" );
		break;
	}
	if( !lContinue ) {
		_Menu_Process_Debug_Print( "Condition failed\n" );
		_Menu_Clip_Pop( lOldClipPos, lOldClipSize );
		return lResult;
	}

	// process the events for this item
	lContinue = true;
	switch( pMode ) {
	case MENU_PROCESS_RUNFLAG:
		Menu_SetRunFlag( pItem );
		break;
	case MENU_PROCESS_UPDATE:
		Raise_Update( pItem );
		if( Menu_HasRunFlag( pItem, RUNFLAG_HIDDEN ) )
			lContinue = false;
		break;
	case MENU_PROCESS_DRAW:
		Raise_Draw( pItem );
		break;
	case MENU_PROCESS_MOUSE:
		// check if the mouse is even in the clip area
		if( Util_InRect( Cursor_Position, Menu_Clip_Position, Menu_Clip_Size ) ||
		    ( Menu_Clip_Position == '0 0 0' && Menu_Clip_Size == '0 0 0' ) ) {
			pItem._runFlag = pItem._runFlag | RUNFLAG_MOUSEINAREA;

			if( !Menu_HasRunFlag( pItem, RUNFLAG_HADMOUSE ) && Menu_HasEvents( pItem ) )
				Raise_MouseEnter( pItem );
			if( pSelectState != MENU_SELECT_NEVER && Menu_HasFlag( pItem, FLAG_SEALOFFMOUSE ) )
				Menu_ActiveItem = null_entity;
			if( ( pSelectState == MENU_SELECT_ALWAYS ) ||
			    ( Menu_IsSelectable( pItem ) && pSelectState == MENU_SELECT_SELECTABLE ) )
				Menu_ActiveItem = pItem;
		} else if( Menu_HasRunFlag( pItem, RUNFLAG_HADMOUSE ) && Menu_HasEvents( pItem ) )
			Raise_MouseLeave( pItem );
		break;
	case MENU_PROCESS_KEY:
		if( Menu_ActiveItem == pItem ) {
			lContinue = false;
			if( Raise_Key( pItem, pKey, pAscii ) )
				lResult = MENU_EVENT_PROCESSED;
			else
				lResult = MENU_EVENT_RAISEPARENT;

			_Menu_Process_Debug_Return( lResult );
		}
		break;
	}
	if( !lContinue ) {
		_Menu_Process_Debug_Print( "Early\n" );
		_Menu_Clip_Pop( lOldClipPos, lOldClipSize );
		return lResult;
	}

	// we adjust the origin for the children
	lOldOrigin = Menu_Origin;
	_Menu_Origin_Push( pItem.pos + pItem.origin );

	_Menu_Process_Debug_Print( "\n" );

	switch( pMode ) {
	case MENU_PROCESS_RUNFLAG:
		for( lChild = pItem._child ; lChild ; lChild = lChild._next ) {
			Menu_InheritRunFlag( pItem, lChild );
			Menu_ProcessRunFlag( lChild );
		}
		break;
	case MENU_PROCESS_DRAW:
		for( lChild = pItem._child ; lChild ; lChild = lChild._next )
			Menu_ProcessDraw( lChild );
		break;
	case MENU_PROCESS_UPDATE:
		for( lChild = pItem._child ; lChild ; lChild = lChild._next )
			Menu_ProcessUpdate( lChild );
		break;
	case MENU_PROCESS_MOUSE:
		for( lChild = pItem._child ; lChild ; lChild = lChild._next )
			if( Menu_HasEvents( pItem ) )
				Menu_ProcessMouse( lChild, pSelectState );
			else
				Menu_ProcessMouse( lChild, MENU_SELECT_NEVER );
		break;
	case MENU_PROCESS_KEY:
		for( lChild = pItem._child ; lContinue && lChild ; lChild = lChild._next ) {
			local float lRet;

			lRet = Menu_ProcessKey( lChild, pKey, pAscii );

			switch( lRet ) {
			case MENU_EVENT_RAISEPARENT:
				lContinue = false;
				if( Raise_Key( pItem, pKey, pAscii ) )
					lResult = MENU_EVENT_PROCESSED;
				else
					lResult = MENU_EVENT_RAISEPARENT;
				break;
			case MENU_EVENT_PROCESSED:
				lResult = lRet;
				lContinue = false;
				break;
			case MENU_EVENT_CONTINUE:
				lResult = lRet;
				break;
			}
		}
		_Menu_Process_Debug_Return( lResult );
		break;
	}

	_Menu_Origin_Pop( lOldOrigin );

	_Menu_Clip_Pop( lOldClipPos, lOldClipSize );
	return lResult;
};

void() Menu_Frame =
{
	Sys_Debug_Frame();

	Menu_UpdateRunFlags();
	// process the update event
	Menu_Process_Setup();
	Menu_ProcessUpdate( Menu_ActiveWindow, MENU_PROCESS_UPDATE );

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

	Menu_CollectGarbage( false );
}

void() Menu_Draw =
{
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
