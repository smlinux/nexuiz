// Property of Alientrap
// custom/video.qc

void() _IDNR_Sync =
{
	String_EntitySet( self, value, strcat( cvar_string( "vid_width" ), " ", cvar_string( "vid_height" ) ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNR_Set =
{
	tokenize( self.value );
	cvar_set( "vid_width", argv( 0 ) );
	cvar_set( "vid_height", argv( 1 ) );
};

void() _IDNR_Send =
{
	_IDNR_Set();
	_IDNR_Sync();
};

void() _IDNR_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNR_Send();
};

void() _IDNR_Test_Start =
{
	_IDNR_Set();
};

void() _IDNR_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	_IDNR_Send();
};

void( float pEvent ) Item_Data_Nex_Resolution_DataEvent =
{
	switch( pEvent ) {
		case ITEM_DATA_SYNC:
		_IDNR_Sync();
		break;
		case ITEM_DATA_SEND:
		_IDNR_Send();
		break;
		case ITEM_DATA_RESET:
		_IDNR_Reset();
		break;
		case ITEM_DATA_TEST_START:
		_IDNR_Test_Start();
		break;
		case ITEM_DATA_TEST_END:
		_IDNR_Test_End();
		break;
	}
};

void() Item_Data_Nex_Resolution_Spawn =
{
	Item_Data_Init();

	self._dataEvent = Item_Data_Nex_Resolution_DataEvent;
	self._reinit = _IDNR_Sync;
};
