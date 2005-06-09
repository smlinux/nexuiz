// DP/Nex Menu
// control/data/cvar.qc

/*
===================
Item_Data_CvarCreateSave
===================
*/

void() Item_Data_Cvar_Sync =
{
	String_EntitySet( self, _syncValue, str_cvar( self.cvarName ) );
	String_EntitySet( self, value, self._syncValue );
};

void() Item_Data_Cvar_Send =
{
	cvar_set( self.cvarName, self.value );
	Item_Data_Cvar_Sync();
};

void() Item_Data_Cvar_Reset =
{
	String_EntitySet( self, value, self.defValue );
	Item_Data_Cvar_Send();
};

void() Item_Data_Cvar_Test_Start =
{
	cvar_set( self.cvarName, self.value );
};

void() Item_Data_Cvar_Test_End =
{
	cvar_set( self.cvarName, self._syncValue );
};

void() Item_Data_Cvar_Save_ExecString = {
	Data_ExecString = String_Append( Data_ExecString, strcat( "set \"", self.cvarName, "\" \"", self.value, "\"\n" ) );
};

void( float pEvent ) Item_Data_Cvar_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		Item_Data_Cvar_Sync();
		break;
	case ITEM_DATA_SEND:
		Item_Data_Cvar_Send();
		break;
	case ITEM_DATA_RESET:
		Item_Data_Cvar_Reset();
		break;
	case ITEM_DATA_TEST_START:
		Item_Data_Cvar_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		Item_Data_Cvar_Test_End();
		break;
	case ITEM_DATA_SAVE_EXECSTRING:
		Item_Data_Cvar_Save_ExecString();
		break;
	}
};

void() Item_Data_Cvar_Destroy =
{
	Item_Data_Destroy();
	String_EntityFree( self, cvarName );
};

void() Item_Data_Cvar_Spawn =
{
	String_EntityZone( self, cvarName );
	Item_Data_Init();

	self.flag = self.flag | FLAG_HIDDEN;

	self._dataEvent = Item_Data_Cvar_DataEvent;
	self._reinit = Item_Data_Cvar_Sync;
	self._destroy = Item_Data_Cvar_Destroy;
};

/*
===================
Item_Data_CvarCreateSave
===================
*/

void() Item_Data_CvarCreateSave_Spawn =
{
	Item_Data_Cvar_Spawn();

	registercvar( self.cvarName, self.defValue, CVAR_SAVE );
};
