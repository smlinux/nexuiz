// DP/Nex Menu
// control/visual/picture.qc

/////////////////
// Item_Picture
///

void() Item_Picture_Draw =
{
	Menu_DrawPicture( self.pos, self.picture, self.size, self.color, self.alpha, self.drawFlag );
};

void() Item_Picture_Destroy =
{
	String_EntityFree( self, picture );
};

void() Item_Picture_Spawn =
{
	// this items needs a picture field
	if( !self.picture ) {
		Menu_DeleteAfterFrame( self );
		return;
	}

	String_EntityZone( self, picture );

	// load the picture if it isnt loaded already
	Gfx_Precache( self.picture );

	if( self.flag == 0 )
		self.flag = self.flag | FLAG_NOSELECT;

	self._destroy = Item_Picture_Destroy;
	self._draw = Item_Picture_Draw;
};
