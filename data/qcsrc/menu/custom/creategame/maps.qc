// Property of Alientrap/AK
// custom/creategame/maps.qc

/*
===================
Item_Nex_Map_Info
===================
*/

/*
===================
Item_Nex_Map_Info_Destroy
===================
*/
void() Item_Nex_Map_Info_Destroy =
{
	String_EntityFree( self, link );
	String_EntityFree( self, picture );
	String_EntityFree( self, text );
	String_EntityFree( self, normal );
};

/*
===================
Item_Nex_Map_Info_Spawn
===================
*/
void() Item_Nex_Map_Info_Spawn =
{
	String_EntityZone( self, link );
	String_EntityZone( self, picture );
	String_EntityZone( self, text );
	String_EntityZone( self, normal );

	Gfx_Precache( self.picture );

	self._destroy =	Item_Nex_Map_Info_Destroy;
};

/*
===================
Item_Nex_MapDB
===================
*/
string _Nex_MapList_FullPath;
string _Nex_MapList_Name;
string _Nex_MapList_FilteredFullPath;
string _Nex_MapList_FilteredName;
string _Nex_MapList_Filter;
entity _Nex_MapList_Root;

/*
===================
Item_Nex_MapDB_EnumFiles
===================
*/
// map definition format
// name
// rest: description text
void() Item_Nex_MapDB_EnumFiles =
{
	local float lSearchHandle;
	local float lSearchSize;
	local float lSearchCounter;
	local entity lMap;

	lSearchHandle = search_begin( "maps/*.mapcfg", true, true );
	if( lSearchHandle < 0 )
		return;
	lSearchCounter = 0;
	for( lSearchSize = search_getsize( lSearchHandle );
	lSearchCounter < lSearchSize; ++lSearchCounter ) {
		local float 	lHandle;

		local string	lFilename;
		local string 	lStripped;
		local string 	lPic;
		local string 	lName;
		local string	lDescription;
		local string	lTitle;

		lFilename = search_getfilename( lSearchHandle, lSearchCounter );
		lStripped = String_Zone( substring( lFilename, 0, strlen( lFilename ) - 7 ) );
		lName = String_Zone( substring( lStripped, 5, 100000 ) );

		lHandle = fopen( strcat( lStripped, ".txt" ), FILE_READ );
		if( lHandle < 0 ) {
			lTitle = String_Zone( lName );
			lDescription = String_Zone( strcat( "\n--NO INFORMATION AVAILABLE--\n", lFilename ) );
		} else {
			// uncomment this line and comment the other if you have the old map info files
			//lTitle = String_Zone( lName );
			lTitle = String_Zone( fgets( lHandle ) );
			lPic = fgets( lHandle ); // also get picture
			if(lPic)
			{
				lStripped = String_Zone( lPic );
			}

			lDescription = String_Create();
			do {
				local string lLine;

				lLine = fgets( lHandle );
				lDescription = String_Append( lDescription, strcat( lLine, "\n" ) );
			} while( validstring( lLine ) );

			fclose( lHandle );
		}

		// save this in a new Map_Info
		lMap = Menu_CreateItem( "Item_Nex_Map_Info", ftos( lSearchCounter ), self.name );

		lMap.link = lName;
		// check the picture
		if( Gfx_Precache( lStripped ) ) {
			lMap.picture = lStripped;
		} else {
			lMap.picture = "gfx/m_nomap";
		}
		lMap.normal = lTitle;
		lMap.text = lDescription;

		_Nex_MapList_FullPath = Util_AltStringPushBack( _Nex_MapList_FullPath, lName );
		_Nex_MapList_Name = Util_AltStringPushBack( _Nex_MapList_Name, lTitle );

		Menu_LinkItem( lMap );

		String_Free( lTitle );
		String_Free( lName );
		String_Free( lStripped );
		String_Free( lDescription );
	}

	search_end( lSearchHandle );

	_Nex_MapList_FilteredFullPath = String_Set( _Nex_MapList_FilteredFullPath, _Nex_MapList_FullPath );
	_Nex_MapList_FilteredName = String_Set( _Nex_MapList_FilteredName, _Nex_MapList_Name );

	Menu_LinkChildren( self );

	self.minValue = 1;
	self.stepValue = 1;
	self.maxValue = fabs( lMap.orderPos );
};

