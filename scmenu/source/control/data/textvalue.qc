// DP/Nex Menu
// control/data/textvalue.qc

void( float pEvent ) Item_DataLink_TextValue_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		self._link._realValue = stof( self.value );
		Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		self._realValue = self._link._realValue;
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		if( self._link._realValue != self._realValue ) {
			self._realValue = self._link._realValue;
			String_EntitySet( self, value, self._link.value );
		}
	} else {
		Raise_DataEvent( self._link, pEvent );
		self._realValue = self._link._realValue;
		String_EntitySet( self, value, self._link.value );
	}
};

void() Item_DataLink_TextValue_Spawn =
{
	Item_DataLink_Init();

	self._dataEvent = Item_DataLink_TextValue_DataEvent;
	self._realValue = self._link.minValue - 1;
};
