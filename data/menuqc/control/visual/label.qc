// DP/Nex Menu
// control/visual/label.qc

//////////////
// Item_Label
///

void() _IL_Calc =
{
	// calculate the size if necessary
	if( self.size == '0 0 0' ) {
		self.size_x = self.fontSize_x * strlen( self.text );
		self.size_y = self.fontSize_y;
	} else if( self.fontSize == '0 0 0' ) {
		self.fontSize_x = self.size_x / strlen( self.text );
		self.fontSize_y = self.size_y;
	}
};

void() Item_Label_Update =
{
	_IL_Calc();
};

void() Item_Label_Draw =
{
	local vector lAligned;
	// do we need to align the text?
	if( self.alignment == ITEM_ALIGN_LEFT )
		lAligned_x = self.pos_x;
	else if( self.alignment & ITEM_ALIGN_CENTER )
		lAligned_x = self.pos_x + (self.size_x - strlen( self.text ) * self.fontSize_x) / 2;
	else if( self.alignment & ITEM_ALIGN_RIGHT )
		lAligned_x = self.pos_x + self.size_x - strlen( self.text ) * self.fontSize_x;
	else
		lAligned_x = self.pos_x;
	lAligned_y = self.pos_y;

	Menu_DrawString( lAligned, self.text, self.fontSize, self.color, self.alpha, self.drawFlag );
};

void() Item_Label_Destroy =
{
	String_EntityFree( self, text );
};

void() Item_Label_Spawn =
{
	if( self.flag == 0 )
		self.flag = self.flag | FLAG_DRAWUPDATEONLY;

	String_EntityZone( self, text );

	_IL_Calc();

	if( self.alignment & ITEM_ALIGN_FIX_CENTER )
		self.pos_x = self.pos_x - self.size_x / 2;
	else if( self.alignment & ITEM_ALIGN_FIX_LEFT )
		self.pos_x = self.pos_x - self.size_x;

	self._destroy = Item_Label_Destroy;
	self._draw = Item_Label_Draw;
	self._update = Item_Label_Update;
};
