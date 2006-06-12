// Property of Alientrap/AK
// custom/key.qc

void( float pEvent ) Item_Data_Nex_Key_DataEvent;

void() _IDNK_Sync =
{
	String_EntitySet( self, value, String_Normal( Key_GetBindList( self.target ) ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNK_Set =
{
	local float lCount, lCounter;

	lCount = Util_GetAltStringCount( self.value );
	Key_LimitBinds( 0, self.target );

	for( lCounter = 0 ; lCounter < lCount ; ++lCounter )
		Key_Bind( Key_GetName( stof( String_Normal( Util_GetAltStringItem( self.value, lCounter ) ) ) ), self.target );
};

void() _IDNK_Send =
{
	_IDNK_Set();
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNK_Reset =
{
	local float lCount, lCounter;
	local string lKey;
	// TODO: remove this - but we need this for testing purposes atm
	// INFO: defValue should contain the key names used by DP not the key numbers!
	if( !self.defValue )
		return;

	String_EntitySet( self, value, "" );

	lCount = Util_GetAltStringCount( self.defValue );
	Key_LimitBinds( 0, self.target );

	for( lCounter = 0 ; lCounter < lCount ; lCounter++ ) {
		lKey = Util_GetAltStringItem( self.defValue, lCounter );
		Key_Bind( lKey, self.target );
		String_EntitySet( self, value, strcat( self.value, " '", Key_GetNum( lKey ), "'" ) );
		String_Free( lKey );
	}

	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNK_Test_Start =
{
	_IDNK_Set();
};

void() _IDNK_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	_IDNK_Set();
};

void( float pEvent ) Item_Data_Nex_Key_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNK_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNK_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNK_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNK_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNK_Test_End();
		break;
	}
};

void() Item_Data_Nex_Key_Destroy =
{
	String_EntityFree( self, target );
	Item_Data_Destroy();
};

void() Item_Data_Nex_Key_Spawn =
{
	Item_Data_Init();

	String_EntityZone( self, target );

	self._destroy = Item_Data_Nex_Key_Destroy;
	self._reinit = _IDNK_Sync;
	self._dataEvent = Item_Data_Nex_Key_DataEvent;
};


/*
===================
Item_Nex_KeyButton Item_Button
===================
*/

bool( float pKey, float pAscii ) Item_Nex_KeyButton_Key =
{
	if( pKey == K_BACKSPACE ) {
		local float lNum;
		// unbind the key
		Raise_DataEvent( self._target, ITEM_DATALINK_GET );
		lNum = stof( self._target.value );
		if( lNum >= 0 ) {
			Key_Unbind( Key_GetName( lNum ) );
			Raise_DataEvent( self._target, ITEM_DATALINK_SET );
		}
		return true;
	} else if( pKey == K_UPARROW ) {
		Menu_SelectPrev( false );
		Menu_SelectPrev( true );
		return true;
	} else if( pKey == K_DOWNARROW ) {
		Menu_SelectNext( false );
		Menu_SelectNext( true );
		return true;
	} else
		return Item_Button_Key( pKey, pAscii );
};

void() Item_Nex_KeyButton_Update =
{
	local float lNum;
	Item_DataUser_Update();

	Raise_DataEvent( self._target, ITEM_DATALINK_GET );
	lNum = stof( self._target.value );
	if( lNum < 0 )
		String_EntitySet( self, normal, "-" );
	else
		String_EntitySet( self, normal, Key_GetName( lNum ) );
	Item_Button_Update();
};

void() Item_Nex_KeyButton_Destroy =
{
	Item_DataUser_Destroy();
	Item_Button_Destroy();
};

void() Item_Nex_KeyButton_Spawn =
{
	Item_DataUser_Init();
	Item_Button_Spawn();

	self._destroy = Item_Nex_KeyButton_Destroy;
	self._update = Item_Nex_KeyButton_Update;
	self._key = Item_Nex_KeyButton_Key;
};

