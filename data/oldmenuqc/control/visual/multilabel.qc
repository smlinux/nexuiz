// DP/Nex Menu
// control/visual/multilabel.qc

/*
===================
_IML_Calc
===================
*/
void() _IML_Calc =
{
	local float lMaxWidth;
	local float lLineNumber;
	local vector lLine;

	lMaxWidth = 0;
	lLineNumber = 0;
	lLine = '0 0 0';
	do {
		if( self.wrap )
			lLine = Util_GetEndOfWrappedLine( self.text, lLine, self.wrap );
		else
			lLine = Util_GetEndOfLine( self.text, lLine );

		++lLineNumber;
		lMaxWidth = max( lMaxWidth, lLine_z );
	} while( lLine_x != lLine_y );

	self.size_x = lMaxWidth * self.fontSize_x;
	self.size_y = lLineNumber * self.fontSize_y;
};

/*
===================
_IML_DrawLine
===================
*/
void( vector pPosition, string pText ) _IML_DrawLine =
{
	if( self.alignment == ITEM_ALIGN_CENTER )
		pPosition_x = self.pos_x + (self.size_x - strlen( pText ) * self.fontSize_x) / 2;
	else if( self.alignment == ITEM_ALIGN_RIGHT )
		pPosition_x = self.pos_x + self.size_x - strlen( pText ) * self.fontSize_x;
	else
		pPosition_x = self.pos_x;

	Menu_DrawString( pPosition, pText, self.fontSize, self.color, self.alpha, self.drawFlag );
};

/*
===================
Item_MultiLable_Draw
===================
*/
void() Item_MultiLabel_Draw =
{
	local vector lPosition;
	local vector lLine;

	lPosition_y = self.pos_y;
	lLine = '0 0 0';
	do  {
		if( self.wrap )
			lLine = Util_GetEndOfWrappedLine( self.text, lLine, self.wrap );
		else
			lLine = Util_GetEndOfLine( self.text, lLine );

		_IML_DrawLine( lPosition, substring( self.text, lLine_x - lLine_z + 1, lLine_z ) );
		lPosition_y = lPosition_y + self.fontSize_y;
	} while( lLine_x != lLine_y );
};

/*
===================
Item_MultiLabel_Update
===================
*/
void() Item_MultiLabel_Update =
{
	if( self.size == '0 0 0' )
		_IML_Calc();
};

/*
===================
Item_MultiLabel_Destroy
===================
*/
void() Item_MultiLabel_Destroy =
{
	String_EntityFree( self, text );
};

/*
===================
Item_MultiLabel_Spawn
===================
*/
void() Item_MultiLabel_Spawn =
{
	if( self.flag == 0 )
		self.flag = self.flag | FLAG_DRAWUPDATEONLY;

	String_EntityZone( self, text );

	Item_MultiLabel_Update();

	self._destroy = Item_MultiLabel_Destroy;
	self._draw = Item_MultiLabel_Draw;
	self._update = Item_MultiLabel_Update;
};
