// DP/Nex Menu
// control/window/reference.qc

//////////////////
// Item_Reference
///
// NOTE: You use have multiple links to the same window, only one should be visible per frame,
// NOTE: else the behavior would be unexpectable
// NOTE: FIXME: Atm only references to windows with no parents( thus top layer ) work

/*
===================
Item_Reference_Update
===================
*/
void() Item_Reference_Update =
{
	// update the link and the link's parent
	if( self.link == "" ) {
		self._child = null_entity;
		return;
	}

	if( self.link != self._link.name )
		self._link = Menu_GetItem( self.link );

	self._child = self._link;
	self._child._parent = self;
};

/*
===================
Item_Reference_Draw
===================
*/
void() Item_Reference_Draw =
{
	if( sys_debug_ref )
		Menu_Fill( self.pos, self.size, '0 0 0.2', 1.0, DRAWFLAG_ADDITIVE );
};

/*
===================
Item_Reference_Destroy
===================
*/
void() Item_Reference_Destroy =
{
	String_EntityFree( self, link );
};

/*
===================
Item_Reference_Spawn
===================
*/
void() Item_Reference_Spawn =
{
	self.flag = self.flag | FLAG_NOSELECT | FLAG_EMBEDDED;

	String_EntityZone( self, link );

	Item_Reference_Update();

	self._destroy = Item_Reference_Destroy;
	self._draw = Item_Reference_Draw;
	self._update = Item_Reference_Update;
};
