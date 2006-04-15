// DP/Nex Menu
// control/visual/button.qc

////////////////
// Item_Button
///

bool( string pString ) _IB_IsPicture =
{
	return (substring( pString, 0, 1 ) == "$" );
};

string( string pString ) _IB_GetPath =
{
	return substring( pString, 1, 1000 );
};

// pString should be strzoned
vector( string pString ) _IB_GetSize =
{
	local vector lSize;
	if( _IB_IsPicture( pString ) )
		return Gfx_GetImageSize( _IB_GetPath( pString ) );

	lSize_x = strlen( pString ) * self.fontSize_x;
	lSize_y = self.fontSize_y;
	lSize_z = 0;

	return lSize;
};

vector() _IB_GetMaxSize =
{
	local vector lNormal, lSelected, lPressed, lSize;

	lNormal = _IB_GetSize( self.normal );
	lSelected = _IB_GetSize( self.selected );
	lPressed = _IB_GetSize( self.pressed );

	lSize_x = max( lNormal_x, lSelected_x, lPressed_x );
	lSize_y = max( lNormal_y, lSelected_y, lPressed_y );
	lSize_z = 0;

	return lSize;
};

void( string pName, vector pColor, float pAlpha, float pDrawFlag ) _IB_Draw =
{
	local vector lSize;
	local vector lPos;
	local vector lMaxSize;

	// Calculate the real size of the current state
	lSize = _IB_GetSize( pName );
	lMaxSize = _IB_GetMaxSize();
	if( _IB_IsPicture( pName ) ) {
		lSize_x = lSize_x * ( self.size_x / lMaxSize_x );
		lSize_y = lSize_y * ( self.size_y / lMaxSize_y );
	}

	// Get the position - it depends on the alignment
	//if( self.alignment == ITEM_ALIGN_LEFT ) // do nothing
	lPos_y = self.pos_y;
	if( self.alignment == ITEM_ALIGN_LEFT )
		lPos_x = self.pos_x;
	if( self.alignment == ITEM_ALIGN_CENTER )
		lPos_x = self.pos_x + (self.size_x - lSize_x ) / 2;
	else if( self.alignment == ITEM_ALIGN_RIGHT )
		lPos_x = self.pos_x + self.size_x - lSize_x;
	else
		lPos_x = self.pos_x;

	if( _IB_IsPicture( pName ) )
		Menu_DrawPicture( lPos, _IB_GetPath( pName ), lSize, pColor, pAlpha, pDrawFlag );
	else
		Menu_DrawString( lPos, pName, self.fontSize, pColor, pAlpha, pDrawFlag );
};

void() Item_Button_Draw =
{
	local string lText;

	if( self._state == ITEM_STATE_NORMAL )
		_IB_Draw( self.normal, self.color, self.alphas_x, self.drawFlags_x );
	else if( self._state == ITEM_STATE_SELECTED ) {
		if( self.selected )
			lText = self.selected;
		else
			lText = self.normal;
		_IB_Draw( lText, self.colorSelected, self.alphas_y, self.drawFlags_y );
	} else if( self._state == ITEM_STATE_PRESSED ) {
		if( self.pressed )
			lText = self.pressed;
		else if( self.selected )
			lText = self.selected;
		else
			lText = self.normal;
		_IB_Draw( lText, self.colorPressed, self.alphas_z, self.drawFlags_z );
	}
};

void() _IB_Calc =
{
	if( self.size == '0 0 0' )
		self.size = _IB_GetMaxSize();
};

void() Item_Button_Update =
{
	Item_Link_Update();

	_IB_Calc();

	if( self._presstime + ITEM_BUTTON_ACTIONTIME > Timer_Time )
		self._state = ITEM_STATE_PRESSED;
	else if( Item_Link_IsSelected() )
		self._state = ITEM_STATE_SELECTED;
	else
		self._state = ITEM_STATE_NORMAL;
};

void( bool pSelect, bool pUser ) Item_Button_Select =
{
	if( pSelect && pUser )
		Sound_Play( self.soundSelected );
};

bool( float pKey, float pAscii ) Item_Button_Key =
{
	if( Item_Link_Key( pKey, pAscii ) )
		return true;

	if( pKey == K_SPACE || pKey == K_ENTER || pKey == K_MOUSE1 ) {
		Sound_Play( self.soundPressed );
		self._presstime = Timer_Time;

		CtCall_Action();
		return true;
	}
	return false;
};

void() Item_Button_Destroy =
{
	CtCall_Destroy();

	String_EntityFree( self, normal );
	String_EntityFree( self, selected );
	String_EntityFree( self, pressed );
	String_EntityFree( self, soundSelected );
	String_EntityFree( self, soundPressed );

	Item_Link_Destroy();
};

void() Item_Button_Spawn =
{
	self._presstime = Timer_Time - 1 - ITEM_BUTTON_ACTIONTIME;

	// zone all the strings
	String_EntityZone( self, normal );
	String_EntityZone( self, selected );
	String_EntityZone( self, pressed );
	String_EntityZone( self, soundSelected );
	String_EntityZone( self, soundPressed );

	Item_Link_Init();

	// set the defaults, etc
	if( _IB_IsPicture( self.normal ) )
		Gfx_Precache( _IB_GetPath( self.normal ) );
	if( _IB_IsPicture( self.selected ) )
		Gfx_Precache( _IB_GetPath( self.selected ) );
	if( _IB_IsPicture( self.pressed ) )
		Gfx_Precache( _IB_GetPath( self.pressed ) );

	Sound_Precache( self.soundSelected );
	Sound_Precache( self.soundPressed );

	_IB_Calc();

	self._reinit = CtCall_Reinit;
	self._destroy = Item_Button_Destroy;
	self._key = Item_Button_Key;
	self._draw = Item_Button_Draw;
	self._select = Item_Button_Select;
	self._update = Item_Button_Update;

	CtCall_Init();
};
