// DP/Nex Menu
// control/data/textswitch.qc


void( float pEvent ) Item_DataLink_TextSwitch_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		Item_DataLink_Value_Clamp();
		if( self._link ) {
			String_EntitySet( self._link, value, String_Normal( Util_GetAltStringItem( self.valueList, self._realValue ) ) );
			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		local float lPos, lCount;
		// sync _link.value
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );

		// check if we need a full resync
		// TODO: Remove this check since we actually dont want to support twice-defined entries
		if( String_Normal( Util_GetAltStringItem( self.valueList, self._realValue ) ) == self._link.value ) {
			String_EntitySet( self, value, String_Normal( Util_GetAltStringItem( self.descList, self._realValue ) ) );
			return;
		}

		// resync _link.value
		lCount = Util_GetAltStringCount( self.valueList );
		for( lPos = 0 ; lPos < lCount ; ++lPos )
			if( String_Normal( Util_GetAltStringItem( self.valueList, lPos ) ) == self._link.value )
				break;

		if( lPos > lCount ) {
			// if there is no match test for a custom entry
			if( Util_GetAltStringCount( self.descList ) > lCount ) {
				lPos++;
			} else {
				lPos = 0;
			}
		}
		self._realValue = lPos;
		String_EntitySet( self, value, String_Normal( Util_GetAltStringItem( self.descList, lPos ) ) );
	} else
		Raise_DataEvent( self._link, pEvent );
};

void() Item_DataLink_TextSwitch_Destroy =
{
	String_EntityFree( self, valueList );
	Item_DataLink_Switch_Destroy();
};

void() Item_DataLink_TextSwitch_Spawn =
{
	Item_DataLink_Switch_Init();
	String_EntityZone( self, valueList );

	self.minValue = 0.0;
	if( self.maxValue == 0.0 )
		self.maxValue = Util_GetAltStringCount( self.valueList ) - 1;
	if( self.maxValue == 0.0 )
		self.stepValue = 0.0;
	else
		self.stepValue = 1.0;

	self._destroy = Item_DataLink_TextSwitch_Destroy;
	self._dataEvent = Item_DataLink_TextSwitch_DataEvent;
};
