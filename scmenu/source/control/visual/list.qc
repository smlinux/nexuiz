// DP/Nex Menu
// control/visual/list.qc

void() Item_List_Draw =
{
	local float lStart;
	local float lLines;
	local float lLine;
	local float lEnd;
	local vector lPos;

	if( !self._target )
		return;

	Raise_DataEvent( self._target, ITEM_DATALINK_GET );
	lLines = floor( self.size_y / ( self.fontSize_y + 2 ) );
	lStart = max( 0, floor( DataLink_Switch_GetOrdinal( self._target, self._target._realValue ) - lLines / 2 ) );
	lEnd = min( lStart + lLines, DataLink_Switch_GetOrdinal( self._target, self._target.maxValue ) );

	lPos = '0 1 0' + self.pos;
	for( lLine = lStart ; lLine <= lEnd ; lLine++ ) {
		local string lText;
		lText = Util_GetAltStringItem( self._target.descList, lLine );
		if( lLine == DataLink_Switch_GetOrdinal( self._target, self._target._realValue ) ) {
			if( self._state == ITEM_STATE_SELECTED )
				Menu_DrawString( lPos, lText, self.fontSize, self.colorSelected, self.alphas_y, self.drawFlags_y );
			else if( self._state == ITEM_STATE_PRESSED )
				Menu_DrawString( lPos, lText, self.fontSize, self.colorPressed, self.alphas_z, self.drawFlags_z );
			else
				Menu_DrawString( lPos, lText, self.fontSize, self.colorInactive, self.alphaInactive, self.drawFlagInactive );
		} else {
			Menu_DrawString( lPos, lText, self.fontSize, self.color, self.alphas_x, self.drawFlags_x );
		}

		lPos_y = lPos_y + self.fontSize_y + 1;

		String_Free( lText );
	}
};

void() Item_List_Update =
{
	Item_DataUser_Update();

	if( self._presstime + ITEM_BUTTON_ACTIONTIME > Timer_Time )
		self._state = ITEM_STATE_PRESSED;
	else if( Menu_ActiveItem == self )
		self._state = ITEM_STATE_SELECTED;
	else
		self._state = ITEM_STATE_NORMAL;

	/*if( Menu_HasRunFlag( self, RUNFLAG_MOUSEINAREA ) ) {
		local float lItem;
		local float lStart;
		local float lLines;

		lLines = floor( self.size_y / ( self.fontSize_y + 2 ) );
		lStart = max( 0, floor( DataLink_Switch_GetOrdinal( self._target, self._target._realValue ) - lLines / 2 ) );
		lItem = floor( ( Menu_Cursor_Position_y - self.pos_y ) / ( self.fontSize_y + 2 ) );
		lItem = min( lStart + lItem, DataLink_Switch_GetOrdinal( self._target, self._target.maxValue ) );

		print( ftos( lItem ), "\n" );

		self._target._realValue = lItem * self._target.stepValue + self._target.minValue;
		Raise_DataEvent( self._target, ITEM_DATALINK_SET );

		CtCall_Action();
	}*/
};

void( bool pSelect, bool pUser ) Item_List_Select =
{
	if( pSelect && pUser )
		Sound_Play( self.soundSelected );
};

bool( float pKey, float pAscii ) Item_List_Key =
{
	if( pKey == K_DOWNARROW ) {
		Sound_Play( self.soundPressed );
		self._presstime = Timer_Time;

		self._target._realValue = self._target._realValue + 1;
		Raise_DataEvent( self._target, ITEM_DATALINK_SET );

		CtCall_Action();
		return true;
	} else if( pKey == K_UPARROW ) {
		Sound_Play( self.soundPressed );
		self._presstime = Timer_Time;

		self._target._realValue = self._target._realValue - 1;
		Raise_DataEvent( self._target, ITEM_DATALINK_SET );

		CtCall_Action();
		return true;
	}
	return false;
};

void() Item_List_Destroy =
{
	CtCall_Destroy();

	String_EntityFree( self, soundSelected );
	String_EntityFree( self, soundPressed );

	Item_DataUser_Destroy();
};

void() Item_List_Spawn =
{
	Item_DataUser_Init();

	String_EntityZone( self, soundSelected );
	String_EntityZone( self, soundPressed );

	Sound_Precache( self.soundSelected );
	Sound_Precache( self.soundPressed );

	self._draw = Item_List_Draw;
	self._update = Item_List_Update;
	self._select = Item_List_Select;
	self._key = Item_List_Key;
	self._reinit = CtCall_Reinit;

	CtCall_Init();
};
