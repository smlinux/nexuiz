// DP/Nex Menu
// control/visual/rect.qc

///////////////
// Item_Rect
///

void() Item_Rect_Draw =
{
	Menu_Fill( self.pos, self.size, self.color, self.alpha, self.drawFlag );
};

void() Item_Rect_Spawn =
{
	self.flag = self.flag | FLAG_NOSELECT;

	self._draw = Item_Rect_Draw;
};
