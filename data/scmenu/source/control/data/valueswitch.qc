// DP/Nex Menu
// control/data/valueswitch.qc

/*
===================
Item_DataLink_ValueSwitch_DataEvent
===================
*/
void( float pEvent ) Item_DataLink_ValueSwitch_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		Item_DataLink_Value_Clamp();
		if( self._link ) {
			self._link._realValue = self._realValue;
			String_EntitySet( self._link, value, ftos( self._realValue ) );
			Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		}
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		local float lPos;

		Raise_DataEvent( self._link, ITEM_DATALINK_GET );

		self._realValue = stof( self._link.value );
		Item_DataLink_Value_Clamp();

		lPos = rint( (self._realValue - self.minValue) / self.stepValue  );
		String_EntitySet( self, value, String_Normal( Util_GetAltStringItem( self.descList, lPos ) ) );
	} else
		Raise_DataEvent( self._link, pEvent );
};

/*
===================
Item_DataLink_ValueSwitch_Spawn
===================
*/
void() Item_DataLink_ValueSwitch_Spawn =
{
	Item_DataLink_Switch_Init();

	if( self.maxValue == 0.0 )
		self.maxValue = self.minValue + (Util_GetAltStringCount( self.descList ) - 1) * self.stepValue;
	else {
		local float lCount;

		lCount = Util_GetAltStringCount( self.descList );
		if( lCount )
			self.stepValue = (self.maxValue - self.minValue ) / (lCount - 1);
		else
			self.stepValue = 0;
	}

	self._dataEvent = Item_DataLink_ValueSwitch_DataEvent;
	self._destroy = Item_DataLink_Switch_Destroy;
};
