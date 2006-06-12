// DP/Nex Menu
// control/data/value.qc

/*
===================
Item_DataLink_Value_Clamp
===================
*/
void() Item_DataLink_Value_Clamp =
{
	if( self._realValue > self.maxValue && self.maxValue > self.minValue )
		self._realValue = self.maxValue;
	else if( self._realValue < self.minValue )
		self._realValue = self.minValue;
	else // clamp it to(?) stepValue
		self._realValue =  self.minValue + self.stepValue * rint( ( self._realValue - self.minValue ) / self.stepValue );
};

/*
===================
Item_DataLink_Value_ClampedText
===================
*/
string() Item_DataLink_Value_ClampedText =
{
	return Util_FloatToClampedText( self._realValue, self.stepValue );
}

/*
===================
Item_DataLink_Value_DataEvent
===================
*/
void( float pEvent ) Item_DataLink_Value_DataEvent =
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
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		self._realValue = stof( self._link.value );
		String_EntitySet( self, value, Item_DataLink_Value_ClampedText() );
		Item_DataLink_Value_Clamp();
	} else
		Raise_DataEvent( self._link, pEvent );
};

/*
===================
Item_DataLink_Value_Spawn
===================
*/
void() Item_DataLink_Value_Spawn =
{
	Item_DataLink_Init();

	if( self.stepValue == 0.0 )
		self.stepValue = 1;

	self._dataEvent = Item_DataLink_Value_DataEvent;
};

