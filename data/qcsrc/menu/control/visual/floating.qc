// DP/Nex Menu
// control/visual/floating.qc

bool( float pKey, float pAscii ) Item_FloatingArea_Key =
{
	if( pKey == K_MOUSE1 || pKey == K_ENTER ) {
		if( self._state != ITEM_STATE_PRESSED )
			self._state = ITEM_STATE_PRESSED;
		else
			self._state = ITEM_STATE_NORMAL;

		return true;
	} else if( pKey == K_ESCAPE )
		self._state = ITEM_STATE_NORMAL;

	return false;
};

void() Item_FloatingArea_Update =
{
	if( !self.target ) {
		self._state = ITEM_STATE_NORMAL;
		return;
	} else if( self.target != self._target.name )
		self._target = Menu_GetItem( self.target );

	if( self._state == ITEM_STATE_PRESSED )
		self._target.pos = self._target.pos + Cursor_Relative;
	else if( Menu_ActiveItem == self )
		self._state = ITEM_STATE_SELECTED;
};

void() Item_FloatingArea_Destroy =
{
	String_EntityFree( self, target );
};

void( bool pSelect, bool pUser ) Item_FloatingArea_Select =
{
	if( !pSelect && self._state == ITEM_STATE_PRESSED )
		Menu_CorrectSelection( self, false );
};

void() Item_FloatingArea_Spawn =
{
	self.flag = self.flag | FLAG_CHILDDRAWUPDATEONLY;

	String_EntityZone( self, target );

	self._update = Item_FloatingArea_Update;
	self._key = Item_FloatingArea_Key;
	self._destroy = Item_FloatingArea_Destroy;
	self._select = Item_FloatingArea_Select;
};
