// DP/Nex Menu
// control/data/router.qc

void( float pEvent ) Item_DataLink_Splitter_DataEvent =
{
	local entity lChild;

	switch( pEvent ) {
		case ITEM_DATALINK_SET:
			for( lChild = self._child ; lChild ; lChild = lChild._next ) {
				lChild._realValue = self._realValue;
				Raise_DataEvent( lChild, ITEM_DATALINK_SET );
			}
		case ITEM_DATALINK_GET:
			if( self._child ) {
				Raise_DataEvent( self._child, ITEM_DATALINK_GET );
				self._realValue = self._child._realValue;
			}
			break;
		default:
			for( lChild = self._child ; lChild ; lChild = lChild._next )
				Raise_DataEvent( lChild, pEvent );
			break;
	}
};

void() Item_DataLink_Splitter_Spawn =
{
	Item_DataLink_Init();

	self._dataEvent = Item_DataLink_Splitter_DataEvent;
};
