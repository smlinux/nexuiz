// DP/Nex Menu
// control/data/cvar.qc

/*
===================
Item_Data_Cvar
===================
*/

void() Item_Data_Cvar_Sync =
{
	String_EntitySet( self, _syncValue, cvar_string( self.cvarName ) );
	String_EntitySet( self, value, self._syncValue );
};

void() Item_Data_Cvar_Send =
{
	cvar_set( self.cvarName, self.value );
	Item_Data_Cvar_Sync();
};

void() Item_Data_Cvar_Reset =
{
	if( self.defValue ) {
		String_EntitySet( self, value, self.defValue );
	} else {
		String_EntitySet( self, value, cvar_defstring( self.cvarName ) );
	}
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
Item_Data_ServerCvar
===================
*/

void( string pValue ) Item_Data_ServerCvar_SendSyncCmd = {
	cmd( self.syncCmd, " \"", pValue, "\"\n" );
};
//#define Item_Data_ServerCvar_SendSyncCmd(pValue) cmd( self.syncCmd, " \"", pValue, "\"\n" )

void() Item_Data_ServerCvar_Sync =
{
	String_EntitySet( self, _syncValue, cvar_string( self.cvarName ) );
	String_EntitySet( self, value, self._syncValue );
};

void() Item_Data_ServerCvar_Send =
{
	Item_Data_ServerCvar_SendSyncCmd( self.value );
	String_EntitySet( self, _syncValue, self.value );
};

void() Item_Data_ServerCvar_Reset =
{
	if( self.defValue ) {
		String_EntitySet( self, value, self.defValue );
	} else {
		String_EntitySet( self, value, cvar_defstring( self.cvarName ) );
	}
	Item_Data_Cvar_Send();
};

void() Item_Data_ServerCvar_Test_Start =
{
	Item_Data_ServerCvar_SendSyncCmd( self.value );
};

void() Item_Data_ServerCvar_Test_End =
{
	Item_Data_ServerCvar_SendSyncCmd( self._syncValue );
};

void() Item_Data_ServerCvar_Save_ExecString = {
	Data_ExecString = String_Append( Data_ExecString, strcat( self.syncCmd, " \"", self.value, "\"\n" ) );
};

void( float pEvent ) Item_Data_ServerCvar_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		Item_Data_ServerCvar_Sync();
		break;
	case ITEM_DATA_SEND:
		Item_Data_ServerCvar_Send();
		break;
	case ITEM_DATA_RESET:
		Item_Data_ServerCvar_Reset();
		break;
	case ITEM_DATA_TEST_START:
		Item_Data_ServerCvar_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		Item_Data_ServerCvar_Test_End();
		break;
	case ITEM_DATA_SAVE_EXECSTRING:
		Item_Data_ServerCvar_Save_ExecString();
		break;
	}
};

void() Item_Data_ServerCvar_Destroy = {
	String_EntityFree( self, syncCmd );
	Item_Data_Cvar_Destroy();
};

void() Item_Data_ServerCvar_Spawn = {
	Item_Data_Cvar_Spawn();

	String_EntityZone( self, syncCmd );

	self._reinit = Item_Data_ServerCvar_Sync;
	self._destroy = Item_Data_ServerCvar_Destroy;
	self._dataEvent = Item_Data_ServerCvar_DataEvent;
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
