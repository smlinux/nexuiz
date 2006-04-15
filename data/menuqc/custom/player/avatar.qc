// Property of Alientrap/AK
// custom/player/avatar.qm

/*
===================
Item_Nex_Avatar_Info
===================
*/

void() Item_Nex_Avatar_Info_Destroy =
{
	String_EntityFree( self, target );
	String_EntityFree( self, link );
	String_EntityFree( self, picture );
	String_EntityFree( self, text );
	String_EntityFree( self, normal );
};

void() Item_Nex_Avatar_Info_Spawn =
{
	String_EntityZone( self, target );
	String_EntityZone( self, link );
	String_EntityZone( self, picture );
	String_EntityZone( self, text );
	String_EntityZone( self, normal );

	Gfx_Precache( self.picture );

	self._destroy =	Item_Nex_Avatar_Info_Destroy;
};

/*
===================
Item_Data_Nex_Avatar
===================
*/


// Nex_Action_Player_BuildAvatarList
// model definition format
// name
// picture\n
// skin filename\n
// model filename\n
// rest: description text
void() _IDNA_BuildList =
{
	local float  	lSearchHandle;
	local float 	lSearchSize;
	local float 	lSearchCounter;
	local entity	lAvatar;

	Menu_EmptyWindow( self );

	// legacy mode
	// TODO:
	// FIXME: only accept *.mdef later
	lSearchHandle = search_begin( "models/player/*.txt", true, true );
	if( lSearchHandle < 0 )
		return;
	lSearchCounter = 0;
	for( lSearchSize = search_getsize( lSearchHandle );
	lSearchCounter < lSearchSize; ++lSearchCounter ) {
		local string 	lFilename;
		local float 	lHandle;

		local string 	lName;
		local string 	lPicture;
		local string	lSkin;
		local string 	lModel;
		local string	lDescription;

		lFilename = search_getfilename( lSearchHandle, lSearchCounter );
		lHandle = fopen( lFilename, FILE_READ );
		if( lHandle < 0 ) {
			print( "Menu: Couldn't open model definition file '", lFilename, "'\n" );
			continue;
		}

		lName = String_Zone( fgets( lHandle ) );
		lPicture = String_Zone(  fgets( lHandle ) );
		lSkin = String_Zone( fgets( lHandle ) );
		lModel = String_Zone( fgets( lHandle ) );
		if( !lName || !lPicture || !lSkin || !lModel ) {
			String_Free( lName );
			String_Free( lPicture );
			String_Free( lSkin );
			String_Free( lModel );
			print( "Menu: Couldn't parse model definition file '",
			 search_getfilename( lSearchHandle, lSearchCounter ), "'\n" );
			fclose( lHandle );
			continue;
		}
		lDescription = String_Create();
		do {
			local string lLine;

			lLine = fgets( lHandle );
			lDescription = String_Append( lDescription, strcat( lLine, "\n" ) );
		} while( validstring( lLine ) );
		if( lDescription ) { // add this avatar_info
			lAvatar = Menu_CreateItem( "Item_Nex_Avatar_Info", ftos( lSearchCounter ), self.name );

			lAvatar.target = lModel;
			lAvatar.link = lSkin;
			lAvatar.picture = lPicture;
			lAvatar.normal = lName;
			lAvatar.text = lDescription;

			Menu_LinkItem( lAvatar );
		}
		String_Free( lName );
		String_Free( lPicture );
		String_Free( lSkin );
		String_Free( lModel );
		String_Free( lDescription );
		fclose( lHandle );
	}

	search_end( lSearchHandle );

	Menu_LinkChildren( self );

	self.minValue = 1;
	self.stepValue = 1;
	self.maxValue = fabs( lAvatar.orderPos );
};

void() _IDNA_Sync =
{
	local string lModel, lSkin;
	local entity lMatch;

	lModel = String_Zone( cvar_string( "_cl_playermodel" ) );
	lSkin = String_Zone( cvar_string( "_cl_playerskin" ) );

	for( lMatch = self._child ; lMatch._next ; lMatch = lMatch._next )
		if( lMatch.target == lModel && lMatch.link == lSkin )
			break;

	if( lMatch ) {
		self._link = lMatch;
		self._realValue = fabs( lMatch.orderPos );
		String_EntitySet( self, value, ftos( self._realValue ) );
		String_EntitySet( self, _syncValue, self.value );
	}

	String_Free( lModel );
	String_Free( lSkin );
};

void() _IDNA_UpdateLink =
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

void() _IDNA_RawSet =
{
	_IDNA_UpdateLink();

	cmd( "playermodel \"", self._link.target, "\";" );
	cmd( "playerskin \"", self._link.link, "\"\n" );
};

void() _IDNA_Send =
{
	_IDNA_RawSet();

	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNA_Test_Start =
{
	_IDNA_RawSet();
};

void() _IDNA_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	_IDNA_RawSet();
};

void() _IDNA_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNA_Send();
};

void( float pEvent ) Item_Data_Nex_Avatar_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNA_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNA_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNA_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNA_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNA_Test_End();
		break;
	case ITEM_DATALINK_SET:
		_IDNA_UpdateLink();
		break;
	}
};

void() Item_Data_Nex_Avatar_Spawn =
{
	Item_Data_Init();

	self.flag = self.flag | FLAG_HIDDEN;

	self._reinit = _IDNA_Sync;
	self._dataEvent = Item_Data_Nex_Avatar_DataEvent;

	_IDNA_BuildList();
};
