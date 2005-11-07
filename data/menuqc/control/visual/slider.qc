// DP/Nex Menu
// control/visual/slider.qc

////////////////
// Item_Slider
///

// returns a value in the range of 0..1
float() _IS_GetValue =
{
	local float lValue;
	local entity lLink;

	if( !self._target )
		return 0;

	lLink = self._target;

	Raise_DataEvent( lLink, ITEM_DATALINK_GET );

	if( lLink.maxValue <= lLink.minValue )
		lValue = 0;
	else
		lValue = ( lLink._realValue - lLink.minValue ) / (lLink.maxValue - lLink.minValue);
	return lValue;
};

void( bool pSelect, bool pUser ) Item_Slider_Select =
{
	if( pSelect & pUser )
		Sound_Play( self.soundSelected );
};

void() Item_Slider_Draw =
{
	local float lValue;
	local vector lSliderPos;

	lValue = _IS_GetValue();
	lSliderPos_x = self.pos_x + self.size_x * (self.proportions_x + lValue * self.proportions_y) - lValue * self.sizeSlider_x;
	lSliderPos_y = self.pos_y + (self.size_y - self.sizeSlider_y) * (1 - (self.direction_y - self.direction_x) * lValue - self.direction_x);

	if( Menu_ActiveItem == self ) {
		Menu_DrawPicture( self.pos, self.picture, self.size, self.colorSelected, self.alphas_y, self.drawFlags_y );
		Menu_DrawPicture( lSliderPos, self.pictureSlider, self.sizeSlider, self.colorSelected, self.alphas_y, self.drawFlags_y );
	} else {
		Menu_DrawPicture( self.pos, self.picture, self.size, self.color, self.alphas_x, self.drawFlags_x );
		Menu_DrawPicture( lSliderPos, self.pictureSlider, self.sizeSlider, self.color, self.alphas_x, self.drawFlags_x );
	}
};

void( float pValue ) _IS_Change =
{
	if( pValue < 0 )
		Sound_Play( self.soundDecrease );
	else
		Sound_Play( self.soundIncrease );

	self._target._realValue = self._target._realValue + pValue;
	// FIXME: self._target.realValue += pValue; FTEQCC BUG
	Raise_DataEvent( self._target, ITEM_DATALINK_SET );

	CtCall_Action();
};

bool( float pKey, float pAscii ) Item_Slider_Key =
{
	if( !self._target )
		return false;

	switch( pKey ) {
		case K_LEFTARROW:
			_IS_Change( 0 - self._target.stepValue );
			return true;
			break;
		case K_RIGHTARROW:
			_IS_Change( self._target.stepValue );
			return true;
			break;
		case K_MOUSE1: {
			local float lPos;

			// test if it is within the slider area at all
			// TODO: Check if this is necessary with the future composition implementations
			if( !Util_InRect( Menu_Cursor_Position, self.pos, self.size ) )
				return false;
			lPos = ( Menu_Cursor_Position_x - self.pos_x ) / self.size_x;
			if( lPos <= self.proportions_x )
				_IS_Change( 0 - self._target.stepValue );
			else if( lPos <= self.proportions_x + self.proportions_y && self.proportions_y ) {
				local float lValue;

				lValue = Menu_Cursor_Position_x - self.pos_x - self.sizeSlider_x / 2 - self.size_x * self.proportions_x;
				lValue = lValue / (self.size_x * self.proportions_y - self.sizeSlider_x);
				lValue = lValue * ( self._target.maxValue - self._target.minValue ) + self._target.minValue;
				_IS_Change( lValue - self._target._realValue );
			} else
				_IS_Change( self._target.stepValue );
			return true;
		}
	}
	return false;
};

void() Item_Slider_Destroy =
{
	CtCall_Destroy();

	Item_DataUser_Destroy();

	String_EntityFree( self, picture );
	String_EntityFree( self, pictureSlider );
	String_EntityFree( self, soundSelected );
	String_EntityFree( self, soundIncrease );
	String_EntityFree( self, soundDecrease );
};

void() Item_Slider_Spawn =
{
	String_EntityZone( self, picture );
	String_EntityZone( self, pictureSlider );
	String_EntityZone( self, soundSelected );
	String_EntityZone( self, soundIncrease );
	String_EntityZone( self, soundDecrease );
	Item_DataUser_Init();

	Gfx_Precache( self.picture );
	Gfx_Precache( self.pictureSlider );
	Sound_Precache( self.soundSelected );
	Sound_Precache( self.soundIncrease );
	Sound_Precache( self.soundDecrease );

	if( self.size == '0 0 0' )
		self.size = Gfx_GetImageSize( self.picture );
	if( self.sizeSlider == '0 0 0' )
		self.sizeSlider = Gfx_GetImageSize( self.pictureSlider );

	self._reinit = CtCall_Reinit;
	self._destroy = Item_Slider_Destroy;
	self._key = Item_Slider_Key;
	self._draw = Item_Slider_Draw;
	self._select = Item_Slider_Select;
	self._update = Item_DataUser_Update;

	CtCall_Init();
};
