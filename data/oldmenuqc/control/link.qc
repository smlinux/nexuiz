// DP/Nex Menu
// control/link.qc

////////////////
// [Item_Link]
///

/*
The Link is only established if self.link is valid.
If it is valid, the item is made no selectable since the link should be selectable
*/

void() Item_Link_Update =
{
	if( self.link == "" )
		self._link = null_entity;
	else if( self.link != self._link.name ) {
		self._link = Menu_GetItem( self.link );
		self.flag = self.flag | FLAG_NOSELECT;
	}
};

bool( float pKey, float pAscii ) Item_Link_Key =
{
	if( self._link )
		return Raise_Key( self._link, pKey, pAscii );

	return false;
};

void() Item_Link_MouseEnter =
{
	if( self._link && Menu_IsSelectable( self._link ) )
		Menu_Select( self._link, true );
};

bool() Item_Link_IsSelected =
{
	if( Menu_ActiveItem == self )
		return true;

	if( self._link )
		return (Menu_ActiveItem == self._link);
	else
		return false;
};

void() Item_Link_Destroy =
{
	String_EntityFree( self, link );
};

void() Item_Link_Init =
{
	String_EntityZone( self, link );

	Item_Link_Update();

	self._destroy = Item_Link_Destroy;
	self._key = Item_Link_Key;
	self._mouseEnter = Item_Link_MouseEnter;
	self._update = Item_Link_MouseEnter;
};
