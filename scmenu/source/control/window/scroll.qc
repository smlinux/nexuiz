// DP/Nex Menu
// control/window/scroll.qc

void() Item_ScrollWindow_Update =
{
	local float lLevel;
	local float lOldLevel;
	local entity lParent;

	// reset _link and return if the window isnt owner of the currently selected item
	if( !Menu_IsVisible( self ) || !_Menu_IsEmbeddedParentOf( Menu_ActiveItem, self._child ) ) {
		self._link = null_entity;
		return;
	}
	// if the window has been selected just now, we set _link and scroll to its position
	// if the selection has changed we also scroll down
	// only if nothing has changed, we do nothing, too (this makes scrollbar support possible)
	if( self._link == Menu_ActiveItem ) {
		return;
	} else {
		self._link = Menu_ActiveItem;
	}

	// find the lLevel
	lLevel = Menu_ActiveItem.pos_y;
	for( lParent = Menu_ActiveItem._parent; lParent != self ; lParent = lParent._parent )
		lLevel += lParent.origin_y + lParent.pos_y;

	// self.origin_y is negative to move everything up, -self.origin_y is the level
	lOldLevel = -self.origin_y;
	if( ( Menu_ActiveItem.size_y > self.size_y && lLevel + Menu_ActiveItem.size_y > lOldLevel && lLevel < self.size_y + lOldLevel )
	 || ( lLevel >= lOldLevel && lLevel + Menu_ActiveItem.size_y < lOldLevel + self.size_y ) )
		return;
	// adapt the origin
	// TODO: make this a bit more flexible
	if( lOldLevel < lLevel )
		self.origin_y = self.direction_x - lLevel;
	else
		self.origin_y = self.size_y - self.direction_x - lLevel;

	// now limit it
	self.origin_y = bound( self.size_y - self._child.size_y, self.origin_y, 0 );
	//print( ftos( self.origin_y ), "\n" );
};

void() Item_ScrollWindow_Reinit =
{
	self.origin_y = 0;
};

void() Item_ScrollWindow_Spawn =
{
	Item_Window_Spawn();

	self._update = Item_ScrollWindow_Update;
	self._reinit = Item_ScrollWindow_Reinit;
};
