// DP/Nex Menu
// system/isframe.qc

void() Menu_Init =
{
	//registercvar("menu_reloadlist","0");

	Sys_Debug_Init();
	// do one frame to make it possible to debug the parser
	Sys_Debug_Frame();

	Campaign_Init();

	Menu_InitGarbageStats();
	Menu_Load();
};

void() Menu_Load =
{
	Parser_ParseMenu( MENU_MAINFILE, MENU_PLUGINDIR );

	Menu_LinkWindows();
};

// the good thing is, finddef doesnt fuck up any chain lists
entity(entity pStart, .string pFind1, string pMatch, .float pFind2, float pMatch2) finddef =
{
	while( 1 ) {
		pStart = findstring( pStart, pFind1, pMatch );
		if( pStart == null_entity )
			break;
		if( pStart.pFind2 == pMatch2 )
			break;
	}

	return pStart;
};

void( entity pParent ) Menu_LinkChildren =
{
	local entity lChild;
	local float  lOrder;
	local entity lPrevious;

	// build a list of all children
	lChild = findchainstring( parent, pParent.name );
	if( lChild == null_entity )
		return;

	// inverse the chain
	lPrevious = null_entity;
	while( lChild ) {
		local entity lNext;

		lNext = lChild.chain;
		lChild.chain = lPrevious;
		lPrevious = lChild;
		lChild = lNext;
	}
	lChild = lPrevious;

	lOrder = 1; // we start with orderPos 1 (0 is auto-set)
	lPrevious = null_entity;
	while( lChild ) {
		local entity lOverwrite;
		// try to find an item that has the current orderPos set
		lOverwrite = finddef( null_entity, parent, pParent.name, orderPos, lOrder );
		if( lOverwrite == lChild )
			lChild.orderPos = lOrder;
		else if( lOverwrite ) {
			// insert lOverwrite in front of lChild
			local entity lOPrevious;

			lOPrevious = findentity( null_entity, chain, lOverwrite );
			lOPrevious.chain = lOverwrite.chain;
			lOverwrite.chain = lChild;
			lChild = lOverwrite;
		} else
			lChild.orderPos = 0 - lOrder; //INFO: HACK: tell Spike

		// link it
		if( lPrevious )
			lPrevious._next = lChild;
		else
			pParent._child = lChild;
		lChild._prev = lPrevious;
		lChild._parent = pParent;

		lPrevious = lChild;
		lChild = lChild.chain;
		lOrder++;
	}
	lPrevious._next = null_entity;
};

void() Menu_LinkWindows =
{
	// first verify that MENU_NORMAL_NAME and MENU_INGAME_NAME exist
	// if not add the default strings
	local entity lEntity;

	dprint( "Loading defaults if necessary\n" );

	lEntity = findstring( null_entity, name, MENU_NORMAL_NAME );
	if( lEntity == null_entity )
		loadfromdata( MENU_NORMAL_DEFAULT );

	// verify again if MENU_NORMAL_NAME is there now
	lEntity = findstring( null_entity, name, MENU_NORMAL_NAME );
	if( lEntity == null_entity )
		error( "Bad MENU_NORMAL_DEFAULT!\n" );

	lEntity = findstring( null_entity, name, MENU_INGAME_NAME );
	if( lEntity == null_entity )
		loadfromdata( MENU_INGAME_DEFAULT );

	// verify again if MENU_INGAME_NAME is there now
	lEntity = findstring( null_entity, name, MENU_INGAME_NAME );
	if( lEntity == null_entity )
		error( "Bad MENU_INGAME_DEFAULT!\n" );

	dprint( "Verifying that every name is used only once\n" );

	// verify that every name is only used *once*
	lEntity = null_entity;
	while( ( lEntity = nextent( lEntity ) ) != null_entity ) {
		self = lEntity;
		while( ( self = findstring( self, name, lEntity.name ) ) != null_entity )
			if( self != null_entity )
				objerror( "Name ", lEntity.name, " already used!\n" );
	}

	dprint( "Verification of: name, type and parent fields\n" );

	// now we have to :
	// set the parent field with parent_name
	// check the type field
	self = null_entity;
	while( ( self = nextent( self ) ) != null_entity ) {
		if( self.name == "" ) {
			objerror( "Name is missing!\n" );
			continue;
		}

		if( self.type == "" ) {
			objerror( "Type is missing!\n" );
			continue;
		}

		if( !isfunction( strcat( self.type, "_Spawn" ) ) ) {
			objerror( "Control ", self.type, " not found!\n" );
			continue;
		}

		// find parent
		// if parent_name is "" do nothing else check whether the parent exists
		if( self.parent != "" ) {
			lEntity = findstring( null_entity, name, self.parent );

			if( lEntity == null_entity ) {
				objerror( "Item ", self.parent, " not found!\n" );
				continue;
			}
		}
		else
			self._parent = null_entity;
	}

	dprint( "Building the child lists\n" );
	// call LinkChildren for all entities
	lEntity = null_entity;
	while( ( lEntity = nextent( lEntity ) ) != null_entity )
		Menu_LinkChildren( lEntity );

	dprint( "Calling the type functions\n" );

	// call the type functions (former classname functions)
	lEntity = null_entity;
	while( ( lEntity = nextent( lEntity ) ) != null_entity ) {
		self = lEntity;
		//dprint("Calling ",self.type," (", etos(self),")\n");
		if( !Menu_HasFlag( self, FLAG_TEMPLATE ) && !Menu_HasRunFlag( self, RUNFLAG_SPAWNED ) ) {
			//print( lEntity.name, "\n" );
			callfunction( strcat( self.type, "_Spawn" ) );
			self._runFlag = self._runFlag | RUNFLAG_SPAWNED;
		} //else
			//print( "X ", lEntity.name, "\n" );
	}

	dprint( "Linking windows finished.\n" );
};

