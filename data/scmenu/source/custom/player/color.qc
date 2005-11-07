// Property of Alientrap/AK
// custom/player/color.qc


/*
===================
Item_Data_Nex_Color
===================
*/

void() _IDNC_Sync =
{
	local float lPants;

	// color = shirt * 16 + pants
	lPants = cvar( "_cl_color" ) & 15;

	String_EntitySet( self, value, ftos( lPants ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNC_Send =
{
	cmd( strcat( "color \"", self.value, "\"\n" ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNC_Test_Start =
{
	cmd( strcat( "color \"", self.value, "\"\n" ) );
};

void() _IDNC_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	cmd( strcat( "color \"", self.value, "\"\n" ) );
};

void() _IDNC_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNN_Send();
};

void( float pEvent ) Item_Data_Nex_Color_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNC_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNC_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNC_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNC_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNC_Test_End();
		break;
	}
};

void() Item_Data_Nex_Color_Spawn =
{
	Item_Data_Init();

	self._reinit = _IDNC_Sync;
	self._dataEvent = Item_Data_Nex_Color_DataEvent;
};
