// DP/Nex Menu
// control/visual/scrollbar.qc

const float _VSB_UP_HEIGHT = 20;
const float _VSB_DOWN_HEIGHT = 20;
const float _VSB_PRECISION = 5;
const float _VSB_MINHEIGHT = 10;

const vector _VSB_CLICKAREA_COLOR = '1 1 1';
const vector _VSB_SCOLLER_COLOR	= '1 1 1';
const vector _VSB_SCROLLAREA_COLOR = '1 1 1';

// todo: maybe  use fields to retrieve the picture names?
const string _VSB_SCOLLER_PICTURE = "gfx/scroll_scroller";
const string _VSB_SCROLLAREA_PICTURE = "gfx/scroll_background";
const string _VSB_BUTTON_PICTURE = "gfx/scroll_up";

// scroller == scroll button
float() _IVSB_GetSizeOfScroller = {
	local float lScrollerRange;
	local float lVisibleSize;
	local float lTotalSize;
	local float lScrollerSize;

	lTotalSize = self._target._child.size_y;
	lVisibleSize = self.size_y;
	lScrollerRange = self.size_y - _VSB_DOWN_HEIGHT - _VSB_UP_HEIGHT;

	lScrollerSize = lVisibleSize * lScrollerRange / lTotalSize;
	lScrollerSize = max( _VSB_MINHEIGHT, lScrollerSize );

	return lScrollerSize;
}

void() Item_VScrollBar_Draw = {
	local vector lPosition;
	local vector lSize;

	if( self._target == null_entity ) {
		return;
	}

	lPosition = self.pos;
	lSize = self.size;
	lSize_y = _VSB_UP_HEIGHT;
	Menu_DrawPicture( lPosition, _VSB_BUTTON_PICTURE, lSize, _VSB_CLICKAREA_COLOR, 1.0, 0 );

	lPosition_y = self.pos_y + _VSB_UP_HEIGHT;
	lSize_y = self.size_y - _VSB_UP_HEIGHT - _VSB_DOWN_HEIGHT;
	Menu_DrawPicture( lPosition, _VSB_SCROLLAREA_PICTURE,lSize, _VSB_SCROLLAREA_COLOR, 1.0, 0 );

	lPosition_y = self.pos_y + self.size_y - _VSB_DOWN_HEIGHT;
	lSize_y = _VSB_DOWN_HEIGHT;
	Menu_DrawPicture( lPosition, _VSB_BUTTON_PICTURE, lSize, _VSB_CLICKAREA_COLOR, 1.0, 0 );

	lSize_y = _IVSB_GetSizeOfScroller();
	lPosition_y = self.pos_y + _VSB_UP_HEIGHT - self._target.origin_y * (self.size_y - _VSB_DOWN_HEIGHT - _VSB_UP_HEIGHT - lSize_y) / (self._target._child.size_y - self.size_y);
	Menu_DrawPicture( lPosition, _VSB_SCOLLER_PICTURE, lSize, _VSB_SCOLLER_COLOR, 1.0, 0 );
};

void() _IVSB_RangeBound = {
	self._target.origin_y = bound( - (self._target._child.size_y - self.size_y) , self._target.origin_y, 0 );
};

void() _IVSB_ScrollUp = {
	self._target.origin_y = self._target.origin_y + _VSB_PRECISION;
	_IVSB_RangeBound();
};

void() _IVSB_ScrollDown = {
	self._target.origin_y = self._target.origin_y - _VSB_PRECISION;
	_IVSB_RangeBound();
};

void( float lLevel ) _IVSB_MouseSelect = {
	local float lScrollerRange;
	local float lVisibleSize;
	local float lTotalSize;
	local float lScrollerSize;

	lTotalSize = self._target._child.size_y;
	lVisibleSize = self.size_y;
	lScrollerRange = self.size_y - _VSB_DOWN_HEIGHT - _VSB_UP_HEIGHT;
	lScrollerSize = _IVSB_GetSizeOfScroller();

	lLevel = lLevel - _VSB_UP_HEIGHT - lScrollerSize / 2;
	self._target.origin_y = - ( lLevel * (lTotalSize - lVisibleSize) / (lScrollerRange - lScrollerSize ) );
	_IVSB_RangeBound();
};

bool( float pKey, float Ascii ) Item_VScrollBar_Key = {
	if( self._target == null_entity ) {
		return false;
	}

	if( pKey == K_UPARROW ) {
		_IVSB_ScrollUp();
		return true;
	} else if( pKey == K_DOWNARROW ) {
		_IVSB_ScrollDown();
		return true;
	} else if( pKey == K_MOUSE1 ) {
		local float lLevel;

		if( !Util_InRect( Menu_Cursor_Position, self.pos, self.size ) ) {
			return false;
		}

		lLevel = Menu_Cursor_Position_y - self.pos_y;
		if( lLevel < _VSB_UP_HEIGHT ) {
			_IVSB_ScrollUp();
		} else if( lLevel >= self.size_y - _VSB_DOWN_HEIGHT ) {
			_IVSB_ScrollDown();
		} else {
			_IVSB_MouseSelect( lLevel );
		}
		return true;
	} else if( pKey == K_MWHEELUP ) {
		_IVSB_ScrollUp();
		return true;
	} else if( pKey == K_MWHEELDOWN ) {
		_IVSB_ScrollDown();
		return true;
	}
	return false;
};

void() Item_VScrollBar_Update =
{
	if( self.target == "" ) {
		self._target = null_entity;
	} else if( self.target != self._target.name ) {
		self._target = Menu_GetItem( self.target );
	}

	if( self._target == null_entity ) {
		return;
	}

	// set size height to the height of the scrollwindow's parent
	self.size_y = self._target.size_y;

	// if the scrollbar isnt needed it becomes invisible
	if( self.size_y >= self._target._child.size_y ) {
		self.flag = self.flag | FLAG_HIDDEN;
	} else if( self.flag & FLAG_HIDDEN ) {
		self.flag = self.flag - FLAG_HIDDEN;
	}
};

void() Item_VScrollBar_Destroy = {
	String_EntityFree( self, target );
};

void() Item_VScrollBar_Spawn = {
	String_EntityZone( self, target );
	Item_VScrollBar_Update();

	self._update = Item_VScrollBar_Update;
	self._key = Item_VScrollBar_Key;
	self._draw = Item_VScrollBar_Draw;
	self._destroy = Item_VScrollBar_Destroy;
};
