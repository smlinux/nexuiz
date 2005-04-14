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
Item_DataLink_ClampText
===================
*/
string() Item_DataLink_ClampedValue =
{
	local float lLen;
	local float lClampedStep;
	if( self.stepValue == floor( self.stepValue ) )
		return ftos( self._realValue );
	// Get the integer length
	lLen = strlen( ftos( rint( self._realValue  ) ) );
	// Now add the step length
	lClampedStep = rint( 1.0 / (self.stepValue - floor( self.stepValue )) );
	lLen += strlen( ftos( lClampedStep ) );
	return substring( ftos( self._realValue ), 0, lLen );
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
		String_EntitySet( self, value, Item_DataLink_ClampedValue() );
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