/*
===================
Item_Nex_MapDB_Destroy
===================
*/
void() Item_Nex_MapDB_Destroy =
{
	String_Free( _Nex_MapList_FullPath );
	String_Free( _Nex_MapList_Name );
	String_Free( _Nex_MapList_FilteredFullPath );
	String_Free( _Nex_MapList_FilteredName );
	String_Free( _Nex_MapList_Filter );

	_Nex_MapList_Root = null_entity;
};

/*
===================
Item_Nex_MapDB_Spawn
===================
*/
void() Item_Nex_MapDB_Spawn =
{
	if( _Nex_MapList_Root )
		error( "There is already another Item_Nex_MapDB object!" );

	_Nex_MapList_FullPath = String_Create();
	_Nex_MapList_Name = String_Create();
	_Nex_MapList_FilteredFullPath = String_Create();
	_Nex_MapList_FilteredName = String_Create();
	_Nex_MapList_Filter = String_Create();
	_Nex_MapList_Root = self;

	Item_Nex_MapDB_EnumFiles();

	self._destroy = Item_Nex_MapDB_Destroy;
};

/*
===================
Nex_MapDB_GetByName
===================
*/
entity( string pPath ) Nex_MapDB_GetByPath =
{
	local entity lNode;

	if( !_Nex_MapList_Root )
		error( "No Item_Nex_MapDB found!" );

	for( lNode = _Nex_MapList_Root._child ; lNode ; lNode = lNode._next ) {
		if( lNode.link == pPath ) {
			return lNode;
		}
	}

	return null_entity;
};

/*
===================
Nex_MapDB_GetFilteredByIndex
===================
*/
entity( float pIndex ) Nex_MapDB_GetFilteredByIndex =
{
	local entity lNode;
	local float lFilteredIndex;

	if( !_Nex_MapList_Root )
		error( "No Item_Nex_MapDB found!" );

	pIndex = fabs( pIndex );
	lFilteredIndex = 0;
	for( lNode = _Nex_MapList_Root._child ; lNode ; lNode = lNode._next ) {
		if( substring( lNode.link, 0, strlen( _Nex_MapList_Filter ) ) == _Nex_MapList_Filter ) {
			++lFilteredIndex;
		}
		if( pIndex == lFilteredIndex ) {
			return lNode;
		}
	}

	return null_entity;
};

/*
===================
Nex_MapDB_GetByIndex
===================
*//*
entity( float pIndex ) Nex_MapDB_GetByIndex =
{
	local entity lNode;

	if( !_Nex_MapList_Root )
		error( "No Item_Nex_MapDB found!" );

	pIndex = fabs( pIndex );
	for( lNode = _Nex_MapList_Root._child ; lNode ; lNode = lNode._next ) {
		if( fabs( lNode.orderPos ) == pIndex ) {
			return lNode;
		}
	}

	return null_entity;
};*/

/*
===================
Nex_MapDB_FilterMaps
===================
*/
void( string pPrefix ) Nex_MapDB_FilterMaps =
{
	local float lPrefixLength;
	local float lCounter;
	local float lSize;

	_Nex_MapList_Filter = String_Set( _Nex_MapList_Filter, pPrefix );

	_Nex_MapList_FilteredFullPath = String_Set( _Nex_MapList_FilteredFullPath, "" );
	_Nex_MapList_FilteredName = String_Set( _Nex_MapList_FilteredName, "" );

	lPrefixLength = strlen( pPrefix );
	lSize = Util_GetAltStringCount( _Nex_MapList_FullPath );
	for( lCounter = 0 ; lCounter < lSize ; ++lCounter ) {
		local string lPath;

		lPath = Util_GetAltStringItem( _Nex_MapList_FullPath, lCounter );
		if( substring( lPath, 0, lPrefixLength ) == pPrefix ) {
			local string lName;
			lName = Util_GetAltStringItem( _Nex_MapList_Name, lCounter );

			_Nex_MapList_FilteredFullPath = Util_AltStringPushBack( _Nex_MapList_FilteredFullPath, lPath );
			_Nex_MapList_FilteredName = Util_AltStringPushBack( _Nex_MapList_FilteredName, lName );

			String_Free( lName );
		}

		String_Free( lPath );
	}
};

