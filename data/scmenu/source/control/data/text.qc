// DP/Nex Menu
// control/data/text.qc

void( float pEvent ) Item_DataLink_Text_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		if( self.maxValue >= 0 )
			String_EntitySet( self, value, substring( self.value, 0, self.maxValue ) );
		if( self._link ) {
			String_EntitySet( self._link, value, self.value );
			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		String_EntitySet( self, value, self._link.value );
		if( self.maxValue >= 0 ) {
			Raise_DataEvent( self._link, ITEM_DATALINK_GET );
			String_EntitySet( self, value, substring( self.value, 0, self.maxValue ) );
		}
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_Text_Spawn =
{
	Item_DataLink_Init();

	self._dataEvent = Item_DataLink_Text_DataEvent;
};
