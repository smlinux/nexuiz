// Property of Alientrap/AK
// custom/player/avatar.qm

/*
===================
Item_Nex_Map_Info
===================
*/

void() Item_Nex_Map_Info_Destroy =
{
	String_EntityFree( self, link );
	String_EntityFree( self, picture );
	String_EntityFree( self, text );
	String_EntityFree( self, normal );
};

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
Item_Data_Nex_Avatar
===================
*/


// Nex_Action_Map_BuildAvatarList
// map definition format
// name
// rest: description text
void() _IDNM_BuildList =
{
	local float  	lSearchHandle;
	local float 	lSearchSize;
	local float 	lSearchCounter;
	local entity	lMap;

	// since we access two globals, we cant support calling BuildList multiple times, since this would leak str memory
	//Menu_EmptyWindow( self );
	Nex_MapList_FullPath = String_Create();
	Nex_MapList_Name = String_Create();

	lSearchHandle = search_begin( "maps/*.bsp", true, true );
	if( lSearchHandle < 0 )
		return;
	for( lSearchSize = search_getsize( lSearchHandle ), lSearchCounter = 0;
	lSearchCounter < lSearchSize; ++lSearchCounter ) {
		local float 	lHandle;

		local string	lFilename;
		local string 	lStripped;
		local string 	lName;
		local string	lDescription;
		local string	lTitle;

		lFilename = search_getfilename( lSearchHandle, lSearchCounter );
		lStripped = String_Zone( substring( lFilename, 0, strlen( lFilename ) - 4 ) );
		lName = String_Zone( substring( lStripped, 5, 100000 ) );

		lHandle = fopen( strcat( lStripped, ".txt" ), FILE_READ );
		if( lHandle < 0 ) {
			lTitle = String_Zone( lName );
			lDescription = String_Zone( strcat( "--NO INFORMATION AVAILABLE--\n", lFilename ) );
		} else {
			lTitle = String_Zone( fgets( lHandle ) );
			lDescription = String_Create();
			do {
				local string lLine;

				lLine = fgets( lHandle );
				lDescription = String_Append( lDescription, strcat( lLine, "\n" ) );
			} while( validstring( lLine ) );

			fclose( lHandle );
		}

		// add this avatar_info
		lMap = Menu_CreateItem( "Item_Nex_Map_Info", ftos( lSearchCounter ), self.name );

		lMap.link = lName;
		lMap.picture = lStripped;
		lMap.normal = lTitle;
		lMap.text = lDescription;

		Nex_MapList_FullPath = Util_AltStringPushBack( Nex_MapList_FullPath, lName );
		Nex_MapList_Name = Util_AltStringPushBack( Nex_MapList_Name, lTitle );

		Menu_LinkItem( lMap );

		String_Free( lTitle );
		String_Free( lName );
		String_Free( lStripped );
		String_Free( lDescription );
	}

	search_end( lSearchHandle );

	Menu_LinkChildren( self );

	self.minValue = 1;
	self.stepValue = 1;
	self.maxValue = fabs( lMap.orderPos );
};

void() _IDNM_UpdateLink =
{
	local float lCurrent;
	local float lTarget;
	local entity lMatch;

	lCurrent = fabs( self._link.orderPos );
	lTarget = self._realValue;
	if( lCurrent < lTarget )
		for( lMatch = self._link; lMatch._next && fabs( lMatch.orderPos ) != lTarget; lMatch = lMatch._next );
	else
		for( lMatch = self._link; lMatch._prev && fabs( lMatch.orderPos ) != lTarget; lMatch = lMatch._prev );
	// lMatch always is valid if there are any children
	self._link = lMatch;

	self._realValue = fabs( self._link.orderPos );
	String_EntitySet( self, value, ftos( self._realValue ) );
};

void() _IDNM_Sync =
{
	String_EntitySet( self, value, ftos( self._realValue ) );
	String_EntitySet( self, _syncValue, ftos( self._realValue ) );
};

void() _IDNM_Send =
{
	_IDNM_UpdateLink();
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNM_Test_Start =
{
	_IDNM_UpdateLink();
};

void() _IDNM_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	_IDNM_UpdateLink();
};

void() _IDNM_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNM_Send();
};

void( float pEvent ) Item_Data_Nex_Map_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNM_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNM_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNM_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNM_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNM_Test_End();
		break;
	case ITEM_DATALINK_SET:
		_IDNM_UpdateLink();
		break;
	}
};

void() Item_Data_Nex_Map_Spawn =
{
	Item_Data_Init();

	self.flag = self.flag | FLAG_HIDDEN;

	self._dataEvent = Item_Data_Nex_Map_DataEvent;

	_IDNM_BuildList();

	self._link = self._child;
	self._realValue = stof( self.defValue );
	_IDNM_UpdateLink();
};

void( float pEvent ) Item_DataLink_Nex_MapList_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		break;
	case ITEM_DATA_SEND:
		break;
	case ITEM_DATA_RESET:
		self._realValue = 0.0;
		break;
	case ITEM_DATA_TEST_START:
		break;
	case ITEM_DATA_TEST_END:
		break;
	case ITEM_DATALINK_SET:
		self._realValue = floor( self._realValue );
		if( self._realValue < 1.0 )
			self._realValue = 1.0;
		if( self._realValue > self.maxValue )
			self._realValue = self.maxValue;
		break;
	}
};

void() Item_DataLink_Nex_MapList_Destroy =
{
	String_EntityFree( self, valueList );

	Item_DataLink_Switch_Destroy();
};

void() Item_DataLink_Nex_MapList_Spawn =
{
	Item_DataLink_Switch_Init();
	String_EntityCreate( self, valueList );

	self.minValue = 1.0;
	self.maxValue = 1.0;
	self.stepValue = 0.0;

	self._dataEvent = Item_DataLink_Nex_MapList_DataEvent;
	self._destroy = Item_DataLink_Nex_MapList_Destroy;
};

void( entity pItem ) Item_DataLink_Nex_MapList_InitWithMapList =
{
	String_EntitySet( pItem, valueList, Nex_MapList_FullPath );
	String_EntitySet( pItem, descList, Nex_MapList_Name );

	Item_DataLink_Nex_MapList_UpdateRange( pItem );
};

void( entity pItem ) Item_DataLink_Nex_MapList_UpdateRange =
{
	pItem.minValue = 1.0;
	pItem.maxValue = Util_GetAltStringCount( pItem.descList );

	if( pItem.maxValue > 1.0 )
		pItem.stepValue = 1.0;
	else
		pItem.stepValue = 0.0;

};
