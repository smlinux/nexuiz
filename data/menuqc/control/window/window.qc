// DP/Nex Menu
// control/window/normal.qc

////////////////
// Item_Window
///

/*
===================
Item_Window_Key
===================
*/
bool( float pKey, float pAscii ) Item_Window_Key =
{
	if( CtCall_Key( pKey, pAscii ) )
		return true;

	return false;
};

void() Item_Window_Draw =
{
	if( !sys_debug)
		return;
	if( Menu_HasRunFlag( self, RUNFLAG_MOUSEINAREA ) ) {
		if( sys_debug_area ) {
			local entity lChild;
			Menu_Fill( self.pos, self.size, '0.2 0 0', 0.2, DRAWFLAG_NORMAL );

			for( lChild = self._child ; lChild ; lChild = lChild._next ) {
				local vector lColor;

				if( !Menu_IsVisible( lChild ) )
					continue;

				lColor_x =  mod( fabs( lChild.orderPos ) + 5, 9 ) / 8;
				lColor_y = mod( fabs( lChild.orderPos * 8 ), 9 ) / 8;
				lColor_z = mod( fabs( lChild.orderPos * 7 ), 9 ) / 8;
				Menu_Fill( self.pos + self.origin + lChild.pos, lChild.size, lColor, 0.2, DRAWFLAG_NORMAL );
			}
		}
		if( sys_debug_mouse )
			sys_debug_cursor_localpos = Menu_Cursor_Position - self.origin - self.pos;
	}
};

/*
===================
Item_Window_Spawn
===================
*/
void() Item_Window_Spawn =
{
	self.flag = self.flag | FLAG_NOSELECT;

	self._key = Item_Window_Key;
	self._draw = Item_Window_Draw;
};
