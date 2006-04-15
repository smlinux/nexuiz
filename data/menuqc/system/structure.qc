// DP/Nex Menu
// system/structure.qc

// TODO: finish the debug output
void( float pLevel, string pText ) _Menu_Structure_Debug =
{
	if( pLevel <= sys_debug_structure )
		print( pText );
};

void( bool pUser ) _Menu_Select =
{
	Raise_Select( Menu_ActiveItem, true, pUser );
};

entity( entity pItem ) _Menu_GetParent =
{
	if( !pItem._parent )
		return null_entity;
	if( Menu_IsEmbedded( pItem._parent ) )
		return _Menu_GetParent( pItem._parent );
	return pItem._parent;
};

bool( entity pItem, entity pParent ) _Menu_IsEmbeddedParentOf =
{
	if( pItem._parent == pParent )
		return true;
	if( Menu_IsEmbedded( pItem._parent ) )
		return _Menu_IsEmbeddedParentOf( pItem._parent, pParent );
	return false;
};

entity( entity pItem ) _Menu_GetFirst =
{
	if( Menu_IsEmbedded( pItem ) && pItem._child )
		return _Menu_GetFirst( pItem._child );
	return pItem;
};

entity( entity pItem ) _Menu_GetLast =
{
	if( Menu_IsEmbedded( pItem ) && pItem._child ) {
		local entity lNode;

		for( lNode = pItem._child ; lNode._next ; lNode = lNode._next );
		return _Menu_GetLast( lNode );
	}
	return pItem;
};

entity( entity pItem ) _Menu_GetNext =
{
	local entity lNext;

	lNext = pItem._next;
	if( lNext )
		return _Menu_GetFirst( lNext );
	if( Menu_IsEmbedded( pItem._parent ) && pItem._parent != Menu_ActiveWindow )
		return _Menu_GetNext( pItem._parent );
	else
		return null_entity;
};

entity( entity pItem ) _Menu_GetPrev =
{
	local entity lPrev;

	lPrev = pItem._prev;
	if( lPrev )
		return _Menu_GetLast( lPrev );
	if( Menu_IsEmbedded( pItem._parent ) && pItem._parent != Menu_ActiveWindow )
		return _Menu_GetPrev( pItem._parent );
	else
		return null_entity;
};

void() _Menu_SelectNext =
{
	local entity lTemp;

	if( !Menu_ActiveItem ) {
		_Menu_Structure_Debug( 1, "_SelectNext: Bad Menu_ActiveItem!\n" );
		return;
	}

	// try to select the next item
	lTemp = Menu_ActiveItem;
	while( (lTemp = _Menu_GetNext( lTemp )) != null_entity )
			if( Menu_IsSelectable( lTemp ) ) {
			Menu_ActiveItem = lTemp;
			_Menu_Structure_Debug( 1, strcat( "_SelectNext: ", lTemp.name, "\n" ) );
			return;
		}
	// loop
	// only because of embedded:
	for( lTemp = Menu_ActiveItem ; _Menu_GetPrev( lTemp ) ; lTemp = _Menu_GetPrev( lTemp ) );
// TODO: rewrite _Menu_Select* to use an additional temp variable for storing the result of the functionc all
	for( ; lTemp != Menu_ActiveItem ; lTemp = _Menu_GetNext( lTemp ) )
		if( Menu_IsSelectable( lTemp ) ) {
			Menu_ActiveItem = lTemp;
			_Menu_Structure_Debug( 1, strcat( "_SelectNext after loop: ", lTemp.name, "\n" ) );
			return;
		}
};

void() _Menu_SelectPrev =
{
	local entity lTemp;

	if( !Menu_ActiveItem ) {
		_Menu_Structure_Debug( 1, "_SelectPrev: Bad Menu_ActiveItem!\n" );
		return;
	}

	// try to select the previous item
	lTemp = Menu_ActiveItem;
	while( (lTemp = _Menu_GetPrev( lTemp )) != null_entity )
		if( Menu_IsSelectable( lTemp ) ) {
			Menu_ActiveItem = lTemp;
			_Menu_Structure_Debug( 1, strcat( "_SelectPrev: ", lTemp.name, "\n" ) );
			return;
		}
	// loop
	for( lTemp = Menu_ActiveItem ; _Menu_GetNext( lTemp ) ; lTemp = _Menu_GetNext( lTemp ) );
	for( ; lTemp != Menu_ActiveItem ; lTemp = _Menu_GetPrev( lTemp ) ) {
		if( Menu_IsSelectable( lTemp ) ) {
			Menu_ActiveItem = lTemp;
			_Menu_Structure_Debug( 1, strcat( "_SelectPrev after loop: ", lTemp.name, "\n" ) );
			return;
		}
	}
};

