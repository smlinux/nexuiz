// DP/Nex Menu
// control/data/container.qc


////////////////////////
// Item_Data_Container
///

void() Item_Data_Container_Reinit =
{
	String_EntitySet( self, value, self._syncValue );
};

void( float pEvent ) Item_Data_Container_DataEvent =
{
	switch( pEvent ) {
		case ITEM_DATA_SYNC:
			String_EntitySet( self, value, self._syncValue );
			break;
		case ITEM_DATA_SEND:
			String_EntitySet( self, _syncValue, self.value );
			break;
		case ITEM_DATA_RESET:
			String_EntitySet( self, value, self.defValue );
			String_EntitySet( self, _syncValue, self.defValue );
			break;
	}
};

void() Item_Data_Container_Spawn =
{
	Item_Data_Init();

	self._reinit = Item_Data_Container_Reinit;
	self._dataEvent = Item_Data_Container_DataEvent;

	String_EntitySet( self, _syncValue, self.defValue );
};
