// DP/Nex Menu
// control/visual/editbox.qc

/////////////////
// Item_EditBox
///

void() Item_EditBox_Draw =
{
	local vector lCursor;
	local float lAlpha;

	if( !self._target )
		return;

	Raise_DataEvent( self._target, ITEM_DATALINK_GET );

	if( self._state == ITEM_STATE_NORMAL ) {
		Menu_DrawString( self.pos + self.origin, self._target.value, self.fontSize, self.color, self.alphas_x, self.drawFlags_x );
		return;
	}

	lCursor_x = self._cursorPos * self.fontSize_x;
	lCursor_y = self.fontSize_y;

	if( mod( Timer_Time * 1000, 1000 / ITEM_EDITBOX_CURSOR_FREQ ) > 500 / ITEM_EDITBOX_CURSOR_FREQ )
		lAlpha = 1;
	else
		lAlpha = 0;
	//lAlpha = 1.2 - fabs( 1 + floor( Timer_Time * ITEM_EDITBOX_CURSOR_FREQ / 2 ) * 2 - Timer_Time * ITEM_EDITBOX_CURSOR_FREQ );

	if( self._state == ITEM_STATE_SELECTED ) {
		lCursor_y = lCursor_y - self.sizeCursor_y;
		Menu_DrawString( self.pos + self.origin, self._target.value, self.fontSize, self.colorSelected, self.alphas_y, self.drawFlags_y );
		Menu_Fill( self.pos + self.origin + lCursor, self.sizeCursor, self.colorCursor, self.alphasCursor_x * lAlpha, self.drawFlagsCursor_x );
	} else {
		lCursor_y = lCursor_y - self.sizeCursorFlash_y;
		Menu_DrawString( self.pos + self.origin, self._target.value, self.fontSize, self.colorPressed, self.alphas_z, self.drawFlags_z );
		Menu_Fill( self.pos + self.origin + lCursor, self.sizeCursorFlash, self.colorCursorFlash, self.alphasCursor_y * lAlpha, self.drawFlagsCursor_y );
	}
};

void() Item_EditBox_Update =
{
	Item_DataUser_Update();

	if( self._presstime + ITEM_EDITBOX_FLASHTIME > Timer_Time )
		self._state = ITEM_STATE_PRESSED;
	else if( Menu_ActiveItem == self )
		self._state = ITEM_STATE_SELECTED;
	else
		self._state = ITEM_STATE_NORMAL;

	if( !self._target )
		return;

	// clamp the cursor position if necessary
	Raise_DataEvent( self._target, ITEM_DATALINK_GET );
	self._cursorPos = bound( 0, self._cursorPos, strlen( self._target.value ) );

	// scroll the text if necessary
	// save the scrolled position in origin
	self.origin_y = 0;
	if( ( self._cursorPos + ITEM_EDITBOX_SCROLLDISTANCE > self.size_x / self.fontSize_x )
		&& ( self._target.maxValue - ITEM_EDITBOX_SCROLLDISTANCE > self.size_x / self.fontSize_x ) )
		self.origin_x = self.fontSize_x * ( floor( self.size_x / self.fontSize_x ) - self._cursorPos - ITEM_EDITBOX_SCROLLDISTANCE );
	else
		self.origin_x = 0;
};

void() _IEB_RemoveChar =
{
	local string lTemp;
	local string lValue;

	lValue = self._target.value;
	// TODO: perhaps use strlen perhaps
	// FIXME: FteQCC bug: lTemp = strcat( substring( lValue, 0, self._cursorPos ), substring( lValue, self._cursorPos + 1, 100000 ) );
	lTemp = strcat( substring( lValue, 0, self._cursorPos ) );
	lTemp = strcat( lTemp, substring( lValue, self._cursorPos + 1, 100000 ) );
	String_EntitySet( self._target, value, lTemp );
	Raise_DataEvent( self._target, ITEM_DATALINK_SET );

	self._presstime = Timer_Time;
	Sound_Play( self.soundKey );
};

void( float pAscii ) _IEB_InsertChar =
{
	local string lValue;
	local string lTemp;

	lValue = self._target.value;
	lTemp = strcat( substring( lValue, 0, self._cursorPos ) , chr( pAscii ) );
	lTemp = strcat( lTemp, substring( lValue, self._cursorPos, 100000 ) );
	// FIXME: FTEQCC bug: lTemp = strcat( substring( lValue, 0, self._cursorPos ) , chr( pAscii ), substring( lValue, self._cursorPos, 100000 ) );
	String_EntitySet( self._target, value, lTemp );
	Raise_DataEvent( self._target, ITEM_DATALINK_SET );

	self._cursorPos = self._cursorPos + 1;

	self._presstime = Timer_Time;
	Sound_Play( self.soundKey );
};

bool( float pKey, float pAscii ) Item_EditBox_Key =
{
	if( !self._target )
		return false;
	else if( pKey == K_ENTER ) {
		CtCall_Action();
		Sound_Play( self.soundKey );
		return true;
	} else if( pKey == K_LEFTARROW ) {
		if( self._cursorPos )
			self._cursorPos = self._cursorPos - 1;
		Sound_Play( self.soundMove );
		return true;
	} else if( pKey == K_RIGHTARROW ) {
		if( self._cursorPos < strlen( self._target.value ) )
			self._cursorPos = self._cursorPos + 1;
		Sound_Play( self.soundMove );
		return true;
	} else if( pKey == K_BACKSPACE ) {
		if( self._cursorPos > 0 ) {
			self._cursorPos = self._cursorPos - 1;
			_IEB_RemoveChar();
		}
		return true;
	} else if( pKey == K_DEL ) {
		if( self._cursorPos < strlen( self._target.value ) )
			_IEB_RemoveChar();
		return true;
	} else if( 30 <= pAscii &&  pAscii <= 126 ) {
		_IEB_InsertChar( pAscii );
		return true;
	}
	return false;
};

void( bool pSelect, bool pUser ) Item_EditBox_Select =
{
	CtCall_Select( pSelect, pUser );
	if( pSelect && pUser )
		Sound_Play( self.soundSelected );
};

void() Item_EditBox_Destroy =
{
	CtCall_Destroy();
	Item_DataUser_Destroy();

	String_EntityFree( self, soundSelected );
	String_EntityFree( self, soundKey );
	String_EntityFree( self, soundMove );
};

void() Item_EditBox_Reinit =
{
	self._cursorPos = 0;
	CtCall_Reinit();
};

void() Item_EditBox_Spawn =
{
	Item_DataUser_Init();

	String_EntityZone( self, soundSelected );
	String_EntityZone( self, soundKey );
	String_EntityZone( self, soundMove );

	Sound_Precache( self.soundSelected );
	Sound_Precache( self.soundKey );
	Sound_Precache( self.soundMove );

	if( self.size == '0 0 0' && self._target && self._target.maxValue >= 0 ) {
		self.size_x = self.fontSize_x * self._target.maxValue + max( self.sizeCursor_x, self.sizeCursorFlash );
		self.size_y = self.fontSize_y;
	}

	self._reinit = Item_EditBox_Reinit;
	self._destroy = Item_EditBox_Destroy;
	self._key = Item_EditBox_Key;
	self._draw = Item_EditBox_Draw;
	self._select = Item_EditBox_Select;
	self._update = Item_EditBox_Update;

	CtCall_Init();
};
