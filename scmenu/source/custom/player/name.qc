// Property of Alientrap/AK
// custom/player/name.qc

/*
===================
Item_Data_Nex_Name
===================
*/

void() _IDNN_Sync =
{
	String_EntitySet( self, value, str_cvar( "_cl_name" ) );
	String_EntitySet( self, _syncValue, self.value );
};
void() _IDNN_Send =
{
	cmd( strcat( "name \"", self.value, "\"\n" ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNN_Test_Start =
{
	cmd( strcat( "name \"", self.value, "\"\n" ) );
};

void() _IDNN_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	cmd( strcat( "name \"", self.value, "\"\n" ) );
};

void() _IDNN_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNN_Send();
};

void( float pEvent ) Item_Data_Nex_Name_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNN_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNN_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNN_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNN_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNN_Test_End();
		break;
	}
};

void() Item_Data_Nex_Name_Spawn =
{
	Item_Data_Init();

	self._reinit = _IDNN_Sync;
	self._dataEvent = Item_Data_Nex_Name_DataEvent;
};