bool() _Menu_SelectUp =
{
	// Menu_ActiveItem is the child
	local entity lSelected, lParent, lNode;

	lSelected = Menu_ActiveItem;
	if( !lSelected ) {
		_Menu_Structure_Debug( 1, "_SelectUp: Bad Menu_ActiveItem!\n" );
		return false;
	}

	// If we try to select up the active window, we'll pop the menu history
	if( lSelected == Menu_ActiveWindow ) {
		// If there is no history, we quit the menu
		_Menu_Structure_Debug( 2, "_SelectUp: Selecting up current active window..\n" );
		if( Menu_History == null_entity ) {
			_Menu_Structure_Debug( 2, "_SelectUp: Empty history -> toggling menu..\n" );
			if( !Menu_Toggle() )
				Menu_Reselect( false );
			return true;
		}

		_Menu_Structure_Debug( 2, "_SelectUp: Popping history..\n" );
		Menu_History_Pop();
	}

	lParent = _Menu_GetParent( lSelected );
	if( !lParent ) {
		_Menu_Structure_Debug( 2, "_SelectUp: No parent and not active window!\n" );
		return false;
	}

	// If this window is selectable, we know that there is at least one selectable item in the parent,
	// thus we will select the parent
	if( Menu_IsSelectable( lParent ) ) {
		Menu_ActiveItem = lParent;
		_Menu_Structure_Debug( 1, strcat( "_SelectUp: first parent: ", lParent.name, "\n" ) );
		return true;
	}

	// if there is no parent window of this window (lParent), it's the active window
	// else we have failed
	if( lParent == Menu_ActiveWindow ) {
		Menu_ActiveItem = Menu_ActiveWindow;
		_Menu_Structure_Debug( 2, strcat( "_SelectUp: select up parent: ", Menu_ActiveItem.name, "\n" ) );
		if( _Menu_SelectUp() )
			return true;
		Menu_ActiveItem = lSelected;
		return false;
	} else if( !lParent._parent ) {
		_Menu_Structure_Debug( 1, "_SelectUp: No parent of parent and not active window!\n" );
		return false;
	}

	// If not, we try to determine whether the window is the first window with a selectable children in
	// the parent window. If lParent is the selected by selectdown, we move up, if not we have found it.
	// IDEA: inline this
	Menu_ActiveItem = _Menu_GetParent( lParent );
	_Menu_Structure_Debug( 2, strcat( "_SelectUp: SelectDown on parent of parent '", Menu_ActiveItem.name, "' \n" ) );
	_Menu_SelectDown();
	// thanks to embedded windows (and not only them) - added later on - perhaps doesnt really
	// fit into the old logic behind it - take this with caution
	for( lNode = Menu_ActiveItem ; lNode ; lNode = lNode._parent )
		if( lNode._parent == lParent ) {
			Menu_ActiveItem = _Menu_GetParent( lSelected ); //lParent._parent;
			if( _Menu_SelectUp() )
				return true;
			Menu_ActiveItem = lSelected;
			return false;
		}

	// else we have already found the window we have searched!
	return true;
};

void( entity pItem ) _Menu_PrintRunFlag;
bool() _Menu_SelectDown =
{
	// Menu_ActiveItem is the window
	local entity lParent, lChild;

	lParent = Menu_ActiveItem;
	if( !lParent ) {
		_Menu_Structure_Debug( 1, "_SelectDown: Bad Menu_ActiveItem!\n" );
		return false;
	}

	// lets find the first selectable item
	for( lChild = _Menu_GetFirst( lParent._child ) ; lChild ; lChild = _Menu_GetNext( lChild ) )
		if( Menu_IsSelectable( lChild ) ) {
			Menu_ActiveItem = lChild;
			_Menu_PrintRunFlag( lChild );
			_Menu_Structure_Debug( 1, strcat( "_SelectDown: ", lChild.name, "\n" ) );
			return true;
		}

	// lets find the first window that has a selectable item
	for( lChild = _Menu_GetFirst( lParent._child ) ; lChild ; lChild = _Menu_GetNext( lChild ) )
		if( !Menu_IsEmbedded( lChild ) ) {
			Menu_ActiveItem = lChild;
			_Menu_Structure_Debug( 2, strcat( "_SelectDown: Try child: ", Menu_ActiveItem.name, "\n" ) );
			if( _Menu_SelectDown() )
				return true;
		}

	Menu_ActiveItem = lParent;
	return false;
};

