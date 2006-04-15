// Property of Alientrap/AK
// custom/creategame/filelist.qc

//Item_DataLink_Nex_FileList [Item_DataLink_Switch]

/*
===================
IDLNFL_Sync
===================
*/
void() IDLNFL_Sync = {
	local float lCount;
	local float lHandle;
	local float lMaskStart, lMaskedLength;
	local float lCounter;

	lHandle = search_begin( strcat( self.selected, "*.", self.normal ), true, true );
	if( lHandle < 0 ) {
		return;
	}
	lCount = search_getsize( lHandle );

	String_EntitySet( self, valueList, "" );
	String_EntitySet( self, descList, "" );

	lMaskStart = strlen( self.selected );
	lMaskedLength = lMaskStart + strlen( self.normal) + 1; // +1 because of the '.'
	for( lCounter = 0 ; lCounter < lCount ; lCounter++ ) {
		local string lFilename;

		lFilename = search_getfilename( lHandle, lCounter );
		self.valueList = Util_AltStringPushBack( self.valueList, lFilename );
		self.descList = Util_AltStringPushBack( self.descList, substring( lFilename, lMaskStart, strlen( lFilename ) - lMaskedLength ) );
	}

	self.minValue = 0.0;
	if( lCount > 0 ) {
		self.stepValue = 1.0;
		self.maxValue = lCount - 1;
	} else {
		self.stepValue = 0.0;
		self.maxValue = 0.0;
	}
};

/*
===================
Item_DataLink_Nex_FileList_Destroy
===================
*/
void() Item_DataLink_Nex_FileList_Destroy =
{
	String_EntityFree( self, valueList );
	String_EntityFree( self, normal );
	String_EntityFree( self, selected );

	Item_DataLink_Switch_Destroy();
};

/*
===================
Item_DataLink_Nex_FileList_DataEvent
===================
*/
void( float pEvent ) Item_DataLink_Nex_FileList_DataEvent =
{
	switch( pEvent ) {
		case ITEM_DATA_SYNC:
			IDLNFL_Sync();
			break;
		case ITEM_DATA_RESET:
			IDLNFL_Sync();
			self._realValue = 0.0;
			break;
		case ITEM_DATALINK_SET:
			Item_DataLink_Value_Clamp();
			break;
		case ITEM_DATALINK_GET:
			String_EntitySet( self, value, String_Normal( Util_GetAltStringItem( self.descList, self._realValue ) ) );
			break;
	}
};

/*
===================
Item_DataLink_Nex_FileList_Spawn
===================
*/
void() Item_DataLink_Nex_FileList_Spawn =
{
	Item_DataLink_Switch_Init();

	String_EntityCreate( self, valueList );
	String_EntityZone( self, normal );
	String_EntityZone( self, selected );

	self._reinit = IDLNFL_Sync;
	self._destroy = Item_DataLink_Nex_FileList_Destroy;
	self._dataEvent = Item_DataLink_Nex_FileList_DataEvent;
};
