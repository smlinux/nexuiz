// DP/Nex Menu
// system/mgfx.qc

void( vector pPos, vector pSize, vector pColor, float pAlpha, float pDrawFlag, string pText ) _Mgfx_Debug_Info =
{
	if( !sys_debug_mgfx )
		return;

	pText = String_Zone( pText );

	print( "MGFX output: ", vtos( pPos ), " - ", vtos( pSize), " C", vtos( pColor ) );
	print( " A", ftos( pAlpha ), " X", ftos( pDrawFlag ), " ", pText, "\n" );

	String_Free( pText );
};

/*
===================
Menu_MenToOrg
===================
*/
vector( vector pPos )  Menu_MenToOrg =
{
	return pPos - Menu_Origin;
};

/*
===================
Menu_OrgToMen
===================
*/
vector( vector pPos )  Menu_OrgToMen =
{
	return pPos + Menu_Origin;
};

/*
===================
Menu_ConToOrg
===================
*/
vector( vector pPos )  Menu_ConToOrg =
{
	pPos = Gfx_ConToMen( pPos );
	return Menu_MenToOrg( pPos );
};

/*
===================
Menu_OrgToCon
===================
*/
vector( vector pPos )  Menu_OrgToCon =
{
	pPos = Menu_OrgToMen( pPos );
	return Gfx_MenToCon( pPos );
};

/*
===================
Menu_DrawCharacter
===================
*/
float( vector pPosition, float pCharacter, vector pScale, vector pRGB, float pAlpha, float pFlag )
Menu_DrawCharacter =
{
	_Mgfx_Debug_Info( pPosition, pScale, pRGB, pAlpha, pFlag, strcat( "DrawChar: ", ftos( pCharacter ) ) );

	pPosition = Menu_OrgToMen( pPosition );
	return Gfx_DrawCharacter( pPosition, pCharacter, pScale, pRGB, pAlpha, pFlag );
};

/*
===================
Menu_DrawString
===================
*/
float( vector pPosition, string pText, vector pScale, vector pRGB, float pAlpha, float pFlag )
Menu_DrawString =
{
	// TODO: FIXME: do I really want this?
	if( !pText )
		return 1;

	_Mgfx_Debug_Info( pPosition, pScale, pRGB, pAlpha, pFlag, strcat( "DrawString: ", pText ) );

	pPosition = Menu_OrgToMen( pPosition );
	return Gfx_DrawString( pPosition, pText, pScale, pRGB, pAlpha, pFlag );
};

/*
===================
Menu_DrawPicture
===================
*/
float( vector pPosition, string pPicture, vector pSize, vector pRGB, float pAlpha, float pFlag )
Menu_DrawPicture =
{
	_Mgfx_Debug_Info( pPosition, pSize, pRGB, pAlpha, pFlag, strcat( "DrawPicture: ", pPicture ) );

	pPosition = Menu_OrgToMen( pPosition );
	return Gfx_DrawPic( pPosition, pPicture, pSize, pRGB, pAlpha, pFlag );
};

/*
===================
Menu_Fill
===================
*/
float( vector pPosition, vector pSize, vector pRGB, float pAlpha, float pFlag )
Menu_Fill =
{
	_Mgfx_Debug_Info( pPosition, pSize, pRGB, pAlpha, pFlag, "Fill" );

	pPosition = Menu_OrgToMen( pPosition );
	return Gfx_Fill( pPosition, pSize, pRGB, pAlpha, pFlag );
};

/*
===================
Menu_SetClipArea
===================
*/
void( float pX, float pY, float pWidth, float pHeight )
Menu_SetClipArea =
{
	local vector lPosition;
	local vector lDelta;
	local vector lSize;

	lPosition_x = pX;
	lPosition_y = pY;
	lPosition = Menu_OrgToMen( lPosition);

	lSize_x = pWidth;
	lSize_y = pHeight;
	// clip it to the current clip area
	lDelta = Util_GetClipDelta( lPosition, Menu_Clip_Position, Menu_Clip_Size );
	lPosition = lPosition + lDelta;
	lSize = Util_ClipRect( lPosition, lSize - lDelta, Menu_Clip_Position, Menu_Clip_Size );

	Gfx_SetClipArea( lPosition_x, lPosition_y, pWidth, pHeight );
};

/*
===================
Menu_ResetClipArea
===================
*/
void()
Menu_ResetClipArea =
{
	if( Menu_Clip_Position == '0 0 0' && Menu_Clip_Size == '0 0 0' )
		Gfx_ResetClipArea();
	else
		Gfx_SetClipArea( Menu_Clip_Position_x, Menu_Clip_Position_y, Menu_Clip_Size_x, Menu_Clip_Size_y );
}