void() _Menu_Reselect =
{
	Menu_ActiveItem = Menu_ActiveWindow;
	_Menu_SelectDown();
};

void( bool pUser ) Menu_SelectNext =
{
	Raise_Select( Menu_ActiveItem, false, pUser );
	_Menu_SelectNext();
	Raise_Select( Menu_ActiveItem, true, pUser );
};

void( bool pUser ) Menu_SelectPrev =
{
	Raise_Select( Menu_ActiveItem, false, pUser );
	_Menu_SelectPrev();
	Raise_Select( Menu_ActiveItem, true, pUser );
};

bool( bool pUser ) Menu_SelectUp =
{
	local entity lOld;

	lOld = Menu_ActiveItem;
	if( _Menu_SelectUp() ) {
		Raise_Select( lOld, false, pUser );
		Raise_Select( Menu_ActiveItem, true, pUser );
		return true;
	}
	return false;
};

bool( bool pUser ) Menu_SelectDown =
{
	local entity lOld;

	lOld = Menu_ActiveItem;
	if( _Menu_SelectDown() ) {
		Raise_Select( lOld, false, pUser );
		Raise_Select( Menu_ActiveItem, true, pUser );
		return true;
	}
	return false;
};

void( entity pItem, bool pUser ) Menu_Select =
{
	Raise_Select( Menu_ActiveItem, false, pUser );
	_Menu_Structure_Debug( 1, strcat( "Menu_Select: ", pItem.name, "\n" ) );
	Menu_ActiveItem = pItem;
	Raise_Select( Menu_ActiveItem, true, pUser );
};

void( entity pItem, bool pUser ) Menu_CorrectSelection =
{
	if( Menu_ActiveItem != pItem )
		Menu_Select( pItem, pUser );
};

void( bool pUser ) Menu_Reselect =
{
	Raise_Select( Menu_ActiveItem, false, pUser );
	_Menu_Reselect();
	Raise_Select( Menu_ActiveItem, true, pUser );
};

void( entity pMenu, bool pMakeActive, bool pUser ) Menu_JumpToWindow =
{
	Raise_Select( Menu_ActiveItem, false, pUser );

	// only jump to windows
	if( !pMenu._child )
		error("Cant jump to ", pMenu.name, " !\n");

	// add a history point
	if( pMakeActive ) {
		Menu_History_Push( pMenu, Util_NullFunction );
		Menu_ActiveWindow = pMenu;
	}

	// now set the selected to the first selectable child
	Menu_ActiveItem = pMenu;
	if( !_Menu_SelectDown() )
		error( "Couldn't jump to ", pMenu.name, " !\n" );

	Raise_Select( Menu_ActiveItem, true, pUser );
};

#ifdef USEFUNCTIONS
bool( entity pEntity, float pFlag ) Menu_HasFlag =
{
	if( pEntity.flag & pFlag )
		return true;
	return false;
};

bool( entity pEntity, float pRunFlag ) Menu_HasRunFlag =
{
	if( pEntity._runFlag & pRunFlag )
		return true;
	return false;
};
#endif

entity( entity pOrigin, string pName, bool pThrow ) Menu_GetItemEx =
{
	local entity lItem;
	local string lFirstTwo;

	lFirstTwo = substring( pName, 0, 2 );

	// FIXME: perhaps add another function or do this in some other way
	if( lFirstTwo == "::" )
		lItem = findstring( null_entity,  name, substring( pName, 2, 100000 ) );
	// support for direction tokens, init token ##
	else if( lFirstTwo == "##" ) {
		local string lToken;
		local float lCount, lCounter;
		lItem = pOrigin;
		lCount = tokenize( substring( pName, 2, 100000 ) );
		// we have the following tokens atfer the ##: up down next prev
		for( lCounter = 0 ; lCounter < lCount && lItem ; ++lCounter ) {
			lToken = argv( lCounter );
			if( lToken == "up" )
				lItem = lItem._parent;
			else if( lToken == "down" )
				lItem = lItem._child;
			else if( lToken == "next" )
				lItem = lItem._next;
			else if( lToken == "prev" )
				lItem = lItem._prev;
			else
				error( "Bad direction link(bad token): '", pName, "'!" );
		}
	} else  {
		// we start from the current namespace and try to find the object
		// by checking for it in all parent namespaces
		lItem = null_entity;
		while( !lItem && (pOrigin = pOrigin._parent) != null_entity )
			lItem = findstring( null_entity, name, strcat( pOrigin.name, "::", pName ) );

		if( !lItem )
			lItem = findstring( null_entity, name, pName );
	}

	if( lItem == null_entity && pThrow )
		error( "Couldn't find item '", pName, "'!" );

	return lItem;
};

