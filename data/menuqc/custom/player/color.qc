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
	bprint("Pants: ", ftos(lPants), "\n");

	String_EntitySet( self, value, ftos( lPants ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNC_Send =
{
	local float lShirt;
	lShirt = (cvar( "_cl_color" ) / 16) & 15;	
	cmd( strcat( "color ", ftos( lShirt), " ", self.value, "\n" ) );
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


/*
===================
Item_Data_Nex_ColorShirt
===================
*/

void() _IDNCS_Sync =
{
	local float lShirt;

	// color = shirt * 16 + pants
	lShirt = (cvar( "_cl_color" ) / 16) & 15;
	
	bprint("Shirt: ", ftos(lShirt), "\n");

	String_EntitySet( self, value, ftos( lShirt ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNCS_Send =
{
	local float lPants;
	lPants = cvar( "_cl_color" ) & 15;
	cmd( strcat( "color ", self.value , " ", ftos( lPants ) , "\n" ) );
	String_EntitySet( self, _syncValue, self.value );
};


void() _IDNCS_Test_Start =
{
	//cmd( strcat( "color \"", self.value, "\"\n" ) );
};

void() _IDNCS_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	//cmd( strcat( "color \"", self.value, "\"\n" ) );
};


void() _IDNCS_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNN_Send();
};

void( float pEvent ) Item_Data_Nex_ColorShirt_DataEvent =
{
	switch( pEvent ) {
	case ITEM_DATA_SYNC:
		_IDNCS_Sync();
		break;
	case ITEM_DATA_SEND:
		_IDNCS_Send();
		break;
	case ITEM_DATA_RESET:
		_IDNCS_Reset();
		break;
	case ITEM_DATA_TEST_START:
		_IDNCS_Test_Start();
		break;
	case ITEM_DATA_TEST_END:
		_IDNCS_Test_End();
		break;
	}
};

void() Item_Data_Nex_ColorShirt_Spawn =
{
	Item_Data_Init();

	self._reinit = _IDNCS_Sync;
	self._dataEvent = Item_Data_Nex_ColorShirt_DataEvent;
};
