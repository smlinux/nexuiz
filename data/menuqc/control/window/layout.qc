// DP/Nex Menu
// control/window/layout.qc

////////////////
// Item_Layout
///

/*
===================
Item_Layout_Update
===================
*/
void() Item_Layout_Update =
{
	local entity lChild;
	local vector lCurrent;

	lCurrent = '0.0 0.0 0.0';
	for( lChild = self._child ; lChild ; lChild = lChild._next ) {
		if( Menu_HasRunFlag( lChild, RUNFLAG_HIDDEN ) )
			continue;

		if( self.direction_y ) {
			if( self.alignment == ITEM_ALIGN_FIRST && lChild._child )
				lChild.pos_x = lCurrent_x - lChild._child.size_x;
			else if( self.alignment == ITEM_ALIGN_LEFT )
				lChild.pos_x = lCurrent_x;
			else if( self.alignment == ITEM_ALIGN_CENTER )
				lChild.pos_x = lCurrent_x - lChild.size_x / 2;
			else
				lChild.pos_x = lCurrent_x - lChild.size_x;
		} else
			lChild.pos_x = lCurrent_x;

		if( self.direction_x ) {
			if( self.alignment == ITEM_ALIGN_LEFT )
				lChild.pos_y = lCurrent_y;
			else if( self.alignment == ITEM_ALIGN_CENTER )
				lChild.pos_y = lCurrent_y - lChild.size_y / 2;
			else if( self.alignment == ITEM_ALIGN_FIRST && lChild._child )
				lChild.pos_y = lCurrent_y - lChild._child.size_y;
			else
				lChild.pos_y = lCurrent_y - lChild.size_y;
		} else
			lChild.pos_y = lCurrent_y;

		if( self.direction_x )
			lCurrent_x += lChild.size_x + self.direction_x;
		else if( self.direction_y )
			lCurrent_y += lChild.size_y + self.direction_y;
	}
};

/*
===================
Item_Layout_Spawn
===================
*/
void() Item_Layout_Spawn =
{
	Item_Window_Spawn();

	Item_Layout_Update();

	self._update = Item_Layout_Update;
};