entity( entity pOrigin, string pName, bool pThrow ) Menu_GetChildEx =
{
	local entity lItem;

	if( pOrigin )
		lItem = findstring( null_entity, name, strcat( pOrigin.name, "::", pName ) );
	else
		lItem = findstring( null_entity, name, pName );

	if( lItem == null_entity && pThrow )
		error( "Couldn't find item '", pName, "'!" );

	return lItem;
};

entity( string pName ) Menu_GetItem =
{
	return Menu_GetItemEx( self, pName, true );
};

entity( string pName ) Menu_GetChild =
{
	return Menu_GetChildEx( self, pName, true );
};

void( entity pWindow ) Menu_EmptyWindow =
{
	local entity lChild;

	for( lChild = pWindow._child ; lChild ; lChild = lChild._next ) {
		Menu_EmptyWindow( lChild );
		Raise_Destroy( lChild );
		remove( lChild );
	}

	pWindow._child = null_entity;
};

void( entity pEntity ) Menu_RemoveItem =
{
	local entity lParent;
	// raise the destroy event
	lParent = pEntity._parent;
	Menu_EmptyWindow( pEntity );
	Raise_Destroy( pEntity );
	remove( pEntity );
	if( lParent )
		Menu_LinkChildren( lParent );
};

void( entity pItem ) _Menu_PrintRunFlag =
{
	if( sys_debug_runflag ) {
		print( " ", pItem.name, " Runflags: " );
		if( pItem._runFlag & RUNFLAG_TEMPLATE )
			print( "TEMPLATE " );
		if( pItem._runFlag & RUNFLAG_MOUSEINAREA )
			print( "MOUSEINAREA " );
		if( pItem._runFlag & RUNFLAG_HADMOUSE )
			print( "HADMOUSE " );
		if( pItem._runFlag & RUNFLAG_CHILDDRAWONLY )
			print( "CHILDDRAWONLY " );
		if( pItem._runFlag & RUNFLAG_CHILDDRAWUPDATEONLY )
			print( "CHILDDRAWUPDATEONLY " );
		if( pItem._runFlag & RUNFLAG_HIDDEN )
			print( "HIDDEN " );
		if( pItem._runFlag & RUNFLAG_CLIPPED )
			print( "CLIPPED " );
		if( pItem._runFlag & RUNFLAG_NOSELECT )
			print( "NOSELECT " );
		print( "\n" );
	}
};

void( entity pItem ) Menu_SetRunFlag =
{
	local float lFlag;
	local float lRunFlag;

	lFlag = pItem.flag;

	// RUNFLAG_TEMPLATE
	if( lFlag & FLAG_TEMPLATE )
		pItem._runFlag = pItem._runFlag | RUNFLAG_TEMPLATE;
	// RUNFLAG_HADMOUSE,
	lRunFlag = pItem._runFlag;
	if(lRunFlag & RUNFLAG_MOUSEINAREA )
		pItem._runFlag = (lRunFlag - RUNFLAG_MOUSEINAREA) | RUNFLAG_HADMOUSE;
	// RUNFLAG_MOUSEINAREA,
	// these will be handled in MENU_PROCESS_MOUSE
	// RUNFLAG_CHILDDRAWONLY,
	// RUNFLAG_CHILDDRAWONLY,
	// these two are handled in InheritRunFlag
	// RUNFLAG_CLIPPED,
	// check if it is within the clipping area (ie. really visible)
	// trick: since the position and size are clipped against the previous clipping area
	// Menu_Clip_Size will be '0 0 0', if the areas dont overlap
	if( Menu_Clip_Size == '0 0 0' && Menu_Clip_Position != '0 0 0' )
		pItem._runFlag = pItem._runFlag | RUNFLAG_CLIPPED;
	// RUNFLAG_HIDDEN
	lRunFlag = pItem._runFlag;
	if( ( lFlag & FLAG_HIDDEN  ) ||
		( lRunFlag & RUNFLAG_TEMPLATE ) ||
		( ( lFlag & FLAG_SERVERONLY ) && !( gamestatus & GAME_ISSERVER ) ) ||
		( ( lFlag & FLAG_CONNECTEDONLY ) && !( gamestatus & GAME_CONNECTED ) ) ||
		( ( lFlag & FLAG_DEVELOPERONLY ) && !( gamestatus & GAME_DEVELOPER ) ) )
		pItem._runFlag = lRunFlag | RUNFLAG_HIDDEN;
	// RUNFLAG_NOSELECT
	lRunFlag = pItem._runFlag;
	if( ( lFlag & FLAG_NOSELECT ) ||
		( lFlag & FLAG_DRAWONLY ) ||
		( lFlag & FLAG_DRAWUPDATEONLY ) ||
		( lFlag & FLAG_EMBEDDED ) ||
		( lRunFlag & RUNFLAG_TEMPLATE ) ||
		( lRunFlag & RUNFLAG_HIDDEN ) ||
		( lRunFlag & RUNFLAG_CHILDDRAWONLY ) ||
		( lRunFlag & RUNFLAG_CHILDDRAWUPDATEONLY ) )
		pItem._runFlag = lRunFlag | RUNFLAG_NOSELECT;

	_Menu_PrintRunFlag( pItem );
};