/*
===================
Nex_MapDB_GetFilteredPathAltString
===================
*/
string() Nex_MapDB_GetFilteredPathAltString =
{
	return _Nex_MapList_FilteredFullPath;
}

/*
===================
Nex_MapDB_GetFilteredNameAltString
===================
*/
string() Nex_MapDB_GetFilteredNameAltString =
{
	return _Nex_MapList_FilteredName;
};

/*
===================
Nex_MapDB_GetPathAltString
===================
*/
string() Nex_MapDB_GetPathAltString =
{
	return _Nex_MapList_FullPath;
};

/*
===================
Nex_MapDB_GetNameAltString
===================
*/
string() Nex_MapDB_GetNameAltString =
{
	return _Nex_MapList_Name;
};

/*
===================
Nex_MapDB_GetFilteredIndex
===================
*/
float( entity pItem ) Nex_MapDB_GetFilteredIndex =
{
	local float lIndex;
	local float lCount;

	lCount = Util_GetAltStringCount( _Nex_MapList_FilteredFullPath );
	for( lIndex = 0 ; lIndex < lCount ; ++lIndex ) {
		local string lPath;
		lPath = String_Normal( Util_GetAltStringItem( _Nex_MapList_FilteredFullPath, lIndex ) );
		if( lPath == pItem.link ) {
			return lIndex + 1;
		}
	}
	return 1;
};

/*
===================
Item_DataLink_Nex_MapList_Save
===================
*/
void() Item_DataLink_Nex_MapList_Save =
{
	local float lCount;
	local float lIndex;
	local string lOutput;

	lOutput = String_Create();

	lCount = Util_GetAltStringCount( self.valueList );
	for( lIndex = 0 ; lIndex < lCount ; lIndex++ ) {
		lOutput = String_Append( lOutput, strcat( "\'", String_Normal( Util_GetAltStringItem( self.valueList, lIndex ) ), "\'" ) );
	}

	cvar_set( self.cvarName, lOutput );
	cvar_set( strcat( self.cvarName, "_index" ), "0" );

	String_Free( lOutput );
};

/*
===================
Item_DataLink_Nex_MapList_Load
===================
*/
void() Item_DataLink_Nex_MapList_Load =
{
	local string lEntry;
	local entity lMapInfo;
	local float lCounter;
	local float lCount;

	DataLink_Nex_MapList_Clear( self );

	lCount = tokenize( cvar_string( self.cvarName ) );

	lEntry = String_Create();
	for( lCounter = 0 ; lCounter < lCount ; lCounter++ ) {
		lEntry = String_Set( lEntry, argv( lCounter ) );

		lMapInfo = Nex_MapDB_GetByPath( lEntry );
		if( lMapInfo == null_entity ) {
			print( self.cvarName, ": Map '", lEntry, "' not found in database - ignored\n" );
			continue;
		}

		self.descList = Util_AltStringPushBack( self.descList, lMapInfo.normal );
		self.valueList = Util_AltStringPushBack( self.valueList, lMapInfo.link );
	}
	String_Free( lEntry );

	DataLink_Nex_MapList_UpdateRange( self );
	Nex_MapSelector_Synchronize();
};

/*
===================
Item_DataLink_Nex_MapList_ExecString
===================
*/
void() Item_DataLink_Nex_MapList_ExecString =
{
	local float lCount;
	local float lIndex;

	Data_ExecString = String_Append( Data_ExecString, strcat( "set \"", self.cvarName, "_index\" \"0\"\nset \"", self.cvarName, "\" \"" ) );

	lCount = Util_GetAltStringCount( self.valueList );
	for( lIndex = 0 ; lIndex < lCount ; lIndex++ ) {
		Data_ExecString = String_Append( Data_ExecString, strcat( "\'", String_Normal( Util_GetAltStringItem( self.valueList, lIndex ) ), "\'" ) );
	}

	Data_ExecString = String_Append( Data_ExecString, "\"\n" );
};

