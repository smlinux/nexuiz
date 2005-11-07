// DP/Nex Menu
// control/data/fastresync.qc

/////////////////////////////
// Item_DataLink_FastResync
////

void( float pEvent ) Item_DataLink_FastResync_DataEvent =
{
	if( pEvent == ITEM_DATALINK_GET ) {
		if( self._presstime != Timer_Time ) {
			Raise_DataEvent( self._link, ITEM_DATA_SYNC );
			self._presstime = Timer_Time;
		}
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		String_EntitySet( self, value, self._link.value );
		self._realValue = self._link._realValue;
	} else if( pEvent == ITEM_DATALINK_SET ) {
		if( self._link ) {
			String_EntitySet( self._link, value, self.value );
			self._link._realValue = self._realValue;
			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_FastResync_Spawn =
{
	Item_DataLink_Init();

	self._presstime = Timer_Time - 1;

	self._dataEvent = Item_DataLink_FastResync_DataEvent;
};