void( entity pParent, entity pItem ) Menu_InheritRunFlag =
{
	// reset the runflag
	pItem._runFlag = pItem._runFlag & (RUNFLAG_MOUSEINAREA | RUNFLAG_DELETEFRAME | RUNFLAG_DELETETOGGLE | RUNFLAG_SPAWNED);
	// inherit template
	if( pParent._runFlag & RUNFLAG_TEMPLATE )
		pItem._runFlag = pItem._runFlag | RUNFLAG_TEMPLATE;
	// inherit drawonly
	if( ( pParent._runFlag & RUNFLAG_CHILDDRAWONLY ) ||
		( pParent.flag & FLAG_CHILDDRAWONLY ) )
		pItem._runFlag = pItem._runFlag | RUNFLAG_CHILDDRAWONLY;
	// inherit drawupdateonly
	if( ( pParent._runFlag & RUNFLAG_CHILDDRAWUPDATEONLY )  ||
		( pParent.flag & FLAG_CHILDDRAWUPDATEONLY ) )
		pItem._runFlag = pItem._runFlag | RUNFLAG_CHILDDRAWUPDATEONLY;
	if( pParent._runFlag & RUNFLAG_HIDDEN )
		pItem._runFlag = pItem._runFlag | RUNFLAG_HIDDEN;
};

void() Menu_UpdateRunFlags =
{
	local vector lPos, lSize, lOrg;

	lPos = Menu_Clip_Position;
	lSize = Menu_Clip_Size;
	lOrg = Menu_Origin;

	Menu_Process_Setup();

	// set the runflag of the active window
	Menu_ActiveWindow._runFlag = Menu_ActiveWindow._runFlag & RUNFLAG_MOUSEINAREA;

	// update runflag by using the view tree
	Menu_ProcessRunFlag( Menu_ActiveWindow );

	Menu_Clip_Size = lSize;
	Menu_Clip_Position = lPos;
	Menu_Origin = lOrg;
	Menu_Cursor_Position = Cursor_Position - Menu_Origin;
};

bool( entity pEntity ) Menu_HasEvents =
{
	if( pEntity._runFlag & RUNFLAG_CHILDDRAWONLY )
		return false;
	if( pEntity._runFlag & RUNFLAG_CHILDDRAWUPDATEONLY )
		return false;
	if( pEntity.flag & FLAG_DRAWONLY )
		return false;
	if( pEntity.flag & FLAG_DRAWUPDATEONLY )
		return false;
	//if( pEntity._runflag & RUNFLAG_HIDDEN )
	//	return false;
	return true;
};

#ifdef USEFUNCTIONS
bool( entity pEntity ) Menu_IsVisible =
{
	return !(pEntity._runFlag & (RUNFLAG_HIDDEN | RUNFLAG_CLIPPED));
};

bool( entity pEntity ) Menu_IsSelectable =
{
	return !(pEntity._runFlag & RUNFLAG_NOSELECT); // && !(pEntity._runFlag & RUNFLAG_TEMPLATE);
};

bool( entity pEntity ) Menu_IsTemplate =
{
	return pEntity._runFlag & RUNFLAG_TEMPLATE;
};

bool( entity pEntity ) Menu_IsEmbedded =
{
	return pEntity.flag & FLAG_EMBEDDED;
};

string( entity pItem ) Menu_GetName =
{
	return substring( pItem.name, strlen( pItem.parent ) + 2, 100000 );
};
#endif