/*
===================
Item_DataLink_Nex_MapList_DataEvent
===================
*/
void( float pEvent ) Item_DataLink_Nex_MapList_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		if( self.cvarName != "" ) {
			Item_DataLink_Nex_MapList_Load();
		}
		break;
	case ITEM_DATA_SEND:
		if( self.cvarName != "" ) {
			Item_DataLink_Nex_MapList_Save();
		}
		break;
	case ITEM_DATA_RESET:
		self._realValue = 1.0;
		break;
	case ITEM_DATA_TEST_START:
		break;
	case ITEM_DATA_TEST_END:
		break;
	case ITEM_DATA_SAVE_EXECSTRING:
		if( self.cvarName != "" ) {
			Item_DataLink_Nex_MapList_ExecString();
		}
		break;
	case ITEM_DATALINK_SET:
	case ITEM_DATALINK_GET:
		self._realValue = floor( self._realValue );
		if( self._realValue < 1.0 ) {
			self._realValue = 1.0;
		} else if( self._realValue > self.maxValue ) {
			self._realValue = self.maxValue;
		}

		break;
	}
};

/*
===================
IDLNML_Reinit
===================
*/
void() IDLNML_Reinit =
{
	Raise_DataEvent( self, ITEM_DATA_SYNC );
};

/*
===================
Item_DataLink_Nex_MapList_Destroy
===================
*/
void() Item_DataLink_Nex_MapList_Destroy =
{
	String_EntityFree( self, valueList );
	String_EntityFree( self, cvarName );

	Item_DataLink_Switch_Destroy();
};

/*
===================
Item_DataLink_Nex_MapList_Spawn
===================
*/
void() Item_DataLink_Nex_MapList_Spawn =
{
	Item_DataLink_Switch_Init();
	String_EntityZone( self, valueList );
	String_EntityZone( self, cvarName );

	if( self.cvarName != "" ) {
		registercvar( self.cvarName, "", CVAR_SAVE );
		registercvar( strcat( self.cvarName, "_index" ), "", CVAR_SAVE );
	}

	self.minValue = 1.0;
	self.maxValue = 1.0;
	self.stepValue = 0.0;

	self._reinit = IDLNML_Reinit;
	self._dataEvent = Item_DataLink_Nex_MapList_DataEvent;
	self._destroy = Item_DataLink_Nex_MapList_Destroy;

	CtCall_Init();
};

/*
===================
Item_DataLink_Nex_MapList_InitWithMapList
===================
*/
void() Item_DataLink_Nex_MapList_InitWithMapList =
{
	String_EntitySet( self, valueList, Nex_MapDB_GetFilteredPathAltString() );
	String_EntitySet( self, descList, Nex_MapDB_GetFilteredNameAltString() );

	self._realValue = 1.0;
	DataLink_Nex_MapList_UpdateRange( self );
};

/*
===================
DataLink_Nex_MapList_UpdateRange
===================
*/
void( entity pItem ) DataLink_Nex_MapList_UpdateRange =
{
	pItem.minValue = 1.0;
	pItem.maxValue = Util_GetAltStringCount( pItem.descList );

	if( pItem.maxValue >= 1 ) {
		pItem.stepValue = 1.0;
	} else {
		pItem.maxValue = 1.0;
		pItem.stepValue = 0.0;
	}
};