void( entity pItem ) Menu_LinkItem =
{
	local entity lEntity;
	local entity lOldSelf;

	if( Menu_HasRunFlag( pItem, RUNFLAG_SPAWNED ) )
		return;

	// verify the type
	if( pItem.type == "" )
		error( "LinkItem: Type is missing (", etos( pItem ), ")!\n" );

	if( !isfunction( strcat( pItem.type, "_Spawn" ) ) )
		error( "LinkItem: Control ", pItem.type, " not found (", etos( pItem ), ")!\n" );

	// verify name and parent
	lEntity = null_entity;
	while( (lEntity = findstring( lEntity, name, pItem.name )) != null_entity )
		if( lEntity != pItem )
			error( "LinkItem: Name '", pItem.name, "' already in use (", etos( pItem ), ", ", etos( lEntity ), ")!" );

	if( pItem.parent != "" ) {
		pItem._parent = findstring( null_entity, name, pItem.parent );

		if( !pItem._parent  )
			error( "LinkItem: Couldnt find parent '", pItem.parent, "' (", etos( pItem ), ")!" );
	} else
		pItem._parent = null_entity;

	// Add the children
	Menu_LinkChildren( pItem );

	// link children
	for( lEntity = pItem._child ; lEntity ; lEntity = lEntity._next )
		Menu_LinkItem( lEntity );

	// call the spawn function
	lOldSelf = self;
	self = pItem;
	if( !Menu_HasFlag( self, FLAG_TEMPLATE ) ) {
		callfunction( strcat( self.type, "_Spawn" ) );
		self._runFlag = self._runFlag | RUNFLAG_SPAWNED;
	}
	self = lOldSelf;
};

void() Menu_Hide =
{
	Raise_Select( Menu_ActiveItem, false, false );
	Menu_CollectGarbage( true );
	Menu_ResetGarbageStats();
};

void() Menu_PerformReinit =
{
	// clear history
	Menu_History_Clear();

	// reset the key hook (if necessary at all)
	Menu_KeyHook = Util_NullFunction;

	// choose which menu to display
	// AK 05: added support for scmenu_directmenu
	if( cvar_string( "scmenu_directmenu" ) != "" ) {
		Menu_ActiveWindow = findstring( null_entity, name, cvar_string( "scmenu_directmenu" ) );
		cvar_set( "scmenu_directmenu", "" );
	} else if( MENU_ALLOWINGAME && ( gamestatus & GAME_CONNECTED ) )
		Menu_ActiveWindow = findstring( null_entity, name, MENU_INGAME_NAME );
	else
		Menu_ActiveWindow = findstring( null_entity, name, MENU_NORMAL_NAME );

	// and reinit all menu items
	self = null_entity;
	while( (self = nextent( self ) ) != null_entity ) {
		if( self.parent == "" )
			self._parent = null_entity;
		//else actually this shouldnt happen
		else if( self._parent.name != self.parent )
			objerror( "Parent (should be ", self.parent, ") of menu item ", self.name, " changed to ", self._parent.name, " !\n" );

		Raise_Reinit( self ); // always call reinit
	}

	// run one runflag frame to (re)init the runflags
	Menu_UpdateRunFlags();

	Menu_Reselect( false );
};

void() Menu_Shutdown =
{
	// call the terminate event for each object
	self = null_entity;
	while( ( self = nextent( self ) ) != null_entity )
		Raise_Destroy( self );
	Campaign_Shutdown();
};

entity( string pType, string pName, string pParent ) Menu_CreateItem =
{
	local entity lItem;

	if( !pType )
		error( "Bad pType '", pType, "'!" );
	if( !pName )
		error( "Bad pName '", pName, "'!" );

	lItem = spawn();
	parseentitydata( lItem, strcat( "{ type \"", pType, "\" name \"", strcat( pParent, "::", pName ), "\" parent \"", pParent, "\" }" ) );
	return lItem;
};

entity( entity pTemplate, string pName, string pParent, bool pTree ) Menu_DeriveItem =
{
	local entity lItem;
	local entity lChild;

	if( !pTemplate )
		error( "Null pTemplate!" );
	if( !pName )
		error( "Bad pName '", pName, "'!" );

	lItem = spawn();
	copyentity( pTemplate, lItem );
	if( lItem.flag & FLAG_TEMPLATE )
		lItem.flag = lItem.flag - FLAG_TEMPLATE;
	if( lItem._runFlag & RUNFLAG_SPAWNED )
		lItem._runFlag = lItem._runFlag - RUNFLAG_SPAWNED;
	parseentitydata( lItem, strcat( "{ name \"", strcat( pParent, "::", pName ), "\" parent \"", pParent, "\" }" ) );

	if( pTree )
		for( lChild = pTemplate._child ; lChild ; lChild = lChild._next ) {
			local string lName;
			lName = String_Zone( substring( lChild.name, strlen( lChild.parent ) + 2, 100000 ) );
			Menu_DeriveItem( lChild, lName, lItem.name, true );
			String_Free( lName );
		}

	return lItem;
};

void( entity pItem, string pData ) Menu_AddEntityData =
{
	parseentitydata( pItem, pData );
};

void( entity pWindow ) Menu_LinkWindow =
{
	Menu_LinkItem( pWindow );
};
