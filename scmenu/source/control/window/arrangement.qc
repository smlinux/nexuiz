// DP/Nex Menu
// control/window/composition.qc

/*
===================
Item_Arrangement_CalculateSize
===================
*/
void() Item_Arrangement_CalculateSize =
{
	local vector lMin;
	local vector lMax;
	local entity lChild;

	// TODO: this is garbage, fix this
	lMax = '0 0 0';
	lMin_x = INFINITY;
	lMin_y = INFINITY;
	for( lChild = self._child ; lChild ; lChild = lChild._next ) {
		if( Menu_HasRunFlag( lChild, RUNFLAG_HIDDEN ) )
			continue;

		lMin_x = min( lMin_x, lChild.pos_x );
		lMin_y = min( lMin_y, lChild.pos_y );
		lMax_x = max( lMax_x, lChild.pos_x + lChild.size_x );
		lMax_y = max( lMax_y, lChild.pos_y + lChild.size_y );
	}
	self.size = lMax - lMin;
};

/*
===================
Item_Arrangement_Update
===================
*/
void() Item_Arrangement_Update =
{
	Item_Layout_Update();

	Item_Arrangement_CalculateSize();

	if( self.direction_x ) {
		if( self.alignment == ITEM_ALIGN_LEFT )
			self.origin_y = 0;
		else if( self.alignment == ITEM_ALIGN_CENTER || self.alignment == ITEM_ALIGN_FIRST )
			self.origin_y = self.size_y / 2;
		else
			self.origin_y = self.size_y;
	} else
		self.origin_y = 0;
	if( self.direction_y ) {
		if( self.alignment == ITEM_ALIGN_LEFT )
			self.origin_x = 0;
		else if( self.alignment == ITEM_ALIGN_CENTER || self.alignment == ITEM_ALIGN_FIRST )
			self.origin_x = self.size_x / 2;
		else
			self.origin_x = self.size_x;
	} else
		self.origin_x = 0;
};

/*
===================
Item_Arrangement_Spawn
===================
*/
void() Item_Arrangement_Spawn =
{
	Item_Layout_Spawn();

	Item_Arrangement_Update();

	self._update = Item_Arrangement_Update;
};