/*
===================
DataLink_Nex_MapList_InsertEntryAfter
===================
*/
void( entity pItem, string pName, string pPath ) DataLink_Nex_MapList_InsertEntryAfter =
{
	local float lIndex;

	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	// - 1, because minValue == 1
	lIndex = pItem._realValue - 1;
	pItem.descList = Util_InsAltStringItem( pItem.descList, lIndex, pName );
	pItem.valueList = Util_InsAltStringItem( pItem.valueList, lIndex, pPath );

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_DeleteEntry
===================
*/
void( entity pItem ) DataLink_Nex_MapList_DeleteEntry =
{
	local float lIndex;

	if( pItem.stepValue == 0.0 )
		return;

	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	lIndex = pItem._realValue - 1;
	pItem.descList = Util_DelAltStringItem( pItem.descList, lIndex );
	pItem.valueList = Util_DelAltStringItem( pItem.valueList, lIndex );

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_MoveEntryUp
===================
*/
void( entity pItem ) DataLink_Nex_MapList_MoveEntryUp =
{
	local string lName;
	local string lPath;
	local float lIndexNew;
	local float lIndexOld;

	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	if( pItem._realValue == 1 )
		return;

	// map 1..n to 0..n-1
	lIndexOld = pItem._realValue - 1;

	// we want to insert it up by one, ie. insert it after up by two
	lIndexNew = lIndexOld - 2;

	lName = Util_GetAltStringItem( pItem.descList, lIndexOld );
	lPath = Util_GetAltStringItem( pItem.valueList, lIndexOld );

	pItem.descList = Util_InsAltStringItem( pItem.descList, lIndexNew, String_Normal( lName ) );
	pItem.valueList = Util_InsAltStringItem( pItem.valueList, lIndexNew, String_Normal( lPath ) );

	// adjust lIndexOld for the entry that has been inserted before it
	lIndexOld = lIndexOld + 1;

	pItem.descList = Util_DelAltStringItem( pItem.descList, lIndexOld );
	pItem.valueList = Util_DelAltStringItem( pItem.valueList, lIndexOld );

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_MoveEntryDown
===================
*/
void( entity pItem ) DataLink_Nex_MapList_MoveEntryDown =
{
	local string lName;
	local string lPath;
	local float lIndexNew;
	local float lIndexOld;

	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	if( pItem._realValue == pItem.maxValue )
		return;

	// map 1..n to 0..n-1
	lIndexOld = pItem._realValue - 1;

	// we want to insert it down by one
	lIndexNew = lIndexOld + 1;

	lName = Util_GetAltStringItem( pItem.descList, lIndexOld );
	lPath = Util_GetAltStringItem( pItem.valueList, lIndexOld );

	pItem.descList = Util_InsAltStringItem( pItem.descList, lIndexNew, String_Normal( lName ) );
	pItem.valueList = Util_InsAltStringItem( pItem.valueList, lIndexNew, String_Normal( lPath ) );

	pItem.descList = Util_DelAltStringItem( pItem.descList, lIndexOld );
	pItem.valueList = Util_DelAltStringItem( pItem.valueList, lIndexOld );

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_SetFirst
===================
*/
void( entity pItem, string pName, string pPath ) DataLink_Nex_MapList_SetFirst =
{
	if( pItem.stepValue == 0.0 ) {
		pItem.descList = Util_AltStringPush( pItem.descList, pName );
		pItem.valueList = Util_AltStringPush( pItem.valueList, pPath );
	} else {
		pItem.descList = Util_SetAltStringItem( pItem.descList, 0, pName );
		pItem.valueList = Util_SetAltStringItem( pItem.valueList, 0, pPath );
	}

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_Clear
===================
*/
void( entity pItem ) DataLink_Nex_MapList_Clear =
{
	String_EntitySet( pItem, descList, "" );
	String_EntitySet( pItem, valueList, "" );

	DataLink_Nex_MapList_UpdateRange( pItem );
};

/*
===================
DataLink_Nex_MapList_GetCurrentName
===================
*/
string( entity pItem ) DataLink_Nex_MapList_GetCurrentName =
{
	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	return Util_GetAltStringItem( pItem.descList, pItem._realValue - 1 );
};

/*
===================
DataLink_Nex_MapList_GetCurrentPath
===================
*/
string( entity pItem ) DataLink_Nex_MapList_GetCurrentPath =
{
	Raise_DataEvent( pItem, ITEM_DATALINK_GET );
	return Util_GetAltStringItem( pItem.valueList, pItem._realValue - 1 );
};
