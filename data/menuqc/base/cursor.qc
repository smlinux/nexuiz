// NG-Menu
// base/cursor.qc

void() Cursor_Init =
{
	// default cursor (embedded into DP): ui/mousepointer.tga
	if( Gfx_Precache( CURSOR_PATH ) )
		Cursor_Current = CURSOR_PATH;
	else {
		Cursor_Current = "ui/mousepointer.tga";
		Gfx_Precache( Cursor_Current );
	}

	Cursor_Position = Cursor_Relative = '0 0 0';

	Cursor_Animation = Cursor_DefaultAnimation;
};

void() Cursor_Quit =
{
};

void() Cursor_Display =
{
	setmousetarget( MT_MENU );
};

void() Cursor_Hide =
{
	setmousetarget( MT_CLIENT );
};

void() Cursor_Draw =
{
	local vector lPos;
	local vector lSize;

	lSize = Gfx_GetImageSize( Cursor_Current ) * Cursor_Scale;
	lPos_x = Cursor_Position_x - lSize_x * Cursor_Offset_x;
	lPos_y = Cursor_Position_y - lSize_y * Cursor_Offset_y;
	lPos_z = 0.0;

	Gfx_DrawPic( lPos, Cursor_Current, lSize, Cursor_Color, Cursor_Transparency, Cursor_Flag );
};

void() Cursor_Update =
{
	local vector lRelPos;
	local float lMenuMouseSpeed;
	lMenuMouseSpeed = cvar("scmenu_mouse_speed");
	if(lMenuMouseSpeed == 0)
		lMenuMouseSpeed = 1;
	else
		lMenuMouseSpeed = bound(0.7, lMenuMouseSpeed, 3.0);

	lRelPos = getmousepos();
	lRelPos = Gfx_ConToMen( lRelPos );

	Cursor_Relative_x = lRelPos_x * Cursor_Speed_x * lMenuMouseSpeed;
	Cursor_Relative_y = lRelPos_y * Cursor_Speed_y * lMenuMouseSpeed;

	Cursor_Relative_x = bound( 0.0, Cursor_Position_x + Cursor_Relative_x, Gfx_Menu_Width ) - Cursor_Position_x;
	Cursor_Relative_y = bound( 0.0, Cursor_Position_y + Cursor_Relative_y, Gfx_Menu_Height ) - Cursor_Position_y;

	Cursor_Position_x = Cursor_Position_x + Cursor_Relative_x;
	Cursor_Position_y = Cursor_Position_y + Cursor_Relative_y;
	Cursor_Position_z = 0.0;

	Cursor_Animation();
};

void() Cursor_DefaultAnimation =
{
};

void( vector pRelPos, string pText, vector pScale, vector pColor, float pAlpha, float pDrawFlag ) Cursor_PrintInfo =
{
	local vector lPosition;
	local vector lSize;

	lSize = Gfx_GetImageSize( Cursor_Current ) * Cursor_Scale;

	if( pRelPos_x != 0 ) {
		if( pRelPos_x > 0 ) // align it on the left
			lPosition_x = Cursor_Position_x + lSize_x * (Cursor_Offset_x + 0.5 + pRelPos_x / 2) ;
		else if( pRelPos_x < 0 ) // align it on the right
			lPosition_x = Cursor_Position_x + lSize_x * (Cursor_Offset_x + 0.5 + pRelPos_x / 2) -
					pScale_x * strlen( pText );
		lPosition_y = Cursor_Position_y + lSize_y * (Cursor_Offset_y + 0.5 + pRelPos_y / 2 ) - pScale_y / 2;
	} else
		lPosition_x = Cursor_Position_x + lSize_x * (Cursor_Offset_x + 0.5) -
				pScale_x * strlen( pText ) / 2;

	if( pRelPos_y != 0 ) {
		if( pRelPos_y > 0 )
			lPosition_y = Cursor_Position_y + lSize_y * (Cursor_Offset_y + 0.5 - pRelPos_y / 2) - pScale_y;
		else if( pRelPos_y < 0 )
			lPosition_y = Cursor_Position_y + lSize_y * (Cursor_Offset_y + 0.5 - pRelPos_y / 2);
	}

	Gfx_DrawString( lPosition, pText, pScale, pColor, pAlpha, pDrawFlag );
};
