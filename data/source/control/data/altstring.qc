// DP/Nex Menu
// control/data/altstring.qc

void( float pEvent ) Item_DataLink_AltString_DataEvent =
{
	Item_DataLink_Update();

	if( !self._link )
		return;
	if( pEvent == ITEM_DATALINK_SET ) {
		self._link.value = Util_SetAltStringItem( self._link.value, self.stepValue, self.value );
		Raise_DataEvent( self._link, ITEM_DATALINK_SET );
	} else if( pEvent == ITEM_DATALINK_GET ) {
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		String_EntitySet( self, value, String_Normal( Util_GetAltStringItem( self._link.value, self.stepValue ) ) );
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_AltString_Spawn =
{
	Item_DataLink_Init();

	self._dataEvent = Item_DataLink_AltString_DataEvent;
};
