// Property of Alientrap/AK
// custom/player/color.qc

/*
color/_cl_color

color = shirt * 16 + pants
*/

/*
===================
Item_Data_Nex_Color
===================
*/

void( string pValue ) _IDNC_SendSyncCmd = {
	local float lPants, lShirt, lCombined;

	lCombined = stof( pValue );
	lPants = lCombined & 0x0F;
	lShirt = (lCombined & 0xF0) / 16;

	cmd( "color ", ftos( lShirt ), " ", ftos( lPants ), "\n" );
	//print( "%color ", ftos( lPants ), " ", ftos( lShirt ), "\n" );
};

void() _IDNC_Sync =
{
	String_EntitySet( self, value, cvar_string( "_cl_color" ) );
	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNC_Send =
{
	_IDNC_SendSyncCmd( self.value );

	String_EntitySet( self, _syncValue, self.value );
};

void() _IDNC_Test_Start =
{
	_IDNC_SendSyncCmd( self.value );
};

void() _IDNC_Test_End =
{
	String_EntitySet( self, value, self._syncValue );
	_IDNC_SendSyncCmd( self.value );
};

void() _IDNC_Reset =
{
	String_EntitySet( self, value, self.defValue );
	_IDNC_Send();
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
Item_DataLink_Nex_PantsColor
===================
*/

void( float pEvent ) Item_DataLink_Nex_PantsColor_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		Item_DataLink_Value_Clamp();
		if( self._link ) {
			local float lShirt;
			local float lNewColor;

			self._realValue = stof( self.value );

			lShirt = (stof( self._link.value ) & 0xF0) / 16;
			lNewColor = self._realValue + lShirt * 16;

			self._link._realValue = lNewColor;
			String_EntitySet( self._link, value, Util_FloatToClampedText( lNewColor, 1.0 ) );

			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		self._realValue = stof( self._link.value ) & 0x0F;

		Item_DataLink_Value_Clamp();
		String_EntitySet( self, value, Item_DataLink_Value_ClampedText() );
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_Nex_PantsColor_Spawn =
{
	Item_DataLink_Value_Spawn();

	self.stepValue = 1.0;

	self._dataEvent = Item_DataLink_Nex_PantsColor_DataEvent;
};

/*
===================
Item_DataLink_Nex_ShirtColor
===================
*/

void( float pEvent ) Item_DataLink_Nex_ShirtColor_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		Item_DataLink_Value_Clamp();
		if( self._link ) {
			local float lPants;
			local float lNewColor;

			self._realValue = stof( self.value );

			lPants = stof( self._link.value ) & 0x0F;
			lNewColor = self._realValue * 16 + lPants;

			self._link._realValue = lNewColor;
			String_EntitySet( self._link, value, Util_FloatToClampedText( lNewColor, 1.0 ) );

			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		self._realValue = (stof( self._link.value ) & 0xF0) / 16;

		Item_DataLink_Value_Clamp();
		String_EntitySet( self, value, Item_DataLink_Value_ClampedText() );
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_Nex_ShirtColor_Spawn =
{
	Item_DataLink_Value_Spawn();

	self.stepValue = 1.0;

	self._dataEvent = Item_DataLink_Nex_ShirtColor_DataEvent;
};
