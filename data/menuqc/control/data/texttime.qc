// DP/Nex Menu
// control/data/texttime.qc

float() _IDLTT_ConvertTime =
{
	local float  lTotal;
	local float  lCurrent;
	local float  lCount, lCounter;

	lTotal = 0;

	lCount = tokenize( self.value );
	for( lCounter = 0; lCounter < lCount; ++lCounter ) {
		lCurrent = stof( argv( lCounter ) );
		lTotal = lTotal * 60 + lCurrent;

		if( argv( ++lCounter ) != ":" )
			break;
	}
	return rint( lTotal );
};

string() _IDLTT_MakeString =
{
	local string lString;
	local float  lTotal;
	local float  lCurrent;

	lTotal = rint( self._realValue );
	lString = "";
	do {
		lCurrent = mod( lTotal, 60 );

		if( lString == "" )
			lString = String_Zone( ftos( lCurrent ) );
		else
			lString = String_Set( lString, strcat( ftos( lCurrent ), ":", lString ) );

		lTotal = floor( lTotal / 60 );
	} while( lTotal );

	return lString;
};

void( float pEvent ) Item_DataLink_TextTime_DataEvent =
{
	Item_DataLink_Update();

	if( pEvent == ITEM_DATALINK_SET ) {
		self._link._realValue = _IDLTT_ConvertTime();
		Raise_DataEvent( self._link, ITEM_DATALINK_SET );
		self._realValue = self._link._realValue;
	} else if( !self._link )
		return;
	else if( pEvent == ITEM_DATALINK_GET ) {
		Raise_DataEvent( self._link, ITEM_DATALINK_GET );
		if( self._link._realValue != self._realValue ) {
			self._realValue = self._link._realValue;
			String_EntitySet( self, value, String_Normal( _IDLTT_MakeString() ) );
		}
	} else {
		Raise_DataEvent( self._link, pEvent );
		self._realValue = self._link._realValue;
		String_EntitySet( self, value, String_Normal( _IDLTT_MakeString() ) );
	}
};

void() Item_DataLink_TextTime_Spawn =
{
	Item_DataLink_Init();

	self._dataEvent = Item_DataLink_TextTime_DataEvent;
	self._realValue = self._link.minValue - 1;
};
