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
// model definition format
// name
// picture\n
// skin filename\n
// model filename\n
// rest: description text
void() _IDNM_BuildList =
{
	local float  	lSearchHandle;
	local float 	lSearchSize;
	local float 	lSearchCounter;
	local entity	lMap;

	Menu_EmptyWindow( self );

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

		lFilename = search_getfilename( lSearchHandle, lSearchCounter );
		lStripped = String_Zone( substring( lFilename, 0, strlen( lFilename ) - 4 ) );
		lName = String_Zone( substring( lStripped, 5, 100000 ) );

		lHandle = fopen( strcat( lStripped, ".txt" ), FILE_READ );
		if( lHandle < 0 )
			lDescription = String_Zone( strcat( "--NO INFORMATION AVAILABLE--\n", lFilename ) );
		else {
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
		lMap.normal = lName;
		lMap.text = lDescription;

		Menu_LinkItem( lMap );

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
